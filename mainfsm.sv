module mainfsm(
    input  logic       clk, reset,
    input  logic [6:0] op,
    output logic [2:0] ImmSrc,
    output logic [1:0] ALUSrcA, ALUSrcB, ResultSrc,
    output logic       AdrSrc, IRWrite, PCUpdate, RegWrite, MemWrite, Branch,
    output logic [1:0] ALUOp
);

    // State definitions based on Table 1 and RISC-V multicycle flow
    typedef enum logic [3:0] {
        S0_FETCH, S1_DECODE, S2_MEMADR, S3_MEMREAD, S4_MEMWB, S5_MEMWRITE,
        S6_EXECUTER, S7_ALUWB, S8_EXECUTEI, S9_JAL, S10_BEQ
    } statetype;

    statetype state, nextstate;

    // --- State Register ---
    always_ff @(posedge clk or posedge reset)
        if (reset) state <= S0_FETCH;
        else       state <= nextstate;

    // --- Next State Logic ---
    always_comb
        case (state)
            S0_FETCH:   nextstate = S1_DECODE;
            S1_DECODE:  case(op)
                            7'b0000011: nextstate = S2_MEMADR;   // lw
                            7'b0100011: nextstate = S2_MEMADR;   // sw
                            7'b0110011: nextstate = S6_EXECUTER; // R-type
                            7'b0010011: nextstate = S8_EXECUTEI; // I-type (addi)
                            7'b1101111: nextstate = S9_JAL;      // jal
                            7'b1100011: nextstate = S10_BEQ;     // beq
                            default:    nextstate = S0_FETCH;
                        endcase
            S2_MEMADR:  if (op == 7'b0000011) nextstate = S3_MEMREAD;
                        else                  nextstate = S5_MEMWRITE;
            S3_MEMREAD:  nextstate = S4_MEMWB;
            S4_MEMWB:    nextstate = S0_FETCH;
            S5_MEMWRITE: nextstate = S0_FETCH;
            S6_EXECUTER: nextstate = S7_ALUWB;
            S7_ALUWB:    nextstate = S0_FETCH;
            S8_EXECUTEI: nextstate = S7_ALUWB;
            S9_JAL:      nextstate = S7_ALUWB;
            S10_BEQ:     nextstate = S0_FETCH;
            default:     nextstate = S0_FETCH;
        endcase

    // --- Output Logic (Control Signals) ---
    // Signals mapped according to Figure 1
    always_comb begin
        // Default values to ensure no latches are created
        {AdrSrc, IRWrite, RegWrite, MemWrite, PCUpdate, Branch} = 6'b0;
        {ALUSrcA, ALUSrcB, ResultSrc, ALUOp} = 8'b0;

        case (state)
            S0_FETCH: begin
                AdrSrc = 1'b0;     // Select PC as address
                IRWrite = 1'b1;    // Enable Instruction Register write
                ALUSrcA = 2'b00;   // SrcA = PC
                ALUSrcB = 2'b10;   // SrcB = 4
                ALUOp = 2'b00;     // Add
                ResultSrc = 2'b10; // Result = ALUResult
                PCUpdate = 1'b1;   // Trigger PC update
            end
            S1_DECODE: begin
                ALUSrcA = 2'b01;   // SrcA = OldPC
                ALUSrcB = 2'b01;   // SrcB = ImmExt
                ALUOp = 2'b00;     // Add (pre-calculate branch target)
            end
            S2_MEMADR: begin
                ALUSrcA = 2'b10;   // SrcA = Reg RD1
                ALUSrcB = 2'b01;   // SrcB = ImmExt
                ALUOp = 2'b00;     // Add (calculate memory address)
            end
            S3_MEMREAD: begin
                AdrSrc = 1'b1;     // Select ALUOut as address
                ResultSrc = 2'b00; 
            end
            S4_MEMWB: begin
                ResultSrc = 2'b01; // Result = Data from memory
                RegWrite = 1'b1;   // Write to register file
            end
            S5_MEMWRITE: begin
                AdrSrc = 1'b1;     // Select ALUOut as address
                MemWrite = 1'b1;   // Enable memory write
                ResultSrc = 2'b00; 
            end
            S6_EXECUTER: begin
                ALUSrcA = 2'b10;   // SrcA = Reg RD1
                ALUSrcB = 2'b00;   // SrcB = Reg RD2
                ALUOp = 2'b10;     // Logic defined by funct3/7
            end
            S7_ALUWB: begin
                ResultSrc = 2'b00; // Result = ALUOut
                RegWrite = 1'b1;   // Write to register file
            end
            S8_EXECUTEI: begin
                ALUSrcA = 2'b10;   // SrcA = Reg RD1
                ALUSrcB = 2'b01;   // SrcB = ImmExt
                ALUOp = 2'b10;     // Logic defined by funct3
            end
            S9_JAL: begin
                ALUSrcA = 2'b01;   // SrcA = OldPC
                ALUSrcB = 2'b10;   // SrcB = 4
                ALUOp = 2'b00;     // Add
                ResultSrc = 2'b00; // Result = ALUOut
                PCUpdate = 1'b1;   // Jump update
            end
            S10_BEQ: begin
                ALUSrcA = 2'b10;   // SrcA = Reg RD1
                ALUSrcB = 2'b00;   // SrcB = Reg RD2
                ALUOp = 2'b01;     // Subtract (for Zero comparison)
                ResultSrc = 2'b00;
                Branch = 1'b1;     // Enable branch logic
            end
        endcase
    end

    // --- Immediate Decoder ---
    // Logic for ImmSrc based on instruction type
    always_comb
        case(op)
            7'b0000011: ImmSrc = 3'b000; // I-type (lw)
            7'b0010011: ImmSrc = 3'b000; // I-type (addi)
            7'b0100011: ImmSrc = 3'b001; // S-type (sw)
            7'b0110011: ImmSrc = 3'bxxx; // R-type
            7'b1100011: ImmSrc = 3'b010; // B-type (beq)
            7'b1101111: ImmSrc = 3'b011; // J-type (jal)
            default:    ImmSrc = 3'b000;
        endcase

endmodule