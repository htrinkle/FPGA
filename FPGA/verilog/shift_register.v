module shift_register #(
	parameter N = 8
)(
   // Control
	input wire clk,
	input wire sel,
	input wire rising,
	input wire falling,
	input wire si,
	input wire reset_flag,	 // reset SR and load data to tx
	output wire so,
	output wire done_strobe, // 1 for one clock when SR filled
	output wire done,		 // 1 if SR full, cleared on reset

	// Data
	input wire [N-1:0] data_in,
	output wire [N-1:0]  data_out
);

localparam CtrWidth = $clog2(N);

reg [N-1:0] sr;
reg [CtrWidth:0] ctr;
reg in_buf;

assign so = sr[N-1];
assign done = (ctr == N+1);
assign done_strobe = (ctr == N);
assign data_out = sr;

// Serial input buffer - read on rising edge
always @(posedge clk) begin
	if (sel & rising ) begin
		in_buf <= si;
	end else begin
		in_buf <= in_buf;
	end
end

// Shift Register - shift on falling edge
always @(posedge clk) begin
	if (reset_flag) begin
		sr <= data_in;  // load SR at start of SPI session with data to tx
		ctr <= 0;		// reset counter
	end else if (sel & falling & ~done) begin
		sr <= {sr[N-2:0], in_buf}; // shift in received data
		ctr <= ctr + 1'b1;
    end else begin
        sr <= sr;
		ctr <= (done_strobe) ? N+1 : ctr; // ctr == N only exists for one clock cycle
    end
end

endmodule