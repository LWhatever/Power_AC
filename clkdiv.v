module clkdiv(
input clk,
input [11:0] div,
output reg clkdiv
);
reg [11:0] cnt;
wire [11:0] div1 = div>>1;

always@(posedge clk)
begin
	if(cnt>div)
		cnt <= 12'd0;
	cnt <= cnt + 12'd1;
	if(cnt == div1)
		clkdiv <= 1'b1;
	else if(cnt == div)
	begin
		clkdiv <= 1'b0;
		cnt <= 12'd0;
	end
end
endmodule
