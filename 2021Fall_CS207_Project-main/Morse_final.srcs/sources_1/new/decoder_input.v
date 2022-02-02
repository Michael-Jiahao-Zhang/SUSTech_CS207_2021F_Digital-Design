`timescale 1ns / 1ps

module decoder_input (
    input clk, enable,
    input short,long, rst,mid,down,
    output[7:0] code, //first 3bit is code length
    output [2:0] code_len,
    output clka
);
//reg[24:0] cnt1;
//    wire clk_out;
//        always @ (posedge clk )
//        if(!enable)
//        begin
//            cnt1<=1'b0;
//        end    

//        else
//            cnt1 <= cnt1 + 1'b1;
        
//    assign clk_out = cnt1[24];                //!取key_clk的最高位，clk过20个周期才更新一次 (2^20/100M = 10)ms 

     reg [23:0] cnt1;
     reg clk_out;
    always @(posedge clk)     
         begin
             if(!enable)begin
                 cnt1 <= 0;
                 clk_out <= 0;
             end
             else begin
                 if(cnt1 == 9500000)begin //if parameter too big, simulation could fail, if too small, actual operation could fail (tested 20000000)
                     clk_out <= ~clk_out;
                     cnt1 <= 0;
                 end
                 else
                     cnt1 <= cnt1+1;
             end
         end


// variable
reg [20:0] cnt;
reg scnt;
reg lcnt;
reg mcnt;
wire up_out;
wire s_out;
wire l_out;
wire m_out;
wire d_out;
key_debounce s(clk,enable,short,s_out);
key_debounce l(clk,enable,long,l_out);
key_debounce m(clk,enable,mid,m_out);
key_debounce d(clk,enable,down,d_out);
reg [2:0] tot_cnt; //bits in the code
parameter cnt_0=0;
parameter cnt_1=1;
parameter cnt_2=2;
parameter cnt_3=3;
parameter cnt_4=4;
parameter cnt_5=5;
parameter cnt_error=6; //input more than 5bits, can't decode
reg[2:0] cur_cnt;
reg[7:0] cur_code;
reg [7:0] total_code; //5~7 bits indicate code length, rest are 1 for long, 0 for short

//count bits fsm
always @(posedge clk_out,negedge enable ) begin
    if(!enable) begin//init
       //total_code<=8'b00000000;
       // tot_cnt<=3'b000;
        cur_cnt<=3'b000;
        cur_code<=8'b0000_0000;
        end
    else
        cur_cnt <= tot_cnt;
        cur_code<=total_code;
end

//count bit
always@* begin
    case(cur_cnt)
        cnt_0: if(s_out ) begin tot_cnt=cnt_1; end
                  else if(l_out) begin tot_cnt=cnt_1; total_code[0]=1; end
                  else if(rst | m_out) begin tot_cnt=3'b000; total_code=8'b0000_0000; end
                  else if(d_out)  tot_cnt=cnt_0; 
                  else begin tot_cnt=cnt_0; {total_code[4:0]}={cur_code[4:0]}; end //change
        cnt_1: if(s_out ) begin tot_cnt=cnt_2; end
                  else if(l_out) begin tot_cnt=cnt_2; total_code[1]=1; end
                  else if(rst | m_out)begin  tot_cnt=3'b000; total_code=8'b0000_0000; end
                  else if(d_out) begin tot_cnt=cnt_0; total_code[0]=0;end
                    else begin tot_cnt=cnt_1; {total_code[4:0]}={cur_code[4:0]}; end
        cnt_2: if(s_out ) begin tot_cnt=cnt_3; end
                   else if(l_out) begin tot_cnt=cnt_3; total_code[cnt_2]=1; end
                    else if(rst | m_out) begin tot_cnt=3'b000;total_code=8'b0000_0000;end
                    else if(d_out)begin tot_cnt=cnt_1; total_code[cnt_1]=0;end
                    else begin tot_cnt=cnt_2; {total_code[4:0]}={cur_code[4:0]}; end
        cnt_3:if(s_out ) begin tot_cnt=cnt_4; end
                      else if(l_out) begin tot_cnt=cnt_4; total_code[cnt_3]=1; end
                      else if(rst | m_out) begin tot_cnt=cnt_0;total_code=8'b0000_0000; end
                      else if(d_out) begin tot_cnt=cnt_2;total_code[cnt_2]=0;end
                   else begin tot_cnt=cnt_3; {total_code[4:0]}={cur_code[4:0]}; end
        cnt_4: if(s_out ) begin tot_cnt=cnt_5; end
                      else if(l_out) begin tot_cnt=cnt_5; total_code[cnt_4]=1; end //total[4] is the fifith bit.
                    else if(rst|m_out) begin tot_cnt=cnt_0;total_code=8'b0000_0000; end
                    else if(d_out) begin tot_cnt=cnt_3;total_code[cnt_3]=0;end
                       else  begin tot_cnt=cnt_4; {total_code[4:0]}={cur_code[4:0]}; end
        cnt_5: if(s_out | l_out) begin tot_cnt =cnt_0;total_code=8'b0000_0000; end
                     else if(rst|m_out)begin  tot_cnt=cnt_0;total_code=8'b0000_0000; end
                     else if(d_out) begin tot_cnt=cnt_4;total_code[cnt_4]=0;end
                       else begin tot_cnt=cnt_5;  {total_code[4:0]}={cur_code[4:0]}; end//but counted 5 bits, aware the difference
        endcase
        end
        
        

always @(*) begin
    case(cur_cnt)
         3'b000:  if(s_out | l_out)  {total_code[7],total_code[6],total_code[5]}=3'b001;
                        else if(m_out|rst)  {total_code[7],total_code[6],total_code[5]}=3'b000; 
                        else   {total_code[7],total_code[6],total_code[5]}=3'b000;
                        
        3'b001:   if(s_out | l_out) begin  {total_code[7],total_code[6],total_code[5]} =3'b010; end 
                        else if(m_out|rst)  {total_code[7],total_code[6],total_code[5]}=3'b000; 
                        else if(d_out)  {total_code[7],total_code[6],total_code[5]}=3'b000; 
                        else  {total_code[7],total_code[6],total_code[5]} =3'b001;
                        
            3'b010:   if(s_out | l_out) begin  {total_code[7],total_code[6],total_code[5]} =3'b011; end 
                        else if(m_out|rst)  {total_code[7],total_code[6],total_code[5]}=3'b000; 
                        else if(d_out)  {total_code[7],total_code[6],total_code[5]}=3'b001; 
                         else  {total_code[7],total_code[6],total_code[5]} =3'b010;
                
                3'b011:  if(s_out | l_out)  {total_code[7],total_code[6],total_code[5]}=3'b100; 
                        else if(m_out|rst)  {total_code[7],total_code[6],total_code[5]}=3'b000;
                        else if(d_out)  {total_code[7],total_code[6],total_code[5]}=3'b010; 
                        else   {total_code[7],total_code[6],total_code[5]}=3'b011;
                        
         3'b100:  if(s_out | l_out)  {total_code[7],total_code[6],total_code[5]}=3'b101;
                         else if(m_out|rst)  {total_code[7],total_code[6],total_code[5]}=3'b000;
                         else if(d_out)  {total_code[7],total_code[6],total_code[5]}=3'b011; 
                         else  {total_code[7],total_code[6],total_code[5]}=3'b100;
                         
          3'b101:  if(s_out | l_out)  {total_code[7],total_code[6],total_code[5]}=3'b000;
                  else if(m_out|rst)  {total_code[7],total_code[6],total_code[5]}=3'b000; 
                  else if(d_out)  {total_code[7],total_code[6],total_code[5]}=3'b100; 
                  else   {total_code[7],total_code[6],total_code[5]}=3'b101;
       
    endcase
end

assign code=cur_code;
assign code_len = cur_cnt;
assign clka=clk_out;


endmodule