module core(
input clk,rst_n,
input [11:0]ADDR,
input RD,WR,
inout [15:0]DATA,
inout [3:0]KEY_H,KEY_V,
input SOMI,
output SIMO,
output SCLK,
output CS,
output spwm1, spwm2, pwm1, pwm2,
output reg en
);

wire cs0,cs1,cs2,cs3;//cs4,cs5,cs6,cs7,
wire [15:0]rddat0, data0, data1, data2, data3;//rddat4,rddat5,rddat6,rddat7,
wire irq;
wire [15:0]wrdat;
wire [13:0] MAX1, MAX2;

always@(posedge cs2)
	en <= WR?1'b0:1'b1;

BUS BUS_inst
(
	.clk(clk) ,	// input  clk_sig
	.rst_n(rst_n) ,	// input  rst_n_sig
	.ADDR(ADDR) ,	// input [11:0] ADDR_sig
	.RD(RD) ,	// input  RD_sig
	.WR(WR) ,	// input  WR_sig
	.DATA(DATA) ,	// inout [15:0] DATA_sig
	.cs0(cs0) ,	// output  cs0_sig
	.cs1(cs1) ,	// output  cs1_sig
	.cs2(cs2) ,	// output  cs2_sig
	.cs3(cs3) ,	// output  cs3_sig
	.rddat0(rddat0) ,	// input [15:0] rddat0_sig
	.rddat1(data0[15:2]) ,	// input [15:0] rddat1_sig
	.rddat2(data1[15:2]) ,	// input [15:0] rddat2_sig
	.rddat3(data2[15:2]) ,	// input [15:0] rddat3_sig
	.rddat4(data3[15:2]) ,	// input [15:0] rddat4_sig
	.rddat5(MAX1) ,	// input [15:0] rddat5_sig
	.rddat6(MAX2) ,	// input [15:0] rddat6_sig
	.wrdat(wrdat) 	// output [15:0] wrdat_sig用来改占空比
);

KEY KEY_inst
(
	.clk(clk) ,	// input  clk_sig
	.rst_n(rst_n) ,	// input  rst_n_sig
	.rddat(rddat0) ,	// output [7:0] rddat_sig
	.irq(irq) ,	// output  irq_sig
	.cs(cs0) ,	// input  cs_sig
	.KEY_H(KEY_H) ,	// inout [3:0] KEY_H_sig
	.KEY_V(KEY_V) 	// inout [3:0] KEY_V_sig
);

SPI SPI_inst
(
	.clk(clk) ,	// input  clk_sig
	.rst(rst_n) ,	// input  rst_sig
	.SIMO(SIMO) ,	// output  SIMO_sig
	.SCLK(SCLK) ,	// output  SCLK_sig
	.SOMI(SOMI) ,	// input  SOMI_sig
	.CS(CS) ,	// output  CS_sig
	.data0(data0) ,	// output [15:0] data0_sig
	.data1(data1) ,	// output [15:0] data1_sig
	.data2(data2) ,	// output [15:0] data2_sig
	.data3(data3) ,	// output [15:0] data3_sig
	.MAX1(MAX1) ,	// output [13:0] MAX1_sig
	.MAX2(MAX2) 	// output [13:0] MAX2_sig
);

SPWM SPWM_inst
(
	.clk_50m(clk) ,	// input  clk_50m_sig
	.rst_n(rst_n) ,	// input  rst_n_sig
	.spwm1(spwm1) ,	// output  spwm1_sig
	.spwm2(spwm2) ,	// output  spwm2_sig
	.pwm1(pwm1) ,	// output  pwm1_sig
	.pwm2(pwm2) ,	// output  pwm2_sig
	.datacs(cs1) ,	// input  datacs_sig
	.dataAddr(wrdat[15]) ,	// input  dataAddr_sig
	.WR(WR) ,	// input  WR_sig
	.wrdat(wrdat[14:0]), 	// input [15:0] wrdat_sig
);
endmodule

