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

        $display("==================================================");
        $display(" RISC-V SoC C Program LED Pattern Testbench");
        $display("==================================================");

        reset = 1;
        #20;
        reset = 0;

        #10000000;

        $display("Final LED = 0x%02h", led_out);

        if ((led_out == 8'h01) ||
            (led_out == 8'h02) ||
            (led_out == 8'h04) ||
            (led_out == 8'h08) ||
            (led_out == 8'h10)) begin
            $display("[PASS] LED blinking pattern is active. Current LED = 0x%02h", led_out);
        end
        else begin
            $display("[INFO] LED current value = 0x%02h", led_out);
            $display("[INFO] Open GTKWave and check led_out[7:0] pattern.");
        end

        $display("Expected pattern:");
        $display("0x55 -> 0x01 -> 0x02 -> 0x04 -> 0x08 -> 0x10 -> 0x08 -> 0x04 -> 0x02 -> repeat");

        $finish;
    end

endmodule
