/////////////////////////////////////////////////////////////////////
// Design unit: adder32
// File name  : fpadder.sv
// Description: top module 
// 			  : 32-bit floating-point adder, one input port, two operands
//            : IEEE Standard 754
//			  : ELEC6236 coursework#1
// Limitations: None
// System     : SystemVerilog IEEE 1800-2005
// Author     : Jun Xia
//            : School of Electronics and Computer Science
//            : University of Southampton
//            : Southampton SO17 1BJ, UK
// Revision   : Version 2.0 
//////////////////////////////////////////////////////////////////
module fpadder (output logic [31:0] sum, output logic ready,
                input logic [31:0] a, input logic clock, nreset);
     
    logic [31:0] m,n;      // 2 inputs
    logic [1:0] exp;
	logic sign; 
    logic adding, stopOp, infNum, abSum, notNum, bigNum;   //control signals
	logic [7:0] exp_m, exp_n;        						 //exp_m/n: original exponent; 
	logic [22:0] manti_m, manti_n;						// original mantissa
	logic [23:0] manti_m2, manti_n2, manti_m1, manti_n1;	// manti_m2/n2: denormalized mantissa; manti_m1/n1: shifted mantissa
	logic sign_m, sign_n;		// sign bits 
	
    assign sign_m = m[31];
    assign sign_n = n[31];
    assign exp_m = {m[30:23]};
    assign exp_n = {n[30:23]};
    assign manti_m = {m[22:0]};
    assign manti_n = {n[22:0]};
	assign manti_m2 = {1'b1, manti_m};
	assign manti_n2 = {1'b1, manti_n};
	
	// if exponent is 255 and mantissa is not zero, it's not a number; assert stopOp 
	// if one or two of the two numbers if infinity, assert infNum
	always_comb 
      begin
        notNum = (exp_m == 255 & manti_m != 0) || (exp_n == 255 & manti_n != 0);  
		bigNum = (exp_m == 255 & manti_m == 0) || (exp_n == 255 & manti_n == 0);
      end 
	  
    always_comb 
      begin
        exp = (exp_m > exp_n)? 2'b10 : (exp_m < exp_n)? 2'b01 : 2'b00;
        sign = (sign_m == sign_n)? '1 : '0;
      end
	  
    always_comb
      begin
          if (exp == 2'b10) begin
            manti_n1 = manti_n2 >> (exp_m - exp_n);      // 24-bit 
			manti_m1 = manti_m2;  
			end
          else if (exp == 2'b01) begin
            manti_m1 = manti_m2 >> (exp_n - exp_m);
			manti_n1 = manti_n2;	
			end
          else begin
			manti_m1 = manti_m2; 
			manti_n1 = manti_n2;	
			end
      end                                                

	//operation unit
    logic [24:0] manti_m3, manti_n3, sum_manti;
    logic [7:0]  sum_exp;
    logic sum_sign;

    assign manti_m3 = {'0, manti_m1[23:0]};
    assign manti_n3 = {'0, manti_n1[23:0]};

    always_ff @(posedge clock, negedge nreset)     //cannot use comb, infer latches
      if(!nreset) begin
      	sum_manti <= 0;
        sum_exp <= 0; 
        sum_sign <= 0; end
		
      else if (adding == '1) begin	 
        if (sign == '1) begin              // if the operands have the same sign bit, it may overflow.
        sum_manti <= (manti_n3 + manti_m3);   //address this problem in line 78      	
		sum_exp <= (exp ==  2'b10)? exp_m : exp_n;
        sum_sign <= sign_m; end
        else if (sign == '0 & exp == 2'b10) begin
      	sum_manti <= manti_m3 - manti_n3;
		sum_exp <= exp_m; 
        sum_sign <= sign_m; end
        else if (sign == '0 & exp == 2'b01) begin
      	sum_manti <= manti_n3 - manti_m3;
      	sum_exp <= exp_n; 
        sum_sign <= sign_n; end
        else if (sign == '0 & exp == 2'b00) begin
       	sum_manti <= (manti_m3 > manti_n3)? (manti_m3 - manti_n3) : (manti_m3 < manti_n3)? (manti_n3 - manti_m3) : 25'h1000000;
      	sum_exp <= (manti_m3 > manti_n3)? exp_m : (manti_m3 < manti_n3)? exp_n : 8'h0; 
        sum_sign <= (manti_m3 > manti_n3)? sign_m : (manti_m3 < manti_n3)? sign_n : '0; end 	end
		
	//if the input is not a number, set every bit of sum to 1
	  else if (stopOp == 1) begin
		sum_manti[24:23] <= 2'b01;
		sum_manti[22:0] <= 23'h7fffff;
      	sum_exp <= 8'hff; 
        sum_sign <= '0; end
		
	//if the inputs have one or two inf num
	  else if (infNum == 1) begin
		if (sign == 1) begin			// if sign bits are the same
			sum_manti[24:23] <= 2'b01;
			sum_manti[22:0] <= 0;
			sum_exp <= 8'hff; 
			sum_sign <= sign_m; end	
		else begin						// if sign bits are not the same 
			sum_manti[24:23] <= 2'b01;
			sum_manti[22:0] <= 0;
			sum_exp <= (exp == 2'b0) ? 8'h0 : 8'hff; 
			sum_sign <= (exp == 2'b10)? sign_m : (exp == 2'b01)? sign_n : 1'b0; end	end				
	
	//assemble the sum for output
      always_ff @(posedge clock, negedge nreset)
		if(!nreset)
			sum <= 0;
		else if(abSum == 1) begin
        if (sum_manti[24] == 1)	begin 
			if (sum_exp == 254)						//if sum_exp+1 == 255, manti should be set to zero,
				sum <= {sum_sign, 8'hff, 23'b0};     // the result is inf.
			else if (sum_exp == 0 & sum_manti[22:0] == 0)
				sum <= 0;
			else 
				sum <= {sum_sign, sum_exp + 8'b1, sum_manti[23:1]}; end			
        else begin
			if (sum_manti[23] == 1)
			sum <= {sum_sign, sum_exp, sum_manti[22:0]};  
			else if (sum_manti[22] == 1)
			sum <= {sum_sign, (sum_exp - 8'h1), sum_manti[21:0], 1'b0}; 
			else if (sum_manti[21] == 1)
			sum <= {sum_sign, (sum_exp - 8'h2), sum_manti[20:0], 2'b0};
			else if (sum_manti[20] == 1)
			sum <= {sum_sign, (sum_exp - 8'h3), sum_manti[19:0], 3'b0};
			else if (sum_manti[19] == 1)
			sum <= {sum_sign, (sum_exp - 8'h4), sum_manti[18:0], 4'b0};
			else if (sum_manti[18] == 1)
			sum <= {sum_sign, (sum_exp - 8'h5), sum_manti[17:0], 5'b0}; 
			else if (sum_manti[17] == 1)
			sum <= {sum_sign, (sum_exp - 8'h6), sum_manti[16:0], 6'b0};
			else if (sum_manti[16] == 1)
			sum <= {sum_sign, (sum_exp - 8'h7), sum_manti[15:0], 7'b0};
			else if (sum_manti[15] == 1)
			sum <= {sum_sign, (sum_exp - 8'h8), sum_manti[14:0], 8'b0};
			else if (sum_manti[14] == 1)
			sum <= {sum_sign, (sum_exp - 8'h9), sum_manti[13:0], 9'b0}; 
			else if (sum_manti[13] == 1)
			sum <= {sum_sign, (sum_exp - 8'ha), sum_manti[12:0], 10'b0};
			else if (sum_manti[12] == 1)
			sum <= {sum_sign, (sum_exp - 8'hb), sum_manti[11:0], 11'b0};
			else if (sum_manti[11] == 1)
			sum <= {sum_sign, (sum_exp - 8'hc), sum_manti[10:0], 12'b0};
			else if (sum_manti[10] == 1)
			sum <= {sum_sign, (sum_exp - 8'hd), sum_manti[9:0], 13'b0}; 
			else if (sum_manti[9] == 1)
			sum <= {sum_sign, (sum_exp - 8'he), sum_manti[8:0], 14'b0};
			else if (sum_manti[8] == 1)
			sum <= {sum_sign, (sum_exp - 8'hf), sum_manti[7:0], 15'b0};
			else if (sum_manti[7] == 1)
			sum <= {sum_sign, (sum_exp - 8'h10), sum_manti[6:0], 16'b0};
			else if (sum_manti[6] == 1)
			sum <= {sum_sign, (sum_exp - 8'h11), sum_manti[5:0], 17'b0};
			else if (sum_manti[5] == 1)
			sum <= {sum_sign, (sum_exp - 8'h12), sum_manti[4:0], 18'b0};
			else if (sum_manti[4] == 1)
			sum <= {sum_sign, (sum_exp - 8'h13), sum_manti[3:0], 19'b0};
			else if (sum_manti[3] == 1)
			sum <= {sum_sign, (sum_exp - 8'h14), sum_manti[2:0], 20'b0}; 
			else if (sum_manti[2] == 1)
			sum <= {sum_sign, (sum_exp - 8'h15), sum_manti[1:0], 21'b0};
			else if (sum_manti[1] == 1)
			sum <= {sum_sign, (sum_exp - 8'h16), sum_manti[0], 22'b0};
			else if (sum_manti[0] == 1)
			sum <= {sum_sign, (sum_exp - 8'h17), 23'b0};
			end
			end

   //control unit           
	enum {start, loadN1, loadN2, pred, asblSum, stop} state;
    
    always_ff @(posedge clock, negedge nreset)
    	if(!nreset)begin
    		state <= start;
			m <= 0;
			n <= 0;  end
    	else begin
			ready <= 0;
			infNum <= 0;
			stopOp <= 0;
			adding <= 0;
			abSum <= 0;
			case(state)
				start:begin
					state <= loadN1; end
				loadN1:begin
					n <= a;
					state <= loadN2; end
				loadN2:begin
					m <= a;
					state <= pred; end
				pred: begin
					state <= asblSum;
					if (!notNum & bigNum)
						infNum <= 1;
					else if (notNum)
						stopOp <= 1;
					else
						adding <= 1; end
				asblSum:begin
					state <= stop;
					abSum <= 1; end
				stop:begin
					ready <= 1;
					state <= start; end				
            endcase
			end		
endmodule