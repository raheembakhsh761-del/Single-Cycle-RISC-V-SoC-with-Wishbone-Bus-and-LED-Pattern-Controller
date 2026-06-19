`timescale 1ns/1ps

// ============================================================
//  wb_read_mux.v
//  Read-data multiplexer for one shared Wishbone bus
// ============================================================

module wb_read_mux (
    input        sel_s0,
    input        sel_s1,
    input        sel_s2,
    input  [31:0] rdata_s0,
    input  [31:0] rdata_s1,
    input  [31:0] rdata_s2,
    output reg [31:0] wb_dat_o
);
    always @(*) begin
        if      (sel_s0) wb_dat_o = rdata_s0;
        else if (sel_s1) wb_dat_o = rdata_s1;
        else if (sel_s2) wb_dat_o = rdata_s2;
        else             wb_dat_o = 32'hDEAD_BEEF;
    end
endmodule
