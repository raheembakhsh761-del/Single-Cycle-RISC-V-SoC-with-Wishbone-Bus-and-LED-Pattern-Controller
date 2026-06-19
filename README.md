# RISC-V SoC with Wishbone Bus — Updated Project Guide

This project contains a single-cycle RV32I RISC-V CPU connected to a simple Wishbone-style shared bus.

## 1. Folder structure

```text
riscv_soc_project_updated/
├── README.md
├── rtl_compile_order.f
├── sim_compile_order.f
├── rtl/
│   ├── riscv_soc.v              # SoC top
│   ├── riscv_core.v             # CPU core
│   ├── program_counter.v
│   ├── PCplus4.v
│   ├── Control_Unit.v
│   ├── Register_File.v
│   ├── immediate_generator.v
│   ├── ALU_Control.v
│   ├── ALU_unit.v
│   ├── Adder.v
│   ├── Mux1.v
│   ├── Mux2.v
│   ├── Mux3.v
│   ├── AND_logic.v
│   ├── instruction_memory.v
│   ├── wb_master_lsu.v
│   ├── wb_addr_decoder.v
│   ├── wb_read_mux.v
│   ├── wb_prog_mem_slave.v
│   ├── wb_data_mem_slave.v
│   └── wb_led_slave.v
├── sim/
│   └── riscv_soc_tb.v           # self-checking simulation testbench
├── sw/
│   ├── test_program.c           # C test program
│   ├── crt0.s                   # startup assembly
│   ├── link.ld                  # linker script
│   ├── elf2hex.py               # binary-to-Verilog-hex converter
│   └── program.hex              # current program loaded by instruction memory
└── build/                       # output folder
```

## 2. Address map

| Slave | Address range | Purpose |
|---|---:|---|
| Slave 0 | `0x0000_0000` to `0x0000_0FFF` | Program memory |
| Slave 1 | `0x0000_1000` to `0x0000_1FFF` | Data memory |
| Slave 2 | `0x0000_2000` to `0x0000_2FFF` | LED MMIO |

## 3. Install tools

On Ubuntu or WSL:

```bash
sudo apt update
sudo apt install iverilog gtkwave gcc-riscv64-unknown-elf binutils-riscv64-unknown-elf
```

## 4. Run the built-in Verilog testbench

This testbench directly loads instructions into instruction memory and checks registers and LED output.

```bash
cd riscv_soc_project_updated
iverilog -g2012 -o build/sim.out -f sim_compile_order.f
vvp build/sim.out
gtkwave riscv_soc.vcd
```

Expected result should show pass messages like:

```text
Results: 11 PASSED | 0 FAILED
ALL TESTS PASSED
```

## 5. Compile the C program using GCC

Run these commands from the main project folder:

```bash
cd riscv_soc_project_updated
riscv64-unknown-elf-gcc \
  -march=rv32i -mabi=ilp32 \
  -nostdlib -nostartfiles \
  -T sw/link.ld \
  -o build/test_program.elf \
  sw/crt0.s sw/test_program.c
```

Disassemble to check generated instructions:

```bash
riscv64-unknown-elf-objdump -d build/test_program.elf > build/test_program.dump
cat build/test_program.dump
```

## 6. Convert ELF to program.hex

Do not directly use `objcopy -O verilog` for this memory, because this RTL expects one 32-bit instruction word per line.
Use binary first, then convert to 32-bit little-endian words:

```bash
riscv64-unknown-elf-objcopy -O binary build/test_program.elf build/test_program.bin
python3 sw/elf2hex.py build/test_program.bin sw/program.hex
```

Copy `program.hex` to the simulation working folder because the RTL uses `$readmemh("program.hex", ...)`:

```bash
cp sw/program.hex ./program.hex
```

## 7. Simulate with the GCC-generated program.hex

The included self-checking testbench overwrites memory for its own tests. For GCC program simulation, use a simple top testbench or modify `riscv_soc_tb.v` so it does not overwrite `DUT.IMEM.I_Mem`.

A quick option is to make a simple testbench named `sim/riscv_soc_c_tb.v`:

```verilog
`timescale 1ns/1ps
module riscv_soc_c_tb;
    reg clk = 0;
    reg reset = 1;
    wire [7:0] led_out;

    always #5 clk = ~clk;

    riscv_soc DUT (
        .clk(clk),
        .reset(reset),
        .led_out(led_out)
    );

    initial begin
        $dumpfile("riscv_soc_c.vcd");
        $dumpvars(0, riscv_soc_c_tb);
        #20 reset = 0;
        #20000;
        $display("Final LED = 0x%02h", led_out);
        $finish;
    end
endmodule
```

Compile and run:

```bash
iverilog -g2012 -o build/c_sim.out sim/riscv_soc_c_tb.v -f rtl_compile_order.f
vvp build/c_sim.out
gtkwave riscv_soc_c.vcd
```

Expected final LED from `test_program.c` is:

```text
Final LED = 0x55
```

## 8. Important note about current RTL

Your current `riscv_soc.v` uses two program memories:

1. `instruction_memory IMEM` for direct instruction fetch.
2. `wb_prog_mem_slave S0_PROG` as Wishbone Slave 0.

Both load `program.hex`, but the CPU fetches instructions from `instruction_memory IMEM`. So for running C code, make sure `program.hex` is visible to `instruction_memory.v` at simulation time.

