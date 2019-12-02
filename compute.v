module subtract(input signed [11:0]dataa, datab, input clock, output reg overflow, output reg signed [11:0] result);
	
	reg signed [11:0] datab_inv, datab_c;
	reg rhs, lhs;
	
	always@(posedge clock)
	begin
		datab_inv = ~datab;
		datab_c = datab_inv + 1;
		result = dataa + datab_c;
		
		rhs = dataa[11] == datab_c[11];
		lhs = dataa[11] != result[11] ;
		overflow = rhs && lhs;
	end
	
endmodule	

module addition(input signed [11:0]dataa, datab, input clock, output reg overflow, output reg signed [11:0] result);
	
//	wire signed [11:0] dataa_w, datab_w;
//	assign dataa_w = dataa;
//	assign datab_w = datab;
	
	always@(posedge clock)
	begin
		result = dataa + datab;
		
		overflow = (dataa[11] == datab[11]) && (dataa[11] != result[11]);
	end
endmodule 

module multiplication(input signed [11:0]dataa, datab, input clock, output reg signed result);
	
	always@(posedge clock)
	begin 
		result = dataa * datab;
	end
	
endmodule

module compute(input [11:0] x,
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
reg [11:0]Prod1r;
reg [11:0]x_sqr;
reg [11:0]Prod2r;
reg [11:0]x_cbr;
reg [11:0]Prod3r;
reg [11:0]res1r;
reg [11:0]res2r;
reg [11:0]sumr;
wire overflowFlag1;
wire overflowFlag2;
wire overflowFlag3;


always@(posedge clock)
begin
	Prod1r <= Prod1;
	x_sqr <= x_sq;
	Prod2r <= Prod2;
	x_cbr <= x_cb;
	Prod3r <= Prod3;
	res1r <= res1;
	res2r <= res2;
	sumr <= sum; 
end

//cyc1
multiplication multiplication1(.dataa(x), .datab(param_in1),.clock(clock), .result(Prod1));
//CYC1.clock(clock),
multiplication multiplication2(.dataa(x), .datab(x),.clock(clock), .result(x_sq));
//Cyc2
multiplication multiplication3(.dataa(x), .datab(x_sq),.clock(clock), .result(x_cb));
//Cyc2
multiplication multiplication4(.dataa(x_sq), .datab(param_in2),.clock(clock), .result(Prod2));
//Cyc3
multiplication multiplication5(.dataa(x_cb), .datab(param_in3),.clock(clock), .result(Prod3));
//Cyc2
addition addition1(.dataa(param_in0), .clock(clock),.datab(Prod1), .overflow(overflowFlag1), .result(res1));
//Cyc3
addition addition2(.dataa(res1), .clock(clock), .datab(Prod2), .overflow(overflowFlag2), .result(res2));
//Cyc4
addition addition3(.dataa(res2), .clock(clock), .datab(Prod3), .overflow(overflowFlag3), .result(sum));



always@(posedge clock)
begin
if((~reset) || overflowFlag1 || overflowFlag2 || overflowFlag3)
out <= 12'd0;
else
out <= sum;
end

endmodule
	