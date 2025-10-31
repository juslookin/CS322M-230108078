// src/riscvpipeline.sv
// Top-level 5-stage pipeline module

module riscvpipeline(
    input  logic        clk, reset,
    
    // Instruction Memory
    output logic [31:0] PC,
    input  logic [31:0] Instr,
    
    // Data Memory
    output logic        MemWrite,
    output logic [31:0] ALUResult_M, WriteData_M,
    input  logic [31:0] ReadData_M
);

    // Hazard Unit signals
    logic [4:0]  rs1_D, rs2_D, rd_E;
    logic        MemRead_E;
    logic        Stall_F, Flush_D, Flush_E;
    logic        PC_Sel_F;
    logic        PCSrc_M;

    // Forwarding Unit signals
    logic [4:0]  rs1_E, rs2_E, rd_M, rd_W;
    logic        RegWrite_M, RegWrite_W;
    logic [1:0]  ForwardA_E, ForwardB_E;

    // Controller signals
    logic [6:0]  op_D, funct7_D;
    logic [2:0]  funct3_D;
    logic [1:0]  ResultSrc_D;
    logic        MemWrite_D, Branch_D, ALUSrc_D;
    logic        RegWrite_D, Jump_D;
    logic [1:0]  ImmSrc_D;
    logic [4:0]  ALUControl_D;

    // Instantiate Pipelined Datapath
    datapath dp (
        .clk(clk), .reset(reset),
        
        .rs1_D(rs1_D), .rs2_D(rs2_D), .rd_E(rd_E),
        .MemRead_E(MemRead_E),
        .Stall_F(Stall_F), .Flush_D(Flush_D), .Flush_E(Flush_E),

        .rs1_E(rs1_E), .rs2_E(rs2_E), .rd_M(rd_M), .rd_W(rd_W),
        .RegWrite_M(RegWrite_M), .RegWrite_W(RegWrite_W),
        .ForwardA_E(ForwardA_E), .ForwardB_E(ForwardB_E),

        .op_D(op_D), .funct3_D(funct3_D), .funct7_D(funct7_D),
        .ResultSrc_D(ResultSrc_D), .MemWrite_D(MemWrite_D), 
        .Branch_D(Branch_D), .ALUSrc_D(ALUSrc_D),
        .RegWrite_D(RegWrite_D), .Jump_D(Jump_D),
        .ImmSrc_D(ImmSrc_D), .ALUControl_D(ALUControl_D),

        .PCSrc_M(PCSrc_M), .PC_Sel_F(PC_Sel_F),

        .PC(PC), .Instr(Instr),
        .MemWrite_M(MemWrite),
        .ALUResult_M(ALUResult_M), 
        .WriteData_M(WriteData_M),
        .ReadData_M(ReadData_M)
    );

    // Instantiate Controller
    controller c (
        .op(op_D), .funct3(funct3_D), .funct7(funct7_D),
        .ResultSrc_D(ResultSrc_D), .MemWrite_D(MemWrite_D),
        .Branch_D(Branch_D), .ALUSrc_D(ALUSrc_D),
        .RegWrite_D(RegWrite_D), .Jump_D(Jump_D),
        .ImmSrc_D(ImmSrc_D), .ALUControl_D(ALUControl_D)
    );

    // Instantiate Hazard Unit
    hazard_unit hu (
        .rs1_D(rs1_D), .rs2_D(rs2_D),
        .rd_E(rd_E), .MemRead_E(MemRead_E),
        .PCSrc_M(PCSrc_M),
        .Stall_F(Stall_F), 
        .Flush_D(Flush_D), 
        .Flush_E(Flush_E)
    );

    // Instantiate Forwarding Unit
    forwarding_unit fu (
        .rs1_E(rs1_E), .rs2_E(rs2_E),
        .rd_M(rd_M), .RegWrite_M(RegWrite_M),
        .rd_W(rd_W), .RegWrite_W(RegWrite_W),
        .ForwardA_E(ForwardA_E),
        .ForwardB_E(ForwardB_E)
    );

    // PC Select Logic (controlled by hazard unit)
    assign PC_Sel_F = PCSrc_M; // 0 = PC+4, 1 = Branch Target

endmodule