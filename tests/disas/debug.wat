;;! target = "x86_64"
;;! test = "compile"
;;! flags = ["-Dguest-debug=yes"]
;;! objdump = "--funcs all"

(module
  (func (export "main") (param i32 i32) (result i32)
    local.get 0
    local.get 1
    i32.add))
;; wasm[0]::function[0]:
;;       pushq   %rbp
;;       movq    %rsp, %rbp
;;       subq    $0x20, %rsp
;;       movl    %edx, -0x18(%rbp)
;;       movl    %ecx, -0x14(%rbp)
;;       movq    8(%rdi), %r11
;;       movq    %rsp, %rax
;;       movq    0x18(%r11), %r11
;;       cmpq    %r11, %rax
;;       jb      0x4f
;;   22: movq    %rdi, (%rsp)
;;       nopl    (%rax, %rax)
;;       ├─╼ debug frame state (after previous inst): func key DefinedWasmFunction(StaticModuleIndex(0), DefinedFuncIndex(0)), wasm PC 0x24, slot at FP-0x20, locals I32 @ slot+0x8, I32 @ slot+0xc, stack 
;;       ╰─╼ breakpoint patch: wasm PC 0x24, patch bytes [232, 149, 1, 0, 0]
;;       movl    %edx, -0x10(%rbp)
;;       nopl    (%rax, %rax)
;;       ├─╼ debug frame state (after previous inst): func key DefinedWasmFunction(StaticModuleIndex(0), DefinedFuncIndex(0)), wasm PC 0x26, slot at FP-0x20, locals I32 @ slot+0x8, I32 @ slot+0xc, stack I32 @ slot+0x10
;;       ╰─╼ breakpoint patch: wasm PC 0x26, patch bytes [232, 141, 1, 0, 0]
;;       movl    %ecx, -0xc(%rbp)
;;       nopl    (%rax, %rax)
;;       ├─╼ debug frame state (after previous inst): func key DefinedWasmFunction(StaticModuleIndex(0), DefinedFuncIndex(0)), wasm PC 0x28, slot at FP-0x20, locals I32 @ slot+0x8, I32 @ slot+0xc, stack I32 @ slot+0x10, I32 @ slot+0x14
;;       ╰─╼ breakpoint patch: wasm PC 0x28, patch bytes [232, 133, 1, 0, 0]
;;       leal    (%rdx, %rcx), %eax
;;       movl    %eax, -0x10(%rbp)
;;       nopl    (%rax, %rax)
;;       ├─╼ debug frame state (after previous inst): func key DefinedWasmFunction(StaticModuleIndex(0), DefinedFuncIndex(0)), wasm PC 0x29, slot at FP-0x20, locals I32 @ slot+0x8, I32 @ slot+0xc, stack I32 @ slot+0x10
;;       ╰─╼ breakpoint patch: wasm PC 0x29, patch bytes [232, 122, 1, 0, 0]
;;       movl    %eax, -0x10(%rbp)
;;       addq    $0x20, %rsp
;;       popq    %rbp
;;       retq
;;   4f: movq    %rdi, -8(%rbp)
;;   53: xorl    %esi, %esi
;;   55: callq   0x168
;;   5a: movq    -8(%rbp), %rdi
;;   5e: callq   0x196
;;       ╰─╼ debug frame state (after previous inst): func key DefinedWasmFunction(StaticModuleIndex(0), DefinedFuncIndex(0)), wasm PC 0x23, slot at FP-0x20, locals I32 @ slot+0x8, I32 @ slot+0xc, stack 
;;   63: ud2
;;
;; wasm[0]::array_to_wasm_trampoline[0]:
;;       pushq   %rbp
;;       movq    %rsp, %rbp
;;       subq    $0x40, %rsp
;;       movq    %rbx, -0x30(%rbp)
;;       movq    %r12, -0x28(%rbp)
;;       movq    %r13, -0x20(%rbp)
;;       movq    %r14, -0x18(%rbp)
;;       movq    %r15, -0x10(%rbp)
;;       movl    (%rdx), %r8d
;;       movl    0x10(%rdx), %ecx
;;       movq    %rdx, (%rsp)
;;       movq    %rbp, %r9
;;       movq    8(%rdi), %r10
;;       movq    %r9, 0x48(%r10)
;;       movq    %rsp, %r9
;;       movq    %r9, 0x40(%r10)
;;       leaq    0x35(%rip), %r9
;;       movq    %r9, 0x50(%r10)
;;       movq    %r8, %rdx
;;       movq    %r10, -0x38(%rbp)
;;       callq   0
;;       ├─╼ exception frame offset: SP = FP - 0x40
;;       ╰─╼ exception handler: default handler, no dynamic context, handler=0xd9
;;       movq    (%rsp), %rdx
;;       movl    %eax, (%rdx)
;;       movl    $1, %eax
;;       movq    -0x30(%rbp), %rbx
;;       movq    -0x28(%rbp), %r12
;;       movq    -0x20(%rbp), %r13
;;       movq    -0x18(%rbp), %r14
;;       movq    -0x10(%rbp), %r15
;;       addq    $0x40, %rsp
;;       popq    %rbp
;;       retq
;;   d9: movq    -0x38(%rbp), %r10
;;   dd: movq    $1, 0x88(%r10)
;;   e8: xorl    %eax, %eax
;;   ea: movq    -0x30(%rbp), %rbx
;;   ee: movq    -0x28(%rbp), %r12
;;   f2: movq    -0x20(%rbp), %r13
;;   f6: movq    -0x18(%rbp), %r14
;;   fa: movq    -0x10(%rbp), %r15
;;   fe: addq    $0x40, %rsp
;;  102: popq    %rbp
;;  103: retq
;;
;; signatures[0]::wasm_to_array_trampoline:
;;       pushq   %rbp
;;       movq    %rsp, %rbp
;;       subq    $0x20, %rsp
;;       movq    %rdx, %r8
;;       movq    %rbp, %rdx
;;       movq    8(%rsi), %r15
;;       movq    %rsi, %rbx
;;       movq    %rdx, 0x30(%r15)
;;       movq    %rbp, %rax
;;       movq    8(%rax), %rax
;;       movq    %rax, 0x38(%r15)
;;       leaq    (%rsp), %rdx
;;       movq    %r8, %rax
;;       movl    %eax, (%rsp)
;;       movl    %ecx, -0x10(%rbp)
;;       movl    $2, %ecx
;;       movq    8(%rdi), %rax
;;       callq   *%rax
;;       addq    $1, 0x10(%r15)
;;       testb   %al, %al
;;       je      0x156
;;  14d: movl    (%rsp), %eax
;;       addq    $0x20, %rsp
;;       popq    %rbp
;;       retq
;;  156: movq    %rbx, %rdi
;;  159: movq    0x10(%rdi), %rax
;;  15d: movq    0x148(%rax), %rax
;;  164: callq   *%rax
;;  166: ud2
;;
;; wasmtime_builtin_trap:
;;       pushq   %rbp
;;       movq    %rsp, %rbp
;;       movq    %rbp, %r10
;;       movq    8(%rdi), %r9
;;       movq    %r10, 0x30(%r9)
;;       movq    %rbp, %r10
;;       movq    8(%r10), %r11
;;       movq    %r11, 0x38(%r9)
;;       movq    0x10(%rdi), %r11
;;       movq    0x140(%r11), %r11
;;       movzbq  %sil, %rsi
;;       callq   *%r11
;;       popq    %rbp
;;       retq
;;
;; wasmtime_builtin_raise:
;;       pushq   %rbp
;;       movq    %rsp, %rbp
;;       movq    %rbp, %r9
;;       movq    8(%rdi), %r8
;;       movq    %r9, 0x30(%r8)
;;       movq    %rbp, %r9
;;       movq    8(%r9), %r9
;;       movq    %r9, 0x38(%r8)
;;       movq    0x10(%rdi), %r9
;;       movq    0x148(%r9), %r9
;;       callq   *%r9
;;       popq    %rbp
;;       retq
;;
;; wasmtime_patchable_builtin_breakpoint:
;;       pushq   %rbp
;;       movq    %rsp, %rbp
;;       subq    $0x160, %rsp
;;       movq    %rax, -0x160(%rbp)
;;       movq    %rcx, -0x158(%rbp)
;;       movq    %rdx, -0x150(%rbp)
;;       movq    %rsi, -0x148(%rbp)
;;       movq    %rdi, -0x140(%rbp)
;;       movq    %r8, -0x138(%rbp)
;;       movq    %r9, -0x130(%rbp)
;;       movq    %r10, -0x128(%rbp)
;;       movq    %r11, -0x120(%rbp)
;;       movq    %r12, -0x118(%rbp)
;;       movq    %r13, -0x110(%rbp)
;;       movdqu  %xmm0, -0x100(%rbp)
;;       movdqu  %xmm1, -0xf0(%rbp)
;;       movdqu  %xmm2, -0xe0(%rbp)
;;       movdqu  %xmm3, -0xd0(%rbp)
;;       movdqu  %xmm4, -0xc0(%rbp)
;;       movdqu  %xmm5, -0xb0(%rbp)
;;       movdqu  %xmm6, -0xa0(%rbp)
;;       movdqu  %xmm7, -0x90(%rbp)
;;       movdqu  %xmm8, -0x80(%rbp)
;;       movdqu  %xmm9, -0x70(%rbp)
;;       movdqu  %xmm10, -0x60(%rbp)
;;       movdqu  %xmm11, -0x50(%rbp)
;;       movdqu  %xmm12, -0x40(%rbp)
;;       movdqu  %xmm13, -0x30(%rbp)
;;       movdqu  %xmm14, -0x20(%rbp)
;;       movdqu  %xmm15, -0x10(%rbp)
;;       movq    %rbp, %r10
;;       movq    8(%rdi), %r9
;;       movq    %r10, 0x30(%r9)
;;       movq    %rbp, %r10
;;       movq    8(%r10), %r11
;;       movq    %r11, 0x38(%r9)
;;       movq    0x10(%rdi), %r12
;;       movq    %rdi, %r13
;;       movq    0x170(%r12), %r11
;;       callq   *%r11
;;       testb   %al, %al
;;       je      0x37e
;;  2b8: movq    -0x160(%rbp), %rax
;;       movq    -0x158(%rbp), %rcx
;;       movq    -0x150(%rbp), %rdx
;;       movq    -0x148(%rbp), %rsi
;;       movq    -0x140(%rbp), %rdi
;;       movq    -0x138(%rbp), %r8
;;       movq    -0x130(%rbp), %r9
;;       movq    -0x128(%rbp), %r10
;;       movq    -0x120(%rbp), %r11
;;       movq    -0x118(%rbp), %r12
;;       movq    -0x110(%rbp), %r13
;;       movdqu  -0x100(%rbp), %xmm0
;;       movdqu  -0xf0(%rbp), %xmm1
;;       movdqu  -0xe0(%rbp), %xmm2
;;       movdqu  -0xd0(%rbp), %xmm3
;;       movdqu  -0xc0(%rbp), %xmm4
;;       movdqu  -0xb0(%rbp), %xmm5
;;       movdqu  -0xa0(%rbp), %xmm6
;;       movdqu  -0x90(%rbp), %xmm7
;;       movdqu  -0x80(%rbp), %xmm8
;;       movdqu  -0x70(%rbp), %xmm9
;;       movdqu  -0x60(%rbp), %xmm10
;;       movdqu  -0x50(%rbp), %xmm11
;;       movdqu  -0x40(%rbp), %xmm12
;;       movdqu  -0x30(%rbp), %xmm13
;;       movdqu  -0x20(%rbp), %xmm14
;;       movdqu  -0x10(%rbp), %xmm15
;;       addq    $0x160, %rsp
;;       popq    %rbp
;;       retq
;;  37e: movq    %r13, %rdi
;;  381: movq    0x148(%r12), %rax
;;  389: callq   *%rax
;;  38b: ud2
