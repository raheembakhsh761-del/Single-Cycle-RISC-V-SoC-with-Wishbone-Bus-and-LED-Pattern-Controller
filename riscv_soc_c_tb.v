`timescale 1ns/1ps
module riscv_soc_c_tb;
    reg clk = 0;
    reg reset = 1;
    wire [7:0] led_out;

    always #5 clk = ~clk;

    riscv_soc DUT (
        .clk(clk),
        .reset(reset),
        .led_out(led_out)
    );

    initial begin
        $dumpfile("riscv_soc_c.vcd");
        $dumpvars(0, riscv_soc_c_tb);
        #20 reset = 0;
        #2000000;
        $display("Final LED = 0x%02h", led_out);
        $finish;
    end
endmodule
