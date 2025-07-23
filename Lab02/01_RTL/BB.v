module BB(
    //Input Ports
    input clk,
    input rst_n,
    input in_valid,
    input [1:0] inning,   // Current inning number
    input half,           // 0: top of the inning, 1: bottom of the inning
    input [2:0] action,   // Action code

    //Output Ports
    output reg out_valid,  // Result output valid
    output reg [7:0] score_A,  // Score of team A (guest team)
    output reg [7:0] score_B,  // Score of team B (home team)
    output reg [1:0] result    // 0: Team A wins, 1: Team B wins, 2: Darw
);

//==============================================//
//             Action Memo for Students         //
// Action code interpretation:
// 3’d0: Walk (BB)
// 3’d1: 1H (single hit)
// 3’d2: 2H (double hit)
// 3’d3: 3H (triple hit)
// 3’d4: HR (home run)
// 3’d5: Bunt (short hit)
// 3’d6: Ground ball
// 3’d7: Fly ball
//==============================================//

//==============================================//
//             Parameter and Integer            //
//==============================================//
// State declaration for FSM
// Example: parameter IDLE = 3'b000;
/*
reg [1:0] state_cs, state_ns;
parameter S_IDLE       = 2'd0;
parameter S_INPUT    = 2'd1;
parameter S_OUT      = 2'd2;
integer i ;
*/

//==============================================//
//                 reg declaration              //
//==============================================//
reg in_valid_d , half_d ;
reg [2:0] act_s , act_c;
reg [2:0] bases_s,bases_c;
reg [1:0] out_s ,out_c ;
reg [3:0] teamA_s,teamA_c;
reg [3:0] teamB_s,teamB_c;
reg [2:0] score_c ,score_s ;
reg [1:0] inning_d , inning_d_c;

//==============================================//
//             Current State Block              //
//==============================================//
/*
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin 
		state_cs <= S_IDLE;
	end
	else begin 
		state_cs <= state_ns;
	end
end

always@(*) begin
	case(state_cs)
		S_IDLE:
		begin
			if(in_valid)
				state_ns = S_INPUT;
			else
				state_ns = S_IDLE;
		end
		
		S_INPUT:
		begin
			if(!in_valid)
				state_ns = S_OUT;
			else
				state_ns = S_INPUT;
		end		
		
		S_OUT:
		begin
            state_ns = S_IDLE;
		end
		default:
			state_ns = S_IDLE;
	endcase
end
*/

//==============================================//
//              Next State Block                //
//==============================================//

//=======================================================
//                   SEQ
//=======================================================
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		bases_s	 <= 0 ;
	end
	else begin
		bases_s	 <= bases_c	 	 ;	
	end    
end


always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		in_valid_d <= 0 ;
	end
	else in_valid_d <= in_valid ;
end



always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		half_d <= 0 ;
	end
	else if ( in_valid) begin
        half_d <= half ;
    end
    else half_d <= 0 ;
end


always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		teamA_s <= 0 ;
		teamB_s <= 0 ;
	end
	
	else if (out_valid) begin
		teamA_s <= 0 ;
		teamB_s <= 0 ;		
	end
	
	else begin
		teamA_s <= teamA_c ;
		teamB_s <= teamB_c ;		
	end
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		score_s <= 0 ; 
	end
	else score_s <= score_c ;
end


always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		out_s <= 0 ;
	end
	else out_s <= out_c ;
end

/*
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		inning_d <= 0 ;
	end
	else inning_d <= inning_d_c ;
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		act_s <= 0 ;
	end
	else act_s <= act_c ;
end
*/


always @(posedge clk ) begin
	inning_d <= inning_d_c ;
	act_s <= act_c ;
end



//=======================================================
//                   COM
//=======================================================
always @(*) begin
	if (in_valid) begin
		act_c = action ;
	end
	else act_c = 0 ;
end

always @(*) begin
	if (in_valid) begin
		inning_d_c = inning ;
	end
	else inning_d_c = 0 ;
end




always @(*) begin
    if ((act_s == 3'd7 || act_s == 3'd6 ) && out_s == 2) begin
		if (half_d == 0) begin
			teamA_c = teamA_s + score_s ;
			teamB_c = teamB_s ;
		end
		else if (half_d == 1 && inning_d < 3 || (half_d == 1 && inning_d == 3 && teamA_s >= teamB_s)) begin
        teamA_c = teamA_s ;
		teamB_c = teamB_s + score_s ;
		end
		else begin
        	teamA_c = teamA_s ;
			teamB_c = teamB_s ;			
		end 
    end
    else if (act_s ==3'd6 && bases_s[0] == 1 && out_s == 1) begin
		if (half_d == 0) begin
			teamA_c = teamA_s + score_s ;
			teamB_c = teamB_s ;
		end
		else if (half_d == 1 && inning_d < 3 || (half_d == 1 && inning_d == 3 && teamA_s >= teamB_s)) begin
        	teamA_c = teamA_s ;
			teamB_c = teamB_s + score_s ;
		end
		else begin
        	teamA_c = teamA_s ;
			teamB_c = teamB_s ;			
		end 
    end
    else begin 
        teamA_c = teamA_s ;
		teamB_c = teamB_s ;
    end 
end


reg [1:0] source_base;
always @(*) begin
	source_base = bases_s[2] + bases_s[1] + bases_s[0] ;
end

/*always @(*) begin
	if ( in_valid_d) begin
		if (act_s == 3'd0 ) begin
			if (bases_s == 3'b111) begin
				bases_c =  bases_s  ;
				out_c   = out_s     ;
				score_c = score_s + 1   ;	
			end
			else if (bases_s[0] == 1'b0 ) begin
				bases_c[0] =  1 ;
				bases_c[1] =  bases_s[1] ;
				bases_c[2] =  bases_s[2] ;
				out_c   = out_s      ;
				score_c = score_s    ;					
			end
			else begin
				bases_c[0] =  1 ;
				bases_c[1] =  bases_s[0] ;
				bases_c[2] =  bases_s[1] ;
				out_c   = out_s     ;
				score_c = score_s    ;	
			end
		end


		else if (act_s == 3'd1 ) begin
			if (out_s == 0 || out_s == 1) begin
				bases_c[0] =  1 ;
				bases_c[1] =  bases_s[0] ;
				bases_c[2] =  bases_s[1] ;
				out_c   = out_s     ;
				if (bases_s[2] == 1) begin
					score_c = score_s + 1  ;
				end
				else score_c = score_s   ;			
			end
			else begin
				bases_c[0] =  1 ;
				bases_c[1] =  0 ;
				bases_c[2] =  bases_s[0] ;
				out_c   = out_s     ;
				if (bases_s[2] == 1 && bases_s[1] == 1 ) begin
					score_c = score_s + 2  ;
				end
				else if (bases_s[2] == 1 || bases_s[1] == 1) begin
					score_c = score_s + 1  ;
				end
				else score_c = score_s   ;	
			end
		end
		
		else if (act_s == 3'd2) begin
			if (out_s == 0 || out_s == 1) begin
				bases_c[0] =  0 ;
				bases_c[1] =  1 ;
				bases_c[2] =  bases_s[0] ;
				out_c   = out_s     ;
				case (bases_s[2:1])
					2'b00: score_c = score_s   ;
					2'b01,2'b10: score_c = score_s + 1  ;
					default: score_c = score_s + 2  ; 
				endcase
			end
			else begin
				bases_c[0] =  0 ;
				bases_c[1] =  0 ;
				bases_c[2] =  1 ;
				out_c   = out_s     ;
				case (bases_s)
					3'b000: score_c = score_s   ;
					3'b001,3'b010,3'b100 : score_c = score_s + 1  ;
					3'b011,3'b110,3'b101 : score_c = score_s + 2  ;
					default: score_c = score_s + 3  ; 
				endcase
			end
		end


		else if (act_s == 3'd3) begin
			if (bases_s == 3'b000) begin  ///000
			///100
				bases_c = 3'b100;
				out_c   = out_s     ;
				score_c = score_s   ;
			end
			else if (bases_s == 3'b001) begin ///001
			///100
				bases_c = 3'b100;
				out_c   = out_s     ;
				score_c = score_s + 1  ;
			end
			else if (bases_s == 3'b011) begin ///011
			//100
				bases_c = 3'b100;
				score_c = score_s + 2   ;
				out_c   = out_s     ;
			end
			else if (bases_s == 3'b111) begin ///111
			//100
				bases_c = 3'b100;
				score_c = score_s + 3 ;
				out_c   = out_s     ;
			end
			else if (bases_s == 3'b010) begin ///010
			//100
				bases_c = 3'b100;
				score_c = score_s + 1 ;
				out_c   = out_s     ;
			end
			else if (bases_s == 3'b110) begin ///110
			///100
				bases_c = 3'b100;
				score_c = score_s + 2 ;
				out_c   = out_s     ;
			end
			else if (bases_s == 3'b101) begin ///101
			//100
				bases_c = 3'b100;
				score_c = score_s + 2 ;
				out_c   = out_s     ;
			end
			else if (bases_s == 3'b100) begin ///100
			//
				bases_c = bases_s ;			
				score_c = score_s + 1 ;
				out_c   = out_s     ;
			end
			else begin
				bases_c = bases_s ;
				out_c   = out_s     ;
				score_c = score_s   ;
			end		
		end
		
	
		else if (act_s == 3'd4 ) begin
				bases_c = 3'b000 ;
				out_c   = out_s     ;			
			case (bases_s)
				3'b000:	score_c = score_s + 1   ;
				3'b001,3'b010,3'b100: score_c = score_s + 2   ;
				3'b110,3'b011,3'b101: score_c = score_s + 3   ; 
				default:score_c = score_s + 4   ;    
			endcase		
		end
			
		else if (act_s == 3'd5) begin
			out_c = out_s + 1 ;
			bases_c = bases_s << 1 ;			
			if (bases_s[2] == 1) begin
				score_c = score_s + 1 ;				
			end
			else score_c = score_s	;
		end
		
		else if (act_s == 3'd6) begin
			if (out_s == 0) begin
				bases_c[1:0] = 2'b00 ;
				bases_c[2] = bases_s[1] ;
				if (bases_s[0] == 0) begin
					out_c = out_s + 1 ;
					if (bases_s[2] == 1) begin
						score_c = score_s + 1 ;
					end
					else score_c = score_s ;
				end
				else begin
					out_c = out_s + 2 ;
					if (bases_s[2] == 1) begin
						score_c = score_s + 1 ;
					end
					else score_c = score_s ;
				end 
			end
			else if (out_s == 1) begin
				if (bases_s[0] == 0) begin
				bases_c[1:0] = 2'b00 ;
				bases_c[2] = bases_s[1] ;
					out_c = out_s + 1 ;
					if (bases_s[2] == 1) begin
						score_c = score_s + 1 ;
					end
					else score_c = score_s ;
				end
				else begin
					bases_c = 3'b000;
    	            out_c = 0     ;
    	            score_c = 0   ; 	
				end
			end
			else begin
				bases_c = 3'b000;
				out_c   = 0   ;
				score_c = 0   ;
			end
		end

		else if (act_s == 3'd7) begin
			if (out_s == 0 || out_s == 1) begin
				bases_c[1:0] = bases_s[1:0] ;
				bases_c[2] = 0 ;
				out_c   = out_s  + 1   ;
				if (bases_s[2] == 1) begin
					score_c = score_s + 1 ;
				end
				else score_c = score_s  ;	
			end
			else begin
				bases_c = 3'b000;
    	        out_c = 0     ;
    	        score_c = 0   ; 		
			end		
		end
	end
	else begin
		bases_c = bases_s ;
		out_c   = out_s     ;
		score_c = score_s   ;			
	end
end*/
/*always @(*) begin
	if ( in_valid_d) begin
		if (act_s == 3'd0 ) begin
			if (bases_s == 3'b111) begin
				score_c = score_s + 1   ;	
			end
			else if (bases_s[0] == 1'b0 ) begin
				score_c = score_s    ;					
			end
			else begin
				score_c = score_s    ;	
			end
		end

		else if (act_s == 3'd1 ) begin
			if (out_s == 0 || out_s == 1) begin
				if (bases_s[2] == 1) begin
					score_c = score_s + 1  ;
				end
				else score_c = score_s   ;			
			end
			else begin
				if (bases_s[2] == 1 && bases_s[1] == 1 ) begin
					score_c = score_s + 2  ;
				end
				else if (bases_s[2] == 1 || bases_s[1] == 1) begin
					score_c = score_s + 1  ;
				end
				else score_c = score_s   ;	
			end
		end
		
		else if (act_s == 3'd2) begin
			if (out_s == 0 || out_s == 1) begin
				case (bases_s[2:1])
					2'b00: score_c = score_s   ;
					2'b01,2'b10: score_c = score_s + 1  ;
					default: score_c = score_s + 2  ; 
				endcase
			end
			else begin
				case (bases_s)
					3'b000: score_c = score_s   ;
					3'b001,3'b010,3'b100 : score_c = score_s + 1  ;
					3'b011,3'b110,3'b101 : score_c = score_s + 2  ;
					default: score_c = score_s + 3  ; 
				endcase
			end
		end


		else if (act_s == 3'd3) begin
			if (bases_s == 3'b000) begin  ///000
			///100
				score_c = score_s   ;
			end
			else if (bases_s == 3'b001) begin ///001
			///100
				score_c = score_s + 1  ;
			end
			else if (bases_s == 3'b011) begin ///011
			//100
				score_c = score_s + 2   ;
			end
			else if (bases_s == 3'b111) begin ///111
			//100
				score_c = score_s + 3 ;
			end
			else if (bases_s == 3'b010) begin ///010
			//100
				score_c = score_s + 1 ;
			end
			else if (bases_s == 3'b110) begin ///110
			///100
				score_c = score_s + 2 ;
			end
			else if (bases_s == 3'b101) begin ///101
			//100
				score_c = score_s + 2 ;
			end
			else if (bases_s == 3'b100) begin ///100
			//		
				score_c = score_s + 1 ;
			end
			else begin
				score_c = score_s   ;
			end		
		end
		
		else if (act_s == 3'd4 ) begin			
			case (bases_s)
				3'b000:	score_c = score_s + 1   ;
				3'b001,3'b010,3'b100: score_c = score_s + 2   ;
				3'b110,3'b011,3'b101: score_c = score_s + 3   ; 
				default:score_c = score_s + 4   ;    
			endcase		
		end
			
		else if (act_s == 3'd5) begin			
			if (bases_s[2] == 1) begin
				score_c = score_s + 1 ;				
			end
			else score_c = score_s	;
		end
		
		else if (act_s == 3'd6) begin
			if (out_s == 0) begin
				if (bases_s[0] == 0) begin
					if (bases_s[2] == 1) begin
						score_c = score_s + 1 ;
					end
					else score_c = score_s ;
				end
				else begin
					if (bases_s[2] == 1) begin
						score_c = score_s + 1 ;
					end
					else score_c = score_s ;
				end 
			end
			else if (out_s == 1) begin
				if (bases_s[0] == 0) begin
					if (bases_s[2] == 1) begin
						score_c = score_s + 1 ;
					end
					else score_c = score_s ;
				end
				else begin
    	            score_c = 0   ; 	
				end
			end
			else begin
				score_c = 0   ;
			end
		end

		else if (act_s == 3'd7) begin
			if (out_s == 0 || out_s == 1) begin
				if (bases_s[2] == 1) begin
					score_c = score_s + 1 ;
				end
				else score_c = score_s  ;	
			end
			else begin
    	        score_c = 0   ; 		
			end		
		end
	end
	else begin
		score_c = score_s   ;			
	end
end*/

always @(*) begin
	if ( in_valid_d) begin
			if (act_s == 3'd0 && bases_s == 3'b111) begin
					score_c = score_s + 1   ;	
			end

			else if (act_s == 3'd1 ) begin
				if (out_s == 0 || out_s == 1) begin
					if (bases_s[2] == 1) begin
						score_c = score_s + 1  ;
					end
					else score_c = score_s   ;			
				end
				else begin
					if (bases_s[2] == 1 && bases_s[1] == 1 ) begin
						score_c = score_s + 2  ;
					end
					else if (bases_s[2] == 1 || bases_s[1] == 1) begin
						score_c = score_s + 1  ;
					end
					else score_c = score_s   ;	
				end
			end
		
			else if (act_s == 3'd2) begin
				if (out_s == 0 || out_s == 1) begin
					case (bases_s[2:1])
						2'b00: score_c = score_s   ;
						2'b01,2'b10: score_c = score_s + 1  ;
						default: score_c = score_s + 2  ; 
					endcase
				end
				else begin
					case (bases_s)
						3'b000: score_c = score_s   ;
						3'b001,3'b010,3'b100 : score_c = score_s + 1  ;
						3'b011,3'b110,3'b101 : score_c = score_s + 2  ;
						default: score_c = score_s + 3  ; 
					endcase
				end
			end


			else if (act_s == 3'd3 && bases_s == 3'b000) begin
					score_c = score_s   ;
			end
			else if ((act_s == 3'd3 &&(bases_s == 3'b001 || bases_s == 3'b010 || bases_s == 3'b100)) || (act_s == 3'd5 && (bases_s[2] == 1)) || (act_s == 3'd4 && bases_s == 3'b000)) begin 
					score_c = score_s + 1  ;
			end
			else if ((act_s == 3'd3 &&(bases_s == 3'b011 || bases_s == 3'b110 || bases_s == 3'b101)) || (act_s == 3'd4 &&(bases_s == 3'b001 || bases_s == 3'b010 || bases_s == 3'b100))) begin
					score_c = score_s + 2   ;
			end
			else if (act_s == 3'd3 &&(bases_s == 3'b111) || (act_s == 3'd4 &&(bases_s == 3'b110 || bases_s == 3'b011 || bases_s == 3'b101))) begin 
					score_c = score_s + 3 ;
			end
		
		
			else if (act_s == 3'd4 &&(bases_s == 3'b111)) begin			
					score_c = score_s + 4   ;    	
			end
		
		else if (act_s == 3'd6) begin
			if (out_s == 0) begin
				if (bases_s[0] == 0) begin
					if (bases_s[2] == 1) begin
						score_c = score_s + 1 ;
					end
					else score_c = score_s ;
				end
				else begin
					if (bases_s[2] == 1) begin
						score_c = score_s + 1 ;
					end
					else score_c = score_s ;
				end 
			end
			else if (out_s == 1) begin
				if (bases_s[0] == 0) begin
					if (bases_s[2] == 1) begin
						score_c = score_s + 1 ;
					end
					else score_c = score_s ;
				end
				else begin
    	            score_c = 0   ; 	
				end
			end
			else begin
				score_c = 0   ;
			end
		end

		else if (act_s == 3'd7) begin
			if (out_s == 0 || out_s == 1) begin
				if (bases_s[2] == 1) begin
					score_c = score_s + 1 ;
				end
				else score_c = score_s  ;	
			end
			else begin
    	        score_c = 0   ; 		
			end		
		end
		else score_c = score_s   ;
	end
	else begin
		score_c = score_s   ;			
	end
end

/*always @(*) begin
	if (bases_s == 3'b111 && act_s == 4) begin
		score_c = score_s + 4 ;
	end
	else if ((bases_s == 3'b111 && (act_s == 3 || (act_s ==2 && out_s==2))) || (act_s == 4 && (bases_s == 3'b110 || bases_s == 3'b101 || bases_s == 3'b011))) begin
		score_c = score_s + 3 ;
	end
	else if (((bases_s == 3'b110 || bases_s == 3'b101 || bases_s == 3'b011) && (act_s == 3 || (act_s ==2 && out_s==2))) || ((bases_s == 3'b011) && (act_s == 1 && out_s == 2))||(act_s == 4 && (bases_s == 3'b001|| bases_s == 3'b010 || bases_s == 3'b100))) begin
		score_c = score_s + 2 ;
	end
	else if ((bases_s == 3'b100 || bases_s == 3'b010 || bases_s == 3'b001) && (act_s == 3 || (act_s ==2 && out_s==2)))begin
		score_c = score_s + 1 ;
	end
	else score_c = score_s ;
end
*/

always @(*) begin
	if ( in_valid_d) begin
		if (act_s == 3'd0 ) begin
			if (bases_s == 3'b111) begin
				bases_c =  bases_s  ;
				out_c   = out_s     ;
			end
			else if (bases_s[0] == 1'b0 ) begin
				bases_c[0] =  1 ;
				bases_c[1] =  bases_s[1] ;
				bases_c[2] =  bases_s[2] ;
				out_c   = out_s      ;				
			end
			else begin
				bases_c[0] =  1 ;
				bases_c[1] =  bases_s[0] ;
				bases_c[2] =  bases_s[1] ;
				out_c   = out_s     ;
			end
		end


		else if (act_s == 3'd1 ) begin
			if (out_s == 0 || out_s == 1) begin
				bases_c[0] =  1 ;
				bases_c[1] =  bases_s[0] ;
				bases_c[2] =  bases_s[1] ;
				out_c   = out_s     ;		
			end
			else begin
				bases_c[0] =  1 ;
				bases_c[1] =  0 ;
				bases_c[2] =  bases_s[0] ;
				out_c   = out_s     ;

			end
		end
		
		else if (act_s == 3'd2) begin
			if (out_s == 0 || out_s == 1) begin
				bases_c[0] =  0 ;
				bases_c[1] =  1 ;
				bases_c[2] =  bases_s[0] ;
				out_c   = out_s     ;
			end
			else begin
				bases_c[0] =  0 ;
				bases_c[1] =  0 ;
				bases_c[2] =  1 ;
				out_c   = out_s     ;
			end
		end


		else if (act_s == 3'd3) begin
			if (bases_s == 3'b000) begin  ///000
			///100
				bases_c = 3'b100;
				out_c   = out_s     ;
			end
			else if (bases_s == 3'b001) begin ///001
			///100
				bases_c = 3'b100;
				out_c   = out_s     ;
			end
			else if (bases_s == 3'b011) begin ///011
			//100
				bases_c = 3'b100;
				out_c   = out_s     ;
			end
			else if (bases_s == 3'b111) begin ///111
			//100
				bases_c = 3'b100;
				out_c   = out_s     ;
			end
			else if (bases_s == 3'b010) begin ///010
			//100
				bases_c = 3'b100;
				out_c   = out_s     ;
			end
			else if (bases_s == 3'b110) begin ///110
			///100
				bases_c = 3'b100;
				out_c   = out_s     ;
			end
			else if (bases_s == 3'b101) begin ///101
			//100
				bases_c = 3'b100;
				out_c   = out_s     ;
			end
			else if (bases_s == 3'b100) begin ///100
			//
				bases_c = bases_s ;		
				out_c   = out_s     ;
			end
			else begin
				bases_c = bases_s ;
				out_c   = out_s     ;
			end		
		end
		
		else if (act_s == 3'd4 ) begin
				bases_c = 3'b000 ;
				out_c   = out_s     ;			
		end
			
		else if (act_s == 3'd5) begin
			out_c = out_s + 1 ;
			bases_c = bases_s << 1 ;			
		end
		
		else if (act_s == 3'd6) begin
			if (out_s == 0) begin
				bases_c[1:0] = 2'b00 ;
				bases_c[2] = bases_s[1] ;
				if (bases_s[0] == 0) begin
					out_c = out_s + 1 ;
				end
				else begin
					out_c = out_s + 2 ;
				end 
			end
			else if (out_s == 1) begin
				if (bases_s[0] == 0) begin
				bases_c[1:0] = 2'b00 ;
				bases_c[2] = bases_s[1] ;
					out_c = out_s + 1 ;
				end
				else begin
					bases_c = 3'b000;
    	            out_c = 0     ;	
				end
			end
			else begin
				bases_c = 3'b000;
				out_c   = 0   ;
			end
		end

		else if (act_s == 3'd7) begin
			if (out_s == 0 || out_s == 1) begin
				bases_c[1:0] = bases_s[1:0] ;
				bases_c[2] = 0 ;
				out_c   = out_s  + 1   ;	
			end
			else begin
				bases_c = 3'b000;
    	        out_c = 0     ;		
			end		
		end
	end
	else begin
		bases_c = bases_s ;
		out_c   = out_s     ;		
	end
end


//==============================================//
//                Output Block                  //
//==============================================//
// Decide when to set out_valid high, and output score_A, score_B, and result.
/*
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_valid <= 0 ;     
    end
    else if (state_cs == S_OUT) begin
        out_valid <= 1 ;
    end
    else out_valid <= 0 ;
end
*/
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_valid <= 0 ;     
    end
    else if (!in_valid && in_valid_d) begin
        out_valid <= 1 ;
    end
    else out_valid <= 0 ;
end

/*
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        score_A  = 0 ;
        score_B  = 0 ;
        result   = 0 ;		
	end
	else if (state_cs == S_OUT) begin
        score_A  = teamA_s ;
        score_B  = teamB_s ;
        if (teamA_s > teamB_s) begin
            result  = 0 ; 
        end
        else if (teamA_s < teamB_s) begin
            result  = 1 ; 
        end
        else result = 2 ;      
    end
    else begin
        score_A  = 0 ;
        score_B  = 0 ;
        result   = 0 ;        
    end
end
*/


always @(*) begin
	if (out_valid) begin
        score_A  = teamA_s ;
        score_B  = teamB_s ;
        if (teamA_s > teamB_s) begin
            result  = 0 ; 
        end
        else if (teamA_s < teamB_s) begin
            result  = 1 ; 
        end
        else result = 2 ;      
    end
    else begin
        score_A  = 0 ;
        score_B  = 0 ;
        result   = 0 ;        
    end
end



endmodule
