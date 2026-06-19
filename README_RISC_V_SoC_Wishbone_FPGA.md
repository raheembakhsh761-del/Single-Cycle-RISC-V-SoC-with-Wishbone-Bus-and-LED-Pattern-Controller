# Design and FPGA Implementation of a Single-Cycle RISC-V SoC with Wishbone Bus and LED Pattern Controller

![RISC-V](https://img.shields.io/badge/RISC--V-RV32I-blue)
![HDL](https://img.shields.io/badge/HDL-Verilog-orange)
![Bus](https://img.shields.io/badge/Bus-Wishbone-green)
![FPGA](https://img.shields.io/badge/FPGA-Lattice%20ECP5-purple)
![Tools](https://img.shields.io/badge/Tools-Yosys%20%7C%20nextpnr%20%7C%20ecppack-lightgrey)

## Project Overview

This repository contains the complete design, simulation, software flow, and FPGA implementation of a **Single-Cycle RISC-V System-on-Chip (SoC)** with a **Wishbone bus interconnect** and a **memory-mapped LED pattern controller**.

The project was completed as part of the **EE-474 Computer Architecture Final Project** at **Namal University, Mianwali**. The main objective was to design a working RISC-V based SoC from RTL level, verify it through simulation, compile a C program using the RISC-V GCC toolchain, generate a machine-code HEX file, and deploy the final design on a **Colorlight i5 Lattice ECP5 FPGA board**.

The project demonstrates the complete flow from:

```text
C Program → RISC-V GCC → ELF → Binary → HEX → Instruction Memory → RISC-V SoC → Wishbone Bus → LED Peripheral → FPGA LEDs
```

---

## Key Features

- Custom **RV32I single-cycle RISC-V processor** designed in Verilog HDL
- Complete datapath and control implementation
- Wishbone-based SoC integration
- One RISC-V core acting as a **Wishbone master**
- Three memory-mapped Wishbone slaves:
  - Program memory / instruction memory
  - Data memory
  - LED controller peripheral
- GCC-compatible embedded C software flow
- ELF-to-binary and binary-to-HEX conversion
- Icarus Verilog simulation support
- GTKWave waveform verification
- FPGA synthesis using Yosys
- Place-and-route using nextpnr-ecp5
- Bitstream generation using ecppack
- FPGA programming using openFPGALoader
- Hardware validation using LED pattern output on Colorlight i5 ECP5 FPGA

---

## System Architecture

The SoC is built around a custom single-cycle RV32I processor. The processor generates addresses, write data, byte-select signals, and control signals through a Wishbone master interface. The Wishbone address decoder selects the correct slave according to the memory address range.

### Top-Level Architecture

```text
+---------------------------------------------------------------+
|                         RISC-V SoC                            |
|                                                               |
|  +-------------------+        +----------------------------+   |
|  | Single-Cycle      |        | Wishbone Interconnect      |   |
|  | RV32I Processor   | <----> | Address Decoder + MUX      |   |
|  | Wishbone Master   |        +-------------+--------------+   |
|  +-------------------+                      |                  |
|                                             |                  |
|           +---------------------------------+----------------+ |
|           |                                 |                | |
|  +--------v---------+              +--------v--------+       | |
|  | Program Memory   |              | Data Memory     |       | |
|  | Wishbone Slave   |              | Wishbone Slave  |       | |
|  | S0               |              | S1              |       | |
|  +------------------+              +-----------------+       | |
|                                                               | |
|                                      +----------------------+ | |
|                                      | LED Controller       | | |
|                                      | Wishbone Slave S2    | | |
|                                      +----------+-----------+ | |
|                                                 |             | |
+-------------------------------------------------|-------------+
                                                  |
                                                  v
                                           FPGA LED Pins
```

---

## Wishbone Bus Architecture

The design uses a shared Wishbone bus. The RISC-V processor is the only master, while instruction memory, data memory, and LED controller are connected as slave peripherals.

### Wishbone Roles

| Bus Role | Count | Module | Purpose |
|---|---:|---|---|
| Master | 1 | `riscv_core.v` / CPU bus interface | Generates instruction fetch, load/store, and LED MMIO transactions |
| Slave S0 | 1 | `wb_prog_mem_slave.v` | Program memory / instruction memory |
| Slave S1 | 1 | `wb_data_mem_slave.v` | Data RAM for load and store instructions |
| Slave S2 | 1 | `wb_led_slave.v` | Memory-mapped LED controller |

### Main Wishbone Signals

| Signal | Direction | Description |
|---|---|---|
| `wb_cyc` | Master to slave | Indicates that a valid bus cycle is active |
| `wb_stb` | Master to slave | Indicates a valid transfer request |
| `wb_we` | Master to slave | Write enable: `1` for write, `0` for read |
| `wb_adr[31:0]` | Master to slave | 32-bit memory-mapped address |
| `wb_dat_mosi[31:0]` | Master to slave | Write data from CPU to selected slave |
| `wb_dat_miso[31:0]` | Slave to master | Read data returned from selected slave |
| `wb_sel[3:0]` | Master to slave | Byte-lane select |
| `wb_ack` | Slave to master | Acknowledges completion of the transfer |

---

## Memory Map

The SoC uses a flat 32-bit address space. Each slave occupies a separate address region.

| Region | Start Address | End Address | Size | Slave Module | Access |
|---|---:|---:|---:|---|---|
| Instruction Memory | `0x00000000` | `0x00000FFF` | 4 KB | `wb_prog_mem_slave.v` | Read only |
| Data Memory | `0x00001000` | `0x00001FFF` | 4 KB | `wb_data_mem_slave.v` | Read / Write |
| LED Peripheral | `0x00002000` | `0x00002FFF` | 4 KB | `wb_led_slave.v` | Memory-mapped I/O |
| Reserved | `0x00003000` | `0xFFFFFFFF` | Remaining | N/A | Unused |

The LED controller is mapped at:

```c
#define LED_ADDR ((volatile unsigned int *)0x00002000)
```

Writing a value to this address updates the LED output register.

---

## Supported RV32I Instructions

The processor supports the baseline RV32I instruction categories required for this project.

### ALU Instructions

| Type | Instructions |
|---|---|
| R-type | `ADD`, `SUB`, `AND`, `OR`, `XOR`, `SLL`, `SRL`, `SRA`, `SLT`, `SLTU` |
| I-type | `ADDI`, `ANDI`, `ORI`, `XORI`, `SLTI`, `SLTIU`, `SLLI`, `SRLI`, `SRAI` |

### Memory Instructions

| Type | Instructions |
|---|---|
| Load | `LW`, `LH`, `LB`, `LHU`, `LBU` |
| Store | `SW`, `SH`, `SB` |

### Control Flow Instructions

| Type | Instructions |
|---|---|
| Branch | `BEQ`, `BNE`, `BLT`, `BGE`, `BLTU`, `BGEU` |
| Jump | `JAL`, `JALR` |
| Upper Immediate | `LUI`, `AUIPC` |
| NOP | `ADDI x0, x0, 0` |

> `ECALL` and `EBREAK` are not included in this implementation.

---

## Processor Design

The single-cycle RISC-V processor executes one instruction per clock-style datapath operation. The main internal blocks are:

| Module | Purpose |
|---|---|
| Program Counter | Holds the current instruction address and updates to PC+4 or branch/jump target |
| PC + 4 Adder | Generates the next sequential instruction address |
| Instruction Fetch Interface | Fetches instruction from Wishbone program memory |
| Control Unit | Decodes opcode and generates datapath control signals |
| Register File | Contains 32 general-purpose registers `x0` to `x31` |
| Immediate Generator | Generates I, S, B, U, and J type immediate values |
| ALU Control | Selects ALU operation using `funct3`, `funct7`, and `ALUOp` |
| ALU | Performs arithmetic, logic, shift, compare, and address calculation |
| Branch Logic | Selects branch/jump target when required |
| Load/Store Unit | Converts CPU memory access into Wishbone transactions |
| Write-Back Logic | Writes ALU or memory result back to register file |

---

## LED Pattern Controller

The LED peripheral is implemented as a Wishbone slave. It contains a register that stores the LED output value. When the C program writes to address `0x00002000`, the LED slave captures the lower bits of the write data and drives the FPGA LED pins.

### LED Write Flow

```text
C Code: led_write(0x01)
        |
        v
RISC-V CPU executes SW instruction
        |
        v
Wishbone master drives address 0x00002000
        |
        v
Address decoder selects LED slave S2
        |
        v
LED slave captures write data
        |
        v
FPGA LEDs show the pattern
```

### Example LED Pattern Code

```c
#define LED_ADDR ((volatile unsigned int *)0x00002000)
#define DELAY_COUNT 5000000

static void led_write(unsigned int pattern)
{
    *LED_ADDR = pattern;
}

static void delay_1s(void)
{
    volatile unsigned int i;
    for (i = 0; i < DELAY_COUNT; i++) {
    }
}

void main(void)
{
    while (1) {
        led_write(0x01); delay_1s(); led_write(0x00); delay_1s();
        led_write(0x02); delay_1s(); led_write(0x00); delay_1s();
        led_write(0x04); delay_1s(); led_write(0x00); delay_1s();
        led_write(0x08); delay_1s(); led_write(0x00); delay_1s();
        led_write(0x10); delay_1s(); led_write(0x00); delay_1s();
    }
}
```

---

## Project Folder Structure

Recommended repository structure:

```text
riscv_soc_project/
├── README.md
├── rtl/
│   ├── fpga_top.v
│   ├── riscv_soc.v
│   ├── riscv_core.v
│   ├── instruction_memory.v
│   ├── wb_master_lsu.v
│   ├── wb_addr_decoder.v
│   ├── wb_read_mux.v
│   ├── wb_data_mem_slave.v
│   ├── wb_prog_mem_slave.v
│   └── wb_led_slave.v
├── sw/
│   ├── test_program.c
│   ├── crt0.s
│   ├── link.ld
│   └── elf2hex.py
├── sim/
│   └── riscv_soc_tb.v
├── build/
│   └── generated files
├── docs/
│   ├── images/
│   │   ├── hardware_test.jpg
│   │   ├── simulation_pass.png
│   │   ├── gtkwave_led_pattern.png
│   │   ├── yosys_synthesis.png
│   │   ├── nextpnr_utilization.png
│   │   └── openfpgaloader_done.png
│   └── report/
├── colorlight_i5.lpf
├── rtl_compile_order.f
└── program.hex
```

---

## Important Files

| File | Purpose |
|---|---|
| `rtl/riscv_core.v` | Main RV32I processor core |
| `rtl/riscv_soc.v` | Top-level SoC integration |
| `rtl/wb_master_lsu.v` | Wishbone master load/store unit |
| `rtl/wb_addr_decoder.v` | Selects the correct slave using address range |
| `rtl/wb_read_mux.v` | Routes selected slave read data back to CPU |
| `rtl/wb_prog_mem_slave.v` | Program memory / instruction memory |
| `rtl/wb_data_mem_slave.v` | Data memory for load/store operations |
| `rtl/wb_led_slave.v` | LED memory-mapped peripheral |
| `rtl/fpga_top.v` | FPGA top wrapper |
| `sw/test_program.c` | Embedded C test program and LED pattern code |
| `sw/crt0.s` | Startup assembly file |
| `sw/link.ld` | Linker script for IMEM and DMEM placement |
| `sw/elf2hex.py` | Converts binary file into `program.hex` |
| `sim/riscv_soc_tb.v` | Simulation testbench |
| `colorlight_i5.lpf` | FPGA pin constraint file |
| `rtl_compile_order.f` | RTL file list for Icarus Verilog |

---

## Toolchain Requirements

### Software Tools

Install the following tools before running the project:

- RISC-V GCC toolchain  
  Example: `riscv64-unknown-elf-gcc`
- Icarus Verilog
- GTKWave
- Yosys
- nextpnr-ecp5
- Project Trellis / ecppack
- openFPGALoader
- Python 3
- usbipd-win if programming FPGA from WSL on Windows

### Recommended FPGA Tools

For Ubuntu or WSL Ubuntu, OSS CAD Suite is recommended because it includes:

- Yosys
- nextpnr-ecp5
- ecppack
- openFPGALoader
- Icarus Verilog
- GTKWave

---

## Build Flow

### Step 1: Clean and Prepare Build Folder

```bash
cd ~/riscv_soc_project
rm -rf build
rm -f program.hex riscv_soc.vcd
mkdir -p build
```

---

## GCC-Based Software Flow

### Step 2: Compile C Program to ELF

```bash
riscv64-unknown-elf-gcc \
    -Os \
    -march=rv32i \
    -mabi=ilp32 \
    -msmall-data-limit=0 \
    -nostdlib \
    -nostartfiles \
    -ffreestanding \
    -fno-builtin \
    -DFPGA_BUILD \
    -DDELAY_COUNT=5000000 \
    -T sw/link.ld \
    -o build/test_program.elf \
    sw/crt0.s \
    sw/test_program.c
```

### Step 3: Convert ELF to Binary

```bash
riscv64-unknown-elf-objcopy \
    -O binary \
    build/test_program.elf \
    build/test_program.bin
```

### Step 4: Convert Binary to HEX

```bash
python3 sw/elf2hex.py build/test_program.bin program.hex
```

### Step 5: Check HEX File

```bash
head program.hex
wc -l program.hex
```

The generated `program.hex` is loaded into instruction memory during simulation and synthesis.

---

## Simulation Flow

### Step 6: Compile RTL and Testbench

```bash
iverilog -g2012 \
    -o build/sim.out \
    sim/riscv_soc_tb.v \
    -f rtl_compile_order.f
```

### Step 7: Run Simulation

```bash
vvp build/sim.out
```

Expected output:

```text
Final LED = 0x55
[PASS] Final LED should be 0x55
[PASS] DMEM[0] ADD result = 8
[PASS] DMEM[1] SUB result = 2
...
Results: 11 PASSED | 0 FAILED
*** PROGRAM.HEX TEST PASSED ***
```

### Step 8: Open GTKWave

```bash
gtkwave riscv_soc.vcd
```

Important signals to observe:

| Signal | Purpose |
|---|---|
| `pc_debug` | Shows program counter execution |
| `instruction_debug` | Shows fetched instruction |
| `alu_result_debug` | Shows ALU result and address calculation |
| `wb_adr_debug` | Shows Wishbone address |
| `wb_wdata_debug` | Shows Wishbone write data |
| `wb_cyc`, `wb_stb`, `wb_we`, `wb_ack` | Shows Wishbone transaction handshake |
| `sel_s1_debug`, `sel_s2_debug` | Shows selected slave |
| `led_out` | Shows final LED output or LED pattern |

---

## FPGA Implementation Flow

### Step 9: Synthesis with Yosys

```bash
yosys -p "read_verilog rtl/*.v; synth_ecp5 -top fpga_top -json build/soc.json"
```

### Step 10: Place and Route with nextpnr-ecp5

For LFE5U-45 boards:

```bash
nextpnr-ecp5 \
    --45k \
    --package CABGA381 \
    --json build/soc.json \
    --lpf colorlight_i5.lpf \
    --textcfg build/soc.config
```

For LFE5U-25 boards, replace `--45k` with `--25k`.

### Step 11: Generate Bitstream with ecppack

```bash
ecppack build/soc.config build/soc.bit
```

### Step 12: Program FPGA with openFPGALoader

```bash
sudo env "PATH=$PATH" openFPGALoader -c cmsisdap build/soc.bit
```

Expected output should include:

```text
Programming: 100%
Done
```

---

## Complete One-Line Command Flow

Use this after editing `sw/test_program.c`, `rtl/fpga_top.v`, and `colorlight_i5.lpf`.

```bash
cd ~/riscv_soc_project && \
mkdir -p build && \
riscv64-unknown-elf-gcc -Os -march=rv32i -mabi=ilp32 -msmall-data-limit=0 -nostdlib -nostartfiles -ffreestanding -fno-builtin -DFPGA_BUILD -DDELAY_COUNT=5000000 -T sw/link.ld -o build/test_program.elf sw/crt0.s sw/test_program.c && \
riscv64-unknown-elf-objcopy -O binary build/test_program.elf build/test_program.bin && \
python3 sw/elf2hex.py build/test_program.bin program.hex && \
iverilog -g2012 -o build/sim.out sim/riscv_soc_tb.v -f rtl_compile_order.f && \
vvp build/sim.out && \
yosys -p "read_verilog rtl/*.v; synth_ecp5 -top fpga_top -json build/soc.json" && \
nextpnr-ecp5 --45k --package CABGA381 --json build/soc.json --lpf colorlight_i5.lpf --textcfg build/soc.config && \
ecppack build/soc.config build/soc.bit && \
sudo env "PATH=$PATH" openFPGALoader -c cmsisdap build/soc.bit
```

---

## Colorlight i5 FPGA Pin Mapping

The default clock pin used on the Colorlight i5 board is:

```text
Clock: P3, 25 MHz
```

Example LPF mapping for five external LEDs:

```lpf
LOCATE COMP "clk" SITE "P3";
IOBUF PORT "clk" IO_TYPE=LVCMOS33;

LOCATE COMP "led[0]" SITE "R1";
IOBUF PORT "led[0]" IO_TYPE=LVCMOS33;

LOCATE COMP "led[1]" SITE "T1";
IOBUF PORT "led[1]" IO_TYPE=LVCMOS33;

LOCATE COMP "led[2]" SITE "Y2";
IOBUF PORT "led[2]" IO_TYPE=LVCMOS33;

LOCATE COMP "led[3]" SITE "M1";
IOBUF PORT "led[3]" IO_TYPE=LVCMOS33;

LOCATE COMP "led[4]" SITE "N2";
IOBUF PORT "led[4]" IO_TYPE=LVCMOS33;
```

> Important: Pin mapping can change depending on board revision and the selected header pins. Always verify the Colorlight i5 pinout before connecting LEDs.

---

## Connecting Colorlight i5 to WSL Ubuntu

If using Windows + WSL Ubuntu, attach the FPGA programmer to WSL using `usbipd`.

### Windows PowerShell as Administrator

```powershell
usbipd list
usbipd bind --busid <BUSID>
usbipd attach --wsl --busid <BUSID>
```

### WSL Ubuntu

```bash
lsusb
sudo env "PATH=$PATH" openFPGALoader -c cmsisdap --detect
```

The CMSIS-DAP programmer usually appears with VID:PID:

```text
0d28:0204
```

---

## Hardware Setup

For external LED testing:

1. Connect the selected FPGA GPIO pin to a current-limiting resistor.
2. Connect resistor output to LED anode.
3. Connect LED cathode to GND.
4. Confirm GPIO voltage level before connecting.
5. Do not connect 5V directly to FPGA GPIO.
6. Make sure the LPF pin mapping matches the physical header pins.

Example:

```text
FPGA GPIO Pin → 330Ω Resistor → LED Anode
LED Cathode → GND
```

---

## Verification Results

The design was verified in three levels:

### 1. Software Flow Verification

- C program compiled successfully using RISC-V GCC
- ELF file generated
- Binary file generated
- HEX file generated and loaded into instruction memory

### 2. Simulation Verification

- RTL compiled using Icarus Verilog
- Simulation executed using `vvp`
- GTKWave used to inspect:
  - Program counter
  - Instruction output
  - ALU result
  - Data memory result
  - Wishbone address/data/control signals
  - LED output
- Final result showed all checks passed

Example simulation result:

```text
Results: 11 PASSED | 0 FAILED
*** PROGRAM.HEX TEST PASSED ***
```

### 3. FPGA Hardware Verification

- Design synthesized using Yosys
- Design placed and routed using nextpnr-ecp5
- Bitstream generated using ecppack
- FPGA programmed using openFPGALoader
- LED pattern observed on hardware

---

## Add Project Images to README

Create this folder in your GitHub repository:

```text
docs/images/
```

Recommended images:

| Image File | Description |
|---|---|
| `hardware_test.jpg` | Colorlight i5 FPGA board with LEDs running |
| `simulation_pass.png` | Terminal screenshot showing 11 PASSED / 0 FAILED |
| `gtkwave_led_pattern.png` | GTKWave waveform showing LED pattern |
| `nextpnr_utilization.png` | nextpnr resource utilization screenshot |
| `openfpgaloader_done.png` | FPGA programming completed screenshot |

Example image links:

```markdown
## Hardware Demonstration

![Hardware Test](docs/images/hardware_test.jpg)

## Simulation Result

![Simulation PASS](docs/images/simulation_pass.png)

## GTKWave LED Pattern

![GTKWave LED Pattern](docs/images/gtkwave_led_pattern.png)
```

---

## Troubleshooting

| Problem | Possible Cause | Solution |
|---|---|---|
| `lsusb` does not show device in WSL | USB device not attached to WSL | Use `usbipd list`, `bind`, and `attach` |
| `openFPGALoader: No device found` | Wrong cable option or device not detected | Use `-c cmsisdap` and confirm `lsusb` |
| `sudo: openFPGALoader command not found` | `sudo` does not inherit PATH | Use `sudo env "PATH=$PATH" openFPGALoader ...` |
| IDCODE mismatch | Wrong ECP5 device size selected | Use `--45k` for LFE5U-45 or `--25k` for LFE5U-25 |
| LED does not blink | Wrong pin mapping or LED polarity | Check LPF file, resistor, LED direction, and GND |
| Simulation passes but hardware fails | Incorrect FPGA pin mapping or old bitstream | Rebuild cleanly and verify uploaded `.bit` file |
| GCC program fails | Unsupported instruction generated | Check objdump and keep C code simple or implement missing instruction |

---

## Useful Debug Commands

### Check Generated Program

```bash
head program.hex
wc -l program.hex
```

### Check for Unsupported Instructions

```bash
riscv64-unknown-elf-objdump -d build/test_program.elf | grep -E "lbu|lb|sb|lh|lhu|sh"
```

### Detect FPGA

```bash
sudo env "PATH=$PATH" openFPGALoader -c cmsisdap --detect
```

### Rebuild From Scratch

```bash
rm -rf build program.hex riscv_soc.vcd
mkdir -p build
```

---

## Project Outcomes

Through this project, the following outcomes were achieved:

- A working single-cycle RV32I processor was designed in Verilog HDL.
- The processor was integrated with a Wishbone bus architecture.
- Instruction memory, data memory, and LED controller were connected as memory-mapped slaves.
- A C program was compiled using the RISC-V GCC toolchain and executed on the custom RISC-V processor.
- Simulation was completed using Icarus Verilog and GTKWave.
- The SoC was synthesized and implemented on a Colorlight i5 ECP5 FPGA board.
- The LED pattern output confirmed correct software-to-hardware execution.

---

## Future Improvements

Possible future improvements include:

- Add UART peripheral for serial communication
- Add GPIO input support for switches and buttons
- Add timer peripheral
- Add interrupt support
- Add pipelined processor architecture
- Add hazard detection and forwarding
- Add instruction cache and data cache
- Add support for more RISC-V extensions
- Add automated Makefile-based full build system
- Add continuous integration for simulation checks

---

## Acknowledgements

I sincerely thank **Dr. Tassadaq Hussain** for his valuable guidance, technical support, and mentorship throughout this project.

I also appreciate the support of **CAID, Namal University**, for providing the FPGA hardware resources that enabled real hardware validation of this project.

---

## Author

**Raheem Bakhsh**  
Electrical Engineering  
Namal University, Mianwali  

---

## License

This project is intended for academic and educational purposes. You may use, modify, and extend it for learning and research with proper credit.

---

## Repository Description

A Verilog-based RV32I single-cycle RISC-V SoC with Wishbone bus integration, GCC-compatible C flow, Icarus Verilog/GTKWave simulation, and Colorlight i5 ECP5 FPGA LED pattern deployment.
