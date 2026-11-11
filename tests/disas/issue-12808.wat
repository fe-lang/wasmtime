;;! target = "x86_64"
;;! test = "compile"
;;! flags = ["-Dguest-debug=yes", "-Wthreads=yes"]

(module
  (memory 1 1 shared)
  (func (result i32 i32)
    i32.const 0
    i32.const 0
    i32.const 0
    i32.const 0
    i32.atomic.rmw.cmpxchg))
;; wasm[0]::function[0]:
;;       pushq   %rbp
;;       movq    %rsp, %rbp
;;       subq    $0x20, %rsp
;;       movq    8(%rdi), %rax
;;       movq    %rsp, %rcx
;;       movq    0x18(%rax), %rax
;;       cmpq    %rax, %rcx
;;       jb      0x7f
;;   1c: movq    %rdi, (%rsp)
;;       nopl    (%rax, %rax)
;;       ├─╼ debug frame state (after previous inst): func key DefinedWasmFunction(StaticModuleIndex(0), DefinedFuncIndex(0)), wasm PC 0x1f, slot at FP-0x20, locals , stack 
;;       ╰─╼ breakpoint patch: wasm PC 0x1f, patch bytes [232, 188, 1, 0, 0]
;;       movl    $0, -0x18(%rbp)
;;       nopl    (%rax, %rax)
;;       ├─╼ debug frame state (after previous inst): func key DefinedWasmFunction(StaticModuleIndex(0), DefinedFuncIndex(0)), wasm PC 0x21, slot at FP-0x20, locals , stack I32 @ slot+0x8
;;       ╰─╼ breakpoint patch: wasm PC 0x21, patch bytes [232, 176, 1, 0, 0]
;;       movl    $0, -0x14(%rbp)
;;       nopl    (%rax, %rax)
;;       ├─╼ debug frame state (after previous inst): func key DefinedWasmFunction(StaticModuleIndex(0), DefinedFuncIndex(0)), wasm PC 0x23, slot at FP-0x20, locals , stack I32 @ slot+0x8, I32 @ slot+0xc
;;       ╰─╼ breakpoint patch: wasm PC 0x23, patch bytes [232, 164, 1, 0, 0]
;;       movl    $0, -0x10(%rbp)
;;       nopl    (%rax, %rax)
;;       ├─╼ debug frame state (after previous inst): func key DefinedWasmFunction(StaticModuleIndex(0), DefinedFuncIndex(0)), wasm PC 0x25, slot at FP-0x20, locals , stack I32 @ slot+0x8, I32 @ slot+0xc, I32 @ slot+0x10
;;       ╰─╼ breakpoint patch: wasm PC 0x25, patch bytes [232, 152, 1, 0, 0]
;;       movl    $0, -0xc(%rbp)
;;       nopl    (%rax, %rax)
;;       ├─╼ debug frame state (after previous inst): func key DefinedWasmFunction(StaticModuleIndex(0), DefinedFuncIndex(0)), wasm PC 0x27, slot at FP-0x20, locals , stack I32 @ slot+0x8, I32 @ slot+0xc, I32 @ slot+0x10, I32 @ slot+0x14
;;       ╰─╼ breakpoint patch: wasm PC 0x27, patch bytes [232, 140, 1, 0, 0]
;;       movq    0x30(%rdi), %rcx
;;       xorl    %eax, %eax
;;       movq    (%rcx), %rcx
;;       lock cmpxchgl %eax, (%rcx)
;;       movl    %eax, -0x14(%rbp)
;;       movq    %rax, %rcx
;;       nopl    (%rax, %rax)
;;       ├─╼ debug frame state (after previous inst): func key DefinedWasmFunction(StaticModuleIndex(0), DefinedFuncIndex(0)), wasm PC 0x2b, slot at FP-0x20, locals , stack I32 @ slot+0x8, I32 @ slot+0xc
;;       ╰─╼ breakpoint patch: wasm PC 0x2b, patch bytes [232, 116, 1, 0, 0]
;;       xorl    %eax, %eax
;;       movl    $0, -0x18(%rbp)
;;       movl    %ecx, -0x14(%rbp)
;;       addq    $0x20, %rsp
;;       popq    %rbp
;;       retq
;;   7f: movq    %rdi, -8(%rbp)
;;   83: xorl    %esi, %esi
;;   85: callq   0x189
;;   8a: movq    -8(%rbp), %rdi
;;   8e: callq   0x1b7
;;       ╰─╼ debug frame state (after previous inst): func key DefinedWasmFunction(StaticModuleIndex(0), DefinedFuncIndex(0)), wasm PC 0x1e, slot at FP-0x20, locals , stack 
;;   93: ud2
