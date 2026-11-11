;;! target = "x86_64"
;;! flags = "-W function-references=n,gc=n"
;;! test = "compile"

(module
  (table (export "t") 0 100 funcref)
  (func (export "f") (param i32 i32) (result i32)
    (call_indirect (param i32) (result i32) (local.get 0) (local.get 1))
  )
)

;; wasm[0]::function[0]:
;;       pushq   %rbp
;;       movq    %rsp, %rbp
;;       movq    8(%rdi), %r10
;;       movq    0x18(%r10), %r10
;;       addq    $0x20, %r10
;;       cmpq    %rsp, %r10
;;       ja      0x9a
;;   19: subq    $0x10, %rsp
;;       movq    %rcx, %rax
;;       movq    0x38(%rdi), %rsi
;;       xorq    %rcx, %rcx
;;       movq    %rax, %r9
;;       movl    %r9d, %eax
;;       movq    %rax, %r8
;;       shlq    $3, %r8
;;       addq    0x30(%rdi), %r8
;;       cmpl    %esi, %r9d
;;       cmovaeq %rcx, %r8
;;       movq    (%r8), %rsi
;;       movq    %rsi, %rcx
;;       andq    $0xfffffffffffffffe, %rcx
;;       testq   %rsi, %rsi
;;       je      0x78
;;   52: movq    0x28(%rdi), %rax
;;       movq    %rdi, %r8
;;       movl    0x10(%rcx), %esi
;;       cmpl    4(%rax), %esi
;;       jne     0x9c
;;   65: movq    8(%rcx), %rax
;;       movq    0x18(%rcx), %rdi
;;       movq    %r8, %rsi
;;       callq   *%rax
;;       addq    $0x10, %rsp
;;       popq    %rbp
;;       retq
;;   78: movq    %rdx, -8(%rbp)
;;   7c: movq    %rdi, (%rsp)
;;   80: movq    %rax, %rdx
;;   83: xorl    %esi, %esi
;;   85: callq   0x1f8
;;   8a: movq    %rax, %rcx
;;   8d: movq    -8(%rbp), %rdx
;;   91: movq    (%rsp), %rdi
;;   95: jmp     0x52
;;   9a: ud2
;;   9c: ud2
