module background(
      CLOCK_50,                  // On Board 50 MHz
      VGA_CLK,                   // VGA Clock
      VGA_HS,                    // VGA H_SYNC
      VGA_VS,                    // VGA V_SYNC
      VGA_BLANK_N,                  // VGA BLANK
      VGA_SYNC_N,                // VGA SYNC
      VGA_R,                     // VGA Red[9:0]
      VGA_G,                     // VGA Green[9:0]
      VGA_B,                     // VGA Blue[9:0]
      KEY,
      SW,
		HEX0, 
		HEX1, 
		HEX2, 
		HEX3,
		HEX4, 
		HEX5
   );

   input CLOCK_50;               // 50 MHz
   input [9:0] SW;
   input [3:0] KEY;
   output         VGA_CLK;       // VGA Clock
   output         VGA_HS;        // VGA H_SYNC
   output         VGA_VS;        // VGA V_SYNC
   output         VGA_BLANK_N;   // VGA BLANK
   output         VGA_SYNC_N;    // VGA SYNC
   output   [9:0] VGA_R;         // VGA Red[9:0]
   output   [9:0] VGA_G;         // VGA Green[9:0]
   output   [9:0] VGA_B;         // VGA Blue[9:0]
	output   [6:0] HEX0;
	output   [6:0] HEX1;
	output   [6:0] HEX2;
	output   [6:0] HEX3;
	output   [6:0] HEX4;
	output   [6:0] HEX5;

   wire [2:0] colour;
   assign colour = SW[8:6];
   wire [2:0] DataColor;
   reg [8:0] x_vga;
   reg [7:0] y_vga;
   reg signed [11:0] x, y;
	wire signed [11:0] x_val, y_val;
	wire signed [11:0] y_o, x_o, y_c;
	
   wire signed [11:0] c0, c1, c2, c3;//parameters
	
	//signals
	reg plot_done;
	wire training_done;
   wire overflow;
	reg plot;
	wire draw;
	wire finished_training;
	
	reg [4:0] state, next_state;//state registers
	
	localparam IDLE       = 5'd0,
				  plot_xy1   = 5'd1,
				  plot_xy1_w = 5'd2,
				  plot_xy2   = 5'd3,
				  plot_xy2_w = 5'd4,
				  plot_xy3   = 5'd5,
				  plot_xy3_w = 5'd6,
				  plot_xy4   = 5'd7,
				  plot_xy4_w = 5'd8,
				  plot_w     = 5'd9,
				  plot_do    = 5'd10;
	
	always@(posedge CLOCK_50)
	begin:state_ffs
		if(SW[9])
			state <= IDLE;
		else
			state <= next_state;
	end
				  
	always@(posedge CLOCK_50)
	begin:State_table
		case(state)
			IDLE: next_state = draw ? plot_xy1 : IDLE;
			plot_xy1: next_state = draw ? plot_xy1 : plot_xy1_w;
			plot_xy1_w: next_state = draw ? plot_xy2 : plot_xy1_w;
			plot_xy2: next_state = draw ? plot_xy2 : plot_xy2_w;
			plot_xy2_w: next_state = draw ? plot_xy3 : plot_xy2_w;
			plot_xy3: next_state = draw ? plot_xy3 : plot_xy3_w;
			plot_xy3_w: next_state = draw ? plot_xy4 : plot_xy3_w;
			plot_xy4: next_state = draw ? plot_xy4 : plot_xy4_w;
			plot_xy4_w: next_state = training_done ? plot_do : plot_xy4_w;
			plot_do: next_state = plot_done ? plot_w : plot_do;
			plot_w: begin
							if(finished_training)
								begin	
									next_state = IDLE;
								end
							else
								begin
									if(training_done)
										begin
											next_state = plot_do;
										end
									else
										begin
											next_state = plot_w;
										end
								end
						end
			default: next_state = IDLE;
		endcase
	end
	
	always@(posedge CLOCK_50)
	begin:FSM
		case(state)
			IDLE: begin
						plot <= 0;
						plot_done <= 0; 
					end
			plot_xy1: begin
							if(draw)begin
								plot <= 1;
								x <= x_val;
								y <= y_val;
								end
							else
								plot <= 0;
						 end
			plot_xy2: begin
							if(draw)begin
								plot <= 1;
								x <= x_val;
								y <= y_val;
								end
							else
								plot <= 0;
						 end
			plot_xy3: begin
							if(draw)begin
								plot <= 1;
								x <= x_val;
								y <= y_val;
								end
							else
								plot <= 0;
						 end
			plot_xy4: begin
							if(draw)begin
								plot <= 1;
								x <= x_val;
								y <= y_val;
								end
							else
								plot <= 0;
						 end
			plot_xy4_w: begin
								x <= (~12'd160) + 1;
						   end
			plot_do: begin
						plot<= 1;
						x <= x + 1;//counter
						y <= y_c;
						if(x == 12'd159)
							begin
								plot_done <= 1;
								x <= 0;
							end
					  end
			plot_w: begin
						plot<= 0;
						plot_done <= 0;
					  end
			endcase
	end
								
	
	polynomial_reg train(.SW(SW), .KEY(KEY), .finished_training(finished_training), .CLOCK_50(CLOCK_50), .plot_done(plot_done), .param_out0(c0), 
								 .param_out1(c1), .param_out2(c2), .param_out3(c3), .HEX0(HEX0), 
								 .HEX1(HEX1), .HEX2(HEX2), .HEX3(HEX3), .x_val(x_val), .y_val(y_val),
								 .HEX4(HEX4), .HEX5(HEX5), .training_done(training_done), .draw(draw));
	 
	 compute comp(.x(x),
					.param_in0(c0),
					.param_in1(c1),
					.param_in2(c2),
					.param_in3(c3),
					.reset(~SW[9]),
					.clock(CLOCK_50),
					.out(y_c));

		
	 //we transform the y_vga & x_vga values for our coordinate system
	 always@(posedge CLOCK_50)
	 begin
		if(y > 12'd120)	
			y_vga = 12'd0;
		else if(y[11] == 1'b1)	
			y_vga = 12'd120;
		else
		 y_vga = ~((y - 12'd240) - 12'b000000000001);
		 
		 x_vga = ~(x + 12'd160);
	 end
	
	//vga adapter module
   vga_adapter VGA(
			.resetn(~SW[9]),
			.clock(CLOCK_50),			
			.colour(SW[9:7]),
			.x(x_vga),
			.y(y_vga),
			.plot(plot),
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "320x240";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "display.mif";
        
  
endmodule
