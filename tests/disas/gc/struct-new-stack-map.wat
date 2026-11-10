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
;;       ja      0xc8
;;   19: subq    $0x30, %rsp
;;       movl    %ecx, (%rsp)
;;       movq    0x20(%rdi), %rcx
;;       movl    (%rcx), %eax
;;       leaq    0x20(%rax), %rsi
;;       movl    4(%rcx), %r8d
;;       cmpq    %r8, %rsi
;;       ja      0x76
;;   37: leal    0x20(%rax), %esi
;;       movl    %esi, (%rcx)
;;       movq    8(%rdi), %rcx
;;       movq    0x20(%rcx), %rsi
;;       leaq    (%rsi, %rax), %rcx
;;       movl    $0xb0000022, (%rsi, %rax)
;;       movq    0x28(%rdi), %rdi
;;       movl    (%rdi), %edi
;;       movl    %edi, 4(%rsi, %rax)
;;       movl    $0x20, %edi
;;       movl    %edi, 8(%rsi, %rax)
;;       movss   %xmm0, 0x10(%rcx)
;;       movb    %dl, 0x14(%rcx)
;;       movl    (%rsp), %edx
;;       movl    %edx, 0x18(%rcx)
;;       addq    $0x30, %rsp
;;       popq    %rbp
;;       retq
;;   76: movq    %rdi, %rcx
;;   79: movq    %rdx, 0x28(%rsp)
;;   7e: movdqu  %xmm0, 0x18(%rsp)
;;   84: movl    $0xb0000022, %esi
;;   89: movq    0x28(%rcx), %rax
;;   8d: movq    %rcx, 8(%rsp)
;;   92: movl    $0x20, %ecx
;;   97: movl    $0x10, %r8d
;;   9d: movl    (%rax), %edx
;;   9f: movq    8(%rsp), %rdi
;;   a4: callq   0x130
;;   a9: movq    8(%rsp), %rcx
;;       ╰─╼ stack_map: frame_size=48, frame_offsets=[0]
;;   ae: movq    8(%rcx), %rdx
;;   b2: movl    %eax, %ecx
;;   b4: addq    0x20(%rdx), %rcx
;;   b8: movq    0x28(%rsp), %rdx
;;   bd: movdqu  0x18(%rsp), %xmm0
;;   c3: jmp     0x62
;;   c8: ud2
