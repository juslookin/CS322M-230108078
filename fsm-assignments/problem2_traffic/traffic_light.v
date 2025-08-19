
module traffic_light(
    input  wire clk,
    input  wire rst,     
    input  wire tick,    // 1-cycle pulse; FSM advances only on tick
    output reg  ns_g, ns_y, ns_r,
    output reg  ew_g, ew_y, ew_r
);

    parameter NS_G = 2'b00;
    parameter NS_Y = 2'b01;
    parameter EW_G = 2'b10;
    parameter EW_Y = 2'b11;

    parameter time_green = 3'd5;
    parameter time_yellow = 3'd2;

    reg [1:0] state_present, state_next;
    reg [2:0] tick_count, tick_count_next; 

    // State transition on clock edge
    always @(posedge clk) begin
        if (rst) begin
            state_present <= NS_G;
            tick_count <= 3'd0;
        end else begin
            state_present <= state_next;
            tick_count <= tick_count_next;
        end
    end

    // Next state logic
    always @(*) begin
        state_next = state_present;
        tick_count_next   = tick_count;

        case (state_present)
            NS_G: begin
                if (tick) begin
                    if (tick_count == time_green-1) begin
                        state_next = NS_Y;
                        tick_count_next   = 3'd0;
                    end else tick_count_next = tick_count + 1;
                end
            end

            NS_Y: begin
                if (tick) begin
                    if (tick_count == time_yellow-1) begin
                        state_next = EW_G;
                        tick_count_next   = 3'd0;
                    end else tick_count_next = tick_count + 1;
                end
            end

            EW_G: begin
                if (tick) begin
                    if (tick_count == time_green-1) begin
                        state_next = EW_Y;
                        tick_count_next   = 3'd0;
                    end else tick_count_next = tick_count + 1;
                end
            end

            EW_Y: begin
                if (tick) begin
                    if (tick_count == time_yellow-1) begin
                        state_next = NS_G;
                        tick_count_next   = 3'd0;
                    end else tick_count_next = tick_count + 1;
                end
            end

            default: begin
                state_next = NS_G;
                tick_count_next   = 3'd0;
            end
        endcase
    end

    // Output logic: set lights based on current state
    always @(*) begin
        ns_g=0; ns_y=0; ns_r=0;
        ew_g=0; ew_y=0; ew_r=0;
        case (state_present)
            NS_G: begin ns_g=1; ew_r=1; end
            NS_Y: begin ns_y=1; ew_r=1; end
            EW_G: begin ew_g=1; ns_r=1; end
            EW_Y: begin ew_y=1; ns_r=1; end
        endcase
    end
endmodule
