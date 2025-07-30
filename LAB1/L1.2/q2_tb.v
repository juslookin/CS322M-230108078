`timescale 1ns/1ns
`include "q2.v"

module q2_tb;
    reg [3:0] a, b;
    wire c;

    q2 dut(
        .A(a),
        .B(b),
        .C(c)
    );

    initial begin
       $dumpfile("q2_tb.vcd");
       $dumpvars(0, q2_tb);

       a = 4'b0000; b = 4'b0000;
       #10;

       a = 4'b0001; b = 4'b1010;
       #10;

       a = 4'b0010; b = 4'b0010;
       #10;

       a = 4'b1010; b = 4'b0011;
       #10;

       $display("test is completed...");

    end

endmodule
