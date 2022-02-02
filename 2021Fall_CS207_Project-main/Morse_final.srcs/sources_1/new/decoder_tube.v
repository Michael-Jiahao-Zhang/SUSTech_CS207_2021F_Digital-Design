`timescale 1ns / 1ps

module decoder_tube(en,rst, clk, acc,char,num_seg, seg_en, seg_out,led_warn);
    input en;
	input rst;
	input clk;	    //100MHz
	input acc;
	//input mid; //accepted code
	input [7:0] char;
    input  [3:0] num_seg;      //��Ҫ��������
	output reg [7:0] seg_en;	//�ĸ�����
	output reg [7:0] seg_out;	//����ô�������ļ�������ܣ�
	output reg led_warn;
    reg clk_seg;
    reg [23:0] cnt;          //����clk�ļ�����
    reg [2:0] scan_cnt;     //���ڷ�Ƶ��ʱ��clk_seg�ļ�����
    
    parameter period = 200000;  //500Hz �ȶ�

    
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
    always @(posedge clk, posedge rst)	//��ƵΪclk_seg
    begin
        if(!en)
            begin
            cnt<=0;
            clk_seg<=0;
            end
        else if (rst)    //��λ
            begin
            cnt <= 0;   //cnt��0
            clk_seg <= 0;   //clk��0
            end
        else begin
            if (cnt == (period >> 1) - 1)       //���Ƴ���2Ϊ������ڣ���������ڽ���
                begin
                clk_seg <= ~clk_seg;    //clkȡ��������ȡ��Ϊһ������
                cnt <= 0;       //cnt��0
                end
            else
                cnt <= cnt + 1; //cnt����
        end
    end

        always@(posedge clk_seg, posedge rst)    //����clk_seg�ı�scan_cnt
        begin
//tried adding en,not working
            if (rst)    //��λ
                scan_cnt <= 0;  //scan_cnt��0
            else begin
                scan_cnt <= scan_cnt + 1;   //scan_cnt����
                if (scan_cnt == 3'd7)   //scan_cntһ���������
                    scan_cnt <= 0;      //scan_cnt��0
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
    
    always @(scan_cnt)      //��scan_cnt�仯��seg_outҲ�ı�(����ʾ��ͬ������) changed * to scan_cnt
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