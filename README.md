# RISC-V Single-Cycle SoC with Wishbone Bus (Separate Verilog Files)

Top module: `riscv_soc`

Hierarchy:
- `riscv_soc`
  - `riscv_core`
  - `instruction_memory`
  - `wb_addr_decoder`
  - `wb_read_mux`
  - `wb_prog_mem_slave`
  - `wb_data_mem_slave`
  - `wb_led_slave`

Compile with Icarus Verilog example:

```bash
iverilog -o riscv_soc.out -f compile_order.f
```

Note: `program.hex` is required by `instruction_memory` and `wb_prog_mem_slave`. Replace the sample NOP file with your real machine-code hex.
