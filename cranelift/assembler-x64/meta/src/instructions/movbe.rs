use crate::dsl::{Feature::*, Inst, Location::*};
use crate::dsl::{fmt, inst, r, rex, w};

#[rustfmt::skip] // Keeps instructions on a single line.
pub fn list() -> Vec<Inst> {
    vec![
        // Loads and stores that reverse the bytes of the value they move.
        inst("movbel", fmt("RM", [w(r32), r(m32)]), rex([0x0F, 0x38, 0xF0]).r(), (_64b | compat) & movbe),
        inst("movbeq", fmt("RM", [w(r64), r(m64)]), rex([0x0F, 0x38, 0xF0]).w().r(), _64b & movbe),
        inst("movbel", fmt("MR", [w(m32), r(r32)]), rex([0x0F, 0x38, 0xF1]).r(), (_64b | compat) & movbe),
        inst("movbeq", fmt("MR", [w(m64), r(r64)]), rex([0x0F, 0x38, 0xF1]).w().r(), _64b & movbe),
    ]
}
