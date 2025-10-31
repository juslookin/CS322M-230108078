// This module connects your pipelined core to the memories.
// It replaces the 'top' module from your old riscvsingle.sv.

module top(input  logic        clk, reset, 
           output logic [31:0] WriteData, DataAdr, 
           output logic        MemWrite);

    // Internal wires connecting components
    logic [31:0] PC, Instr;
    logic [31:0] ReadData;
    logic [31:0] ALUResult_M, WriteData_M; // Outputs from pipeline
    logic        MemWrite_M;

    // Instantiate the 5-stage pipelined core
    // (This module will be in src/riscvpipeline.sv)
    riscvpipeline core (
        .clk(clk), .reset(reset),
        
        // Instruction memory interface
        .PC(PC), 
        .Instr(Instr),
        
        // Data memory interface
        .MemWrite(MemWrite_M),
        .ALUResult_M(ALUResult_M), // This is the address
        .WriteData_M(WriteData_M), // This is the data to write
        .ReadData_M(ReadData)
    );

    // Instantiate memories
    // (These modules will be in tb/imem.sv and tb/dmem.sv)
    imem imem(PC, Instr);
    dmem dmem(clk, MemWrite_M, ALUResult_M, WriteData_M, ReadData);

    // Assign internal signals to top-level outputs for the testbench
    // The testbench needs to see the final memory signals.
    assign MemWrite  = MemWrite_M;
    assign DataAdr   = ALUResult_M; // The ALU result is the address for lw/sw
    assign WriteData = WriteData_M; // This is the data being written

endmodule
