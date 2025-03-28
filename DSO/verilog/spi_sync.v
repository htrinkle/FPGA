module spi_sync(
	input wire clk,
	input wire sck,
	input wire ncs,
	input wire mosi,
	output reg mosi_out,
	output wire spi_start,
	output wire spi_sck_rising,
	output wire spi_sck_falling,
	output wire spi_busy
);

reg [1:0] sck_buf = 0;
reg [1:0] ncs_buf = 0;
reg spi_busy_state = 0;

reg ncs_state;
reg sck_state;

wire next_ncs_state;
wire next_sck_state;
wire ncs_not_low;
wire sck_not_low;

wire ncs_low;
wire ncs_high;
wire sck_low;
wire sck_high;

////////////////////////////////////
// Assignments

// read/write strobes on sck transitions while ncs is asserted (low)
assign spi_sck_rising = (~sck_state & next_sck_state) & ~ncs_state;
assign spi_sck_falling = (sck_state & ~next_sck_state) & ~ncs_state;

// reset SPI module counters on ncs falling edge
assign spi_start = ncs_state & ~next_ncs_state;

// busy
assign spi_busy = spi_busy_state;

// Internal signals
assign ncs_not_low = |ncs_buf;
assign sck_not_low = |sck_buf;
assign ncs_high = &ncs_buf;
assign sck_high = &sck_buf;

// sck and ncs state machine
assign next_sck_state = sck_high | (sck_state & sck_not_low); 
assign next_ncs_state = ncs_high | (ncs_state & ncs_not_low); 

////////////////////////////////////
// Control

// spi_busy_state
// SPI is busy while ncs is low, and should remain busy for at least one clock cycle longer than de-bounced 
// ncs_low to allow SPI data to be latched after transmission.

always @(posedge clk)
begin
	if (~ncs) begin 
		spi_busy_state <= 1'b1;
	end else if (ncs_state & ~sck_state) begin 
		spi_busy_state <= 1'b0;
	end else begin
		spi_busy_state <= spi_busy_state;
	end
end

// sync SPI with internal clock F_SPI <= F_CLK/10
always @(posedge clk)
begin
	sck_buf <= {sck_buf[0], sck};
	ncs_buf <= {ncs_buf[0], ncs};
	mosi_out <= mosi;
end

// State of ncs and sck pins
always @(posedge clk)
begin
	sck_state <= next_sck_state;
	ncs_state <= next_ncs_state;
end

endmodule