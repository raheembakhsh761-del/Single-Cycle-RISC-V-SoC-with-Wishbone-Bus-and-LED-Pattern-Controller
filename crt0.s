# =============================================================================
# crt0.s — Minimal startup for RISC-V bare-metal SoC
# Sets up stack pointer, clears BSS, then calls main()
# =============================================================================
.section .text.startup
.global _start

_start:
    # Set stack pointer to top of data memory address range
    lui  sp, 0x00002          # sp = 0x0000_2000
    addi sp, sp, -16          # align stack

    # Zero out BSS
    la   t0, __bss_start
    la   t1, __bss_end
bss_loop:
    beq  t0, t1, bss_done
    sw   zero, 0(t0)
    addi t0, t0, 4
    j    bss_loop
bss_done:

    call main

halt:
    j halt
