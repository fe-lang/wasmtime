//! Lowering rules for X64.

// ISLE integration glue.
pub(super) mod isle;

use crate::ir::{
    Endianness, ExternalName, Inst as IRInst, InstructionData, LibCall, Opcode, Type, types,
};
use crate::isa::x64::abi::*;
use crate::isa::x64::inst::args::*;
use crate::isa::x64::inst::*;
use crate::isa::x64::settings as x64_settings;
use crate::isa::{CallConv, x64::X64Backend};
use crate::machinst::*;
use crate::result::CodegenResult;
use crate::settings::Flags;
use alloc::boxed::Box;
use target_lexicon::Triple;

/// Identifier for a particular input of an instruction.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
struct InsnInput {
    insn: IRInst,
    input: usize,
}

//=============================================================================
// Helpers for instruction lowering.

impl Lower<'_, Inst> {
    #[inline]
    pub fn temp_writable_gpr(&mut self) -> WritableGpr {
        WritableGpr::from_writable_reg(self.alloc_tmp(types::I64).only_reg().unwrap()).unwrap()
    }

    #[inline]
    pub fn temp_writable_xmm(&mut self) -> WritableXmm {
        WritableXmm::from_writable_reg(self.alloc_tmp(types::F64).only_reg().unwrap()).unwrap()
    }
}

fn is_int_or_ref_ty(ty: Type) -> bool {
    match ty {
        types::I8 | types::I16 | types::I32 | types::I64 => true,
        _ => false,
    }
}

enum MergeableLoadSize {
    /// The load size performed by a sinkable load merging operation is
    /// precisely the size necessary for the type in question.
    Exact,

    /// Narrower-than-32-bit values are handled by ALU insts that are at least
    /// 32 bits wide, which is normally OK as we ignore upper buts; but, if we
    /// generate, e.g., a direct-from-memory 32-bit add for a byte value and
    /// the byte is the last byte in a page, the extra data that we load is
    /// incorrectly accessed. So we only allow loads to merge for
    /// 32-bit-and-above widths.
    Min32,
}

/// Determines whether a load operation (indicated by `src_insn`) can be merged
/// into the current lowering point. If so, returns the address-base source (as
/// an `InsnInput`) and an offset from that address from which to perform the
/// load.
fn is_mergeable_load(
    ctx: &mut Lower<Inst>,
    src_insn: IRInst,
    size: MergeableLoadSize,
) -> Option<(InsnInput, i32)> {
    let insn_data = ctx.data(src_insn);
    let inputs = ctx.num_inputs(src_insn);
    if inputs != 1 {
        return None;
    }

    // If this type is too small to get a merged load, don't merge the load.
    let load_ty = ctx.output_ty(src_insn, 0);
    if ty_bits(load_ty) < 32 {
        match size {
            MergeableLoadSize::Exact => {}
            MergeableLoadSize::Min32 => return None,
        }
    }

    // If the load's flags specify big-endian, we can't merge.
    if let Some(flags) = ctx.memflags(src_insn) {
        if flags.explicit_endianness() == Some(Endianness::Big) {
            return None;
        }
    }

    // Just testing the opcode is enough, because the width will always match if
    // the type does (and the type should match if the CLIF is properly
    // constructed).
    if let &InstructionData::Load {
        opcode: Opcode::Load,
        offset,
        ..
    } = insn_data
    {
        Some((
            InsnInput {
                insn: src_insn,
                input: 0,
            },
            offset.into(),
        ))
    } else {
        None
    }
}

fn emit_vm_call(
    ctx: &mut Lower<Inst>,
    flags: &Flags,
    isa_flags: &x64_settings::Flags,
    triple: &Triple,
    libcall: LibCall,
    inputs: &[ValueRegs<Reg>],
) -> CodegenResult<InstOutput> {
    let extname = ExternalName::LibCall(libcall);

    // TODO avoid recreating signatures for every single Libcall function.
    let call_conv = CallConv::for_libcall(flags, CallConv::triple_default(triple));
    let sig = libcall.signature(call_conv, types::I64);
    let outputs = ctx.gen_call_output(&sig);

    if !ctx.sigs().have_abi_sig_for_signature(&sig) {
        ctx.sigs_mut()
            .make_abi_sig_from_ir_signature::<X64ABIMachineSpec>(sig.clone(), flags, isa_flags)?;
    }
    let sig = ctx.sigs().abi_sig_for_signature(&sig);

    let uses = ctx.gen_call_args(sig, inputs);
    let defs = ctx.gen_call_rets(sig, &outputs);

    let stack_ret_space = ctx.sigs()[sig].sized_stack_ret_space();
    let stack_arg_space = ctx.sigs()[sig].sized_stack_arg_space();
    ctx.abi_mut()
        .accumulate_outgoing_args_size(stack_ret_space + stack_arg_space);

    if flags.use_colocated_libcalls() {
        let call_info = ctx.gen_call_info(sig, extname, uses, defs, None, false);
        ctx.emit(Inst::call_known(Box::new(call_info)));
    } else {
        let tmp = ctx.alloc_tmp(types::I64).only_reg().unwrap();
        ctx.emit(Inst::LoadExtName {
            dst: tmp.map(Gpr::unwrap_new),
            name: Box::new(extname),
            offset: 0,
            distance: RelocDistance::Far,
        });
        let call_info = ctx.gen_call_info(sig, RegMem::reg(tmp.to_reg()), uses, defs, None, false);
        ctx.emit(Inst::call_unknown(Box::new(call_info)));
    }
    Ok(outputs)
}

//=============================================================================
// Lowering-backend trait implementation.

impl LowerBackend for X64Backend {
    type MInst = Inst;

    fn lower(&self, ctx: &mut Lower<Inst>, ir_inst: IRInst) -> Option<InstOutput> {
        isle::lower(ctx, self, ir_inst)
    }

    fn lower_branch(
        &self,
        ctx: &mut Lower<Inst>,
        ir_inst: IRInst,
        targets: &[MachLabel],
    ) -> Option<()> {
        isle::lower_branch(ctx, self, ir_inst, targets)
    }

    fn maybe_pinned_reg(&self) -> Option<Reg> {
        Some(regs::pinned_reg())
    }
}
