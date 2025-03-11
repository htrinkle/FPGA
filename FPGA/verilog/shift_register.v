module shift_register #(
	parameter N = 8
)(
   // Control
	input wire clk,
	input wire sel, //implies shift on posedge clk
	input wire si,
	output wire so,
	input wire reset_flag,
	// Data
	output reg full,	
	input wire [N-1:0] data_in,
	output reg [N-1:0]  q
);

reg [N-1:0] sr;
reg [$clog2(N)-1:0] ctr;

assign so = sr[N-1];
assign latch = (ctr == (N-1));

// Counter
always @(posedge clk)
	if (reset_flag) begin
		ctr <= 0;
	end else if (sel & ~latch) begin
		ctr <= ctr + 1'b1;
	end else begin
		ctr <= ctr;
    end

// Shift Register
always @(posedge clk) begin
	if (reset_flag) begin
		sr <= data_in;  // Latch input into selected SR at start of SPI session
	end else if (sel & ~full) begin
		sr <= {sr[N-2:0], si}; // shift
    end else begin
        sr <= sr;
    end
end

// Output Latch
always @(posedge clk) q <= (latch & full) ? sr : q;

// Full latch
always @(posedge clk) begin
    if (reset_flag) begin
        full <= 1'b0;
    end else if (latch & sel) begin
        full <=1'b1;
    end else begin
        full <= full;
    end
end

endmodule