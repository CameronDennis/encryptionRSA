module fullsubtractor
(
 input [15:0] x,
 input [15:0] y,
 output wire [15:0] O 
 );
 
assign O =   y -  x;
 
endmodule

module mymodfunc(output reg[15:0] O, output reg Done, input[15:0] A, B, input Load, Clk, Reset);
	reg [15:0] A_temp, B_temp, A_reg, B_reg, O_reg;
	wire [15:0] O_temp;
	reg [2:0]state;
	fullsubtractor dut1(B_temp, A_temp, O_temp);
	always @(posedge Clk or posedge Reset) begin
		if (Reset == 1) begin
			state <= 0;
		end
		case (state)
			0: if (Load) begin
				A_reg <= A;
				B_reg <= B;
				state <= 1;
			end
			1: begin
				A_temp <= A_reg;
				B_temp <= B_reg;
				state = 2;
			end
			2: begin
				if (O_temp > B) begin
					state <= 1;
					A_reg <= O_temp;
				end
				else begin
					Done = 1;
					state = 3;
				end
			end
			3: begin
				O <= O_temp;
				Done = 0;
				state = 0;
			end
		endcase
	end
endmodule

module mymodfunc_tb;
reg clk, reset, load;
reg [15:0] a, b;
wire done;
wire[15:0] out;

mymodfunc dut(out, done, a, b, load, clk, reset);

	always #5 clk = ~clk;
	initial
	begin
	clk = 0;
	reset = 1;
	#20 reset = 0;
	a = 16'd1456; 
	b = 8'd9;
	#10 load = 1;
	#10 load = 0;
	#10000 $display (" A = %d, B = %d, O = %d", a, b, out);

	#10 $finish;
	end
endmodule
