module top (
            input switch,
            input clk,
            input rst,
            input down,
            input short,
            input long,
            input mid,
            input   up,     //ÕÀ∏Ò
            input   [3:0] row,                     // æÿ’Ûº¸≈Ã ––
            input key_on1,key_on2,key_on3,key_on4,key_on5,key_on6,key_on7,key_on8,key_on_all,key_on_mus,
            input modulee,
            output [3:0] col,                 // æÿ’Ûº¸≈Ã ¡–
            output reg [22:0] led_out,
            output led_warn,
            output reg [7: 0] seg_en,
            output reg [7: 0] seg_out,
            output beep);     //TODO

//TODO
wire [7:0] seg_en_ecd;
wire [7:0] seg_out_ecd;
wire [7:0] seg_en_dcd;
wire [7:0] seg_out_dcd;
wire[22:0] led_dec;
reg [22:0] led_enc=23'b00000_00000_00000_00000_010;

encoder_main e(clk, rst, up, row,
    key_on1,key_on2,key_on3,key_on4,key_on5,key_on6,key_on7,key_on8,
    key_on_all,key_on_mus,modulee,switch,col, seg_en_ecd,seg_out_ecd,beep);
decoder_main d(clk, switch, down, short, long, mid, rst, led_dec,//one light for short, 2 for long, separate 1 between 
   led_warn,seg_en_dcd, seg_out_dcd);

always @(switch) begin
    if (!switch) begin   //encoder   //TODO
        seg_en  = seg_en_ecd;
        seg_out = seg_out_ecd;
        led_out=led_enc;
        
    end
    else begin      //decoder       //TODO
        seg_en  = seg_en_dcd;
        seg_out = seg_out_dcd;
        led_out=led_dec;
        
    end
end

endmodule
