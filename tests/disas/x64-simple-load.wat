;;! target = "x86_64"
;;! test = "compile"
;;! objdump = '--traps --addrmap'

(module
  (memory 1)

  (func $load8 (param i32) (result i32 i32)
    (i32.load8_u (local.get 0))
    (i32.load8_u offset=4 (local.get 0))
  )
)
;; wasm[0]::function[0]::load8:
;;       pushq   %rbp
;;       movq    %rsp, %rbp
;;       movl    %edx, %esi
;;       ╰─╼ addrmap: 0x21
;;       movq    0x38(%rdi), %rdi
;;       movzbq  (%rdi, %rsi), %rax
;;       ╰─╼ trap: Normal(MemoryOutOfBounds)
;;       movzbq  4(%rdi, %rsi), %rcx
;;       ├─╼ addrmap: 0x26
;;       ╰─╼ trap: Normal(MemoryOutOfBounds)
;;       popq    %rbp
;;       ╰─╼ addrmap: 0x29
;;       retq
