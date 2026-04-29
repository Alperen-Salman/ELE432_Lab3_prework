module top (
    input  logic        clk, reset,
    output logic [31:0] WriteData, DataAdr,
    output logic        MemWrite
);

    logic [31:0] ReadData;

    // Instantiate the RISC-V multicycle processor core
    riscv rv (clk, reset, DataAdr, WriteData, MemWrite, ReadData);

    // Instantiate the unified memory (Instruction + Data) 
    mem m (clk, MemWrite, DataAdr, WriteData, ReadData);

endmodule