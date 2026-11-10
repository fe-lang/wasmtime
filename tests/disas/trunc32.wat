;;! target = "x86_64-unknown-linux-gnu"
;;! test = "compile"
;;! flags = "-Ccompiler=cranelift -Ccranelift-has_sse41=false  -Osignals-based-traps=n"

(module
  (func (export "i32.trunc_f32_u") (param f32) (result i32)
    (i32.trunc_f32_u (local.get 0))
  )
)
;; wasm[0]::function[0]:
;;       pushq   %rbp
;;       movq    %rsp, %rbp
;;       subq    $0x20, %rsp
;;       movdqu  %xmm0, 0x10(%rsp)
;;       movq    8(%rdi), %rax
;;       movq    %rdi, (%rsp)
;;       movq    %rsp, %rcx
;;       movq    0x18(%rax), %rax
;;       cmpq    %rax, %rcx
;;       jb      0x10b
;;   26: xorpd   %xmm0, %xmm0
;;       movdqu  0x10(%rsp), %xmm1
;;       cvtss2sd %xmm1, %xmm0
;;       ucomisd %xmm0, %xmm0
;;       jp      0xf2
;;       jne     0xf2
;;   44: movq    (%rsp), %rdi
;;       callq   0x243
;;       movabsq $13830554455654793216, %rax
;;       movq    %rax, %xmm1
;;       ucomisd %xmm0, %xmm1
;;       jae     0xd9
;;   66: ucomisd 0xc2(%rip), %xmm0
;;       jae     0xc0
;;   74: movdqu  0x10(%rsp), %xmm2
;;       movl    $0x4f000000, %ecx
;;       movd    %ecx, %xmm1
;;       ucomiss %xmm1, %xmm2
;;       jae     0xa1
;;       jp      0x121
;;   92: cvttss2si %xmm2, %eax
;;       cmpl    $0, %eax
;;       jge     0xba
;;   9f: ud2
;;       movaps  %xmm2, %xmm0
;;       subss   %xmm1, %xmm0
;;       cvttss2si %xmm0, %eax
;;       cmpl    $0, %eax
;;       jl      0x123
;;   b5: addl    $0x80000000, %eax
;;       addq    $0x20, %rsp
;;       popq    %rbp
;;       retq
;;   c0: movl    $6, %esi
;;   c5: movq    (%rsp), %rdi
;;   c9: callq   0x26d
;;   ce: movq    (%rsp), %rdi
;;   d2: callq   0x29b
;;   d7: ud2
;;   d9: movl    $6, %esi
;;   de: movq    (%rsp), %rdi
;;   e2: callq   0x26d
;;   e7: movq    (%rsp), %rdi
;;   eb: callq   0x29b
;;   f0: ud2
;;   f2: movl    $8, %esi
;;   f7: movq    (%rsp), %rdi
;;   fb: callq   0x26d
;;  100: movq    (%rsp), %rdi
;;  104: callq   0x29b
;;  109: ud2
;;  10b: xorl    %esi, %esi
;;  10d: movq    (%rsp), %rdi
;;  111: callq   0x26d
;;  116: movq    (%rsp), %rdi
;;  11a: callq   0x29b
;;  11f: ud2
;;  121: ud2
;;  123: ud2
;;  125: addb    %al, (%rax)
;;  127: addb    %al, (%rax)
;;  129: addb    %al, (%rax)
;;  12b: addb    %al, (%rax)
;;  12d: addb    %al, (%rax)
;;  12f: addb    %al, (%rax)
;;  131: addb    %al, (%rax)
;;  133: addb    %al, (%rax)
;;  135: addb    %dh, %al
;;  137: addb    %al, (%r8)
;;  13a: addb    %al, (%rax)
;;  13c: addb    %al, (%rax)
;;  13e: addb    %al, (%rax)
