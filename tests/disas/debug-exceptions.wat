;;! target = "aarch64"
;;! test = "compile"
;;! flags = ["-Wexceptions=yes", "-Wgc=yes", "-Dguest-debug=yes"]

(module
  (tag $t (param i32))
  (import "" "host" (func))
  (func (export "main")
    (block $b (result i32)
      (try_table (catch $t $b)
        (drop (i32.const 42))
        (throw $t (i32.const 42)))
      i32.const 0)
    (call 0)
    (drop)))
;; wasm[0]::function[1]:
;;       stp     x29, x30, [sp, #-0x10]!
;;       mov     x29, sp
;;       stp     x27, x28, [sp, #-0x10]!
;;       stp     x25, x26, [sp, #-0x10]!
;;       stp     x23, x24, [sp, #-0x10]!
;;       stp     x21, x22, [sp, #-0x10]!
;;       stp     x19, x20, [sp, #-0x10]!
;;       stp     d14, d15, [sp, #-0x10]!
;;       stp     d12, d13, [sp, #-0x10]!
;;       stp     d10, d11, [sp, #-0x10]!
;;       stp     d8, d9, [sp, #-0x10]!
;;       sub     sp, sp, #0x20
;;       ldr     x0, [x2, #8]
;;       ldr     x1, [x0, #0x18]
;;       stur    x0, [sp, #0x18]
;;       mov     x0, sp
;;       cmp     x0, x1
;;       b.lo    #0x214
;;   48: stur    x2, [sp]
;;       mov     x0, x2
;;       stur    x2, [sp, #0x10]
;;       nop
;;       ├─╼ debug frame state (after previous inst): func key DefinedWasmFunction(StaticModuleIndex(0), DefinedFuncIndex(0)), wasm PC 0x35, slot at FP-0xb0, locals , stack 
;;       ╰─╼ breakpoint patch: wasm PC 0x35, patch bytes [64, 1, 0, 148]
;;       ldur    x0, [sp, #0x10]
;;       nop
;;       ├─╼ debug frame state (after previous inst): func key DefinedWasmFunction(StaticModuleIndex(0), DefinedFuncIndex(0)), wasm PC 0x37, slot at FP-0xb0, locals , stack 
;;       ╰─╼ breakpoint patch: wasm PC 0x37, patch bytes [62, 1, 0, 148]
;;       ldur    x0, [sp, #0x10]
;;       nop
;;       ├─╼ debug frame state (after previous inst): func key DefinedWasmFunction(StaticModuleIndex(0), DefinedFuncIndex(0)), wasm PC 0x3d, slot at FP-0xb0, locals , stack 
;;       ╰─╼ breakpoint patch: wasm PC 0x3d, patch bytes [60, 1, 0, 148]
;;       mov     w1, #0x2a
;;       stur    w1, [sp, #8]
;;       nop
;;       ├─╼ debug frame state (after previous inst): func key DefinedWasmFunction(StaticModuleIndex(0), DefinedFuncIndex(0)), wasm PC 0x3f, slot at FP-0xb0, locals , stack I32 @ slot+0x8
;;       ╰─╼ breakpoint patch: wasm PC 0x3f, patch bytes [57, 1, 0, 148]
;;       nop
;;       ├─╼ debug frame state (after previous inst): func key DefinedWasmFunction(StaticModuleIndex(0), DefinedFuncIndex(0)), wasm PC 0x40, slot at FP-0xb0, locals , stack 
;;       ╰─╼ breakpoint patch: wasm PC 0x40, patch bytes [56, 1, 0, 148]
;;       stur    w1, [sp, #8]
;;       nop
;;       ├─╼ debug frame state (after previous inst): func key DefinedWasmFunction(StaticModuleIndex(0), DefinedFuncIndex(0)), wasm PC 0x42, slot at FP-0xb0, locals , stack I32 @ slot+0x8
;;       ╰─╼ breakpoint patch: wasm PC 0x42, patch bytes [54, 1, 0, 148]
;;       ldur    x2, [sp, #0x10]
;;       bl      #0x4bc
;;   88: ldur    x0, [sp, #0x10]
;;       ldr     x0, [x0, #0x20]
;;       ldr     w3, [x0]
;;       mov     w1, w3
;;       add     x1, x1, #0x20
;;       ldr     w4, [x0, #4]
;;       cmp     x1, x4
;;       b.hi    #0x190
;;   a8: add     w1, w3, #0x20
;;       str     w1, [x0]
;;       mov     w4, #2
;;       movk    w4, #0x400, lsl #16
;;       ldur    x0, [sp, #0x18]
;;       ldr     x5, [x0, #0x20]
;;       add     x1, x5, w3, uxtw
;;       str     w4, [x5, w3, uxtw]
;;       ldur    x0, [sp, #0x10]
;;       ldr     x4, [x0, #0x28]
;;       ldr     w4, [x4, #8]
;;       str     w4, [x1, #4]
;;       mov     x4, #0x20
;;       str     w4, [x1, #8]
;;       mov     w6, #0x2a
;;       str     w6, [x1, #0x18]
;;       str     w2, [x1, #0x10]
;;       mov     w8, #0
;;       str     w8, [x1, #0x14]
;;       ldur    x2, [sp, #0x10]
;;       bl      #0x4f4
;;       ├─╼ exception frame offset: SP = FP - 0xb0
;;       ╰─╼ exception handler: tag=0, context at [SP+0x10], handler=0x100
;;       b       #0x1cc
;;  100: mov     w10, w0
;;       mov     x11, #0x20
;;       adds    x9, x10, x11
;;       cset    x11, hs
;;       tst     w11, #0xff
;;       b.ne    #0x1fc
;;  118: ldur    x4, [sp, #0x18]
;;       ldr     x12, [x4, #0x28]
;;       cmp     x9, x12
;;       b.hi    #0x1e4
;;  128: ldr     x14, [x4, #0x20]
;;       add     x14, x14, w0, uxtw
;;       ldr     w14, [x14, #0x18]
;;       stur    w14, [sp, #8]
;;       ldur    x0, [sp, #0x10]
;;       nop
;;       ├─╼ debug frame state (after previous inst): func key DefinedWasmFunction(StaticModuleIndex(0), DefinedFuncIndex(0)), wasm PC 0x48, slot at FP-0xb0, locals , stack I32 @ slot+0x8
;;       ╰─╼ breakpoint patch: wasm PC 0x48, patch bytes [6, 1, 0, 148]
;;       ldr     x0, [x0, #0x38]
;;       ldur    x9, [sp, #0x10]
;;       ldr     x2, [x9, #0x48]
;;       ldur    x3, [sp, #0x10]
;;       blr     x0
;;       ╰─╼ debug frame state (after previous inst): func key DefinedWasmFunction(StaticModuleIndex(0), DefinedFuncIndex(0)), wasm PC 0x4a, slot at FP-0xb0, locals , stack I32 @ slot+0x8
;;  154: ldur    x0, [sp, #0x10]
;;       nop
;;       ├─╼ debug frame state (after previous inst): func key DefinedWasmFunction(StaticModuleIndex(0), DefinedFuncIndex(0)), wasm PC 0x4a, slot at FP-0xb0, locals , stack I32 @ slot+0x8
;;       ╰─╼ breakpoint patch: wasm PC 0x4a, patch bytes [255, 0, 0, 148]
;;       nop
;;       ├─╼ debug frame state (after previous inst): func key DefinedWasmFunction(StaticModuleIndex(0), DefinedFuncIndex(0)), wasm PC 0x4b, slot at FP-0xb0, locals , stack 
;;       ╰─╼ breakpoint patch: wasm PC 0x4b, patch bytes [254, 0, 0, 148]
;;       add     sp, sp, #0x20
;;       ldp     d8, d9, [sp], #0x10
;;       ldp     d10, d11, [sp], #0x10
;;       ldp     d12, d13, [sp], #0x10
;;       ldp     d14, d15, [sp], #0x10
;;       ldp     x19, x20, [sp], #0x10
;;       ldp     x21, x22, [sp], #0x10
;;       ldp     x23, x24, [sp], #0x10
;;       ldp     x25, x26, [sp], #0x10
;;       ldp     x27, x28, [sp], #0x10
;;       ldp     x29, x30, [sp], #0x10
;;       ret
;;  190: ldur    x19, [sp, #0x18]
;;  194: mov     x20, x2
;;  198: mov     w3, #2
;;  19c: movk    w3, #0x400, lsl #16
;;  1a0: ldur    x2, [sp, #0x10]
;;  1a4: ldr     x0, [x2, #0x28]
;;  1a8: ldr     w4, [x0, #8]
;;  1ac: mov     w5, #0x20
;;  1b0: mov     w6, #0x10
;;  1b4: bl      #0x3e8
;;  1b8: ldr     x0, [x19, #0x20]
;;  1bc: add     x1, x0, w2, uxtw
;;  1c0: mov     x3, x2
;;  1c4: mov     x2, x20
;;  1c8: b       #0xe0
;;  1cc: mov     w3, #9
;;  1d0: ldur    x2, [sp, #0x10]
;;  1d4: bl      #0x450
;;  1d8: ldur    x2, [sp, #0x10]
;;  1dc: bl      #0x488
;;       ╰─╼ debug frame state (after previous inst): func key DefinedWasmFunction(StaticModuleIndex(0), DefinedFuncIndex(0)), wasm PC 0x42, slot at FP-0xb0, locals , stack I32 @ slot+0x8
;;  1e0: udf     #0xc11f
;;  1e4: mov     w3, #0xfe
;;  1e8: ldur    x2, [sp, #0x10]
;;  1ec: bl      #0x450
;;  1f0: ldur    x2, [sp, #0x10]
;;  1f4: bl      #0x488
;;       ╰─╼ debug frame state (after previous inst): func key DefinedWasmFunction(StaticModuleIndex(0), DefinedFuncIndex(0)), wasm PC 0x37, slot at FP-0xb0, locals , stack 
;;  1f8: udf     #0xc11f
;;  1fc: mov     w3, #0xfe
;;  200: ldur    x2, [sp, #0x10]
;;  204: bl      #0x450
;;  208: ldur    x2, [sp, #0x10]
;;  20c: bl      #0x488
;;       ╰─╼ debug frame state (after previous inst): func key DefinedWasmFunction(StaticModuleIndex(0), DefinedFuncIndex(0)), wasm PC 0x37, slot at FP-0xb0, locals , stack 
;;  210: udf     #0xc11f
;;  214: stur    x2, [sp, #0x10]
;;  218: mov     w3, #0
;;  21c: bl      #0x450
;;  220: ldur    x2, [sp, #0x10]
;;  224: bl      #0x488
;;       ╰─╼ debug frame state (after previous inst): func key DefinedWasmFunction(StaticModuleIndex(0), DefinedFuncIndex(0)), wasm PC 0x34, slot at FP-0xb0, locals , stack 
;;  228: udf     #0xc11f
