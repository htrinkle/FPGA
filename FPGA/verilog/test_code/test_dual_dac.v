// Can use to test single or dual dac

module test_dual_dac(
    input wire clk,
    input wire button,
    output wire [2:0] led,
    output wire [7:0] dac_a_d,
    output wire [7:0] dac_b_d,
    output wire dac_a_c,
    output wire dac_b_c
);

localparam LedCtrWidth = $clog2(24_000_000 / 2);

reg [7:0] buf1, buf0;
wire [7:0] ramp;
wire [LedCtrWidth-1:0] led_q;
wire pll_clk;

// IO Assignments
assign dac_a_c = clk;
assign dac_b_c = clk;
assign dac_a_d = buf1;
assign dac_b_d = buf1;
assign led = led_q[LedCtrWidth-1 : LedCtrWidth-3];

// PLL
PLL pll_inst(.inclk0(clk), .c0(pll_clk));
// assign pll_clk = clk;  // bypass pl

// Ramp Counter 
counter_sr #(.Bits(8)) ramp_ctr(.clk(pll_clk), .sync_reset(~button), .q(ramp));

// LED Counter
counter_sr #(.Bits(LedCtrWidth)) led_ctr(.clk(clk), .sync_reset(~button), .q(led_q));

// Neg-edge triggered buffer for DAC data output
always @(negedge pll_clk)
begin
    {buf1, buf0} = {~buf0, ramp};
end

endmodule