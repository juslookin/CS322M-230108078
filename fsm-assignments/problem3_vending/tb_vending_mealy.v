`timescale 1ns/1ps
module tb_vending_mealy;
    reg clk, rst;
    reg [1:0] coin;
    wire vend, chg5;

    vending_mealy dut(.clk(clk), .rst(rst), .coin(coin), .vend(vend), .chg5(chg5));

    always #5 clk = ~clk;

    initial begin
        clk = 0; rst = 1; coin = 2'b00;

        $dumpfile("dump.vcd");
        $dumpvars(0, tb_vending_mealy);

        // release reset
        repeat (2) @(negedge clk);
        rst = 0;

        // Scenario 1: 10 + 10 → vend
        send_coin(2'b10);
        send_coin(2'b10);

        // Scenario 2: 5 + 5 + 10 → vend
        send_coin(2'b01);
        send_coin(2'b01);
        send_coin(2'b10);

        // Scenario 3: 5 + 10 + 10 → vend + change
        send_coin(2'b01);
        send_coin(2'b10);
        send_coin(2'b10);

        // idle a few cycles
        repeat (5) @(negedge clk);

        $finish;
    end

    task send_coin;
        input [1:0] c;
        begin
            @(negedge clk);
            coin = c;         // apply coin
            @(posedge clk);   // hold across one full posedge
            @(negedge clk);
            coin = 2'b00;     // return to idle
        end
    endtask

endmodule
