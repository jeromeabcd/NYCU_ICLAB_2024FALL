/**************************************************************************/
// Copyright (c) 2024, OASIS Lab
// MODULE: TETRIS
// FILE NAME: TETRIS.v
// VERSRION: 1.0
// DATE: August 15, 2024
// AUTHOR: Yu-Hsuan Hsu, NYCU IEE
// DESCRIPTION: ICLAB2024FALL / LAB3 / TETRIS
// MODIFICATION HISTORY:
// Date                 Description
// 
/**************************************************************************/
module TETRIS (
	//INPUT
	rst_n,
	clk,
	in_valid,
	tetrominoes,
	position,
	//OUTPUT
	tetris_valid,
	score_valid,
	fail,
	score,
	tetris
);

//---------------------------------------------------------------------
//   PORT DECLARATION          
//---------------------------------------------------------------------
input				rst_n, clk, in_valid;
input		[2:0]	tetrominoes;
input		[2:0]	position;
output reg			tetris_valid, score_valid, fail;
output reg	[3:0]	score;
output reg 	[71:0]	tetris;



//---------------------------------------------------------------------
//   PARAMETER & INTEGER DECLARATION
//---------------------------------------------------------------------
parameter IDLE = 3'd0;
parameter CAL = 3'd1;
parameter ELI = 3'd2;
parameter OUT = 3'd3;
integer i; 
//---------------------------------------------------------------------
//   REG & WIRE DECLARATION
//---------------------------------------------------------------------

reg [2:0] tetrominoes_in,position_in;
reg [4:0] counter, count_out,count_16_s;
reg [8:0] bit_p;
reg [101:0] map;
reg [6:0] map2 [20:0];
reg [2:0] current_state,next_state;
reg [5:0] row,row_A,row_seq,eli_row;
reg [3:0] score_A;
reg [6:0] map_judge;
reg condition_precalculated;


//---------------------------------------------------------------------
//   DESIGN
//---------------------------------------------------------------------
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		current_state <= IDLE;
	else
		current_state <= next_state;
end

always@(*)begin
	case(current_state)
		IDLE:begin
			if(in_valid)
				next_state = CAL;
			else
				next_state = current_state;
		end
		CAL:begin
			if(row==row_seq+1) next_state = ELI;
			else next_state = current_state;
		end
		ELI:begin
			if(counter==3) next_state = OUT;
			else next_state = ELI;
		end
		OUT:begin
			if (fail || count_16_s==16) next_state = IDLE;
			else if (in_valid)next_state = CAL;
			else next_state = OUT;
		end
		default:next_state = IDLE;
	endcase
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n) 
		counter <= 0;
	else if(next_state==IDLE || next_state==CAL)
		counter <= 0;
	else if(current_state==ELI) 
		counter <= counter + 1;
	else counter <= 0;
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n) 
		count_out <= 0;
	else if(next_state==IDLE || next_state==CAL)
		count_out <= 0;
	else if(current_state==OUT) 
		count_out <= count_out + 1;
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n) 
		count_16_s <= 0;
	else if(next_state==IDLE)
		count_16_s <= 0;
	else if(count_out==1) 
		count_16_s <= count_16_s + 1;
end


always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		tetrominoes_in <= 0;
		position_in <= 0;
	end
	else if(next_state==IDLE)begin
		tetrominoes_in <= 0;
		position_in <= 0;
	end
	else if(in_valid)begin
		tetrominoes_in <= tetrominoes;
		position_in <= position;
	end
	else begin
		tetrominoes_in <= tetrominoes_in;
		position_in <= position_in;
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		row_seq <= 0;
	end
	else begin
		row_seq <= row;
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		row_A <= 0;
	end
	else if(current_state==CAL && next_state==ELI)begin
		row_A <= row;
	end
end

/*always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		bit_a <= 0;
		bit_b <= 0;
		bit_c <= 0;
	end
	else begin
		bit_a <= bit_p + 1;
		bit_b <= bit_p + 2;
		bit_c <= bit_p + 3;
	end
end*/
/*always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		bit_p <= 0;
	end
	else begin
		bit_p <= row * 6 + position_in;
	end
end*/


/*always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		row <= 12;
	end
	else if(current_state==OUT)begin
		row <= 12;
	end
	else if(current_state==CAL)begin
		case(tetrominoes_in)
				3'd0: begin
					if(map[bit_p] == 0 && map[bit_p + 1] == 0 && map[bit_p + 6] == 0 && map[bit_p + 7] == 0) begin
						row <= row - 1;
					end 
					else row <= row + 1;
				end
				3'd1: begin
					if(map[bit_p] == 0 && map[bit_p + 6] == 0 && map[bit_p + 12] == 0 && map[bit_p + 18] == 0) begin
						row <= row - 1;
					end
					else row <= row + 1;
				end
				3'd2: begin
					if(map[bit_p] == 0 && map[bit_p + 1] == 0 && map[bit_p + 2] == 0 && map[bit_p + 3] == 0) begin
						row <= row - 1;
					end
					else row <= row + 1;
				end
				3'd3: begin
					if(map[bit_p + 1] == 0 && map[bit_p + 7] == 0 && map[bit_p + 12] == 0 && map[bit_p + 13] == 0) begin
						row <= row - 1;
					end
					else row <= row + 1;
				end
				3'd4: begin
					if(map[bit_p] == 0 && map[bit_p + 6] == 0 && map[bit_p + 7] == 0 && map[bit_p + 8] == 0) begin
						row <= row - 1;
					end
					else row <= row + 1;
				end
				3'd5: begin
					if(map[bit_p] == 0 && map[bit_p + 1] == 0 && map[bit_p + 6] == 0 && map[bit_p + 12] == 0) begin
						row <= row - 1;
					end
					else row <= row + 1;
				end
				3'd6: begin
					if(map[bit_p + 1] == 0 && map[bit_p + 6] == 0 && map[bit_p + 7] == 0 && map[bit_p + 12] == 0) begin
						row <= row - 1;
					end
					else row <= row + 1;
				end
				3'd7: begin
					if(map[bit_p] == 0 && map[bit_p + 1] == 0 && map[bit_p + 7] == 0 && map[bit_p + 8] == 0) begin
						row <= row - 1;
					end
					else row <= row + 1;
				end
        endcase
	end
end*/

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        row <= 12;
    end
    else if (current_state == OUT) begin
        row <= 12;
    end
    else if (current_state == CAL) begin
        if (condition_precalculated) begin
            row <= row - 1;
        end
        else begin
            row <= row + 1;
        end
    end
end



always @(*) begin
	if (next_state == CAL) begin
        case (tetrominoes_in)
            3'd0,3'd5: condition_precalculated = (map[bit_p] == 0 && map[bit_p + 1] == 0);
            3'd1: condition_precalculated = (map[bit_p] == 0);
            3'd2: condition_precalculated = (map[bit_p] == 0 && map[bit_p + 1] == 0 && map[bit_p + 2] == 0 && map[bit_p + 3] == 0);
            3'd3: condition_precalculated = (map[bit_p + 1] == 0 && map[bit_p + 12] == 0);
            3'd4: condition_precalculated = (map[bit_p] == 0 && map[bit_p + 7] == 0 && map[bit_p + 8] == 0);
            //3'd5: condition_precalculated = (map[bit_p] == 0 && map[bit_p + 1] == 0);
            3'd6: condition_precalculated = (map[bit_p + 1] == 0 && map[bit_p + 6] == 0);
            3'd7: condition_precalculated = (map[bit_p] == 0 && map[bit_p + 1] == 0 && map[bit_p + 8] == 0);
            default: condition_precalculated = 0;
        endcase
    end
	else condition_precalculated = 0;
end

/*always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        row <= 12;
    end
    else if (current_state == OUT) begin
        row <= 12;
    end
    else if (current_state == CAL) begin
        case (tetrominoes_in)
            3'd0: if (map[72+position_in] == 1 || map[72+position_in]== 1)row <= 13;
				  else if (map[66+position_in] == 1 || map[66+position_in]== 1)row <= 12;
				  else if (map[60+position_in] == 1 || map[60+position_in]== 1)row <= 11;
				  else if (map[67+position_in] == 1 || map[67+position_in]== 1)row <= 10;
				  else if (map[67+position_in] == 1 || map[67+position_in]== 1)row <= 9;
				  else if (map[67+position_in] == 1 || map[67+position_in]== 1)row <= 8;
				  else if (map[67+position_in] == 1 || map[67+position_in]== 1)row <= 7;
				  else if (map[67+position_in] == 1 || map[67+position_in]== 1)row <= 6;
				  else if (map[67+position_in] == 1 || map[67+position_in]== 1)row <= 5;
				  else if (map[67+position_in] == 1 || map[67+position_in]== 1)row <= 4;
				  else if (map[67+position_in] == 1 || map[67+position_in]== 1)row <= 3;
				  else if (map[67+position_in] == 1 || map[67+position_in]== 1)row <= 2;
			3'd1: condition_precalculated = (map[67+position_in] == 1 || map[67+position_in]== 0);
            3'd2: condition_precalculated = (map[bit_p] == 0 && map[bit_p + 1] == 0 && map[bit_p + 2] == 0 && map[bit_p + 3] == 0);
            3'd3: condition_precalculated = (map[bit_p + 1] == 0 && map[bit_p + 7] == 0 && map[bit_p + 12] == 0 && map[bit_p + 13] == 0);
            3'd4: condition_precalculated = (map[bit_p] == 0 && map[bit_p + 6] == 0 && map[bit_p + 7] == 0 && map[bit_p + 8] == 0);
            3'd5: condition_precalculated = (map[bit_p] == 0 && map[bit_p + 1] == 0 && map[bit_p + 6] == 0 && map[bit_p + 12] == 0);
            3'd6: condition_precalculated = (map[bit_p + 1] == 0 && map[bit_p + 6] == 0 && map[bit_p + 7] == 0 && map[bit_p + 12] == 0);
            3'd7: condition_precalculated = (map[bit_p] == 0 && map[bit_p + 1] == 0 && map[bit_p + 7] == 0 && map[bit_p + 8] == 0);
            default: condition_precalculated = 0;
        endcase
    end
end*/



/*always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		
	end
	else if (map[row*6] && map[row*6] && map[row*6]  && map[row*6]  && map[row*6])


	if(map[row*6:row*6+6] == 111111 &&)
end*/

assign bit_p = row * 6 + position_in;

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		map <= 96'b111111;
	end
	else if(next_state==IDLE)begin
		map <= 96'b111111;
	end
	else if((current_state==CAL) && (row==row_seq+1))begin
		if (tetrominoes_in == 3'd0) begin
			map[bit_p] <= 1;
			map[bit_p + 1] <= 1;
			map[bit_p + 6] <= 1;
			map[bit_p + 7] <= 1;
		end
		else if (tetrominoes_in == 3'd1) begin
			map[bit_p] <= 1;
			map[bit_p + 6] <= 1;
			map[bit_p + 12] <= 1;
			map[bit_p + 18] <= 1;
		end
		else if (tetrominoes_in == 3'd2) begin
			map[bit_p] <= 1;
			map[bit_p + 1] <= 1;
			map[bit_p + 2] <= 1;
			map[bit_p + 3] <= 1;
		end
		else if (tetrominoes_in == 3'd3) begin
			map[bit_p + 1] <= 1;
			map[bit_p + 7] <= 1;
			map[bit_p + 12] <= 1;
			map[bit_p + 13] <= 1;
		end
		else if (tetrominoes_in == 3'd4) begin
			map[bit_p] <= 1;
			map[bit_p + 6] <= 1;
			map[bit_p + 7] <= 1;
			map[bit_p + 8] <= 1;
		end
		else if (tetrominoes_in == 3'd5) begin
			map[bit_p] <= 1;
			map[bit_p + 1] <= 1;
			map[bit_p + 6] <= 1;
			map[bit_p + 12] <= 1;
		end
		else if (tetrominoes_in == 3'd6) begin
			map[bit_p + 1] <= 1;
			map[bit_p + 6] <= 1;
			map[bit_p + 7] <= 1;
			map[bit_p + 12] <= 1;
		end
		else if (tetrominoes_in == 3'd7) begin
			map[bit_p] <= 1;
			map[bit_p + 1] <= 1;
			map[bit_p + 7] <= 1;
			map[bit_p + 8] <= 1;
		end
	end
	else if(counter==4)begin
		map[5:0]   <= map2[0];
		map[11:6]  <= map2[1];
		map[17:12] <= map2[2];
		map[23:18] <= map2[3];
		map[29:24] <= map2[4];
		map[35:30] <= map2[5];
		map[41:36] <= map2[6];
		map[47:42] <= map2[7];
		map[53:48] <= map2[8];
		map[59:54] <= map2[9];
		map[65:60] <= map2[10];
		map[71:66] <= map2[11];
		map[77:72] <= map2[12];
		map[83:78] <= map2[13];
		map[89:84] <= map2[14];
		map[95:90] <= map2[15];
		map[101:96] <= map2[16];
	end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		score_A <= 0;
		for(i = 0; i < 21; i = i + 1) begin
                map2[i] <= 0;
            end
	end 
	else if (current_state==IDLE)begin
		score_A <= 0;
		for(i = 16; i < 21; i = i + 1) begin
                map2[i] <= 0;
        end
		map2[16] <= map[101:96];
		map2[15] <= map[95:90];
		map2[14] <= map[89:84];
		map2[13] <= map[83:78];
		map2[12] <= map[77:72];
		map2[11] <= map[71:66];
		map2[10] <= map[65:60];
		map2[9]  <= map[59:54];
		map2[8]  <= map[53:48];
		map2[7]  <= map[47:42];
		map2[6]  <= map[41:36];
		map2[5]  <= map[35:30];
		map2[4]  <= map[29:24];
		map2[3]  <= map[23:18];
		map2[2]  <= map[17:12];
		map2[1]  <= map[11:6];
		map2[0]  <= map[5:0];
    end
	else if (current_state==CAL)begin
		score_A <= score_A;
		for(i = 16; i < 21; i = i + 1) begin
                map2[i] <= 0;
        end
		map2[16] <= map[101:96];
		map2[15] <= map[95:90];
		map2[14] <= map[89:84];
		map2[13] <= map[83:78];
		map2[12] <= map[77:72];
		map2[11] <= map[71:66];
		map2[10] <= map[65:60];
		map2[9]  <= map[59:54];
		map2[8]  <= map[53:48];
		map2[7]  <= map[47:42];
		map2[6]  <= map[41:36];
		map2[5]  <= map[35:30];
		map2[4]  <= map[29:24];
		map2[3]  <= map[23:18];
		map2[2]  <= map[17:12];
		map2[1]  <= map[11:6];
		map2[0]  <= map[5:0];
    end
	else if (counter == 3 && eli_row != 50) begin
		if (map_judge==1)begin//1
			score_A <= score_A+4;
			map2[eli_row] <= map2[eli_row + 4];
			map2[eli_row + 1] <= map2[eli_row + 5];
			map2[eli_row + 2] <= map2[eli_row + 6];
			map2[eli_row + 3] <= map2[eli_row + 7];
			map2[eli_row + 4] <= map2[eli_row + 8];
			map2[eli_row + 5] <= map2[eli_row + 9];
			map2[eli_row + 6] <= map2[eli_row + 10];
			map2[eli_row + 7] <= map2[eli_row + 11];
			map2[eli_row + 8] <= map2[eli_row + 12];
			map2[eli_row + 9] <= map2[eli_row + 13];
			map2[eli_row + 10] <= map2[eli_row + 14];
			map2[eli_row + 11] <= map2[eli_row + 15];
		end
		else if (map_judge==2) begin//2
			score_A <= score_A+3;
			map2[eli_row] <= map2[eli_row + 1];
			map2[eli_row + 1] <= map2[eli_row + 4];
			map2[eli_row + 2] <= map2[eli_row + 5];
			map2[eli_row + 3] <= map2[eli_row + 6];
			map2[eli_row + 4] <= map2[eli_row + 7];
			map2[eli_row + 5] <= map2[eli_row + 8];
			map2[eli_row + 6] <= map2[eli_row + 9];
			map2[eli_row + 7] <= map2[eli_row + 10];
			map2[eli_row + 8] <= map2[eli_row + 11];
			map2[eli_row + 9] <= map2[eli_row + 12];
			map2[eli_row + 10] <= map2[eli_row + 13];
			map2[eli_row + 11] <= map2[eli_row + 14];
		end
		else if (map_judge==3) begin//3
			score_A <= score_A+3;
			map2[eli_row] <= map2[eli_row + 2];
			map2[eli_row + 1] <= map2[eli_row + 4];
			map2[eli_row + 2] <= map2[eli_row + 5];
			map2[eli_row + 3] <= map2[eli_row + 6];
			map2[eli_row + 4] <= map2[eli_row + 7];
			map2[eli_row + 5] <= map2[eli_row + 8];
			map2[eli_row + 6] <= map2[eli_row + 9];
			map2[eli_row + 7] <= map2[eli_row + 10];
			map2[eli_row + 8] <= map2[eli_row + 11];
			map2[eli_row + 9] <= map2[eli_row + 12];
			map2[eli_row + 10] <= map2[eli_row + 13];
			map2[eli_row + 11] <= map2[eli_row + 14];
		end
		else if (map_judge==4) begin//4
			score_A <= score_A+3;
			map2[eli_row] <= map2[eli_row + 3];
			map2[eli_row + 1] <= map2[eli_row + 4];
			map2[eli_row + 2] <= map2[eli_row + 5];
			map2[eli_row + 3] <= map2[eli_row + 6];
			map2[eli_row + 4] <= map2[eli_row + 7];
			map2[eli_row + 5] <= map2[eli_row + 8];
			map2[eli_row + 6] <= map2[eli_row + 9];
			map2[eli_row + 7] <= map2[eli_row + 10];
			map2[eli_row + 8] <= map2[eli_row + 11];
			map2[eli_row + 9] <= map2[eli_row + 12];
			map2[eli_row + 10] <= map2[eli_row + 13];
			map2[eli_row + 11] <= map2[eli_row + 14];
		end
		else if (map_judge==5) begin//5
			score_A <= score_A+2;
			map2[eli_row] <= map2[eli_row + 1];
			map2[eli_row + 1] <= map2[eli_row + 2];
			map2[eli_row + 2] <= map2[eli_row + 4];
			map2[eli_row + 3] <= map2[eli_row + 5];
			map2[eli_row + 4] <= map2[eli_row + 6];
			map2[eli_row + 5] <= map2[eli_row + 7];
			map2[eli_row + 6] <= map2[eli_row + 8];
			map2[eli_row + 7] <= map2[eli_row + 9];
			map2[eli_row + 8] <= map2[eli_row + 10];
			map2[eli_row + 9] <= map2[eli_row + 11];
			map2[eli_row + 10] <= map2[eli_row + 12];
			map2[eli_row + 11] <= map2[eli_row + 13];
		end

		else if (map_judge==6) begin//6
			score_A <= score_A+2;
			map2[eli_row] <= map2[eli_row + 1];
			map2[eli_row + 1] <= map2[eli_row + 3];
			map2[eli_row + 2] <= map2[eli_row + 4];
			map2[eli_row + 3] <= map2[eli_row + 5];
			map2[eli_row + 4] <= map2[eli_row + 6];
			map2[eli_row + 5] <= map2[eli_row + 7];
			map2[eli_row + 6] <= map2[eli_row + 8];
			map2[eli_row + 7] <= map2[eli_row + 9];
			map2[eli_row + 8] <= map2[eli_row + 10];
			map2[eli_row + 9] <= map2[eli_row + 11];
			map2[eli_row + 10] <= map2[eli_row + 12];
			map2[eli_row + 11] <= map2[eli_row + 13];
		end
		else if (map_judge==7) begin//7
			score_A <= score_A+2;
			map2[eli_row] <= map2[eli_row + 2];
			map2[eli_row + 1] <= map2[eli_row + 3];
			map2[eli_row + 2] <= map2[eli_row + 4];
			map2[eli_row + 3] <= map2[eli_row + 5];
			map2[eli_row + 4] <= map2[eli_row + 6];
			map2[eli_row + 5] <= map2[eli_row + 7];
			map2[eli_row + 6] <= map2[eli_row + 8];
			map2[eli_row + 7] <= map2[eli_row + 9];
			map2[eli_row + 8] <= map2[eli_row + 10];
			map2[eli_row + 9] <= map2[eli_row + 11];
			map2[eli_row + 10] <= map2[eli_row + 12];
			map2[eli_row + 11] <= map2[eli_row + 13];
		end
		else begin
			score_A <= score_A+1;
			map2[eli_row] <= map2[eli_row + 1];
			map2[eli_row + 1] <= map2[eli_row + 2];
			map2[eli_row + 2] <= map2[eli_row + 3];
			map2[eli_row + 3] <= map2[eli_row + 4];
			map2[eli_row + 4] <= map2[eli_row + 5];
			map2[eli_row + 5] <= map2[eli_row + 6];
			map2[eli_row + 6] <= map2[eli_row + 7];
			map2[eli_row + 7] <= map2[eli_row + 8];
			map2[eli_row + 8] <= map2[eli_row + 9];
			map2[eli_row + 9] <= map2[eli_row + 10];
			map2[eli_row + 10] <= map2[eli_row + 11];
			map2[eli_row + 11] <= map2[eli_row + 12];
		end
	end
	else if (current_state == OUT || counter == 3 || counter == 2 || counter == 1) begin
		for(i = 0; i < 21; i = i + 1) begin
                map2[i] <= map2[i];
            end
    end
	else begin
		for(i = 16; i < 21; i = i + 1) begin
                map2[i] <= 0;
        end
		map2[16] <= map[101:96];
		map2[15] <= map[95:90];
		map2[14] <= map[89:84];
		map2[13] <= map[83:78];
		map2[12] <= map[77:72];
		map2[11] <= map[71:66];
		map2[10] <= map[65:60];
		map2[9]  <= map[59:54];
		map2[8]  <= map[53:48];
		map2[7]  <= map[47:42];
		map2[6]  <= map[41:36];
		map2[5]  <= map[35:30];
		map2[4]  <= map[29:24];
		map2[3]  <= map[23:18];
		map2[2]  <= map[17:12];
		map2[1]  <= map[11:6];
		map2[0]  <= map[5:0];
    end
end


always@(posedge clk or negedge rst_n)begin
	if(!rst_n) map_judge<=0;
	else if (counter == 2 && eli_row != 50) begin
	if (map2[eli_row + 1] == 6'b111111 && map2[eli_row + 2] == 6'b111111 && map2[eli_row + 3] == 6'b111111)begin
		 map_judge<=1;
	end
	else if (map2[eli_row + 2] == 6'b111111 && map2[eli_row + 3] == 6'b111111)begin
		 map_judge<=2;
	end
	else if(map2[eli_row + 1] == 6'b111111 && map2[eli_row + 3] == 6'b111111)begin
		 map_judge<=3;
	end
	else if (map2[eli_row + 1] == 6'b111111 && map2[eli_row + 2] == 6'b111111)begin
		 map_judge<=4;
	end
	else if(map2[eli_row + 3] == 6'b111111)begin
		 map_judge<=5;
	end
	else if(map2[eli_row + 2] == 6'b111111) begin
		 map_judge<=6;
	end
	else if(map2[eli_row + 1] == 6'b111111) begin
		 map_judge<=7;
	end
	else map_judge<=0;
	end 
end



always@(posedge clk or negedge rst_n)begin
	if (!rst_n) begin
		eli_row <= 0;
	end
	else if (row_A>=0) begin
		if (map2[row_A] == 6'b111111) eli_row <= row_A;
		else if (map2[row_A+1] == 6'b111111) eli_row <= row_A + 1;
		else if (map2[row_A+2] == 6'b111111) eli_row <= row_A + 2;
		else if (map2[row_A+3] == 6'b111111) eli_row <= row_A + 3;
		else eli_row <= 50;
	end
end


always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
    	score_valid <= 0;
	end
    else if(count_out==1)begin
    	score_valid <= 1;
	end
	else begin
    	score_valid <= 0;
	end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
    	tetris_valid <= 0;
	end
	else if(next_state==IDLE)begin
    	tetris_valid <= 0;
	end
    else if(current_state==OUT && map[101:78]!=0 && count_out==1)begin
    	tetris_valid <= 1;
	end
	else if(current_state==OUT && count_16_s==15 && count_out==1)begin
    	tetris_valid <= 1;
	end
	else tetris_valid <= 0;
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
    	score <= 0;
	end
	else if(next_state==IDLE || next_state==CAL)begin
    	score <= 0;
	end
    else if(count_out==1)begin
    	score <= score_A;
	end
	else score <= 0;
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
    	fail <= 0;
	end
	else if(next_state==IDLE)begin
    	fail <= 0;
	end
	else if(current_state==OUT && map[101:78]!=0 && count_out==1)begin
    	fail <= 1;
	end
	else fail  <= 0;
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
    	tetris <= 0;
	end
	else if(next_state==IDLE)begin
    	tetris <= 0;
	end
    else if(current_state==OUT && map[101:78]!=0 && count_out==1)begin
    	tetris <= map[77:6];
	end
	else if(current_state==OUT && count_16_s==15 && count_out==1)begin
    	tetris <= map[77:6];
	end
	else tetris <= 0;
end



endmodule