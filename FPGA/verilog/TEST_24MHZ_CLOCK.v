module TEST_24MHZ_CLOCK ( 
    input wire clk,
    input wire button,
    output wire[2:0] led
);

localparam OSC_F = 24_000_000;
localparam HALF_OSC_F = OSC_F / 2;
localparam CTR_WIDTH = $clog2(HALF_OSC_F);

reg [CTR_WIDTH-1:0] ctr; 
reg [2:0] ledBuf;

assign led = ~ledBuf;

always @(posedge clk) 
begin
	ctr <= (ctr == HALF_OSC_F) ? 0 : ctr + 1'd1;
end

always @(posedge clk) 
begin
	if (~button)
		ledBuf <= 3'd0;
	else
		ledBuf <= (ctr == 0) ? ledBuf + 1'd1 : ledBuf;
end

endmodule