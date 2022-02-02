`timescale 1ns / 1ps

module keyANDseg (
    input   clk,    // 系统时钟
    input   switch, // 开关
    input   rst,    // 复位信号
    input   up,     //退格
    input   [3:0] row,                     // 矩阵键盘 行
    input   key_on1,key_on2,key_on3,key_on4,key_on5,key_on6,key_on7,key_on8,key_on_all,key_on_mus,
    input modulee,
    output  reg [3:0] col,                 // 矩阵键盘 列
    output  reg [7:0] seg_en,              // 控制哪个灯亮
    output  reg [7:0] seg_out,              // 控制每个灯怎么亮（同时亮哪几个数码管）
    output beep
    );
    
    // +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    // 小键盘开始
    wire up_out;
    
    //退格键up防抖开始
    debounce_up u(clk, ~rst, up, up_out);
    // 分频部分 开始
    reg [19:0] cnt1;
    reg key_on;
    reg [3:0]val;
    reg [35:0] cnt_buzzer;
    reg [35:0] time1,time2,time3,time4,time5,time6,time7,time8;
    wire key_clk;
    reg [3:0] num_seg;
    reg [3:0] num_pressed;
    reg [3:0] num_back;
    
    
    //蜂鸣器
    
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
                cnt_buzzer <= 1'b0;        //清空
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
        
    assign key_clk = cnt1[19];                //!取key_clk的最高位，clk过20个周期才更新一次 (2^20/100M = 10)ms 
    // 分频部分 结束

    // 状态机
    parameter NO_KEY_PRESSED = 6'b000_001;  // 没有按键按下  
    parameter SCAN_COL0      = 6'b000_010;  // 扫描第0列 
    parameter SCAN_COL1      = 6'b000_100;  // 扫描第1列 
    parameter SCAN_COL2      = 6'b001_000;  // 扫描第2列 
    parameter SCAN_COL3      = 6'b010_000;  // 扫描第3列 
    parameter KEY_PRESSED    = 6'b100_000;  // 有按键按下
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
    reg [5:0] current_state, next_state;    // 现态、次态

    always @ (posedge key_clk, posedge rst)
        if(switch)
        begin
            current_state <= NO_KEY_PRESSED;
        end    
        else if (rst)
            current_state <= NO_KEY_PRESSED;
        else
            current_state <= next_state;    //随着key_clk的变化进行"到下一个状态"的状态迁移

    
    // 根据条件转移状态
    always @ (*)
    if(!switch)begin
        case (current_state)    //若有按键按下，row != 4h'F,从col0开始一列一列扫描
            NO_KEY_PRESSED :                    // 没有按键按下
                if (row != 4'hF)
                next_state = SCAN_COL0;
                else
                next_state = NO_KEY_PRESSED;
            SCAN_COL0 :                         // 扫描第0列 
                if (row != 4'hF)
                next_state = KEY_PRESSED;
                else
                next_state = SCAN_COL1;
            SCAN_COL1 :                         // 扫描第1列 
                if (row != 4'hF)
                next_state = KEY_PRESSED;
                else
                next_state = SCAN_COL2;    
            SCAN_COL2 :                         // 扫描第2列
                if (row != 4'hF)
                next_state = KEY_PRESSED;
                else
                next_state = SCAN_COL3;
            SCAN_COL3 :                         // 扫描第3列
                if (row != 4'hF)
                next_state = KEY_PRESSED;
                else
                next_state = NO_KEY_PRESSED;
            KEY_PRESSED :                       // 有按键按下
                if (row != 4'hF)
                next_state = KEY_PRESSED;
                else
                next_state = NO_KEY_PRESSED;                      
        endcase
    end
    //next_state是最后扫描的结果（到next_state发现row != 4'hF才停）


    reg       key_pressed_flag;             // 键盘按下标志
    reg [3:0] col_val, row_val;             // 列值、行值

    // 根据次态，给相应寄存器赋值
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
        case (next_state)   // next_state是上一步最后扫描的结果
            NO_KEY_PRESSED :                  // 没有按键按下
                begin
                col <= 4'h0;
                key_pressed_flag <= 0;        // 清键盘按下标志
                end

            SCAN_COL0 :                       // 扫描第0列
                col <= 4'b1110;

            SCAN_COL1 :                       // 扫描第1列
                col <= 4'b1101;

            SCAN_COL2 :                       // 扫描第2列
                col <= 4'b1011;

            SCAN_COL3 :                       // 扫描第3列
                col <= 4'b0111;

            KEY_PRESSED :                     // 有按键按下
                begin
                    col_val <= col;        // 锁存列值
                    row_val <= row;        // 锁存行值
                    key_pressed_flag <= 1;          // 置键盘按下标志  
                end

        endcase
    // 状态机部分 结束

    //记录按了几次键盘
   
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
        
        


    // 扫描行列值部分 开始
    reg [3:0] keyboard_val [8:0];   //!开个keyboard_val数组，下标从1到8，下标是几代表第几次按的数(从1开始计数)
    always @ (posedge key_clk or posedge rst) begin
//        if(!switch) begin
//        if(switch)
//        begin
//            keyboard_val[0] <= 4'hA;   //不注释掉会混乱
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
            keyboard_val[0] <= 4'hA;   //应该没用
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
        begin       //退格后归A
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
                8'b1110_1110 : keyboard_val[num_seg] <= 4'h1;    //从右往左，从下往上扫描键盘
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
    //  扫描行列值部分 结束
    //  小键盘结束，keyboard_val为按下的值
    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++



    //-----------------------------------------------------------------------------------------------------------------------------
    // 数码管译码显示
    reg [19:0] cnt2;
    reg clk_seg;
    reg [2:0] scan_cnt;     // 基于分频后时钟clk_seg的计数子
    
    parameter period = 200000;  // 500Hz （稳定）

    always @(posedge clk, negedge rst)	// 分频为clk_seg,tried change to nege,no use
        begin
            if(switch)
            begin
                cnt2 <= 0;   //cnt归0
                clk_seg <= 0;   //clk归0
            end
//tried delete sw here
             else if (rst)    // 复位
                begin
                cnt2 <= 0;   //cnt归0
                clk_seg <= 0;   //clk归0
                end
            else begin
                if (cnt2 == (period >> 1) - 1)       // 右移除以2为半个周期，当半个周期结束
                    begin
                    clk_seg <= ~clk_seg;    // clk取反，两次取反为一个周期
                    cnt2 <= 0;       // cnt归0
                    end
                else
                    cnt2 <= cnt2 + 1; // cnt递增
            end
        end

    always@(posedge clk_seg, negedge rst)    // 根据clk_seg改变scan_cnt
        begin
//            if(switch)
//            begin
//                scan_cnt <= 0;  // scan_cnt归0
//            end
//try delete sw here
             if (rst)    // 复位
                scan_cnt <= 0;  // scan_cnt归0
            else begin
                scan_cnt <= scan_cnt + 1;   // scan_cnt递增
                if (scan_cnt == 3'd7)   // scan_cnt一个周期完成
                    scan_cnt <= 0;      // scan_cnt归0
            end
        end

    always @(switch,rst,scan_cnt,num_pressed, num_back) begin //original scan_cnt,rst
    if(switch)
        num_seg=0;
   else if (rst)//tryied delete else, not working
        num_seg = 0;
    else begin
        num_seg = num_pressed - num_back;
        if (num_seg == 0) begin     //要显示的数字个数为0
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

        if(num_seg == 2) begin      //要显示的数字个数为2
            case(scan_cnt)
                0: seg_en = 8'b0111_1111;       //第0时刻只亮第1个灯
                1: seg_en = 8'b1011_1111;       //第1时刻只亮第2个灯
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

    wire[7:0] numDisplay [9:0];  // !开个numDisplay数组，下标从0到9，下标是几代表要表示哪一个数字
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

    //!keyboard_val数组下标从1到8，下标是几代表第几次按的数(从1开始计数)
    always @(scan_cnt) begin
//    if(!switch) //curious
//        begin
            case(scan_cnt)
                0: seg_out = numDisplay[keyboard_val[1]];   // !在第i时刻显示第i次按的数
                1: seg_out = numDisplay[keyboard_val[2]];
                2: seg_out = numDisplay[keyboard_val[3]];
                3: seg_out = numDisplay[keyboard_val[4]];
                4: seg_out = numDisplay[keyboard_val[5]];
                5: seg_out = numDisplay[keyboard_val[6]];
                6: seg_out = numDisplay[keyboard_val[7]];
                7: seg_out = numDisplay[keyboard_val[8]];
            default: seg_out = 8'b1111_1111;    // 不知道有没有用
            endcase
        end
//    end
    // 数码管结束
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
        实现一键播放功能
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
    buzzer buzzer1(clk,rst,modulee,key_on,val,beep);//此处为单数字播放功能

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
