module dds #(
	parameter AW = 8
)(
	input wire clk,
	input wire [31:0] cfg,
	input wire [7:0] tbl_data,
	output wire [AW-1:0] tbl_addr,
	output wire [7:0] q
);

	// Phase Accumulator Width
	localparam PhaseAccW = 32;

	// configuration wiring
	wire [29:0] phace_inc;
	wire dds_on;
	wire dds_inv;

	// Phase Accumulator
	reg [PhaseAccW-1:0] phase;

	// Data Output Buffer
	reg [7:0] q_buf;

	// Assignments
	assign tbl_addr = phase[PhaseAccW-1:PhaseAccW-AW];
	assign {dds_on, dds_inv, phase_inc} = cfg;

	// Phase accumulator state machine
	always @(posedge clk) phase <= phase + phase_inc;

	// Data state machine
	// There will be a clk period lag between tbl_addr and tbl_data and again q_buf
	always @(posedge clk) begin
		if (dds_on) begin
			q_buf <= (dds_inv) ? ~tbl_data : tbl_data;
		end else begin
			q_buf <= 8'h80;
		end
	end

endmodule