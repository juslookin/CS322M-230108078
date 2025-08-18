module seq_detect_mealy(input clk, input reset, input din, output reg y);
    reg [1:0] state_present, state_next;

    // State encoding
    parameter match_0 = 2'b00; // no match
    parameter match_1 = 2'b01; // saw "1"
    parameter match_2 = 2'b10; // saw "11"
    parameter match_3 = 2'b11; // saw "110"

    // State register
    always @(posedge clk) begin
        if (reset) state_present <= match_0;   // synchronous reset
        else  state_present <= state_next;
    end

    // Next-state and output logic
    always @(*) begin
        y = 1'b0;           // default output
        state_next = match_0;    // default next state

        case (state_present)
            match_0: begin
                if (din) state_next = match_1;
                else     state_next = match_0;
            end
            match_1: begin
                if (din) state_next = match_2;
                else     state_next = match_0;
            end
            match_2: begin
                if (din) state_next = match_2; // stay with suffix "11"
                else     state_next = match_3;
            end
            match_3: begin
                if (din) begin
                    y = 1'b1;            // detected 1101
                    state_next = match_1;     // fallback suffix "1"
                end else begin
                    state_next = match_0;
                end
            end
            default: state_next = match_0;
        endcase
    end
endmodule
