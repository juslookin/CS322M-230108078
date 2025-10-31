// src/datapath.sv
// The 5-stage pipelined datapath

module datapath(
    input  logic        clk, reset,
    
    // Interface to Hazard Unit
    output logic [4:0]  rs1_D, rs2_D, rd_E,
    output logic        MemRead_E,
    input  logic        Stall_F, Flush_D, Flush_E,

    // Interface to Forwarding Unit
    output logic [4:0]  rs1_E,
    output logic [4:0]  rs2_E, rd_M, rd_W,
    output logic        RegWrite_M, RegWrite_W,
    input  logic [1:0]  ForwardA_E, ForwardB_E,

    // Interface to Controller
    output logic [6:0]  op_D, funct7_D,
    output logic [2:0]  funct3_D,
    input  logic [1:0]  ResultSrc_D,
    input  logic        MemWrite_D, Branch_D, ALUSrc_D,
    input  logic        RegWrite_D, Jump_D,
    input  logic [1:0]  ImmSrc_D,
    input  logic [4:0]  ALUControl_D,

    // Interface to PC Mux
    output logic        PCSrc_M, // To Hazard Unit
    input  logic        PC_Sel_F, // From Hazard Unit

    // Memory Interfaces
    output logic [31:0] PC, Instr,
    output logic        MemWrite_M,
    output logic [31:0] ALUResult_M, WriteData_M,
    input  logic [31:0] ReadData_M
);

    // Pipeline stage signals
    logic [31:0] PC_F, PCNext_F, PCPlus4_F, PCTarget_E, PCTarget_M;
    logic [31:0] Instr_D, PCPlus4_D;
    
    logic [31:0] SrcA_D, WriteData_D, ImmExt_D, Result_W;
    logic [4:0]  rd_D;

    logic [31:0] PC_E, PCPlus4_E, SrcA_E, WriteData_E, ImmExt_E;
    logic [31:0] SrcA_ALU_E, SrcB_ALU_E;
    logic [4:0]  ALUControl_E;
    logic [1:0]  ResultSrc_E;
    logic        ALUSrc_E, RegWrite_E, MemWrite_E, Branch_E, Jump_E;
    logic [31:0] ALUResult_E;
    logic        Zero_E;

    logic [31:0] PCPlus4_M;
    logic [1:0]  ResultSrc_M;
    logic        RegWrite_E_M; // Renamed to avoid clash
    logic [31:0] PCPlus4_W, ALUResult_W;


    // Stall/Flush logic
    logic PC_en_F, IF_ID_en_D;
    assign PC_en_F      = ~Stall_F;
    assign IF_ID_en_D   = ~Stall_F;


//=================================================================
// 1. IF STAGE (Instruction Fetch)
//=================================================================

    // PC Register
    flopr #(32) pcreg(clk, reset, PC_en_F, PCNext_F, PC);

    // PC Mux: Selects next PC
    // 00: PC + 4 (default)
    // 01: Branch Target (from MEM stage)
    mux2 #(32) pcmux(PCPlus4_F, PCTarget_M, PC_Sel_F, PCNext_F);

    // PC + 4 Adder
    adder pcadd4(PC, 32'd4, PCPlus4_F);
    
    // Outputs
    assign PC = PC_F;
    assign Instr = Instr_F; // From imem (connected in top)


//=================================================================
// IF/ID PIPELINE REGISTER
//=================================================================

    pipereg #(64) if_id_reg (
        .clk(clk), .reset(reset), 
        .en(IF_ID_en_D), 
        .flush(Flush_D),
        .d({PCPlus4_F, PC_F}), 
        .q({PCPlus4_D, PC_D})
    );
    // Instruction is passed directly from imem to ID stage
    // to avoid needing a register for it, or:
    // pipereg #(32) if_id_instr_reg (clk, reset, IF_ID_en_D, Flush_D, Instr_F, Instr_D);
    assign Instr_D = Instr; // Simplification: Instr is read in ID


//=================================================================
// 2. ID STAGE (Instruction Decode)
//=================================================================

    // Connect to Controller
    assign op_D     = Instr_D[6:0];
    assign funct3_D = Instr_D[14:12];
    assign funct7_D = Instr_D[31:25];

    // Register File
    assign rs1_D = Instr_D[19:15];
    assign rs2_D = Instr_D[24:20];
    assign rd_D  = Instr_D[11:7];
    
    regfile rf (
        .clk(clk), 
        .we3(RegWrite_W), // Write comes from WB stage
        .a1(rs1_D), 
        .a2(rs2_D), 
        .a3(rd_W),        // Write address from WB stage
        .wd3(Result_W),   // Write data from WB stage
        .rd1(SrcA_D), 
        .rd2(WriteData_D)
    );

    // Sign Extension
    extend ext(Instr_D[31:7], ImmSrc_D, ImmExt_D);
    
    // Outputs to Hazard Unit
    assign MemRead_E = MemRead_D; // Pass-through for simplicity
    

//=================================================================
// ID/EX PIPELINE REGISTER
//=================================================================
    // Group control signals
    logic [10:0] controls_D;
    assign controls_D = {ALUControl_D, ResultSrc_D, MemWrite_D, 
                         Branch_D, ALUSrc_D, RegWrite_D, Jump_D};
    
    logic [10:0] controls_E;
    assign {ALUControl_E, ResultSrc_E, MemWrite_E, 
            Branch_E, ALUSrc_E, RegWrite_E, Jump_E} = controls_E;

    pipereg #(32+32+32+32+5+11) id_ex_reg (
        .clk(clk), .reset(reset), 
        .en(1'b1),        // Always enabled,
        .flush(Flush_E),  // but flushed on hazard
        .d({PCPlus4_D, PC_D, SrcA_D, WriteData_D, rd_D, controls_D, ImmExt_D}), 
        .q({PCPlus4_E, PC_E, SrcA_E, WriteData_E, rd_E, controls_E, ImmExt_E})
    );
    assign rs1_E = Instr_D[19:15]; // Pass-through for forwarding
    assign rs2_E = Instr_D[24:20]; // Pass-through for forwarding


//=================================================================
// 3. EX STAGE (Execute)
//=================================================================

    // Branch Target Adder
    adder pcaddbranch(PC_E, ImmExt_E, PCTarget_E);

    // Forwarding Muxes for ALU inputs
    mux3 #(32) fwdAmux(SrcA_E, Result_W, ALUResult_M, ForwardA_E, SrcA_ALU_E);
    mux3 #(32) fwdBmux(WriteData_E, Result_W, ALUResult_M, ForwardB_E, SrcB_ALU_E);

    // ALU SrcB Mux (rs2 vs immediate)
    mux2 #(32) srcbmux(SrcB_ALU_E, ImmExt_E, ALUSrc_E, SrcB_ALU_E_muxed);

    // ALU
    // This is UNCHANGED from your single-cycle core.
    // It handles ADD, SUB, AND, OR, SLT, and all 10
    // of your RVX10 custom instructions based on ALUControl_E.
    alu alu (
        .a(SrcA_ALU_E), 
        .b(SrcB_ALU_E_muxed), 
        .alucontrol(ALUControl_E), 
        .result(ALUResult_E), 
        .zero(Zero_E)
    );
    
    assign MemRead_E = MemWrite_E; // Pass-through for hazard unit


//=================================================================
// EX/MEM PIPELINE REGISTER
//=================================================================
    logic [5:0] controls_E_out;
    assign controls_E_out = {ResultSrc_E, MemWrite_E, Branch_E, RegWrite_E, Jump_E};
    
    logic [5:0] controls_M;
    assign {ResultSrc_M, MemWrite_M, Branch_M, RegWrite_M, Jump_M} = controls_M;

    pipereg #(32+32+32+32+1+5+6) ex_mem_reg (
        .clk(clk), .reset(reset), 
        .en(1'b1), .flush(1'b0), // Never flushes, never stalls
        .d({PCPlus4_E, PCTarget_E, ALUResult_E, WriteData_E, Zero_E, rd_E, controls_E_out}), 
        .q({PCPlus4_M, PCTarget_M, ALUResult_M, WriteData_M, Zero_M, rd_M, controls_M})
    );
    assign RegWrite_E_M = RegWrite_M; // Pass-through


//=================================================================
// 4. MEM STAGE (Memory Access)
//=================================================================

    // Data Memory Access (signals routed to top)
    // dmem(clk, MemWrite_M, ALUResult_M, WriteData_M, ReadData_M);
    assign MemWrite_M = MemWrite_M;
    assign ALUResult_M = ALUResult_M; // This is the Data Address
    assign WriteData_M = WriteData_M; // This is the Data to write

    // Branch/Jump Decision
    assign PCSrc_M = (Branch_M & Zero_M) | Jump_M;


//=================================================================
// MEM/WB PIPELINE REGISTER
//=================================================================
    logic [2:0] controls_M_out;
    assign controls_M_out = {ResultSrc_M, RegWrite_M};
    
    logic [2:0] controls_W;
    assign {ResultSrc_W, RegWrite_W} = controls_W;

    pipereg #(32+32+32+5+3) mem_wb_reg (
        .clk(clk), .reset(reset), 
        .en(1'b1), .flush(1'b0),
        .d({PCPlus4_M, ReadData_M, ALUResult_M, rd_M, controls_M_out}), 
        .q({PCPlus4_W, ReadData_W, ALUResult_W, rd_W, controls_W})
    );


//=================================================================
// 5. WB STAGE (Write Back)
//=================================================================

    // Result Mux: Select final data to write to register file
    mux3 #(32) resultmux(
        ALUResult_W,   // 00: ALU result (R-type, I-type)
        ReadData_W,    // 01: Data from memory (lw)
        PCPlus4_W,     // 10: PC+4 (jal)
        ResultSrc_W, 
        Result_W
    );

endmodule