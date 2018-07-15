module tri_wave(
input clk,
output [7:0] wave_cnt
);
reg [10:0] wave = 0;
always@(posedge clk)
begin
	if(wave < 12'd2040)
		wave <= wave + 11'd3;
	else
		wave <= 11'd0;
end
assign wave_cnt[7:0] = wave[10:3];
endmodule