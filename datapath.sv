module datapath (
    input  logic        clk, reset,
    input  logic [2:0]  ImmSrc,
    input  logic [1:0]  ALUSrcA, ALUSrcB,
    input  logic [1:0]  ResultSrc,
    input  logic        AdrSrc,
    input  logic [2:0]  ALUControl,
    input  logic        IRWrite, PCWrite, RegWrite,
    output logic        Zero,
    output logic [31:0] Instr,
    output logic [31:0] Adr, WriteData,
    input  logic [31:0] ReadData
);

    logic [31:0] PC, OldPC;
    logic [31:0] Data, RD1, RD2, A, SrcA, SrcB;
    logic [31:0] ALUResult, ALUOut, Result, ImmExt;

    // --- Memory and Instruction Logic ---
    
    // PC Register: Updates only when PCWrite is high
    flopenr #(32) pcreg(clk, reset, PCWrite, Result, PC);

    // Address Mux: Selects between PC (Fetch) and Result (Mem Access)
    mux2 #(32)   adrmux(PC, Result, AdrSrc, Adr);

    // Instruction Register: Captures new instruction from memory
    flopenr #(32) ir(clk, reset, IRWrite, ReadData, Instr);
    flopenr #(32) oldpcreg(clk, reset, IRWrite, PC, OldPC);

    // Data Register: Buffer for data read from memory
    flopr #(32)  datareg(clk, reset, ReadData, Data);

    // --- Register File and Extend Logic ---
    
    regfile      rf(clk, RegWrite, Instr[19:15], Instr[24:20], 
                    Instr[11:7], Result, RD1, RD2);
                    
    extend       ext(Instr[31:7], ImmSrc, ImmExt);

    // Pipelines registers to hold values for the Execute stage
    flopr #(32)  areg(clk, reset, RD1, A);
    flopr #(32)  wdreg(clk, reset, RD2, WriteData);

    // --- ALU Logic ---
    
    // ALUSrcA Mux: Selects PC, OldPC, or Register A
    mux3 #(32)   srcamux(PC, OldPC, A, ALUSrcA, SrcA);

    // ALUSrcB Mux: Selects Register B (WriteData), ImmExt, or constant 4
    mux3 #(32)   srcbmux(WriteData, ImmExt, 32'd4, ALUSrcB, SrcB);

    alu          alu_inst(SrcA, SrcB, ALUControl, ALUResult, Zero);
    
    // ALUOut register: Stores ALU result for use in a later cycle
    flopr #(32)  aluoutreg(clk, reset, ALUResult, ALUOut);

    // --- Result Logic ---
    
    // ResultSrc Mux: Final value to be written to PC or RegFile
    mux3 #(32)   resmux(ALUOut, Data, ALUResult, ResultSrc, Result);

endmodule