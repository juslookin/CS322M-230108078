module alu(input  logic [31:0] a, b,
           input  logic [4:0]  alucontrol,
           output logic [31:0] result,
           output logic        zero);

  logic [31:0] condinvb, sum;
  logic        v;              // overflow
  logic        isAddSub;       // true when is add or subtract operation

  wire signed [31:0] sa = a;
  wire signed [31:0] sb = b;
  wire [4:0] sh = b[4:0];


  localparam [4:0]
    ALU_ADD   = 5'b00000,
    ALU_SUB   = 5'b00001,
    ALU_AND   = 5'b00010,
    ALU_OR    = 5'b00011,
    ALU_XOR   = 5'b00100,
    ALU_SLT   = 5'b00101,
    ALU_SLL   = 5'b00110,
    ALU_SRL   = 5'b00111,
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


  assign condinvb = alucontrol[0] ? ~b : b;
  assign sum = a + condinvb + alucontrol[0];
  assign isAddSub = ~alucontrol[2] & ~alucontrol[1] |
                    ~alucontrol[1] & alucontrol[0];

  always_comb
    case (alucontrol)
      ALU_ADD:   result = sum; 
      ALU_SUB:   result = sum;       
      ALU_AND:   result = a & b;
      ALU_OR:    result = a | b;
      ALU_XOR:   result = a ^ b;
      ALU_SLT:   result = {31'b0, (sa < sb)};   
      ALU_SLL:   result = a << sh;
      ALU_SRL:   result = a >> sh;

      // RVX10
      ALU_ANDN:  result = a & ~b;
      ALU_ORN:   result = a | ~b;
      ALU_XNOR:  result = ~(a ^ b);
      ALU_MIN:   result = (sa < sb) ? a : b;
      ALU_MAX:   result = (sa > sb) ? a : b;
      ALU_MINU:  result = (a < b) ? a : b;
      ALU_MAXU:  result = (a > b) ? a : b;
      ALU_ROL:   result = (sh == 5'd0) ? a : ((a << sh) | (a >> (32 - sh)));
      ALU_ROR:   result = (sh == 5'd0) ? a : ((a >> sh) | (a << (32 - sh)));
      ALU_ABS:   result = (sa >= 0) ? a : (32'(0) - a);

      default:   result = 32'bx;
    endcase

  assign zero = (result == 32'b0);
  assign v = ~(alucontrol[0] ^ a[31] ^ b[31]) & (a[31] ^ sum[31]) & isAddSub;
  
endmodule