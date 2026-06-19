`timescale 1ns/1ps

module wb_led_slave (
    input         clk,
    input         reset,
    // Wishbone Slave interface
    input         wb_cyc_i,
    input         wb_stb_i,
    input         wb_we_i,
    input  [31:0] wb_adr_i,
    input  [31:0] wb_dat_i,
    input  [3:0]  wb_sel_i,
    output [31:0] wb_dat_o,
    output        wb_ack_o,
    // LED output
    output reg [7:0] led_out
);
    // Combinational ack/read
    assign wb_dat_o = (wb_cyc_i && wb_stb_i && !wb_we_i) ? {24'b0, led_out} : 32'b0;
    assign wb_ack_o = wb_cyc_i && wb_stb_i;

    // Clocked LED register
    always @(posedge clk or posedge reset) begin
        if (reset)
            led_out <= 8'b0;
        else if (wb_cyc_i && wb_stb_i && wb_we_i)
            led_out <= wb_dat_i[7:0];
    end
endmodule
