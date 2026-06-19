`timescale 1ns/1ps

module wb_data_mem_slave (
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

    // 1024 words × 4 bytes = 4 KB
    reg [31:0] mem [0:1023];

    integer k;

    wire [9:0] waddr;
    assign waddr = wb_adr_i[11:2];

    assign wb_dat_o =
        (wb_cyc_i && wb_stb_i && !wb_we_i)
        ? mem[waddr]
        : 32'b0;

    assign wb_ack_o = wb_cyc_i && wb_stb_i;

    // Simulation-only initialization.
    // This prevents unwritten locations from appearing as x.
`ifndef SYNTHESIS
    initial begin
        for (k = 0; k < 1024; k = k + 1)
            mem[k] = 32'b0;
    end
`endif

    // Data-memory writes
    always @(posedge clk) begin
        if (wb_cyc_i && wb_stb_i && wb_we_i) begin
            if (wb_sel_i[0])
                mem[waddr][7:0] <= wb_dat_i[7:0];

            if (wb_sel_i[1])
                mem[waddr][15:8] <= wb_dat_i[15:8];

            if (wb_sel_i[2])
                mem[waddr][23:16] <= wb_dat_i[23:16];

            if (wb_sel_i[3])
                mem[waddr][31:24] <= wb_dat_i[31:24];
        end
    end

endmodule
