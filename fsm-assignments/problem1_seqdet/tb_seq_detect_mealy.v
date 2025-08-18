`timescale 1ns/1ps
module tb_seq_detect_mealy;   // <-- testbench name is different
    reg clk, rst, din;
    wire y;

    // DUT instantiation
    seq_detect_mealy dut(.clk(clk), .reset(rst), .din(din), .y(y));

    // Clock generation: 100 MHz (10 ns period)
    always #5 clk = ~clk;

    initial begin
        // Init
        clk = 0;
        rst = 1;
        din = 0;

        // Waveform dump
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_seq_detect_mealy);

        // Hold reset for 2 cycles
        repeat (2) @(negedge clk);
        rst = 0;

        // Drive a bitstream with overlaps: 11011011101
        send_bit(1); send_bit(1); send_bit(0); send_bit(1);
        send_bit(1); send_bit(0); send_bit(1);
        send_bit(1); send_bit(1); send_bit(0); send_bit(1);

        // Idle a few cycles
        repeat (5) @(negedge clk);

        $finish;
    end

    // Task to send one bit per cycle
    task send_bit;
        input b;
        begin
            @(negedge clk);
            din = b;
        end
    endtask
endmodule
