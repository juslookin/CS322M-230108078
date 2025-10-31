// src/controller.sv
// Generates control signals in the ID stage.
// These signals are then pipelined.

module controller(input  logic [6:0] op,
                  input  logic [2:0] funct3,
                  input  logic [6:0] funct7,
                  
                  // Main Decoder Outputs
                  output logic [1:0] ResultSrc_D,
                  output logic       MemWrite_D,
                  output logic       Branch_D, 
                  output logic       ALUSrc_D,
                  output logic       RegWrite_D, 
                  output logic       Jump_D,
                  output logic [1:0] ImmSrc_D,
                  
                  // ALU Decoder Outputs
                  output logic [4:0] ALUControl_D);

    logic [1:0] ALUOp_D;

    // Main Decoder
    // Note: PCSrc signal is removed, as it's now decided in MEM
    maindec md(op, ResultSrc_D, MemWrite_D, Branch_D,
               ALUSrc_D, RegWrite_D, Jump_D, ImmSrc_D, ALUOp_D);

    // ALU Decoder
    // This module is UNCHANGED from your single-cycle.
    // It already supports your RVX10 instructions.
    aludec ad(op, funct3, funct7, ALUOp_D, ALUControl_D);

endmodule

//
// maindec: UNCHANGED from your single-cycle core
// aludec:  UNCHANGED from your single-cycle core
//