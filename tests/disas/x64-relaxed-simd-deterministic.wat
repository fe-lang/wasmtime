;;! target = "x86_64"
;;! test = "compile"
;;! flags = "-Ccranelift-sse42 -Ccranelift-has-avx -Wrelaxed-simd-deterministic"

(module
  (func (param v128) (result v128)
    local.get 0
    i32x4.relaxed_trunc_f32x4_s
  )

  (func (param v128) (result v128)
    local.get 0
    i32x4.relaxed_trunc_f32x4_u
  )

  (func (param v128) (result v128)
    local.get 0
    i32x4.relaxed_trunc_f64x2_s_zero
  )

  (func (param v128) (result v128)
    local.get 0
    i32x4.relaxed_trunc_f64x2_u_zero
  )

  (func (param v128 v128) (result v128)
    local.get 0
    local.get 1
    i16x8.relaxed_dot_i8x16_i7x16_s
  )

  (func (param v128 v128 v128) (result v128)
    local.get 0
    local.get 1
    local.get 2
    i32x4.relaxed_dot_i8x16_i7x16_add_s
  )
)

;; wasm[0]::function[0]:
;;       pushq   %rbp
;;       movq    %rsp, %rbp
;;       vcmpeqps %xmm0, %xmm0, %xmm3
;;       vandps  %xmm3, %xmm0, %xmm5
;;       vpxor   %xmm5, %xmm3, %xmm7
;;       vcvttps2dq %xmm5, %xmm0
;;       vpand   %xmm7, %xmm0, %xmm1
;;       vpsrad  $0x1f, %xmm1, %xmm1
;;       vpxor   %xmm0, %xmm1, %xmm0
;;       popq    %rbp
;;       retq
;;
;; wasm[0]::function[1]:
;;       pushq   %rbp
;;       movq    %rsp, %rbp
;;       vxorps  %xmm3, %xmm3, %xmm5
;;       vmaxps  %xmm5, %xmm0, %xmm7
;;       vpcmpeqd %xmm5, %xmm5, %xmm0
;;       vpsrld  $1, %xmm0, %xmm0
;;       vcvtdq2ps %xmm0, %xmm1
;;       vcvttps2dq %xmm7, %xmm0
;;       vsubps  %xmm1, %xmm7, %xmm2
;;       vcmpleps %xmm2, %xmm1, %xmm1
;;       vcvttps2dq %xmm2, %xmm2
;;       vpxor   %xmm1, %xmm2, %xmm1
;;       vpxor   %xmm2, %xmm2, %xmm2
;;       vpmaxsd %xmm2, %xmm1, %xmm1
;;       vpaddd  %xmm0, %xmm1, %xmm0
;;       popq    %rbp
;;       retq
;;
;; wasm[0]::function[2]:
;;       pushq   %rbp
;;       movq    %rsp, %rbp
;;       vcmpeqpd %xmm0, %xmm0, %xmm3
;;       vandps  0xf(%rip), %xmm3, %xmm5
;;       vminpd  %xmm5, %xmm0, %xmm7
;;       vcvttpd2dq %xmm7, %xmm0
;;       popq    %rbp
;;       retq
;;   9b: addb    %al, (%rax)
;;   9d: addb    %al, (%rax)
;;   9f: addb    %al, (%rax)
;;   a1: addb    %al, %al
;;
;; wasm[0]::function[3]:
;;       pushq   %rbp
;;       movq    %rsp, %rbp
;;       vxorpd  %xmm3, %xmm3, %xmm5
;;       vmaxpd  %xmm5, %xmm0, %xmm7
;;       vminpd  0x1c(%rip), %xmm7, %xmm0
;;       vroundpd $3, %xmm0, %xmm0
;;       vaddpd  0x1e(%rip), %xmm0, %xmm0
;;       vshufps $0x88, %xmm5, %xmm0, %xmm0
;;       popq    %rbp
;;       retq
;;   e9: addb    %al, (%rax)
;;   eb: addb    %al, (%rax)
;;   ed: addb    %al, (%rax)
;;   ef: addb    %al, (%rax)
;;   f1: addb    %ah, %al
;;
;; wasm[0]::function[4]:
;;       pushq   %rbp
;;       movq    %rsp, %rbp
;;       vpmovsxbw %xmm0, %xmm2
;;       vpmovsxbw %xmm1, %xmm3
;;       vpmullw %xmm3, %xmm2, %xmm2
;;       vpalignr $8, %xmm0, %xmm0, %xmm0
;;       vpmovsxbw %xmm0, %xmm0
;;       vpalignr $8, %xmm1, %xmm1, %xmm1
;;       vpmovsxbw %xmm1, %xmm1
;;       vpmullw %xmm1, %xmm0, %xmm0
;;       vphaddw %xmm0, %xmm2, %xmm0
;;       popq    %rbp
;;       retq
;;
;; wasm[0]::function[5]:
;;       pushq   %rbp
;;       movq    %rsp, %rbp
;;       vpmovsxbw %xmm0, %xmm3
;;       vpmovsxbw %xmm1, %xmm4
;;       vpmullw %xmm4, %xmm3, %xmm3
;;       vpmaddwd 0x36(%rip), %xmm3, %xmm3
;;       vpalignr $8, %xmm0, %xmm0, %xmm0
;;       vpmovsxbw %xmm0, %xmm0
;;       vpalignr $8, %xmm1, %xmm1, %xmm1
;;       vpmovsxbw %xmm1, %xmm1
;;       vpmullw %xmm1, %xmm0, %xmm0
;;       vpmaddwd 0x24(%rip), %xmm0, %xmm0
;;       vphaddd %xmm0, %xmm3, %xmm0
;;       vpaddd  %xmm2, %xmm0, %xmm0
;;       popq    %rbp
;;       retq
;;  1a7: addb    %al, (%rax)
;;  1a9: addb    %al, (%rax)
;;  1ab: addb    %al, (%rax)
;;  1ad: addb    %al, (%rax)
;;  1af: addb    %al, (%rcx)
;;  1b1: addb    %al, (%rcx)
;;  1b3: addb    %al, (%rcx)
;;  1b5: addb    %al, (%rcx)
;;  1b7: addb    %al, (%rcx)
;;  1b9: addb    %al, (%rcx)
;;  1bb: addb    %al, (%rcx)
;;  1bd: addb    %al, (%rcx)
;;  1bf: addb    %al, (%rcx)
;;  1c1: addb    %al, (%rcx)
;;  1c3: addb    %al, (%rcx)
;;  1c5: addb    %al, (%rcx)
;;  1c7: addb    %al, (%rcx)
;;  1c9: addb    %al, (%rcx)
;;  1cb: addb    %al, (%rcx)
;;  1cd: addb    %al, (%rcx)
