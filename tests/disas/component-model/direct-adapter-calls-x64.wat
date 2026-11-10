;;! target = "x86_64"
;;! test = 'compile'
;;! filter = "function"
;;! flags = "-C inlining=n -Wconcurrency-support=n"

;; Same as `direct-adapter-calls.wat` but shows full compilation down to x86_64
;; so that we can exercise our linker's ability to resolve relocations for
;; direct calls across Wasm modules.

(component
  (component $A
    (core module $M
      (func (export "f'") (param i32) (result i32)
        (i32.add (local.get 0) (i32.const 42))
      )
    )

    (core instance $m (instantiate $M))

    (func (export "f") (param "x" u32) (result u32)
      (canon lift (core func $m "f'"))
    )
  )

  (component $B
    (import "f" (func $f (param "x" u32) (result u32)))

    (core func $f' (canon lower (func $f)))

    (core module $N
      (import "" "f'" (func $f' (param i32) (result i32)))
      (func (export "g'") (result i32)
        (call $f' (i32.const 1234))
      )
    )

    (core instance $n
      (instantiate $N
        (with "" (instance (export "f'" (func $f'))))
      )
    )

    (func (export "g") (result u32)
      (canon lift (core func $n "g'"))
    )
  )

  (instance $a (instantiate $A))
  (instance $b
    (instantiate $B
      (with "f" (func $a "f"))
    )
  )

  (export "g" (func $b "g"))
)

;; wasm[0]::function[0]:
;;       pushq   %rbp
;;       movq    %rsp, %rbp
;;       leal    0x2a(%rdx), %eax
;;       popq    %rbp
;;       retq
;;
;; wasm[1]::function[1]:
;;       pushq   %rbp
;;       movq    %rsp, %rbp
;;       movq    8(%rdi), %r10
;;       movq    0x18(%r10), %r10
;;       addq    $0x10, %r10
;;       cmpq    %rsp, %r10
;;       ja      0x4c
;;   39: movq    %rdi, %rsi
;;       movq    0x48(%rdi), %rdi
;;       movl    $0x4d2, %edx
;;       callq   0x60
;;       popq    %rbp
;;       retq
;;   4c: ud2
;;
;; wasm[2]::function[2]:
;;       pushq   %rbp
;;       movq    %rsp, %rbp
;;       movq    8(%rdi), %r10
;;       movq    0x18(%r10), %r10
;;       addq    $0x30, %r10
;;       cmpq    %rsp, %r10
;;       ja      0xfd
;;   79: subq    $0x20, %rsp
;;       movq    %rdi, (%rsp)
;;       movq    (%rsp), %rdi
;;       movq    0x88(%rdi), %rcx
;;       movl    (%rcx), %esi
;;       movq    %rcx, 0x10(%rsp)
;;       testl   %esi, %esi
;;       movq    %rsi, 8(%rsp)
;;       jne     0xbc
;;   a0: movq    (%rsp), %rdi
;;       movq    0x58(%rdi), %rax
;;       movq    0x68(%rdi), %rdi
;;       movl    $0x17, %edx
;;       movq    (%rsp), %rsi
;;       callq   *%rax
;;       ├─╼ exception frame offset: SP = FP - 0x20
;;       ╰─╼ exception handler: default handler, context at [SP+0x0], handler=0xe8
;;       jmp     0xe6
;;   bc: movq    (%rsp), %rsi
;;       movq    0x70(%rsi), %rax
;;       movl    (%rax), %eax
;;       movq    0x48(%rsi), %rdi
;;       callq   0
;;       ├─╼ exception frame offset: SP = FP - 0x20
;;       ╰─╼ exception handler: default handler, context at [SP+0x0], handler=0xe8
;;       movq    0x10(%rsp), %rcx
;;       movq    8(%rsp), %rsi
;;       movl    %esi, (%rcx)
;;       addq    $0x20, %rsp
;;       popq    %rbp
;;       retq
;;   e1: jmp     0xe8
;;   e6: ud2
;;   e8: movq    (%rsp), %rsi
;;   ec: movq    0x58(%rsi), %rax
;;   f0: movq    0x68(%rsi), %rdi
;;   f4: movl    $0x31, %edx
;;   f9: callq   *%rax
;;   fb: ud2
;;   fd: ud2
