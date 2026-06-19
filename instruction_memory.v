`timescale 1ns/1ps

module instruction_memory (
    input  wire [31:0] read_address,
    output wire [31:0] instruction_out
);

    // 1024 words × 32 bits = 4096 bytes
    reg [31:0] I_Mem [0:1023];

    initial begin
        $readmemh("program.hex", I_Mem);
    end

    assign instruction_out = I_Mem[read_address[11:2]];

endmodule
