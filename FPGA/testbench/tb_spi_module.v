`include "../verilog/spi_module.v"
`include "../verilog/spi_sync.v"
`include "../verilog/shift_register.v"
`include "../verilog/register.v"
`include "../verilog/spi_mem_controller.v"

module tb_spi_module();

wire miso;

reg clk = 0;
reg mosi = 0;
reg sck = 0;
reg nCS = 1;

wire [7:0] q_c;
wire [31:0] q_0, q_1;
wire [15:0] mem_sim;

assign mem_sim[15:12] = 4'hE;

spi_module dut (
	.clk(clk),
	.sck(sck),
	.mosi(mosi),
	.ncs(nCS),
	.miso(miso),
  .data_in_1({16'hbabe, q_0[15:0]}),
  .q_c(q_c),
	.q_0(q_0),
	.q_1(q_1),
  .mem_data(mem_sim),
  .mem_addr(mem_sim[11:0])
);

reg [31:0] tx_data = 0;
reg [31:0] rx_data = 0;
reg [7:0] tx_cmd = 0;
reg [7:0] rx_stat = 0;
integer i, j;
wire [31:0] q0, q1;



initial begin 
  $dumpfile("tb_spi_module.vcd");
  $dumpvars(3, tb_spi_module);
  #10 $display("init");
  
  #1 clk = 0;
  #1 mosi = 0;
  #1 nCS = 1;
  #1 sck = 0;
  #10 $display("hello");
  #10
  
  // SPI REG0, no Write
  tx_cmd = 8'ha4; 
  tx_data = 32'h24af55aa;
  $display("Send %2x %8X", tx_cmd, tx_data);
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
  #44
  
  // SPI REG1, Write
  tx_cmd = 8'h55;
  tx_data = 32'h01234567;
  $display("Send %2x %8X", tx_cmd, tx_data);
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
  #44

// REG0
  tx_cmd = 8'ha4;
  tx_data = 32'h01010101;
  $display("Send %2x %8X", tx_cmd, tx_data);
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
  #44
  
  // SPI(32)
  tx_cmd = 8'h51;
  tx_data = 32'h01010202;
  $display("Send %2x %8X", tx_cmd, tx_data);
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

  #44

  // MEM Access

  // SPI Memory
  tx_cmd = 8'h02;
  tx_data = 16'h0;
  $display("Send %2x (mem)", tx_cmd);
  #1 nCS = 0;
  for (i=0; i<8; i++) begin
    mosi = tx_cmd[7-i];
    #137 sck = 1;
    rx_stat = {rx_stat[7:0], miso};
    #137 sck = 0;
  end
  for (j=0; j<16; j++) begin
    for (i=0; i<16; i++) begin
      mosi = tx_data[31-i];
      #137 sck = 1;
      rx_data = {rx_data[30:0], miso};
      #137 sck = 0;
    end
    $display("ID %04d Rx Data %04x", j, rx_data[15:0]);
  end


  #1 nCS = 1;
  $display("Received %2x %08x", rx_stat, rx_data);

  #200 $finish;
end

initial forever begin
  #5 clk <= ~clk;
end

endmodule
