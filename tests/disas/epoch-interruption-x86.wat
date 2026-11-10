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
;;       ja      0xbf
;;   19: subq    $0x20, %rsp
;;       movq    0x18(%rdi), %rax
;;       movq    8(%rdi), %rcx
;;       movq    (%rax), %rdx
;;       movq    8(%rcx), %r8
;;       cmpq    %r8, %rdx
;;       jae     0x46
;;   35: movq    (%rax), %rdx
;;       cmpq    %r8, %rdx
;;       jae     0x6f
;;       jmp     0x35
;;   46: movq    %rdi, (%rsp)
;;       movq    %rcx, 8(%rsp)
;;       movq    %rax, 0x10(%rsp)
;;       callq   0x107
;;       movq    %rax, %r8
;;       movq    (%rsp), %rdi
;;       movq    8(%rsp), %rcx
;;       movq    0x10(%rsp), %rax
;;       jmp     0x35
;;   6f: movq    %rdi, (%rsp)
;;       movq    %rax, 0x10(%rsp)
;;       movq    8(%rcx), %rax
;;       movq    %rcx, 8(%rsp)
;;       cmpq    %rax, %rdx
;;       jae     0xa0
;;   8a: movq    %rax, %r8
;;       movq    (%rsp), %rdi
;;       movq    8(%rsp), %rcx
;;       movq    0x10(%rsp), %rax
;;       jmp     0x35
;;   a0: movq    (%rsp), %rdi
;;       callq   0x107
;;       movq    %rax, %r8
;;       movq    (%rsp), %rdi
;;       movq    8(%rsp), %rcx
;;       movq    0x10(%rsp), %rax
;;       jmp     0x35
;;   bf: ud2
