`timescale 1ns/1ps

// ============================================================
//  riscv_soc.v
//  Detailed Bus Architecture: 1 Wishbone Master and 3 Slaves
//
//  Master:
//      M0: CPU shared Wishbone master
//
//  Slaves:
//      S0: Program / instruction memory 0x0000_0000 - 0x0000_0FFF
//      S1: Data memory                  0x0000_1000 - 0x0000_1FFF
//      S2: LED controller MMIO          0x0000_2000 - 0x0000_2FFF
// ============================================================

module riscv_soc (
    input         clk,
    input         reset,
    output [7:0]  led_out
);

    // ------------------------------------------------------------
    // One shared Wishbone master bus from CPU
    // ------------------------------------------------------------
    wire        m_wb_cyc;
    wire        m_wb_stb;
    wire        m_wb_we;
    wire [31:0] m_wb_adr;
    wire [31:0] m_wb_dat_mosi;
    wire [3:0]  m_wb_sel;
    wire [31:0] m_wb_dat_miso;
    wire        m_wb_ack;

    // Slave select signals
    wire sel_s0;   // Program / instruction memory
    wire sel_s1;   // Data memory
    wire sel_s2;   // LED MMIO

    // Slave read data and ACK signals
    wire [31:0] rdata_s0;
    wire [31:0] rdata_s1;
    wire [31:0] rdata_s2;
    wire        ack_s0;
    wire        ack_s1;
    wire        ack_s2;

    // ------------------------------------------------------------
    // Address decoder
    // ------------------------------------------------------------
    wb_addr_decoder ADDR_DEC (
        .wb_adr_i(m_wb_adr),
        .sel_s0(sel_s0),
        .sel_s1(sel_s1),
        .sel_s2(sel_s2)
    );

    // ------------------------------------------------------------
    // S0: Program / instruction memory slave
    // ------------------------------------------------------------
    wb_prog_mem_slave S0_PROG (
        .clk(clk),
        .reset(reset),
        .wb_cyc_i(m_wb_cyc & sel_s0),
        .wb_stb_i(m_wb_stb & sel_s0),
        .wb_we_i(m_wb_we),
        .wb_adr_i(m_wb_adr),
        .wb_dat_i(m_wb_dat_mosi),
        .wb_sel_i(m_wb_sel),
        .wb_dat_o(rdata_s0),
        .wb_ack_o(ack_s0)
    );

    // ------------------------------------------------------------
    // S1: Data memory slave
    // ------------------------------------------------------------
    wb_data_mem_slave S1_DATA (
        .clk(clk),
        .reset(reset),
        .wb_cyc_i(m_wb_cyc & sel_s1),
        .wb_stb_i(m_wb_stb & sel_s1),
        .wb_we_i(m_wb_we),
        .wb_adr_i(m_wb_adr),
        .wb_dat_i(m_wb_dat_mosi),
        .wb_sel_i(m_wb_sel),
        .wb_dat_o(rdata_s1),
        .wb_ack_o(ack_s1)
    );

    // ------------------------------------------------------------
    // S2: LED controller memory-mapped I/O slave
    // ------------------------------------------------------------
    wb_led_slave S2_LED (
        .clk(clk),
        .reset(reset),
        .wb_cyc_i(m_wb_cyc & sel_s2),
        .wb_stb_i(m_wb_stb & sel_s2),
        .wb_we_i(m_wb_we),
        .wb_adr_i(m_wb_adr),
        .wb_dat_i(m_wb_dat_mosi),
        .wb_sel_i(m_wb_sel),
        .wb_dat_o(rdata_s2),
        .wb_ack_o(ack_s2),
        .led_out(led_out)
    );

    // ------------------------------------------------------------
    // Read-data mux and ACK merge
    // ------------------------------------------------------------
    wb_read_mux RDMUX (
        .sel_s0(sel_s0),
        .sel_s1(sel_s1),
        .sel_s2(sel_s2),
        .rdata_s0(rdata_s0),
        .rdata_s1(rdata_s1),
        .rdata_s2(rdata_s2),
        .wb_dat_o(m_wb_dat_miso)
    );

    assign m_wb_ack = ack_s0 | ack_s1 | ack_s2;

    // ------------------------------------------------------------
    // CPU core: only one shared Wishbone master interface
    // ------------------------------------------------------------
    riscv_core CPU (
        .clk(clk),
        .reset(reset),
        .wb_cyc_o(m_wb_cyc),
        .wb_stb_o(m_wb_stb),
        .wb_we_o(m_wb_we),
        .wb_adr_o(m_wb_adr),
        .wb_dat_o(m_wb_dat_mosi),
        .wb_sel_o(m_wb_sel),
        .wb_dat_i(m_wb_dat_miso),
        .wb_ack_i(m_wb_ack)
    );

endmodule
