`timescale 1ns/1ns
`include "q1.v"

module q1_tb;
    reg a,b;
    wire o1,o2,o3;
    
    q1 dut(
        .A(a),
        .B(b),
        .O1(o1),
        .O2(o2),
        .O3(o3)
    );

    initial begin
       $dumpfile("q1_tb.vcd");
       $dumpvars(0,q1_tb);

       a=0; b=0;
       #10;

       a=0;b=1;
       #10; 

       a=1; b=0;
       #10;

       a=1;b=1;
       #10; 

       $display("test is completed...");

    end

endmodule
