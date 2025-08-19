module vending_mealy(
    input  wire clk,
    input  wire rst,       
    input  wire [1:0] coin,
    output reg  vend,  
    output reg  chg5       
);

    // State encoding
    parameter total_0  = 2'b00; // total=0
    parameter total_5  = 2'b01; // total=5
    parameter total_10 = 2'b10; // total=10
    parameter total_15 = 2'b11; // total=15

    reg [1:0] state_present, state_next;

    // Register coin to avoid timing glitches
    reg [1:0] coin_reg;
    always @(posedge clk) begin
        if (rst) coin_reg <= 2'b00;
        else     coin_reg <= coin;
    end

    // State register
    always @(posedge clk) begin
        if (rst) state_present <= total_0;
        else     state_present <= state_next;
    end

    // Next-state and output logic (Mealy)
    always @(*) begin
        // defaults
        state_next = state_present;
        vend       = 0;
        chg5       = 0;

        case (state_present)
            total_0: case (coin_reg)
                    2'b01: state_next = total_5;
                    2'b10: state_next = total_10;
                    default: state_next = total_0;
                endcase

            total_5: case (coin_reg)
                    2'b01: state_next = total_10;
                    2'b10: state_next = total_15;
                    default: state_next = total_5;
                endcase

            total_10: case (coin_reg)
                    2'b01: state_next = total_15;
                    2'b10: begin
                              vend   = 1; // total=20
                              state_next = total_0;
                           end
                    default: state_next = total_10;
                endcase

            total_15: case (coin_reg)
                    2'b01: begin
                              vend   = 1; // total=20
                              state_next = total_0;
                           end
                    2'b10: begin
                              vend   = 1; // total=25
                              chg5       = 1;
                              state_next = total_0;
                           end
                    default: state_next = total_15;
                endcase
        endcase
    end
endmodule
