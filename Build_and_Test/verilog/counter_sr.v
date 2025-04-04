module counter_sr #(
	parameter Bits = 8
)(
	input wire clk,
	input wire sync_reset,
	output reg [Bits-1:0] q,
	output wire carry
);

assign carry = &q;

always @(posedge clk)
begin
    q <= (sync_reset) ? 0 : q + 1'd1;
end

endmodule