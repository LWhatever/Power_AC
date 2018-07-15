//module pwm
//(
//	input clk_2M,
//	input [6:0] DutyCycle,
//	output reg pwm
//);
//
//reg [6:0] cnt;
//
//	
//always@(posedge clk_2M)
//begin
//	if(cnt<7'd99)
//		cnt<=cnt+6'd1;
//	else
//		cnt<=0;
//	if(cnt<DutyCycle)
//		pwm=1'b1;
//	else pwm=1'b0;
//end
//
//endmodule

module pwm(CLOCK, CCR1, clk1, clk2);
	input CLOCK;
	input [9:0] CCR1;
	output clk1, clk2;
	reg clk1, clk2;
	reg pclk, En, Edg;
	wire Ok;
	reg [9:0] cnt;
	delay d1(En, CLOCK, 4'b1111, Ok);
	
	always@(posedge CLOCK)
	begin
		cnt <= cnt + 10'd1;
		if(cnt == CCR1)
		begin
			pclk <= 1'b1;
			En <= 1'b1;
		end
		else if(cnt == 10'd1000)
		begin
			pclk <= 1'b0;
			cnt <= 0;
			En <= 1'b1;
		end
		
		if(pclk == 1'b1)
		begin
			clk1 <= 0;
			if(Ok)
			begin
				clk2 <= 1'b1;
				En <= 0;
			end
		end
		else if(pclk == 1'b0)
		begin
			clk2 <= 0;
			if(Ok)
			begin
				clk1 <= 1'b1;
				En <= 0;
			end
		end
	end
endmodule

module delay(en,clk,ed,ok);
	input en,clk;
	input [3:0] ed;
	output ok;
	reg [3:0] count;
	reg ok;
	always@(posedge clk)
	begin
		if(en)
		begin
			ok <= 0;
			count <= count+4'b0001;
		end
		if(count == ed)
			ok <= 1;
	end
endmodule
