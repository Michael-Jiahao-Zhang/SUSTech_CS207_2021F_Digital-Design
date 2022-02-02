`timescale 1ns / 1ps

module keyANDseg (
    input   clk,    // ϵͳʱ��
    input   switch, // ����
    input   rst,    // ��λ�ź�
    input   up,     //�˸�
    input   [3:0] row,                     // ������� ��
    input   key_on1,key_on2,key_on3,key_on4,key_on5,key_on6,key_on7,key_on8,key_on_all,key_on_mus,
    input modulee,
    output  reg [3:0] col,                 // ������� ��
    output  reg [7:0] seg_en,              // �����ĸ�����
    output  reg [7:0] seg_out,              // ����ÿ������ô����ͬʱ���ļ�������ܣ�
    output beep
    );
    
    // +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    // С���̿�ʼ
    wire up_out;
    
    //�˸��up������ʼ
    debounce_up u(clk, ~rst, up, up_out);
    // ��Ƶ���� ��ʼ
    reg [19:0] cnt1;
    reg key_on;
    reg [3:0]val;
    reg [35:0] cnt_buzzer;
    reg [35:0] time1,time2,time3,time4,time5,time6,time7,time8;
    wire key_clk;
    reg [3:0] num_seg;
    reg [3:0] num_pressed;
    reg [3:0] num_back;
    
    
    //������
    
    always@(posedge clk, posedge rst)
        begin
            if(switch)
            begin
                cnt_buzzer<=1'b0;
            end    
            else if(rst)
            begin 
                cnt_buzzer <= 1'b0;
            end
            else if(key_on_all==0)
            begin
                 cnt_buzzer <= 1'b0;
            end
            else if(cnt_buzzer != 35'd9_999_999_999)    //100s
                cnt_buzzer <= cnt_buzzer + 1'b1;
                
            else 
                cnt_buzzer <= 1'b0;        //���
        end
        
        
    always @ (posedge clk, posedge rst)
        if(switch)
        begin
            cnt1<=1'b0;
        end    
        else if (rst)
            cnt1 <= 0;
        else
            cnt1 <= cnt1 + 1'b1;
        
    assign key_clk = cnt1[19];                //!ȡkey_clk�����λ��clk��20�����ڲŸ���һ�� (2^20/100M = 10)ms 
    // ��Ƶ���� ����

    // ״̬��
    parameter NO_KEY_PRESSED = 6'b000_001;  // û�а�������  
    parameter SCAN_COL0      = 6'b000_010;  // ɨ���0�� 
    parameter SCAN_COL1      = 6'b000_100;  // ɨ���1�� 
    parameter SCAN_COL2      = 6'b001_000;  // ɨ���2�� 
    parameter SCAN_COL3      = 6'b010_000;  // ɨ���3�� 
    parameter KEY_PRESSED    = 6'b100_000;  // �а�������
    parameter TIME1_0   =   35'd650_000_000;
    parameter TIME2_0   =   35'd600_000_000;
    parameter TIME3_0   =   35'd550_000_000;
    parameter TIME4_0   =   35'd500_000_000;
    parameter TIME5_0   =   35'd450_000_000;
    parameter TIME6_0   =   35'd500_000_000;
    parameter TIME7_0   =   35'd550_000_000;
    parameter TIME8_0   =   35'd600_000_000;
    parameter TIME9_0   =   35'd650_000_000;
    parameter TIME0_0   =   35'd700_000_000;
    parameter t = 30'd300_000_000;
    reg [5:0] current_state, next_state;    // ��̬����̬

    always @ (posedge key_clk, posedge rst)
        if(switch)
        begin
            current_state <= NO_KEY_PRESSED;
        end    
        else if (rst)
            current_state <= NO_KEY_PRESSED;
        else
            current_state <= next_state;    //����key_clk�ı仯����"����һ��״̬"��״̬Ǩ��

    
    // ��������ת��״̬
    always @ (*)
    if(!switch)begin
        case (current_state)    //���а������£�row != 4h'F,��col0��ʼһ��һ��ɨ��
            NO_KEY_PRESSED :                    // û�а�������
                if (row != 4'hF)
                next_state = SCAN_COL0;
                else
                next_state = NO_KEY_PRESSED;
            SCAN_COL0 :                         // ɨ���0�� 
                if (row != 4'hF)
                next_state = KEY_PRESSED;
                else
                next_state = SCAN_COL1;
            SCAN_COL1 :                         // ɨ���1�� 
                if (row != 4'hF)
                next_state = KEY_PRESSED;
                else
                next_state = SCAN_COL2;    
            SCAN_COL2 :                         // ɨ���2��
                if (row != 4'hF)
                next_state = KEY_PRESSED;
                else
                next_state = SCAN_COL3;
            SCAN_COL3 :                         // ɨ���3��
                if (row != 4'hF)
                next_state = KEY_PRESSED;
                else
                next_state = NO_KEY_PRESSED;
            KEY_PRESSED :                       // �а�������
                if (row != 4'hF)
                next_state = KEY_PRESSED;
                else
                next_state = NO_KEY_PRESSED;                      
        endcase
    end
    //next_state�����ɨ��Ľ������next_state����row != 4'hF��ͣ��


    reg       key_pressed_flag;             // ���̰��±�־
    reg [3:0] col_val, row_val;             // ��ֵ����ֵ

    // ���ݴ�̬������Ӧ�Ĵ�����ֵ
    always @ (posedge key_clk, posedge rst)
        if(switch)
        begin
            col <= 4'h0;
            key_pressed_flag <= 0;
        end  
        else if (rst)
        begin
            col <= 4'h0;
            key_pressed_flag <= 0;
        end
        else
        case (next_state)   // next_state����һ�����ɨ��Ľ��
            NO_KEY_PRESSED :                  // û�а�������
                begin
                col <= 4'h0;
                key_pressed_flag <= 0;        // ����̰��±�־
                end

            SCAN_COL0 :                       // ɨ���0��
                col <= 4'b1110;

            SCAN_COL1 :                       // ɨ���1��
                col <= 4'b1101;

            SCAN_COL2 :                       // ɨ���2��
                col <= 4'b1011;

            SCAN_COL3 :                       // ɨ���3��
                col <= 4'b0111;

            KEY_PRESSED :                     // �а�������
                begin
                    col_val <= col;        // ������ֵ
                    row_val <= row;        // ������ֵ
                    key_pressed_flag <= 1;          // �ü��̰��±�־  
                end

        endcase
    // ״̬������ ����

    //��¼���˼��μ���
   
    always @ (posedge key_pressed_flag, posedge rst)
        begin
//            if(switch) //suspicious
//            begin
//                num_pressed <= 0;
//            end
             if (rst)
                num_pressed <= 0;
            else
                num_pressed <= num_pressed + 1'b1;
        end

    always @ (posedge up_out, posedge rst)
        begin
            if(switch)
            begin
                num_back<=0;
            end
            if (rst)
                num_back <= 0;
            else
                num_back <= num_back + 1'b1;
        end
        
        


    // ɨ������ֵ���� ��ʼ
    reg [3:0] keyboard_val [8:0];   //!����keyboard_val���飬�±��1��8���±��Ǽ�����ڼ��ΰ�����(��1��ʼ����)
    always @ (posedge key_clk or posedge rst) begin
//        if(!switch) begin
//        if(switch)
//        begin
//            keyboard_val[0] <= 4'hA;   //��ע�͵������
//            keyboard_val[1] <= 4'hA;
//            keyboard_val[2] <= 4'hA;
//            keyboard_val[3] <= 4'hA;
//            keyboard_val[4] <= 4'hA;
//            keyboard_val[5] <= 4'hA;
//            keyboard_val[6] <= 4'hA;
//            keyboard_val[7] <= 4'hA;
//            keyboard_val[8] <= 4'hA;
//        end
         if (rst) begin
            keyboard_val[0] <= 4'hA;   //Ӧ��û��
            keyboard_val[1] <= 4'hA;
            keyboard_val[2] <= 4'hA;
            keyboard_val[3] <= 4'hA;
            keyboard_val[4] <= 4'hA;
            keyboard_val[5] <= 4'hA;
            keyboard_val[6] <= 4'hA;
            keyboard_val[7] <= 4'hA;
            keyboard_val[8] <= 4'hA;
            end
        else
        begin       //�˸���A
        case (num_seg)  
            0:keyboard_val[1] <= 4'hA;
            1:keyboard_val[2] <= 4'hA;
            2:keyboard_val[3] <= 4'hA;
            3:keyboard_val[4] <= 4'hA;
            4:keyboard_val[5] <= 4'hA;
            5:keyboard_val[6] <= 4'hA;
            6:keyboard_val[7] <= 4'hA;
            7:keyboard_val[8] <= 4'hA;
        endcase
        
        if (key_pressed_flag)
            case ({col_val, row_val})
                8'b1110_1110 : keyboard_val[num_seg] <= 4'h1;    //�������󣬴�������ɨ�����
                8'b1110_1101 : keyboard_val[num_seg] <= 4'h4;
                8'b1110_1011 : keyboard_val[num_seg] <= 4'h7;
                
                8'b1101_1110 : keyboard_val[num_seg] <= 4'h2;
                8'b1101_1101 : keyboard_val[num_seg] <= 4'h5;
                8'b1101_1011 : keyboard_val[num_seg] <= 4'h8;
                8'b1101_0111 : keyboard_val[num_seg] <= 4'h0;
                
                8'b1011_1110 : keyboard_val[num_seg] <= 4'h3;
                8'b1011_1101 : keyboard_val[num_seg] <= 4'h6;
                8'b1011_1011 : keyboard_val[num_seg] <= 4'h9;
            endcase
        end
     end
//  end
    //  ɨ������ֵ���� ����
    //  С���̽�����keyboard_valΪ���µ�ֵ
    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++



    //-----------------------------------------------------------------------------------------------------------------------------
    // �����������ʾ
    reg [19:0] cnt2;
    reg clk_seg;
    reg [2:0] scan_cnt;     // ���ڷ�Ƶ��ʱ��clk_seg�ļ�����
    
    parameter period = 200000;  // 500Hz ���ȶ���

    always @(posedge clk, negedge rst)	// ��ƵΪclk_seg,tried change to nege,no use
        begin
            if(switch)
            begin
                cnt2 <= 0;   //cnt��0
                clk_seg <= 0;   //clk��0
            end
//tried delete sw here
             else if (rst)    // ��λ
                begin
                cnt2 <= 0;   //cnt��0
                clk_seg <= 0;   //clk��0
                end
            else begin
                if (cnt2 == (period >> 1) - 1)       // ���Ƴ���2Ϊ������ڣ���������ڽ���
                    begin
                    clk_seg <= ~clk_seg;    // clkȡ��������ȡ��Ϊһ������
                    cnt2 <= 0;       // cnt��0
                    end
                else
                    cnt2 <= cnt2 + 1; // cnt����
            end
        end

    always@(posedge clk_seg, negedge rst)    // ����clk_seg�ı�scan_cnt
        begin
//            if(switch)
//            begin
//                scan_cnt <= 0;  // scan_cnt��0
//            end
//try delete sw here
             if (rst)    // ��λ
                scan_cnt <= 0;  // scan_cnt��0
            else begin
                scan_cnt <= scan_cnt + 1;   // scan_cnt����
                if (scan_cnt == 3'd7)   // scan_cntһ���������
                    scan_cnt <= 0;      // scan_cnt��0
            end
        end

    always @(switch,rst,scan_cnt,num_pressed, num_back) begin //original scan_cnt,rst
    if(switch)
        num_seg=0;
   else if (rst)//tryied delete else, not working
        num_seg = 0;
    else begin
        num_seg = num_pressed - num_back;
        if (num_seg == 0) begin     //Ҫ��ʾ�����ָ���Ϊ0
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

        if(num_seg == 2) begin      //Ҫ��ʾ�����ָ���Ϊ2
            case(scan_cnt)
                0: seg_en = 8'b0111_1111;       //��0ʱ��ֻ����1����
                1: seg_en = 8'b1011_1111;       //��1ʱ��ֻ����2����
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
    end

    wire[7:0] numDisplay [9:0];  // !����numDisplay���飬�±��0��9���±��Ǽ�����Ҫ��ʾ��һ������
        begin
            assign numDisplay[0] = 8'b1100_0000; // 0
            assign numDisplay[1] = 8'b1111_1001; // 1
            assign numDisplay[2] = 8'b1010_0100; // 2
            assign numDisplay[3] = 8'b1011_0000; // 3
            assign numDisplay[4] = 8'b1001_1001; // 4
            assign numDisplay[5] = 8'b1001_0010; // 5
            assign numDisplay[6] = 8'b1000_0010; // 6
            assign numDisplay[7] = 8'b1111_1000; // 7
            assign numDisplay[8] = 8'b1000_0000; // 8
            assign numDisplay[9] = 8'b1001_0000; // 9
        end

    //!keyboard_val�����±��1��8���±��Ǽ�����ڼ��ΰ�����(��1��ʼ����)
    always @(scan_cnt) begin
//    if(!switch) //curious
//        begin
            case(scan_cnt)
                0: seg_out = numDisplay[keyboard_val[1]];   // !�ڵ�iʱ����ʾ��i�ΰ�����
                1: seg_out = numDisplay[keyboard_val[2]];
                2: seg_out = numDisplay[keyboard_val[3]];
                3: seg_out = numDisplay[keyboard_val[4]];
                4: seg_out = numDisplay[keyboard_val[5]];
                5: seg_out = numDisplay[keyboard_val[6]];
                6: seg_out = numDisplay[keyboard_val[7]];
                7: seg_out = numDisplay[keyboard_val[8]];
            default: seg_out = 8'b1111_1111;    // ��֪����û����
            endcase
        end
//    end
    // ����ܽ���
    //-----------------------------------------------------------------------------------------------------------------------------

always @(posedge clk)
    begin
    if(!switch)begin
        if(key_on1==1)
            begin
            key_on<=1;
            val<=keyboard_val[1];
            end
        else if(key_on2==1)
            begin
            key_on<=1;
            val<=keyboard_val[2];
            end
        else if(key_on3==1)
            begin
            key_on<=1;
            val<=keyboard_val[3];
        end
        else if(key_on4==1)
            begin
            key_on<=1;
            val<=keyboard_val[4];
        end
        else if(key_on5==1)
            begin
            key_on<=1;
            val<=keyboard_val[5];
        end
        else if(key_on6==1)
            begin
            key_on<=1;
            val<=keyboard_val[6];
        end
        else if(key_on7==1)
            begin
            key_on<=1;
            val<=keyboard_val[7];
        end
        else if(key_on8==1)
            begin
            key_on<=1;
            val<=keyboard_val[8];
        end
        else if(key_on_mus==1)
        begin
            key_on<=1;
            val<=11;
        end
        /*
        ʵ��һ�����Ź���
        */
        else if(key_on_all)
                    begin
                        if(cnt_buzzer>0&&cnt_buzzer<time1)
                            begin
                            key_on<=1;
                            val<=keyboard_val[1];
                            end
                        else if(cnt_buzzer>time1&&cnt_buzzer<time1+t)
                            begin
                            key_on<=0;
                            end
                        else if(cnt_buzzer>time1+t&&cnt_buzzer<time1+t+time2)
                            begin
                            key_on<=1;
                            val<=keyboard_val[2];
                            end
                        else if(time1+t+time2<cnt_buzzer&&time1+t*2+time2>cnt_buzzer)
                            begin
                            key_on<=0;
                            end
                        else if(time1+t*2+time2<cnt_buzzer&&time1+t*2+time2+time3>cnt_buzzer)
                            begin
                            key_on<=1;
                            val<=keyboard_val[3];
                            end
                        else if(time1+t*2+time2+time3<cnt_buzzer&&time1+t*3+time2+time3>cnt_buzzer)
                            begin
                            key_on<=0;
                            end       
                        else if(time1+t*3+time2+time3<cnt_buzzer&&time1+t*3+time2+time3+time4>cnt_buzzer)
                            begin
                            key_on<=1;
                            val<=keyboard_val[4];
                            end
                        else if(time1+t*3+time2+time3+time4<cnt_buzzer&&time1+t*4+time2+time3+time4>cnt_buzzer)
                            begin
                            key_on<=0;
                            end
                        else if(time1+t*4+time2+time3+time4<cnt_buzzer&&time1+t*4+time2+time3+time4+time5>cnt_buzzer)
                            begin
                            key_on<=1;
                            val<=keyboard_val[5];
                            end
                        else if(time1+t*4+time2+time3+time4+time5<cnt_buzzer&&time1+t*5+time2+time3+time4+time5>cnt_buzzer)
                            begin
                            key_on<=0;
                            end
                        else if(time1+t*5+time2+time3+time4+time5<cnt_buzzer&&time1+t*5+time2+time3+time4+time5+time6>cnt_buzzer)
                            begin
                            key_on<=1;
                            val<=keyboard_val[6];
                            end
                        else if(time1+t*5+time2+time3+time4+time5+time6<cnt_buzzer&&time1+t*6+time2+time3+time4+time5+time6>cnt_buzzer)
                            begin
                            key_on<=0;
                            end
                        else if(time1+t*6+time2+time3+time4+time5+time6<cnt_buzzer&&time1+t*6+time2+time3+time4+time5+time6+time7>cnt_buzzer)
                            begin
                            key_on<=1;
                            val<=keyboard_val[7];
                            end
                        else if(time1+t*6+time2+time3+time4+time5+time6+time7<cnt_buzzer&&time1+t*7+time2+time3+time4+time5+time6+time7>cnt_buzzer)
                            begin
                            key_on<=0;
                            end
                        else if(time1+t*7+time2+time3+time4+time5+time6+time7<cnt_buzzer&&time1+t*7+time2+time3+time4+time5+time6+time7+time8>cnt_buzzer)
                            begin
                            key_on<=1;
                            val<=keyboard_val[8];
                            end
                        else if(time1+t*7+time2+time3+time4+time5+time6+time7+time8<cnt_buzzer)
                            begin
                            key_on<=0;
                            end
                    end
        else key_on<=0;
        end
    end
    buzzer buzzer1(clk,rst,modulee,key_on,val,beep);//�˴�Ϊ�����ֲ��Ź���

    always@(posedge clk)
    if(!switch)begin
        begin
            case(keyboard_val[1])
                0:time1=TIME0_0;
                1:time1=TIME1_0;
                2:time1=TIME2_0;
                3:time1=TIME3_0;
                4:time1=TIME4_0;
                5:time1=TIME5_0;
                6:time1=TIME6_0;
                7:time1=TIME7_0;
                8:time1=TIME8_0;
                9:time1=TIME9_0;
            endcase
                case(keyboard_val[2])
                0:time2=TIME0_0;
                1:time2=TIME1_0;
                2:time2=TIME2_0;
                3:time2=TIME3_0;
                4:time2=TIME4_0;
                5:time2=TIME5_0;
                6:time2=TIME6_0;
                7:time2=TIME7_0;
                8:time2=TIME8_0;
                9:time2=TIME9_0;
            endcase        
                case(keyboard_val[3])
                0:time3=TIME0_0;
                1:time3=TIME1_0;
                2:time3=TIME2_0;
                3:time3=TIME3_0;
                4:time3=TIME4_0;
                5:time3=TIME5_0;
                6:time3=TIME6_0;
                7:time3=TIME7_0;
                8:time3=TIME8_0;
                9:time3=TIME9_0;
            endcase    
                case(keyboard_val[4])
                0:time4=TIME0_0;
                1:time4=TIME1_0;
                2:time4=TIME2_0;
                3:time4=TIME3_0;
                4:time4=TIME4_0;
                5:time4=TIME5_0;
                6:time4=TIME6_0;
                7:time4=TIME7_0;
                8:time4=TIME8_0;
                9:time4=TIME9_0;
            endcase    
                case(keyboard_val[5])
                0:time5=TIME0_0;
                1:time5=TIME1_0;
                2:time5=TIME2_0;
                3:time5=TIME3_0;
                4:time5=TIME4_0;
                5:time5=TIME5_0;
                6:time5=TIME6_0;
                7:time5=TIME7_0;
                8:time5=TIME8_0;
                9:time5=TIME9_0;
            endcase    
                case(keyboard_val[6])
                0:time6=TIME0_0;
                1:time6=TIME1_0;
                2:time6=TIME2_0;
                3:time6=TIME3_0;
                4:time6=TIME4_0;
                5:time6=TIME5_0;
                6:time6=TIME6_0;
                7:time6=TIME7_0;
                8:time6=TIME8_0;
                9:time6=TIME9_0;
            endcase    
                case(keyboard_val[7])
                0:time7=TIME0_0;
                1:time7=TIME1_0;
                2:time7=TIME2_0;
                3:time7=TIME3_0;
                4:time7=TIME4_0;
                5:time7=TIME5_0;
                6:time7=TIME6_0;
                7:time7=TIME7_0;
                8:time7=TIME8_0;
                9:time7=TIME9_0;
            endcase    
                case(keyboard_val[8])
                0:time8=TIME0_0;
                1:time8=TIME1_0;
                2:time8=TIME2_0;
                3:time8=TIME3_0;
                4:time8=TIME4_0;
                5:time8=TIME5_0;
                6:time8=TIME6_0;
                7:time8=TIME7_0;
                8:time8=TIME8_0;
                9:time8=TIME9_0;
            endcase
        end
    end
endmodule
