/**************************************************************************/
// Copyright (c) 2024, OASIS Lab
// MODULE: SA
// FILE NAME: SA_wocg.v
// VERSRION: 1.0
// DATE: Nov 06, 2024
// AUTHOR: Yen-Ning Tung, NYCU AIG
// CODE TYPE: RTL or Behavioral Level (Verilog)
// DESCRIPTION: 2024 Spring IC Lab / Exersise Lab08 / SA_wocg
// MODIFICATION HISTORY:
// Date                 Description
// 
/**************************************************************************/

module SA(
	// Input signals
	clk,
	rst_n,
	in_valid,
	T,
	in_data,
	w_Q,
	w_K,
	w_V,
	// Output signals
	out_valid,
	out_data
);

input clk;
input rst_n;
input in_valid;
input [3:0] T;
input signed [7:0] in_data;
input signed [7:0] w_Q;
input signed [7:0] w_K;
input signed [7:0] w_V;

output reg out_valid;
output reg signed [63:0] out_data;
//==============================================
//       parameter & integer declaration        
//==============================================
integer i,j;
parameter IDLE = 0;
parameter IN_DATA_Q = 1;
parameter IN_DATA_K = 2;
parameter IN_DATA_V = 3;
parameter GEN = 4;
parameter MATMUL = 5;
parameter SCALE = 6;
parameter RELU = 7;
parameter OUT = 8;

//==============================================
//           reg & wire declaration             
//==============================================
reg [3:0] current_state,next_state;

reg signed[7:0] WQ [0:7][0:7] ;
reg signed[7:0] WK [0:7][0:7] ;
reg signed[7:0] WV [0:7][0:7] ;
reg signed[19:0] WQ_out [0:7][0:7] ;
reg signed[19:0] WK_out [0:7][0:7] ;
reg signed[19:0] WV_out [0:7][0:7] ;
reg signed[43:0] KQ [0:7][0:7] ;
reg signed[7:0] X_0 [0:7][0:7] ;
reg signed[19:0] X_CAL0, X_CAL1, X_CAL2, X_CAL3, X_CAL4, X_CAL5, X_CAL6, X_CAL7 ;
reg signed[19:0] W_CAL0, W_CAL1, W_CAL2, W_CAL3, W_CAL4, W_CAL5, W_CAL6, W_CAL7 ;
reg signed[43:0] scale_in1, scale_in2, scale_in3, scale_in4, scale_in5, scale_in6, scale_in7, scale_in8 ;
reg signed[43:0] scale_out1, scale_out2, scale_out3, scale_out4, scale_out5, scale_out6, scale_out7, scale_out8 ;
reg signed[43:0] RELU_out1, RELU_out2, RELU_out3, RELU_out4, RELU_out5, RELU_out6, RELU_out7, RELU_out8 ;
reg signed[43:0] RELU_in1, RELU_in2, RELU_in3, RELU_in4, RELU_in5, RELU_in6, RELU_in7, RELU_in8 ;
reg signed[43:0] S_in1, S_in2, S_in3, S_in4, S_in5, S_in6, S_in7, S_in8 ;
reg signed[43:0] V_in1, V_in2, V_in3, V_in4, V_in5, V_in6, V_in7, V_in8 ;

reg [3:0] T_in ;


reg [6:0]counter_in_1;
reg [6:0]counter_in_2;
reg [6:0]counter_in_3;
reg [3:0]counter_GEN;
reg [3:0]counter_GEN_8;
reg [3:0]counter_OUT;
reg [3:0]counter_OUT_8;
reg [10:0]counter_GEN_all;
reg [10:0]counter_global;
reg [4:0]counter_scale;
reg [4:0]counter_RELU;
reg signed[44:0]GEN_out;
//reg sleep_in1,sleep_in2,sleep_in3,sleep_gen,sleep_scl,sleep_re,sleep_out;
//wire clk_in1,clk_in2,clk_in3,clk_gen,clk_sc1,clk_sc2,clk_sc3,clk_sc4,clk_sc5,clk_sc6,clk_sc7,clk_sc8,clk_re1,clk_re2,clk_re3,clk_re4,clk_re5,clk_re6,clk_re7,clk_re8,clk_out,clk_gen1;
//==============================================
//                  GATE_OR            
//==============================================
/*GATED_OR GATED_IN1(.CLOCK(clk),.SLEEP_CTRL(sleep_in1),.RST_N(rst_n),.CLOCK_GATED(clk_in1));
GATED_OR GATED_IN2(.CLOCK(clk),.SLEEP_CTRL(sleep_in2),.RST_N(rst_n),.CLOCK_GATED(clk_in2));
GATED_OR GATED_IN3(.CLOCK(clk),.SLEEP_CTRL(sleep_in3),.RST_N(rst_n),.CLOCK_GATED(clk_in3));
GATED_OR GATED_GEN(.CLOCK(clk),.SLEEP_CTRL(sleep_gen),.RST_N(rst_n),.CLOCK_GATED(clk_gen));
GATED_OR GATED_GEN1(.CLOCK(clk),.SLEEP_CTRL(sleep_gen),.RST_N(rst_n),.CLOCK_GATED(clk_gen1));
GATED_OR GATED_SCALE1(.CLOCK(clk),.SLEEP_CTRL(sleep_scl),.RST_N(rst_n),.CLOCK_GATED(clk_sc1));
GATED_OR GATED_SCALE2(.CLOCK(clk),.SLEEP_CTRL(sleep_scl),.RST_N(rst_n),.CLOCK_GATED(clk_sc2));
GATED_OR GATED_SCALE3(.CLOCK(clk),.SLEEP_CTRL(sleep_scl),.RST_N(rst_n),.CLOCK_GATED(clk_sc3));
GATED_OR GATED_SCALE4(.CLOCK(clk),.SLEEP_CTRL(sleep_scl),.RST_N(rst_n),.CLOCK_GATED(clk_sc4));
GATED_OR GATED_SCALE5(.CLOCK(clk),.SLEEP_CTRL(sleep_scl),.RST_N(rst_n),.CLOCK_GATED(clk_sc5));
GATED_OR GATED_SCALE6(.CLOCK(clk),.SLEEP_CTRL(sleep_scl),.RST_N(rst_n),.CLOCK_GATED(clk_sc6));
GATED_OR GATED_SCALE7(.CLOCK(clk),.SLEEP_CTRL(sleep_scl),.RST_N(rst_n),.CLOCK_GATED(clk_sc7));
GATED_OR GATED_SCALE8(.CLOCK(clk),.SLEEP_CTRL(sleep_scl),.RST_N(rst_n),.CLOCK_GATED(clk_sc8));
GATED_OR GATED_RE1(.CLOCK(clk),.SLEEP_CTRL(sleep_re),.RST_N(rst_n),.CLOCK_GATED(clk_re1));
GATED_OR GATED_RE2(.CLOCK(clk),.SLEEP_CTRL(sleep_re),.RST_N(rst_n),.CLOCK_GATED(clk_re2));
GATED_OR GATED_RE3(.CLOCK(clk),.SLEEP_CTRL(sleep_re),.RST_N(rst_n),.CLOCK_GATED(clk_re3));
GATED_OR GATED_RE4(.CLOCK(clk),.SLEEP_CTRL(sleep_re),.RST_N(rst_n),.CLOCK_GATED(clk_re4));
GATED_OR GATED_RE5(.CLOCK(clk),.SLEEP_CTRL(sleep_re),.RST_N(rst_n),.CLOCK_GATED(clk_re5));
GATED_OR GATED_RE6(.CLOCK(clk),.SLEEP_CTRL(sleep_re),.RST_N(rst_n),.CLOCK_GATED(clk_re6));
GATED_OR GATED_RE7(.CLOCK(clk),.SLEEP_CTRL(sleep_re),.RST_N(rst_n),.CLOCK_GATED(clk_re7));
GATED_OR GATED_RE8(.CLOCK(clk),.SLEEP_CTRL(sleep_re),.RST_N(rst_n),.CLOCK_GATED(clk_re8));
GATED_OR GATED_OUT(.CLOCK(clk),.SLEEP_CTRL(sleep_out),.RST_N(rst_n),.CLOCK_GATED(clk_out));

always @(*) begin
	if(!cg_en) begin
		sleep_in1 = 0;
        sleep_in2 = 0;
        sleep_in3 = 0;
		sleep_gen = 0;
		sleep_scl = 0;
		sleep_re = 0;
		sleep_out = 0;
	end
	else begin
		sleep_in1  = (current_state != IN_DATA_Q && next_state != IN_DATA_Q && next_state != IN_DATA_K && next_state != IDLE && current_state != IDLE && current_state != OUT)?1:0;
        sleep_in2  = (current_state != IN_DATA_Q && current_state != IN_DATA_K && next_state != IN_DATA_K && next_state != IN_DATA_V && next_state != IDLE && next_state != OUT)?1:0;
        sleep_in3  = (current_state != IN_DATA_Q && current_state != IN_DATA_V && next_state != IN_DATA_V && next_state != GEN && next_state != IDLE && next_state != OUT)?1:0;
		sleep_gen  = (current_state != GEN && next_state != GEN && current_state != MATMUL && next_state != IDLE)?1:0;
		sleep_scl  = (current_state != SCALE && next_state != SCALE && next_state != IDLE)?1:0;
		sleep_re  = (current_state != RELU && next_state != RELU && next_state != IDLE)?1:0;
		sleep_out  = (current_state != RELU && current_state != OUT && next_state != OUT && next_state != IDLE  && current_state != IDLE)?1:0;
	end
end*/
//==============================================
//                  design                      
//==============================================

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)begin
		current_state <= 0;
	end
	else begin
		current_state <= next_state;
	end
end

always @(*) begin
	case(current_state)
		IDLE:begin
			if(in_valid)begin
				next_state = IN_DATA_Q;
			end
			else begin
				next_state = IDLE;
			end
		end
		IN_DATA_Q:begin
			if(counter_in_1==64)begin
				next_state = IN_DATA_K;
			end
			else begin
				next_state = IN_DATA_Q;
			end
		end
		IN_DATA_K:begin
			if(counter_in_2==64)begin
				next_state = IN_DATA_V;
			end
			else begin
				next_state = IN_DATA_K;
			end
		end
		IN_DATA_V:begin
			if(counter_in_3==64)begin
				next_state = GEN;
			end
			else begin
				next_state = IN_DATA_V;
			end
		end
		GEN:begin//4
			if(counter_GEN_all==191)begin
				next_state = MATMUL;
			end
			else begin
				next_state = GEN;
			end
		end
		MATMUL:begin//5
			if(counter_GEN_all==258)begin
				next_state = SCALE;
			end
			else begin
				next_state = MATMUL;
			end
		end
		SCALE:begin//6
			if(counter_scale==8)begin
				next_state = RELU;
			end
			else begin
				next_state = SCALE;
			end
		end
		RELU:begin//7
			if(counter_RELU==8)begin
				next_state = OUT;
			end
			else begin
				next_state = RELU;
			end
		end
		OUT:begin
			if(counter_OUT_8==8 && T_in==8)begin
				next_state = IDLE;
			end
			else if(counter_OUT_8==1 && T_in==1)begin
				next_state = IDLE;
			end
			else if(counter_OUT_8==4 && T_in==4)begin
				next_state = IDLE;
			end
			else begin
				next_state = OUT;
			end
		end
		default:begin
			next_state = IDLE;
		end
	endcase
end
//==============================================
//            counter design                      
//==============================================
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) counter_in_1 <= 0;
    else if(next_state==IN_DATA_Q) counter_in_1 <= counter_in_1 + 1;
    else if(next_state==IDLE) counter_in_1 <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) counter_in_2 <= 0;
    else if(next_state==IN_DATA_K) counter_in_2 <= counter_in_2 + 1;
    else if(next_state==IDLE) counter_in_2 <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) counter_in_3 <= 0;
    else if(next_state==IN_DATA_V) counter_in_3 <= counter_in_3 + 1;
    else if(next_state==IDLE) counter_in_3 <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) counter_GEN <= 0;
	else if(counter_GEN==7) counter_GEN <= 0;
    else if(current_state==GEN || current_state==MATMUL) counter_GEN <= counter_GEN + 1;
    else if(current_state==IDLE) counter_GEN <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) counter_GEN_8 <= 0;
	else if(counter_GEN_8==7 && counter_GEN==7) counter_GEN_8 <= 0;
    else if((current_state==GEN || current_state==MATMUL) && counter_GEN==7) counter_GEN_8 <= counter_GEN_8 + 1;
    else if(current_state==IDLE) counter_GEN_8 <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) counter_GEN_all <= 0;
    else if((current_state==GEN || current_state==MATMUL)) counter_GEN_all <= counter_GEN_all + 1;
    else if(current_state==IDLE) counter_GEN_all <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) counter_scale <= 0;
    else if(current_state==SCALE) counter_scale <= counter_scale + 1;
    else if(current_state==IDLE) counter_scale <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) counter_RELU <= 0;
    else if(current_state==RELU) counter_RELU <= counter_RELU + 1;
    else if(current_state==IDLE) counter_RELU <= 0;
end


always @(posedge clk or negedge rst_n) begin
    if(!rst_n) counter_OUT_8 <= 0;
	//else if(counter_OUT_8==7 && counter_OUT==7) counter_OUT_8 <= 0;
    else if(current_state==OUT && counter_OUT==7) counter_OUT_8 <= counter_OUT_8 + 1;
    else if(current_state==IDLE) counter_OUT_8 <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) counter_OUT <= 0;
	else if(counter_OUT==7) counter_OUT <= 0;
    else if(current_state==OUT) counter_OUT <= counter_OUT + 1;
    else if(current_state==IDLE) counter_OUT <= 0;
end

//==============================================
//             input design                      
//==============================================
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) T_in <= 0;
    else if (next_state == IN_DATA_Q && current_state == IDLE) T_in <= T;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i = 0; i < 8; i = i + 1) begin
			for(j = 0; j < 8; j = j + 1) begin
                WQ [i][j] <= 0;
			end
        end
    end
    else if(in_valid)begin
        case(counter_in_1)
            0  : WQ [0][0] <= w_Q;
			1  : WQ [0][1] <= w_Q;
			2  : WQ [0][2] <= w_Q;
			3  : WQ [0][3] <= w_Q;
			4  : WQ [0][4] <= w_Q;
			5  : WQ [0][5] <= w_Q;
			6  : WQ [0][6] <= w_Q;
			7  : WQ [0][7] <= w_Q;
			8  : WQ [1][0] <= w_Q;
			9  : WQ [1][1] <= w_Q;
			10  : WQ [1][2] <= w_Q;
			11  : WQ [1][3] <= w_Q;
			12  : WQ [1][4] <= w_Q;
			13  : WQ [1][5] <= w_Q;
			14  : WQ [1][6] <= w_Q;
			15  : WQ [1][7] <= w_Q;
			16  : WQ [2][0] <= w_Q;
			17  : WQ [2][1] <= w_Q;
			18  : WQ [2][2] <= w_Q;
			19  : WQ [2][3] <= w_Q;
			20  : WQ [2][4] <= w_Q;
			21  : WQ [2][5] <= w_Q;
			22  : WQ [2][6] <= w_Q;
			23  : WQ [2][7] <= w_Q;
			24  : WQ [3][0] <= w_Q;
			25  : WQ [3][1] <= w_Q;
			26  : WQ [3][2] <= w_Q;
			27  : WQ [3][3] <= w_Q;
			28  : WQ [3][4] <= w_Q;
			29  : WQ [3][5] <= w_Q;
			30  : WQ [3][6] <= w_Q;
			31  : WQ [3][7] <= w_Q;
			32  : WQ [4][0] <= w_Q;
			33  : WQ [4][1] <= w_Q;
			34  : WQ [4][2] <= w_Q;
			35  : WQ [4][3] <= w_Q;
			36  : WQ [4][4] <= w_Q;
			37  : WQ [4][5] <= w_Q;
			38  : WQ [4][6] <= w_Q;
			39  : WQ [4][7] <= w_Q;
			40  : WQ [5][0] <= w_Q;
			41  : WQ [5][1] <= w_Q;
			42  : WQ [5][2] <= w_Q;
			43  : WQ [5][3] <= w_Q;
			44  : WQ [5][4] <= w_Q;
			45  : WQ [5][5] <= w_Q;
			46  : WQ [5][6] <= w_Q;
			47  : WQ [5][7] <= w_Q;
			48  : WQ [6][0] <= w_Q;
			49  : WQ [6][1] <= w_Q;
			50  : WQ [6][2] <= w_Q;
			51  : WQ [6][3] <= w_Q;
			52  : WQ [6][4] <= w_Q;
			53  : WQ [6][5] <= w_Q;
			54  : WQ [6][6] <= w_Q;
			55  : WQ [6][7] <= w_Q;
			56  : WQ [7][0] <= w_Q;
			57  : WQ [7][1] <= w_Q;
			58  : WQ [7][2] <= w_Q;
			59  : WQ [7][3] <= w_Q;
			60  : WQ [7][4] <= w_Q;
			61  : WQ [7][5] <= w_Q;
			62  : WQ [7][6] <= w_Q;
			63  : WQ [7][7] <= w_Q;
            default:
            for(i = 0; i < 8; i = i + 1) begin
				for(j = 0; j < 8; j = j + 1) begin
					WQ [i][j] <= WQ [i][j];
				end
        	end
        endcase
    end
    else begin
        for(i = 0; i < 8; i = i + 1) begin
			for(j = 0; j < 8; j = j + 1) begin
                WQ [i][j] <= WQ [i][j];
			end
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i = 0; i < 8; i = i + 1) begin
			for(j = 0; j < 8; j = j + 1) begin
                WK [i][j] <= 0;
			end
        end
    end
    else if(in_valid)begin
        case(counter_in_2)
            0  : WK [0][0] <= w_K;
			1  : WK [0][1] <= w_K;
			2  : WK [0][2] <= w_K;
			3  : WK [0][3] <= w_K;
			4  : WK [0][4] <= w_K;
			5  : WK [0][5] <= w_K;
			6  : WK [0][6] <= w_K;
			7  : WK [0][7] <= w_K;
			8  : WK [1][0] <= w_K;
			9  : WK [1][1] <= w_K;
			10  : WK [1][2] <= w_K;
			11  : WK [1][3] <= w_K;
			12  : WK [1][4] <= w_K;
			13  : WK [1][5] <= w_K;
			14  : WK [1][6] <= w_K;
			15  : WK [1][7] <= w_K;
			16  : WK [2][0] <= w_K;
			17  : WK [2][1] <= w_K;
			18  : WK [2][2] <= w_K;
			19  : WK [2][3] <= w_K;
			20  : WK [2][4] <= w_K;
			21  : WK [2][5] <= w_K;
			22  : WK [2][6] <= w_K;
			23  : WK [2][7] <= w_K;
			24  : WK [3][0] <= w_K;
			25  : WK [3][1] <= w_K;
			26  : WK [3][2] <= w_K;
			27  : WK [3][3] <= w_K;
			28  : WK [3][4] <= w_K;
			29  : WK [3][5] <= w_K;
			30  : WK [3][6] <= w_K;
			31  : WK [3][7] <= w_K;
			32  : WK [4][0] <= w_K;
			33  : WK [4][1] <= w_K;
			34  : WK [4][2] <= w_K;
			35  : WK [4][3] <= w_K;
			36  : WK [4][4] <= w_K;
			37  : WK [4][5] <= w_K;
			38  : WK [4][6] <= w_K;
			39  : WK [4][7] <= w_K;
			40  : WK [5][0] <= w_K;
			41  : WK [5][1] <= w_K;
			42  : WK [5][2] <= w_K;
			43  : WK [5][3] <= w_K;
			44  : WK [5][4] <= w_K;
			45  : WK [5][5] <= w_K;
			46  : WK [5][6] <= w_K;
			47  : WK [5][7] <= w_K;
			48  : WK [6][0] <= w_K;
			49  : WK [6][1] <= w_K;
			50  : WK [6][2] <= w_K;
			51  : WK [6][3] <= w_K;
			52  : WK [6][4] <= w_K;
			53  : WK [6][5] <= w_K;
			54  : WK [6][6] <= w_K;
			55  : WK [6][7] <= w_K;
			56  : WK [7][0] <= w_K;
			57  : WK [7][1] <= w_K;
			58  : WK [7][2] <= w_K;
			59  : WK [7][3] <= w_K;
			60  : WK [7][4] <= w_K;
			61  : WK [7][5] <= w_K;
			62  : WK [7][6] <= w_K;
			63  : WK [7][7] <= w_K;
            default:
            for(i = 0; i < 8; i = i + 1) begin
				for(j = 0; j < 8; j = j + 1) begin
					WK [i][j] <= WK [i][j];
				end
        	end
        endcase
    end
    else begin
        for(i = 0; i < 8; i = i + 1) begin
			for(j = 0; j < 8; j = j + 1) begin
                WK [i][j] <= WK [i][j];
			end
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i = 0; i < 8; i = i + 1) begin
			for(j = 0; j < 8; j = j + 1) begin
                WV [i][j] <= 0;
			end
        end
    end
    else if(in_valid)begin
        case(counter_in_3)
            0  : WV [0][0] <= w_V;
			1  : WV [0][1] <= w_V;
			2  : WV [0][2] <= w_V;
			3  : WV [0][3] <= w_V;
			4  : WV [0][4] <= w_V;
			5  : WV [0][5] <= w_V;
			6  : WV [0][6] <= w_V;
			7  : WV [0][7] <= w_V;
			8  : WV [1][0] <= w_V;
			9  : WV [1][1] <= w_V;
			10  : WV [1][2] <= w_V;
			11  : WV [1][3] <= w_V;
			12  : WV [1][4] <= w_V;
			13  : WV [1][5] <= w_V;
			14  : WV [1][6] <= w_V;
			15  : WV [1][7] <= w_V;
			16  : WV [2][0] <= w_V;
			17  : WV [2][1] <= w_V;
			18  : WV [2][2] <= w_V;
			19  : WV [2][3] <= w_V;
			20  : WV [2][4] <= w_V;
			21  : WV [2][5] <= w_V;
			22  : WV [2][6] <= w_V;
			23  : WV [2][7] <= w_V;
			24  : WV [3][0] <= w_V;
			25  : WV [3][1] <= w_V;
			26  : WV [3][2] <= w_V;
			27  : WV [3][3] <= w_V;
			28  : WV [3][4] <= w_V;
			29  : WV [3][5] <= w_V;
			30  : WV [3][6] <= w_V;
			31  : WV [3][7] <= w_V;
			32  : WV [4][0] <= w_V;
			33  : WV [4][1] <= w_V;
			34  : WV [4][2] <= w_V;
			35  : WV [4][3] <= w_V;
			36  : WV [4][4] <= w_V;
			37  : WV [4][5] <= w_V;
			38  : WV [4][6] <= w_V;
			39  : WV [4][7] <= w_V;
			40  : WV [5][0] <= w_V;
			41  : WV [5][1] <= w_V;
			42  : WV [5][2] <= w_V;
			43  : WV [5][3] <= w_V;
			44  : WV [5][4] <= w_V;
			45  : WV [5][5] <= w_V;
			46  : WV [5][6] <= w_V;
			47  : WV [5][7] <= w_V;
			48  : WV [6][0] <= w_V;
			49  : WV [6][1] <= w_V;
			50  : WV [6][2] <= w_V;
			51  : WV [6][3] <= w_V;
			52  : WV [6][4] <= w_V;
			53  : WV [6][5] <= w_V;
			54  : WV [6][6] <= w_V;
			55  : WV [6][7] <= w_V;
			56  : WV [7][0] <= w_V;
			57  : WV [7][1] <= w_V;
			58  : WV [7][2] <= w_V;
			59  : WV [7][3] <= w_V;
			60  : WV [7][4] <= w_V;
			61  : WV [7][5] <= w_V;
			62  : WV [7][6] <= w_V;
			63  : WV [7][7] <= w_V;
            default:
            for(i = 0; i < 8; i = i + 1) begin
				for(j = 0; j < 8; j = j + 1) begin
					WV [i][j] <= WV [i][j];
				end
        	end
        endcase
    end
    else begin
        for(i = 0; i < 8; i = i + 1) begin
			for(j = 0; j < 8; j = j + 1) begin
                WV [i][j] <= WV [i][j];
			end
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i = 0; i < 8; i = i + 1) begin
		for(j = 0; j < 8; j = j + 1) begin			
                X_0 [i][j] <= 0;
			end
        end
    end
    else if(in_valid)begin
        case(counter_in_1)
            0  : X_0 [0][0] <= in_data;
			1  : X_0 [0][1] <= in_data;
			2  : X_0 [0][2] <= in_data;
			3  : X_0 [0][3] <= in_data;
			4  : X_0 [0][4] <= in_data;
			5  : X_0 [0][5] <= in_data;
			6  : X_0 [0][6] <= in_data;
			7  : X_0 [0][7] <= in_data;
			8  : X_0 [1][0] <= in_data;
			9  : X_0 [1][1] <= in_data;
			10  : X_0 [1][2] <= in_data;
			11  : X_0 [1][3] <= in_data;
			12  : X_0 [1][4] <= in_data;
			13  : X_0 [1][5] <= in_data;
			14  : X_0 [1][6] <= in_data;
			15  : X_0 [1][7] <= in_data;
			16  : X_0 [2][0] <= in_data;
			17  : X_0 [2][1] <= in_data;
			18  : X_0 [2][2] <= in_data;
			19  : X_0 [2][3] <= in_data;
			20  : X_0 [2][4] <= in_data;
			21  : X_0 [2][5] <= in_data;
			22  : X_0 [2][6] <= in_data;
			23  : X_0 [2][7] <= in_data;
			24  : X_0 [3][0] <= in_data;
			25  : X_0 [3][1] <= in_data;
			26  : X_0 [3][2] <= in_data;
			27  : X_0 [3][3] <= in_data;
			28  : X_0 [3][4] <= in_data;
			29  : X_0 [3][5] <= in_data;
			30  : X_0 [3][6] <= in_data;
			31  : X_0 [3][7] <= in_data;
			32  : X_0 [4][0] <= in_data;
			33  : X_0 [4][1] <= in_data;
			34  : X_0 [4][2] <= in_data;
			35  : X_0 [4][3] <= in_data;
			36  : X_0 [4][4] <= in_data;
			37  : X_0 [4][5] <= in_data;
			38  : X_0 [4][6] <= in_data;
			39  : X_0 [4][7] <= in_data;
			40  : X_0 [5][0] <= in_data;
			41  : X_0 [5][1] <= in_data;
			42  : X_0 [5][2] <= in_data;
			43  : X_0 [5][3] <= in_data;
			44  : X_0 [5][4] <= in_data;
			45  : X_0 [5][5] <= in_data;
			46  : X_0 [5][6] <= in_data;
			47  : X_0 [5][7] <= in_data;
			48  : X_0 [6][0] <= in_data;
			49  : X_0 [6][1] <= in_data;
			50  : X_0 [6][2] <= in_data;
			51  : X_0 [6][3] <= in_data;
			52  : X_0 [6][4] <= in_data;
			53  : X_0 [6][5] <= in_data;
			54  : X_0 [6][6] <= in_data;
			55  : X_0 [6][7] <= in_data;
			56  : X_0 [7][0] <= in_data;
			57  : X_0 [7][1] <= in_data;
			58  : X_0 [7][2] <= in_data;
			59  : X_0 [7][3] <= in_data;
			60  : X_0 [7][4] <= in_data;
			61  : X_0 [7][5] <= in_data;
			62  : X_0 [7][6] <= in_data;
			63  : X_0 [7][7] <= in_data;
            default:
            for(i = 0; i < 8; i = i + 1) begin
				for(j = 0; j < 8; j = j + 1) begin
					X_0 [i][j] <= X_0 [i][j];
				end
        	end
        endcase
    end
    else begin
        for(i = 0; i < 8; i = i + 1) begin
			for(j = 0; j < 8; j = j + 1) begin
                X_0 [i][j] <= X_0 [i][j];
			end
        end
    end
end

//==============================================
//         Generation  design                      
//==============================================
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
		X_CAL0 <= 0 ;
		X_CAL1 <= 0 ;
		X_CAL2 <= 0 ;
		X_CAL3 <= 0 ;
		X_CAL4 <= 0 ;
		X_CAL5 <= 0 ;
		X_CAL6 <= 0 ;
		X_CAL7 <= 0 ;
	end
    else if(current_state == IDLE)begin 
		X_CAL0 <= 0 ;
		X_CAL1 <= 0 ;
		X_CAL2 <= 0 ;
		X_CAL3 <= 0 ;
		X_CAL4 <= 0 ;
		X_CAL5 <= 0 ;
		X_CAL6 <= 0 ;
		X_CAL7 <= 0 ;
	end
    else if(current_state == GEN)begin 
		X_CAL0 <= X_0[counter_GEN_8][0];
		X_CAL1 <= X_0[counter_GEN_8][1];
		X_CAL2 <= X_0[counter_GEN_8][2];
		X_CAL3 <= X_0[counter_GEN_8][3];
		X_CAL4 <= X_0[counter_GEN_8][4];
		X_CAL5 <= X_0[counter_GEN_8][5];
		X_CAL6 <= X_0[counter_GEN_8][6];
		X_CAL7 <= X_0[counter_GEN_8][7];
	end
	else if(current_state == MATMUL)begin 
		X_CAL0 <= WQ_out[counter_GEN_8][0];
		X_CAL1 <= WQ_out[counter_GEN_8][1];
		X_CAL2 <= WQ_out[counter_GEN_8][2];
		X_CAL3 <= WQ_out[counter_GEN_8][3];
		X_CAL4 <= WQ_out[counter_GEN_8][4];
		X_CAL5 <= WQ_out[counter_GEN_8][5];
		X_CAL6 <= WQ_out[counter_GEN_8][6];
		X_CAL7 <= WQ_out[counter_GEN_8][7];
	end
	else begin 
		X_CAL0 <= X_CAL1;
		X_CAL1 <= X_CAL2;
		X_CAL2 <= X_CAL3;
		X_CAL3 <= X_CAL4;
		X_CAL4 <= X_CAL5;
		X_CAL5 <= X_CAL6;
		X_CAL6 <= X_CAL7;
		X_CAL7 <= X_CAL0;
	end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
		W_CAL0 <= 0 ;
		W_CAL1 <= 0 ;
		W_CAL2 <= 0 ;
		W_CAL3 <= 0 ;
		W_CAL4 <= 0 ;
		W_CAL5 <= 0 ;
		W_CAL6 <= 0 ;
		W_CAL7 <= 0 ;
	end
    else if(current_state == IDLE)begin 
		W_CAL0 <= 0 ;
		W_CAL1 <= 0 ;
		W_CAL2 <= 0 ;
		W_CAL3 <= 0 ;
		W_CAL4 <= 0 ;
		W_CAL5 <= 0 ;
		W_CAL6 <= 0 ;
		W_CAL7 <= 0 ;
	end
    else if(current_state == GEN && counter_GEN_all <= 63)begin 
		W_CAL0 <= WQ[0][counter_GEN];
		W_CAL1 <= WQ[1][counter_GEN];
		W_CAL2 <= WQ[2][counter_GEN];
		W_CAL3 <= WQ[3][counter_GEN];
		W_CAL4 <= WQ[4][counter_GEN];
		W_CAL5 <= WQ[5][counter_GEN];
		W_CAL6 <= WQ[6][counter_GEN];
		W_CAL7 <= WQ[7][counter_GEN];
	end
	else if(current_state == GEN && counter_GEN_all > 63 && counter_GEN_all <= 127)begin 
		W_CAL0 <= WK[0][counter_GEN];
		W_CAL1 <= WK[1][counter_GEN];
		W_CAL2 <= WK[2][counter_GEN];
		W_CAL3 <= WK[3][counter_GEN];
		W_CAL4 <= WK[4][counter_GEN];
		W_CAL5 <= WK[5][counter_GEN];
		W_CAL6 <= WK[6][counter_GEN];
		W_CAL7 <= WK[7][counter_GEN];
	end
	else if(current_state == GEN && counter_GEN_all > 127 && counter_GEN_all <= 191)begin 
		W_CAL0 <= WV[0][counter_GEN];
		W_CAL1 <= WV[1][counter_GEN];
		W_CAL2 <= WV[2][counter_GEN];
		W_CAL3 <= WV[3][counter_GEN];
		W_CAL4 <= WV[4][counter_GEN];
		W_CAL5 <= WV[5][counter_GEN];
		W_CAL6 <= WV[6][counter_GEN];
		W_CAL7 <= WV[7][counter_GEN];
	end
	else if(current_state == GEN && counter_GEN_all > 127 && counter_GEN_all <= 191)begin 
		W_CAL0 <= WV[0][counter_GEN];
		W_CAL1 <= WV[1][counter_GEN];
		W_CAL2 <= WV[2][counter_GEN];
		W_CAL3 <= WV[3][counter_GEN];
		W_CAL4 <= WV[4][counter_GEN];
		W_CAL5 <= WV[5][counter_GEN];
		W_CAL6 <= WV[6][counter_GEN];
		W_CAL7 <= WV[7][counter_GEN];
	end
	else if(current_state == MATMUL)begin 
		W_CAL0 <= WK_out[counter_GEN][0];
		W_CAL1 <= WK_out[counter_GEN][1];
		W_CAL2 <= WK_out[counter_GEN][2];
		W_CAL3 <= WK_out[counter_GEN][3];
		W_CAL4 <= WK_out[counter_GEN][4];
		W_CAL5 <= WK_out[counter_GEN][5];
		W_CAL6 <= WK_out[counter_GEN][6];
		W_CAL7 <= WK_out[counter_GEN][7];
	end
	else begin 
		W_CAL0 <= W_CAL1;
		W_CAL1 <= W_CAL2;
		W_CAL2 <= W_CAL3;
		W_CAL3 <= W_CAL4;
		W_CAL4 <= W_CAL5;
		W_CAL5 <= W_CAL6;
		W_CAL6 <= W_CAL7;
		W_CAL7 <= W_CAL0;
	end
end


always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
        GEN_out <=  0;  
    end
	else begin
		GEN_out <=  X_CAL0 * W_CAL0 +
					X_CAL1 * W_CAL1 +
					X_CAL2 * W_CAL2 +
					X_CAL3 * W_CAL3 +
					X_CAL4 * W_CAL4 +
					X_CAL5 * W_CAL5 +
					X_CAL6 * W_CAL6 +
					X_CAL7 * W_CAL7 ;
	end
end


always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for(i = 0; i < 8; i = i + 1) begin
			for(j = 0; j < 8; j = j + 1) begin
                WQ_out [i][j] <= 0;
			end
        end     
    end
    else if (current_state==GEN || current_state==MATMUL) begin
        WQ_out [(counter_GEN_all-2)/8][(counter_GEN_all-2)%8] <= GEN_out ;
    end
    else begin
        for(i = 0; i < 8; i = i + 1) begin
			for(j = 0; j < 8; j = j + 1) begin
                WQ_out [i][j] <= WQ_out [i][j] ;
			end
        end     
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for(i = 0; i < 8; i = i + 1) begin
			for(j = 0; j < 8; j = j + 1) begin
				WK_out [i][j] <= 0;
			end
        end     
    end
    else if (current_state==GEN || current_state==MATMUL) begin
		WK_out [(counter_GEN_all-66)/8][(counter_GEN_all-66)%8] <= GEN_out ;
    end
    else begin
        for(i = 0; i < 8; i = i + 1) begin
			for(j = 0; j < 8; j = j + 1) begin
				WK_out [i][j] <= WK_out [i][j] ;
			end
        end     
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for(i = 0; i < 8; i = i + 1) begin
			for(j = 0; j < 8; j = j + 1) begin
				WV_out [i][j] <= 0;
			end
        end     
    end
    else if (current_state==GEN || current_state==MATMUL) begin
		WV_out [(counter_GEN_all-130)/8][(counter_GEN_all-130)%8] <= GEN_out ;
    end
    else begin
        for(i = 0; i < 8; i = i + 1) begin
			for(j = 0; j < 8; j = j + 1) begin
				WV_out [i][j] <= WV_out [i][j] ;
			end
        end     
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for(i = 0; i < 8; i = i + 1) begin
			for(j = 0; j < 8; j = j + 1) begin
				KQ [i][j] <= 0;	
			end
        end     
    end
    else if (current_state==MATMUL) begin
       	KQ [(counter_GEN_all-194)/8][(counter_GEN_all-194)%8] <= GEN_out;	
    end
	else if (current_state==SCALE) begin
       	case(counter_scale)
			1:begin
				KQ [0][0] <= scale_out1;
				KQ [0][1] <= scale_out2;
				KQ [0][2] <= scale_out3;
				KQ [0][3] <= scale_out4;
				KQ [0][4] <= scale_out5;
				KQ [0][5] <= scale_out6;
				KQ [0][6] <= scale_out7;
				KQ [0][7] <= scale_out8;
			end
			2:begin
				KQ [1][0] <= scale_out1;
				KQ [1][1] <= scale_out2;
				KQ [1][2] <= scale_out3;
				KQ [1][3] <= scale_out4;
				KQ [1][4] <= scale_out5;
				KQ [1][5] <= scale_out6;
				KQ [1][6] <= scale_out7;
				KQ [1][7] <= scale_out8;
			end	
			3:begin
				KQ [2][0] <= scale_out1;
				KQ [2][1] <= scale_out2;
				KQ [2][2] <= scale_out3;
				KQ [2][3] <= scale_out4;
				KQ [2][4] <= scale_out5;
				KQ [2][5] <= scale_out6;
				KQ [2][6] <= scale_out7;
				KQ [2][7] <= scale_out8;
			end
			3:begin
				KQ [2][0] <= scale_out1;
				KQ [2][1] <= scale_out2;
				KQ [2][2] <= scale_out3;
				KQ [2][3] <= scale_out4;
				KQ [2][4] <= scale_out5;
				KQ [2][5] <= scale_out6;
				KQ [2][6] <= scale_out7;
				KQ [2][7] <= scale_out8;
			end	
			4:begin
				KQ [3][0] <= scale_out1;
				KQ [3][1] <= scale_out2;
				KQ [3][2] <= scale_out3;
				KQ [3][3] <= scale_out4;
				KQ [3][4] <= scale_out5;
				KQ [3][5] <= scale_out6;
				KQ [3][6] <= scale_out7;
				KQ [3][7] <= scale_out8;
			end	
			5:begin
				KQ [4][0] <= scale_out1;
				KQ [4][1] <= scale_out2;
				KQ [4][2] <= scale_out3;
				KQ [4][3] <= scale_out4;
				KQ [4][4] <= scale_out5;
				KQ [4][5] <= scale_out6;
				KQ [4][6] <= scale_out7;
				KQ [4][7] <= scale_out8;
			end	
			6:begin
				KQ [5][0] <= scale_out1;
				KQ [5][1] <= scale_out2;
				KQ [5][2] <= scale_out3;
				KQ [5][3] <= scale_out4;
				KQ [5][4] <= scale_out5;
				KQ [5][5] <= scale_out6;
				KQ [5][6] <= scale_out7;
				KQ [5][7] <= scale_out8;
			end	
			7:begin
				KQ [6][0] <= scale_out1;
				KQ [6][1] <= scale_out2;
				KQ [6][2] <= scale_out3;
				KQ [6][3] <= scale_out4;
				KQ [6][4] <= scale_out5;
				KQ [6][5] <= scale_out6;
				KQ [6][6] <= scale_out7;
				KQ [6][7] <= scale_out8;
			end
			8:begin
				KQ [7][0] <= scale_out1;
				KQ [7][1] <= scale_out2;
				KQ [7][2] <= scale_out3;
				KQ [7][3] <= scale_out4;
				KQ [7][4] <= scale_out5;
				KQ [7][5] <= scale_out6;
				KQ [7][6] <= scale_out7;
				KQ [7][7] <= scale_out8;
			end				
		endcase
    end
	else if (current_state==RELU) begin
       	case(counter_RELU)
			1:begin
				KQ [0][0] <= RELU_out1;
				KQ [0][1] <= RELU_out2;
				KQ [0][2] <= RELU_out3;
				KQ [0][3] <= RELU_out4;
				KQ [0][4] <= RELU_out5;
				KQ [0][5] <= RELU_out6;
				KQ [0][6] <= RELU_out7;
				KQ [0][7] <= RELU_out8;
			end
			2:begin
				KQ [1][0] <= RELU_out1;
				KQ [1][1] <= RELU_out2;
				KQ [1][2] <= RELU_out3;
				KQ [1][3] <= RELU_out4;
				KQ [1][4] <= RELU_out5;
				KQ [1][5] <= RELU_out6;
				KQ [1][6] <= RELU_out7;
				KQ [1][7] <= RELU_out8;
			end	
			3:begin
				KQ [2][0] <= RELU_out1;
				KQ [2][1] <= RELU_out2;
				KQ [2][2] <= RELU_out3;
				KQ [2][3] <= RELU_out4;
				KQ [2][4] <= RELU_out5;
				KQ [2][5] <= RELU_out6;
				KQ [2][6] <= RELU_out7;
				KQ [2][7] <= RELU_out8;
			end
			3:begin
				KQ [2][0] <= RELU_out1;
				KQ [2][1] <= RELU_out2;
				KQ [2][2] <= RELU_out3;
				KQ [2][3] <= RELU_out4;
				KQ [2][4] <= RELU_out5;
				KQ [2][5] <= RELU_out6;
				KQ [2][6] <= RELU_out7;
				KQ [2][7] <= RELU_out8;
			end	
			4:begin
				KQ [3][0] <= RELU_out1;
				KQ [3][1] <= RELU_out2;
				KQ [3][2] <= RELU_out3;
				KQ [3][3] <= RELU_out4;
				KQ [3][4] <= RELU_out5;
				KQ [3][5] <= RELU_out6;
				KQ [3][6] <= RELU_out7;
				KQ [3][7] <= RELU_out8;
			end	
			5:begin
				KQ [4][0] <= RELU_out1;
				KQ [4][1] <= RELU_out2;
				KQ [4][2] <= RELU_out3;
				KQ [4][3] <= RELU_out4;
				KQ [4][4] <= RELU_out5;
				KQ [4][5] <= RELU_out6;
				KQ [4][6] <= RELU_out7;
				KQ [4][7] <= RELU_out8;
			end	
			6:begin
				KQ [5][0] <= RELU_out1;
				KQ [5][1] <= RELU_out2;
				KQ [5][2] <= RELU_out3;
				KQ [5][3] <= RELU_out4;
				KQ [5][4] <= RELU_out5;
				KQ [5][5] <= RELU_out6;
				KQ [5][6] <= RELU_out7;
				KQ [5][7] <= RELU_out8;
			end	
			7:begin
				KQ [6][0] <= RELU_out1;
				KQ [6][1] <= RELU_out2;
				KQ [6][2] <= RELU_out3;
				KQ [6][3] <= RELU_out4;
				KQ [6][4] <= RELU_out5;
				KQ [6][5] <= RELU_out6;
				KQ [6][6] <= RELU_out7;
				KQ [6][7] <= RELU_out8;
			end
			8:begin
				KQ [7][0] <= RELU_out1;
				KQ [7][1] <= RELU_out2;
				KQ [7][2] <= RELU_out3;
				KQ [7][3] <= RELU_out4;
				KQ [7][4] <= RELU_out5;
				KQ [7][5] <= RELU_out6;
				KQ [7][6] <= RELU_out7;
				KQ [7][7] <= RELU_out8;
			end				
		endcase
    end
    else begin
        for(i = 0; i < 8; i = i + 1) begin
			for(j = 0; j < 8; j = j + 1) begin
                KQ [i][j] <=  KQ [i][j];	
			end
        end     
    end
	
end

//==============================================
//          Scale  design                      
//==============================================

always @(*) begin
	case(counter_scale)
		0:begin
			scale_in1 = KQ [0][0];
			scale_in2 = KQ [0][1];
			scale_in3 = KQ [0][2];
			scale_in4 = KQ [0][3];
			scale_in5 = KQ [0][4];
			scale_in6 = KQ [0][5];
			scale_in7 = KQ [0][6];
			scale_in8 = KQ [0][7];
		end
		1:begin
			scale_in1 = KQ [1][0];
			scale_in2 = KQ [1][1];
			scale_in3 = KQ [1][2];
			scale_in4 = KQ [1][3];
			scale_in5 = KQ [1][4];
			scale_in6 = KQ [1][5];
			scale_in7 = KQ [1][6];
			scale_in8 = KQ [1][7];
		end
		2:begin
			scale_in1 = KQ [2][0];
			scale_in2 = KQ [2][1];
			scale_in3 = KQ [2][2];
			scale_in4 = KQ [2][3];
			scale_in5 = KQ [2][4];
			scale_in6 = KQ [2][5];
			scale_in7 = KQ [2][6];
			scale_in8 = KQ [2][7];
		end
		3:begin
			scale_in1 = KQ [3][0];
			scale_in2 = KQ [3][1];
			scale_in3 = KQ [3][2];
			scale_in4 = KQ [3][3];
			scale_in5 = KQ [3][4];
			scale_in6 = KQ [3][5];
			scale_in7 = KQ [3][6];
			scale_in8 = KQ [3][7];
		end
		4:begin
			scale_in1 = KQ [4][0];
			scale_in2 = KQ [4][1];
			scale_in3 = KQ [4][2];
			scale_in4 = KQ [4][3];
			scale_in5 = KQ [4][4];
			scale_in6 = KQ [4][5];
			scale_in7 = KQ [4][6];
			scale_in8 = KQ [4][7];
		end
		5:begin
			scale_in1 = KQ [5][0];
			scale_in2 = KQ [5][1];
			scale_in3 = KQ [5][2];
			scale_in4 = KQ [5][3];
			scale_in5 = KQ [5][4];
			scale_in6 = KQ [5][5];
			scale_in7 = KQ [5][6];
			scale_in8 = KQ [5][7];
		end
		6:begin
			scale_in1 = KQ [6][0];
			scale_in2 = KQ [6][1];
			scale_in3 = KQ [6][2];
			scale_in4 = KQ [6][3];
			scale_in5 = KQ [6][4];
			scale_in6 = KQ [6][5];
			scale_in7 = KQ [6][6];
			scale_in8 = KQ [6][7];
		end
		7:begin
			scale_in1 = KQ [7][0];
			scale_in2 = KQ [7][1];
			scale_in3 = KQ [7][2];
			scale_in4 = KQ [7][3];
			scale_in5 = KQ [7][4];
			scale_in6 = KQ [7][5];
			scale_in7 = KQ [7][6];
			scale_in8 = KQ [7][7];
		end
	default:begin
		scale_in1 = 0;
		scale_in2 = 0;
		scale_in3 = 0;
		scale_in4 = 0;
		scale_in5 = 0;
		scale_in6 = 0;
		scale_in7 = 0;
		scale_in8 = 0;
	end
	endcase
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)begin
		scale_out1 <= scale_in1/3;
	end
	else begin
		scale_out1 <= scale_in1/3;
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)begin
		scale_out2 <= scale_in2/3;
	end
	else begin
		scale_out2 <= scale_in2/3;
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)begin
		scale_out3 <= scale_in3/3;
	end
	else begin
		scale_out3 <= scale_in3/3;
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)begin
		scale_out4 <= scale_in4/3;
	end
	else begin
		scale_out4 <= scale_in4/3;
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)begin
		scale_out5 <= scale_in5/3;
	end
	else begin
		scale_out5 <= scale_in5/3;
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)begin
		scale_out6 <= scale_in6/3;
	end
	else begin
		scale_out6 <= scale_in6/3;
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)begin
		scale_out7 <= scale_in7/3;
	end
	else begin
		scale_out7 <= scale_in7/3;
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)begin
		scale_out8 <= scale_in8/3;
	end
	else begin
		scale_out8 <= scale_in8/3;
	end
end


//==============================================
//          RELU  design                      
//==============================================
always @(*) begin
	case(counter_RELU)
		0:begin
			RELU_in1 = KQ [0][0];
			RELU_in2 = KQ [0][1];
			RELU_in3 = KQ [0][2];
			RELU_in4 = KQ [0][3];
			RELU_in5 = KQ [0][4];
			RELU_in6 = KQ [0][5];
			RELU_in7 = KQ [0][6];
			RELU_in8 = KQ [0][7];
		end
		1:begin
			RELU_in1 = KQ [1][0];
			RELU_in2 = KQ [1][1];
			RELU_in3 = KQ [1][2];
			RELU_in4 = KQ [1][3];
			RELU_in5 = KQ [1][4];
			RELU_in6 = KQ [1][5];
			RELU_in7 = KQ [1][6];
			RELU_in8 = KQ [1][7];
		end
		2:begin
			RELU_in1 = KQ [2][0];
			RELU_in2 = KQ [2][1];
			RELU_in3 = KQ [2][2];
			RELU_in4 = KQ [2][3];
			RELU_in5 = KQ [2][4];
			RELU_in6 = KQ [2][5];
			RELU_in7 = KQ [2][6];
			RELU_in8 = KQ [2][7];
		end
		3:begin
			RELU_in1 = KQ [3][0];
			RELU_in2 = KQ [3][1];
			RELU_in3 = KQ [3][2];
			RELU_in4 = KQ [3][3];
			RELU_in5 = KQ [3][4];
			RELU_in6 = KQ [3][5];
			RELU_in7 = KQ [3][6];
			RELU_in8 = KQ [3][7];
		end
		4:begin
			RELU_in1 = KQ [4][0];
			RELU_in2 = KQ [4][1];
			RELU_in3 = KQ [4][2];
			RELU_in4 = KQ [4][3];
			RELU_in5 = KQ [4][4];
			RELU_in6 = KQ [4][5];
			RELU_in7 = KQ [4][6];
			RELU_in8 = KQ [4][7];
		end
		5:begin
			RELU_in1 = KQ [5][0];
			RELU_in2 = KQ [5][1];
			RELU_in3 = KQ [5][2];
			RELU_in4 = KQ [5][3];
			RELU_in5 = KQ [5][4];
			RELU_in6 = KQ [5][5];
			RELU_in7 = KQ [5][6];
			RELU_in8 = KQ [5][7];
		end
		6:begin
			RELU_in1 = KQ [6][0];
			RELU_in2 = KQ [6][1];
			RELU_in3 = KQ [6][2];
			RELU_in4 = KQ [6][3];
			RELU_in5 = KQ [6][4];
			RELU_in6 = KQ [6][5];
			RELU_in7 = KQ [6][6];
			RELU_in8 = KQ [6][7];
		end
		7:begin
			RELU_in1 = KQ [7][0];
			RELU_in2 = KQ [7][1];
			RELU_in3 = KQ [7][2];
			RELU_in4 = KQ [7][3];
			RELU_in5 = KQ [7][4];
			RELU_in6 = KQ [7][5];
			RELU_in7 = KQ [7][6];
			RELU_in8 = KQ [7][7];
		end
	default:begin
		RELU_in1 = 0;
		RELU_in2 = 0;
		RELU_in3 = 0;
		RELU_in4 = 0;
		RELU_in5 = 0;
		RELU_in6 = 0;
		RELU_in7 = 0;
		RELU_in8 = 0;
	end
	endcase
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)begin
		RELU_out1 <= 0 ;
	end
	else begin 
		RELU_out1 <= (RELU_in1>0)?RELU_in1:0;
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)begin
		RELU_out2 <= 0 ;
	end
	else begin
		RELU_out2 <= (RELU_in2>0)?RELU_in2:0;
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)begin
		RELU_out3 <= 0 ;
	end
	else begin 
		RELU_out3 <= (RELU_in3>0)?RELU_in3:0;
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)begin
		RELU_out4 <= 0 ;
	end
	else begin 
		RELU_out4 <= (RELU_in4>0)?RELU_in4:0;
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)begin
		RELU_out5 <= 0 ;
	end
	else begin
		RELU_out5 <= (RELU_in5>0)?RELU_in5:0;
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)begin
		RELU_out6 <= 0 ;
	end
	else begin 
		RELU_out6 <= (RELU_in6>0)?RELU_in6:0;
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)begin
		RELU_out7 <= 0 ;
	end
	else begin 
		RELU_out7 <= (RELU_in7>0)?RELU_in7:0;
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)begin
		RELU_out8 <= 0 ;
	end
	else begin 
		RELU_out8 <= (RELU_in8>0)?RELU_in8:0;
	end
end


//==============================================
//             OUT design                      
//==============================================
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
		S_in1 <= 0 ;
		S_in2 <= 0 ;
		S_in3 <= 0 ;
		S_in4 <= 0 ;
		S_in5 <= 0 ;
		S_in6 <= 0 ;
		S_in7 <= 0 ;
		S_in8 <= 0 ;
	end
    else if(current_state == IDLE)begin 
		S_in1 <= 0 ;
		S_in2 <= 0 ;
		S_in3 <= 0 ;
		S_in4 <= 0 ;
		S_in5 <= 0 ;
		S_in6 <= 0 ;
		S_in7 <= 0 ;
		S_in8 <= 0 ;
	end
    else if(current_state == OUT && next_state!=IDLE)begin 
		S_in1 <= KQ[counter_OUT_8][0];
		S_in2 <= KQ[counter_OUT_8][1];
		S_in3 <= KQ[counter_OUT_8][2];
		S_in4 <= KQ[counter_OUT_8][3];
		S_in5 <= KQ[counter_OUT_8][4];
		S_in6 <= KQ[counter_OUT_8][5];
		S_in7 <= KQ[counter_OUT_8][6];
		S_in8 <= KQ[counter_OUT_8][7];
	end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
		V_in1 <= 0 ;
		V_in2 <= 0 ;
		V_in3 <= 0 ;
		V_in4 <= 0 ;
		V_in5 <= 0 ;
		V_in6 <= 0 ;
		V_in7 <= 0 ;
		V_in8 <= 0 ;
	end
    else if(current_state == IDLE)begin 
		V_in1 <= 0 ;
		V_in2 <= 0 ;
		V_in3 <= 0 ;
		V_in4 <= 0 ;
		V_in5 <= 0 ;
		V_in6 <= 0 ;
		V_in7 <= 0 ;
		V_in8 <= 0 ;
	end
    else if(current_state == OUT && next_state!=IDLE)begin 
		V_in1 <= WV_out[0][counter_OUT];
		V_in2 <= WV_out[1][counter_OUT];
		V_in3 <= WV_out[2][counter_OUT];
		V_in4 <= WV_out[3][counter_OUT];
		V_in5 <= WV_out[4][counter_OUT];
		V_in6 <= WV_out[5][counter_OUT];
		V_in7 <= WV_out[6][counter_OUT];
		V_in8 <= WV_out[7][counter_OUT];
	end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_valid <= 0 ;     
    end
    else if (current_state==OUT && next_state!=IDLE) begin
        out_valid <= 1 ;
    end
    else out_valid <= 0 ;
end

always @(*) begin
    if (current_state==OUT && T_in==8) begin
        out_data =  S_in1 * V_in1 +
					S_in2 * V_in2 +
					S_in3 * V_in3 +
					S_in4 * V_in4 +
					S_in5 * V_in5 +
					S_in6 * V_in6 +
					S_in7 * V_in7 +
					S_in8 * V_in8 ; 
    end
	else if (current_state==OUT && T_in==4) begin
        out_data =  S_in1 * V_in1 +
					S_in2 * V_in2 +
					S_in3 * V_in3 +
					S_in4 * V_in4 ;
    end
	else if (current_state==OUT && T_in==1) begin
        out_data =  S_in1 * V_in1;
    end
    else out_data = 0 ;
end

endmodule
