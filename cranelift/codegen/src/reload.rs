//! Reloading values from memory where registers run out.
//!
//! A value that a load read stays in memory until something may write over
//! it. Where more values are live than the target
//! has registers, the register allocator spills some of them: a store to the
//! stack and a load before each later use. A value still in memory needs
//! neither. Loading it again from where it is, right before a later use, ends
//! its live range at an earlier use, and lowering can merge the new load into
//! its use. A load's address is known early, so the new load runs ahead of the
//! computation that needs it. A value a store wrote is in memory too, but
//! loading it back puts the store's forwarding latency on the path from the
//! value to its use, which slowed a latency-bound hash (BLAKE2) twofold. For
//! the same reason a load of a place its block stored to earlier is no home:
//! the new load's address is ready long before the store, so the core runs
//! the load first and must flush when the store turns out to write its bytes.
//!
//! Each block is scanned in order, tracking where in memory each value is. An
//! access's place is a base, a value or a stack slot, and a range of byte
//! offsets from it. Two places with one base and disjoint ranges never
//! overlap, nor do two stack slots, nor a stack slot whose address only ever
//! reaches the addresses of loads and stores (or the arguments of C memory
//! routines) and a place based on a value. Other calls cannot reach such a
//! stack slot either. Then each value's uses, from
//! its last, load it again while more values are live between that use and
//! the one before it than the target has registers, and the address to load
//! from is live there anyway.

use crate::FxHashMap;
use crate::entity::{EntitySet, SecondaryMap};
use crate::ir::immediates::Offset32;
use crate::ir::{
    Block, ExternalName, Function, Inst, InstructionData, LibCall, MemFlags, Opcode, StackSlot,
    Type, Value, ValueDef,
};
use crate::packed_option::PackedOption;
use alloc::vec::Vec;
use smallvec::{SmallVec, smallvec};

/// The most instructions of a block whose values reload. BLAKE2's
/// compression unrolls ten rounds into one block of 1,230 instructions, each
/// message word used once a round; reloading the words there gained nothing
/// but moved the register allocation of the whole function, and the
/// function's single-round loop, whose own code barely changed, ran twice as
/// slowly (pipeline resyncs went up sevenfold). Keccak's round is 250.
const MAX_BLOCK_INSTS: u32 = 1000;

/// What an access's address is relative to.
#[derive(Clone, Copy, PartialEq, Eq, Debug)]
enum Base {
    Value(Value),
    Slot(StackSlot),
}

/// The bytes an access reads or writes: `start..end` from its base.
#[derive(Clone, Copy, Debug)]
struct Place {
    base: Base,
    start: i64,
    end: i64,
}

/// Where a value is in memory, and the load that read it: its opcode,
/// address (for its type), flags and result type.
#[derive(Clone, Copy, Debug)]
struct Home {
    place: Place,
    opcode: Opcode,
    addr: Value,
    flags: MemFlags,
    ty: Type,
}

/// The place `addr + offset` names for `size` bytes.
fn place(func: &Function, addr: Value, offset: Offset32, size: u32) -> Place {
    let mut base = addr;
    let mut start = i64::from(offset);
    let constant = |value: Value| match func
        .dfg
        .value_def(value)
        .inst()
        .map(|inst| func.dfg.insts[inst])
    {
        Some(InstructionData::UnaryImm {
            opcode: Opcode::Iconst,
            imm,
        }) => Some(imm.bits()),
        _ => None,
    };
    loop {
        let Some(def) = func.dfg.value_def(base).inst() else {
            break;
        };
        match func.dfg.insts[def] {
            InstructionData::Binary {
                opcode: Opcode::Iadd,
                args: [x, y],
            } => {
                let (pointer, delta) = match (constant(x), constant(y)) {
                    (_, Some(delta)) => (x, delta),
                    (Some(delta), _) => (y, delta),
                    _ => break,
                };
                let Some(moved) = start.checked_add(delta) else {
                    break;
                };
                base = pointer;
                start = moved;
            }
            InstructionData::StackAddr {
                stack_slot, offset, ..
            } => {
                if let Some(moved) = start.checked_add(i64::from(offset)) {
                    return Place {
                        base: Base::Slot(stack_slot),
                        start: moved,
                        end: moved.saturating_add(i64::from(size)),
                    };
                }
                break;
            }
            _ => break,
        }
    }
    Place {
        base: Base::Value(base),
        start,
        end: start.saturating_add(i64::from(size)),
    }
}

/// The bytes a load of `opcode` reads into a `ty` result, if it reads an
/// integer that fits a register.
fn load_size(opcode: Opcode, ty: Type) -> Option<u32> {
    if !ty.is_int() || ty.bits() > 64 {
        return None;
    }
    match opcode {
        Opcode::Load => Some(ty.bytes()),
        Opcode::Uload8 | Opcode::Sload8 => Some(1),
        Opcode::Uload16 | Opcode::Sload16 => Some(2),
        Opcode::Uload32 | Opcode::Sload32 => Some(4),
        _ => None,
    }
}

/// Whether a write to `a` may change the bytes of `b`.
fn may_overlap(a: &Place, b: &Place, escaped: &EntitySet<StackSlot>) -> bool {
    let overlap = a.start < b.end && b.start < a.end;
    match (a.base, b.base) {
        (Base::Slot(x), Base::Slot(y)) => x == y && overlap,
        (Base::Value(x), Base::Value(y)) => x != y || overlap,
        (Base::Slot(slot), Base::Value(_)) | (Base::Value(_), Base::Slot(slot)) => {
            escaped.contains(slot)
        }
    }
}

/// Whether `inst` calls a C memory routine (`memcpy`, `memmove`, `memset`
/// or `memcmp`), which accesses the memory its arguments point to during the
/// call and keeps no pointer.
fn memory_libcall(func: &Function, inst: Inst) -> bool {
    let InstructionData::Call { func_ref, .. } = func.dfg.insts[inst] else {
        return false;
    };
    matches!(
        func.dfg.ext_funcs[func_ref].name,
        ExternalName::LibCall(
            LibCall::Memcpy | LibCall::Memmove | LibCall::Memset | LibCall::Memcmp
        )
    )
}

/// The stack slots whose address reaches anything but the address of a load
/// or a store, or an argument of a C memory routine, through constant offsets.
fn escaped_slots(func: &Function) -> EntitySet<StackSlot> {
    let mut escaped = EntitySet::new();
    for block in func.layout.blocks() {
        for inst in func.layout.block_insts(block) {
            if memory_libcall(func, inst) {
                continue;
            }
            let operands: SmallVec<[Value; 4]> = match func.dfg.insts[inst] {
                InstructionData::Load { .. } => continue,
                InstructionData::Store {
                    args: [value, _], ..
                } => smallvec![value],
                // A constant offset from a slot's address is an address in the
                // slot, whose own uses count.
                InstructionData::Binary {
                    opcode: Opcode::Iadd,
                    ..
                } if matches!(
                    place(func, func.dfg.first_result(inst), Offset32::new(0), 0).base,
                    Base::Slot(_)
                ) =>
                {
                    continue;
                }
                _ => func.dfg.inst_values(inst).collect(),
            };
            for value in operands {
                if let Base::Slot(slot) = place(func, value, Offset32::new(0), 0).base {
                    escaped.insert(slot);
                }
            }
        }
    }
    escaped
}

/// Load values from memory again at their later uses in a block where more
/// than `registers` integer values are live, and return how many loads were
/// added.
pub(crate) fn reload_values(func: &mut Function, registers: u32) -> usize {
    let escaped = escaped_slots(func);

    // A block that uses each value, and whether another one does too.
    let mut use_block = SecondaryMap::<Value, PackedOption<Block>>::new();
    let mut shared = EntitySet::<Value>::new();
    for block in func.layout.blocks() {
        for inst in func.layout.block_insts(block) {
            for value in func.dfg.inst_values(inst) {
                let value = func.dfg.resolve_aliases(value);
                match use_block[value].expand() {
                    None => use_block[value] = block.into(),
                    Some(other) if other != block => {
                        shared.insert(value);
                    }
                    Some(_) => {}
                }
            }
        }
    }
    let live_out = |value: Value, block: Block| {
        shared.contains(value)
            || use_block[value]
                .expand()
                .is_some_and(|other| other != block)
    };
    let weight = |func: &Function, value: Value| {
        let ty = func.dfg.value_type(value);
        match ty.bits() {
            _ if !ty.is_int() => 0,
            0..=64 => 1,
            _ => 2,
        }
    };

    let mut added = 0;
    let mut insts = Vec::new();
    let mut position_of = SecondaryMap::<Inst, u32>::new();
    let mut uses = FxHashMap::<Value, Vec<u32>>::default();
    let mut homes = FxHashMap::<Value, Home>::default();
    // The places the block has stored to so far.
    let mut stored = Vec::<Place>::new();
    let mut reloadable = FxHashMap::<(Value, u32), Home>::default();
    let mut pressure = Vec::new();
    let mut reloads = Vec::new();
    let blocks: Vec<Block> = func.layout.blocks().collect();
    for block in blocks {
        insts.clear();
        insts.extend(func.layout.block_insts(block));
        let count = insts.len() as u32;
        if count > MAX_BLOCK_INSTS {
            continue;
        }
        uses.clear();
        homes.clear();
        stored.clear();
        reloadable.clear();
        reloads.clear();

        // Where each value is in memory before each instruction that uses it.
        for (position, &inst) in insts.iter().enumerate() {
            let position = position as u32;
            position_of[inst] = position;
            for value in func.dfg.inst_values(inst) {
                let value = func.dfg.resolve_aliases(value);
                let positions = uses.entry(value).or_default();
                if positions.last() != Some(&position) {
                    positions.push(position);
                    if let Some(home) = homes.get(&value) {
                        reloadable.insert((value, position), *home);
                    }
                }
            }
            match func.dfg.insts[inst] {
                InstructionData::Load {
                    opcode,
                    arg,
                    flags,
                    offset,
                } => {
                    let result = func.dfg.first_result(inst);
                    let ty = func.dfg.value_type(result);
                    let arg = func.dfg.resolve_aliases(arg);
                    if let Some(size) = load_size(opcode, ty)
                        && let place = place(func, arg, offset, size)
                        && !stored
                            .iter()
                            .any(|written| may_overlap(written, &place, &escaped))
                    {
                        homes.insert(
                            result,
                            Home {
                                place,
                                opcode,
                                addr: arg,
                                flags,
                                ty,
                            },
                        );
                    }
                }
                InstructionData::Store {
                    opcode,
                    args: [value, addr],
                    offset,
                    ..
                } => {
                    let ty = func.dfg.value_type(value);
                    let size = match opcode {
                        Opcode::Store => ty.bytes(),
                        Opcode::Istore8 => 1,
                        Opcode::Istore16 => 2,
                        Opcode::Istore32 => 4,
                        _ => {
                            homes.retain(|_, home| {
                                matches!(home.place.base, Base::Slot(slot) if !escaped.contains(slot))
                            });
                            continue;
                        }
                    };
                    let place = place(func, addr, offset, size);
                    homes.retain(|_, home| !may_overlap(&home.place, &place, &escaped));
                    stored.push(place);
                }
                ref data => {
                    let opcode = data.opcode();
                    if opcode.can_store() || opcode.is_call() || opcode.other_side_effects() {
                        // Nothing else reaches a stack slot whose address only
                        // loads and stores use, but a memory routine reaches
                        // the slots its arguments point into.
                        let reached: SmallVec<[StackSlot; 4]> = if memory_libcall(func, inst) {
                            func.dfg
                                .inst_args(inst)
                                .iter()
                                .filter_map(|&arg| {
                                    match place(func, arg, Offset32::new(0), 0).base {
                                        Base::Slot(slot) => Some(slot),
                                        Base::Value(_) => None,
                                    }
                                })
                                .collect()
                        } else {
                            SmallVec::new()
                        };
                        homes.retain(|_, home| {
                            matches!(home.place.base, Base::Slot(slot)
                                if !escaped.contains(slot) && !reached.contains(&slot))
                        });
                    }
                }
            }
        }
        if reloadable.is_empty() {
            continue;
        }

        // The integer values live just before each instruction, and at the
        // block's end.
        pressure.clear();
        pressure.resize(insts.len() + 2, 0i32);
        let start = |func: &Function, value: Value| match func.dfg.value_def(value) {
            ValueDef::Result(def, _) if func.layout.inst_block(def) == Some(block) => {
                position_of[def] + 1
            }
            _ => 0,
        };
        let mut end = FxHashMap::<Value, u32>::default();
        for (&value, positions) in &uses {
            let last = if live_out(value, block) {
                count
            } else {
                *positions.last().unwrap()
            };
            end.insert(value, last);
            let weight = weight(func, value);
            if weight > 0 {
                let first = start(func, value);
                if first <= last {
                    pressure[first as usize] += weight;
                    pressure[last as usize + 1] -= weight;
                }
            }
        }
        for index in 1..pressure.len() {
            pressure[index] += pressure[index - 1];
        }

        // Each value's uses from its last, while its live range ends at the
        // use before.
        let mut values: Vec<Value> = reloadable.keys().map(|&(value, _)| value).collect();
        values.sort_unstable();
        values.dedup();
        let tail = |value: &Value| {
            let positions = &uses[value];
            match positions.len() {
                0 | 1 => 0,
                n => positions[n - 1] - positions[n - 2],
            }
        };
        values.sort_by_key(|value| core::cmp::Reverse((tail(value), *value)));
        // Each reload: its use's position, the value, its home and the
        // value's use before, where the reload ends its live range.
        let mut chosen = Vec::new();
        for value in values {
            let weight = weight(func, value);
            if weight == 0 || live_out(value, block) {
                continue;
            }
            let positions = &uses[&value];
            for pair in positions.windows(2).rev() {
                let [before, at] = [pair[0], pair[1]];
                let Some(home) = reloadable.get(&(value, at)) else {
                    break;
                };
                let based = match home.place.base {
                    Base::Value(base) => end.contains_key(&base),
                    Base::Slot(_) => true,
                };
                let busy = (before + 1..=at).any(|gap| pressure[gap as usize] > registers as i32);
                if !based || !busy || i32::try_from(home.place.start).is_err() {
                    break;
                }
                for gap in before + 1..=at {
                    pressure[gap as usize] -= weight;
                }
                chosen.push((at, value, *home, (at - before) * weight as u32));
            }
        }
        // A reload from a stack slot addresses the slot from the stack
        // pointer; one from a value's place keeps that base value live up to
        // the reload. Extending a base past its last use costs a register
        // there, which pays when its reloads free more: each frees its value
        // from its use before up to the reload.
        let mut bases = FxHashMap::<Value, (u32, u32)>::default();
        for &(at, _, home, freed) in &chosen {
            if let Base::Value(base) = home.place.base {
                let (gain, last) = bases.entry(base).or_default();
                *gain += freed;
                *last = (*last).max(at);
            }
        }
        reloads.extend(
            chosen
                .into_iter()
                .filter(|(_, _, home, _)| match home.place.base {
                    Base::Value(base) => {
                        let (gain, last) = bases[&base];
                        gain > last.saturating_sub(end[&base])
                    }
                    Base::Slot(_) => true,
                })
                .map(|(at, value, home, _)| (insts[at as usize], value, home)),
        );

        for &(user, value, home) in &reloads {
            let start = Offset32::new(i32::try_from(home.place.start).unwrap());
            let (arg, offset) = match home.place.base {
                Base::Value(base) => (base, start),
                Base::Slot(slot) => {
                    let addr = func.dfg.make_inst(InstructionData::StackAddr {
                        opcode: Opcode::StackAddr,
                        stack_slot: slot,
                        offset: start,
                    });
                    let pointer = func.dfg.value_type(home.addr);
                    func.dfg.make_inst_results(addr, pointer);
                    func.layout.insert_inst(addr, user);
                    (func.dfg.first_result(addr), Offset32::new(0))
                }
            };
            let load = func.dfg.make_inst(InstructionData::Load {
                opcode: home.opcode,
                arg,
                flags: home.flags,
                offset,
            });
            func.dfg.make_inst_results(load, home.ty);
            let reloaded = func.dfg.first_result(load);
            func.layout.insert_inst(load, user);
            let aliases: Vec<Value> = func
                .dfg
                .inst_values(user)
                .filter(|&used| func.dfg.resolve_aliases(used) == value)
                .collect();
            func.dfg.map_inst_values(user, |used| {
                if aliases.contains(&used) {
                    reloaded
                } else {
                    used
                }
            });
            added += 1;
        }
    }
    added
}
