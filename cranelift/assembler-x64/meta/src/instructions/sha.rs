use crate::dsl::{Feature::*, Inst, Location::*};
use crate::dsl::{align, fmt, inst, r, rex, rw};

#[rustfmt::skip] // Keeps instructions on a single line.
pub fn list() -> Vec<Inst> {
    vec![
        // SHA-256 rounds and message schedule (Intel SHA extensions). Two
        // rounds take the next two `wk` sums from the low words of `xmm0`.
        inst("sha256rnds2", fmt("RM0", [rw(xmm1), r(align(xmm_m128)), r(xmm0)]), rex([0x0F, 0x38, 0xCB]).r(), (_64b | compat) & sha),
        inst("sha256msg1", fmt("A", [rw(xmm1), r(align(xmm_m128))]), rex([0x0F, 0x38, 0xCC]).r(), (_64b | compat) & sha),
        inst("sha256msg2", fmt("A", [rw(xmm1), r(align(xmm_m128))]), rex([0x0F, 0x38, 0xCD]).r(), (_64b | compat) & sha),
    ]
}
