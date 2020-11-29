`include "hw8.v"
`include "myexp.v"

module proj2(
    output reg cal_done,
    output reg[15:0] cal_val,
    input [15:0]private_key,
    public_key,
    message_val,
    input clk,
    start,
    rst);
reg[5:0] state;
reg[7:0] expIn, exponent;
reg expLoad, expCin;
wire expDone, expCout;
wire[15:0] expResult;
myexp exp1(expResult, expDone, expCout, expIn, exponent, expLoad, clk, rst, expCin);
reg[15:0] modIn, modulus; 
reg modLoad, modCin;
wire modDone;
wire [15:0] modResult;
mymodfunc mod1(modResult, modDone, modIn, modulus, modLoad, clk, rst, modCin);

reg[15:0] prvKey, pubKey, mesVal;
//parameters
parameter Capture_state = 5'd0;
parameter Exponent_state1 = 5'd1;
parameter Exponent_state2 = 5'd2;
parameter Exponent_state3 = 5'd3;
parameter Mod_state1 = 5'd4;
parameter Mod_state2 = 5'd5;
parameter Mod_state3 = 5'd6;
parameter Cal_done_state1 = 5'd7;
parameter Cal_done_state2 = 5'd8;
parameter Cal_done_state3 = 5'd9;

always@(posedge clk) begin
    if(rst) begin
        state <= 1'b0;
        expIn <= 1'b0;
        exponent <= 1'b0;
        expLoad <= 1'b0;
        expCin <= 1'b0;
        modIn <= 1'b0;
        modulus <= 1'b0;
        modLoad <= 1'b0;
        modCin <= 1'b0;
    end
    else
    case(state)
        Capture_state: if(start)begin
            cal_val <= 1'b0;
            cal_done <= 1'b0;
            prvKey <= private_key;
            pubKey <= public_key;
            mesVal <= message_val;
            state <= Exponent_state1;
        end
        Exponent_state1:begin
            expIn <= mesVal;
            exponent <= prvKey;
            expLoad <= 1'b1;
            state <= Exponent_state2;
        end
        Exponent_state2:begin
            expLoad <= 1'b0;
            state <= Exponent_state3;
        end
        Exponent_state3:begin
            if(!expDone) begin
                state <= Exponent_state2;
            end
            else state <= Mod_state1;
        end
        Mod_state1:begin
            modIn <= expResult;
            modulus <= pubKey;
            modLoad <= 1'b1;
            state <= Mod_state2;
        end
        Mod_state2:begin
            modLoad <= 1'b0;
            state <= Mod_state3;
        end
        Mod_state3:begin
            if(!modDone) begin
                state <= Mod_state2;
            end
            else state <= Cal_done_state1;
        end
        Cal_done_state1:begin
            cal_done <= 1'b1;
            cal_val <= modResult;
            state <= Capture_state;
        end
    endcase
end


endmodule
module proj2_tb;
reg [15:0]private_key, public_key, message_val;
reg clk, rst, start;
wire cal_done;
wire [15:0]cal_val;
parameter Capture_state = 5'd0;
parameter Exponent_state1 = 5'd1;
parameter Exponent_state2 = 5'd2;
parameter Exponent_state3 = 5'd3;
parameter Mod_state1 = 5'd4;
parameter Mod_state2 = 5'd5;
parameter Mod_state3 = 5'd6;
parameter Cal_done_state1 = 5'd7;
proj2 dut(cal_done, cal_val, private_key, public_key, message_val, clk, start, rst);

always #5 clk = ~clk;
always @(dut.state) begin
    case(dut.state)
        Capture_state: $display($time, " Capture_state");
        Exponent_state1: $display($time, " Exponent_state1");
        Exponent_state2: $display($time, " Exponent_state2");
        Exponent_state3: $display($time, " Exponent_state3");
        Mod_state1: $display($time, " Mod_state1");
        Mod_state2: $display($time, " Mod_state2");
        Mod_state3: $display($time, " Mod_state3");
        Cal_done_state1: $display($time, " Cal_done_state1");
    endcase
end

initial begin
    clk = 0;
    rst = 1;
    message_val = 4'd9;
    private_key = 2'd3;
    public_key = 6'd33;
    $display($time, " Message = %d, Private Key = %d, Public Key = %d", message_val, private_key, public_key);
    #10 rst = 0;
    #10 start = 1;
    #10 start = 0;
    #9000 $display($time, " Encrypted Message = %d, Calculation Done = %d", cal_val, cal_done);
    $finish;
end


endmodule