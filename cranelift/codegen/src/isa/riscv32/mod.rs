//! risc-v 32-bit Instruction Set Architecture.

use crate::dominator_tree::DominatorTree;
use crate::ir::{Function, Opcode, Type};
use crate::isa::riscv32::settings as riscv_settings;
use crate::isa::{
    Builder as IsaBuilder, FunctionAlignment, IsaFlagsHashKey, OwnedTargetIsa, TargetIsa,
};
use crate::machinst::{
    CompiledCode, CompiledCodeStencil, MachInst, MachTextSectionBuilder, Reg, SigSet,
    TextSectionBuilder, VCode, compile,
};
use crate::result::CodegenResult;
use crate::settings::{self as shared_settings, Flags};
use crate::{CodegenError, ir};
use alloc::string::String;
use alloc::{boxed::Box, vec::Vec};
use core::fmt;
use cranelift_control::ControlPlane;
use target_lexicon::{Architecture, BinaryFormat, Endianness, Riscv32Architecture, Triple};
mod abi;
pub(crate) mod inst;
mod lower;
mod settings;
#[cfg(feature = "unwind")]
use crate::isa::unwind::systemv;

use self::inst::EmitInfo;

/// An riscv32 backend.
pub struct Riscv32Backend {
    triple: Triple,
    flags: shared_settings::Flags,
    isa_flags: riscv_settings::Flags,
}

impl Riscv32Backend {
    /// Create a new riscv32 backend with the given (shared) flags.
    pub fn new_with_flags(
        triple: Triple,
        flags: shared_settings::Flags,
        isa_flags: riscv_settings::Flags,
    ) -> Riscv32Backend {
        Riscv32Backend {
            triple,
            flags,
            isa_flags,
        }
    }

    /// This performs lowering to VCode, register-allocates the code, computes block layout and
    /// finalizes branches. The result is ready for binary emission.
    fn compile_vcode(
        &self,
        func: &Function,
        domtree: &DominatorTree,
        ctrl_plane: &mut ControlPlane,
    ) -> CodegenResult<(VCode<inst::Inst>, regalloc2::Output)> {
        validate_supported_types(func)?;
        let emit_info = EmitInfo::new(self.flags.clone(), self.isa_flags.clone());
        let sigs = SigSet::new::<abi::Riscv32MachineDeps>(func, &self.flags)?;
        let abi = abi::Riscv32Callee::new(func, self, &self.isa_flags, &sigs)?;
        compile::compile::<Riscv32Backend>(func, domtree, self, abi, emit_info, sigs, ctrl_plane)
    }
}

fn validate_supported_types(func: &Function) -> CodegenResult<()> {
    fn supported(ty: Type) -> bool {
        ty.is_int() && ty.bits() <= 64
    }

    fn allowed_i64_opcode(opcode: Opcode) -> bool {
        matches!(
            opcode,
            Opcode::Iconst
                | Opcode::Iadd
                | Opcode::IaddImm
                | Opcode::Isub
                | Opcode::IrsubImm
                | Opcode::Band
                | Opcode::BandImm
                | Opcode::Bor
                | Opcode::BorImm
                | Opcode::Bxor
                | Opcode::BxorImm
                | Opcode::Bnot
                | Opcode::Uextend
                | Opcode::Sextend
                | Opcode::Ireduce
                | Opcode::Ishl
                | Opcode::IshlImm
                | Opcode::Ushr
                | Opcode::UshrImm
                | Opcode::Sshr
                | Opcode::SshrImm
                | Opcode::Load
                | Opcode::Store
                | Opcode::Select
                | Opcode::Icmp
                | Opcode::IcmpImm
                | Opcode::Jump
                | Opcode::Brif
                | Opcode::Return
                | Opcode::Call
                | Opcode::CallIndirect
        )
    }

    for param in func
        .signature
        .params
        .iter()
        .chain(func.signature.returns.iter())
    {
        if !supported(param.value_type) {
            return Err(CodegenError::Unsupported(format!(
                "riscv32im currently supports only integer scalar values up to i64; found {}",
                param.value_type
            )));
        }
    }
    for block in func.layout.blocks() {
        for &value in func.dfg.block_params(block) {
            let ty = func.dfg.value_type(value);
            if !supported(ty) {
                return Err(CodegenError::Unsupported(format!(
                    "riscv32im currently supports only integer scalar values up to i64; found {ty}"
                )));
            }
        }
        for inst in func.layout.block_insts(block) {
            let opcode = func.dfg.insts[inst].opcode();
            if !allowed_i64_opcode(opcode)
                && func
                    .dfg
                    .inst_args(inst)
                    .iter()
                    .chain(func.dfg.inst_results(inst).iter())
                    .any(|&value| {
                        let ty = func.dfg.value_type(value);
                        ty.is_int() && ty.bits() == 64
                    })
            {
                return Err(CodegenError::Unsupported(format!(
                    "riscv32im does not support {opcode} for i64 values yet"
                )));
            }

            for &value in func.dfg.inst_results(inst) {
                let ty = func.dfg.value_type(value);
                if !supported(ty) {
                    return Err(CodegenError::Unsupported(format!(
                        "riscv32im currently supports only integer scalar values up to i64; found {ty}"
                    )));
                }
            }
        }
    }

    Ok(())
}

impl TargetIsa for Riscv32Backend {
    fn compile_function(
        &self,
        func: &Function,
        domtree: &DominatorTree,
        want_disasm: bool,
        ctrl_plane: &mut ControlPlane,
    ) -> CodegenResult<CompiledCodeStencil> {
        let (vcode, regalloc_result) = self.compile_vcode(func, domtree, ctrl_plane)?;

        let want_disasm = want_disasm || log::log_enabled!(log::Level::Debug);
        let emit_result = vcode.emit(&regalloc_result, want_disasm, &self.flags, ctrl_plane);
        let value_labels_ranges = emit_result.value_labels_ranges;
        let buffer = emit_result.buffer;

        if let Some(disasm) = emit_result.disasm.as_ref() {
            log::debug!("disassembly:\n{disasm}");
        }

        Ok(CompiledCodeStencil {
            buffer,
            vcode: emit_result.disasm,
            value_labels_ranges,
            bb_starts: emit_result.bb_offsets,
            bb_edges: emit_result.bb_edges,
        })
    }

    fn name(&self) -> &'static str {
        "riscv32"
    }
    fn dynamic_vector_bytes(&self, _dynamic_ty: ir::Type) -> u32 {
        16
    }

    fn triple(&self) -> &Triple {
        &self.triple
    }

    fn flags(&self) -> &shared_settings::Flags {
        &self.flags
    }

    fn isa_flags(&self) -> Vec<shared_settings::Value> {
        self.isa_flags.iter().collect()
    }

    fn isa_flags_hash_key(&self) -> IsaFlagsHashKey<'_> {
        IsaFlagsHashKey(self.isa_flags.hash_key())
    }

    #[cfg(feature = "unwind")]
    fn emit_unwind_info(
        &self,
        result: &CompiledCode,
        kind: crate::isa::unwind::UnwindInfoKind,
    ) -> CodegenResult<Option<crate::isa::unwind::UnwindInfo>> {
        use crate::isa::unwind::UnwindInfo;
        use crate::isa::unwind::UnwindInfoKind;
        Ok(match kind {
            UnwindInfoKind::SystemV => {
                let mapper = self::inst::unwind::systemv::RegisterMapper;
                Some(UnwindInfo::SystemV(
                    crate::isa::unwind::systemv::create_unwind_info_from_insts(
                        &result.buffer.unwind_info[..],
                        result.buffer.data().len(),
                        &mapper,
                    )?,
                ))
            }
            UnwindInfoKind::Windows => None,
            _ => None,
        })
    }

    #[cfg(feature = "unwind")]
    fn create_systemv_cie(&self) -> Option<gimli::write::CommonInformationEntry> {
        Some(inst::unwind::systemv::create_cie())
    }

    fn text_section_builder(&self, num_funcs: usize) -> Box<dyn TextSectionBuilder> {
        Box::new(MachTextSectionBuilder::<inst::Inst>::new(num_funcs))
    }

    #[cfg(feature = "unwind")]
    fn map_regalloc_reg_to_dwarf(&self, reg: Reg) -> Result<u16, systemv::RegisterMappingError> {
        inst::unwind::systemv::map_reg(reg).map(|reg| reg.0)
    }

    fn function_alignment(&self) -> FunctionAlignment {
        inst::Inst::function_alignment()
    }

    fn page_size_align_log2(&self) -> u8 {
        debug_assert_eq!(1 << 12, 0x1000);
        12
    }

    #[cfg(feature = "disas")]
    fn to_capstone(&self) -> Result<capstone::Capstone, capstone::Error> {
        use capstone::prelude::*;
        let mut cs_builder = Capstone::new().riscv().mode(arch::riscv::ArchMode::RiscV32);

        // Enable C instruction decoding if we have compressed instructions enabled.
        //
        // We can't enable this unconditionally because it will cause Capstone to
        // emit weird instructions and generally mess up when it encounters unknown
        // instructions, such as any Zba,Zbb,Zbc or Vector instructions.
        //
        // This causes the default disassembly to be quite unreadable, so enable
        // it only when we are actually going to be using them.
        let uses_compressed = self
            .isa_flags()
            .iter()
            .filter(|f| ["has_zca", "has_zcb", "has_zcd"].contains(&f.name))
            .any(|f| f.as_bool().unwrap_or(false));
        if uses_compressed {
            cs_builder = cs_builder.extra_mode([arch::riscv::ArchExtraMode::RiscVC].into_iter());
        }

        let mut cs = cs_builder.build()?;

        // Similar to AArch64, RISC-V uses inline constants rather than a separate
        // constant pool. We want to skip disassembly over inline constants instead
        // of stopping on invalid bytes.
        cs.set_skipdata(true)?;
        Ok(cs)
    }

    fn pretty_print_reg(&self, reg: Reg, _size: u8) -> String {
        // TODO-RISC-V: implement proper register pretty-printing.
        format!("{reg:?}")
    }

    fn has_native_fma(&self) -> bool {
        false
    }

    fn has_round(&self) -> bool {
        false
    }

    fn has_blendv_lowering(&self, _: Type) -> bool {
        false
    }

    fn has_x86_pshufb_lowering(&self) -> bool {
        false
    }

    fn has_x86_pmulhrsw_lowering(&self) -> bool {
        false
    }

    fn has_x86_pmaddubsw_lowering(&self) -> bool {
        false
    }

    fn default_argument_extension(&self) -> ir::ArgumentExtension {
        ir::ArgumentExtension::None
    }
}

impl fmt::Display for Riscv32Backend {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        f.debug_struct("MachBackend")
            .field("name", &self.name())
            .field("triple", &self.triple())
            .field("flags", &format!("{}", self.flags()))
            .finish()
    }
}

/// Create a new `isa::Builder`.
pub fn isa_builder(triple: Triple) -> IsaBuilder {
    assert!(matches!(triple.architecture, Architecture::Riscv32(..)));
    IsaBuilder {
        triple,
        setup: riscv_settings::builder(),
        constructor: isa_constructor,
    }
}

fn isa_constructor(
    triple: Triple,
    shared_flags: Flags,
    builder: &shared_settings::Builder,
) -> CodegenResult<OwnedTargetIsa> {
    let isa_flags = riscv_settings::Flags::new(&shared_flags, builder);

    let Architecture::Riscv32(arch) = triple.architecture else {
        unreachable!();
    };
    if !matches!(
        arch,
        Riscv32Architecture::Riscv32im | Riscv32Architecture::Riscv32
    ) {
        return Err(CodegenError::Unsupported(
            "The RISC-V 32-bit backend currently supports riscv32im only".into(),
        ));
    }
    if !matches!(
        triple.binary_format,
        BinaryFormat::Elf | BinaryFormat::Unknown
    ) {
        return Err(CodegenError::Unsupported(
            "The RISC-V 32-bit backend currently supports ELF only".into(),
        ));
    }
    if triple.endianness() != Ok(Endianness::Little) {
        return Err(CodegenError::Unsupported(
            "The RISC-V 32-bit backend does not support big-endian targets".into(),
        ));
    }
    if !isa_flags.has_m() {
        return Err(CodegenError::Unsupported(
            "The RISC-V 32-bit backend currently requires the M extension".into(),
        ));
    }
    if isa_flags.has_a()
        || isa_flags.has_f()
        || isa_flags.has_d()
        || isa_flags.has_zfa()
        || isa_flags.has_zfhmin()
        || isa_flags.has_zfh()
        || isa_flags.has_v()
        || isa_flags.has_zvfh()
        || isa_flags.has_zca()
        || isa_flags.has_zcd()
        || isa_flags.has_zcb()
        || isa_flags.has_zbkb()
        || isa_flags.has_zba()
        || isa_flags.has_zbb()
        || isa_flags.has_zbc()
        || isa_flags.has_zbs()
        || isa_flags.has_zicond()
        || isa_flags.has_zicsr()
        || isa_flags.has_zifencei()
        || isa_flags.has_zvl32b()
        || isa_flags.has_zvl64b()
        || isa_flags.has_zvl128b()
        || isa_flags.has_zvl256b()
        || isa_flags.has_zvl512b()
        || isa_flags.has_zvl1024b()
        || isa_flags.has_zvl2048b()
        || isa_flags.has_zvl4096b()
        || isa_flags.has_zvl8192b()
        || isa_flags.has_zvl16384b()
        || isa_flags.has_zvl32768b()
        || isa_flags.has_zvl65536b()
    {
        return Err(CodegenError::Unsupported(
            "The RISC-V 32-bit backend currently supports only RV32IM soft-float".into(),
        ));
    }

    let backend = Riscv32Backend::new_with_flags(triple, shared_flags, isa_flags);
    Ok(backend.wrapped())
}
