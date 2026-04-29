// 2-way Multiplexer
module mux2 #(parameter WIDTH = 8) (
    input  logic [WIDTH-1:0] d0, d1,
    input  logic             s,
    output logic [WIDTH-1:0] y
);
    assign y = s ? d1 : d0;
endmodule

// 3-way Multiplexer
module mux3 #(parameter WIDTH = 8) (
    input  logic [WIDTH-1:0] d0, d1, d2,
    input  logic [1:0]       s,
    output logic [WIDTH-1:0] y
);
    assign y = (s == 2'b00) ? d0 :
               (s == 2'b01) ? d1 : d2;
endmodule

// Resettable Flip-Flop
module flopr #(parameter WIDTH = 8) (
    input  logic             clk, reset,
    input  logic [WIDTH-1:0] d,
    output logic [WIDTH-1:0] q
);
    always_ff @(posedge clk, posedge reset)
        if (reset) q <= 0;
        else       q <= d;
endmodule

// Resettable Flip-Flop with Enable
module flopenr #(parameter WIDTH = 8) (
    input  logic             clk, reset, en,
    input  logic [WIDTH-1:0] d,
    output logic [WIDTH-1:0] q
);
    always_ff @(posedge clk, posedge reset)
        if (reset)   q <= 0;
        else if (en) q <= d;
endmodule