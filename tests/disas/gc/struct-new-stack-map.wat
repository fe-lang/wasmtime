;;! target = "x86_64"
;;! flags = "-W function-references,gc"
;;! test = "compile"

(module
  (type $ty (struct (field (mut f32))
                    (field (mut i8))
                    (field (mut anyref))))

  (func (param f32 i32 anyref) (result (ref $ty))
    (struct.new $ty (local.get 0) (local.get 1) (local.get 2))
  )
)
;; wasm[0]::function[0]:
;;       pushq   %rbp
;;       movq    %rsp, %rbp
;;       movq    8(%rdi), %r10
;;       movq    0x18(%r10), %r10
;;       addq    $0x40, %r10
;;       cmpq    %rsp, %r10
;;       ja      0xcf
;;   19: subq    $0x30, %rsp
;;       movl    %ecx, (%rsp)
;;       movq    0x20(%rdi), %rsi
;;       movl    (%rsi), %eax
;;       movl    %eax, %ecx
;;       leaq    0x20(%rcx), %r8
;;       movl    4(%rsi), %r9d
;;       cmpq    %r9, %r8
;;       ja      0x7d
;;   39: leal    0x20(%rax), %r8d
;;       movl    %r8d, (%rsi)
;;       movq    8(%rdi), %rsi
;;       movq    0x20(%rsi), %r8
;;       leaq    (%r8, %rcx), %rsi
;;       movl    $0xb0000022, (%r8, %rcx)
;;       movq    0x28(%rdi), %rdi
;;       movl    (%rdi), %edi
;;       movl    %edi, 4(%r8, %rcx)
;;       movl    $0x20, %edi
;;       movl    %edi, 8(%r8, %rcx)
;;       movss   %xmm0, 0x10(%rsi)
;;       movb    %dl, 0x14(%rsi)
;;       movl    (%rsp), %ecx
;;       movl    %ecx, 0x18(%rsi)
;;       addq    $0x30, %rsp
;;       popq    %rbp
;;       retq
;;   7d: movq    %rdi, %rcx
;;   80: movq    %rdx, 0x28(%rsp)
;;   85: movdqu  %xmm0, 0x18(%rsp)
;;   8b: movl    $0xb0000022, %esi
;;   90: movq    0x28(%rcx), %rax
;;   94: movq    %rcx, 8(%rsp)
;;   99: movl    $0x20, %ecx
;;   9e: movl    $0x10, %r8d
;;   a4: movl    (%rax), %edx
;;   a6: movq    8(%rsp), %rdi
;;   ab: callq   0x137
;;   b0: movq    8(%rsp), %rcx
;;       ╰─╼ stack_map: frame_size=48, frame_offsets=[0]
;;   b5: movq    8(%rcx), %rcx
;;   b9: movl    %eax, %esi
;;   bb: addq    0x20(%rcx), %rsi
;;   bf: movq    0x28(%rsp), %rdx
;;   c4: movdqu  0x18(%rsp), %xmm0
;;   ca: jmp     0x69
;;   cf: ud2
