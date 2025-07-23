module ISP(
    // Input Signals
    input clk,
    input rst_n,
    input in_valid,
    input [3:0] in_pic_no,
    input [1:0] in_mode,
    input [1:0] in_ratio_mode,

    // Output Signals
    output reg out_valid,
    output reg[7:0] out_data,
    
    // DRAM Signals
    // axi write address channel
    // src master
    output reg[3:0]  awid_s_inf,
    output reg[31:0] awaddr_s_inf,
    output reg[2:0]  awsize_s_inf,
    output reg[1:0]  awburst_s_inf,
    output reg[7:0]  awlen_s_inf,
    output        awvalid_s_inf,
    // src slave
    input         awready_s_inf,
    // -----------------------------
  
    // axi write data channel 
    // src master
    output reg[127:0] wdata_s_inf,
    output reg        wlast_s_inf,
    output reg        wvalid_s_inf,
    // src slave
    input          wready_s_inf,
  
    // axi write response channel 
    // src slave
    input [3:0]    bid_s_inf,
    input [1:0]    bresp_s_inf,
    input          bvalid_s_inf,
    // src master 
    output reg        bready_s_inf,
    // -----------------------------
  
    // axi read address channel 
    // src master
    output [3:0]   arid_s_inf,
    output reg[31:0]  araddr_s_inf,
    output reg[7:0]   arlen_s_inf,
    output reg[2:0]   arsize_s_inf,
    output reg[1:0]   arburst_s_inf,
    output reg        arvalid_s_inf,
    // src slave
    input          arready_s_inf,
    // -----------------------------
  
    // axi read data channel 
    // slave
    input [3:0]    rid_s_inf,
    input [127:0]  rdata_s_inf,
    input [1:0]    rresp_s_inf,
    input          rlast_s_inf,
    input          rvalid_s_inf,
    // master
    output reg         rready_s_inf
    
);

//---------------------------------------------------------------------
//   PARAMETER
//---------------------------------------------------------------------
integer i,j;
parameter IDLE = 0;
parameter IN_DATA = 1;
parameter DRAM_FOCUS_READ = 2;
parameter FOCUS_CAL = 3;
parameter FOCUS_CAL2 = 4;
parameter DRAM_EXP_READ = 5;
parameter EXP_CAL = 6;
parameter EXP_CAL2 = 7;
parameter WAIT_BVALID = 8;
parameter OUT = 9;


//---------------------------------------------------------------------
//   Reg & Wires
//---------------------------------------------------------------------
reg [4:0]current_state,next_state;
reg [1:0]mode;
reg [3:0]pic_num;
reg [1:0]ratio;
reg [7:0]counter;
reg [7:0]column1,column2,column3,column4,column5,column6,column7,column8,column9,column10,column11,column12;
reg [7:0]comp1,comp2,comp3,comp4,comp5,comp6,comp7,comp8,comp9,comp10,comp11,comp12;
reg [7:0]column_mi_1,column_mi_2,column_mi_3,column_mi_4,column_mi_5;
reg [7:0]row_mi_1,row_mi_2,row_mi_3,row_mi_4,row_mi_5,row_mi_6;

reg [10:0]column_mi_all6,column_mi_all4;
reg [10:0]row_mi_all6,row_mi_all4,row_mi_all2;

reg[12:0]reg6x6,reg4x4,reg2x2;

//reg[12:0]regall;

reg[8:0]regbig;

reg [7:0]Focus_map[0:5][0:5];

reg [127:0]W_DATA;
reg [127:0]W_DATA_seq;
reg [127:0]W_DATA_seq2;
reg [127:0]W_DATA_seq3;
reg [127:0]W_DATA_seq4;

reg [8:0]EXP_in1,EXP_in2,EXP_in3,EXP_in4,EXP_in5,EXP_in6,EXP_in7,EXP_in8;
reg [8:0]EXP_in9,EXP_in10,EXP_in11,EXP_in12,EXP_in13,EXP_in14,EXP_in15,EXP_in16;

reg plus0,plus1,plus2,plus3,plus4,plus5,plus6,plus7,plus8,plus9,plus10,plus11,plus12,plus13,plus14,plus15,plus16;

reg [6:0]map1,map2,map3,map4,map5,map6;

reg [6:0]Avg_cnt1,Avg_cnt2,Avg_cnt3,Avg_cnt4,Avg_cnt5,Avg_cnt6,Avg_cnt7,Avg_cnt8,Avg_cnt9,Avg_cnt10,Avg_cnt11,Avg_cnt12,Avg_cnt13,Avg_cnt14,Avg_cnt15,Avg_cnt16;

reg [18:0]Avg_out;
reg [11:0]Avg_add;

reg [1:0]move,move0;

reg [7:0] data [15:0];
wire [7:0] max_stage1 [7:0];
wire [7:0] max_stage2 [3:0];
wire [7:0] max_stage3 [1:0];
wire [7:0] max_final;
wire [7:0] min_stage1 [7:0];
wire [7:0] min_stage2 [3:0];
wire [7:0] min_stage3 [1:0];
wire [7:0] min_final;

reg [7:0] max_R;
reg [7:0] max_G;
reg [7:0] max_B;
reg [7:0] min_R;
reg [7:0] min_G;
reg [7:0] min_B;

reg [9:0] result;


//---------------------------------------------------------------------
//   FSM
//---------------------------------------------------------------------

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) current_state <= 0;
	else current_state <= next_state;
end

always @(*) begin
	case(current_state)
        IDLE:begin
            if(in_valid) next_state = IN_DATA;
            else next_state = IDLE;
        end
        IN_DATA:begin
            if((plus0==0 && pic_num==0)||(plus1==0 && pic_num==1)||(plus2==0 && pic_num==2)||(plus3==0 && pic_num==3)||(plus4==0 && pic_num==4)||(plus5==0 && pic_num==5)||(plus6==0 && pic_num==6)||(plus7==0 && pic_num==7)||(plus8==0 && pic_num==8)||(plus9==0 && pic_num==9)||(plus10==0 && pic_num==10)||(plus11==0 && pic_num==11)||(plus12==0 && pic_num==12)||(plus13==0 && pic_num==13)||(plus14==0 && pic_num==14)||(plus15==0 && pic_num==15)) next_state = OUT;
            else if(mode==0) next_state = DRAM_FOCUS_READ;
            else if(mode==1 || mode==2) next_state = DRAM_EXP_READ;
            else next_state = IN_DATA;
        end
        DRAM_FOCUS_READ:begin
            if(arready_s_inf) next_state = FOCUS_CAL;
            else next_state = DRAM_FOCUS_READ;
        end
        FOCUS_CAL:begin
            if(rlast_s_inf) next_state = FOCUS_CAL2;
            else next_state = FOCUS_CAL;
        end
        FOCUS_CAL2:begin
            if(counter==143) next_state = OUT;
            else next_state = FOCUS_CAL2;
        end
        DRAM_EXP_READ:begin
            if(arready_s_inf) next_state = EXP_CAL;
            else next_state = DRAM_EXP_READ;
        end
        EXP_CAL:begin
            if(rvalid_s_inf) next_state = EXP_CAL2;
            else next_state = EXP_CAL;
        end
        EXP_CAL2:begin
            if(counter == 193 && mode == 2) next_state = OUT;
            else if(counter == 195) next_state = WAIT_BVALID;
            else next_state = EXP_CAL2;
        end
        WAIT_BVALID:begin
            if(bvalid_s_inf) next_state = OUT;
            else next_state = WAIT_BVALID;
        end
        OUT:begin
            next_state = IDLE;
        end
        default:next_state = IDLE;
	endcase
end

//---------------------------------------------------------------------
//   Counter design
//---------------------------------------------------------------------

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) counter <= 0;
    else if(rvalid_s_inf || current_state==FOCUS_CAL2 || current_state==EXP_CAL2) counter <= counter + 1;
    else if(current_state==IDLE) counter <= 0;
end
always @(posedge clk or negedge rst_n) begin//0
    if(!rst_n) plus0 <= 1;
    else if(current_state==DRAM_EXP_READ && pic_num==0  && mode==1) plus0 <= 0;
    else if((current_state==EXP_CAL|| current_state==EXP_CAL2) && W_DATA>0 && pic_num==0  && mode==1) plus0 <= 1;
    //else plus0 <= plus0;
end
always @(posedge clk or negedge rst_n) begin//1
    if(!rst_n)plus1 <= 1;
    else if(current_state==DRAM_EXP_READ && pic_num==1  && mode==1) plus1 <= 0;
    else if((current_state==EXP_CAL|| current_state==EXP_CAL2) && W_DATA>0 && pic_num==1  && mode==1) plus1 <= 1;
    //else plus1 <= plus1;
end
always @(posedge clk or negedge rst_n) begin//2
    if(!rst_n)plus2 <= 1;
    else if(current_state==DRAM_EXP_READ && pic_num==2  && mode==1) plus2 <= 0;
    else if((current_state==EXP_CAL|| current_state==EXP_CAL2) && W_DATA>0 && pic_num==2  && mode==1) plus2 <= 1;
    //else plus2 <= plus2;
end
always @(posedge clk or negedge rst_n) begin//3
    if(!rst_n)plus3 <= 1;
    else if(current_state==DRAM_EXP_READ && pic_num==3  && mode==1) plus3 <= 0;
    else if((current_state==EXP_CAL|| current_state==EXP_CAL2) && W_DATA>0 && pic_num==3  && mode==1) plus3 <= 1;
    //else plus3 <= plus3;
end
always @(posedge clk or negedge rst_n) begin//4
    if(!rst_n)plus4 <= 1;
    else if(current_state==DRAM_EXP_READ && pic_num==4  && mode==1) plus4 <= 0;
    else if((current_state==EXP_CAL|| current_state==EXP_CAL2) && W_DATA>0 && pic_num==4  && mode==1) plus4 <= 1;
    //else plus4 <= plus4;
end
always @(posedge clk or negedge rst_n) begin//5
    if(!rst_n)plus5 <= 1;
    else if(current_state==DRAM_EXP_READ && pic_num==5  && mode==1) plus5 <= 0;
    else if((current_state==EXP_CAL|| current_state==EXP_CAL2) && W_DATA>0 && pic_num==5  && mode==1) plus5 <= 1;
    //else plus5 <= plus5;
end
always @(posedge clk or negedge rst_n) begin//6
    if(!rst_n)plus6 <= 1;
    else if(current_state==DRAM_EXP_READ && pic_num==6  && mode==1) plus6 <= 0;
    else if((current_state==EXP_CAL|| current_state==EXP_CAL2) && W_DATA>0 && pic_num==6  && mode==1) plus6 <= 1;
    //else plus6 <= plus6;
end
always @(posedge clk or negedge rst_n) begin//7
    if(!rst_n)plus7 <= 1;
    else if(current_state==DRAM_EXP_READ && pic_num==7  && mode==1) plus7 <= 0;
    else if((current_state==EXP_CAL|| current_state==EXP_CAL2) && W_DATA>0 && pic_num==7  && mode==1) plus7 <= 1;
    //else plus7 <= plus7;
end
always @(posedge clk or negedge rst_n) begin//8
    if(!rst_n)plus8 <= 1;
    else if(current_state==DRAM_EXP_READ && pic_num==8  && mode==1) plus8 <= 0;
    else if((current_state==EXP_CAL|| current_state==EXP_CAL2) && W_DATA>0 && pic_num==8  && mode==1) plus8 <= 1;
    else plus8 <= plus8;
end
always @(posedge clk or negedge rst_n) begin//9
    if(!rst_n)plus9 <= 1;
    else if(current_state==DRAM_EXP_READ && pic_num==9  && mode==1) plus9 <= 0;
    else if((current_state==EXP_CAL|| current_state==EXP_CAL2) && W_DATA>0 && pic_num==9  && mode==1) plus9 <= 1;
    //else plus9 <= plus9;
end
always @(posedge clk or negedge rst_n) begin//10
    if(!rst_n)plus10 <= 1;
    else if(current_state==DRAM_EXP_READ && pic_num==10  && mode==1) plus10 <= 0;
    else if((current_state==EXP_CAL|| current_state==EXP_CAL2) && W_DATA>0 && pic_num==10  && mode==1) plus10 <= 1;
    //else plus10 <= plus10;
end
always @(posedge clk or negedge rst_n) begin//11
    if(!rst_n)plus11 <= 1;
    else if(current_state==DRAM_EXP_READ && pic_num==11  && mode==1) plus11 <= 0;
    else if((current_state==EXP_CAL|| current_state==EXP_CAL2) && W_DATA>0 && pic_num==11  && mode==1) plus11 <= 1;
    //else plus11 <= plus11;
end
always @(posedge clk or negedge rst_n) begin//12
    if(!rst_n)plus12 <= 1;
    else if(current_state==DRAM_EXP_READ && pic_num==12  && mode==1) plus12 <= 0;
    else if((current_state==EXP_CAL|| current_state==EXP_CAL2) && W_DATA>0 && pic_num==12  && mode==1) plus12 <= 1;
    //else plus12 <= plus12;
end
always @(posedge clk or negedge rst_n) begin//13
    if(!rst_n)plus13 <= 1;
    else if(current_state==DRAM_EXP_READ && pic_num==13  && mode==1) plus13 <= 0;
    else if((current_state==EXP_CAL|| current_state==EXP_CAL2) && W_DATA>0 && pic_num==13  && mode==1) plus13 <= 1;
    //else plus13 <= plus13;
end
always @(posedge clk or negedge rst_n) begin//14
    if(!rst_n)plus14 <= 1;
    else if(current_state==DRAM_EXP_READ && pic_num==14  && mode==1) plus14 <= 0;
    else if((current_state==EXP_CAL|| current_state==EXP_CAL2) && W_DATA>0 && pic_num==14  && mode==1) plus14 <= 1;
    //else plus14 <= plus14;
end
always @(posedge clk or negedge rst_n) begin//15
    if(!rst_n)plus15 <= 1;
    else if(current_state==DRAM_EXP_READ && pic_num==15  && mode==1) plus15 <= 0;
    else if((current_state==EXP_CAL|| current_state==EXP_CAL2) && W_DATA>0 && pic_num==15  && mode==1) plus15 <= 1;
    //else plus15 <= plus15;
end


//---------------------------------------------------------------------
//   Input design
//---------------------------------------------------------------------
always @(posedge clk) begin
    if (in_valid)begin
        mode <= in_mode;
        pic_num <= in_pic_no;
        ratio <= in_ratio_mode;
    end
end

always @(posedge clk) begin
    /*if(next_state == IDLE) begin
        for(i = 0; i < 7; i = i + 1) begin
            for(j = 0; j < 7; j = j + 1) begin
                Focus_map[i][j] <= 0;
            end
        end
    end
    else begin*/
        case(counter)
            1  : begin
                Focus_map[0][0] <= map1;
                Focus_map[0][1] <= map2;
                Focus_map[0][2] <= map3;
                Focus_map[0][3] <= map4;
                Focus_map[0][4] <= map5;
                Focus_map[0][5] <= map6;
            end
            3  : begin
                Focus_map[1][0] <= map1;
                Focus_map[1][1] <= map2;
                Focus_map[1][2] <= map3;
                Focus_map[1][3] <= map4;
                Focus_map[1][4] <= map5;
                Focus_map[1][5] <= map6;
            end
            5  : begin
                Focus_map[2][0] <= map1;
                Focus_map[2][1] <= map2;
                Focus_map[2][2] <= map3;
                Focus_map[2][3] <= map4;
                Focus_map[2][4] <= map5;
                Focus_map[2][5] <= map6;
            end
            7 : begin
                Focus_map[3][0] <= map1;
                Focus_map[3][1] <= map2;
                Focus_map[3][2] <= map3;
                Focus_map[3][3] <= map4;
                Focus_map[3][4] <= map5;
                Focus_map[3][5] <= map6;
            end
            9  : begin
                Focus_map[4][0] <= map1;
                Focus_map[4][1] <= map2;
                Focus_map[4][2] <= map3;
                Focus_map[4][3] <= map4;
                Focus_map[4][4] <= map5;
                Focus_map[4][5] <= map6;
            end
            11  : begin
                Focus_map[5][0] <= map1;
                Focus_map[5][1] <= map2;
                Focus_map[5][2] <= map3;
                Focus_map[5][3] <= map4;
                Focus_map[5][4] <= map5;
                Focus_map[5][5] <= map6;
            end
            65  : begin
                Focus_map[0][0] <= Focus_map[0][0] + map1;
                Focus_map[0][1] <= Focus_map[0][1] + map2;
                Focus_map[0][2] <= Focus_map[0][2] + map3;
                Focus_map[0][3] <= Focus_map[0][3] + map4;
                Focus_map[0][4] <= Focus_map[0][4] + map5;
                Focus_map[0][5] <= Focus_map[0][5] + map6;
            end
            67  : begin
                Focus_map[1][0] <= Focus_map[1][0] + map1;
                Focus_map[1][1] <= Focus_map[1][1] + map2;
                Focus_map[1][2] <= Focus_map[1][2] + map3;
                Focus_map[1][3] <= Focus_map[1][3] + map4;
                Focus_map[1][4] <= Focus_map[1][4] + map5;
                Focus_map[1][5] <= Focus_map[1][5] + map6;
            end
            69  : begin
                Focus_map[2][0] <= Focus_map[2][0] + map1;
                Focus_map[2][1] <= Focus_map[2][1] + map2;
                Focus_map[2][2] <= Focus_map[2][2] + map3;
                Focus_map[2][3] <= Focus_map[2][3] + map4;
                Focus_map[2][4] <= Focus_map[2][4] + map5;
                Focus_map[2][5] <= Focus_map[2][5] + map6;
            end
            71  : begin
                Focus_map[3][0] <= Focus_map[3][0] + map1;
                Focus_map[3][1] <= Focus_map[3][1] + map2;
                Focus_map[3][2] <= Focus_map[3][2] + map3;
                Focus_map[3][3] <= Focus_map[3][3] + map4;
                Focus_map[3][4] <= Focus_map[3][4] + map5;
                Focus_map[3][5] <= Focus_map[3][5] + map6;
            end
            73  : begin
                Focus_map[4][0] <= Focus_map[4][0] + map1;
                Focus_map[4][1] <= Focus_map[4][1] + map2;
                Focus_map[4][2] <= Focus_map[4][2] + map3;
                Focus_map[4][3] <= Focus_map[4][3] + map4;
                Focus_map[4][4] <= Focus_map[4][4] + map5;
                Focus_map[4][5] <= Focus_map[4][5] + map6;
            end
            75  : begin
                Focus_map[5][0] <= Focus_map[5][0] + map1;
                Focus_map[5][1] <= Focus_map[5][1] + map2;
                Focus_map[5][2] <= Focus_map[5][2] + map3;
                Focus_map[5][3] <= Focus_map[5][3] + map4;
                Focus_map[5][4] <= Focus_map[5][4] + map5;
                Focus_map[5][5] <= Focus_map[5][5] + map6;
            end
            129  : begin
                Focus_map[0][0] <= Focus_map[0][0] + map1;
                Focus_map[0][1] <= Focus_map[0][1] + map2;
                Focus_map[0][2] <= Focus_map[0][2] + map3;
                Focus_map[0][3] <= Focus_map[0][3] + map4;
                Focus_map[0][4] <= Focus_map[0][4] + map5;
                Focus_map[0][5] <= Focus_map[0][5] + map6;
            end
            131  : begin
                Focus_map[1][0] <= Focus_map[1][0] + map1;
                Focus_map[1][1] <= Focus_map[1][1] + map2;
                Focus_map[1][2] <= Focus_map[1][2] + map3;
                Focus_map[1][3] <= Focus_map[1][3] + map4;
                Focus_map[1][4] <= Focus_map[1][4] + map5;
                Focus_map[1][5] <= Focus_map[1][5] + map6;
            end
            133  : begin
                Focus_map[2][0] <= Focus_map[2][0] + map1;
                Focus_map[2][1] <= Focus_map[2][1] + map2;
                Focus_map[2][2] <= Focus_map[2][2] + map3;
                Focus_map[2][3] <= Focus_map[2][3] + map4;
                Focus_map[2][4] <= Focus_map[2][4] + map5;
                Focus_map[2][5] <= Focus_map[2][5] + map6;
            end
            135  : begin
                Focus_map[3][0] <= Focus_map[3][0] + map1;
                Focus_map[3][1] <= Focus_map[3][1] + map2;
                Focus_map[3][2] <= Focus_map[3][2] + map3;
                Focus_map[3][3] <= Focus_map[3][3] + map4;
                Focus_map[3][4] <= Focus_map[3][4] + map5;
                Focus_map[3][5] <= Focus_map[3][5] + map6;
            end
            137  : begin
                Focus_map[4][0] <= Focus_map[4][0] + map1;
                Focus_map[4][1] <= Focus_map[4][1] + map2;
                Focus_map[4][2] <= Focus_map[4][2] + map3;
                Focus_map[4][3] <= Focus_map[4][3] + map4;
                Focus_map[4][4] <= Focus_map[4][4] + map5;
                Focus_map[4][5] <= Focus_map[4][5] + map6;
            end
            139  : begin
                Focus_map[5][0] <= Focus_map[5][0] + map1;
                Focus_map[5][1] <= Focus_map[5][1] + map2;
                Focus_map[5][2] <= Focus_map[5][2] + map3;
                Focus_map[5][3] <= Focus_map[5][3] + map4;
                Focus_map[5][4] <= Focus_map[5][4] + map5;
                Focus_map[5][5] <= Focus_map[5][5] + map6;
            end
        endcase
    //end
end

always @(posedge clk) begin
    if(counter>20 && counter<80)begin
        map1 <= rdata_s_inf[7:0]     >>1;
        map2 <= rdata_s_inf[15:8]    >>1;
        map3 <= rdata_s_inf[23:16]   >>1;
        map4 <= rdata_s_inf[31:24]   >>1;
        map5 <= rdata_s_inf[39:32]   >>1;
        map6 <= rdata_s_inf[47:40]   >>1;
    end
    else begin
        map1 <= rdata_s_inf[7:0]     >>2;
        map2 <= rdata_s_inf[15:8]    >>2;
        map3 <= rdata_s_inf[23:16]   >>2;
        map4 <= rdata_s_inf[31:24]   >>2;
        map5 <= rdata_s_inf[39:32]   >>2;
        map6 <= rdata_s_inf[47:40]   >>2;
    end
end

always @(*) begin
    column1  = (comp2>comp1)?comp1:comp2;
    column2  = (comp2>comp1)?comp2:comp1;
    column3  = (comp4>comp3)?comp3:comp4;
    column4  = (comp4>comp3)?comp4:comp3;
    column5  = (comp6>comp5)?comp5:comp6;
    column6  = (comp6>comp5)?comp6:comp5;
    column7  = (comp8>comp7)?comp7:comp8;
    column8  = (comp8>comp7)?comp8:comp7;
    column9  = (comp10>comp9)?comp9:comp10;
    column10 = (comp10>comp9)?comp10:comp9;
    column11 = (comp12>comp11)?comp11:comp12;
    column12 = (comp12>comp11)?comp12:comp11;
end

always @(*) begin
    case(counter)
            131  : begin
                comp1  = Focus_map[0][0];
                comp2  = Focus_map[0][1];
                comp3  = Focus_map[0][1];
                comp4  = Focus_map[0][2];
                comp5  = Focus_map[0][2];
                comp6  = Focus_map[0][3];
                comp7  = Focus_map[0][3];
                comp8  = Focus_map[0][4];
                comp9  = Focus_map[0][4];
                comp10 = Focus_map[0][5];
                comp11 = 0;
                comp12 = 0;
            end
            132  : begin
                comp1  = Focus_map[0][0];
                comp2  = Focus_map[1][0];
                comp3  = Focus_map[0][1];
                comp4  = Focus_map[1][1];
                comp5  = Focus_map[0][2];
                comp6  = Focus_map[1][2];
                comp7  = Focus_map[0][3];
                comp8  = Focus_map[1][3];
                comp9  = Focus_map[0][4];
                comp10 = Focus_map[1][4];
                comp11 = Focus_map[0][5];
                comp12 = Focus_map[1][5];
            end
            133  : begin
                comp1  = Focus_map[1][0];
                comp2  = Focus_map[1][1];
                comp3  = Focus_map[1][1];
                comp4  = Focus_map[1][2];
                comp5  = Focus_map[1][2];
                comp6  = Focus_map[1][3];
                comp7  = Focus_map[1][3];
                comp8  = Focus_map[1][4];
                comp9  = Focus_map[1][4];
                comp10 = Focus_map[1][5];
                comp11 = 0;
                comp12 = 0;
            end
            134  : begin
                comp1  = Focus_map[1][0];
                comp2  = Focus_map[2][0];
                comp3  = Focus_map[1][1];
                comp4  = Focus_map[2][1];
                comp5  = Focus_map[1][2];
                comp6  = Focus_map[2][2];
                comp7  = Focus_map[1][3];
                comp8  = Focus_map[2][3];
                comp9  = Focus_map[1][4];
                comp10 = Focus_map[2][4];
                comp11 = Focus_map[1][5];
                comp12 = Focus_map[2][5];
            end
            135  : begin
                comp1  = Focus_map[2][0];
                comp2  = Focus_map[2][1];
                comp3  = Focus_map[2][1];
                comp4  = Focus_map[2][2];
                comp5  = Focus_map[2][2];
                comp6  = Focus_map[2][3];
                comp7  = Focus_map[2][3];
                comp8  = Focus_map[2][4];
                comp9  = Focus_map[2][4];
                comp10 = Focus_map[2][5];
                comp11 = 0;
                comp12 = 0;
            end
            136  : begin
                comp1  = Focus_map[2][0];
                comp2  = Focus_map[3][0];
                comp3  = Focus_map[2][1];
                comp4  = Focus_map[3][1];
                comp5  = Focus_map[2][2];
                comp6  = Focus_map[3][2];
                comp7  = Focus_map[2][3];
                comp8  = Focus_map[3][3];
                comp9  = Focus_map[2][4];
                comp10 = Focus_map[3][4];
                comp11 = Focus_map[2][5];
                comp12 = Focus_map[3][5];
            end
            137  : begin
                comp1  = Focus_map[3][0];
                comp2  = Focus_map[3][1];
                comp3  = Focus_map[3][1];
                comp4  = Focus_map[3][2];
                comp5  = Focus_map[3][2];
                comp6  = Focus_map[3][3];
                comp7  = Focus_map[3][3];
                comp8  = Focus_map[3][4];
                comp9  = Focus_map[3][4];
                comp10 = Focus_map[3][5];
                comp11 = 0;
                comp12 = 0;
            end
            138  : begin
                comp1  = Focus_map[3][0];
                comp2  = Focus_map[4][0];
                comp3  = Focus_map[3][1];
                comp4  = Focus_map[4][1];
                comp5  = Focus_map[3][2];
                comp6  = Focus_map[4][2];
                comp7  = Focus_map[3][3];
                comp8  = Focus_map[4][3];
                comp9  = Focus_map[3][4];
                comp10 = Focus_map[4][4];
                comp11 = Focus_map[3][5];
                comp12 = Focus_map[4][5];
            end
            139  : begin
                comp1  = Focus_map[4][0];
                comp2  = Focus_map[4][1];
                comp3  = Focus_map[4][1];
                comp4  = Focus_map[4][2];
                comp5  = Focus_map[4][2];
                comp6  = Focus_map[4][3];
                comp7  = Focus_map[4][3];
                comp8  = Focus_map[4][4];
                comp9  = Focus_map[4][4];
                comp10 = Focus_map[4][5];
                comp11 = 0;
                comp12 = 0;
            end
            140  : begin
                comp1  = Focus_map[4][0];
                comp2  = Focus_map[5][0];
                comp3  = Focus_map[4][1];
                comp4  = Focus_map[5][1];
                comp5  = Focus_map[4][2];
                comp6  = Focus_map[5][2];
                comp7  = Focus_map[4][3];
                comp8  = Focus_map[5][3];
                comp9  = Focus_map[4][4];
                comp10 = Focus_map[5][4];
                comp11 = Focus_map[4][5];
                comp12 = Focus_map[5][5];
            end
            141  : begin
                comp1  = Focus_map[5][0];
                comp2  = Focus_map[5][1];
                comp3  = Focus_map[5][1];
                comp4  = Focus_map[5][2];
                comp5  = Focus_map[5][2];
                comp6  = Focus_map[5][3];
                comp7  = Focus_map[5][3];
                comp8  = Focus_map[5][4];
                comp9  = Focus_map[5][4];
                comp10 = Focus_map[5][5];
                comp11 = 0;
                comp12 = 0;
            end
    default:begin
        comp1  = 0;
        comp2  = 0;
        comp3  = 0;
        comp4  = 0;
        comp5  = 0;
        comp6  = 0;
        comp7  = 0;
        comp8  = 0;
        comp9  = 0;
        comp10 = 0;
        comp11 = 0;
        comp12 = 0;
    end
    endcase
end

always @(posedge clk) begin
    row_mi_1 <= column2-column1;
    row_mi_2 <= column4-column3;
    row_mi_3 <= column6-column5;
    row_mi_4 <= column8-column7;
    row_mi_5 <= column10-column9;
    row_mi_6 <= column12-column11;
end

always @(*) begin
    column_mi_all4 = row_mi_2 + row_mi_all2;
    row_mi_all6 = row_mi_1 + row_mi_all4 + row_mi_6;
    row_mi_all4 = column_mi_all4 + row_mi_5;
    row_mi_all2 = row_mi_3 + row_mi_4;
end

always @(posedge clk) begin
    if(current_state==IDLE)reg6x6<=0;
    else if(counter>131 && counter<143)reg6x6 <= reg6x6 + row_mi_all6;
    else if(counter==143)reg6x6 <= reg6x6/36;
end

always @(posedge clk) begin
    if(current_state==IDLE)reg4x4<=0;
    else if(counter==134||counter==136||counter==138||counter==140)reg4x4 <= reg4x4 + column_mi_all4;
    else if(counter==135||counter==137||counter==139)reg4x4 <= reg4x4 + row_mi_all4;
    else if(counter==143)reg4x4 <= reg4x4 >> 4;
end

always @(posedge clk) begin
    if(current_state==IDLE)reg2x2<=0;
    else if(counter==137)reg2x2 <= reg2x2 + row_mi_all2;
    else if(counter==136||counter==138)reg2x2 <= reg2x2 + row_mi_3;
    else if(counter==143)reg2x2 <= reg2x2 >> 2;
end

//---------------------------------------------------------------------
//   EXP CAL
//---------------------------------------------------------------------

always @(posedge clk) begin
    if(mode == 1)begin
        if(ratio==0)begin
            EXP_in1  <= rdata_s_inf[7:0]     >>2;
            EXP_in2  <= rdata_s_inf[15:8]    >>2;
            EXP_in3  <= rdata_s_inf[23:16]   >>2;
            EXP_in4  <= rdata_s_inf[31:24]   >>2;
            EXP_in5  <= rdata_s_inf[39:32]   >>2;
            EXP_in6  <= rdata_s_inf[47:40]   >>2;
            EXP_in7  <= rdata_s_inf[55:48]   >>2;
            EXP_in8  <= rdata_s_inf[63:56]   >>2;
            EXP_in9  <= rdata_s_inf[71:64]   >>2;
            EXP_in10 <= rdata_s_inf[79:72]   >>2;
            EXP_in11 <= rdata_s_inf[87:80]   >>2;
            EXP_in12 <= rdata_s_inf[95:88]   >>2;
            EXP_in13 <= rdata_s_inf[103:96]  >>2;
            EXP_in14 <= rdata_s_inf[111:104] >>2;
            EXP_in15 <= rdata_s_inf[119:112] >>2;
            EXP_in16 <= rdata_s_inf[127:120] >>2;
        end
        else if(ratio==1)begin
            EXP_in1  <= rdata_s_inf[7:0]     >>1;
            EXP_in2  <= rdata_s_inf[15:8]    >>1;
            EXP_in3  <= rdata_s_inf[23:16]   >>1;
            EXP_in4  <= rdata_s_inf[31:24]   >>1;
            EXP_in5  <= rdata_s_inf[39:32]   >>1;
            EXP_in6  <= rdata_s_inf[47:40]   >>1;
            EXP_in7  <= rdata_s_inf[55:48]   >>1;
            EXP_in8  <= rdata_s_inf[63:56]   >>1;
            EXP_in9  <= rdata_s_inf[71:64]   >>1;
            EXP_in10 <= rdata_s_inf[79:72]   >>1;
            EXP_in11 <= rdata_s_inf[87:80]   >>1;
            EXP_in12 <= rdata_s_inf[95:88]   >>1;
            EXP_in13 <= rdata_s_inf[103:96]  >>1;
            EXP_in14 <= rdata_s_inf[111:104] >>1;
            EXP_in15 <= rdata_s_inf[119:112] >>1;
            EXP_in16 <= rdata_s_inf[127:120] >>1;
        end
        else if(ratio==3)begin 
            EXP_in1  <= rdata_s_inf[7:0]     <<1;
            EXP_in2  <= rdata_s_inf[15:8]    <<1;
            EXP_in3  <= rdata_s_inf[23:16]   <<1;
            EXP_in4  <= rdata_s_inf[31:24]   <<1;
            EXP_in5  <= rdata_s_inf[39:32]   <<1;
            EXP_in6  <= rdata_s_inf[47:40]   <<1;
            EXP_in7  <= rdata_s_inf[55:48]   <<1;
            EXP_in8  <= rdata_s_inf[63:56]   <<1;
            EXP_in9  <= rdata_s_inf[71:64]   <<1;
            EXP_in10 <= rdata_s_inf[79:72]   <<1;
            EXP_in11 <= rdata_s_inf[87:80]   <<1;
            EXP_in12 <= rdata_s_inf[95:88]   <<1;
            EXP_in13 <= rdata_s_inf[103:96]  <<1;
            EXP_in14 <= rdata_s_inf[111:104] <<1;
            EXP_in15 <= rdata_s_inf[119:112] <<1;
            EXP_in16 <= rdata_s_inf[127:120] <<1;
        end
        else begin
            EXP_in1  <= rdata_s_inf[7:0]    ;
            EXP_in2  <= rdata_s_inf[15:8]   ;
            EXP_in3  <= rdata_s_inf[23:16]  ;
            EXP_in4  <= rdata_s_inf[31:24]  ;
            EXP_in5  <= rdata_s_inf[39:32]  ;
            EXP_in6  <= rdata_s_inf[47:40]  ;
            EXP_in7  <= rdata_s_inf[55:48]  ;
            EXP_in8  <= rdata_s_inf[63:56]  ;
            EXP_in9  <= rdata_s_inf[71:64]  ;
            EXP_in10 <= rdata_s_inf[79:72]  ;
            EXP_in11 <= rdata_s_inf[87:80]  ;
            EXP_in12 <= rdata_s_inf[95:88]  ;
            EXP_in13 <= rdata_s_inf[103:96] ;
            EXP_in14 <= rdata_s_inf[111:104];
            EXP_in15 <= rdata_s_inf[119:112];
            EXP_in16 <= rdata_s_inf[127:120];
        end
    end
    /*else begin
        EXP_in1  <= 0;
        EXP_in2  <= 0;
        EXP_in3  <= 0;
        EXP_in4  <= 0;
        EXP_in5  <= 0;
        EXP_in6  <= 0;
        EXP_in7  <= 0;
        EXP_in8  <= 0;
        EXP_in9  <= 0;
        EXP_in10 <= 0;
        EXP_in11 <= 0;
        EXP_in12 <= 0;
        EXP_in13 <= 0;
        EXP_in14 <= 0;
        EXP_in15 <= 0;
        EXP_in16 <= 0;
    end*/
end

always @(posedge clk) begin
    //if(current_state==EXP_CAL || current_state==EXP_CAL2)begin
        W_DATA[7:0]     <= (EXP_in1 <256)?EXP_in1 :255;
        W_DATA[15:8]    <= (EXP_in2 <256)?EXP_in2 :255;
        W_DATA[23:16]   <= (EXP_in3 <256)?EXP_in3 :255;
        W_DATA[31:24]   <= (EXP_in4 <256)?EXP_in4 :255;
        W_DATA[39:32]   <= (EXP_in5 <256)?EXP_in5 :255;
        W_DATA[47:40]   <= (EXP_in6 <256)?EXP_in6 :255;
        W_DATA[55:48]   <= (EXP_in7 <256)?EXP_in7 :255;
        W_DATA[63:56]   <= (EXP_in8 <256)?EXP_in8 :255;
        W_DATA[71:64]   <= (EXP_in9 <256)?EXP_in9 :255;
        W_DATA[79:72]   <= (EXP_in10<256)?EXP_in10:255;
        W_DATA[87:80]   <= (EXP_in11<256)?EXP_in11:255;
        W_DATA[95:88]   <= (EXP_in12<256)?EXP_in12:255;
        W_DATA[103:96]  <= (EXP_in13<256)?EXP_in13:255;
        W_DATA[111:104] <= (EXP_in14<256)?EXP_in14:255;
        W_DATA[119:112] <= (EXP_in15<256)?EXP_in15:255;
        W_DATA[127:120] <= (EXP_in16<256)?EXP_in16:255;
    //end
    //else begin
       // W_DATA <= 0;
    //end
end

always @(*) begin
    if(counter>65 && counter<130)begin
        move = 1 ;
    end
    else begin
        move = 2 ;
    end
end

always @(posedge clk) begin
    Avg_cnt1  <= W_DATA[7:0]    >>move;
    Avg_cnt2  <= W_DATA[15:8]   >>move;
    Avg_cnt3  <= W_DATA[23:16]  >>move;
    Avg_cnt4  <= W_DATA[31:24]  >>move;
    Avg_cnt5  <= W_DATA[39:32]  >>move;
    Avg_cnt6  <= W_DATA[47:40]  >>move;
    Avg_cnt7  <= W_DATA[55:48]  >>move;
    Avg_cnt8  <= W_DATA[63:56]  >>move;
    Avg_cnt9  <= W_DATA[71:64]  >>move;
    Avg_cnt10 <= W_DATA[79:72]  >>move;
    Avg_cnt11 <= W_DATA[87:80]  >>move;
    Avg_cnt12 <= W_DATA[95:88]  >>move;
    Avg_cnt13 <= W_DATA[103:96] >>move;
    Avg_cnt14 <= W_DATA[111:104]>>move;
    Avg_cnt15 <= W_DATA[119:112]>>move;
    Avg_cnt16 <= W_DATA[127:120]>>move;
end

/*always @(*) begin
    if(counter>63 && counter<128)begin
        Avg_cnt1  = W_DATA[7:0]     >>1;
        Avg_cnt2  = W_DATA[15:8]    >>1;
        Avg_cnt3  = W_DATA[23:16]   >>1;
        Avg_cnt4  = W_DATA[31:24]   >>1;
        Avg_cnt5  = W_DATA[39:32]   >>1;
        Avg_cnt6  = W_DATA[47:40]   >>1;
        Avg_cnt7  = W_DATA[55:48]   >>1;
        Avg_cnt8  = W_DATA[63:56]   >>1;
        Avg_cnt9  = W_DATA[71:64]   >>1;
        Avg_cnt10 = W_DATA[79:72]   >>1;
        Avg_cnt11 = W_DATA[87:80]   >>1;
        Avg_cnt12 = W_DATA[95:88]   >>1;
        Avg_cnt13 = W_DATA[103:96]  >>1;
        Avg_cnt14 = W_DATA[111:104] >>1;
        Avg_cnt15 = W_DATA[119:112] >>1;
        Avg_cnt16 = W_DATA[127:120] >>1;
    end
    else begin
        Avg_cnt1  = W_DATA[7:0]    >>2;
        Avg_cnt2  = W_DATA[15:8]   >>2;
        Avg_cnt3  = W_DATA[23:16]  >>2;
        Avg_cnt4  = W_DATA[31:24]  >>2;
        Avg_cnt5  = W_DATA[39:32]  >>2;
        Avg_cnt6  = W_DATA[47:40]  >>2;
        Avg_cnt7  = W_DATA[55:48]  >>2;
        Avg_cnt8  = W_DATA[63:56]  >>2;
        Avg_cnt9  = W_DATA[71:64]  >>2;
        Avg_cnt10 = W_DATA[79:72]  >>2;
        Avg_cnt11 = W_DATA[87:80]  >>2;
        Avg_cnt12 = W_DATA[95:88]  >>2;
        Avg_cnt13 = W_DATA[103:96] >>2;
        Avg_cnt14 = W_DATA[111:104]>>2;
        Avg_cnt15 = W_DATA[119:112]>>2;
        Avg_cnt16 = W_DATA[127:120]>>2;
    end
end*/

always @(posedge clk) begin
    Avg_add <= Avg_cnt1 + Avg_cnt2 + Avg_cnt3 + Avg_cnt4 + Avg_cnt5 + Avg_cnt6 + Avg_cnt7 + Avg_cnt8 + Avg_cnt9 + Avg_cnt10 + Avg_cnt11 + Avg_cnt12 + Avg_cnt13 + Avg_cnt14 + Avg_cnt15 + Avg_cnt16; 
end


always @(posedge clk/* or negedge rst_n*/) begin
    /*if(!rst_n)Avg_out <= 0; 
    else*/ if(current_state==EXP_CAL)Avg_out <= 0 ;
    else if(counter<195)Avg_out <= Avg_out + Avg_add ;
    else if(counter==195)Avg_out <= Avg_out>>10 ;
end

always @(posedge clk) begin
    W_DATA_seq <= W_DATA;
    W_DATA_seq2 <= W_DATA_seq;
    //W_DATA_seq3 <= W_DATA_seq2;
    //W_DATA_seq4 <= W_DATA_seq3;
end

always @(*) begin
	if((current_state == DRAM_EXP_READ || current_state == EXP_CAL || current_state == EXP_CAL2) && mode == 1) begin
		wdata_s_inf = W_DATA_seq2;
	end
	else begin
		wdata_s_inf = 0;
	end
end
//---------------------------------------------------------------------
//   Average of Min and Max in Picture
//---------------------------------------------------------------------
always @(*) begin
    if(mode ==2)begin
        data[0]  = rdata_s_inf[7:0]    ;
        data[1]  = rdata_s_inf[15:8]   ;
        data[2]  = rdata_s_inf[23:16]  ;
        data[3]  = rdata_s_inf[31:24]  ;
        data[4]  = rdata_s_inf[39:32]  ;
        data[5]  = rdata_s_inf[47:40]  ;
        data[6]  = rdata_s_inf[55:48]  ;
        data[7]  = rdata_s_inf[63:56]  ;
        data[8]  = rdata_s_inf[71:64]  ;
        data[9]  = rdata_s_inf[79:72]  ;
        data[10] = rdata_s_inf[87:80]  ;
        data[11] = rdata_s_inf[95:88]  ;
        data[12] = rdata_s_inf[103:96] ;
        data[13] = rdata_s_inf[111:104];
        data[14] = rdata_s_inf[119:112];
        data[15] = rdata_s_inf[127:120];
    end
    else begin
        data[0]  = 0;
        data[1]  = 0;
        data[2]  = 0;
        data[3]  = 0;
        data[4]  = 0;
        data[5]  = 0;
        data[6]  = 0;
        data[7]  = 0;
        data[8]  = 0;
        data[9]  = 0;
        data[10] = 0;
        data[11] = 0;
        data[12] = 0;
        data[13] = 0;
        data[14] = 0;
        data[15] = 0;
    end
end
//first max
assign max_stage1[0] = (data[0] > data[1]) ? data[0] : data[1];
assign max_stage1[1] = (data[2] > data[3]) ? data[2] : data[3];
assign max_stage1[2] = (data[4] > data[5]) ? data[4] : data[5];
assign max_stage1[3] = (data[6] > data[7]) ? data[6] : data[7];
assign max_stage1[4] = (data[8] > data[9]) ? data[8] : data[9];
assign max_stage1[5] = (data[10] > data[11]) ? data[10] : data[11];
assign max_stage1[6] = (data[12] > data[13]) ? data[12] : data[13];
assign max_stage1[7] = (data[14] > data[15]) ? data[14] : data[15];
//first min
assign min_stage1[0] = (data[0] < data[1]) ? data[0] : data[1];
assign min_stage1[1] = (data[2] < data[3]) ? data[2] : data[3];
assign min_stage1[2] = (data[4] < data[5]) ? data[4] : data[5];
assign min_stage1[3] = (data[6] < data[7]) ? data[6] : data[7];
assign min_stage1[4] = (data[8] < data[9]) ? data[8] : data[9];
assign min_stage1[5] = (data[10] < data[11]) ? data[10] : data[11];
assign min_stage1[6] = (data[12] < data[13]) ? data[12] : data[13];
assign min_stage1[7] = (data[14] < data[15]) ? data[14] : data[15];
//sec max
assign max_stage2[0] = (max_stage1[0] > max_stage1[1]) ? max_stage1[0] : max_stage1[1];
assign max_stage2[1] = (max_stage1[2] > max_stage1[3]) ? max_stage1[2] : max_stage1[3];
assign max_stage2[2] = (max_stage1[4] > max_stage1[5]) ? max_stage1[4] : max_stage1[5];
assign max_stage2[3] = (max_stage1[6] > max_stage1[7]) ? max_stage1[6] : max_stage1[7];
//sec min
assign min_stage2[0] = (min_stage1[0] < min_stage1[1]) ? min_stage1[0] : min_stage1[1];
assign min_stage2[1] = (min_stage1[2] < min_stage1[3]) ? min_stage1[2] : min_stage1[3];
assign min_stage2[2] = (min_stage1[4] < min_stage1[5]) ? min_stage1[4] : min_stage1[5];
assign min_stage2[3] = (min_stage1[6] < min_stage1[7]) ? min_stage1[6] : min_stage1[7];
//third min
assign max_stage3[0] = (max_stage2[0] > max_stage2[1]) ? max_stage2[0] : max_stage2[1];
assign max_stage3[1] = (max_stage2[2] > max_stage2[3]) ? max_stage2[2] : max_stage2[3];
//third max
assign min_stage3[0] = (min_stage2[0] < min_stage2[1]) ? min_stage2[0] : min_stage2[1];
assign min_stage3[1] = (min_stage2[2] < min_stage2[3]) ? min_stage2[2] : min_stage2[3];
//last max
assign max_final = (max_stage3[0] > max_stage3[1]) ? max_stage3[0] : max_stage3[1];
assign min_final = (min_stage3[0] < min_stage3[1]) ? min_stage3[0] : min_stage3[1];

/*always @(posedge clk) begin
    if(current_state==IDLE) begin
        max_R <= 0;
    end
    else if(counter == 0) begin
        max_R <= max_final;
    end
    else if(counter <= 63) begin
        max_R <= (max_final > max_R) ? max_final : max_R;
    end
end

always @(posedge clk) begin
    if(current_state==IDLE) begin
        max_G <= 0;
    end
    else if(counter == 64) begin
        max_G <= max_final;
    end
    else if(counter >= 64 && counter <= 127) begin
        max_G <= (max_final > max_G) ? max_final : max_G;
    end
end

always @(posedge clk) begin
    if(current_state==IDLE) begin
        max_B <= 0;
    end
    else if(counter == 128) begin
        max_B <= max_final;
    end
    else if(counter >= 128 && counter <= 192) begin
        max_B <= (max_final > max_B) ? max_final : max_B;
    end
end

always @(posedge clk) begin
    if(current_state==IDLE) begin
        min_R <= 0;
    end
    else if(counter == 0) begin
        min_R <= min_final;
    end
    else if(counter <= 63) begin
        min_R <= (min_final < min_R) ? min_final : min_R;
    end
end

always @(posedge clk) begin
    if(current_state==IDLE) begin
        min_G <= 0;
    end
    else if(counter == 64) begin
        min_G <= min_final;
    end
    else if(counter >= 64 && counter <= 127) begin
        min_G <= (min_final < min_G) ? min_final : min_G;
    end
end

always @(posedge clk) begin
    if(current_state==IDLE) begin
        min_B <= 0;
    end
    else if(counter == 128) begin
        min_B <= min_final;
    end
    else if(counter >= 128 && counter <= 192) begin
        min_B <= (min_final < min_B) ? min_final : min_B;
    end
end*/

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        max_R <= 0;
    end
    else if(current_state==IDLE) begin
        max_R <= 0;
    end
    else if(counter == 0 && mode == 2) begin
        max_R <= max_final;
    end
    else if(counter <= 63 && mode == 2) begin
        max_R <= (max_final > max_R) ? max_final : max_R;
    end
    else max_R <= max_R;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        max_G <= 0;
    end
    else if(current_state==IDLE) begin
        max_G <= 0;
    end
    else if(counter == 64 && mode == 2) begin
        max_G <= max_final;
    end
    else if(counter > 64 && counter <= 127 && mode == 2) begin
        max_G <= (max_final > max_G) ? max_final : max_G;
    end
    else max_G <= max_G;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        max_B <= 0;
    end
    else if(current_state==IDLE) begin
        max_B <= 0;
    end
    else if(counter == 128 && mode == 2) begin
        max_B <= max_final;
    end
    else if(counter > 128 && counter <= 192 && mode == 2) begin
        max_B <= (max_final > max_B) ? max_final : max_B;
    end
    else max_B <= max_B;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        min_R <= 0;
    end
    else if(current_state==IDLE) begin
        min_R <= 0;
    end
    else if(counter == 0 && mode == 2) begin
        min_R <= min_final;
    end
    else if(counter <= 63 && mode == 2) begin
        min_R <= (min_final < min_R) ? min_final : min_R;
    end
    else min_R <= min_R;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        min_G <= 0;
    end
    else if(current_state==IDLE) begin
        min_G <= 0;
    end
    else if(counter == 64 && mode == 2) begin
        min_G <= min_final;
    end
    else if(counter > 64 && counter <= 127 && mode == 2) begin
        min_G <= (min_final < min_G) ? min_final : min_G;
    end
    else min_G <= min_G;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        min_B <= 0;
    end
    else if(current_state==IDLE) begin
        min_B <= 0;
    end
    else if(counter == 128 && mode == 2) begin
        min_B <= min_final;
    end
    else if(counter > 128 && counter <= 192 && mode == 2) begin
        min_B <= (min_final < min_B) ? min_final : min_B;
    end
    else min_B <= min_B;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        result <= 0;
    end
    else begin
        result <= ((min_R+min_G+min_B)/3 + (max_R+max_G+max_B)/3) >> 1 ;
    end
end


//---------------------------------------------------------------------
//   Read DRAM
//---------------------------------------------------------------------
assign arid_s_inf = 0;
//assign arburst_s_inf = 1;
//assign arsize_s_inf = 4;

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
        arburst_s_inf <= 0;
        arsize_s_inf  <= 0;
	end
	else begin
        arburst_s_inf <= 1;
        arsize_s_inf  <= 4;
	end
end


always @(*) begin
	if(current_state == DRAM_FOCUS_READ || current_state == DRAM_EXP_READ) begin
		arvalid_s_inf = 1;
	end
	else begin
		arvalid_s_inf = 0;
	end
end

always @(*) begin
	if(current_state == DRAM_FOCUS_READ) begin
		araddr_s_inf = 32'h0001_0000 + pic_num * 3072 + 429;
	end
    else if(current_state == DRAM_EXP_READ) begin
		araddr_s_inf = 32'h0001_0000 + pic_num * 3072;
	end
	else begin
		araddr_s_inf = 0;
	end
end

always @(*) begin
	if(current_state == DRAM_FOCUS_READ || current_state == FOCUS_CAL || current_state == DRAM_EXP_READ || current_state == EXP_CAL|| current_state == EXP_CAL2) begin
		rready_s_inf = 1;
	end
	else begin
		rready_s_inf = 0;
	end
end

always @(*) begin
	if(current_state == DRAM_FOCUS_READ) begin
		arlen_s_inf = 138;
	end
    else if(current_state == DRAM_EXP_READ) begin
		arlen_s_inf = 191;
	end
	else begin
		arlen_s_inf = 0;
	end
end

//---------------------------------------------------------------------
//   WRITE DRAM
//---------------------------------------------------------------------
//assign awid_s_inf = 0;
//assign awburst_s_inf = 1;
//assign awsize_s_inf =  (!rst_n) ? 0 :4;
//assign awlen_s_inf = (!rst_n) ? 0 : 192;
assign awvalid_s_inf = (current_state == DRAM_EXP_READ && mode == 1) ? 1 : 0;


always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
        awid_s_inf     <= 0;
        awburst_s_inf  <= 0;
        awsize_s_inf   <= 0;
		awlen_s_inf    <= 0;
	end
	else begin
        awid_s_inf     <= 0;
        awburst_s_inf  <= 1;
        awsize_s_inf   <= 4;
		awlen_s_inf    <= 191;
	end
end

always @(*) begin
	if((current_state == DRAM_EXP_READ || current_state == EXP_CAL2  || current_state == EXP_CAL  || current_state == WAIT_BVALID) && mode==1) begin
        bready_s_inf = 1;
	end
	else begin
        bready_s_inf = 0;
	end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        wvalid_s_inf <= 0;
	end
	else if( (rvalid_s_inf || current_state == EXP_CAL2) && mode==1) begin
        wvalid_s_inf <= 1;
	end
	else begin
        wvalid_s_inf <= 0;
	end
end

always @(*) begin
	if(current_state == EXP_CAL2 && counter == 195 && mode==1) begin
        wlast_s_inf = 1;
	end
	else begin
        wlast_s_inf = 0;
	end
end

always @(*) begin
	if(current_state == DRAM_EXP_READ && mode==1) begin
		awaddr_s_inf = 32'h0001_0000 + pic_num * 3072;
	end
	else begin
		awaddr_s_inf = 0;
	end
end

//---------------------------------------------------------------------
//   Output design
//---------------------------------------------------------------------
always @(*) begin
	if(current_state == OUT) begin
		out_valid = 1;
	end
	else begin
		out_valid = 0;
	end
end

always @(*) begin
	if(current_state == OUT) begin
        if((!plus0 && pic_num==0)||(!plus1 && pic_num==1)||(!plus2 && pic_num==2)||(!plus3 && pic_num==3)||(!plus4 && pic_num==4)||(!plus5 && pic_num==5)||(!plus6 && pic_num==6)||(!plus7 && pic_num==7)||(!plus8 && pic_num==8)||(!plus9 && pic_num==9)||(!plus10 && pic_num==10)||(!plus11 && pic_num==11)||(!plus12 && pic_num==12)||(!plus13 && pic_num==13)||(!plus14 && pic_num==14)||(!plus15 && pic_num==15))out_data = 0;
        else if(mode == 0)begin
            if((reg2x2>=reg4x4)&&(reg2x2>=reg6x6))begin
		        out_data = 0;
            end
            else if((reg4x4>=reg2x2)&&(reg4x4>=reg6x6))begin
		        out_data = 1;
            end
            else out_data = 2;
        end
        else if(mode == 2)begin
            out_data = result;
        end
        else out_data = Avg_out;
	end
	else begin
		out_data = 0;
	end
end

endmodule
