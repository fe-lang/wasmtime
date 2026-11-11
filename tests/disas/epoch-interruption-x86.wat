;;! target = "x86_64"
;;! test = "compile"
;;! flags = ["-Wepoch-interruption=y"]

(module (func (loop (br 0))))

;; wasm[0]::function[0]:
;;       pushq   %rbp
;;       movq    %rsp, %rbp
;;       movq    8(%rdi), %r10
;;       movq    0x18(%r10), %r10
;;       addq    $0x30, %r10
;;       cmpq    %rsp, %r10
;;       ja      0xb5
;;   19: subq    $0x20, %rsp
;;       movq    0x18(%rdi), %rax
;;       movq    8(%rdi), %rcx
;;       movq    (%rax), %rdx
;;       movq    8(%rcx), %r8
;;       cmpq    %r8, %rdx
;;       jae     0x46
;;   35: movq    (%rax), %rdx
;;       cmpq    %r8, %rdx
;;       jae     0x6b
;;       jmp     0x35
;;   46: movq    %rdi, -0x10(%rbp)
;;       movq    %rcx, (%rsp)
;;       movq    %rax, -0x18(%rbp)
;;       callq   0xfd
;;       movq    %rax, %r8
;;       movq    -0x10(%rbp), %rdi
;;       movq    (%rsp), %rcx
;;       movq    -0x18(%rbp), %rax
;;       jmp     0x35
;;   6b: movq    %rdi, -0x10(%rbp)
;;       movq    %rax, -0x18(%rbp)
;;       movq    8(%rcx), %rax
;;       movq    %rcx, (%rsp)
;;       cmpq    %rax, %rdx
;;       jae     0x98
;;   84: movq    %rax, %r8
;;       movq    -0x10(%rbp), %rdi
;;       movq    (%rsp), %rcx
;;       movq    -0x18(%rbp), %rax
;;       jmp     0x35
;;   98: movq    -0x10(%rbp), %rdi
;;       callq   0xfd
;;       movq    %rax, %r8
;;       movq    -0x10(%rbp), %rdi
;;       movq    (%rsp), %rcx
;;       movq    -0x18(%rbp), %rax
;;       jmp     0x35
;;   b5: ud2
