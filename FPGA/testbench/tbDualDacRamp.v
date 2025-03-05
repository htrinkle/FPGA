`include "../verilog/COUNTER_SR.v"

module tbDualDacRamp();

reg button_press;
reg clk = 0;
wire [2:0] led_display;
wire [7:0] dac_a_d;
wire [7:0] dac_b_d;
wire dac_a_c;
wire dac_b_c;

COUNTER_SR #(.BITS(8)) dut1(.clk(clk), .sReset(button_press), .q(dac_a_d));
COUNTER_SR #(.BITS(8)) dut2(.clk(clk), .sReset(button_press), .q(dac_b_d));

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
    $dumpfile("tbDualDacRamp.vcd");
    $dumpvars(2, tbDualDacRamp);
end

// Clock
initial forever begin
  #5 clk <= ~clk;
end

endmodule