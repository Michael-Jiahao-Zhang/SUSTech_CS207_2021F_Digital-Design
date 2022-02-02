`timescale 1ns / 1ps

module decoder_tube(en,rst, clk, acc,char,num_seg, seg_en, seg_out,led_warn);
    input en;
	input rst;
	input clk;	    //100MHz
	input acc;
	//input mid; //accepted code
	input [7:0] char;
    input  [3:0] num_seg;      //需要亮几个灯
	output reg [7:0] seg_en;	//哪个灯亮
	output reg [7:0] seg_out;	//灯怎么亮（亮哪几个数码管）
	output reg led_warn;
    reg clk_seg;
    reg [23:0] cnt;          //基于clk的计数子
    reg [2:0] scan_cnt;     //基于分频后时钟clk_seg的计数子
    
    parameter period = 200000;  //500Hz 稳定

    
    //8 codes to display
    reg [7:0] cd_1=8'b11111111;
    reg [7:0]cd_2=8'b11111111;
    reg[7:0] cd_3=8'b11111111;
    reg[7:0] cd_4=8'b11111111;
    reg [7:0] cd_5=8'b11111111;
    reg [7:0]cd_6=8'b11111111;
    reg[7:0] cd_7=8'b11111111;
    reg[7:0] cd_8=8'b11111111;
    
    //fsm of which code to input
    reg[3:0] cur_code;
    reg[3:0] nxt_code;
    always @(posedge clk, posedge rst)	//分频为clk_seg
    begin
        if(!en)
            begin
            cnt<=0;
            clk_seg<=0;
            end
        else if (rst)    //复位
            begin
            cnt <= 0;   //cnt归0
            clk_seg <= 0;   //clk归0
            end
        else begin
            if (cnt == (period >> 1) - 1)       //右移除以2为半个周期，当半个周期结束
                begin
                clk_seg <= ~clk_seg;    //clk取反，两次取反为一个周期
                cnt <= 0;       //cnt归0
                end
            else
                cnt <= cnt + 1; //cnt递增
        end
    end

        always@(posedge clk_seg, posedge rst)    //根据clk_seg改变scan_cnt
        begin
//tried adding en,not working
            if (rst)    //复位
                scan_cnt <= 0;  //scan_cnt归0
            else begin
                scan_cnt <= scan_cnt + 1;   //scan_cnt递增
                if (scan_cnt == 3'd7)   //scan_cnt一个周期完成
                    scan_cnt <= 0;      //scan_cnt归0
            end
        end
        
        
          always@(num_seg,char) //changed from * to this
                    begin
                        case(num_seg)
                            4'b0000: begin  cd_1=char; end
                            4'b0001:begin cd_2=char; end
                            4'b0010:begin cd_3=char;end
                            4'b0011:begin cd_4=char;end
                            4'b0100: begin cd_5=char; end
                            4'b0101:begin cd_6=char; end
                            4'b0110:begin cd_7=char;end
                            4'b0111:begin   cd_8=char; end
                            //already full, need warning.
                            //default:begin  cd_8=cd_8; cd_7=cd_7;cd_6=cd_6; cd_5=cd_5;cd_4=cd_4; cd_3=cd_3;cd_2=cd_2;cd_1=cd_1; end
                          endcase
                      end                    



    always @(scan_cnt) //changed * to scan_cnt
    begin
        if(num_seg == 0) begin
        led_warn=0;
            case(scan_cnt)
                0: seg_en = 8'b1111_1111;
                1: seg_en = 8'b1111_1111;
                2: seg_en = 8'b1111_1111;
                3: seg_en = 8'b1111_1111;
                4: seg_en = 8'b1111_1111;
                5: seg_en = 8'b1111_1111;
                6: seg_en = 8'b1111_1111;
                7: seg_en = 8'b1111_1111;
                default: seg_en = 8'b1111_1111;
            endcase
        end

        if(num_seg == 1) begin
         led_warn=0;
            case(scan_cnt)
                0: seg_en = 8'b0111_1111;
                1: seg_en = 8'b1111_1111;
                2: seg_en = 8'b1111_1111;
                3: seg_en = 8'b1111_1111;
                4: seg_en = 8'b1111_1111;
                5: seg_en = 8'b1111_1111;
                6: seg_en = 8'b1111_1111;
                7: seg_en = 8'b1111_1111;
                default: seg_en = 8'b1111_1111;
            endcase
        end

        if(num_seg == 2) begin
         led_warn=0;
            case(scan_cnt)
                0: seg_en = 8'b0111_1111;
                1: seg_en = 8'b1011_1111;
                2: seg_en = 8'b1111_1111;
                3: seg_en = 8'b1111_1111;
                4: seg_en = 8'b1111_1111;
                5: seg_en = 8'b1111_1111;
                6: seg_en = 8'b1111_1111;
                7: seg_en = 8'b1111_1111;
                default: seg_en = 8'b1111_1111;
            endcase
        end

        if(num_seg == 3) begin
         led_warn=0;
            case(scan_cnt)
                0: seg_en = 8'b0111_1111;  
                1: seg_en = 8'b1011_1111;
                2: seg_en = 8'b1101_1111;
                3: seg_en = 8'b1111_1111;
                4: seg_en = 8'b1111_1111;
                5: seg_en = 8'b1111_1111;
                6: seg_en = 8'b1111_1111;
                7: seg_en = 8'b1111_1111;
                default: seg_en = 8'b1111_1111;
            endcase
        end

        if(num_seg == 4) begin
         led_warn=0;
            case(scan_cnt)
                0: seg_en = 8'b0111_1111;
                1: seg_en = 8'b1011_1111;
                2: seg_en = 8'b1101_1111;
                3: seg_en = 8'b1110_1111;
                4: seg_en = 8'b1111_1111;
                5: seg_en = 8'b1111_1111;
                6: seg_en = 8'b1111_1111;
                7: seg_en = 8'b1111_1111;
                default: seg_en = 8'b1111_1111;
            endcase
        end

        if(num_seg == 5) begin
         led_warn=0;
            case(scan_cnt)
                0: seg_en = 8'b0111_1111;
                1: seg_en = 8'b1011_1111;
                2: seg_en = 8'b1101_1111;
                3: seg_en = 8'b1110_1111;
                4: seg_en = 8'b1111_0111;
                5: seg_en = 8'b1111_1111;
                6: seg_en = 8'b1111_1111;
                7: seg_en = 8'b1111_1111;
                default: seg_en = 8'b1111_1111;
            endcase
        end

        if(num_seg == 6) begin
         led_warn=0;
            case(scan_cnt)
            0: seg_en = 8'b0111_1111;
            1: seg_en = 8'b1011_1111;
            2: seg_en = 8'b1101_1111;
            3: seg_en = 8'b1110_1111;
            4: seg_en = 8'b1111_0111;
            5: seg_en = 8'b1111_1011;
            6: seg_en = 8'b1111_1111;
            7: seg_en = 8'b1111_1111;
                default: seg_en = 8'b1111_1111;
            endcase
        end

        if(num_seg == 7) begin
         led_warn=0;
            case(scan_cnt)
                0: seg_en = 8'b0111_1111; 
                1: seg_en = 8'b1011_1111;
                2: seg_en = 8'b1101_1111;
                3: seg_en = 8'b1110_1111;
                4: seg_en = 8'b1111_0111;
                5: seg_en = 8'b1111_1011;
                6: seg_en = 8'b1111_1101;
                7: seg_en = 8'b1111_1111;
                default: seg_en = 8'b1111_1111;
            endcase
        end

        if(num_seg == 8) begin
        
            led_warn=1;
            case(scan_cnt)
                0: seg_en = 8'b0111_1111; 
                1: seg_en = 8'b1011_1111;
                2: seg_en = 8'b1101_1111;
                3: seg_en = 8'b1110_1111;
                4: seg_en = 8'b1111_0111;
                5: seg_en = 8'b1111_1011;
                6: seg_en = 8'b1111_1101;
                7: seg_en = 8'b1111_1110;
                default: seg_en = 8'b1111_1111;
            endcase
        end
    end
    
    always @(scan_cnt)      //当scan_cnt变化，seg_out也改变(灯显示不同的数字) changed * to scan_cnt
    begin
        case(scan_cnt)
            0: seg_out = cd_1; // 0
            1: seg_out = cd_2; // 1
            2: seg_out = cd_3; // 2
            3: seg_out = cd_4; // 3
            4: seg_out = cd_5; // 4
            5: seg_out = cd_6; // 5
            6: seg_out = cd_7; // 6
            7: seg_out = cd_8; // 7
            //8: seg_out = 8'b10000000; // 8
            //9: seg_out = 8'b10010000; // 9
            default: seg_out = 8'b11111111;
        endcase
    end
endmodule