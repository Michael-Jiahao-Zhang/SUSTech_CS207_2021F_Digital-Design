`timescale 1ns / 1ps

module decoder_main (
    input clk,
    input enable,
    input down,//up is reset, down is backspace.
    short,long, //left and right
    mid, rst, //mid for confirm
    //longest morse code is 5bit, add one bit for error-detecting
    //switch to Encode mode

    output [22:0] led_out,//one light for short, 2 for long, separate 1 between 
    output led_warn,

   output [7:0] seg_en,
   output [7:0] seg_out
    
);

wire[7:0] cur_code; //stores cuurent code, need to display in led.
wire[2:0] cur_len; //stores current code lenth
decoder_input in(clk,enable,short,long,rst,mid,down,cur_code,cur_len);
//decoder_input in(clk,enable,short,long_val,rst_val,mid_val,down_val,cur_code,cur_len); 
wire [22:0] cur_led;
//display led
decoder_led display(clk,cur_len,enable,cur_code,cur_led);

//decode
wire [7:0] tube_char;
wire [4:0] code_in;
assign code_in={cur_code[4:0]};
wire [3:0] tube_cnt;
wire ac;
decoder_dec dec(clk,enable,mid,rst,code_in,cur_len,tube_cnt,tube_char,ac);
 
 //display tube
 decoder_tube tu(enable,rst,clk,ac,tube_char,tube_cnt,seg_en,seg_out,led_warn);
 
assign led_out=cur_led;

endmodule