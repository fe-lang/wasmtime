;;! target = "x86_64-unknown-linux-gnu"
;;! test = "compile"
;;! flags = "-Ccompiler=cranelift -Ccranelift-has_sse41=false  -Osignals-based-traps=n"

(module
  (func (export "i64.trunc_f64_u") (param f64) (result i64)
    (i64.trunc_f64_u (local.get 0))
  )
)
;; wasm[0]::function[0]:
;;       pushq   %rbp
;;       movq    %rsp, %rbp
;;       subq    $0x20, %rsp
;;       movq    8(%rdi), %rax
;;       movq    %rdi, -8(%rbp)
;;       movq    %rsp, %rcx
;;       movq    0x18(%rax), %rax
;;       cmpq    %rax, %rcx
;;       jb      0x113
;;   20: ucomisd %xmm0, %xmm0
;;       movdqu  %xmm0, (%rsp)
;;       jp      0xfa
;;       jne     0xfa
;;   35: movq    -8(%rbp), %rdi
;;       movdqu  (%rsp), %xmm0
;;       callq   0x234
;;       movabsq $13830554455654793216, %rax
;;       movq    %rax, %xmm1
;;       ucomisd %xmm0, %xmm1
;;       jae     0xe1
;;   5c: ucomisd 0xcc(%rip), %xmm0
;;       jae     0xc8
;;   6a: movdqu  (%rsp), %xmm2
;;       movabsq $0x43e0000000000000, %rcx
;;       movq    %rcx, %xmm1
;;       ucomisd %xmm1, %xmm2
;;       jae     0x9f
;;       jp      0x129
;;   8e: cvttsd2si %xmm2, %rax
;;       cmpq    $0, %rax
;;       jge     0xc2
;;   9d: ud2
;;       movaps  %xmm2, %xmm0
;;       subsd   %xmm1, %xmm0
;;       cvttsd2si %xmm0, %rax
;;       cmpq    $0, %rax
;;       jl      0x12b
;;   b5: movabsq $9223372036854775808, %rcx
;;       addq    %rcx, %rax
;;       addq    $0x20, %rsp
;;       popq    %rbp
;;       retq
;;   c8: movl    $6, %esi
;;   cd: movq    -8(%rbp), %rdi
;;   d1: callq   0x25e
;;   d6: movq    -8(%rbp), %rdi
;;   da: callq   0x28c
;;   df: ud2
;;   e1: movl    $6, %esi
;;   e6: movq    -8(%rbp), %rdi
;;   ea: callq   0x25e
;;   ef: movq    -8(%rbp), %rdi
;;   f3: callq   0x28c
;;   f8: ud2
;;   fa: movl    $8, %esi
;;   ff: movq    -8(%rbp), %rdi
;;  103: callq   0x25e
;;  108: movq    -8(%rbp), %rdi
;;  10c: callq   0x28c
;;  111: ud2
;;  113: xorl    %esi, %esi
;;  115: movq    -8(%rbp), %rdi
;;  119: callq   0x25e
;;  11e: movq    -8(%rbp), %rdi
;;  122: callq   0x28c
;;  127: ud2
;;  129: ud2
;;  12b: ud2
;;  12d: addb    %al, (%rax)
;;  12f: addb    %al, (%rax)
;;  131: addb    %al, (%rax)
;;  133: addb    %al, (%rax)
;;  135: addb    %dh, %al
;;  137: addb    %al, (%r8)
;;  13a: addb    %al, (%rax)
;;  13c: addb    %al, (%rax)
;;  13e: addb    %al, (%rax)
