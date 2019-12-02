module polynomial_reg(input signed [9:0]SW, input [3:0]KEY, input CLOCK_50, plot_done, output reg signed [11:0] param_out0, 
						    param_out1, param_out2, param_out3, output [6:0] HEX0, HEX1, HEX2, HEX3,
							 HEX4, HEX5, output reg[8:0]x_val, output reg[7:0]y_val, output reg training_done, draw, finished_training);


	reg [5:0] state;
	reg [5:0] next_state;
	reg signed [11:0] reg_param_in [0:3];
	reg [6:0] cycle_cnt;
	reg signed [11:0] x[0:3];
	reg signed [11:0] y[0:3];
	reg [3:0] h[0:5];
	wire signed [11:0] w_param_in  [0:3];
	wire signed [11:0] w_param_out [0:3];
	wire clock;
	wire reset;
	wire signed [4:0]data_in;
	wire go;
	
	Clock_divider clk(.clock_in(CLOCK_50), .clock_out(clock));

	assign reset = SW[9];
	assign data_in = SW[4:0];
	assign go = KEY[0];
	
	localparam IDLE       = 6'd0,
				  input_x1   = 6'd1,
				  input_x1_w = 6'd2,
				  input_y1   = 6'd3,
				  input_y1_w = 6'd4,
				  input_x2   = 6'd5,
				  input_x2_w = 6'd6,
				  input_y2   = 6'd7,
				  input_y2_w = 6'd8,
				  input_x3   = 6'd9,
				  input_x3_w = 6'd10,
				  input_y3   = 6'd11,
				  input_y3_w = 6'd12,
				  input_x4   = 6'd13,
				  input_x4_w = 6'd14,
				  input_y4   = 6'd15,
				  input_y4_w = 6'd16,
				  training   = 6'd17,
				  training_w = 6'd18;
				  
	assign w_param_in[0] = reg_param_in[0];
	assign w_param_in[1] = reg_param_in[1];
	assign w_param_in[2] = reg_param_in[2];
	assign w_param_in[3] = reg_param_in[3];
	
	always@(posedge clock)
	begin
		case(state)
		
			IDLE:       next_state <= go ? IDLE : input_x1;
						
			input_x1:   next_state <= go ? input_x1_w : input_x1;
							
			input_x1_w: next_state <= go ? input_x1_w : input_y1;
				
			input_y1:   next_state <= go ? input_y1_w : input_y1;
							
			input_y1_w: next_state <= go ? input_y1_w : input_x2;
			
			input_x2:   next_state <= go ? input_x2_w : input_x2;
							
			input_x2_w: next_state <= go ? input_x2_w : input_y2;
			
			input_y2:   next_state <= go ? input_y2_w : input_y2;
							
			input_y2_w: next_state <= go ? input_y2_w : input_x3;
			
			input_x3:   next_state <= go ? input_x3_w : input_x3;
							
			input_x3_w: next_state <= go ? input_x3_w : input_y3;
			
			input_y3:   next_state <= go ? input_y3_w : input_y3;
							
			input_y3_w: next_state <= go ? input_y3_w : input_x4;

			input_x4:   next_state <= go ? input_x4_w : input_x4;
							
			input_x4_w: next_state <= go ? input_x4_w : input_y4;
			
			input_y4:   next_state <= go ? input_y4_w : input_y4;
							
			input_y4_w: next_state <= go ? input_y4_w : training;
			
			training:   next_state <= training_w;
			
			training_w: begin
								if(cycle_cnt != 100)
									next_state = plot_done ? training : training_w;
								else
									next_state = IDLE;
							end 
											
			default: next_state <= IDLE;	
			
		endcase
	end
			
	
	always@(posedge clock)
	begin
		case(state) 
			IDLE:     begin
							x[0] <= 0;
							x[1] <= 0;
							x[2] <= 0;
							x[3] <= 0;
							y[0] <= 0;
							y[1] <= 0;
							y[2] <= 0;
							y[3] <= 0;
							draw <= 0;
							training_done <= 0;
							finished_training <= 0;
						 end
			
			input_x1: begin
							x[0] <= {{7{data_in[4]}},data_in};
							h[0] <= data_in;
						 end
			input_y1: begin
							y[0] <= {{7{data_in[4]}},data_in};
							h[1] <= data_in;
						 end
			input_y1_w: begin
							draw <= 1;
							x_val <= x[0][8:0];
							y_val <= y[0][7:0];
							end
								
			input_x2: begin
							draw <= 0;
							x[1] <= {{7{data_in[4]}},data_in};
							h[2] <= data_in;
						 end
			input_y2: begin
							y[1] <= {{7{data_in[4]}},data_in};
							h[3] <= data_in;
						 end
			input_y2_w: begin
							draw <= 1;
							x_val <= x[1][8:0];
							y_val <= y[1][7:0];
							end
			input_x3: begin
							draw <= 0;
							x[2] <= {{7{data_in[4]}},data_in};
						 end
			input_y3: begin
							y[2] <= {{7{data_in[4]}},data_in};
						 end
			input_y3_w: begin
							draw <= 1;
							x_val <= x[2][8:0];
							y_val <= y[2][7:0];
							end
			input_x4: begin
							draw <= 0;
							x[3] <= {{7{data_in[4]}},data_in};
							h[4] <= data_in;
						 end
			input_y4: begin
							y[3] <= {{7{data_in[4]}},data_in};
							h[5] <= data_in;
						 end
		 input_y4_w: begin
								draw <= 1;
								x_val <= x[3][8:0];
								y_val <= y[3][7:0];
								reg_param_in[0] <= 0;
								reg_param_in[1] <= 0;
								reg_param_in[2] <= 0;
								reg_param_in[3] <= 0;
								cycle_cnt <= 0;
								finished_training <= 0;
							end
			training: begin
								draw <= 0;
								training_done <= 0;
								param_out0 <= w_param_out[0];
								param_out1 <= w_param_out[1];
								param_out2 <= w_param_out[2];
								param_out3 <= w_param_out[3];
								reg_param_in[0] <= w_param_out[0];
								reg_param_in[1] <= w_param_out[1];
								reg_param_in[2] <= w_param_out[2];
								reg_param_in[3] <= w_param_out[3];
								
								h[0] <= w_param_out[0][3:0];
								h[1] <= w_param_out[0][7:4];
								h[2] <= w_param_out[1][3:0];
								h[3] <= w_param_out[1][7:4];
								h[4] <= w_param_out[2][3:0];
								h[5] <= w_param_out[2][7:4];
								
								cycle_cnt <= cycle_cnt + 1;
							 end
			training_w:  begin
								training_done <= 1;
							 end
					 default: begin
									reg_param_in[0] <= 0;
									reg_param_in[1] <= 0;
									reg_param_in[2] <= 0;
									reg_param_in[3] <= 0;
									
									cycle_cnt <= 0;
								 end
		endcase
	end
	
	always@(posedge clock)
	begin
		if(reset)
			state <= IDLE;
			
		else 
			state <= next_state;
	end
							
	
	trainingAlgorithm train(.x1(x[0]), .x2(x[1]), .x3(x[2]), .x4(x[3]), .y1(y[0]), .y2(y[1]),
									.y3(y[2]), .y4(y[3]), .param_in0(w_param_in[0]), .param_in1(w_param_in[1]), 
									.param_in2(w_param_in[2]), .param_in3(w_param_in[3]), .reset(reset), 
									.clock(clock), .param_out0(w_param_out[0]),.param_out1(w_param_out[1]), 
									.param_out2(w_param_out[2]), .param_out3(w_param_out[3]));
	

	seg7 hex0(h[0], HEX0);
	seg7 hex1(h[1], HEX1);
	seg7 hex2(h[2], HEX2);
	seg7 hex3(h[3], HEX3);
	seg7 hex4(h[4], HEX4);
	seg7 hex5(h[5], HEX5);
							
endmodule	

module trainingAlgorithm(input [11:0] x1, x2, x3, x4, y1, y2, y3, y4,input [11:0] param_in0,
								 param_in1, param_in2, param_in3, input reset, clock, output reg [11:0] param_out0,
								 param_out1, param_out2, param_out3);

	reg  [11:0] cparam      [0:3];
	reg  [11:0] sum_reg     [0:3];
	wire        overflow    [0:31];
	wire [11:0] h           [0:15];
	wire [11:0] sub         [0:15];
	wire [11:0] add         [0:7];
	wire [11:0] sum         [0:3];
	wire [11:0] mult        [0:23];
	wire [11:0] w_param_out [0:3];
	
	always@(posedge clock)begin
		if(reset)
			begin
				cparam[0] <= 0;
				cparam[1] <= 0;
				cparam[2] <= 0;
				cparam[3] <= 0;	
		end
		else 
			begin
				cparam[0] <= param_in0;
				cparam[1] <= param_in1;
				cparam[2] <= param_in2;
				cparam[3] <= param_in3;
			end
	end	
	
	//zeroth parameter update cycle begin
	hypothesis hyp1(.x(x1), .param_in0(param_in0), .param_in1(param_in1), .param_in2(param_in2), 
						 .param_in3(param_in3), .reset(reset), .clock(clock), .out(h[0]));				 
	sub s1(.dataa(h[0]), .datab(y1), .overflow(overflow[0]), .result(sub[0]));
	
	hypothesis hyp2(.x(x2), .param_in0(param_in0), .param_in1(param_in1), .param_in2(param_in2), 
						 .param_in3(param_in3), .reset(reset), .clock(clock), .out(h[1]));				 
	sub s2(.dataa(h[1]), .datab(y2), .overflow(overflow[1]), .result(sub[1]));
	
	hypothesis hyp3(.x(x3), .param_in0(param_in0), .param_in1(param_in1), .param_in2(param_in2), 
						 .param_in3(param_in3), .reset(reset), .clock(clock), .out(h[2]));				 
	sub s3(.dataa(h[2]), .datab(y3), .overflow(overflow[2]), .result(sub[2]));
	
	hypothesis hyp4(.x(x4), .param_in0(param_in0), .param_in1(param_in1), .param_in2(param_in2), 
						 .param_in3(param_in3), .reset(reset), .clock(clock), .out(h[3]));				 
	sub s4(.dataa(h[3]), .datab(y4), .overflow(overflow[3]), .result(sub[3]));
	
	add a1(.dataa(sub[0]), .datab(sub[1]), .overflow(overflow[4]), .result(add[0]));
	add a2(.dataa(sub[2]), .datab(sub[3]), .overflow(overflow[5]), .result(add[1]));
	add a3(.dataa(add[0]), .datab(add[1]), .overflow(overflow[6]), .result(sum[0]));
	//zeroth parameter update cycle ends
	
	//first parameter update cycle begin
	hypothesis hyp5(.x(x1), .param_in0(param_in0), .param_in1(param_in1), .param_in2(param_in2), 
						 .param_in3(param_in3), .reset(reset), .clock(clock), .out(h[4]));		 
	sub s5(.dataa(h[4]), .datab(y1), .overflow(overflow[7]), .result(sub[4]));
	
	hypothesis hyp6(.x(x2), .param_in0(param_in0), .param_in1(param_in1), .param_in2(param_in2), 
						 .param_in3(param_in3), .reset(reset), .clock(clock), .out(h[5])); 
	sub s6(.dataa(h[5]), .datab(y2), .overflow(overflow[8]), .result(sub[5]));
	
	hypothesis hyp7(.x(x3), .param_in0(param_in0), .param_in1(param_in1), .param_in2(param_in2), 
						 .param_in3(param_in3), .reset(reset), .clock(clock), .out(h[6]));	 
	sub s7(.dataa(h[6]), .datab(y3), .overflow(overflow[9]), .result(sub[6]));
	
	hypothesis hyp8(.x(x4), .param_in0(param_in0), .param_in1(param_in1), .param_in2(param_in2), 
						 .param_in3(param_in3), .reset(reset), .clock(clock), .out(h[7])); 
	sub s8(.dataa(h[7]), .datab(y4), .overflow(overflow[10]), .result(sub[7]));
	
	multiply m1(.dataa(x1), .datab(sub[4]), .result(mult[0]));
	multiply m2(.dataa(x2), .datab(sub[5]), .result(mult[1]));
	multiply m3(.dataa(x3), .datab(sub[6]), .result(mult[2]));
	multiply m4(.dataa(x4), .datab(sub[7]), .result(mult[3]));
	
	add a4(.dataa(mult[0]), .datab(mult[1]), .overflow(overflow[11]), .result(add[2]));
	add a5(.dataa(mult[2]), .datab(mult[3]), .overflow(overflow[12]), .result(add[3]));
	add a6(.dataa(add[2]), .datab(add[3]), .overflow(overflow[13]), .result(sum[1]));
	//first parameter update cycle ends
	
	//second parameter update cycle begin
	hypothesis hyp9(.x(x1), .param_in0(param_in0), .param_in1(param_in1), .param_in2(param_in2), 
						 .param_in3(param_in3), .reset(reset), .clock(clock), .out(h[8]));		 
	sub s9(.dataa(h[8]), .datab(y1), .overflow(overflow[14]), .result(sub[8]));
	
	hypothesis hyp10(.x(x2), .param_in0(param_in0), .param_in1(param_in1), .param_in2(param_in2), 
						 .param_in3(param_in3), .reset(reset), .clock(clock), .out(h[9])); 
	sub s10(.dataa(h[9]), .datab(y2), .overflow(overflow[15]), .result(sub[9]));
	
	hypothesis hyp11(.x(x3), .param_in0(param_in0), .param_in1(param_in1), .param_in2(param_in2), 
						 .param_in3(param_in3), .reset(reset), .clock(clock), .out(h[10]));	 
	sub s11(.dataa(h[10]), .datab(y3), .overflow(overflow[16]), .result(sub[10]));
	
	hypothesis hyp12(.x(x4), .param_in0(param_in0), .param_in1(param_in1), .param_in2(param_in2), 
						 .param_in3(param_in3), .reset(reset), .clock(clock), .out(h[11])); 
	sub s12(.dataa(h[11]), .datab(y4), .overflow(overflow[17]), .result(sub[11]));
	
	multiply m5(.dataa(x1), .datab(x1), .result(mult[4]));
	multiply m6(.dataa(x2), .datab(x2), .result(mult[5]));
	multiply m7(.dataa(x3), .datab(x3), .result(mult[6]));
	multiply m8(.dataa(x4), .datab(x4), .result(mult[7]));
	
	multiply m9(.dataa(mult[4]), .datab(sub[4]), .result(mult[8]));
	multiply m10(.dataa(mult[5]), .datab(sub[5]), .result(mult[9]));
	multiply m11(.dataa(mult[6]), .datab(sub[6]), .result(mult[10]));
	multiply m12(.dataa(mult[7]), .datab(sub[7]), .result(mult[11]));
	
	add a7(.dataa(mult[8]), .datab(mult[9]), .overflow(overflow[18]), .result(add[4]));
	add a8(.dataa(mult[10]), .datab(mult[11]), .overflow(overflow[19]), .result(add[5]));
	add a9(.dataa(add[4]), .datab(add[5]), .overflow(overflow[20]), .result(sum[2]));
	//second parameter update cycle ends
	
	//third parameter update cycle begin
	hypothesis hyp13(.x(x1), .param_in0(param_in0), .param_in1(param_in1), .param_in2(param_in2), 
						 .param_in3(param_in3), .reset(reset), .clock(clock), .out(h[12]));		 
	sub s13(.dataa(h[12]), .datab(y1), .overflow(overflow[21]), .result(sub[12]));
	
	hypothesis hyp14(.x(x2), .param_in0(param_in0), .param_in1(param_in1), .param_in2(param_in2), 
						 .param_in3(param_in3), .reset(reset), .clock(clock), .out(h[13])); 
	sub s14(.dataa(h[13]), .datab(y2), .overflow(overflow[22]), .result(sub[13]));
	
	hypothesis hyp15(.x(x3), .param_in0(param_in0), .param_in1(param_in1), .param_in2(param_in2), 
						 .param_in3(param_in3), .reset(reset), .clock(clock), .out(h[14]));	 
	sub s15(.dataa(h[14]), .datab(y3), .overflow(overflow[23]), .result(sub[14]));
	
	hypothesis hyp16(.x(x4), .param_in0(param_in0), .param_in1(param_in1), .param_in2(param_in2), 
						 .param_in3(param_in3), .reset(reset), .clock(clock), .out(h[15])); 
	sub s16(.dataa(h[15]), .datab(y4), .overflow(overflow[24]), .result(sub[15]));
	
	multiply m13(.dataa(x1), .datab(x1), .result(mult[12]));
	multiply m14(.dataa(x2), .datab(x2), .result(mult[13]));
	multiply m15(.dataa(x3), .datab(x3), .result(mult[14]));
	multiply m16(.dataa(x4), .datab(x4), .result(mult[15]));
	
	multiply m17(.dataa(x1), .datab(mult[12]), .result(mult[16]));
	multiply m18(.dataa(x2), .datab(mult[13]), .result(mult[17]));
	multiply m19(.dataa(x3), .datab(mult[14]), .result(mult[18]));
	multiply m20(.dataa(x4), .datab(mult[15]), .result(mult[19]));
	
	multiply m21(.dataa(mult[16]), .datab(sub[4]), .result(mult[20]));
	multiply m22(.dataa(mult[17]), .datab(sub[5]), .result(mult[21]));
	multiply m23(.dataa(mult[18]), .datab(sub[6]), .result(mult[22]));
	multiply m24(.dataa(mult[19]), .datab(sub[7]), .result(mult[23]));
	
	add a10(.dataa(mult[20]), .datab(mult[21]), .overflow(overflow[25]), .result(add[6]));
	add a11(.dataa(mult[22]), .datab(mult[23]), .overflow(overflow[26]), .result(add[7]));
	add a12(.dataa(add[6]), .datab(add[7]), .overflow(overflow[27]), .result(sum[3]));
	//third parameter update cycle ends
	
	//divide by 16 
	always@(posedge clock)
	begin
		sum_reg[0][11:5] <= sum[0][11];
		sum_reg[0][4]    <= sum[0][10];
		sum_reg[0][3]    <= sum[0][9];
		sum_reg[0][2]    <= sum[0][8];
		sum_reg[0][1]    <= sum[0][7];
		sum_reg[0][0]    <= sum[0][6];
//		sum_reg[0][1]    <= sum[0][5];
//		sum_reg[0][0]    <= sum[0][4];
		
		sum_reg[1][11:5] <= sum[1][11];
		sum_reg[1][4]    <= sum[1][10];
		sum_reg[1][3]    <= sum[1][9];
		sum_reg[1][2]    <= sum[1][8];
		sum_reg[1][1]    <= sum[1][7];
		sum_reg[1][0]    <= sum[1][6];
//		sum_reg[1][1]    <= sum[1][5];
//		sum_reg[1][0]    <= sum[1][4];
		
		sum_reg[2][11:5] <= sum[2][11];
		sum_reg[2][4]    <= sum[2][10];
		sum_reg[2][3]    <= sum[2][9];
		sum_reg[2][2]    <= sum[2][8];
		sum_reg[2][1]    <= sum[2][7];
		sum_reg[2][0]    <= sum[2][6];
//		sum_reg[2][1]    <= sum[2][5];
//		sum_reg[2][0]    <= sum[2][4];
		
		sum_reg[3][11:5] <= sum[3][11];
		sum_reg[3][4]    <= sum[3][10];
		sum_reg[3][3]    <= sum[3][9];
		sum_reg[3][2]    <= sum[3][8];
		sum_reg[3][1]    <= sum[3][7];
		sum_reg[3][0]    <= sum[3][6];
//		sum_reg[3][1]    <= sum[3][5];
//		sum_reg[3][0]    <= sum[3][4];	
	end
	
	sub param_update0(.dataa(cparam[0]), .datab(sum_reg[0]), .overflow(overflow[28]), .result(w_param_out[0]));
	sub param_update1(.dataa(cparam[1]), .datab(sum_reg[1]), .overflow(overflow[29]), .result(w_param_out[1]));
	sub param_update2(.dataa(cparam[2]), .datab(sum_reg[2]), .overflow(overflow[30]), .result(w_param_out[2]));
	sub param_update3(.dataa(cparam[3]), .datab(sum_reg[3]), .overflow(overflow[31]), .result(w_param_out[3]));
	
	always@(posedge clock)
	begin
		if(reset)
		begin
			param_out0 <= 0;
			param_out1 <= 0;
			param_out2 <= 0;
			param_out3 <= 0;
		end
		
		else
		begin
			param_out0 <= w_param_out[0];
			param_out1 <= w_param_out[1];
			param_out2 <= w_param_out[2];
			param_out3 <= w_param_out[3];
		end
	end
	
endmodule

module hypothesis(input [11:0] x,
						input [11:0] param_in0, param_in1, param_in2, param_in3,
						input reset, clock, output reg [11:0]out);
						
	wire [11:0]Prod1;
	wire [11:0]x_sq;
	wire [11:0]Prod2;
	wire [11:0]x_cb;
	wire [11:0]Prod3;
	wire [11:0]res1;
	wire [11:0]res2;
	wire [11:0]sum;
	wire overflowFlag1;
	wire overflowFlag2;
	wire overflowFlag3;
	
	multiply mult1(.dataa(x), .datab(param_in1), .result(Prod1));
	multiply mult2(.dataa(x), .datab(x), .result(x_sq));
	multiply mult3(.dataa(x), .datab(x_sq), .result(x_cb));
	multiply mult4(.dataa(x_sq), .datab(param_in2), .result(Prod2));
	multiply mult5(.dataa(x_cb), .datab(param_in3), .result(Prod3));
	
	add add1(.dataa(param_in0), .datab(Prod1), .overflow(overflowFlag1), .result(res1));
	add add2(.dataa(res1), .datab(Prod2), .overflow(overflowFlag2), .result(res2));
	add add3(.dataa(res2), .datab(Prod3), .overflow(overflowFlag3), .result(sum));			
		
	always@(posedge clock)
	begin 
		if(reset || overflowFlag1 || overflowFlag2 || overflowFlag3)
			out <= 12'd0;
		else
			out <= sum;
	end
	
endmodule
	
module multiply(input [11:0] dataa, datab, output [11:0] result);

	wire signed [11:0] w1, w2, w3;
	
	assign w1 = dataa;
	assign w2 = datab;
	
	assign w3 = w1 * w2;
	
	assign result = w3;
	
endmodule

module sub(input [11:0] dataa, datab, output overflow, output [11:0] result);
	
	wire signed [11:0] w1, w2, w3, w4;
	
	assign w1 = dataa;
	assign w2 = datab;
	
	assign w3 = w1 - w2;
	
	assign result = w3;
	
	assign w4 = ~w2 + 1'b1;
	
	assign overflow =  w1[11] ^ w4[11];

endmodule

module add(input [11:0] dataa, datab, output overflow, output [11:0] result);

	wire signed [11:0] w1, w2, w3;
	
	assign w1 = dataa;
	assign w2 = datab;
	
	assign w3 = w1 + w2;
	
	assign result = w3;
	
	assign overflow =  w1[11] ^ w2[11];
	
endmodule
	
	
module Clock_divider(clock_in,clock_out);
	input clock_in; // input clock on FPGA
	output clock_out; // output clock after dividing the input clock by divisor
	reg[27:0] counter=28'd0;
	parameter DIVISOR = 28'd10000000;

	always @(posedge clock_in)
	begin
	 counter <= counter + 28'd1;
	 if(counter>=(DIVISOR-1))
	  counter <= 28'd0;
	end

	assign clock_out = (counter<DIVISOR/2)?1'b0:1'b1;

endmodule 

module seg7(input [3:0] SW, output [6:0] HEX0);
   // Logic functions describing each of the 7 segments of the display
   assign HEX0[0]=~((SW[3]|SW[2]|SW[1]|~SW[0])&(SW[3]|~SW[2]|SW[1]|SW[0])&(~SW[3]|SW[2]|~SW[1]|~SW[0])&(~SW[3]|~SW[2]|SW[1]|~SW[0]));
	assign HEX0[1]=~((SW[3]|~SW[2]|SW[1]|~SW[0])& (SW[3]|~SW[2]|~SW[1]|SW[0])&(~SW[3]|SW[2]|~SW[1]|~SW[0])&(~SW[3]|~SW[2]|SW[1]|SW[0])&(~SW[3]|~SW[2]|~SW[1]|SW[0])&(~SW[3]|~SW[2]|~SW[1]|~SW[0]));
	assign HEX0[2]=~((SW[3]|SW[2]|~SW[1]|SW[0])&(~SW[3]|~SW[2]|SW[1]|SW[0])&(~SW[3]|~SW[2]|~SW[1]|SW[0])&(~SW[3]|~SW[2]|~SW[1]|~SW[0]));
	assign HEX0[3]=~((SW[3]|SW[2]|SW[1]|~SW[0])&(SW[3]|~SW[2]|SW[1]|SW[0])&(SW[3]|~SW[2]|~SW[1]|~SW[0])&(~SW[3]|SW[2]|~SW[1]|SW[0])&(~SW[3]|~SW[2]|~SW[1]|~SW[0])); 
	assign HEX0[4]=~((SW[3]|SW[2]|SW[1]|~SW[0])&(SW[3]|SW[2]|~SW[1]|~SW[0])&(SW[3]|~SW[2]|SW[1]|SW[0])&(SW[3]|~SW[2]|SW[1]|~SW[0])&(SW[3]|~SW[2]|~SW[1]|~SW[0])&(~SW[3]|SW[2]|SW[1]|~SW[0]));
	assign HEX0[5]=~((SW[3]|SW[2]|SW[1]|~SW[0])&(SW[3]|SW[2]|~SW[1]|SW[0])&(SW[3]|SW[2]|~SW[1]|~SW[0])&(SW[3]|~SW[2]|~SW[1]|~SW[0])&(~SW[3]|~SW[2]|SW[1]|~SW[0]));
	assign HEX0[6]=~((SW[3]|SW[2]|SW[1]|SW[0])&(SW[3]|SW[2]|SW[1]|~SW[0])&(SW[3]|~SW[2]|~SW[1]|~SW[0])&(~SW[3]|~SW[2]|SW[1]|SW[0]));
endmodule