module alu(
    input  logic [31:0] a, b,
    input  logic [2:0]  alucontrol,
    output logic [31:0] result,
    output logic        zero
);

    logic [31:0] condinvb, sum;
    logic        v;              // overflow
    logic        isAddSub;       // true of addition or subtraction

    assign condinvb = alucontrol[0] ? ~b : b;
    assign sum = a + condinvb + alucontrol[0];
    assign isAddSub = ~alucontrol[2] & ~alucontrol[1] |
                      ~alucontrol[2] & alucontrol[0];

    always_comb
        case (alucontrol)
            3'b000:  result = sum;               // add
            3'b001:  result = sum;               // subtract
            3'b010:  result = a & b;             // and
            3'b011:  result = a | b;             // or
            3'b101:  result = sum[31];           // slt
            default: result = 32'bx;
        endcase

    assign zero = (result == 32'b0);
endmodule