module COUNTER_SR #(
	parameter BITS = 8
)(
	input wire clk,
	input wire sReset,
	output reg [BITS-1:0] q,
	output wire carry
);

assign carry = &q;

always @(posedge clk)
begin
    q <= (sReset) ? 0 : q + 1'd1;
end

endmodule