//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2023 Fall
//   Lab04 Exercise		: Convolution Neural Network 
//   Author     		: Yu-Chi Lin (a6121461214.st12@nycu.edu.tw)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : CNN.v
//   Module Name : CNN
//   Release version : V1.0 (Release Date: 2024-10)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module CNN(
    //Input Port
    clk,
    rst_n,
    in_valid,
    Img,
    Kernel_ch1,
    Kernel_ch2,
	Weight,
    Opt,

    //Output Port
    out_valid,
    out
    );


//---------------------------------------------------------------------
//   PARAMETER
//---------------------------------------------------------------------

// IEEE floating point parameter
parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 0;
parameter inst_arch_type = 0;
parameter inst_arch = 0;
parameter inst_faithful_round = 0;


input rst_n, clk, in_valid;
input [inst_sig_width+inst_exp_width:0] Img, Kernel_ch1, Kernel_ch2, Weight;
input Opt;

output reg	out_valid;
output reg [inst_sig_width+inst_exp_width:0] out;

//==============================================//
//       parameter & integer declaration        //
//==============================================//

integer i,j;
parameter IDLE = 0;
parameter IN_DATA = 1;
parameter MAX_POOL = 2;

//---------------------------------------------------------------------
//   Reg & Wires
//---------------------------------------------------------------------
reg [1:0]current_state,next_state;

reg [31:0]image1[0:6][0:6];
reg [31:0]image2[0:6][0:6];
reg [31:0]image3[0:6][0:6];

reg [31:0]conv_map1[0:5][0:5];
reg [31:0]conv_map2[0:5][0:5];

reg [31:0]kernel1_1[0:1][0:1];
reg [31:0]kernel1_2[0:1][0:1];
reg [31:0]kernel1_3[0:1][0:1];

reg [31:0]kernel2_1[0:1][0:1];
reg [31:0]kernel2_2[0:1][0:1];
reg [31:0]kernel2_3[0:1][0:1];

reg [31:0]weight1[0:7];
reg [31:0]weight2[0:7];
reg [31:0]weight3[0:7];
reg [31:0]wei1,wei2,wei3,wei4,wei5,wei6,wei7,wei8;



reg [31:0]cmp1,cmp2,cmp3,cmp4,cmp5,cmp6,cmp7,cmp8,cmp9;
reg [31:0]cmp1_2,cmp2_2,cmp3_2,cmp4_2,cmp5_2,cmp6_2,cmp7_2,cmp8_2,cmp9_2;
reg [31:0]cmp12,cmp34,cmp56,cmp78;
reg [31:0]cmp12_2,cmp34_2,cmp56_2,cmp78_2;
reg [31:0]cmp1234,cmp5678;
reg [31:0]cmp1234_2,cmp5678_2;
reg [31:0]cmp1_8;
reg [31:0]cmp1_8_2;
reg [31:0]cmpall,cmpall_2;
reg [31:0]div_fc;
reg [31:0]soft_out;
reg [31:0]softall1;
reg [31:0]softall2;
reg [31:0]softall3;

reg [31:0]act1,act2,act3,act4,act5,act6,act7,act8;
reg [31:0]actmul1,actmul2,actmul3,actmul4,actmul5,actmul6,actmul7,actmul8;
reg [31:0]actmul12,actmul34,actmul56,actmul78;
reg [31:0]actmul1234,actmul5678;
reg [31:0]softadd;
reg [31:0]fcall;
reg [31:0]fcall_exp;
reg [31:0]fcout1,fcout2,fcout3;

reg [31:0]window1_1,window1_2,window1_3,window1_4;
reg [31:0]kernal_cal1_1,kernal_cal1_2,kernal_cal1_3,kernal_cal1_4,kernal_cal2_1,kernal_cal2_2,kernal_cal2_3,kernal_cal2_4;
reg [31:0]mul1,mul2,mul3,mul4,mul5,mul6,mul7,mul8;
reg [31:0]conv_add1,conv_add2,conv_add3,conv_add4;
reg [31:0]conv_out_1,conv_out_2;
reg [31:0]conv_map_out1,conv_map_out2;
reg [31:0]conv_out_all1,conv_out_all2;

reg [7:0]counter;
reg Opt_in;
reg [4:0]counter_max;

reg [31:0]sig_out;
reg [31:0]tanh_deno;
reg [31:0]tanh_nume;
reg [31:0]sigmoid;
reg [31:0]act_in;
reg [31:0]e_pos;
reg [31:0]e_neg;
reg [31:0]div_in_1;
reg [31:0]div_in_2;

//---------------------------------------------------------------------
//   FSM
//---------------------------------------------------------------------
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) current_state <= 0;
	else current_state <= next_state;
end

always @(*) begin
	case(current_state)
        IDLE:begin//0
            if(in_valid) next_state = IN_DATA;
            else next_state = IDLE;
        end
        IN_DATA:begin//1
            if(counter==133) next_state = MAX_POOL;
            else next_state = IN_DATA;
        end
        MAX_POOL:begin//2
            if(counter_max==16) next_state = IDLE;
            else next_state = MAX_POOL;
        end
        default:next_state = IDLE;
	endcase
end

//==============================================//
//                   COUNTER                    //
//==============================================//
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) counter <= 0;
    else if(in_valid) counter <= counter + 1;
    else if(current_state==IN_DATA) counter <= counter + 1;
    else if(current_state==IDLE) counter <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) counter_max <= 0;
    else if(current_state==MAX_POOL) counter_max <= counter_max + 1;
    else if(current_state==IDLE) counter_max <= 0;
end


//---------------------------------------------------------------------
//   DESIGN
//---------------------------------------------------------------------
always @(posedge clk or negedge rst_n) begin//opt
    if(!rst_n) Opt_in <= 0;
    else if (in_valid && counter==0) Opt_in <= Opt;
end

always @(posedge clk or negedge rst_n) begin//weight
    if(!rst_n) begin
        for(i = 0; i < 8; i = i + 1) begin
            weight1[i] <= 0;
            weight2[i] <= 0; 
            weight3[i] <= 0;   
        end
    end
    else if(in_valid)begin
        case(counter)
            0  : weight1[0] <= Weight;
            1  : weight1[1] <= Weight;
            2  : weight1[2] <= Weight;
            3  : weight1[3] <= Weight;
            4  : weight1[4] <= Weight;
            5  : weight1[5] <= Weight;
            6  : weight1[6] <= Weight;
            7  : weight1[7] <= Weight;
            8  : weight2[0] <= Weight;
            9  : weight2[1] <= Weight;
            10 : weight2[2] <= Weight;
            11 : weight2[3] <= Weight;
            12 : weight2[4] <= Weight;
            13 : weight2[5] <= Weight;
            14 : weight2[6] <= Weight;
            15 : weight2[7] <= Weight;
            16 : weight3[0] <= Weight;
            17 : weight3[1] <= Weight;
            18 : weight3[2] <= Weight;
            19 : weight3[3] <= Weight;
            20 : weight3[4] <= Weight;
            21 : weight3[5] <= Weight;
            22 : weight3[6] <= Weight;
            23 : weight3[7] <= Weight;
        endcase
    end
end

always @(posedge clk or negedge rst_n) begin//kernel1
    if(!rst_n) begin
        for(i = 0; i < 2; i = i + 1) begin
            for(j = 0; j < 2; j = j + 1) begin
                kernel1_1[i][j] <= 0;
                kernel1_2[i][j] <= 0; 
                kernel1_3[i][j] <= 0;
            end
        end
    end
    else if(in_valid)begin
        case(counter)
            0  : kernel1_1[0][0] <= Kernel_ch1;
            1  : kernel1_1[0][1] <= Kernel_ch1;
            2  : kernel1_1[1][0] <= Kernel_ch1;
            3  : kernel1_1[1][1] <= Kernel_ch1;
            4  : kernel1_2[0][0] <= Kernel_ch1;
            5  : kernel1_2[0][1] <= Kernel_ch1;
            6  : kernel1_2[1][0] <= Kernel_ch1;
            7  : kernel1_2[1][1] <= Kernel_ch1;
            8  : kernel1_3[0][0] <= Kernel_ch1;
            9  : kernel1_3[0][1] <= Kernel_ch1;
            10 : kernel1_3[1][0] <= Kernel_ch1;
            11 : kernel1_3[1][1] <= Kernel_ch1;
        endcase
    end
end

always @(posedge clk or negedge rst_n) begin//kernel2
    if(!rst_n) begin
        for(i = 0; i < 2; i = i + 1) begin
            for(j = 0; j < 2; j = j + 1) begin
                kernel2_1[i][j] <= 0;
                kernel2_2[i][j] <= 0; 
                kernel2_3[i][j] <= 0;
            end
        end
    end
    else if(in_valid)begin
        case(counter)
            0  : kernel2_1[0][0] <= Kernel_ch2;
            1  : kernel2_1[0][1] <= Kernel_ch2;
            2  : kernel2_1[1][0] <= Kernel_ch2;
            3  : kernel2_1[1][1] <= Kernel_ch2;
            4  : kernel2_2[0][0] <= Kernel_ch2;
            5  : kernel2_2[0][1] <= Kernel_ch2;
            6  : kernel2_2[1][0] <= Kernel_ch2;
            7  : kernel2_2[1][1] <= Kernel_ch2;
            8  : kernel2_3[0][0] <= Kernel_ch2;
            9  : kernel2_3[0][1] <= Kernel_ch2;
            10 : kernel2_3[1][0] <= Kernel_ch2;
            11 : kernel2_3[1][1] <= Kernel_ch2;
        endcase
    end
end

always @(posedge clk or negedge rst_n) begin//image1
    if(!rst_n) begin
        for(i = 0; i < 7; i = i + 1) begin
            for(j = 0; j < 7; j = j + 1) begin
                image1[i][j] <= 0;
            end
        end
    end
    else if(next_state == IDLE) begin
        for(i = 0; i < 7; i = i + 1) begin
            for(j = 0; j < 7; j = j + 1) begin
                image1[i][j] <= 0;
            end
        end
    end
    else if(in_valid && counter<=24)begin
        case(counter)
            0  : image1[1][1] <= Img;
            1  : image1[1][2] <= Img;
            2  : image1[1][3] <= Img;
            3  : image1[1][4] <= Img;
            4  : image1[1][5] <= Img;
            5  : image1[2][1] <= Img;
            6  : image1[2][2] <= Img;
            7  : image1[2][3] <= Img;
            8  : image1[2][4] <= Img;
            9  : image1[2][5] <= Img;
            10 : image1[3][1] <= Img;
            11 : image1[3][2] <= Img;
            12 : image1[3][3] <= Img;
            13 : image1[3][4] <= Img;
            14 : image1[3][5] <= Img;
            15 : image1[4][1] <= Img;
            16 : image1[4][2] <= Img;
            17 : image1[4][3] <= Img;
            18 : image1[4][4] <= Img;
            19 : image1[4][5] <= Img;
            20 : image1[5][1] <= Img;
            21 : image1[5][2] <= Img;
            22 : image1[5][3] <= Img;
            23 : image1[5][4] <= Img;
            24 : image1[5][5] <= Img;
        endcase
    end
    else if(counter==25 && Opt_in==1)begin//padding
        image1[0][0] <= image1[1][1];
        image1[0][1] <= image1[1][1];
        image1[0][2] <= image1[1][2];
        image1[0][3] <= image1[1][3];
        image1[0][4] <= image1[1][4];
        image1[0][5] <= image1[1][5];
        image1[0][6] <= image1[1][5];
        image1[1][0] <= image1[1][1];
        image1[1][6] <= image1[1][5];
        image1[2][0] <= image1[2][1];   
        image1[2][6] <= image1[2][5];   
        image1[3][0] <= image1[3][1];   
        image1[3][6] <= image1[3][5];   
        image1[4][0] <= image1[4][1];   
        image1[4][6] <= image1[4][5];   
        image1[5][0] <= image1[5][1];  
        image1[5][6] <= image1[5][5];   
        image1[6][0] <= image1[5][1];
        image1[6][1] <= image1[5][1];
        image1[6][2] <= image1[5][2];
        image1[6][3] <= image1[5][3];
        image1[6][4] <= image1[5][4];
        image1[6][5] <= image1[5][5];
        image1[6][6] <= image1[5][5];
    end 
    /*else begin
        for(i = 0; i < 7; i = i + 1) begin
            for(j = 0; j < 7; j = j + 1) begin
                image1[i][j] <= image1[i][j];
            end
        end
    end*/
end

always @(posedge clk or negedge rst_n) begin//image2
    if(!rst_n) begin
        for(i = 0; i < 7; i = i + 1) begin
            for(j = 0; j < 7; j = j + 1) begin
                image2[i][j] <= 0;
            end
        end
    end
    else if(next_state == IDLE) begin
        for(i = 0; i < 7; i = i + 1) begin
            for(j = 0; j < 7; j = j + 1) begin
                image2[i][j] <= 0;
            end
        end
    end
    else if(in_valid && counter<=49)begin
        case(counter)
            25 : image2[1][1] <= Img;
            26 : image2[1][2] <= Img;
            27 : image2[1][3] <= Img;
            28 : image2[1][4] <= Img;
            29 : image2[1][5] <= Img;
            30 : image2[2][1] <= Img;
            31 : image2[2][2] <= Img;
            32 : image2[2][3] <= Img;
            33 : image2[2][4] <= Img;
            34 : image2[2][5] <= Img;
            35 : image2[3][1] <= Img;
            36 : image2[3][2] <= Img;
            37 : image2[3][3] <= Img;
            38 : image2[3][4] <= Img;
            39 : image2[3][5] <= Img;
            40 : image2[4][1] <= Img;
            41 : image2[4][2] <= Img;
            42 : image2[4][3] <= Img;
            43 : image2[4][4] <= Img;
            44 : image2[4][5] <= Img;
            45 : image2[5][1] <= Img;
            46 : image2[5][2] <= Img;
            47 : image2[5][3] <= Img;
            48 : image2[5][4] <= Img;
            49 : image2[5][5] <= Img;
        endcase
    end
    else if(counter==50 && Opt_in==1)begin//padding
        image2[0][0] <= image2[1][1];
        image2[0][1] <= image2[1][1];
        image2[0][2] <= image2[1][2];
        image2[0][3] <= image2[1][3];
        image2[0][4] <= image2[1][4];
        image2[0][5] <= image2[1][5];
        image2[0][6] <= image2[1][5];
        image2[1][0] <= image2[1][1];
        image2[1][6] <= image2[1][5];
        image2[2][0] <= image2[2][1];   
        image2[2][6] <= image2[2][5];   
        image2[3][0] <= image2[3][1];   
        image2[3][6] <= image2[3][5];   
        image2[4][0] <= image2[4][1];   
        image2[4][6] <= image2[4][5];   
        image2[5][0] <= image2[5][1];  
        image2[5][6] <= image2[5][5];   
        image2[6][0] <= image2[5][1];
        image2[6][1] <= image2[5][1];
        image2[6][2] <= image2[5][2];
        image2[6][3] <= image2[5][3];
        image2[6][4] <= image2[5][4];
        image2[6][5] <= image2[5][5];
        image2[6][6] <= image2[5][5];
    end 
    /*else begin
        for(i = 0; i < 7; i = i + 1) begin
            for(j = 0; j < 7; j = j + 1) begin
                image2[i][j] <= image2[i][j];
            end
        end
    end*/
end

always @(posedge clk or negedge rst_n) begin//image3
    if(!rst_n) begin
        for(i = 0; i < 7; i = i + 1) begin
            for(j = 0; j < 7; j = j + 1) begin
                image3[i][j] <= 0;
            end
        end
    end
    else if(next_state == IDLE) begin
        for(i = 0; i < 7; i = i + 1) begin
            for(j = 0; j < 7; j = j + 1) begin
                image3[i][j] <= 0;
            end
        end
    end
    else if(in_valid)begin
        case(counter)
            50 : image3[1][1] <= Img;
            51 : image3[1][2] <= Img;
            52 : image3[1][3] <= Img;
            53 : image3[1][4] <= Img;
            54 : image3[1][5] <= Img;
            55 : image3[2][1] <= Img;
            56 : image3[2][2] <= Img;
            57 : image3[2][3] <= Img;
            58 : image3[2][4] <= Img;
            59 : image3[2][5] <= Img;
            60 : image3[3][1] <= Img;
            61 : image3[3][2] <= Img;
            62 : image3[3][3] <= Img;
            63 : image3[3][4] <= Img;
            64 : image3[3][5] <= Img;
            65 : image3[4][1] <= Img;
            66 : image3[4][2] <= Img;
            67 : image3[4][3] <= Img;
            68 : image3[4][4] <= Img;
            69 : image3[4][5] <= Img;
            70 : image3[5][1] <= Img;
            71 : image3[5][2] <= Img;
            72 : image3[5][3] <= Img;
            73 : image3[5][4] <= Img;
            74 : image3[5][5] <= Img;
        endcase
    end
    else if(counter==75 && Opt_in==1)begin//padding
        image3[0][0] <= image3[1][1];
        image3[0][1] <= image3[1][1];
        image3[0][2] <= image3[1][2];
        image3[0][3] <= image3[1][3];
        image3[0][4] <= image3[1][4];
        image3[0][5] <= image3[1][5];
        image3[0][6] <= image3[1][5];
        image3[1][0] <= image3[1][1];
        image3[1][6] <= image3[1][5];
        image3[2][0] <= image3[2][1];   
        image3[2][6] <= image3[2][5];   
        image3[3][0] <= image3[3][1];   
        image3[3][6] <= image3[3][5];   
        image3[4][0] <= image3[4][1];   
        image3[4][6] <= image3[4][5];   
        image3[5][0] <= image3[5][1];  
        image3[5][6] <= image3[5][5];   
        image3[6][0] <= image3[5][1];
        image3[6][1] <= image3[5][1];
        image3[6][2] <= image3[5][2];
        image3[6][3] <= image3[5][3];
        image3[6][4] <= image3[5][4];
        image3[6][5] <= image3[5][5];
        image3[6][6] <= image3[5][5];
    end 
    /*else begin
        for(i = 0; i < 7; i = i + 1) begin
            for(j = 0; j < 7; j = j + 1) begin
                image3[i][j] <= image3[i][j];
            end
        end
    end*/
end

always @(posedge clk/* or negedge rst_n*/) begin//window1_1234
    /*if(!rst_n)begin
        window1_1 <= 0;
        window1_2 <= 0;
        window1_3 <= 0;
        window1_4 <= 0;
    end
    else begin*/
        case(counter) 
        //img1     
            26:begin
                window1_1<=image1[0][0]; window1_2<=image1[0][1]; window1_3<=image1[1][0]; window1_4<=image1[1][1];
            end
            27:begin
                window1_1<=image1[0][1]; window1_2<=image1[0][2]; window1_3<=image1[1][1]; window1_4<=image1[1][2];
            end
            28:begin
                window1_1<=image1[0][2]; window1_2<=image1[0][3]; window1_3<=image1[1][2]; window1_4<=image1[1][3];
            end
            29:begin
                window1_1<=image1[0][3]; window1_2<=image1[0][4]; window1_3<=image1[1][3]; window1_4<=image1[1][4];
            end
            30:begin
                window1_1<=image1[0][4]; window1_2<=image1[0][5]; window1_3<=image1[1][4]; window1_4<=image1[1][5];
            end
            31:begin
                window1_1<=image1[0][5]; window1_2<=image1[0][6]; window1_3<=image1[1][5]; window1_4<=image1[1][6];
            end
            32:begin
                window1_1<=image1[1][0]; window1_2<=image1[1][1]; window1_3<=image1[2][0]; window1_4<=image1[2][1];
            end
            33:begin
                window1_1<=image1[1][1]; window1_2<=image1[1][2]; window1_3<=image1[2][1]; window1_4<=image1[2][2];
            end
            34:begin
                window1_1<=image1[1][2]; window1_2<=image1[1][3]; window1_3<=image1[2][2]; window1_4<=image1[2][3];
            end
            35:begin
                window1_1<=image1[1][3]; window1_2<=image1[1][4]; window1_3<=image1[2][3]; window1_4<=image1[2][4];
            end
            36:begin
                window1_1<=image1[1][4]; window1_2<=image1[1][5]; window1_3<=image1[2][4]; window1_4<=image1[2][5];
            end
            37:begin
                window1_1<=image1[1][5]; window1_2<=image1[1][6]; window1_3<=image1[2][5]; window1_4<=image1[2][6];
            end
            38:begin
                window1_1<=image1[2][0]; window1_2<=image1[2][1]; window1_3<=image1[3][0]; window1_4<=image1[3][1];
            end
            39:begin
                window1_1<=image1[2][1]; window1_2<=image1[2][2]; window1_3<=image1[3][1]; window1_4<=image1[3][2];
            end
            40:begin
                window1_1<=image1[2][2]; window1_2<=image1[2][3]; window1_3<=image1[3][2]; window1_4<=image1[3][3];
            end
            41:begin
                window1_1<=image1[2][3]; window1_2<=image1[2][4]; window1_3<=image1[3][3]; window1_4<=image1[3][4];
            end
            42:begin
                window1_1<=image1[2][4]; window1_2<=image1[2][5]; window1_3<=image1[3][4]; window1_4<=image1[3][5];
            end
            43:begin
                window1_1<=image1[2][5]; window1_2<=image1[2][6]; window1_3<=image1[3][5]; window1_4<=image1[3][6];
            end
            44:begin
                window1_1<=image1[3][0]; window1_2<=image1[3][1]; window1_3<=image1[4][0]; window1_4<=image1[4][1];
            end
            45:begin
                window1_1<=image1[3][1]; window1_2<=image1[3][2]; window1_3<=image1[4][1]; window1_4<=image1[4][2];
            end
            46:begin
                window1_1<=image1[3][2]; window1_2<=image1[3][3]; window1_3<=image1[4][2]; window1_4<=image1[4][3];
            end
            47:begin
                window1_1<=image1[3][3]; window1_2<=image1[3][4]; window1_3<=image1[4][3]; window1_4<=image1[4][4];
            end
            48:begin
                window1_1<=image1[3][4]; window1_2<=image1[3][5]; window1_3<=image1[4][4]; window1_4<=image1[4][5];
            end
            49:begin
                window1_1<=image1[3][5]; window1_2<=image1[3][6]; window1_3<=image1[4][5]; window1_4<=image1[4][6];
            end
            50:begin
                window1_1<=image1[4][0]; window1_2<=image1[4][1]; window1_3<=image1[5][0]; window1_4<=image1[5][1];
            end
            51:begin
                window1_1<=image1[4][1]; window1_2<=image1[4][2]; window1_3<=image1[5][1]; window1_4<=image1[5][2];
            end
            52:begin
                window1_1<=image1[4][2]; window1_2<=image1[4][3]; window1_3<=image1[5][2]; window1_4<=image1[5][3];
            end
            53:begin
                window1_1<=image1[4][3]; window1_2<=image1[4][4]; window1_3<=image1[5][3]; window1_4<=image1[5][4];
            end
            54:begin
                window1_1<=image1[4][4]; window1_2<=image1[4][5]; window1_3<=image1[5][4]; window1_4<=image1[5][5];
            end
            55:begin
                window1_1<=image1[4][5]; window1_2<=image1[4][6]; window1_3<=image1[5][5]; window1_4<=image1[5][6];
            end
            56:begin
                window1_1<=image1[5][0]; window1_2<=image1[5][1]; window1_3<=image1[6][0]; window1_4<=image1[6][1];
            end
            57:begin
                window1_1<=image1[5][1]; window1_2<=image1[5][2]; window1_3<=image1[6][1]; window1_4<=image1[6][2];
            end
            58:begin
                window1_1<=image1[5][2]; window1_2<=image1[5][3]; window1_3<=image1[6][2]; window1_4<=image1[6][3];
            end
            59:begin
                window1_1<=image1[5][3]; window1_2<=image1[5][4]; window1_3<=image1[6][3]; window1_4<=image1[6][4];
            end
            60:begin
                window1_1<=image1[5][4]; window1_2<=image1[5][5]; window1_3<=image1[6][4]; window1_4<=image1[6][5];
            end
            61:begin
                window1_1<=image1[5][5]; window1_2<=image1[5][6]; window1_3<=image1[6][5]; window1_4<=image1[6][6];
            end
        //img2
            62:begin
                window1_1<=image2[0][0]; window1_2<=image2[0][1]; window1_3<=image2[1][0]; window1_4<=image2[1][1];
            end
            63:begin
                window1_1<=image2[0][1]; window1_2<=image2[0][2]; window1_3<=image2[1][1]; window1_4<=image2[1][2];
            end
            64:begin
                window1_1<=image2[0][2]; window1_2<=image2[0][3]; window1_3<=image2[1][2]; window1_4<=image2[1][3];
            end
            65:begin
                window1_1<=image2[0][3]; window1_2<=image2[0][4]; window1_3<=image2[1][3]; window1_4<=image2[1][4];
            end
            66:begin
                window1_1<=image2[0][4]; window1_2<=image2[0][5]; window1_3<=image2[1][4]; window1_4<=image2[1][5];
            end
            67:begin
                window1_1<=image2[0][5]; window1_2<=image2[0][6]; window1_3<=image2[1][5]; window1_4<=image2[1][6];
            end
            68:begin
                window1_1<=image2[1][0]; window1_2<=image2[1][1]; window1_3<=image2[2][0]; window1_4<=image2[2][1];
            end
            69:begin
                window1_1<=image2[1][1]; window1_2<=image2[1][2]; window1_3<=image2[2][1]; window1_4<=image2[2][2];
            end
            70:begin
                window1_1<=image2[1][2]; window1_2<=image2[1][3]; window1_3<=image2[2][2]; window1_4<=image2[2][3];
            end
            71:begin
                window1_1<=image2[1][3]; window1_2<=image2[1][4]; window1_3<=image2[2][3]; window1_4<=image2[2][4];
            end
            72:begin
                window1_1<=image2[1][4]; window1_2<=image2[1][5]; window1_3<=image2[2][4]; window1_4<=image2[2][5];
            end
            73:begin
                window1_1<=image2[1][5]; window1_2<=image2[1][6]; window1_3<=image2[2][5]; window1_4<=image2[2][6];
            end
            74:begin
                window1_1<=image2[2][0]; window1_2<=image2[2][1]; window1_3<=image2[3][0]; window1_4<=image2[3][1];
            end
            75:begin
                window1_1<=image2[2][1]; window1_2<=image2[2][2]; window1_3<=image2[3][1]; window1_4<=image2[3][2];
            end
            76:begin
                window1_1<=image2[2][2]; window1_2<=image2[2][3]; window1_3<=image2[3][2]; window1_4<=image2[3][3];
            end
            77:begin
                window1_1<=image2[2][3]; window1_2<=image2[2][4]; window1_3<=image2[3][3]; window1_4<=image2[3][4];
            end
            78:begin
                window1_1<=image2[2][4]; window1_2<=image2[2][5]; window1_3<=image2[3][4]; window1_4<=image2[3][5];
            end
            79:begin
                window1_1<=image2[2][5]; window1_2<=image2[2][6]; window1_3<=image2[3][5]; window1_4<=image2[3][6];
            end
            80:begin
                window1_1<=image2[3][0]; window1_2<=image2[3][1]; window1_3<=image2[4][0]; window1_4<=image2[4][1];
            end
            81:begin
                window1_1<=image2[3][1]; window1_2<=image2[3][2]; window1_3<=image2[4][1]; window1_4<=image2[4][2];
            end
            82:begin
                window1_1<=image2[3][2]; window1_2<=image2[3][3]; window1_3<=image2[4][2]; window1_4<=image2[4][3];
            end
            83:begin
                window1_1<=image2[3][3]; window1_2<=image2[3][4]; window1_3<=image2[4][3]; window1_4<=image2[4][4];
            end
            84:begin
                window1_1<=image2[3][4]; window1_2<=image2[3][5]; window1_3<=image2[4][4]; window1_4<=image2[4][5];
            end
            85:begin
                window1_1<=image2[3][5]; window1_2<=image2[3][6]; window1_3<=image2[4][5]; window1_4<=image2[4][6];
            end
            86:begin
                window1_1<=image2[4][0]; window1_2<=image2[4][1]; window1_3<=image2[5][0]; window1_4<=image2[5][1];
            end
            87:begin
                window1_1<=image2[4][1]; window1_2<=image2[4][2]; window1_3<=image2[5][1]; window1_4<=image2[5][2];
            end
            88:begin
                window1_1<=image2[4][2]; window1_2<=image2[4][3]; window1_3<=image2[5][2]; window1_4<=image2[5][3];
            end
            89:begin
                window1_1<=image2[4][3]; window1_2<=image2[4][4]; window1_3<=image2[5][3]; window1_4<=image2[5][4];
            end
            90:begin
                window1_1<=image2[4][4]; window1_2<=image2[4][5]; window1_3<=image2[5][4]; window1_4<=image2[5][5];
            end
            91:begin
                window1_1<=image2[4][5]; window1_2<=image2[4][6]; window1_3<=image2[5][5]; window1_4<=image2[5][6];
            end
            92:begin
                window1_1<=image2[5][0]; window1_2<=image2[5][1]; window1_3<=image2[6][0]; window1_4<=image2[6][1];
            end
            93:begin
                window1_1<=image2[5][1]; window1_2<=image2[5][2]; window1_3<=image2[6][1]; window1_4<=image2[6][2];
            end
            94:begin
                window1_1<=image2[5][2]; window1_2<=image2[5][3]; window1_3<=image2[6][2]; window1_4<=image2[6][3];
            end
            95:begin
                window1_1<=image2[5][3]; window1_2<=image2[5][4]; window1_3<=image2[6][3]; window1_4<=image2[6][4];
            end
            96:begin
                window1_1<=image2[5][4]; window1_2<=image2[5][5]; window1_3<=image2[6][4]; window1_4<=image2[6][5];
            end
            97:begin
                window1_1<=image2[5][5]; window1_2<=image2[5][6]; window1_3<=image2[6][5]; window1_4<=image2[6][6];
            end
        //img3
            98:begin
                window1_1<=image3[0][0]; window1_2<=image3[0][1]; window1_3<=image3[1][0]; window1_4<=image3[1][1];
            end
            99:begin
                window1_1<=image3[0][1]; window1_2<=image3[0][2]; window1_3<=image3[1][1]; window1_4<=image3[1][2];
            end
            100:begin
                window1_1<=image3[0][2]; window1_2<=image3[0][3]; window1_3<=image3[1][2]; window1_4<=image3[1][3];
            end
            101:begin
                window1_1<=image3[0][3]; window1_2<=image3[0][4]; window1_3<=image3[1][3]; window1_4<=image3[1][4];
            end
            102:begin
                window1_1<=image3[0][4]; window1_2<=image3[0][5]; window1_3<=image3[1][4]; window1_4<=image3[1][5];
            end
            103:begin
                window1_1<=image3[0][5]; window1_2<=image3[0][6]; window1_3<=image3[1][5]; window1_4<=image3[1][6];
            end
            104:begin
                window1_1<=image3[1][0]; window1_2<=image3[1][1]; window1_3<=image3[2][0]; window1_4<=image3[2][1];
            end
            105:begin
                window1_1<=image3[1][1]; window1_2<=image3[1][2]; window1_3<=image3[2][1]; window1_4<=image3[2][2];
            end
            106:begin
                window1_1<=image3[1][2]; window1_2<=image3[1][3]; window1_3<=image3[2][2]; window1_4<=image3[2][3];
            end
            107:begin
                window1_1<=image3[1][3]; window1_2<=image3[1][4]; window1_3<=image3[2][3]; window1_4<=image3[2][4];
            end
            108:begin
                window1_1<=image3[1][4]; window1_2<=image3[1][5]; window1_3<=image3[2][4]; window1_4<=image3[2][5];
            end
            109:begin
                window1_1<=image3[1][5]; window1_2<=image3[1][6]; window1_3<=image3[2][5]; window1_4<=image3[2][6];
            end
            110:begin
                window1_1<=image3[2][0]; window1_2<=image3[2][1]; window1_3<=image3[3][0]; window1_4<=image3[3][1];
            end
            111:begin
                window1_1<=image3[2][1]; window1_2<=image3[2][2]; window1_3<=image3[3][1]; window1_4<=image3[3][2];
            end
            112:begin
                window1_1<=image3[2][2]; window1_2<=image3[2][3]; window1_3<=image3[3][2]; window1_4<=image3[3][3];
            end
            113:begin
                window1_1<=image3[2][3]; window1_2<=image3[2][4]; window1_3<=image3[3][3]; window1_4<=image3[3][4];
            end
            114:begin
                window1_1<=image3[2][4]; window1_2<=image3[2][5]; window1_3<=image3[3][4]; window1_4<=image3[3][5];
            end
            115:begin
                window1_1<=image3[2][5]; window1_2<=image3[2][6]; window1_3<=image3[3][5]; window1_4<=image3[3][6];
            end
            116:begin
                window1_1<=image3[3][0]; window1_2<=image3[3][1]; window1_3<=image3[4][0]; window1_4<=image3[4][1];
            end
            117:begin
                window1_1<=image3[3][1]; window1_2<=image3[3][2]; window1_3<=image3[4][1]; window1_4<=image3[4][2];
            end
            118:begin
                window1_1<=image3[3][2]; window1_2<=image3[3][3]; window1_3<=image3[4][2]; window1_4<=image3[4][3];
            end
            119:begin
                window1_1<=image3[3][3]; window1_2<=image3[3][4]; window1_3<=image3[4][3]; window1_4<=image3[4][4];
            end
            120:begin
                window1_1<=image3[3][4]; window1_2<=image3[3][5]; window1_3<=image3[4][4]; window1_4<=image3[4][5];
            end
            121:begin
                window1_1<=image3[3][5]; window1_2<=image3[3][6]; window1_3<=image3[4][5]; window1_4<=image3[4][6];
            end
            122:begin
                window1_1<=image3[4][0]; window1_2<=image3[4][1]; window1_3<=image3[5][0]; window1_4<=image3[5][1];
            end
            123:begin
                window1_1<=image3[4][1]; window1_2<=image3[4][2]; window1_3<=image3[5][1]; window1_4<=image3[5][2];
            end
            124:begin
                window1_1<=image3[4][2]; window1_2<=image3[4][3]; window1_3<=image3[5][2]; window1_4<=image3[5][3];
            end
            125:begin
                window1_1<=image3[4][3]; window1_2<=image3[4][4]; window1_3<=image3[5][3]; window1_4<=image3[5][4];
            end
            126:begin
                window1_1<=image3[4][4]; window1_2<=image3[4][5]; window1_3<=image3[5][4]; window1_4<=image3[5][5];
            end
            127:begin
                window1_1<=image3[4][5]; window1_2<=image3[4][6]; window1_3<=image3[5][5]; window1_4<=image3[5][6];
            end
            128:begin
                window1_1<=image3[5][0]; window1_2<=image3[5][1]; window1_3<=image3[6][0]; window1_4<=image3[6][1];
            end
            129:begin
                window1_1<=image3[5][1]; window1_2<=image3[5][2]; window1_3<=image3[6][1]; window1_4<=image3[6][2];
            end
            130:begin
                window1_1<=image3[5][2]; window1_2<=image3[5][3]; window1_3<=image3[6][2]; window1_4<=image3[6][3];
            end
            131:begin
                window1_1<=image3[5][3]; window1_2<=image3[5][4]; window1_3<=image3[6][3]; window1_4<=image3[6][4];
            end
            132:begin
                window1_1<=image3[5][4]; window1_2<=image3[5][5]; window1_3<=image3[6][4]; window1_4<=image3[6][5];
            end
            133:begin
                window1_1<=image3[5][5]; window1_2<=image3[5][6]; window1_3<=image3[6][5]; window1_4<=image3[6][6];
            end
        endcase
    //end
end


always @(posedge clk/* or negedge rst_n*/) begin//kernel_cal
    /*if(!rst_n)begin
        kernal_cal1_1 <= 0;
        kernal_cal1_2 <= 0;
        kernal_cal1_3 <= 0;
        kernal_cal1_4 <= 0;
        kernal_cal2_1 <= 0;
        kernal_cal2_2 <= 0;
        kernal_cal2_3 <= 0;
        kernal_cal2_4 <= 0;
    end
    else begin*/
        case(counter) 
        //img1     
            26:begin
                kernal_cal1_1<=kernel1_1[0][0]; kernal_cal1_2<=kernel1_1[0][1]; kernal_cal1_3<=kernel1_1[1][0]; kernal_cal1_4<=kernel1_1[1][1];
                kernal_cal2_1<=kernel2_1[0][0]; kernal_cal2_2<=kernel2_1[0][1]; kernal_cal2_3<=kernel2_1[1][0]; kernal_cal2_4<=kernel2_1[1][1];
            end
            62:begin
                kernal_cal1_1<=kernel1_2[0][0]; kernal_cal1_2<=kernel1_2[0][1]; kernal_cal1_3<=kernel1_2[1][0]; kernal_cal1_4<=kernel1_2[1][1];
                kernal_cal2_1<=kernel2_2[0][0]; kernal_cal2_2<=kernel2_2[0][1]; kernal_cal2_3<=kernel2_2[1][0]; kernal_cal2_4<=kernel2_2[1][1];
            end
            98:begin
                kernal_cal1_1<=kernel1_3[0][0]; kernal_cal1_2<=kernel1_3[0][1]; kernal_cal1_3<=kernel1_3[1][0]; kernal_cal1_4<=kernel1_3[1][1];
                kernal_cal2_1<=kernel2_3[0][0]; kernal_cal2_2<=kernel2_3[0][1]; kernal_cal2_3<=kernel2_3[1][0]; kernal_cal2_4<=kernel2_3[1][1];
            end
        endcase
    //end
end

DW_fp_mult_inst M_mul0(.inst_a(window1_1), .inst_b(kernal_cal1_1), .inst_rnd(0), .z_inst(mul1));
DW_fp_mult_inst M_mul1(.inst_a(window1_2), .inst_b(kernal_cal1_2), .inst_rnd(0), .z_inst(mul2));
DW_fp_mult_inst M_mul2(.inst_a(window1_3), .inst_b(kernal_cal1_3), .inst_rnd(0), .z_inst(mul3));
DW_fp_mult_inst M_mul3(.inst_a(window1_4), .inst_b(kernal_cal1_4), .inst_rnd(0), .z_inst(mul4));
DW_fp_add_inst  CONV01(.inst_a(mul1), .inst_b(mul2), .inst_rnd(0), .z_inst(conv_add1));
DW_fp_add_inst  CONV23(.inst_a(mul3), .inst_b(mul4), .inst_rnd(0), .z_inst(conv_add2));
DW_fp_add_inst  CONVALL1(.inst_a(conv_add1), .inst_b(conv_add2), .inst_rnd(0), .z_inst(conv_out_1));


DW_fp_mult_inst M_mul4(.inst_a(window1_1), .inst_b(kernal_cal2_1), .inst_rnd(0), .z_inst(mul5));
DW_fp_mult_inst M_mul5(.inst_a(window1_2), .inst_b(kernal_cal2_2), .inst_rnd(0), .z_inst(mul6));
DW_fp_mult_inst M_mul6(.inst_a(window1_3), .inst_b(kernal_cal2_3), .inst_rnd(0), .z_inst(mul7));
DW_fp_mult_inst M_mul7(.inst_a(window1_4), .inst_b(kernal_cal2_4), .inst_rnd(0), .z_inst(mul8));
DW_fp_add_inst  CONV45(.inst_a(mul5), .inst_b(mul6), .inst_rnd(0), .z_inst(conv_add3));
DW_fp_add_inst  CONV67(.inst_a(mul7), .inst_b(mul8), .inst_rnd(0), .z_inst(conv_add4));
DW_fp_add_inst  CONVALL2(.inst_a(conv_add3), .inst_b(conv_add4), .inst_rnd(0), .z_inst(conv_out_2));

DW_fp_add_inst  CONVALLALL1(.inst_a(conv_map_out1), .inst_b(conv_out_1), .inst_rnd(0), .z_inst(conv_out_all1));

DW_fp_add_inst  CONVALLALL2(.inst_a(conv_map_out2), .inst_b(conv_out_2), .inst_rnd(0), .z_inst(conv_out_all2));


always @(posedge clk/* or negedge rst_n*/) begin
    /*if(!rst_n) begin
        for(i = 0; i < 6; i = i + 1) begin
            for(j = 0; j < 6; j = j + 1) begin
                conv_map1[i][j] <= 0;
            end
        end
    end
    else begin*/
        case(counter) 
        //img1     
            27:conv_map1[0][0] <= conv_out_1;
            28:conv_map1[0][1] <= conv_out_1;
            29:conv_map1[0][2] <= conv_out_1;
            30:conv_map1[0][3] <= conv_out_1;
            31:conv_map1[0][4] <= conv_out_1;
            32:conv_map1[0][5] <= conv_out_1;
            33:conv_map1[1][0] <= conv_out_1;
            34:conv_map1[1][1] <= conv_out_1;
            35:conv_map1[1][2] <= conv_out_1;
            36:conv_map1[1][3] <= conv_out_1;
            37:conv_map1[1][4] <= conv_out_1;
            38:conv_map1[1][5] <= conv_out_1;
            39:conv_map1[2][0] <= conv_out_1;
            40:conv_map1[2][1] <= conv_out_1;
            41:conv_map1[2][2] <= conv_out_1;
            42:conv_map1[2][3] <= conv_out_1;
            43:conv_map1[2][4] <= conv_out_1;
            44:conv_map1[2][5] <= conv_out_1;
            45:conv_map1[3][0] <= conv_out_1;
            46:conv_map1[3][1] <= conv_out_1;
            47:conv_map1[3][2] <= conv_out_1;
            48:conv_map1[3][3] <= conv_out_1;
            49:conv_map1[3][4] <= conv_out_1;
            50:conv_map1[3][5] <= conv_out_1;
            51:conv_map1[4][0] <= conv_out_1;
            52:conv_map1[4][1] <= conv_out_1;
            53:conv_map1[4][2] <= conv_out_1;
            54:conv_map1[4][3] <= conv_out_1;
            55:conv_map1[4][4] <= conv_out_1;
            56:conv_map1[4][5] <= conv_out_1;
            57:conv_map1[5][0] <= conv_out_1;
            58:conv_map1[5][1] <= conv_out_1;
            59:conv_map1[5][2] <= conv_out_1;
            60:conv_map1[5][3] <= conv_out_1;
            61:conv_map1[5][4] <= conv_out_1;
            62:conv_map1[5][5] <= conv_out_1;

            63:conv_map1[0][0] <= conv_out_all1;
            64:conv_map1[0][1] <= conv_out_all1;
            65:conv_map1[0][2] <= conv_out_all1;
            66:conv_map1[0][3] <= conv_out_all1;
            67:conv_map1[0][4] <= conv_out_all1;
            68:conv_map1[0][5] <= conv_out_all1;
            69:conv_map1[1][0] <= conv_out_all1;
            70:conv_map1[1][1] <= conv_out_all1;
            71:conv_map1[1][2] <= conv_out_all1;
            72:conv_map1[1][3] <= conv_out_all1;
            73:conv_map1[1][4] <= conv_out_all1;
            74:conv_map1[1][5] <= conv_out_all1;
            75:conv_map1[2][0] <= conv_out_all1;
            76:conv_map1[2][1] <= conv_out_all1;
            77:conv_map1[2][2] <= conv_out_all1;
            78:conv_map1[2][3] <= conv_out_all1;
            79:conv_map1[2][4] <= conv_out_all1;
            80:conv_map1[2][5] <= conv_out_all1;
            81:conv_map1[3][0] <= conv_out_all1;
            82:conv_map1[3][1] <= conv_out_all1;
            83:conv_map1[3][2] <= conv_out_all1;
            84:conv_map1[3][3] <= conv_out_all1;
            85:conv_map1[3][4] <= conv_out_all1;
            86:conv_map1[3][5] <= conv_out_all1;
            87:conv_map1[4][0] <= conv_out_all1;
            88:conv_map1[4][1] <= conv_out_all1;
            89:conv_map1[4][2] <= conv_out_all1;
            90:conv_map1[4][3] <= conv_out_all1;
            91:conv_map1[4][4] <= conv_out_all1;
            92:conv_map1[4][5] <= conv_out_all1;
            93:conv_map1[5][0] <= conv_out_all1;
            94:conv_map1[5][1] <= conv_out_all1;
            95:conv_map1[5][2] <= conv_out_all1;
            96:conv_map1[5][3] <= conv_out_all1;
            97:conv_map1[5][4] <= conv_out_all1;
            98:conv_map1[5][5] <= conv_out_all1;

            99:conv_map1[0][0] <= conv_out_all1;
            100:conv_map1[0][1] <= conv_out_all1;
            101:conv_map1[0][2] <= conv_out_all1;
            102:conv_map1[0][3] <= conv_out_all1;
            103:conv_map1[0][4] <= conv_out_all1;
            104:conv_map1[0][5] <= conv_out_all1;
            105:conv_map1[1][0] <= conv_out_all1;
            106:conv_map1[1][1] <= conv_out_all1;
            107:conv_map1[1][2] <= conv_out_all1;
            108:conv_map1[1][3] <= conv_out_all1;
            109:conv_map1[1][4] <= conv_out_all1;
            110:conv_map1[1][5] <= conv_out_all1;
            111:conv_map1[2][0] <= conv_out_all1;
            112:conv_map1[2][1] <= conv_out_all1;
            113:conv_map1[2][2] <= conv_out_all1;
            114:conv_map1[2][3] <= conv_out_all1;
            115:conv_map1[2][4] <= conv_out_all1;
            116:conv_map1[2][5] <= conv_out_all1;
            117:conv_map1[3][0] <= conv_out_all1;
            118:conv_map1[3][1] <= conv_out_all1;
            119:conv_map1[3][2] <= conv_out_all1;
            120:conv_map1[3][3] <= conv_out_all1;
            121:conv_map1[3][4] <= conv_out_all1;
            122:conv_map1[3][5] <= conv_out_all1;
            123:conv_map1[4][0] <= conv_out_all1;
            124:conv_map1[4][1] <= conv_out_all1;
            125:conv_map1[4][2] <= conv_out_all1;
            126:conv_map1[4][3] <= conv_out_all1;
            127:conv_map1[4][4] <= conv_out_all1;
            128:conv_map1[4][5] <= conv_out_all1;
            129:conv_map1[5][0] <= conv_out_all1;
            130:conv_map1[5][1] <= conv_out_all1;
            131:conv_map1[5][2] <= conv_out_all1;
            132:conv_map1[5][3] <= conv_out_all1;
            133:conv_map1[5][4] <= conv_out_all1;
            134:conv_map1[5][5] <= conv_out_all1;
        endcase
    //end
end

always @(posedge clk/* or negedge rst_n*/) begin
    /*if(!rst_n) begin
        for(i = 0; i < 6; i = i + 1) begin
            for(j = 0; j < 6; j = j + 1) begin
                conv_map2[i][j] <= 0;
            end
        end
    end
    else begin*/
        case(counter) 
        //img1     
            27:conv_map2[0][0] <= conv_out_2;
            28:conv_map2[0][1] <= conv_out_2;
            29:conv_map2[0][2] <= conv_out_2;
            30:conv_map2[0][3] <= conv_out_2;
            31:conv_map2[0][4] <= conv_out_2;
            32:conv_map2[0][5] <= conv_out_2;
            33:conv_map2[1][0] <= conv_out_2;
            34:conv_map2[1][1] <= conv_out_2;
            35:conv_map2[1][2] <= conv_out_2;
            36:conv_map2[1][3] <= conv_out_2;
            37:conv_map2[1][4] <= conv_out_2;
            38:conv_map2[1][5] <= conv_out_2;
            39:conv_map2[2][0] <= conv_out_2;
            40:conv_map2[2][1] <= conv_out_2;
            41:conv_map2[2][2] <= conv_out_2;
            42:conv_map2[2][3] <= conv_out_2;
            43:conv_map2[2][4] <= conv_out_2;
            44:conv_map2[2][5] <= conv_out_2;
            45:conv_map2[3][0] <= conv_out_2;
            46:conv_map2[3][1] <= conv_out_2;
            47:conv_map2[3][2] <= conv_out_2;
            48:conv_map2[3][3] <= conv_out_2;
            49:conv_map2[3][4] <= conv_out_2;
            50:conv_map2[3][5] <= conv_out_2;
            51:conv_map2[4][0] <= conv_out_2;
            52:conv_map2[4][1] <= conv_out_2;
            53:conv_map2[4][2] <= conv_out_2;
            54:conv_map2[4][3] <= conv_out_2;
            55:conv_map2[4][4] <= conv_out_2;
            56:conv_map2[4][5] <= conv_out_2;
            57:conv_map2[5][0] <= conv_out_2;
            58:conv_map2[5][1] <= conv_out_2;
            59:conv_map2[5][2] <= conv_out_2;
            60:conv_map2[5][3] <= conv_out_2;
            61:conv_map2[5][4] <= conv_out_2;
            62:conv_map2[5][5] <= conv_out_2;

            63:conv_map2[0][0] <= conv_out_all2;
            64:conv_map2[0][1] <= conv_out_all2;
            65:conv_map2[0][2] <= conv_out_all2;
            66:conv_map2[0][3] <= conv_out_all2;
            67:conv_map2[0][4] <= conv_out_all2;
            68:conv_map2[0][5] <= conv_out_all2;
            69:conv_map2[1][0] <= conv_out_all2;
            70:conv_map2[1][1] <= conv_out_all2;
            71:conv_map2[1][2] <= conv_out_all2;
            72:conv_map2[1][3] <= conv_out_all2;
            73:conv_map2[1][4] <= conv_out_all2;
            74:conv_map2[1][5] <= conv_out_all2;
            75:conv_map2[2][0] <= conv_out_all2;
            76:conv_map2[2][1] <= conv_out_all2;
            77:conv_map2[2][2] <= conv_out_all2;
            78:conv_map2[2][3] <= conv_out_all2;
            79:conv_map2[2][4] <= conv_out_all2;
            80:conv_map2[2][5] <= conv_out_all2;
            81:conv_map2[3][0] <= conv_out_all2;
            82:conv_map2[3][1] <= conv_out_all2;
            83:conv_map2[3][2] <= conv_out_all2;
            84:conv_map2[3][3] <= conv_out_all2;
            85:conv_map2[3][4] <= conv_out_all2;
            86:conv_map2[3][5] <= conv_out_all2;
            87:conv_map2[4][0] <= conv_out_all2;
            88:conv_map2[4][1] <= conv_out_all2;
            89:conv_map2[4][2] <= conv_out_all2;
            90:conv_map2[4][3] <= conv_out_all2;
            91:conv_map2[4][4] <= conv_out_all2;
            92:conv_map2[4][5] <= conv_out_all2;
            93:conv_map2[5][0] <= conv_out_all2;
            94:conv_map2[5][1] <= conv_out_all2;
            95:conv_map2[5][2] <= conv_out_all2;
            96:conv_map2[5][3] <= conv_out_all2;
            97:conv_map2[5][4] <= conv_out_all2;
            98:conv_map2[5][5] <= conv_out_all2;

            99:conv_map2[0][0] <= conv_out_all2;
            100:conv_map2[0][1] <= conv_out_all2;
            101:conv_map2[0][2] <= conv_out_all2;
            102:conv_map2[0][3] <= conv_out_all2;
            103:conv_map2[0][4] <= conv_out_all2;
            104:conv_map2[0][5] <= conv_out_all2;
            105:conv_map2[1][0] <= conv_out_all2;
            106:conv_map2[1][1] <= conv_out_all2;
            107:conv_map2[1][2] <= conv_out_all2;
            108:conv_map2[1][3] <= conv_out_all2;
            109:conv_map2[1][4] <= conv_out_all2;
            110:conv_map2[1][5] <= conv_out_all2;
            111:conv_map2[2][0] <= conv_out_all2;
            112:conv_map2[2][1] <= conv_out_all2;
            113:conv_map2[2][2] <= conv_out_all2;
            114:conv_map2[2][3] <= conv_out_all2;
            115:conv_map2[2][4] <= conv_out_all2;
            116:conv_map2[2][5] <= conv_out_all2;
            117:conv_map2[3][0] <= conv_out_all2;
            118:conv_map2[3][1] <= conv_out_all2;
            119:conv_map2[3][2] <= conv_out_all2;
            120:conv_map2[3][3] <= conv_out_all2;
            121:conv_map2[3][4] <= conv_out_all2;
            122:conv_map2[3][5] <= conv_out_all2;
            123:conv_map2[4][0] <= conv_out_all2;
            124:conv_map2[4][1] <= conv_out_all2;
            125:conv_map2[4][2] <= conv_out_all2;
            126:conv_map2[4][3] <= conv_out_all2;
            127:conv_map2[4][4] <= conv_out_all2;
            128:conv_map2[4][5] <= conv_out_all2;
            129:conv_map2[5][0] <= conv_out_all2;
            130:conv_map2[5][1] <= conv_out_all2;
            131:conv_map2[5][2] <= conv_out_all2;
            132:conv_map2[5][3] <= conv_out_all2;
            133:conv_map2[5][4] <= conv_out_all2;
            134:conv_map2[5][5] <= conv_out_all2;
        endcase
    //end
end

always @(posedge clk/* or negedge rst_n*/) begin
    /*if(!rst_n) begin
        conv_map_out1 <= 0;
    end
    else begin*/
        case(counter) 
        //img1     
            62,98:conv_map_out1 <= conv_map1[0][0];
            63,99:conv_map_out1 <= conv_map1[0][1];
            64,100:conv_map_out1 <= conv_map1[0][2];
            65,101:conv_map_out1 <= conv_map1[0][3];
            66,102:conv_map_out1 <= conv_map1[0][4];
            67,103:conv_map_out1 <= conv_map1[0][5];
            68,104:conv_map_out1 <= conv_map1[1][0];
            69,105:conv_map_out1 <= conv_map1[1][1];
            70,106:conv_map_out1 <= conv_map1[1][2];
            71,107:conv_map_out1 <= conv_map1[1][3];
            72,108:conv_map_out1 <= conv_map1[1][4];
            73,109:conv_map_out1 <= conv_map1[1][5];
            74,110:conv_map_out1 <= conv_map1[2][0];
            75,111:conv_map_out1 <= conv_map1[2][1];
            76,112:conv_map_out1 <= conv_map1[2][2];
            77,113:conv_map_out1 <= conv_map1[2][3];
            78,114:conv_map_out1 <= conv_map1[2][4];
            79,115:conv_map_out1 <= conv_map1[2][5];
            80,116:conv_map_out1 <= conv_map1[3][0];
            81,117:conv_map_out1 <= conv_map1[3][1];
            82,118:conv_map_out1 <= conv_map1[3][2];
            83,119:conv_map_out1 <= conv_map1[3][3];
            84,120:conv_map_out1 <= conv_map1[3][4];
            85,121:conv_map_out1 <= conv_map1[3][5];
            86,122:conv_map_out1 <= conv_map1[4][0];
            87,123:conv_map_out1 <= conv_map1[4][1];
            88,124:conv_map_out1 <= conv_map1[4][2];
            89,125:conv_map_out1 <= conv_map1[4][3];
            90,126:conv_map_out1 <= conv_map1[4][4];
            91,127:conv_map_out1 <= conv_map1[4][5];
            92,128:conv_map_out1 <= conv_map1[5][0];
            93,129:conv_map_out1 <= conv_map1[5][1];
            94,130:conv_map_out1 <= conv_map1[5][2];
            95,131:conv_map_out1 <= conv_map1[5][3];
            96,132:conv_map_out1 <= conv_map1[5][4];
            97,133:conv_map_out1 <= conv_map1[5][5];
        endcase
    //end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        conv_map_out2 <= 0;
    end
    else begin
        case(counter) 
            62,98:conv_map_out2 <= conv_map2[0][0];
            63,99:conv_map_out2 <= conv_map2[0][1];
            64,100:conv_map_out2 <= conv_map2[0][2];
            65,101:conv_map_out2 <= conv_map2[0][3];
            66,102:conv_map_out2 <= conv_map2[0][4];
            67,103:conv_map_out2 <= conv_map2[0][5];
            68,104:conv_map_out2 <= conv_map2[1][0];
            69,105:conv_map_out2 <= conv_map2[1][1];
            70,106:conv_map_out2 <= conv_map2[1][2];
            71,107:conv_map_out2 <= conv_map2[1][3];
            72,108:conv_map_out2 <= conv_map2[1][4];
            73,109:conv_map_out2 <= conv_map2[1][5];
            74,110:conv_map_out2 <= conv_map2[2][0];
            75,111:conv_map_out2 <= conv_map2[2][1];
            76,112:conv_map_out2 <= conv_map2[2][2];
            77,113:conv_map_out2 <= conv_map2[2][3];
            78,114:conv_map_out2 <= conv_map2[2][4];
            79,115:conv_map_out2 <= conv_map2[2][5];
            80,116:conv_map_out2 <= conv_map2[3][0];
            81,117:conv_map_out2 <= conv_map2[3][1];
            82,118:conv_map_out2 <= conv_map2[3][2];
            83,119:conv_map_out2 <= conv_map2[3][3];
            84,120:conv_map_out2 <= conv_map2[3][4];
            85,121:conv_map_out2 <= conv_map2[3][5];
            86,122:conv_map_out2 <= conv_map2[4][0];
            87,123:conv_map_out2 <= conv_map2[4][1];
            88,124:conv_map_out2 <= conv_map2[4][2];
            89,125:conv_map_out2 <= conv_map2[4][3];
            90,126:conv_map_out2 <= conv_map2[4][4];
            91,127:conv_map_out2 <= conv_map2[4][5];
            92,128:conv_map_out2 <= conv_map2[5][0];
            93,129:conv_map_out2 <= conv_map2[5][1];
            94,130:conv_map_out2 <= conv_map2[5][2];
            95,131:conv_map_out2 <= conv_map2[5][3];
            96,132:conv_map_out2 <= conv_map2[5][4];
            97,133:conv_map_out2 <= conv_map2[5][5];
        endcase
    end
end

always @(posedge clk/* or negedge rst_n*/) begin
    /*if(!rst_n) begin
        cmp1 <= 0; cmp2 <= 0; cmp3 <= 0; cmp4 <= 0; cmp5 <= 0; cmp6 <= 0; cmp7 <= 0; cmp8 <= 0;  cmp9 <= 0;
        cmp1_2 <= 0; cmp2_2 <= 0; cmp3_2 <= 0; cmp4_2 <= 0; cmp5_2 <= 0; cmp6_2 <= 0; cmp7_2 <= 0; cmp8_2 <= 0;  cmp9_2 <= 0;
    end
    else begin*/
        case(counter_max)    
            1:begin
                cmp1 <= conv_map1[0][0];
                cmp2 <= conv_map1[0][1];
                cmp3 <= conv_map1[0][2];
                cmp4 <= conv_map1[1][0];
                cmp5 <= conv_map1[1][1];
                cmp6 <= conv_map1[1][2];
                cmp7 <= conv_map1[2][0];
                cmp8 <= conv_map1[2][1];
                cmp9 <= conv_map1[2][2];
                cmp1_2 <= conv_map2[0][0];
                cmp2_2 <= conv_map2[0][1];
                cmp3_2 <= conv_map2[0][2];
                cmp4_2 <= conv_map2[1][0];
                cmp5_2 <= conv_map2[1][1];
                cmp6_2 <= conv_map2[1][2];
                cmp7_2 <= conv_map2[2][0];
                cmp8_2 <= conv_map2[2][1];
                cmp9_2 <= conv_map2[2][2];
            end
            2:begin
                cmp1 <= conv_map1[0][3];
                cmp2 <= conv_map1[0][4];
                cmp3 <= conv_map1[0][5];
                cmp4 <= conv_map1[1][3];
                cmp5 <= conv_map1[1][4];
                cmp6 <= conv_map1[1][5];
                cmp7 <= conv_map1[2][3];
                cmp8 <= conv_map1[2][4];
                cmp9 <= conv_map1[2][5];
                cmp1_2 <= conv_map2[0][3];
                cmp2_2 <= conv_map2[0][4];
                cmp3_2 <= conv_map2[0][5];
                cmp4_2 <= conv_map2[1][3];
                cmp5_2 <= conv_map2[1][4];
                cmp6_2 <= conv_map2[1][5];
                cmp7_2 <= conv_map2[2][3];
                cmp8_2 <= conv_map2[2][4];
                cmp9_2 <= conv_map2[2][5];
            end
            3:begin
                cmp1 <= conv_map1[3][0];
                cmp2 <= conv_map1[3][1];
                cmp3 <= conv_map1[3][2];
                cmp4 <= conv_map1[4][0];
                cmp5 <= conv_map1[4][1];
                cmp6 <= conv_map1[4][2];
                cmp7 <= conv_map1[5][0];
                cmp8 <= conv_map1[5][1];
                cmp9 <= conv_map1[5][2];
                cmp1_2 <= conv_map2[3][0];
                cmp2_2 <= conv_map2[3][1];
                cmp3_2 <= conv_map2[3][2];
                cmp4_2 <= conv_map2[4][0];
                cmp5_2 <= conv_map2[4][1];
                cmp6_2 <= conv_map2[4][2];
                cmp7_2 <= conv_map2[5][0];
                cmp8_2 <= conv_map2[5][1];
                cmp9_2 <= conv_map2[5][2];
            end
            4:begin
                cmp1 <= conv_map1[3][3];
                cmp2 <= conv_map1[3][4];
                cmp3 <= conv_map1[3][5];
                cmp4 <= conv_map1[4][3];
                cmp5 <= conv_map1[4][4];
                cmp6 <= conv_map1[4][5];
                cmp7 <= conv_map1[5][3];
                cmp8 <= conv_map1[5][4];
                cmp9 <= conv_map1[5][5];
                cmp1_2 <= conv_map2[3][3];
                cmp2_2 <= conv_map2[3][4];
                cmp3_2 <= conv_map2[3][5];
                cmp4_2 <= conv_map2[4][3];
                cmp5_2 <= conv_map2[4][4];
                cmp6_2 <= conv_map2[4][5];
                cmp7_2 <= conv_map2[5][3];
                cmp8_2 <= conv_map2[5][4];
                cmp9_2 <= conv_map2[5][5];
            end

        endcase
    //end
end



DW_fp_cmp_inst COM_1(.inst_a(cmp1), .inst_b(cmp2), .z1_inst(cmp12), .inst_zctr(0));
DW_fp_cmp_inst COM_2(.inst_a(cmp3), .inst_b(cmp4), .z1_inst(cmp34), .inst_zctr(0));
DW_fp_cmp_inst COM_3(.inst_a(cmp5), .inst_b(cmp6), .z1_inst(cmp56), .inst_zctr(0));
DW_fp_cmp_inst COM_4(.inst_a(cmp7), .inst_b(cmp8), .z1_inst(cmp78), .inst_zctr(0));
DW_fp_cmp_inst COM_5(.inst_a(cmp12), .inst_b(cmp34), .z1_inst(cmp1234), .inst_zctr(0));
DW_fp_cmp_inst COM_6(.inst_a(cmp56), .inst_b(cmp78), .z1_inst(cmp5678), .inst_zctr(0));
DW_fp_cmp_inst COM_7(.inst_a(cmp1234), .inst_b(cmp5678), .z1_inst(cmp1_8), .inst_zctr(0));
DW_fp_cmp_inst COM_8(.inst_a(cmp1_8), .inst_b(cmp9), .z1_inst(cmpall), .inst_zctr(0));

DW_fp_cmp_inst COM_9(.inst_a(cmp1_2), .inst_b(cmp2_2), .z1_inst(cmp12_2), .inst_zctr(0));
DW_fp_cmp_inst COM_10(.inst_a(cmp3_2), .inst_b(cmp4_2), .z1_inst(cmp34_2), .inst_zctr(0));
DW_fp_cmp_inst COM_11(.inst_a(cmp5_2), .inst_b(cmp6_2), .z1_inst(cmp56_2), .inst_zctr(0));
DW_fp_cmp_inst COM_12(.inst_a(cmp7_2), .inst_b(cmp8_2), .z1_inst(cmp78_2), .inst_zctr(0));
DW_fp_cmp_inst COM_13(.inst_a(cmp12_2), .inst_b(cmp34_2), .z1_inst(cmp1234_2), .inst_zctr(0));
DW_fp_cmp_inst COM_14(.inst_a(cmp56_2), .inst_b(cmp78_2), .z1_inst(cmp5678_2), .inst_zctr(0));
DW_fp_cmp_inst COM_15(.inst_a(cmp1234_2), .inst_b(cmp5678_2), .z1_inst(cmp1_8_2), .inst_zctr(0));
DW_fp_cmp_inst COM_16(.inst_a(cmp1_8_2), .inst_b(cmp9_2), .z1_inst(cmpall_2), .inst_zctr(0));

always @(posedge clk/* or negedge rst_n*/)begin
    /*if(!rst_n) begin
        act1 <= 0; act2 <= 0; act3 <= 0; act4 <= 0; act5 <= 0; act6 <= 0; act7 <= 0; act8 <= 0;;
    end
    else begin*/
        case(counter_max)    
            2:begin
                act1 <= cmpall;
                act5 <= cmpall_2;
            end
            3:begin
                act2 <= cmpall;
                act6 <= cmpall_2;
                act1 <= sig_out;
            end
            4:begin
                act3 <= cmpall;
                act7 <= cmpall_2;
                act2 <= sig_out;
            end
            5:begin
                act4 <= cmpall;
                act8 <= cmpall_2;
                act3 <= sig_out;
            end
            6:begin
                act4 <= sig_out;
            end
            7:begin
                act5 <= sig_out;
            end
            8:begin
                act6 <= sig_out;
            end
            9:begin
                act7 <= sig_out;
            end
            10:begin
                act8 <= sig_out;
            end
        endcase
    //end
end

always @(*)begin
    case(counter_max)
            3 : act_in = act1;
            4 : act_in = act2;
            5 : act_in = act3;
            6 : act_in = act4;
            7 : act_in = act5;
            8 : act_in = act6;
            9 : act_in = act7;
            10 : act_in = act8;
        default: act_in = 0;
    endcase
end

always @(*) begin
    if(Opt_in == 0) begin
        div_in_1 = 32'b00111111100000000000000000000000;
        div_in_2 = sigmoid;
    end
    else begin
        div_in_1 = tanh_nume;
        div_in_2 = tanh_deno;
    end
end

DW_fp_exp_inst E_POS(.inst_a(act_in), .z_inst(e_pos));
DW_fp_exp_inst E_NEG(.inst_a({~act_in[31] , act_in[30:0]}), .z_inst(e_neg));
DW_fp_add_inst SIG(.inst_a(32'b00111111100000000000000000000000), .inst_b(e_neg), .z_inst(sigmoid), .inst_rnd(3'b000));
DW_fp_sub_inst TANH_SUB(.inst_a(e_pos), .inst_b(e_neg), .z_inst(tanh_nume), .inst_rnd(3'b000));
DW_fp_add_inst TANH_ADD(.inst_a(e_pos), .inst_b(e_neg), .z_inst(tanh_deno), .inst_rnd(3'b000));
DW_fp_div_inst div(.inst_a(div_in_1), .inst_b(div_in_2), .z_inst(sig_out), .inst_rnd(3'b000));



DW_fp_mult_inst fc0(.inst_a(act1), .inst_b(wei1), .inst_rnd(0), .z_inst(actmul1));
DW_fp_mult_inst fc1(.inst_a(act2), .inst_b(wei2), .inst_rnd(0), .z_inst(actmul2));
DW_fp_mult_inst fc2(.inst_a(act3), .inst_b(wei3), .inst_rnd(0), .z_inst(actmul3));
DW_fp_mult_inst fc3(.inst_a(act4), .inst_b(wei4), .inst_rnd(0), .z_inst(actmul4));
DW_fp_mult_inst fc4(.inst_a(act5), .inst_b(wei5), .inst_rnd(0), .z_inst(actmul5));
DW_fp_mult_inst fc5(.inst_a(act6), .inst_b(wei6), .inst_rnd(0), .z_inst(actmul6));
DW_fp_mult_inst fc6(.inst_a(act7), .inst_b(wei7), .inst_rnd(0), .z_inst(actmul7));
DW_fp_mult_inst fc7(.inst_a(act8), .inst_b(wei8), .inst_rnd(0), .z_inst(actmul8));

DW_fp_add_inst  fcadd1(.inst_a(actmul1), .inst_b(actmul2), .inst_rnd(0), .z_inst(actmul12));
DW_fp_add_inst  fcadd2(.inst_a(actmul3), .inst_b(actmul4), .inst_rnd(0), .z_inst(actmul34));
DW_fp_add_inst  fcadd3(.inst_a(actmul5), .inst_b(actmul6), .inst_rnd(0), .z_inst(actmul56));
DW_fp_add_inst  fcadd4(.inst_a(actmul7), .inst_b(actmul8), .inst_rnd(0), .z_inst(actmul78));
DW_fp_add_inst  fcadd5(.inst_a(actmul12), .inst_b(actmul34), .inst_rnd(0), .z_inst(actmul1234));
DW_fp_add_inst  fcadd6(.inst_a(actmul56), .inst_b(actmul78), .inst_rnd(0), .z_inst(actmul5678));
DW_fp_add_inst  fcadd7(.inst_a(actmul1234), .inst_b(actmul5678), .inst_rnd(0), .z_inst(fcall));

always @(*)begin
    case(counter_max)
            11 : begin
                wei1 = weight1[0];
                wei2 = weight1[1];
                wei3 = weight1[2];
                wei4 = weight1[3];
                wei5 = weight1[4];
                wei6 = weight1[5];
                wei7 = weight1[6];
                wei8 = weight1[7];
            end
            12 : begin
                wei1 = weight2[0];
                wei2 = weight2[1];
                wei3 = weight2[2];
                wei4 = weight2[3];
                wei5 = weight2[4];
                wei6 = weight2[5];
                wei7 = weight2[6];
                wei8 = weight2[7];
            end
            13 : begin
                wei1 = weight3[0];
                wei2 = weight3[1];
                wei3 = weight3[2];
                wei4 = weight3[3];
                wei5 = weight3[4];
                wei6 = weight3[5];
                wei7 = weight3[6];
                wei8 = weight3[7];
            end

        default: begin
                wei1 = 0;
                wei2 = 0;
                wei3 = 0;
                wei4 = 0;
                wei5 = 0;
                wei6 = 0;
                wei7 = 0;
                wei8 = 0;
            end

    endcase
end

always @(posedge clk or negedge rst_n)begin
    if(!rst_n) begin
        fcout1 <= 0; fcout2 <= 0; fcout3 <= 0;
    end
    else begin
        case(counter_max)    
            11:fcout1 <= fcall_exp;
            12:fcout2 <= fcall_exp;
            13:fcout3 <= fcall_exp;
        endcase
    end
end

DW_fp_exp_inst E_POS2(.inst_a(fcall), .z_inst(fcall_exp));

DW_fp_sum3_inst sum3_2(.inst_a(fcout1), .inst_b(fcout2), .inst_c(fcout3), .inst_rnd(0), .z_inst(softadd));

DW_fp_div_inst div2(.inst_a(div_fc), .inst_b(softadd), .z_inst(soft_out), .inst_rnd(3'b000));

always @(*)begin
    case(counter_max)
            14 : div_fc = fcout1;
            15 : div_fc = fcout2;
            16 : div_fc = fcout3;
        default: div_fc = 0;
    endcase
end

/*always @(posedge clk or negedge rst_n)begin
    if(!rst_n) begin
        softall1 <= 0; softall2 <= 0; softall3 <= 0;
    end
    else begin
        case(counter_max)    
            14:softall1 <= soft_out;
            15:softall2 <= soft_out;
            16:softall3 <= soft_out;
        endcase
    end
end*/
//---------------------------------------------------------------------
// Design
//---------------------------------------------------------------------

always @(*) begin
    if (counter_max==14 || counter_max==15 || counter_max==16)begin
       out = soft_out;
    end
    else out = 0;
end


always @(*) begin
    if(counter_max==14 || counter_max==15 || counter_max==16)begin
        out_valid = 1;
    end
    else out_valid = 0;
end



endmodule



module DW_fp_exp_inst( inst_a, z_inst, status_inst );
    parameter inst_sig_width = 23;
    parameter inst_exp_width = 8;
    parameter inst_ieee_compliance = 0;
    parameter inst_arch = 0;

    input [inst_sig_width+inst_exp_width : 0] inst_a;
    output [inst_sig_width+inst_exp_width : 0] z_inst;
    output [7 : 0] status_inst;
    // Instance of DW_fp_exp
    DW_fp_exp #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch) U1 (
    .a(inst_a),
    .z(z_inst),
    .status(status_inst) );
endmodule

module DW_fp_sub_inst( inst_a, inst_b, inst_rnd, z_inst, status_inst );
    parameter inst_sig_width = 23;
    parameter inst_exp_width = 8;
    parameter inst_ieee_compliance = 0;

    input [inst_sig_width+inst_exp_width : 0] inst_a;
    input [inst_sig_width+inst_exp_width : 0] inst_b;
    input [2 : 0] inst_rnd;
    output [inst_sig_width+inst_exp_width : 0] z_inst;
    output [7 : 0] status_inst;
    // Instance of DW_fp_sub
    DW_fp_sub #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
    U1 ( .a(inst_a), .b(inst_b), .rnd(inst_rnd), .z(z_inst), .status(status_inst) );
endmodule

module DW_fp_mult_inst( inst_a, inst_b, inst_rnd, z_inst, status_inst );
    parameter inst_sig_width = 23;
    parameter inst_exp_width = 8;
    //parameter ieee_compliance = 1;
    parameter inst_ieee_compliance = 0;
    input [inst_sig_width+inst_exp_width : 0] inst_a;
    input [inst_sig_width+inst_exp_width : 0] inst_b;
    input [2 : 0] inst_rnd;
    output [inst_sig_width+inst_exp_width : 0] z_inst;
    output [7 : 0] status_inst;
    // Instance of DW_fp_mult
    DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
    U1 ( .a(inst_a), .b(inst_b), .rnd(inst_rnd), .z(z_inst), .status(status_inst) );
endmodule

module DW_fp_sum3_inst( inst_a, inst_b, inst_c, inst_rnd, z_inst,
status_inst );
    parameter inst_sig_width = 23;
    parameter inst_exp_width = 8;
    parameter inst_ieee_compliance = 0;
    parameter inst_arch_type = 0;
    input [inst_sig_width+inst_exp_width : 0] inst_a;
    input [inst_sig_width+inst_exp_width : 0] inst_b;
    input [inst_sig_width+inst_exp_width : 0] inst_c;
    input [2 : 0] inst_rnd;
    output [inst_sig_width+inst_exp_width : 0] z_inst;
    output [7 : 0] status_inst;
    // Instance of DW_fp_sum3
    DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch_type)
    U1 (
    .a(inst_a),
    .b(inst_b),
    .c(inst_c),
    .rnd(inst_rnd),
    .z(z_inst),
    .status(status_inst) );
endmodule

module DW_fp_div_inst( inst_a, inst_b, inst_rnd, z_inst, status_inst );
    parameter inst_sig_width = 23;
    parameter inst_exp_width = 8;
    parameter inst_ieee_compliance = 0;
    parameter inst_faithful_round = 0;
    
    input [inst_sig_width+inst_exp_width : 0] inst_a;
    input [inst_sig_width+inst_exp_width : 0] inst_b;
    input [2 : 0] inst_rnd;
    output [inst_sig_width+inst_exp_width : 0] z_inst;
    output [7 : 0] status_inst;
    // Instance of DW_fp_div
    DW_fp_div #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_faithful_round) U1
    ( .a(inst_a), .b(inst_b), .rnd(inst_rnd), .z(z_inst), .status(status_inst)
    );
endmodule

module DW_fp_cmp_inst( inst_a, inst_b, inst_zctr, aeqb_inst, altb_inst,
    agtb_inst, unordered_inst, z0_inst, z1_inst, status0_inst,
    status1_inst );
    parameter inst_sig_width = 23;
    parameter inst_exp_width = 8;
    parameter inst_ieee_compliance = 0;
    input [inst_sig_width+inst_exp_width : 0] inst_a;
    input [inst_sig_width+inst_exp_width : 0] inst_b;
    input inst_zctr;
    output aeqb_inst;
    output altb_inst;
    output agtb_inst;
    output unordered_inst;
    output [inst_sig_width+inst_exp_width : 0] z0_inst;
    output [inst_sig_width+inst_exp_width : 0] z1_inst;
    output [7 : 0] status0_inst;
    output [7 : 0] status1_inst;
    // Instance of DW_fp_cmp
    DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
    U1 ( .a(inst_a), .b(inst_b), .zctr(inst_zctr), .aeqb(aeqb_inst),
    .altb(altb_inst), .agtb(agtb_inst), .unordered(unordered_inst),
    .z0(z0_inst), .z1(z1_inst), .status0(status0_inst),
    .status1(status1_inst) );
endmodule

module DW_fp_add_inst( inst_a, inst_b, inst_rnd, z_inst, status_inst );
    parameter inst_sig_width = 23;
    parameter inst_exp_width = 8;
    parameter inst_ieee_compliance = 0;
    input [inst_sig_width+inst_exp_width : 0] inst_a;
    input [inst_sig_width+inst_exp_width : 0] inst_b;
    input [2 : 0] inst_rnd;
    output [inst_sig_width+inst_exp_width : 0] z_inst;
    output [7 : 0] status_inst;
    // Instance of DW_fp_add
    DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
    U1 ( .a(inst_a), .b(inst_b), .rnd(inst_rnd), .z(z_inst), .status(status_inst) );
endmodule