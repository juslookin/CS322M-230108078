`timescale 1ns/1ps
module tb_traffic_light;
    reg clk, rst, tick;
    wire ns_g, ns_y, ns_r, ew_g, ew_y, ew_r;

    traffic_light dut(
        .clk(clk), .rst(rst), .tick(tick),
        .ns_g(ns_g), .ns_y(ns_y), .ns_r(ns_r),
        .ew_g(ew_g), .ew_y(ew_y), .ew_r(ew_r)
    );

    always #5 clk = ~clk;

    integer cyc;
    // Generate a FAST "tick": 1-cycle pulse every 20 clk cycles
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

        repeat (5) @(negedge clk);
        rst = 0;
        repeat (1500) @(negedge clk);

        $finish;
    end
endmodule
