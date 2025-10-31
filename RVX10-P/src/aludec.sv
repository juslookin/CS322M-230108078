module aludec(input  logic [6:0] op,
              input  logic [2:0] funct3,
              input  logic [6:0] funct7,
              input  logic [1:0] ALUOp,
              output logic [4:0] ALUControl);

  // ALUControl encoding (5 bits)
  localparam [4:0]
    ALU_ADD   = 5'b00000,
    ALU_SUB   = 5'b00001,
    ALU_AND   = 5'b00010,
    ALU_OR    = 5'b00011,
    ALU_XOR   = 5'b00100,
    ALU_SLT   = 5'b00101,
    ALU_SLL   = 5'b00110,
    ALU_SRL   = 5'b00111,

    // RVX10 custom encodings
    ALU_ANDN  = 5'b01000,
    ALU_ORN   = 5'b01001,
    ALU_XNOR  = 5'b01010,
    ALU_MIN   = 5'b01011,
    ALU_MAX   = 5'b01100,
    ALU_MINU  = 5'b01101,
    ALU_MAXU  = 5'b01110,
    ALU_ROL   = 5'b01111,
    ALU_ROR   = 5'b10000,
    ALU_ABS   = 5'b10001;

  localparam [6:0] OPC_CUSTOM0 = 7'b0001011;

  logic RtypeSub;
  assign RtypeSub = funct7[5] & op[5];  // TRUE for R-type subtract instruction

  always_comb begin
    ALUControl = 5'bxxxxx;
    case(ALUOp)
      2'b00: ALUControl = ALU_ADD;  
      2'b01: ALUControl = ALU_SUB;  
      default: begin
        // R-type standard instructions or CUSTOM-0
        if (op == OPC_CUSTOM0) begin
          unique case (funct7) 
            7'b0000000: begin
              case (funct3)
                3'b000: ALUControl = ALU_ANDN;
                3'b001: ALUControl = ALU_ORN;
                3'b010: ALUControl = ALU_XNOR;
                default: ALUControl = 5'bxxxxx;
              endcase
            end
            7'b0000001: begin
              case (funct3)
                3'b000: ALUControl = ALU_MIN;   
                3'b001: ALUControl = ALU_MAX;  
                3'b010: ALUControl = ALU_MINU;  
                3'b011: ALUControl = ALU_MAXU;  
                default: ALUControl = 5'bxxxxx;
              endcase
            end
            7'b0000010: begin
              case (funct3)
                3'b000: ALUControl = ALU_ROL;
                3'b001: ALUControl = ALU_ROR;
                default: ALUControl = 5'bxxxxx;
              endcase
            end
            7'b0000011: begin
              case (funct3)
                3'b000: ALUControl = ALU_ABS;
                default: ALUControl = 5'bxxxxx;
              endcase
            end
            default: ALUControl = 5'bxxxxx;
          endcase
        end else begin
          case(funct3)
            3'b000: if (RtypeSub) ALUControl = ALU_SUB; else ALUControl = ALU_ADD;
            3'b010: ALUControl = ALU_SLT;
            3'b110: ALUControl = ALU_OR; 
            3'b111: ALUControl = ALU_AND;
            3'b100: ALUControl = ALU_XOR;
            default: ALUControl = 5'bxxxxx;
          endcase
        end
      end
    endcase
  end
endmodule