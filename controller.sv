module controller(
    input  logic       clk, reset,
    input  logic [6:0] op,
    input  logic [2:0] funct3,
    input  logic       funct7b5,
    input  logic       Zero,
    output logic [2:0] ImmSrc,
    output logic [1:0] ALUSrcA, ALUSrcB,
    output logic [1:0] ResultSrc,
    output logic       AdrSrc,
    output logic [2:0] ALUControl,
    output logic       IRWrite, PCWrite, RegWrite, MemWrite
);

    logic [1:0] ALUOp;
    logic       Branch, PCUpdate;

    // Main Decoder FSM (Using NAMED mapping for safety)
    mainfsm fsm(
        .clk(clk), .reset(reset), .op(op),
        .ImmSrc(ImmSrc), .ALUSrcA(ALUSrcA), .ALUSrcB(ALUSrcB), .ResultSrc(ResultSrc),
        .AdrSrc(AdrSrc), .IRWrite(IRWrite), .PCUpdate(PCUpdate), 
        .RegWrite(RegWrite), .MemWrite(MemWrite), .Branch(Branch), .ALUOp(ALUOp)
    );

    // ALU Decoder
    aludec ad(op[5], funct3, funct7b5, ALUOp, ALUControl);

    // Branch logic for PCUpdate
    assign PCWrite = (Branch & Zero) | PCUpdate;

endmodule