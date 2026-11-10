;;! target = "x86_64"
;;! test = "compile"
;;! objdump = "--filter array_to_wasm --funcs all"

(module (func (export "")))

;; wasm[0]::array_to_wasm_trampoline[0]:
;;       pushq   %rbp
;;       movq    %rsp, %rbp
;;       subq    $0x40, %rsp
;;       movq    %rbx, 0x10(%rsp)
;;       movq    %r12, 0x18(%rsp)
;;       movq    %r13, 0x20(%rsp)
;;       movq    %r14, 0x28(%rsp)
;;       movq    %r15, 0x30(%rsp)
;;       movq    %rbp, %rcx
;;       movq    8(%rdi), %r8
;;       movq    %rcx, 0x48(%r8)
;;       movq    %rsp, %rcx
;;       movq    %rcx, 0x40(%r8)
;;       leaq    0x31(%rip), %rcx
;;       movq    %rcx, 0x50(%r8)
;;       movq    %r8, (%rsp)
;;       callq   0
;;       ├─╼ exception frame offset: SP = FP - 0x40
;;       ╰─╼ exception handler: default handler, no dynamic context, handler=0x71
;;       movl    $1, %eax
;;       movq    0x10(%rsp), %rbx
;;       movq    0x18(%rsp), %r12
;;       movq    0x20(%rsp), %r13
;;       movq    0x28(%rsp), %r14
;;       movq    0x30(%rsp), %r15
;;       addq    $0x40, %rsp
;;       popq    %rbp
;;       retq
;;   71: movq    (%rsp), %r8
;;   75: movq    $1, 0x88(%r8)
;;   80: xorl    %eax, %eax
;;   82: movq    0x10(%rsp), %rbx
;;   87: movq    0x18(%rsp), %r12
;;   8c: movq    0x20(%rsp), %r13
;;   91: movq    0x28(%rsp), %r14
;;   96: movq    0x30(%rsp), %r15
;;   9b: addq    $0x40, %rsp
;;   9f: popq    %rbp
;;   a0: retq
