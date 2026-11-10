;;! target = "x86_64"
;;! test = "compile"
;;! flags = ["-Wexceptions=yes", "-Wgc=yes"]

(module
 (tag $e0 (param i32 i64))

 (func $throw (param i32 i64)
       (throw $e0 (local.get 0) (local.get 1)))

 (func $catch (export "catch") (param i32 i64) (result i32 i64)

       (block $b (result i32 i64)
              (try_table (result i32 i64)
                         (catch $e0 $b)
                         (call $throw (local.get 0) (local.get 1))
                         (i32.const 42)
                         (i64.const 100)))))
;; wasm[0]::function[0]::throw:
;;       pushq   %rbp
;;       movq    %rsp, %rbp
;;       movq    8(%rdi), %r10
;;       movq    0x18(%r10), %r10
;;       addq    $0x30, %r10
;;       cmpq    %rsp, %r10
;;       ja      0xeb
;;   19: subq    $0x20, %rsp
;;       movq    %rdi, -8(%rbp)
;;       movq    %rdx, -0x10(%rbp)
;;       movq    %rcx, (%rsp)
;;       callq   0x367
;;       movq    -8(%rbp), %rcx
;;       movq    %rax, -0x18(%rbp)
;;       movq    0x20(%rcx), %rcx
;;       movl    (%rcx), %esi
;;       leaq    0x30(%rsi), %rdx
;;       movl    4(%rcx), %eax
;;       cmpq    %rax, %rdx
;;       ja      0xab
;;   4c: leal    0x30(%rsi), %eax
;;       movl    %eax, (%rcx)
;;       movq    -8(%rbp), %rcx
;;       movq    8(%rcx), %rax
;;       movq    0x20(%rax), %rdx
;;       leaq    (%rdx, %rsi), %rcx
;;       movl    $0x4000002, (%rdx, %rsi)
;;       movq    -8(%rbp), %rax
;;       movq    0x28(%rax), %rax
;;       movl    0xc(%rax), %eax
;;       movl    %eax, 4(%rdx, %rsi)
;;       movl    $0x30, %eax
;;       movl    %eax, 8(%rdx, %rsi)
;;       movq    -0x10(%rbp), %rdx
;;       movl    %edx, 0x18(%rcx)
;;       movq    (%rsp), %rax
;;       movq    %rax, 0x20(%rcx)
;;       movq    -0x18(%rbp), %rax
;;       movl    %eax, 0x10(%rcx)
;;       movl    $0, 0x14(%rcx)
;;       movq    -8(%rbp), %rdi
;;       callq   0x391
;;       jmp     0xe9
;;   ab: movl    $0x4000002, %esi
;;       movq    -8(%rbp), %rcx
;;       movq    0x28(%rcx), %rax
;;       movl    $0x30, %ecx
;;       movl    $0x10, %r8d
;;       movl    0xc(%rax), %edx
;;       movq    -8(%rbp), %rdi
;;       callq   0x31b
;;       movq    -8(%rbp), %rcx
;;       movq    8(%rcx), %rdx
;;       movl    %eax, %ecx
;;       addq    0x20(%rdx), %rcx
;;       movq    -0x10(%rbp), %rdx
;;       movq    %rax, %rsi
;;       jmp     0x84
;;   e9: ud2
;;       ud2
;;
;; wasm[0]::function[1]::catch:
;;       pushq   %rbp
;;       movq    %rsp, %rbp
;;       movq    8(%rdi), %r10
;;       movq    0x18(%r10), %r10
;;       addq    $0x20, %r10
;;       cmpq    %rsp, %r10
;;       ja      0x15d
;;  119: subq    $0x10, %rsp
;;       movq    %rdi, (%rsp)
;;       movq    (%rsp), %rsi
;;       movq    (%rsp), %rdi
;;       callq   0
;;       ├─╼ exception frame offset: SP = FP - 0x10
;;       ╰─╼ exception handler: tag=0, context at [SP+0x0], handler=0x13d
;;       movl    $0x2a, %eax
;;       movl    $0x64, %ecx
;;       jmp     0x157
;;  13d: movq    %rax, %rcx
;;       movq    (%rsp), %rsi
;;       movq    8(%rsi), %rax
;;       movl    %ecx, %ecx
;;       movq    0x20(%rax), %rdx
;;       movl    0x18(%rdx, %rcx), %eax
;;       movq    0x20(%rdx, %rcx), %rcx
;;       addq    $0x10, %rsp
;;       popq    %rbp
;;       retq
;;  15d: ud2
