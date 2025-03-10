`include "../verilog/SPI_MODULE.v"
`include "../verilog/SPI_SYNC.v"
`include "../verilog/SR.v"

module tbSpi();

wire miso;

reg clk = 0;
reg mosi = 0;
reg sck = 0;
reg nCS = 1;


SPI_MODULE dut (
	.clk(clk),
	.sck(sck),
	.mosi(mosi),
	.ncs(nCS),
	.miso(miso)
);

reg [31:0] tx_data = 0;
reg [31:0] rx_data = 0;
reg [7:0] tx_cmd = 0;
reg [7:0] rx_stat = 0;
integer i;
wire [31:0] q0, q1;



initial begin 
  $dumpfile("tbSpi.vcd");
  $dumpvars(3, tbSpi);
  #10 $display("init");
  
  #1 clk = 0;
  #1 mosi = 0;
  #1 nCS = 1;
  #1 sck = 0;
  #10 $display("hello");
  #10
  
  // SPI(32)
  tx_cmd = 8'hb0;
  tx_data = 32'h24af55aa;
  $display("Printing %2x %8X", tx_cmd, tx_data);
  #1 nCS = 0;
  for (i=0; i<8; i++) begin
	mosi = tx_cmd[7-i];
	#137 sck = 1;
	rx_stat = {rx_stat[7:0], miso};
	#137 sck = 0;
  end
  for (i=0; i<32; i++) begin
	mosi = tx_data[31-i];
	#137 sck = 1;
	rx_data = {rx_data[30:0], miso};
	#137 sck = 0;
  end
  nCS = 1;
  $display("Received %2x %08x", rx_stat, rx_data);
  
  // Delay
  #47
  
  // SPI(32)
  tx_cmd = 8'h51;
  tx_data = 32'h01234567;
  $display("Printing %2x %8X", tx_cmd, tx_data);
  #1 nCS = 0;
  for (i=0; i<8; i++) begin
	mosi = tx_cmd[7-i];
	#137 sck = 1;
	rx_stat = {rx_stat[7:0], miso};
	#137 sck = 0;
  end
  for (i=0; i<32; i++) begin
	mosi = tx_data[31-i];
	#137 sck = 1;
	rx_data = {rx_data[30:0], miso};
	#137 sck = 0;
  end
  nCS = 1;
  $display("Received %2x %08x", rx_stat, rx_data);
  
  #2000 $finish;
end

initial forever begin
  #5 clk <= ~clk;
end

endmodule
