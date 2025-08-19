# Traffic Light Controller Mealy FSM

A **Mealy finite state machine** controlling a traffic light system with North-South (NS) and East-West (EW) directions.  
The FSM cycles through the states **NS Green**, **NS Yellow**, **EW Green**, and **EW Yellow**, with timed phase lengths controlled by an external **tick** pulse.

- **Reset:** Synchronous, active-high.
- **Tick:** 1-cycle pulse input controlling FSM timing.
- **Outputs:** Green (`_g`), Yellow (`_y`), and Red (`_r`) signals for both NS and EW directions.  
  Exactly one color is active per direction at any time.

---

# Simulation Commands
```bash
iverilog -o sim.out traffic_light.v tb_traffic_light.v
vvp sim.out
gtkwave dump.vcd
```

5/2/5/2 Ticks can be observed in the waveform.

# 1 Hz Tick Generation and Verification

---

## Tick Generator

The tick generator divides the system clock down to produce a **1-cycle-wide pulse** at 1 Hz.  

```verilog
module tick_gen #(parameter CLK_FREQ = 50_000_000,  
                  parameter TICK_FREQ = 1)          
(
    input  wire clk,
    input  wire rst,
    output reg  tick
);

    localparam integer COUNT_MAX = CLK_FREQ / TICK_FREQ;
    reg [$clog2(COUNT_MAX)-1:0] counter;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 0;
            tick    <= 0;
        end else begin
            if (counter == COUNT_MAX-1) begin
                counter <= 0;
                tick    <= 1;    
            end else begin
                counter <= counter + 1;
                tick    <= 0;
            end
        end
    end
endmodule
```
## Testbench for tick

```verilog
`timescale 1ns/1ps
module tb_tick_gen;

    reg clk, rst;
    wire tick;

    tick_gen #(.CLK_FREQ(10), .TICK_FREQ(1)) uut (
        .clk(clk),
        .rst(rst),
        .tick(tick)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("tick.vcd");   
        $dumpvars(0, tb_tick_gen);

        clk = 0;
        rst = 1;
        #20;
        rst = 0;

        #200;  
        $finish;
    end
endmodule
```
