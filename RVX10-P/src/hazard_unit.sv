// src/hazard_unit.sv
// Detects load-use and control hazards
// Generates stall and flush signals

module hazard_unit(
    // Inputs from ID Stage
    input  logic [4:0]  rs1_D,
    input  logic [4:0]  rs2_D,

    // Inputs from ID/EX Register
    input  logic [4:0]  rd_E,
    input  logic        MemRead_E,

    // Inputs from MEM Stage
    input  logic        PCSrc_M, // (Branch_M & Zero_M) | Jump_M

    // Outputs to control the pipeline
    output logic        Stall_F,    // Stalls PC and IF/ID
    output logic        Flush_D,    // Flushes IF/ID (for branch)
    output logic        Flush_E     // Flushes ID/EX (for branch or load-use)
);

    // Load-Use Hazard Detection:
    // A load-use hazard occurs if an instruction in the EX stage
    // is a 'lw' (MemRead_E) and its destination register (rd_E)
    // is one of the source registers (rs1_D or rs2_D)
    // of the instruction *currently in the ID stage*.
    logic load_use_hazard;
    assign load_use_hazard = MemRead_E && (rd_E != 0) &&
                             ((rd_E == rs1_D) || (rd_E == rs2_D));

    // Stall PC and IF/ID registers if a load-use hazard is detected
    assign Stall_F = load_use_hazard;
    
    // Flush the instruction in the EX stage (to inject a NOP)
    // and also flush for a taken branch
    assign Flush_E = load_use_hazard || PCSrc_M;

    // Flush the (wrongly fetched) instruction in the ID stage
    // only when a branch is taken.
    assign Flush_D = PCSrc_M;

endmodule