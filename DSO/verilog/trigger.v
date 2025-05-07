module trigger (
    input wire clk,
    input wire signed [7:0] signal,
    input wire signed [7:0] level,
    input wire rising_edge,
    output wire edge_flag
);

wire compare;
reg [2:0] q;

assign compare = (rising_edge) ? signal > level : signal < level;
assign edge_flag = ~|q & compare;

always @(posedge clk) q <= {q[1:0], compare};

endmodule