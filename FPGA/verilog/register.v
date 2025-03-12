module register #(
	parameter N = 8
)(
   // Control
	input wire clk,
	input wire write_enable,
	// Data
	input wire [N-1:0] data_in,
	output reg [N-1:0]  q
);

always @(posedge clk) begin
    q <= (write_enable) ? data_in : q;
end

endmodule