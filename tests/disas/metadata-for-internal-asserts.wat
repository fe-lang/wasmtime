;;! target = "x86_64"
;;! test = 'compile'
;;! flags = '-Ccranelift-wasmtime_debug_checks=on -Cmetadata-for-internal-asserts'
;;! objdump = '--funcs all'

(module (func))

;; wasm[0]::function[0]:
;;       pushq   %rbp
;;       movq    %rsp, %rbp
;;       popq    %rbp
;;       retq
;;
;; signatures[0]::wasm_to_array_trampoline:
;;       pushq   %rbp
;;       movq    %rsp, %rbp
;;       movl    (%rsi), %eax
;;       cmpl    $0x65726f63, %eax
;;       jne     0x59
;;   17: movq    %rbp, %rcx
;;       movq    8(%rsi), %rax
;;       movq    %rsi, %rbx
;;       movq    %rcx, 0x30(%rax)
;;       movq    %rbp, %rcx
;;       movq    8(%rcx), %rcx
;;       movq    %rcx, 0x38(%rax)
;;       leaq    (%rsp), %rdx
;;       xorq    %rcx, %rcx
;;       movq    8(%rdi), %rax
;;       callq   *%rax
;;       testb   %al, %al
;;       je      0x47
;;   45: popq    %rbp
;;       retq
;;   47: movq    %rbx, %rdi
;;   4a: movq    0x10(%rdi), %rax
;;   4e: movq    0x148(%rax), %rax
;;   55: callq   *%rax
;;   57: ud2
;;       ╰─╼ trap: InternalAssert
;;   59: ud2
;;       ╰─╼ trap: InternalAssert
