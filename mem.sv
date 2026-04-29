module mem (
    input  logic        clk, we,
    input  logic [31:0] a, wd,
    output logic [31:0] rd
);

    logic [31:0] RAM[63:0];

    // Load the machine code file
    initial
        $readmemh("riscvtest.txt", RAM);

    // Read logic: Word aligned (ignores bottom two bits)
    assign rd = RAM[a[31:2]]; 

    // Synchronous write logic
    always_ff @(posedge clk)
        if (we) RAM[a[31:2]] <= wd;

endmodule