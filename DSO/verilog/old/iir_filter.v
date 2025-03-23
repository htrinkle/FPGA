module IIR_Filter #(
	parameter N = 8
)(
	input wire clk,
	input wire select,
	input wire [N-1:0] data_in,
	output wire [N-1:0] data_out
);

wire [N+1:0] sum;
assign data_out = sum[N+1:2];
assign sum = q0[N+1:2] + q0[N+1:1] + data_in;

reg [N+1:0] q0;

always @(posedge clk)
		q0 <= (select) ? sum : {data_in, 1'b0};

endmodule