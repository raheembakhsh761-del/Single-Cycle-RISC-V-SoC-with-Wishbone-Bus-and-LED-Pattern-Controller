`timescale 1ns/1ps

// ============================================================
//  wb_prog_mem_slave.v
//  Wishbone program/instruction memory slave, S0
//  Address range: 0x0000_0000 - 0x0000_0FFF
// ============================================================

module wb_prog_mem_slave (
    input         clk,
    input         reset,

    input         wb_cyc_i,
    input         wb_stb_i,
    input         wb_we_i,
    input  [31:0] wb_adr_i,
    input  [31:0] wb_dat_i,
    input  [3:0]  wb_sel_i,

    output [31:0] wb_dat_o,
    output        wb_ack_o
);

    // 1024 words x 32-bit = 4 KB program memory
    reg [31:0] mem [0:1023];

    wire [9:0] word_addr;
    assign word_addr = wb_adr_i[11:2];

    initial begin
        $readmemh("program.hex", mem);
    end

    // Zero-wait-state combinational read/ack for simple bus operation
    assign wb_dat_o = (wb_cyc_i && wb_stb_i && !wb_we_i) ? mem[word_addr] : 32'b0;
    assign wb_ack_o = wb_cyc_i && wb_stb_i;

    // Optional program-memory write support
    always @(posedge clk) begin
        if (wb_cyc_i && wb_stb_i && wb_we_i) begin
            if (wb_sel_i[0]) mem[word_addr][7:0]   <= wb_dat_i[7:0];
            if (wb_sel_i[1]) mem[word_addr][15:8]  <= wb_dat_i[15:8];
            if (wb_sel_i[2]) mem[word_addr][23:16] <= wb_dat_i[23:16];
            if (wb_sel_i[3]) mem[word_addr][31:24] <= wb_dat_i[31:24];
        end
    end

endmodule
