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
;;       ja      0xed
;;   19: subq    $0x10, %rsp
;;       movq    %rdi, 8(%rsp)
;;       movq    0x20(%rdi), %rcx
;;       movl    (%rcx), %esi
;;       movl    %esi, %eax
;;       leaq    0x20(%rax), %rdx
;;       movl    4(%rcx), %r8d
;;       cmpq    %r8, %rdx
;;       ja      0xb1
;;   3b: leal    0x20(%rsi), %edx
;;       movl    %edx, (%rcx)
;;       movq    8(%rsp), %rdi
;;       movq    8(%rdi), %rcx
;;       movq    0x20(%rcx), %rdx
;;       leaq    (%rdx, %rax), %rcx
;;       movl    $0xb0000002, (%rdx, %rax)
;;       ╰─╼ trap: GcHeapCorrupt
;;       movq    0x28(%rdi), %r8
;;       movl    (%r8), %r8d
;;       movl    %r8d, 4(%rdx, %rax)
;;       ╰─╼ trap: GcHeapCorrupt
;;       movl    $0x20, %r8d
;;       movl    %r8d, 8(%rdx, %rax)
;;       ╰─╼ trap: GcHeapCorrupt
;;       movl    %esi, (%rsp)
;;       movl    $0x2a, 0x10(%rcx)
;;       ╰─╼ trap: GcHeapCorrupt
;;       movq    8(%rsp), %rdi
;;       movq    0x38(%rdi), %rax
;;       movq    0x48(%rdi), %rdi
;;       movq    8(%rsp), %rsi
;;       callq   *%rax
;;       ├─╼ exception frame offset: SP = FP - 0x10
;;       ╰─╼ exception handler: default handler, context at [SP+0x8], handler=0x8d
;;       movl    (%rsp), %eax
;;       ╰─╼ stack_map: frame_size=16, frame_offsets=[0]
;;       testl   %eax, %eax
;;       je      0xef
;;   98: movq    8(%rsp), %rdi
;;       movq    8(%rdi), %rcx
;;       movl    %eax, %eax
;;       movq    0x20(%rcx), %rcx
;;       movl    0x10(%rcx, %rax), %eax
;;       ╰─╼ trap: GcHeapCorrupt
;;       addq    $0x10, %rsp
;;       popq    %rbp
;;       retq
;;   b1: movl    $0xb0000002, %esi
;;   b6: movq    8(%rsp), %r9
;;   bb: movq    0x28(%r9), %rax
;;   bf: movl    $0x20, %ecx
;;   c4: movl    $0x10, %r8d
;;   ca: movl    (%rax), %edx
;;   cc: movq    8(%rsp), %rdi
;;   d1: callq   0x231
;;   d6: movq    8(%rsp), %r9
;;   db: movq    8(%r9), %rdx
;;   df: movl    %eax, %ecx
;;   e1: addq    0x20(%rdx), %rcx
;;   e5: movq    %rax, %rsi
;;   e8: jmp     0x6f
;;   ed: ud2
;;       ╰─╼ trap: Normal(StackOverflow)
;;   ef: ud2
;;       ╰─╼ trap: Normal(NullReference)
