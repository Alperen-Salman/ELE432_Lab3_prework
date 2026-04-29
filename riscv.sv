module riscv (
    input  logic        clk, reset,
    output logic [31:0] Adr, WriteData,
    output logic        MemWrite,
    input  logic [31:0] ReadData
);

    // Internal Control Wires between Controller and Datapath
    logic [1:0]  ResultSrc, ALUSrcA, ALUSrcB;
    logic [2:0]  ALUControl, ImmSrc;
    logic        RegWrite, PCWrite, AdrSrc, IRWrite;
    logic        Zero;
    logic [31:0] Instr;

    // Instantiate the Controller (FSM)
    controller c (
        clk, reset,
        Instr[6:0], Instr[14:12], Instr[30], // op, funct3, funct7
        Zero,
        ImmSrc, ALUSrcA, ALUSrcB, ResultSrc,
        AdrSrc, ALUControl, IRWrite, PCWrite, RegWrite, MemWrite
    );

    // Instantiate the Datapath (Hardware blocks)
    datapath dp (
        clk, reset,
        ImmSrc, ALUSrcA, ALUSrcB, ResultSrc,
        AdrSrc, ALUControl, IRWrite, PCWrite, RegWrite,
        Zero, Instr, Adr, WriteData, ReadData
    );

endmodule