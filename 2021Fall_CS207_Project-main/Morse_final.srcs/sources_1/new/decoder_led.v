`timescale 1ns / 1ps

module decoder_led(
input clk, [2:0]len,
input en,
input [7:0] cur_code,
output [22:0] led
    );
//    reg[24:0] cnt1;
//        wire clk_out;
//            always @ (posedge clk)
//            if(!en)
//            begin
//                cnt1<=1'b0;
//            end    
//            else
//                cnt1 <= cnt1 + 1'b1;
            
//        assign clk_out = cnt1[24];                //!取key_clk的最高位，clk过20个周期才更新一次 (2^20/100M = 10)ms 

    reg clk_out;
     reg [23:0] cnt1;
    always @(posedge clk)     
         begin
             if(!en)begin
                 cnt1 <= 0;
                 clk_out <= 0;
             end
             else begin
                 if(cnt1 == 9500000)begin //if parameter too big, simulation could fail, if too small, actual operation could fail (tested 2000000)
                     clk_out <= ~clk_out;
                     cnt1 <= 0;
                 end
                 else
                     cnt1 <= cnt1+1;
             end
         end

    reg [23:0] cur_state;
    reg[23:0] nxt_state;
    parameter len_0 = 3'b000;
    parameter len_1 = 3'b001;
    parameter len_2 = 3'b010;
    parameter len_3 = 3'b011;
    parameter len_4 = 3'b100;
    parameter len_5 = 3'b101;

    always@(posedge clk_out,negedge en)
        begin
        if(~en)
        begin
            cur_state<= 24'b0000_0000_0000_0000_0000_0000;
           // nxt_state<= 24'b0000_0000_0000_0000_0000_0000;
            end
        else
            cur_state <= nxt_state;
       end
       
       
       
    always @* 
        begin
            case(len)
            default: nxt_state=23'b00000_00000_00000_00000_000;
            len_1: case (cur_code[0])
                1'b1: nxt_state=23'b11000_00000_00000_00000_000; //1 long
                1'b0: nxt_state=23'b10000_00000_00000_00000_000; //1 short
            endcase
            len_2: case ({cur_code[1],cur_code[0]})
                2'b00:nxt_state=23'b10100_00000_00000_00000_000; //short short
                2'b01: nxt_state=23'b11010_00000_00000_00000_000;//long short
                2'b10:nxt_state=23'b10110_00000_00000_00000_000; //short long
                2'b11:nxt_state=23'b11011_00000_00000_00000_000; //long long
            endcase
            len_3: case ({cur_code[2],cur_code[1],cur_code[0]})
                3'b111:nxt_state=23'b11011_01100_00000_00000_000;
                3'b000:nxt_state=23'b10101_00000_00000_00000_000;
                3'b001:nxt_state=23'b11010_10000_00000_00000_000;//l s s
                3'b010:nxt_state=23'b10110_10000_00000_00000_000;//s l s
                3'b011:nxt_state=23'b11011_01000_00000_00000_000;//l l s
                3'b100:nxt_state=23'b10101_10000_00000_00000_000;//s s l
                3'b110:nxt_state=23'b10110_11000_00000_00000_000;//s l l
                3'b101:nxt_state=23'b11010_11000_00000_00000_000;//l s l
            endcase
            len_4: case({cur_code[3],cur_code[2],cur_code[1],cur_code[0]})
                4'b1111:nxt_state=23'b11011_01101_10000_00000_001;//N.
                4'b0000:nxt_state=23'b10101_01000_00000_00000_000;//   E.
                4'b0001:nxt_state=23'b11010_10100_00000_00000_000;//lsss E
                4'b0010:nxt_state=23'b10110_10100_00000_00000_000;//slss E
                4'b0100:nxt_state=23'b10101_10100_00000_00000_000;//ssls E
                4'b1000:nxt_state=23'b10101_01100_00000_00000_000;//sssl  E
                4'b0011:nxt_state=23'b11011_01010_00000_00000_000;//llss E
                4'b0110:nxt_state=23'b10110_11010_00000_00000_000;//slls E
                4'b1100:nxt_state=23'b10101_10110_00000_00000_001;//ssll N
                4'b0101:nxt_state=23'b11010_11010_00000_00000_000;//lsls E
               4'b1010:nxt_state=23'b10110_10110_00000_00000_001;//slsl N
                4'b1001:nxt_state=23'b11010_10110_00000_00000_000;//lssl E
                4'b0111:nxt_state=23'b11011_01101_00000_00000_001;//llls N
                4'b1101:nxt_state=23'b11010_11011_00000_00000_000;//lsll E
                4'b1011:nxt_state=23'b11011_01011_00000_00000_000;//llsl E
                4'b1110:nxt_state=23'b10110_11011_00000_00000_000;//slll E
                 default: nxt_state=23'b11111_11111_11111_11111_111; //wrong code warining
            endcase
            len_5: case({cur_code[4],cur_code[3],cur_code[2],cur_code[1],cur_code[0]}) //if the user inputs wrongly 5bit inputs, can set up a error display. (4 bits also)
                5'b11111:nxt_state=23'b11011_01101_10110_00000_000;
                5'b11110:nxt_state=23'b10110_11011_01100_00000_000;
                5'b11100:nxt_state=23'b10101_10110_11000_00000_000;
                5'b11000:nxt_state=23'b10101_01101_10000_00000_000;
                5'b10000:nxt_state=23'b10101_01011_00000_00000_000;
                5'b00000:nxt_state=23'b10101_01010_00000_00000_000;
                5'b00001:nxt_state=23'b11010_10101_00000_00000_000;
                5'b00011:nxt_state=23'b11011_01010_10000_00000_000;
                5'b00111:nxt_state=23'b11011_01101_01000_00000_000;
                5'b01111:nxt_state=23'b11011_01101_10100_00000_000;
                default: nxt_state=23'b11111_11111_11111_11111_111;
            endcase
            endcase
            end

                assign led=cur_state;
                
endmodule
