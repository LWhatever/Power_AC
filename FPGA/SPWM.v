module SPWM(
input clk_50m,
input rst_n,
output reg spwm1,
output reg spwm2,
output wire pwm1,
output wire pwm2,
input datacs,
input dataAddr,					//write data address
input WR,
input [15:0] wrdat
);

reg [15:0] KW=16'd141;
reg [9:0] DutyCycle =10'd500;
reg [15:0] cnt;
wire [7:0] addr=cnt[15:8];		//the address of the sintable
wire [7:0] tri_wave;
wire [7:0] sin;
reg [4:0] cnt1;
reg [4:0] cnt2;
wire clk_19_5k,clk_10m;

always@(posedge clk_19_5k) begin
		cnt<=cnt+KW;
end

always@(posedge clk_50m or negedge rst_n)
begin
	if(!rst_n) begin
		KW <= 141;
		DutyCycle <= 500;
	end
	else if(datacs&WR)
	begin
		if(dataAddr == 1'b0)
			KW <= wrdat;
		else if(dataAddr ==1'b1)
			DutyCycle <= wrdat[9:0];
	end	
end

always@(posedge clk_50m)
begin
	if(!rst_n) begin
		spwm1<=0;
		spwm2<=0;
	end
	else if(sin>=tri_wave)
	begin
		spwm2<=0;
		cnt2<=0;
		cnt1<=cnt1+4'd1;
		if(cnt1>=20)
			spwm1=1;
	end
	else begin
		spwm1<=0;
		cnt1<=0;
		cnt2<=cnt2+4'd1;
		if(cnt2>=20)
			spwm2=1;
	end
end

clkdiv clkdiv_inst(				//gain a clock of 19.5kHz
	.clk(clk_50m),
	.div(12'd2560),
	.clkdiv(clk_19_5k)
	);
	
clkdiv clkdiv_inst2(				//gain a clock of 10MHz
	.clk(clk_50m),
	.div(12'd5),
	.clkdiv(clk_10m)
	);

tri_wave tri_wave_inst
(
	.clk(clk_10m) ,	// input  clk_sig
	.wave_cnt(tri_wave) 	// output [10:0] wave_cnt_sig
);

dds_rom dds_rom_inst(		//sintable
	.address(addr),
	.clock(clk_19_5k),
	.q(sin)
	);

pwm pwm_inst
(
	.CLOCK(clk_50m) ,	// input  CLOCK_sig
	.CCR1(DutyCycle) ,	// input [9:0] CCR1_sig
	.clk1(pwm1) ,	// output  clk1_sig
	.clk2(pwm2) 	// output  clk2_sig
);
endmodule


	
