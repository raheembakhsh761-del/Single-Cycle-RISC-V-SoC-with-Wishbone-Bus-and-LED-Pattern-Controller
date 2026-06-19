`timescale 1ns/1ps

// ============================================================
//  wb_addr_decoder.v
//  One shared Wishbone bus: 1 master, 3 slaves
//      S0: Program / instruction memory 0x0000_0000 - 0x0000_0FFF
//      S1: Data memory                  0x0000_1000 - 0x0000_1FFF
//      S2: LED MMIO                     0x0000_2000 - 0x0000_2FFF
// ============================================================

module wb_addr_decoder (
    input  [31:0] wb_adr_i,
    output reg    sel_s0,   // Program / Instruction Memory
    output reg    sel_s1,   // Data Memory
    output reg    sel_s2    // LED MMIO
);
    always @(*) begin
        sel_s0 = 1'b0;
        sel_s1 = 1'b0;
        sel_s2 = 1'b0;

        case (wb_adr_i[15:12])
            4'b0000: sel_s0 = 1'b1;   // 0x0000_0xxx Program memory
            4'b0001: sel_s1 = 1'b1;   // 0x0000_1xxx Data memory
            4'b0010: sel_s2 = 1'b1;   // 0x0000_2xxx LED MMIO
            default: begin
                sel_s0 = 1'b0;
                sel_s1 = 1'b0;
                sel_s2 = 1'b0;
            end
        endcase
    end
endmodule
