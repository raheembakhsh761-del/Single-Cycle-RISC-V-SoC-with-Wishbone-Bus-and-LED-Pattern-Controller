`timescale 1ns/1ps

module riscv_soc_tb;

    reg clk = 0;
    reg reset = 1;
    wire [7:0] led_out;

    always #5 clk = ~clk;

    riscv_soc DUT (
        .clk(clk),
        .reset(reset),
        .led_out(led_out)
    );

    // Debug signals for GTKWave only
    wire [31:0] pc_debug          = DUT.CPU.PC_out;
    wire [31:0] instruction_debug = DUT.CPU.instruction;
    wire [31:0] alu_result_debug  = DUT.CPU.ALU_result;
    wire [31:0] rd1_debug         = DUT.CPU.RD1;
    wire [31:0] rd2_debug         = DUT.CPU.RD2;
    wire [31:0] writeback_debug   = DUT.CPU.JAL_WB;

    wire regwrite_debug = DUT.CPU.RegWrite;
    wire memread_debug  = DUT.CPU.MemRead;
    wire memwrite_debug = DUT.CPU.MemWrite;
    wire branch_debug   = DUT.CPU.Branch;
    wire jump_debug     = DUT.CPU.Jump;
    wire zero_debug     = DUT.CPU.Zero;

    wire [31:0] x1_debug = DUT.CPU.RF.reg_mem[1];
    wire [31:0] x2_debug = DUT.CPU.RF.reg_mem[2];
    wire [31:0] x3_debug = DUT.CPU.RF.reg_mem[3];
    wire [31:0] x4_debug = DUT.CPU.RF.reg_mem[4];
    wire [31:0] x5_debug = DUT.CPU.RF.reg_mem[5];
    wire [31:0] x6_debug = DUT.CPU.RF.reg_mem[6];
    wire [31:0] x7_debug = DUT.CPU.RF.reg_mem[7];
    wire [31:0] x8_debug = DUT.CPU.RF.reg_mem[8];
    wire [31:0] x9_debug = DUT.CPU.RF.reg_mem[9];

    wire [31:0] dmem0_debug  = DUT.S1_DATA.mem[0];
    wire [31:0] dmem1_debug  = DUT.S1_DATA.mem[1];
    wire [31:0] dmem2_debug  = DUT.S1_DATA.mem[2];
    wire [31:0] dmem3_debug  = DUT.S1_DATA.mem[3];
    wire [31:0] dmem4_debug  = DUT.S1_DATA.mem[4];
    wire [31:0] dmem5_debug  = DUT.S1_DATA.mem[5];
    wire [31:0] dmem10_debug = DUT.S1_DATA.mem[10];
    wire [31:0] dmem20_debug = DUT.S1_DATA.mem[20];
    wire [31:0] dmem30_debug = DUT.S1_DATA.mem[30];
    wire [31:0] dmem50_debug = DUT.S1_DATA.mem[50];

    wire        wb_cyc_debug   = DUT.m_wb_cyc;
    wire        wb_stb_debug   = DUT.m_wb_stb;
    wire        wb_we_debug    = DUT.m_wb_we;
    wire [31:0] wb_adr_debug   = DUT.m_wb_adr;
    wire [31:0] wb_wdata_debug = DUT.m_wb_dat_mosi;
    wire [31:0] wb_rdata_debug = DUT.m_wb_dat_miso;
    wire        wb_ack_debug   = DUT.m_wb_ack;
    wire        sel_s1_debug   = DUT.sel_s1;
    wire        sel_s2_debug   = DUT.sel_s2;

    integer pass_count = 0;
    integer fail_count = 0;

    task check;
        input [255:0] test_name;
        input [31:0] got;
        input [31:0] expected;
        begin
            if (got === expected) begin
                $display("[PASS] %0s got=0x%08h", test_name, got);
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] %0s got=0x%08h expected=0x%08h", test_name, got, expected);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("riscv_soc.vcd");
        $dumpvars(0, riscv_soc_tb);

        $display("===========================================================");
        $display(" RISC-V SoC Testbench: Instructions Loaded from program.hex");
        $display("===========================================================");

        reset = 1;
        repeat (5) @(posedge clk);
        reset = 0;

        repeat (200000) @(posedge clk);

        $display("Final LED = 0x%02h", led_out);

        check("Final LED should be 0x55", {24'b0, led_out}, 32'h00000055);
        check("DMEM[0] ADD result = 8",  dmem0_debug,  32'd8);
        check("DMEM[1] SUB result = 2",  dmem1_debug,  32'd2);
        check("DMEM[2] AND result = 1",  dmem2_debug,  32'd1);
        check("DMEM[3] OR result = 7",   dmem3_debug,  32'd7);
        check("DMEM[4] XOR result = 6",  dmem4_debug,  32'd6);
        check("DMEM[5] SLT result = 0",  dmem5_debug,  32'd0);
        check("DMEM[10] = DEADBEEF",     dmem10_debug, 32'hDEADBEEF);
        check("DMEM[20] = DEADBEEF copy", dmem20_debug, 32'hDEADBEEF);
        check("DMEM[30] Fibonacci first value = 0", dmem30_debug, 32'd0);
        check("DMEM[50] Sorted first value = 1", dmem50_debug, 32'd1);

        $display("===========================================================");
        $display(" Results: %0d PASSED | %0d FAILED", pass_count, fail_count);
        $display("===========================================================");

        if (fail_count == 0)
            $display(" *** PROGRAM.HEX TEST PASSED ***");
        else
            $display(" *** PROGRAM.HEX TEST FAILED ***");

        $finish;
    end

    initial begin
        #100000000;
        $display("[TIMEOUT] Simulation stopped.");
        $finish;
    end

endmodule
