

module adder32_stim;

    timeunit 1ns; timeprecision 10ps;
	
	logic adding, stopOp, infNum;	
	logic [1:0] exp;
    logic clock, nreset, ready;
    logic [31:0] a, m, n, sum;
	logic [7:0] exp_m, exp_n;
	logic [22:0] manti_n, manti_m;
	logic [23:0] manti_m2, manti_n2, manti_m1, manti_n1;
	logic [24:0] manti_m3, manti_n3, sum_manti;
	logic sum_sign;
	logic [7:0] sum_exp;

    fpadder A1(sum, ready, a, clock, nreset);
	
	assign adding = A1.adding;
	assign stopOp = A1.stopOp;
	assign infNum = A1.infNum;
	assign m = A1.m;
	assign n = A1.n;
	assign exp = A1.exp;	
	assign sign = A1.sign;
	assign exp_m = A1.exp_m;
	assign exp_n = A1.exp_n;	
	assign manti_m1 = A1.manti_m1;
	assign manti_n1 = A1.manti_n1;
	assign manti_m = A1.manti_m;
	assign manti_n = A1.manti_n;  
	assign manti_m2 = A1.manti_m2;
	assign manti_n2 = A1.manti_n2;
	assign manti_m3 = A1.manti_m3;
	assign manti_n3 = A1.manti_n3;
	assign sum_exp = A1.sum_exp;
	assign sum_sign = A1.sum_sign;
	assign sum_manti = A1.sum_manti;  


    initial 
    begin
        clock = '0;
        forever #10 clock = ~clock;
    end

    initial
	begin
    nreset = 1;
    #1 nreset = 0;
    #2 nreset = 1;
    end

    initial 
	begin
    a = '0;
	
	//  result: 0
	#20 a = 32'b10000000000000000000000000000000;	//-0   0x80000000
	#25 a = 32'b00000000000000000000000000000000;	//+0   0x00000000

	//test2 result:2=0x40000000
	#55 a = 32'b00111111100000000000000000000000;	//+1  		 0x3f800000
	#25 a = 32'b00111111100000000000000000000000;	//+1   		 0x3f800000

	//test3 result:-2=0xc0000000
	#55 a = 32'b10111111100000000000000000000000;	//-1   0xbf800000
	#25 a = 32'b10111111100000000000000000000000;	//-1   0xbf800000

	//test6 result: 0x3e9f2fdc
	#55 a = 32'b00111111110011111011111001011110;	//   1.622997   0x3fcfbe5e
	#25 a = 32'b10111111101001111111001001100111;	//	-1.312085   0xbfa7f267 	

	//test2 result: 0xc79324e9
	#55 a = 32'b00111111100110011010001100010010;	//  1.200289e+00 		 0x3f99a312
	#25 a = 32'b11000111100100110010010110000011;	// -7.533902e+04   		 0xc7932583

	//test1 result:45.14159=0x423490fd
    #50 a = 32'b01000010001010000000000000000000;	//42;        0x42280000
    #25 a = 32'b01000000010010010000111111010000;	//3.14159;   0x40490fd0
	
	//test2 result: 0xedfe85a6
	#55 a = 32'b11101101111101110011110011110011;	// -9.564560e+27            0xedf73cf3
	#25 a = 32'b11101011011010010001011001010110;	// -2.817852e+26    		0xeb691656
	
	//test3 result: 0x3f800000
	#55 a = 32'b00111111100000000000000000000000;	//+1   0x3f800000
	#25 a = 32'b00000000000000000000000000000000;	//+0   0x00000000
	
	//test4 result: 0 
	#55 a = 32'b10111111100000000000000000000000;	//-1   0xbf800000
	#25 a = 32'b00111111100000000000000000000000;	//+1   0x3f800000
	
	//test6 result: 0xbe9fc99c  
	#55 a = 32'b00111111100000000000000000000000;	//+1                0x3f800000
	#25 a = 32'b10111111101001111111001001100111;	//-1.31208503246    0xbfa7f267	
	
	//test6 result: -1
	#55 a = 32'b10111111100000000000000000000000;	//-1    0xbf800000	
	#25 a = 32'b00000000000000000000000000000000;	//+0    0x00000000
	
	//test7 result: +inf
	#55 a = 32'b01111111010000000000000000000000;	//		0x7f400000  add to inf
	#25 a = 32'b01111111010000000000000000000000;	//		0x7f400000
	
	//test8 result: NaN
	#55 a = 32'b01111111110000000000000000000000;	//		0x7fc00000  not a number
	#25 a = 32'b01111111010000000000000000000000;	//		0x7f400000
	
	//test9 result: +inf
	#55 a = 32'b01111111100000000000000000000000;	//		0x7f800000  +inf
	#25 a = 32'b01111111100000000000000000000000;	//		0x7f800000  +inf
	
	//test10 result: -inf
	#55 a = 32'b11111111100000000000000000000000;	//		0xff800000  -inf
	#25 a = 32'b11111111100000000000000000000000;	//		0xff800000  -inf
	
	//test11 result: 0
	#55 a = 32'b01111111100000000000000000000000;	//		0x7f800000  +inf
	#25 a = 32'b11111111100000000000000000000000;	//		0xff800000  -inf	
	
	//test12 result: NaN
	#55 a = 32'b01111111100000000000000000000000;	//		0x7f800000  +inf
	#25 a = 32'b11111111110000000000000000000000;	//		0xffc00000  not a number
	#100 $stop;
    end
	

              

endmodule
