;;! target = "x86_64"
;;! test = "compile"
;;! objdump = "--filter array_to_wasm --funcs all"

(module (func (export "")))

;; wasm[0]::array_to_wasm_trampoline[0]:
;;       pushq   %rbp
;;       movq    %rsp, %rbp
;;       subq    $0x40, %rsp
;;       movq    %rbx, -0x30(%rbp)
;;       movq    %r12, -0x28(%rbp)
;;       movq    %r13, -0x20(%rbp)
;;       movq    %r14, -0x18(%rbp)
;;       movq    %r15, -0x10(%rbp)
;;       movq    %rbp, %rcx
;;       movq    8(%rdi), %r8
;;       movq    %rcx, 0x48(%r8)
;;       movq    %rsp, %rcx
;;       movq    %rcx, 0x40(%r8)
;;       leaq    0x2c(%rip), %rcx
;;       movq    %rcx, 0x50(%r8)
;;       movq    %r8, (%rsp)
;;       callq   0
;;       ├─╼ exception frame offset: SP = FP - 0x40
;;       ╰─╼ exception handler: default handler, no dynamic context, handler=0x67
;;       movl    $1, %eax
;;       movq    -0x30(%rbp), %rbx
;;       movq    -0x28(%rbp), %r12
;;       movq    -0x20(%rbp), %r13
;;       movq    -0x18(%rbp), %r14
;;       movq    -0x10(%rbp), %r15
;;       addq    $0x40, %rsp
;;       popq    %rbp
;;       retq
;;   67: movq    (%rsp), %r8
;;   6b: movq    $1, 0x88(%r8)
;;   76: xorl    %eax, %eax
;;   78: movq    -0x30(%rbp), %rbx
;;   7c: movq    -0x28(%rbp), %r12
;;   80: movq    -0x20(%rbp), %r13
;;   84: movq    -0x18(%rbp), %r14
;;   88: movq    -0x10(%rbp), %r15
;;   8c: addq    $0x40, %rsp
;;   90: popq    %rbp
;;   91: retq
