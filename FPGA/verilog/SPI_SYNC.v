module spi_sync(
	input wire clk,
	input wire sck,
	input wire ncs,
	input wire mosi,
	output reg mosi_out,
	output wire spi_reset, 
	output wire spi_read,
	output wire spi_write
);

reg [1:0] sck_buf;
reg [1:0] ncs_buf;
reg ncs_state;
reg sck_state;

wire next_ncs_state;
wire next_sck_state;

wire ncs_low;
wire ncs_high;
wire sck_low;
wire sck_high;

////////////////////////////////////
// Assignments

// Internal signals
assign ncs_not_low = |ncs_buf;
assign sck_not_low = |sck_buf;
assign ncs_high = &ncs_buf;
assign sck_high = &sck_buf;

// sck and ncs state machine
assign next_sck_state = sck_high | (sck_state & sck_not_low); 
assign next_ncs_state = ncs_high | (ncs_state & ncs_not_low); 

// read/write strobes on sck transitions while ncs is asserted (low)
assign spi_read = (~sck_state & next_sck_state) & ~ncs_state;
assign spi_write = (sck_state & ~next_sck_state) & ~ncs_state;

// reset SPI module counters on ncs falling edge
assign spi_reset = ncs_state & ~next_ncs_state;

////////////////////////////////////
// Control

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