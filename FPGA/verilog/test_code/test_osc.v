module test_osc #(
	parameter OscF = 24_000_000
)(
	input wire clk,
	input wire button,
	output wire[2:0] led
);

localparam HalfOscF = OscF / 2;
localparam CtrWidth= $clog2(HalfOscF);

reg [CtrWidth-1:0] ctr; 
reg [2:0] led_buf;

assign led = led_buf;

always @(posedge clk) 
begin
	if (~button)
		ctr <= 0;
	else
		ctr <= (ctr == HalfOscF) ? 0 : ctr + 1'd1;
end

always @(posedge clk) 
begin
	if (~button)
		led_buf <= 3'd0;
	else
		led_buf <= (ctr == 0) ? led_buf + 1'd1 : led_buf;
end

endmodule