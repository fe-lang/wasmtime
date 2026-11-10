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
;;       movq    %rdi, (%rsp)
;;       movq    %rsp, %rcx
;;       movq    0x18(%rax), %rax
;;       cmpq    %rax, %rcx
;;       jb      0x116
;;   20: ucomisd %xmm0, %xmm0
;;       movdqu  %xmm0, 0x10(%rsp)
;;       jp      0xfd
;;       jne     0xfd
;;   36: movq    (%rsp), %rdi
;;       movdqu  0x10(%rsp), %xmm0
;;       callq   0x245
;;       movabsq $13830554455654793216, %rax
;;       movq    %rax, %xmm1
;;       ucomisd %xmm0, %xmm1
;;       jae     0xe4
;;   5e: ucomisd 0xca(%rip), %xmm0
;;       jae     0xcb
;;   6c: movdqu  0x10(%rsp), %xmm2
;;       movabsq $0x43e0000000000000, %rcx
;;       movq    %rcx, %xmm1
;;       ucomisd %xmm1, %xmm2
;;       jae     0xa2
;;       jp      0x12c
;;   91: cvttsd2si %xmm2, %rax
;;       cmpq    $0, %rax
;;       jge     0xc5
;;   a0: ud2
;;       movaps  %xmm2, %xmm0
;;       subsd   %xmm1, %xmm0
;;       cvttsd2si %xmm0, %rax
;;       cmpq    $0, %rax
;;       jl      0x12e
;;   b8: movabsq $9223372036854775808, %rcx
;;       addq    %rcx, %rax
;;       addq    $0x20, %rsp
;;       popq    %rbp
;;       retq
;;   cb: movl    $6, %esi
;;   d0: movq    (%rsp), %rdi
;;   d4: callq   0x26f
;;   d9: movq    (%rsp), %rdi
;;   dd: callq   0x29d
;;   e2: ud2
;;   e4: movl    $6, %esi
;;   e9: movq    (%rsp), %rdi
;;   ed: callq   0x26f
;;   f2: movq    (%rsp), %rdi
;;   f6: callq   0x29d
;;   fb: ud2
;;   fd: movl    $8, %esi
;;  102: movq    (%rsp), %rdi
;;  106: callq   0x26f
;;  10b: movq    (%rsp), %rdi
;;  10f: callq   0x29d
;;  114: ud2
;;  116: xorl    %esi, %esi
;;  118: movq    (%rsp), %rdi
;;  11c: callq   0x26f
;;  121: movq    (%rsp), %rdi
;;  125: callq   0x29d
;;  12a: ud2
;;  12c: ud2
;;  12e: ud2
;;  130: addb    %al, (%rax)
;;  132: addb    %al, (%rax)
;;  134: addb    %al, (%rax)
;;  136: lock addb %al, (%r8)
;;  13a: addb    %al, (%rax)
;;  13c: addb    %al, (%rax)
;;  13e: addb    %al, (%rax)
