;;! target = "x86_64-unknown-linux-gnu"
;;! test = "compile"
;;! flags = "-Osignals-based-traps=n"
;;! objdump = "--funcs all --filter wasm-call-component-resource-new"

(component
  (type $r (resource (rep i32)))

  (core module $m (import "" "" (func (param i32) (result i32))))

  (core func $f (canon resource.new $r))
  (core instance $i (instantiate $m (with "" (instance (export "" (func $f))))))
)
;; component-trampolines[0]-wasm-call-component-resource-new[0]:
;;       pushq   %rbp
;;       movq    %rsp, %rbp
;;       subq    $0x10, %rsp
;;       movq    %rdx, %r8
;;       movq    %rbp, %rcx
;;       movq    8(%rsi), %rax
;;       movq    %rsi, (%rsp)
;;       movq    %rcx, 0x30(%rax)
;;       movq    %rbp, %rcx
;;       movq    8(%rcx), %rcx
;;       movq    %rcx, 0x38(%rax)
;;       movl    0x20(%rdi), %eax
;;       testl   %eax, %eax
;;       je      0x11b
;;   e4: movq    8(%rdi), %rax
;;       movq    (%rax), %rax
;;       xorl    %ecx, %ecx
;;       movl    %ecx, %esi
;;       movl    %ecx, %edx
;;       movq    %r8, %rcx
;;       movl    %ecx, %ecx
;;       callq   *%rax
;;       cmpq    $-1, %rax
;;       je      0x108
;;  102: addq    $0x10, %rsp
;;       popq    %rbp
;;       retq
;;  108: movq    (%rsp), %rdi
;;  10c: movq    0x10(%rdi), %rax
;;  110: movq    0x148(%rax), %rax
;;  117: callq   *%rax
;;  119: ud2
;;  11b: movl    $0x17, %esi
;;  120: movq    (%rsp), %rdi
;;  124: callq   0x5c
;;  129: movq    (%rsp), %rdi
;;  12d: callq   0x8a
;;  132: ud2
