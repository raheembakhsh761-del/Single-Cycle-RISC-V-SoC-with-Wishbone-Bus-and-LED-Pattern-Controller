/* =============================================================================
   link.ld — Linker script for RISC-V single-cycle SoC
   IMEM: 0x00000000, 4 KB
   DMEM: 0x00001000, 4 KB address window
   LED : 0x00002000 MMIO
   ============================================================================= */
ENTRY(_start)

MEMORY
{
    IMEM (rx)  : ORIGIN = 0x00000000, LENGTH = 4K
    DMEM (rwx) : ORIGIN = 0x00001000, LENGTH = 4K
}

SECTIONS
{
    .text :
    {
        KEEP(*(.text.startup))
        *(.text*)
        *(.rodata*)
    } > IMEM

    .data :
    {
        *(.sdata*)
        *(.data*)
    } > DMEM AT > IMEM

    .bss :
    {
        __bss_start = .;
        *(.sbss*)
        *(.bss*)
        *(COMMON)
        __bss_end = .;
    } > DMEM

    . = ALIGN(4);
    _end = .;
}
