`include "../verilog/COUNTER_SR.v"
`include "../verilog/TEST_DUAL_DAC.v"

module tbTestDualDac();

reg button_press;
reg clk = 0;
wire [2:0] led_display;
wire [7:0] dac_a_d;
wire [7:0] dac_b_d;
wire dac_a_c;
wire dac_b_c;

TEST_DUAL_DAC dut1(
  .clk(clk), 
  .button(~button_press), 
  .led(led_display), 
  .dac_a_d(dac_a_d), 
  .dac_b_d(dac_b_d),
  .dac_a_c(dac_a_c), 
  .dac_b_c(dac_b_c)
);

initial begin
    $display("Starting");
    button_press = 1'b0;
    # 100
    button_press = 1'b1;
    # 100
    button_press = 1'b0;
    # 10000
    $finish;
    $display("Finished");
end

// Setup Dump File
initial begin
    $dumpfile("tbTestDualDac.vcd");
    $dumpvars(2, tbTestDualDac);
end

// Clock
initial forever begin
  #5 clk <= ~clk;
end

endmodule