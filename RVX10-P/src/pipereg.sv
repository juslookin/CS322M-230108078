// src/pipereg.sv
// Generic pipeline register with stall (enable) and flush (reset)

module pipereg #(parameter WIDTH = 32)
                 (input  logic             clk, reset,
                  input  logic             en,
                  input  logic             flush,
                  input  logic [WIDTH-1:0] d,
                  output logic [WIDTH-1:0] q);

    always_ff @(posedge clk, posedge reset)
        if (reset)      q <= 0;
        else if (flush) q <= 0; // Flush takes priority
        else if (en)    q <= d;
        // if !en, hold the old value (stall)

endmodule