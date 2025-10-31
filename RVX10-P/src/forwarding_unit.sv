// src/forwarding_unit.sv
// Detects data hazards and selects forwarding paths for ALU

module forwarding_unit(
    // Inputs from ID/EX Register
    input  logic [4:0]  rs1_E,
    input  logic [4:0]  rs2_E,

    // Inputs from EX/MEM Register
    input  logic [4:0]  rd_M,
    input  logic        RegWrite_M,
    
    // Inputs from MEM/WB Register
    input  logic [4:0]  rd_W,
    input  logic        RegWrite_W,

    // Outputs to control ALU input muxes
    output logic [1:0]  ForwardA_E,
    output logic [1:0]  ForwardB_E
);

    // ForwardA (for ALU input A, which comes from rs1)
    // Priority: MEM stage has newer data than WB stage
    always_comb begin
        if (RegWrite_M && (rd_M != 0) && (rd_M == rs1_E))
            ForwardA_E = 2'b10; // Forward from MEM/WB (ALUResult_M)
        else if (RegWrite_W && (rd_W != 0) && (rd_W == rs1_E))
            ForwardA_E = 2'b01; // Forward from MEM/WB (Result_W)
        else
            ForwardA_E = 2'b00; // No forwarding, use ID/EX (SrcA_E)
    end

    // ForwardB (for ALU input B, which comes from rs2)
    always_comb begin
        if (RegWrite_M && (rd_M != 0) && (rd_M == rs2_E))
            ForwardB_E = 2'b10; // Forward from MEM/WB (ALUResult_M)
        else if (RegWrite_W && (rd_W != 0) && (rd_W == rs2_E))
            ForwardB_E = 2'b01; // Forward from MEM/WB (Result_W)
        else
            ForwardB_E = 2'b00; // No forwarding, use ID/EX (WriteData_E)
    end

endmodule