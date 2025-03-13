module spi_module(
	input wire clk,
	input wire sck,
	input wire mosi,
	input wire ncs,
	input wire [15:0] mem_data,
	output wire miso,
	output wire [7:0] q_c,
	output wire [31:0] q_0,
	output wire [31:0] q_1,
	output wire [11:0] mem_addr
);

localparam Reg0 = 2'd0;
localparam Reg1 = 2'd1;
localparam RegM = 2'd2;

// SPI wiring
wire mosi_o;
wire rst;
wire rd;
wire wr;

wire miso_c, miso_0, miso_1, miso_m;
wire sel_c, sel_0, sel_1, sel_m;

// Control Signals 
wire [1:0] addr;
wire write_enable;

// Internal Shift Register Wiring
wire [7:0] sr_control_out;
wire [31:0] sr_32_0_out;
wire [31:0] sr_32_1_out;
wire sr_control_done, sr_32_0_done, sr_32_1_done; 
wire sr_control_done_strobe, sr_32_0_done_strobe, sr_32_1_done_strobe; 

// Break out control signals
assign {write_enable, addr} = sr_control_out[2:0];
// Shift Register Select Lines
assign sel_c = rd & ~sr_control_done;
assign sel_0 = rd & sr_control_done & (addr == Reg0);
assign sel_1 = rd & sr_control_done & (addr == Reg1);
assign sel_m = rd & sr_control_done & (addr == RegM);

// MISO Multiplexing
assign miso = (~sr_control_done) ? miso_c : 
				(addr == Reg0) ? miso_0 : 
				(addr == Reg1) ? miso_1 : 
				(addr == RegM) ? miso_m : 1'b0;

assign q_c = sr_control_out;

// SPI SCK sync to internal clock
spi_sync spi_sync_inst(
	.clk(clk),
	.sck(sck),
	.ncs(ncs),
	.mosi(mosi),
	.mosi_out(mosi_o),
	.spi_reset(rst), 
	.spi_read(rd),
	.spi_write(wr)
);

// Shift register for control word
shift_register #(.N(8)) sr_ctrl (
	.clk(clk),

    // Control
	.sel(sel_c),
	.si(mosi_o),
	//.write_enable(1'b1),
	.reset_flag(rst),
	.so(miso_c),
	.done(sr_control_done),

	// Data
	.data_in({sr_control_out[7:4], 4'ha}),
	.data_out(sr_control_out)
);

shift_register #(.N(32)) sr_32_0 (
	.clk(clk),

    // Control
	.sel(sel_0),
	.si(mosi_o),
	.so(miso_0),
	.reset_flag(rst),
	.done_strobe(sr_32_0_done_strobe),
	// Data	
	.data_in(q_0),
	.data_out(sr_32_0_out)
);

register #(.N(32)) r_32_0 (
	.clk(clk),	
	.write_enable(write_enable & sr_32_0_done_strobe),	
	.data_in(sr_32_0_out),	
	.q(q_0)
);

shift_register #(.N(32)) sr_32_1 (
	.clk(clk),

    // Control
	.sel(sel_1),
	.si(mosi_o),
	.so(miso_1),
	.reset_flag(rst),
	.done_strobe(sr_32_1_done_strobe),
	// Data	
	.data_in(q_1),
	.data_out(sr_32_1_out)
);

register #(.N(32)) r_32_1 (
	.clk(clk),	
	.write_enable(write_enable & sr_32_1_done_strobe),	
	.data_in(sr_32_1_out),	
	.q(q_1)
);

spi_mem_controller mem_cont_inst(
	.clk(clk),

    // Control
	.sel(sel_m),
	.si(mosi_o),
	.so(miso_m),
	.reset_flag(rst),

	// Data	
	.data(mem_data),
	.addr(mem_addr)
);

endmodule