`timescale 1ns / 1ps

module encoder_main(
        input   clk,    // 系统时钟
        input   rst,    // 复位信号
        input   up,     //退格
        input   [3:0] row,                     // 矩阵键盘 行
        input key_on1,key_on2,key_on3,key_on4,key_on5,key_on6,key_on7,key_on8,key_on_all,key_on_mus,
        input modulee,
        input switch,
        output [3:0] col,                 // 矩阵键盘 列
        output [7:0] seg_en,              // 控制哪个灯亮
        output [7:0] seg_out,              // 控制每个灯怎么亮（同时亮哪几个数码管）
        output beep
    );
    
    keyANDseg ks(.clk(clk), .rst(rst), .up(up), .row(row), 
    .key_on1(key_on1), .key_on2(key_on2), .key_on3(key_on3), .key_on4(key_on4), .key_on5(key_on5),.key_on6(key_on6), .key_on7(key_on7), .key_on8(key_on8), .key_on_all(key_on_all),
    .key_on_mus(key_on_mus),.modulee(modulee), .switch(switch), .col(col), .seg_en(seg_en), .seg_out(seg_out), .beep(beep));
    
endmodule
