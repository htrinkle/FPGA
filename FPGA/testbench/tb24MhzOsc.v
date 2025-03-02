
`include "../verilog/TEST_24MHZ_CLOCK.v"

module tbBoardTest();

reg button_press;
reg clk;
wire [2:0] led_display;

TEST_24MHZ_CLOCK #(.OSC_F(5)) dut(.clk(clk), .button(button_press), .led(ed_display));

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
    $dumpfile("tbBoardTest.vcd");
    $dumpvars(2, tbBoardTest);
end

// Clock
initial forever begin
  #5 clk <= ~clk;
end

endmodule