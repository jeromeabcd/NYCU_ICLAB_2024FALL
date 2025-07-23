//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//    (C) Copyright System Integration and Silicon Implementation Laboratory
//    All Right Reserved
//		Date		: 2024/9
//		Version		: v1.0
//   	File Name   : MDC.v
//   	Module Name : MDC
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

//synopsys translate_off
`include "HAMMING_IP.v"
//synopsys translate_on

module MDC(
    // Input signals
    clk,
	rst_n,
	in_valid,
    in_data, 
	in_mode,
    // Output signals
    out_valid, 
	out_data
);

// ===============================================================
// Input & Output Declaration
// ===============================================================
input clk, rst_n, in_valid;
input [8:0] in_mode;
input [14:0] in_data;

output reg out_valid;
output reg [206:0] out_data;

//==================================================================
// parameter & integer declaration
//==================================================================
integer i,j;
parameter IDLE = 0;
parameter IN_DATA = 1;
parameter CAL = 2;
parameter OUT = 3;

//==================================================================
// reg & wire
//==================================================================
reg [1:0]current_state,next_state;
reg [14:0] in_data_seq;
reg signed[10:0] in_data_out;
reg signed[10:0] det_map [0:3][0:3];
reg signed[10:0] det_00,det_01,det_10,det_11;
reg signed[22:0] det_square;
reg signed[10:0] det_mul_big1,det_mul_big2;
reg signed[44:0] det_all_1,det_all_2;
reg signed[10:0] det_mul_1,det_mul_2;
reg signed[44:0] det_all;
reg signed[44:0] det_out;
reg signed[50:0] det4_map [0:3];
reg signed[22:0] det9_map [0:8];
reg [4:0]counter;
reg [8:0]mode_in;
reg [4:0]mode;
//==================================================================
// FSM
//==================================================================
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
            if(!in_valid) next_state = CAL;
            else next_state = IN_DATA;
        end
        CAL:begin//2
            if(mode == 22 && counter == 22) next_state = OUT;
            else if(mode == 6 && counter == 22) next_state = OUT;
            else if(mode == 4 && counter == 17) next_state = OUT;
            else next_state = CAL;
        end
        OUT:begin//6
            next_state = IDLE;
        end
        default:next_state = IDLE;
	endcase
end


//==================================================================
// counter design
//==================================================================

always @(posedge clk or negedge rst_n) begin//counter
    if(!rst_n) counter <= 0;
    else if(in_valid || next_state == CAL) counter <= counter + 1;
    else /*if(current_state==IDLE)*/ counter <= 0;
end


//==================================================================
// design
//==================================================================
always @ (posedge clk or negedge rst_n) begin 
	if (!rst_n) in_data_seq <= 0 ;
	else in_data_seq <= in_data  ;
end

always @(posedge clk or negedge rst_n) begin//mode
    if(!rst_n) mode_in <= 0;
    else if (in_valid && counter==0) mode_in <= in_mode;
end



always @(posedge clk or negedge rst_n) begin//det_map
    if(!rst_n) begin
        for(i = 0; i < 4; i = i + 1) begin
            for(j = 0; j < 4; j = j + 1) begin
                det_map[i][j] <= 0; 
            end   
        end
    end
    else if(in_valid || counter<=17)begin
        case(counter)
            1  : det_map[0][0] <= in_data_out;
            2  : det_map[0][1] <= in_data_out;
            3  : det_map[0][2] <= in_data_out;
            4  : det_map[0][3] <= in_data_out;
            5  : det_map[1][0] <= in_data_out;
            6  : det_map[1][1] <= in_data_out;
            7  : det_map[1][2] <= in_data_out;
            8  : det_map[1][3] <= in_data_out;
            9  : det_map[2][0] <= in_data_out;
            10 : det_map[2][1] <= in_data_out;
            11 : det_map[2][2] <= in_data_out;
            12 : det_map[2][3] <= in_data_out;
            13 : det_map[3][0] <= in_data_out;
            14 : det_map[3][1] <= in_data_out;
            15 : det_map[3][2] <= in_data_out;
            16 : det_map[3][3] <= in_data_out;
        endcase
    end
end

always @(*)begin
    if(mode == 22)begin
        case(counter)
            17 : begin
                det_00 = det_map[2][2];
                det_01 = det_map[2][3];
                det_10 = det_map[3][2];
                det_11 = det_map[3][3];
            end
            18 : begin
                det_00 = det_map[1][2];
                det_01 = det_map[1][3];
                det_10 = det_map[3][2];
                det_11 = det_map[3][3];
            end
            19 : begin
                det_00 = det_map[1][2];
                det_01 = det_map[1][3];
                det_10 = det_map[2][2];
                det_11 = det_map[2][3];
            end
            20 : begin
                det_00 = det_map[2][0];
                det_01 = det_map[2][1];
                det_10 = det_map[3][0];
                det_11 = det_map[3][1];
            end
            21 : begin
                det_00 = det_map[1][0];
                det_01 = det_map[1][1];
                det_10 = det_map[3][0];
                det_11 = det_map[3][1];
            end
            22 : begin
                det_00 = det_map[1][0];
                det_01 = det_map[1][1];
                det_10 = det_map[2][0];
                det_11 = det_map[2][1];
            end
            default:begin
                det_00 = 0;
                det_01 = 0;
                det_10 = 0;
                det_11 = 0;
            end
        endcase
    end
    else if(mode == 6)begin
        case(counter)
            17 : begin
                det_00 = det_map[1][1];
                det_01 = det_map[1][2];
                det_10 = det_map[2][1];
                det_11 = det_map[2][2];
            end
            18 : begin
                det_00 = det_map[0][1];
                det_01 = det_map[0][2];
                det_10 = det_map[2][1];
                det_11 = det_map[2][2];
            end
            19 : begin
                det_00 = det_map[0][1];
                det_01 = det_map[0][2];
                det_10 = det_map[1][1];
                det_11 = det_map[1][2];
            end
            20 : begin
                det_00 = det_map[2][1];
                det_01 = det_map[2][2];
                det_10 = det_map[3][1];
                det_11 = det_map[3][2];
            end
            21 : begin
                det_00 = det_map[1][1];
                det_01 = det_map[1][2];
                det_10 = det_map[3][1];
                det_11 = det_map[3][2];
            end
            22 : begin
                det_00 = det_map[1][1];
                det_01 = det_map[1][2];
                det_10 = det_map[2][1];
                det_11 = det_map[2][2];
            end
            default:begin
                det_00 = 0;
                det_01 = 0;
                det_10 = 0;
                det_11 = 0;
            end
        endcase
    end
    else if(mode == 4)begin
        case(counter)
            9 : begin
                det_00 = det_map[0][0];
                det_01 = det_map[0][1];
                det_10 = det_map[1][0];
                det_11 = det_map[1][1];
            end
            10 : begin
                det_00 = det_map[0][1];
                det_01 = det_map[0][2];
                det_10 = det_map[1][1];
                det_11 = det_map[1][2];
            end
            11 : begin
                det_00 = det_map[0][2];
                det_01 = det_map[0][3];
                det_10 = det_map[1][2];
                det_11 = det_map[1][3];
            end
            12 : begin
                det_00 = det_map[1][0];
                det_01 = det_map[1][1];
                det_10 = det_map[2][0];
                det_11 = det_map[2][1];
            end
            13 : begin
                det_00 = det_map[1][1];
                det_01 = det_map[1][2];
                det_10 = det_map[2][1];
                det_11 = det_map[2][2];
            end
            14 : begin
                det_00 = det_map[1][2];
                det_01 = det_map[1][3];
                det_10 = det_map[2][2];
                det_11 = det_map[2][3];
            end
            15 : begin
                det_00 = det_map[2][0];
                det_01 = det_map[2][1];
                det_10 = det_map[3][0];
                det_11 = det_map[3][1];
            end
            16 : begin
                det_00 = det_map[2][1];
                det_01 = det_map[2][2];
                det_10 = det_map[3][1];
                det_11 = det_map[3][2];
            end
            17 : begin
                det_00 = det_map[2][2];
                det_01 = det_map[2][3];
                det_10 = det_map[3][2];
                det_11 = det_map[3][3];
            end
            default:begin
                det_00 = 0;
                det_01 = 0;
                det_10 = 0;
                det_11 = 0;
            end
        endcase
    end
    else begin
        det_00 = 0;
        det_01 = 0;
        det_10 = 0;
        det_11 = 0;
    end
end

always @(*)begin
    if(mode == 22)begin
        case(counter)
            17 : begin
                det_mul_1 = det_map[1][1];
                det_mul_2 = det_map[1][0];
                det_mul_big1 = det_map[0][0];
                det_mul_big2 = det_map[0][1];
            end
            18 : begin
                det_mul_1 = det_map[2][0];
                det_mul_2 = det_map[2][1];
                det_mul_big1 = det_map[0][1];
                det_mul_big2 = det_map[0][0];
            end
            19 : begin
                det_mul_1 = det_map[3][1];
                det_mul_2 = det_map[3][0];
                det_mul_big1 = det_map[0][0];
                det_mul_big2 = det_map[0][1];
            end
            20 : begin
                det_mul_1 = det_map[1][3];
                det_mul_2 = det_map[1][2];
                det_mul_big1 = det_map[0][2];
                det_mul_big2 = det_map[0][3];
            end
            21 : begin
                det_mul_1 = det_map[2][2];
                det_mul_2 = det_map[2][3];
                det_mul_big1 = det_map[0][3];
                det_mul_big2 = det_map[0][2];
            end
            22 : begin
                det_mul_1 = det_map[3][3];
                det_mul_2 = det_map[3][2];
                det_mul_big1 = det_map[0][2];
                det_mul_big2 = det_map[0][3];
            end
            default:begin
                det_mul_1 = 1;
                det_mul_2 = 1;
                det_mul_big1 = 1;
                det_mul_big2 = 1;
            end
        endcase
    end
    else if(mode == 6)begin
        case(counter)
            17 : begin
                det_mul_1 = det_map[0][0];
                det_mul_2 = det_map[0][3];
                det_mul_big1 = 1;
                det_mul_big2 = 1;
            end
            18 : begin
                det_mul_1 = det_map[1][0];
                det_mul_2 = det_map[1][3];
                det_mul_big1 = 1;
                det_mul_big2 = 1;
            end
            19 : begin
                det_mul_1 = det_map[2][0];
                det_mul_2 = det_map[2][3];
                det_mul_big1 = 1;
                det_mul_big2 = 1;
            end
            20 : begin
                det_mul_1 = det_map[1][0];
                det_mul_2 = det_map[1][3];
                det_mul_big1 = 1;
                det_mul_big2 = 1;
            end
            21 : begin
                det_mul_1 = det_map[2][0];
                det_mul_2 = det_map[2][3];
                det_mul_big1 = 1;
                det_mul_big2 = 1;
            end
            22 : begin
                det_mul_1 = det_map[3][0];
                det_mul_2 = det_map[3][3];
                det_mul_big1 = 1;
                det_mul_big2 = 1;
            end
            default:begin
                det_mul_1 = 1;
                det_mul_2 = 1;
                det_mul_big1 = 1;
                det_mul_big2 = 1;
            end
        endcase
    end
    else begin
        det_mul_1 = 1;
        det_mul_2 = 1;
        det_mul_big1 = 1;
        det_mul_big2 = 1;
    end
end



always @(*) begin
    det_square = ((det_00*det_11) - (det_01*det_10));
end

always @(*) begin
    det_all_1 = det_square*det_mul_big1*det_mul_1;
    det_all_2 = det_square*det_mul_big2*det_mul_2;
end

always @(*) begin
    det_all = det_all_1-det_all_2;
end


always @(posedge clk/* or negedge rst_n*/) begin
    /*if (!rst_n) det_out <= 0;
    else */if (mode == 22 && counter >= 17 && counter <= 22) det_out <= det_out + det_all;
    else if (current_state==IDLE) det_out <= 0;
    else det_out <= det_out;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for(i = 0; i < 4; i = i + 1) begin
            det4_map[i] <= 0; 
        end
    end
    /*else if (current_state==IDLE)begin
        for(i = 0; i < 4; i = i + 1) begin
            det4_map[i] <= 0; 
        end
    end*/
    else if (mode == 6) begin
        case(counter)
            17:begin//0
                det4_map[0] <= det_all_1;
                det4_map[1] <= det_all_2;
            end
            18:begin//1
                det4_map[0] <= det4_map[0] - det_all_1;
                det4_map[1] <= det4_map[1] - det_all_2;
            end
            19:begin//2
                det4_map[0] <= det4_map[0] + det_all_1;
                det4_map[1] <= det4_map[1] + det_all_2;
            end
            20:begin//0
                det4_map[2] <= det_all_1;
                det4_map[3] <= det_all_2;
            end
            21:begin//1
                det4_map[2] <= det4_map[2] - det_all_1;
                det4_map[3] <= det4_map[3] - det_all_2;
            end
            22:begin//2
                det4_map[2] <= det4_map[2] + det_all_1;
                det4_map[3] <= det4_map[3] + det_all_2;
            end
            default:begin
                for(i = 0; i < 4; i = i + 1) begin
                    det4_map[i] <= det4_map[i]; 
                end
            end
        endcase
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for(i = 0; i < 9; i = i + 1) begin
            det9_map[i] <= 0; 
        end
    end
    else if (mode == 4) begin
        case(counter)
            9:det9_map[0] <= det_square;
            10:det9_map[1] <= det_square;
            11:det9_map[2] <= det_square;
            12:det9_map[3] <= det_square;
            13:det9_map[4] <= det_square;
            14:det9_map[5] <= det_square;
            15:det9_map[6] <= det_square;
            16:det9_map[7] <= det_square;
            17:det9_map[8] <= det_square;          
            default:begin
                for(i = 0; i < 4; i = i + 1) begin
                    det9_map[i] <= det9_map[i]; 
                end
            end
        endcase
    end
end

//==================================================================
// OUT design
//==================================================================

always @(*) begin
    if (current_state == OUT)
        if(mode==22) out_data = det_out;
        else if(mode==6) out_data = {3'b0,det4_map[0],det4_map[1],det4_map[2],det4_map[3]};
        else  out_data = {det9_map[0],det9_map[1],det9_map[2],det9_map[3],det9_map[4],det9_map[5],det9_map[6],det9_map[7],det9_map[8]};
    else out_data = 0;
end


always @(*) begin
    if(current_state == OUT) out_valid = 1;
    else out_valid = 0;
end



//==================================================================
// IP
//==================================================================

HAMMING_IP #(.IP_BIT(11)) HAMMING(.IN_code(in_data_seq), .OUT_code(in_data_out));
HAMMING_IP #(.IP_BIT(5)) MODE(.IN_code(mode_in), .OUT_code(mode));

endmodule