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
;;       ja      0xf4
;;   19: subq    $0x20, %rsp
;;       movq    %rdi, (%rsp)
;;       movq    %rdx, 8(%rsp)
;;       movq    %rcx, 0x10(%rsp)
;;       callq   0x37c
;;       movq    (%rsp), %rcx
;;       movq    %rax, 0x18(%rsp)
;;       movq    0x20(%rcx), %rdx
;;       movl    (%rdx), %esi
;;       movl    %esi, %ecx
;;       leaq    0x30(%rcx), %rdi
;;       movl    4(%rdx), %eax
;;       cmpq    %rax, %rdi
;;       ja      0xb3
;;   51: leal    0x30(%rsi), %eax
;;       movl    %eax, (%rdx)
;;       movq    (%rsp), %rax
;;       movq    8(%rax), %rax
;;       movq    0x20(%rax), %rdi
;;       leaq    (%rdi, %rcx), %rdx
;;       movl    $0x4000002, (%rdi, %rcx)
;;       movq    (%rsp), %rax
;;       movq    0x28(%rax), %rax
;;       movl    0xc(%rax), %eax
;;       movl    %eax, 4(%rdi, %rcx)
;;       movl    $0x30, %eax
;;       movl    %eax, 8(%rdi, %rcx)
;;       movq    8(%rsp), %rax
;;       movl    %eax, 0x18(%rdx)
;;       movq    0x10(%rsp), %rcx
;;       movq    %rcx, 0x20(%rdx)
;;       movq    0x18(%rsp), %rax
;;       movl    %eax, 0x10(%rdx)
;;       movl    $0, 0x14(%rdx)
;;       movq    (%rsp), %rdi
;;       callq   0x3a6
;;       jmp     0xf2
;;   b3: movl    $0x4000002, %esi
;;       movq    (%rsp), %rcx
;;       movq    0x28(%rcx), %rax
;;       movl    $0x30, %ecx
;;       movl    $0x10, %r8d
;;       movl    0xc(%rax), %edx
;;       movq    (%rsp), %rdi
;;       callq   0x330
;;       movq    (%rsp), %rcx
;;       movq    8(%rcx), %rcx
;;       movl    %eax, %edx
;;       addq    0x20(%rcx), %rdx
;;       movq    %rax, %rsi
;;       movq    8(%rsp), %rax
;;       jmp     0x8a
;;   f2: ud2
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
