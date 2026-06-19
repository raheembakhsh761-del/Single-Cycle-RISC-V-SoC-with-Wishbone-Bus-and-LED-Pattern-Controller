`timescale 1ns/1ps

// ============================================================
//  fpga_top.v  —  FPGA POWER-ON RESET FIXED
//
//  BUG:  assign reset = 1'b0;
//==========================================================

module fpga_top (
    input  wire       clk,        // 25 MHz oscillator
    output wire [4:0] led
);

    // ------------------------------------------------------------------
    // Power-on reset sequencer
    // ------------------------------------------------------------------
    reg [3:0] por_sr = 4'b1111;   // initialised to all-ones at power-up

    always @(posedge clk)
        por_sr <= {por_sr[2:0], 1'b0};   // shift zeros in from the right

    wire reset = por_sr[3];   // HIGH for first 4 clocks, then stays LOW

    // ------------------------------------------------------------------
    // SoC instance
    // ------------------------------------------------------------------
    wire [7:0] led_bus;

    riscv_soc SOC (
        .clk(clk),
        .reset(reset),
        .led_out(led_bus)
    );

    assign led[0] = led_bus[0];
    assign led[1] = led_bus[1];
    assign led[2] = led_bus[2];
    assign led[3] = led_bus[3];
    assign led[4] = led_bus[4];

endmodule
