;;! target = "x86_64"
;;! flags = "-W gc,exceptions"
;;! test = "compile"
;;! objdump = "--stack-maps=true"

(module
  (type $s (struct (field (mut i32))))

  (import "" "gc" (func $gc))

  (func (export "run") (result i32)
    (struct.new $s (i32.const 42))

    block $b
      try_table (catch_all $b)
        ;; This should have both exception handlers and stack maps in the
        ;; disassembly below.
        call $gc
      end
    end

    struct.get $s 0
  )
)
;; wasm[0]::function[1]:
;;       pushq   %rbp
;;       movq    %rsp, %rbp
;;       movq    8(%rdi), %r10
;;       movq    0x18(%r10), %r10
;;       addq    $0x20, %r10
;;       cmpq    %rsp, %r10
;;       ja      0xe7
;;   19: subq    $0x10, %rsp
;;       movq    %rdi, 8(%rsp)
;;       movq    0x20(%rdi), %rax
;;       movl    (%rax), %esi
;;       leaq    0x20(%rsi), %rcx
;;       movl    4(%rax), %edx
;;       cmpq    %rdx, %rcx
;;       ja      0xa8
;;   38: leal    0x20(%rsi), %ecx
;;       movl    %ecx, (%rax)
;;       movq    8(%rsp), %rdi
;;       movq    8(%rdi), %rax
;;       movq    0x20(%rax), %rcx
;;       leaq    (%rcx, %rsi), %rax
;;       movl    $0xb0000002, (%rcx, %rsi)
;;       ╰─╼ trap: GcHeapCorrupt
;;       movq    0x28(%rdi), %rdx
;;       movl    (%rdx), %edx
;;       movl    %edx, 4(%rcx, %rsi)
;;       ╰─╼ trap: GcHeapCorrupt
;;       movl    $0x20, %edx
;;       movl    %edx, 8(%rcx, %rsi)
;;       ╰─╼ trap: GcHeapCorrupt
;;       movl    %esi, (%rsp)
;;       movl    $0x2a, 0x10(%rax)
;;       ╰─╼ trap: GcHeapCorrupt
;;       movq    8(%rsp), %rdi
;;       movq    0x38(%rdi), %rax
;;       movq    0x48(%rdi), %rdi
;;       movq    8(%rsp), %rsi
;;       callq   *%rax
;;       ├─╼ exception frame offset: SP = FP - 0x10
;;       ╰─╼ exception handler: default handler, context at [SP+0x8], handler=0x86
;;       movl    (%rsp), %eax
;;       ╰─╼ stack_map: frame_size=16, frame_offsets=[0]
;;       testl   %eax, %eax
;;       je      0xe9
;;   91: movq    8(%rsp), %rdi
;;       movq    8(%rdi), %rcx
;;       movq    0x20(%rcx), %rcx
;;       movl    0x10(%rcx, %rax), %eax
;;       ╰─╼ trap: GcHeapCorrupt
;;       addq    $0x10, %rsp
;;       popq    %rbp
;;       retq
;;   a8: movl    $0xb0000002, %esi
;;   ad: movq    8(%rsp), %rax
;;   b2: movq    0x28(%rax), %rax
;;   b6: movl    $0x20, %ecx
;;   bb: movl    $0x10, %r8d
;;   c1: movl    (%rax), %edx
;;   c3: movq    8(%rsp), %rdi
;;   c8: callq   0x22b
;;   cd: movq    8(%rsp), %rsi
;;   d2: movq    8(%rsi), %rdx
;;   d6: movl    %eax, %ecx
;;   d8: addq    0x20(%rdx), %rcx
;;   dc: movq    %rax, %rsi
;;   df: movq    %rcx, %rax
;;   e2: jmp     0x68
;;   e7: ud2
;;       ╰─╼ trap: Normal(StackOverflow)
;;   e9: ud2
;;       ╰─╼ trap: Normal(NullReference)
