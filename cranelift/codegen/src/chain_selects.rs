//! Hoisting selects out of carry chains.
//!
//! x64 keeps a chain of carry ops, an `add`/`adc` or `sub`/`sbb` per limb, in
//! the flags. A select lowers to a compare and a conditional move, so one
//! between two links of a chain clobbers the carry, which lowering then saves
//! with `setb` and restores with `neg` around it. The egraph pass places each
//! select right before its first use: a modular reduction picks its limbs
//! with selects that the next field operation's chain takes one link at a
//! time, so each link of that chain saved and restored its carry.
//!
//! A select or compare between the links of a chain, with its operands
//! defined before the chain, moves before the chain, together with the
//! constants and extensions in the chain that it needs. Selects on one
//! condition, now in a row, share its compare. Each moved select's result
//! stays live across the links before its use, where both of its operands
//! did.

use crate::FxHashMap;
use crate::ir::{Block, Function, Inst, Opcode, Value};
use alloc::vec::Vec;

/// Whether `inst` is a carry op: a 64-bit or narrower addition or
/// subtraction with a carry out, and possibly a carry in.
fn is_carry_op(func: &Function, inst: Inst) -> bool {
    matches!(
        func.dfg.insts[inst].opcode(),
        Opcode::UaddOverflow
            | Opcode::UaddOverflowCin
            | Opcode::UsubOverflow
            | Opcode::UsubOverflowBin
    )
}

/// The carry in of carry op `inst`, if it takes one.
fn carry_in(func: &Function, inst: Inst) -> Option<Value> {
    matches!(
        func.dfg.insts[inst].opcode(),
        Opcode::UaddOverflowCin | Opcode::UsubOverflowBin
    )
    .then(|| func.dfg.resolve_aliases(func.dfg.inst_args(inst)[2]))
}

/// Whether `inst` may move before a chain: a select or compare to clear out
/// of it, or a constant or extension one of those needs.
fn is_movable(func: &Function, inst: Inst) -> bool {
    matches!(
        func.dfg.insts[inst].opcode(),
        Opcode::Select | Opcode::Icmp | Opcode::Iconst | Opcode::Uextend
    )
}

/// The carry chains of `block`, each its ops in order.
fn chains(func: &Function, block: Block) -> Vec<Vec<Inst>> {
    let mut chains: Vec<Vec<Inst>> = Vec::new();
    let mut chain_of = FxHashMap::<Value, usize>::default();
    for inst in func.layout.block_insts(block) {
        if !is_carry_op(func, inst) {
            continue;
        }
        let chain = match carry_in(func, inst).and_then(|carry| chain_of.get(&carry)) {
            Some(&chain) => {
                chains[chain].push(inst);
                chain
            }
            None => {
                chains.push(alloc::vec![inst]);
                chains.len() - 1
            }
        };
        chain_of.insert(func.dfg.inst_results(inst)[1], chain);
    }
    chains.retain(|chain| chain.len() > 1);
    chains
}

/// Moves the selects and compares between the links of each carry chain
/// before the chain where their operands allow, and returns how many
/// instructions moved.
pub(crate) fn hoist_chain_selects(func: &mut Function) -> usize {
    let mut moved = 0;
    for block in func.layout.blocks().collect::<Vec<_>>() {
        for chain in chains(func, block) {
            let first = chain[0];
            let last = *chain.last().unwrap();
            // The instructions between the chain's first and last op, which
            // can move before it: their operands come before the chain or
            // from instructions that move too.
            let mut region = Vec::new();
            let mut inst = func.layout.next_inst(first);
            while let Some(current) = inst
                && current != last
            {
                region.push(current);
                inst = func.layout.next_inst(current);
            }
            let mut movable = FxHashMap::<Inst, bool>::default();
            for &inst in &region {
                let ready = is_movable(func, inst)
                    && func.dfg.inst_values(inst).all(|arg| {
                        let arg = func.dfg.resolve_aliases(arg);
                        func.dfg.value_def(arg).inst().is_none_or(|def| {
                            movable
                                .get(&def)
                                .copied()
                                .unwrap_or(!region.contains(&def) && !chain.contains(&def))
                        })
                    });
                movable.insert(inst, ready);
            }
            // Only selects and compares need to leave the chain; the
            // constants and extensions they need move with them.
            let mut wanted: Vec<Inst> = region
                .iter()
                .copied()
                .filter(|&inst| {
                    movable[&inst]
                        && matches!(func.dfg.insts[inst].opcode(), Opcode::Select | Opcode::Icmp)
                })
                .collect();
            let mut index = 0;
            while index < wanted.len() {
                let inst = wanted[index];
                for arg in func.dfg.inst_values(inst).collect::<Vec<_>>() {
                    let arg = func.dfg.resolve_aliases(arg);
                    if let Some(def) = func.dfg.value_def(arg).inst()
                        && movable.get(&def).copied().unwrap_or(false)
                        && !wanted.contains(&def)
                    {
                        wanted.push(def);
                    }
                }
                index += 1;
            }
            for &inst in &region {
                if wanted.contains(&inst) {
                    func.layout.remove_inst(inst);
                    func.layout.insert_inst(inst, first);
                    moved += 1;
                }
            }
        }
    }
    moved
}
