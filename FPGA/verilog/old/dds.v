module dds(
	input wire clk,
	input wire[1:0] mode,
	input wire[29:0] phase_inc,
	output reg[7:0] q
);

reg [31:0] phase;
wire [7:0] lutSinWire;

lutSin sin_tbl(.count(phase[31:24]), .phase(lutSinWire));
//reg [7:0] sin_tbl[0:255];

//initial begin
//	 $readmemh("../python/sin_tbl.txt", sin_tbl);
//end

always @(posedge clk)
	phase <= phase + phase_inc;
	
always @(posedge clk)
	if (mode == 2'b00) // ramp
		q <= phase[31:24];
	else if (mode == 2'b01) // square
		q <= (phase[31] ? 8'hFF : 8'h00);
	else if (mode == 2'b10) // sin
		q <= lutSinWire;
	else
		q <= 8'd128;

endmodule

module lutSin(
	input wire [7:0] count,
	output reg [7:0] phase
);

always @*
	case(count)
		8'b00000000: phase = 8'b10000000;
		8'b00000001: phase = 8'b10000011;
		8'b00000010: phase = 8'b10000110;
		8'b00000011: phase = 8'b10001001;
		8'b00000100: phase = 8'b10001101;
		8'b00000101: phase = 8'b10010000;
		8'b00000110: phase = 8'b10010011;
		8'b00000111: phase = 8'b10010110;
		8'b00001000: phase = 8'b10011001;
		8'b00001001: phase = 8'b10011100;
		8'b00001010: phase = 8'b10011111;
		8'b00001011: phase = 8'b10100010;
		8'b00001100: phase = 8'b10100101;
		8'b00001101: phase = 8'b10101000;
		8'b00001110: phase = 8'b10101011;
		8'b00001111: phase = 8'b10101110;
		8'b00010000: phase = 8'b10110001;
		8'b00010001: phase = 8'b10110100;
		8'b00010010: phase = 8'b10110111;
		8'b00010011: phase = 8'b10111010;
		8'b00010100: phase = 8'b10111100;
		8'b00010101: phase = 8'b10111111;
		8'b00010110: phase = 8'b11000010;
		8'b00010111: phase = 8'b11000100;
		8'b00011000: phase = 8'b11000111;
		8'b00011001: phase = 8'b11001010;
		8'b00011010: phase = 8'b11001100;
		8'b00011011: phase = 8'b11001111;
		8'b00011100: phase = 8'b11010001;
		8'b00011101: phase = 8'b11010100;
		8'b00011110: phase = 8'b11010110;
		8'b00011111: phase = 8'b11011000;
		8'b00100000: phase = 8'b11011011;
		8'b00100001: phase = 8'b11011101;
		8'b00100010: phase = 8'b11011111;
		8'b00100011: phase = 8'b11100001;
		8'b00100100: phase = 8'b11100011;
		8'b00100101: phase = 8'b11100101;
		8'b00100110: phase = 8'b11100111;
		8'b00100111: phase = 8'b11101001;
		8'b00101000: phase = 8'b11101010;
		8'b00101001: phase = 8'b11101100;
		8'b00101010: phase = 8'b11101110;
		8'b00101011: phase = 8'b11101111;
		8'b00101100: phase = 8'b11110001;
		8'b00101101: phase = 8'b11110010;
		8'b00101110: phase = 8'b11110100;
		8'b00101111: phase = 8'b11110101;
		8'b00110000: phase = 8'b11110110;
		8'b00110001: phase = 8'b11110111;
		8'b00110010: phase = 8'b11111001;
		8'b00110011: phase = 8'b11111010;
		8'b00110100: phase = 8'b11111010;
		8'b00110101: phase = 8'b11111011;
		8'b00110110: phase = 8'b11111100;
		8'b00110111: phase = 8'b11111101;
		8'b00111000: phase = 8'b11111110;
		8'b00111001: phase = 8'b11111110;
		8'b00111010: phase = 8'b11111111;
		8'b00111011: phase = 8'b11111111;
		8'b00111100: phase = 8'b11111111;
		8'b00111101: phase = 8'b11111111;
		8'b00111110: phase = 8'b11111111;
		8'b00111111: phase = 8'b11111111;
		8'b01000000: phase = 8'b11111111;
		8'b01000001: phase = 8'b11111111;
		8'b01000010: phase = 8'b11111111;
		8'b01000011: phase = 8'b11111111;
		8'b01000100: phase = 8'b11111111;
		8'b01000101: phase = 8'b11111111;
		8'b01000110: phase = 8'b11111111;
		8'b01000111: phase = 8'b11111110;
		8'b01001000: phase = 8'b11111110;
		8'b01001001: phase = 8'b11111101;
		8'b01001010: phase = 8'b11111100;
		8'b01001011: phase = 8'b11111011;
		8'b01001100: phase = 8'b11111010;
		8'b01001101: phase = 8'b11111010;
		8'b01001110: phase = 8'b11111001;
		8'b01001111: phase = 8'b11110111;
		8'b01010000: phase = 8'b11110110;
		8'b01010001: phase = 8'b11110101;
		8'b01010010: phase = 8'b11110100;
		8'b01010011: phase = 8'b11110010;
		8'b01010100: phase = 8'b11110001;
		8'b01010101: phase = 8'b11101111;
		8'b01010110: phase = 8'b11101110;
		8'b01010111: phase = 8'b11101100;
		8'b01011000: phase = 8'b11101010;
		8'b01011001: phase = 8'b11101001;
		8'b01011010: phase = 8'b11100111;
		8'b01011011: phase = 8'b11100101;
		8'b01011100: phase = 8'b11100011;
		8'b01011101: phase = 8'b11100001;
		8'b01011110: phase = 8'b11011111;
		8'b01011111: phase = 8'b11011101;
		8'b01100000: phase = 8'b11011011;
		8'b01100001: phase = 8'b11011000;
		8'b01100010: phase = 8'b11010110;
		8'b01100011: phase = 8'b11010100;
		8'b01100100: phase = 8'b11010001;
		8'b01100101: phase = 8'b11001111;
		8'b01100110: phase = 8'b11001100;
		8'b01100111: phase = 8'b11001010;
		8'b01101000: phase = 8'b11000111;
		8'b01101001: phase = 8'b11000100;
		8'b01101010: phase = 8'b11000010;
		8'b01101011: phase = 8'b10111111;
		8'b01101100: phase = 8'b10111100;
		8'b01101101: phase = 8'b10111010;
		8'b01101110: phase = 8'b10110111;
		8'b01101111: phase = 8'b10110100;
		8'b01110000: phase = 8'b10110001;
		8'b01110001: phase = 8'b10101110;
		8'b01110010: phase = 8'b10101011;
		8'b01110011: phase = 8'b10101000;
		8'b01110100: phase = 8'b10100101;
		8'b01110101: phase = 8'b10100010;
		8'b01110110: phase = 8'b10011111;
		8'b01110111: phase = 8'b10011100;
		8'b01111000: phase = 8'b10011001;
		8'b01111001: phase = 8'b10010110;
		8'b01111010: phase = 8'b10010011;
		8'b01111011: phase = 8'b10010000;
		8'b01111100: phase = 8'b10001101;
		8'b01111101: phase = 8'b10001001;
		8'b01111110: phase = 8'b10000110;
		8'b01111111: phase = 8'b10000011;
		8'b10000000: phase = 8'b10000000;
		8'b10000001: phase = 8'b01111101;
		8'b10000010: phase = 8'b01111010;
		8'b10000011: phase = 8'b01110111;
		8'b10000100: phase = 8'b01110011;
		8'b10000101: phase = 8'b01110000;
		8'b10000110: phase = 8'b01101101;
		8'b10000111: phase = 8'b01101010;
		8'b10001000: phase = 8'b01100111;
		8'b10001001: phase = 8'b01100100;
		8'b10001010: phase = 8'b01100001;
		8'b10001011: phase = 8'b01011110;
		8'b10001100: phase = 8'b01011011;
		8'b10001101: phase = 8'b01011000;
		8'b10001110: phase = 8'b01010101;
		8'b10001111: phase = 8'b01010010;
		8'b10010000: phase = 8'b01001111;
		8'b10010001: phase = 8'b01001100;
		8'b10010010: phase = 8'b01001001;
		8'b10010011: phase = 8'b01000110;
		8'b10010100: phase = 8'b01000100;
		8'b10010101: phase = 8'b01000001;
		8'b10010110: phase = 8'b00111110;
		8'b10010111: phase = 8'b00111100;
		8'b10011000: phase = 8'b00111001;
		8'b10011001: phase = 8'b00110110;
		8'b10011010: phase = 8'b00110100;
		8'b10011011: phase = 8'b00110001;
		8'b10011100: phase = 8'b00101111;
		8'b10011101: phase = 8'b00101100;
		8'b10011110: phase = 8'b00101010;
		8'b10011111: phase = 8'b00101000;
		8'b10100000: phase = 8'b00100101;
		8'b10100001: phase = 8'b00100011;
		8'b10100010: phase = 8'b00100001;
		8'b10100011: phase = 8'b00011111;
		8'b10100100: phase = 8'b00011101;
		8'b10100101: phase = 8'b00011011;
		8'b10100110: phase = 8'b00011001;
		8'b10100111: phase = 8'b00010111;
		8'b10101000: phase = 8'b00010110;
		8'b10101001: phase = 8'b00010100;
		8'b10101010: phase = 8'b00010010;
		8'b10101011: phase = 8'b00010001;
		8'b10101100: phase = 8'b00001111;
		8'b10101101: phase = 8'b00001110;
		8'b10101110: phase = 8'b00001100;
		8'b10101111: phase = 8'b00001011;
		8'b10110000: phase = 8'b00001010;
		8'b10110001: phase = 8'b00001001;
		8'b10110010: phase = 8'b00000111;
		8'b10110011: phase = 8'b00000110;
		8'b10110100: phase = 8'b00000110;
		8'b10110101: phase = 8'b00000101;
		8'b10110110: phase = 8'b00000100;
		8'b10110111: phase = 8'b00000011;
		8'b10111000: phase = 8'b00000010;
		8'b10111001: phase = 8'b00000010;
		8'b10111010: phase = 8'b00000001;
		8'b10111011: phase = 8'b00000001;
		8'b10111100: phase = 8'b00000001;
		8'b10111101: phase = 8'b00000000;
		8'b10111110: phase = 8'b00000000;
		8'b10111111: phase = 8'b00000000;
		8'b11000000: phase = 8'b00000000;
		8'b11000001: phase = 8'b00000000;
		8'b11000010: phase = 8'b00000000;
		8'b11000011: phase = 8'b00000000;
		8'b11000100: phase = 8'b00000001;
		8'b11000101: phase = 8'b00000001;
		8'b11000110: phase = 8'b00000001;
		8'b11000111: phase = 8'b00000010;
		8'b11001000: phase = 8'b00000010;
		8'b11001001: phase = 8'b00000011;
		8'b11001010: phase = 8'b00000100;
		8'b11001011: phase = 8'b00000101;
		8'b11001100: phase = 8'b00000110;
		8'b11001101: phase = 8'b00000110;
		8'b11001110: phase = 8'b00000111;
		8'b11001111: phase = 8'b00001001;
		8'b11010000: phase = 8'b00001010;
		8'b11010001: phase = 8'b00001011;
		8'b11010010: phase = 8'b00001100;
		8'b11010011: phase = 8'b00001110;
		8'b11010100: phase = 8'b00001111;
		8'b11010101: phase = 8'b00010001;
		8'b11010110: phase = 8'b00010010;
		8'b11010111: phase = 8'b00010100;
		8'b11011000: phase = 8'b00010110;
		8'b11011001: phase = 8'b00010111;
		8'b11011010: phase = 8'b00011001;
		8'b11011011: phase = 8'b00011011;
		8'b11011100: phase = 8'b00011101;
		8'b11011101: phase = 8'b00011111;
		8'b11011110: phase = 8'b00100001;
		8'b11011111: phase = 8'b00100011;
		8'b11100000: phase = 8'b00100101;
		8'b11100001: phase = 8'b00101000;
		8'b11100010: phase = 8'b00101010;
		8'b11100011: phase = 8'b00101100;
		8'b11100100: phase = 8'b00101111;
		8'b11100101: phase = 8'b00110001;
		8'b11100110: phase = 8'b00110100;
		8'b11100111: phase = 8'b00110110;
		8'b11101000: phase = 8'b00111001;
		8'b11101001: phase = 8'b00111100;
		8'b11101010: phase = 8'b00111110;
		8'b11101011: phase = 8'b01000001;
		8'b11101100: phase = 8'b01000100;
		8'b11101101: phase = 8'b01000110;
		8'b11101110: phase = 8'b01001001;
		8'b11101111: phase = 8'b01001100;
		8'b11110000: phase = 8'b01001111;
		8'b11110001: phase = 8'b01010010;
		8'b11110010: phase = 8'b01010101;
		8'b11110011: phase = 8'b01011000;
		8'b11110100: phase = 8'b01011011;
		8'b11110101: phase = 8'b01011110;
		8'b11110110: phase = 8'b01100001;
		8'b11110111: phase = 8'b01100100;
		8'b11111000: phase = 8'b01100111;
		8'b11111001: phase = 8'b01101010;
		8'b11111010: phase = 8'b01101101;
		8'b11111011: phase = 8'b01110000;
		8'b11111100: phase = 8'b01110011;
		8'b11111101: phase = 8'b01110111;
		8'b11111110: phase = 8'b01111010;
		8'b11111111: phase = 8'b01111101;
	endcase

endmodule

// The $readmemb and $readmemh system tasks load the contents of a 2-D
// array variable from a text file.  QIS supports these system tasks in
// initial blocks.  They may be used to initialized the contents of inferred
// RAMs or ROMs.  They may also be used to specify the power-up value for
// a 2-D array of registers. 
// 
// Usage:
//
// ("file_name", memory_name [, start_addr [, end_addr]]);
// ("file_name", memory_name [, start_addr [, end_addr]]);
//
// File Format:
// 
// The text file can contain Verilog whitespace characters, comments,
// and binary ($readmemb) or hexadecimal ($readmemh) data values.  Both
// types of data values can contain x or X, z or Z, and the underscore
// character.
// 
// The data values are assigned to memory words from left to right,
// beginning at start_addr or the left array bound (the default).  The
// next address to load may be specified in the file itself using @hhhhhh, 
// where h is a hexadecimal character.  Spaces between the @ and the address 
// character are not allowed.  It shall be an error if there are too many 
// words in the file or if an address is outside the bounds of the array.
//
// Example:
//
// reg [7:0] ram[0:2];
// 
// initial
// begin
//     $readmemb("init.txt", rom);
// end
//
// <init.txt>
//
// 11110000      // Loads at address 0 by default
// 10101111   
// @2 00001111   
