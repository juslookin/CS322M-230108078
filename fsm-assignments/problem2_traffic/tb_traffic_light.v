`timescale 1ns/1ps
module tb_traffic_light;
    reg clk, rst, tick;
    wire ns_g, ns_y, ns_r, ew_g, ew_y, ew_r;

    // DUT
    traffic_light dut(
        .clk(clk), .rst(rst), .tick(tick),
        .ns_g(ns_g), .ns_y(ns_y), .ns_r(ns_r),
        .ew_g(ew_g), .ew_y(ew_y), .ew_r(ew_r)
    );

    // Clock: 100 MHz (10 ns period)
    always #5 clk = ~clk;

    integer cyc;
    // Generate a FAST "tick": 1-cycle pulse every 20 clk cycles
    // (i.e., tick period = 200 ns in sim; stands in for 1 Hz hardware tick)
    always @(posedge clk) begin
        if (rst) begin
            cyc  <= 0;
            tick <= 0;
        end else begin
            cyc  <= cyc + 1;
            tick <= (cyc % 20 == 0); // 1-cycle wide pulse
        end
    end

    initial begin
        clk = 0; rst = 1; tick = 0;

        $dumpfile("dump.vcd");
        $dumpvars(0, tb_traffic_light);

        // release reset after a few cycles
        repeat (5) @(negedge clk);
        rst = 0;

        // run long enough to see multiple full cycles:
        // one full cycle = 5+2+5+2 = 14 ticks -> 14*20 = 280 clk cycles
        // simulate ~5 cycles:
        repeat (1500) @(negedge clk);

        $finish;
    end

    // Optional: print at each tick for quick sanity check
    always @(posedge clk) if (tick && !rst) begin
        $display("t=%0t ns  tick  NS[g,y,r]=%0d%0d%0d  EW[g,y,r]=%0d%0d%0d",
                 $time, ns_g,ns_y,ns_r, ew_g,ew_y,ew_r);
    end
endmodule
