`timescale 1ns / 1ps

module decoder_dec( //decode 1 char

input clk,en,mid,rst,
input [4:0] code,
input[2:0] code_len,
output [3:0] code_cnt,
output [7:0] char,// how one tube lights up
output wire accepted
    );
      wire m_out;
    wire r_out;
    key_debounce m_d(clk,en,mid,m_out);
    key_debounce r_d(clk,en,rst,r_out);

    
//        reg[24:0] cnt1;
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

  
  
  
    parameter a = 8'b01000010;
    parameter b = 8'b10000001;
    parameter c = 8'b10000101;
    parameter d = 8'b01100001;
    parameter e = 8'b00100000;
    parameter f = 8'b10000100;
    parameter g = 8'b01100011;
    parameter h = 8'b10000000;
    parameter i = 8'b01000000;
    parameter j = 8'b10001110;
    parameter k = 8'b01100101;
    parameter l = 8'b10000010;
    parameter m = 8'b01000011;
    parameter n = 8'b01000001;
    parameter o = 8'b01100111;
    parameter p = 8'b10000110;
    parameter q = 8'b10001011;
    parameter r = 8'b01100010;
    parameter s = 8'b01100000;
    parameter t = 8'b00100001;
    parameter u = 8'b01100100;
    parameter v = 8'b10001000;
    parameter w = 8'b01100110;
    parameter x_code = 8'b10001001;
    parameter y = 8'b10001101;
    parameter z_code  =8'b10000011 ;
    parameter code_1 = 8'b10111110;
    parameter code_2 = 8'b10111100;
    parameter code_3 = 8'b10111000;
    parameter code_4 = 8'b10110000;
    parameter code_5 = 8'b10100000;
    parameter code_6 = 8'b10100001;
    parameter code_7 = 8'b10100011;
    parameter code_8 = 8'b10100111;
    parameter code_9 = 8'b10101111;
    parameter code_0 = 8'b10111111;
    
        reg [7:0] cur_char;
        reg [7:0] nxt_char;
        reg [3:0] cur_cnt;
        reg[3:0] nxt_cnt;
        reg ac;
        reg nxt_ac;
    
    always@(posedge clk_out or posedge r_out)//deleted negedge en
        begin
            if(r_out) //changed from !en to rst
                begin 
                    cur_char<=8'b11111111; //all close
                    cur_cnt<=4'b0000;
                    ac<=1'b0;
                    end
           else
                    cur_char<=nxt_char;  
                    cur_cnt<=nxt_cnt;       
                    ac<=nxt_ac;
        end
    
    

    always@*
        begin
     
       if(cur_cnt==8)
            begin
            nxt_cnt=4'b1000;
                        if(r_out) begin
                       nxt_char=8'b1111_1111;
                       nxt_cnt=4'b0000;
                  end                      

            end  

        else if(m_out) begin //press mid
            case({code_len,code})
            default: begin nxt_char=8'b11111111; nxt_cnt=cur_cnt; end//can't decode, should have warning.
                code_0: begin nxt_char=8'b11000000 ;nxt_cnt=cur_cnt+1; end
                code_1:begin nxt_char=8'b11111001; nxt_cnt=cur_cnt+1;end
                code_2: begin nxt_char=8'b10100100; nxt_cnt=cur_cnt+1;end
                code_3:begin nxt_char=8'b10110000 ;nxt_cnt=cur_cnt+1; end
                code_4: begin nxt_char=8'b10011001;nxt_cnt=cur_cnt+1; end
                code_5:begin nxt_char= 8'b10010010; nxt_cnt=cur_cnt+1;end
                code_6:begin nxt_char=8'b10000010 ; nxt_cnt=cur_cnt+1;end
                code_7:begin nxt_char= 8'b11111000;nxt_cnt=cur_cnt+1; end
                code_8:begin nxt_char=8'b10000000; nxt_cnt=cur_cnt+1;end
                code_9:begin nxt_char=8'b10010000 ;nxt_cnt=cur_cnt+1; end
                a: begin nxt_char=8'b10001000;nxt_cnt=cur_cnt+1;   end
                b:begin nxt_char= 8'b10000011;nxt_cnt=cur_cnt+1; end
                c:begin nxt_char= 8'b11000110; nxt_cnt=cur_cnt+1; end
                d:begin nxt_char= 8'b10100001;  nxt_cnt=cur_cnt+1;end
                e:begin nxt_char= 8'b10000110;  nxt_cnt=cur_cnt+1;end
                f:begin nxt_char= 8'b10001110 ;  nxt_cnt=cur_cnt+1;end
                g:begin nxt_char=8'b1100_0010;  nxt_cnt=cur_cnt+1;end
                h: begin nxt_char=8'b1000_1001;  nxt_cnt=cur_cnt+1;end
                i:begin nxt_char= 8'b1111_0000 ;  nxt_cnt=cur_cnt+1;end
                j:begin nxt_char=8'b1111_0001;  nxt_cnt=cur_cnt+1;end
                k:begin nxt_char=8'b1000_1010;  nxt_cnt=cur_cnt+1;end
                l:begin nxt_char=8'b1100_0111;  nxt_cnt=cur_cnt+1;end
                m:begin nxt_char=8'b1100_1000;  nxt_cnt=cur_cnt+1;end
                n:begin nxt_char= 8'b1010_1011;  nxt_cnt=cur_cnt+1;end
                o:begin nxt_char=8'b10100011;  nxt_cnt=cur_cnt+1;end
                p:begin nxt_char=8'b1000_1100 ;  nxt_cnt=cur_cnt+1;end
                q:begin nxt_char= 8'b1001_1000;  nxt_cnt=cur_cnt+1;end
                r:begin nxt_char= 8'b1100_1110;  nxt_cnt=cur_cnt+1;end
                s:begin nxt_char= 8'b1011_0110;  nxt_cnt=cur_cnt+1;end
                t:begin nxt_char=8'b1000_0111 ;  nxt_cnt=cur_cnt+1;end
                u:begin nxt_char=8'b1100_0001;  nxt_cnt=cur_cnt+1;end
                v:begin nxt_char=8'b1110_0011;  nxt_cnt=cur_cnt+1;end
                w:begin nxt_char=8'b1000_0001;  nxt_cnt=cur_cnt+1;end
               x_code:begin nxt_char=8'b1001_1011;  nxt_cnt=cur_cnt+1;end
                y:begin nxt_char=8'b1001_0001;   nxt_cnt=cur_cnt+1;end
                z_code:begin nxt_char= 8'b1010_0101 ;  nxt_cnt=cur_cnt+1;end
                endcase
                end
            else if(r_out) begin
                    nxt_char=8'b1111_1111;
                    nxt_cnt=4'b0000;
               end                          
                                    
            else begin
                    nxt_cnt=cur_cnt;
                  nxt_char=cur_char;

                         end
        end
     
        assign code_cnt=cur_cnt;
        assign char=cur_char;
        assign accepted=ac;
        
endmodule
