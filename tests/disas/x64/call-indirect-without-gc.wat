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
;;       ja      0x8e
;;   19: subq    $0x10, %rsp
;;       movq    0x38(%rdi), %rax
;;       movq    0x30(%rdi), %r9
;;       xorq    %r8, %r8
;;       movl    %ecx, %esi
;;       leaq    (%r9, %rsi, 8), %r9
;;       cmpl    %eax, %ecx
;;       cmovaeq %r8, %r9
;;       movq    (%r9), %rcx
;;       movq    %rcx, %rax
;;       andq    $0xfffffffffffffffe, %rax
;;       testq   %rcx, %rcx
;;       je      0x6d
;;   47: movl    0x10(%rax), %ecx
;;       movq    0x28(%rdi), %rsi
;;       movq    %rdi, %r8
;;       cmpl    4(%rsi), %ecx
;;       jne     0x90
;;   5a: movq    8(%rax), %rcx
;;       movq    0x18(%rax), %rdi
;;       movq    %r8, %rsi
;;       callq   *%rcx
;;       addq    $0x10, %rsp
;;       popq    %rbp
;;       retq
;;   6d: movq    %rdx, 8(%rsp)
;;   72: movq    %rdi, (%rsp)
;;   76: movq    %rsi, %rdx
;;   79: xorl    %esi, %esi
;;   7b: callq   0x1fe
;;   80: movq    8(%rsp), %rdx
;;   85: movq    (%rsp), %rdi
;;   89: jmp     0x47
;;   8e: ud2
;;   90: ud2
