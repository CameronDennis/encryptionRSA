module fullsubtractor(input [15:0] x, input [15:0] y, output [15:0] O);
 
assign O =   y -  x;
 
endmodule

module mymodfunc(output reg[15:0] O, output reg Done, input [15:0] A, B, input Load,Clk,Reset,Cin);
reg[1:0] state;
reg[15:0] A_reg, B_reg, A_temp, O_reg, B_temp;
wire[15:0] O_temp;

fullsubtractor dut1(A_temp, B_temp, O_temp);

always@(posedge Clk)
begin
if(Reset)
state <= 0;
else
case(state)
	0: if(Load)begin
		A_reg <= B; 
		B_reg <= B; 
		O_reg <= A; 
		state <= 1;
                Done <= 0;
                O <= 0;
		end
	1: begin
		A_temp <= A_reg; 
		B_temp <= O_reg;  
		state <= 2;
		end
	2: begin
		O_reg <= O_temp;
		if(O_reg >= B_reg) state <= 1;
		else begin
			state <= 3; 
			Done <= 1;
			O <= O_reg;
			end
		end
	3: begin
		Done <= 0; 
		state <= 0;
		end

endcase
end
endmodule

module mymodfunc_tb;
reg clk, reset, load, cin;
reg [15:0] a, b;
wire done;
wire[15:0] out;

mymodfunc dut(out, done, a, b, load, clk, reset, cin);

always #5 clk = ~clk;
initial
begin
clk = 0;
cin = 0;
reset = 1;
load = 1;
a = 16'd1456; 
b = 16'd9;
#10 reset = 0;
#10 load = 0;
#9000 $display (" A = %d, B = %d, O = %d", a, b, out);

#10 $finish;
end
endmodule