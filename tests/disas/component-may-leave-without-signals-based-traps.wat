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
;;       movq    %rdx, %r9
;;       movq    %rbp, %rcx
;;       movq    8(%rsi), %rax
;;       movq    %rsi, (%rsp)
;;       movq    %rcx, 0x30(%rax)
;;       movq    %rbp, %rcx
;;       movq    8(%rcx), %rcx
;;       movq    %rcx, 0x38(%rax)
;;       movl    0x20(%rdi), %eax
;;       testl   %eax, %eax
;;       je      0x11c
;;   e4: movq    8(%rdi), %rcx
;;       xorl    %eax, %eax
;;       movq    (%rcx), %r8
;;       movl    %eax, %esi
;;       movl    %eax, %edx
;;       movq    %r9, %rax
;;       movl    %eax, %ecx
;;       callq   *%r8
;;       cmpq    $-1, %rax
;;       je      0x109
;;  103: addq    $0x10, %rsp
;;       popq    %rbp
;;       retq
;;  109: movq    (%rsp), %rdi
;;  10d: movq    0x10(%rdi), %rax
;;  111: movq    0x148(%rax), %rax
;;  118: callq   *%rax
;;  11a: ud2
;;  11c: movl    $0x17, %esi
;;  121: movq    (%rsp), %rdi
;;  125: callq   0x5c
;;  12a: movq    (%rsp), %rdi
;;  12e: callq   0x8a
;;  133: ud2
