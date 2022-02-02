`timescale 1ns / 1ps

module encoder_main(
        input   clk,    // ϵͳʱ��
        input   rst,    // ��λ�ź�
        input   up,     //�˸�
        input   [3:0] row,                     // ������� ��
        input key_on1,key_on2,key_on3,key_on4,key_on5,key_on6,key_on7,key_on8,key_on_all,key_on_mus,
        input modulee,
        input switch,
        output [3:0] col,                 // ������� ��
        output [7:0] seg_en,              // �����ĸ�����
        output [7:0] seg_out,              // ����ÿ������ô����ͬʱ���ļ�������ܣ�
        output beep
    );
    
    keyANDseg ks(.clk(clk), .rst(rst), .up(up), .row(row), 
    .key_on1(key_on1), .key_on2(key_on2), .key_on3(key_on3), .key_on4(key_on4), .key_on5(key_on5),.key_on6(key_on6), .key_on7(key_on7), .key_on8(key_on8), .key_on_all(key_on_all),
    .key_on_mus(key_on_mus),.modulee(modulee), .switch(switch), .col(col), .seg_en(seg_en), .seg_out(seg_out), .beep(beep));
    
endmodule
