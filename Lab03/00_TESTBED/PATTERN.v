/**************************************************************************/
// Copyright (c) 2024, OASIS Lab
// MODULE: PATTERN
// FILE NAME: PATTERN.v
// VERSRION: 1.0
// DATE: August 15, 2024
// AUTHOR: Yu-Hsuan Hsu, NYCU IEE
// DESCRIPTION: ICLAB2024FALL / LAB3 / PATTERN
// MODIFICATION HISTORY:
// Date                 Description
// 
/**************************************************************************/

`ifdef RTL
    `define CYCLE_TIME 40.0
`endif
`ifdef GATE
    `define CYCLE_TIME 40.0
`endif

module PATTERN(
	//OUTPUT
	rst_n,
	clk,
	in_valid,
	tetrominoes,
	position,
	//INPUT
	tetris_valid,
	score_valid,
	fail,
	score,
	tetris
);

//---------------------------------------------------------------------
//   PORT DECLARATION          
//---------------------------------------------------------------------
output reg			rst_n, clk, in_valid;
output reg	[2:0]	tetrominoes;
output reg  [2:0]	position;
input 				tetris_valid, score_valid, fail;
input 		[3:0]	score;
input		[71:0]	tetris;

//---------------------------------------------------------------------
//   PARAMETER & INTEGER DECLARATION
//---------------------------------------------------------------------
///////////////////////////////////
//parameter 
parameter pattern_number = 1000;
integer file ;
integer _round_16 ;



/////////////////////////////////////
reg[2:0] _inputertype[999:0][15:0];  ///1000 16
reg[2:0] _inputerpos[999:0][15:0];
reg[2:0] _tetrominoes ;
reg[2:0] _position    ;
reg _fail_out ;


//////////////////////////////////////



integer total_latency;
integer random_delay;
real CYCLE = `CYCLE_TIME;
integer PAT_NUM;
integer i_pat, a,i,j;
integer input_file;
integer latency;


//---------------------------------------------------------------------
//   REG & WIRE DECLARATION
//---------------------------------------------------------------------
reg [2:0] tetrominoes_input,position_input;
reg [2:0] match;
reg [2:0] tetrominoes_in,position_in;
integer RUN;
reg [90:0] map;
reg [90:0] bit_p;
reg [4:0] score_in,line;
reg signed [5:0] row ;
reg fail_out;
//---------------------------------------------------------------------
//  CLOCK
//---------------------------------------------------------------------
always #(CYCLE/2.0) clk = ~clk;

//---------------------------------------------------------------------
//  SIMULATION
//---------------------------------------------------------------------


task clear_signal;
begin
    map [90:0] = 0 ;
    score_in[4:0] = 0 ;
    fail_out = 0 ;
end endtask








initial begin
    pre_task;
	reset_signal_task;
	for (i_pat = 0; i_pat < PAT_NUM; i_pat = i_pat + 1) begin
        clear_signal ;
        for(_round_16 = 0 ; _round_16 < 16 && fail_out == 0 ; _round_16 = _round_16 + 1)begin
            input_task;
            Calculation_task;
            //Check_task ;
            score_valid_low_task;
            tetris_rst;
            score_valid_cycle_task;
            tetris_valid_cycle_task;
        end
	end
	YOU_PASS_task;
	//$finish;
end

/*
initial begin
	input_file=$fopen("../00_TESTBED/input.txt","r");

	reset_signal_task;
    $fscanf(input_file, "%d", PAT_NUM); 
    map = 0 ;
	for (i_pat = 0; i_pat < PAT_NUM; i_pat = i_pat + 1) begin
        $fscanf(input_file, "%d", RUN);	
        //map = 0 ;
        for(i = 0 ; i < 16 ; i=i+1)begin
            input_task;
            score_valid_low_task;
            tetris_rst;
            check_ans_task;
            //check_signals_task;
            score_valid_cycle_task;
            tetris_valid_cycle_task;
            //repeat(1) @(negedge clk);
            //check_ans;
            //repeat($urandom_range(3, 5)) @(negedge clk);
            if(//fail_out==1// map[90:72] !== 12'd0)begin
                for (j = 0 ; j < 16-i-1 ; j=j+1)begin
                $fscanf(input_file, "%d %d\n", tetrominoes_input , position_input); 
                //break;
                end
                map = 0 ;
                break;
            end
        end
        //map = 0 ;
	end
	YOU_PASS_task;
	//$finish;
end*/

/*initial begin
	input_file=$fopen("../00_TESTBED/input.txt","r");
    i=0;
	reset_signal_task;
    $fscanf(input_file, "%d", PAT_NUM); 
	for (i_pat = 0; i_pat < PAT_NUM; i_pat = i_pat + 1) begin
        $fscanf(input_file, "%d", RUN);	
         map = 0 ;
        while(i != 17)begin
            i=i++;
            input_task;
            score_valid_low_task;
            tetris_rst;
            check_ans_task;
            //check_signals_task;
            score_valid_cycle_task;
            tetris_valid_cycle_task;
            //repeat(1) @(negedge clk);
            //check_ans;
            //repeat($urandom_range(3, 5)) @(negedge clk)
            while(fail_out==1)begin
                repeat (16-i)begin
                   $fscanf(input_file, "%d %d", tetrominoes_input , position_input); 
                end
                @(negedge clk);
                j=17;
            end
        end
	end
	YOU_PASS_task;
	//$finish;
end */

task pre_task ;
    integer i ;
    integer j ;
    integer status;
begin
    file = $fopen("../00_TESTBED/input.txt", "r");
    status = $fscanf(file, "%d", PAT_NUM);
    while (!$feof(file)) begin
        status = $fscanf(file, "%d" , i) ;
        if (i < pattern_number) begin
            for ( j = 0 ; j < 16 ; j++) begin
                status = $fscanf(file, "%d %d" , _inputertype[i][j], _inputerpos[i][j]);
            end
        end
    end
end endtask




task reset_signal_task; begin 

        rst_n = 1'b1;
		in_valid = 1'b0;
        tetrominoes = 3'bxxx;
		position = 3'bxxx;
        total_latency = 0;

        force clk = 0;

        // Apply reset
        #(CYCLE/2.0) rst_n = 0;
        //#CYCLE; rst_n = 1'b0; 
        //#CYCLE; rst_n = 1'b1;
		#(100);

        //tetris_valid, score_valid, fail;
		//score;
		//tetris;
        // Check initial conditions
        if (tetris_valid !== 1'b0 || score_valid !== 1'b0 || fail !== 1'b0 || score !== 4'b0 || tetris !== 72'b0) begin
            $display("************************************************************");     
            $display("                     	  SPEC-4 FAIL                         ");
            $display("************************************************************");
            repeat (5) #CYCLE;
            $finish;
        end
        //#(CYCLE/2.0) rst_n = 1;
        #(CYCLE/2.0) release clk;
        //#CYCLE; release clk;
end endtask





task input_task; begin
	repeat (10) @(negedge clk);

    _tetrominoes = _inputertype[i_pat][_round_16];
    _position    = _inputerpos[i_pat][_round_16];

    in_valid = 1'b1;
    tetrominoes = _tetrominoes ;
    position    = _position    ;
    $display("tetrominoes=%d position=%d ",tetrominoes,position );

    @(negedge clk); 
    in_valid = 1'b0;
    tetrominoes = 3'bxxx;
    position = 3'bxxx;  
    random_delay = $urandom_range(1,4);
    repeat (random_delay) @(negedge clk);

end endtask







task Calculation_task;
    begin
        //clear_signal ;
        fail_out = 0;
        row = 'd11;
        line = 5'd11;
        bit_p = row * 6 + _position;
        score_in =0;

        case(_tetrominoes)
            3'd0: begin
                while(map[bit_p] == 0 && map[bit_p + 1] == 0 && map[bit_p + 6] == 0 && map[bit_p + 7] == 0) begin
                    row = row - 1;
                    bit_p = row * 6 + _position;
                    if (row < 0)
                        break;
                end
                row = row + 1;
                bit_p = row * 6 + _position;
            end
            3'd1: begin
                while(map[bit_p] == 0 && map[bit_p + 6] == 0 && map[bit_p + 12] == 0 && map[bit_p + 18] == 0) begin
                    row = row - 1;
                    bit_p = row * 6 + _position;
                    if (row < 0)
                        break;
                end
                row = row + 1;
                bit_p = row * 6 + _position;
            end
            3'd2: begin
                while(map[bit_p] == 0 && map[bit_p + 1] == 0 && map[bit_p + 2] == 0 && map[bit_p + 3] == 0) begin
                    row = row - 1;
                    bit_p = row * 6 + _position;
                    if (row < 0)
                        break;
                end
                row = row + 1;
                bit_p = row * 6 + _position;
            end
            3'd3: begin
                while(map[bit_p + 1] == 0 && map[bit_p + 7] == 0 && map[bit_p + 12] == 0 && map[bit_p + 13] == 0) begin
                    row = row - 1;
                    bit_p = row * 6 + _position;
                    if (row < 0)
                        break;
                end
                row = row + 1;
                bit_p = row * 6 + _position;
            end
            3'd4: begin
                while(map[bit_p] == 0 && map[bit_p + 6] == 0 && map[bit_p + 7] == 0 && map[bit_p + 8] == 0) begin
                    row = row - 1;
                    bit_p = row * 6 + _position;
                    if (row < 0)
                        break;
                end
                row = row + 1;
                bit_p = row * 6 + _position;
            end
            3'd5: begin
                while(map[bit_p] == 0 && map[bit_p + 1] == 0 && map[bit_p + 6] == 0 && map[bit_p + 12] == 0) begin
                    row = row - 1;
                    bit_p = row * 6 + _position;
                    if (row < 0)
                        break;
                end
                row = row + 1;
                bit_p = row * 6 + _position;
            end
            3'd6: begin
                while(map[bit_p + 1] == 0 && map[bit_p + 6] == 0 && map[bit_p + 7] == 0 && map[bit_p + 12] == 0) begin
                    row = row - 1;
                    bit_p = row * 6 + _position;
                    if (row < 0)
                        break;
                end
                row = row + 1;
                bit_p = row * 6 + _position;
            end
            3'd7: begin
                while(map[bit_p] == 0 && map[bit_p + 1] == 0 && map[bit_p + 7] == 0 && map[bit_p + 8] == 0) begin
                    row = row - 1;
                    bit_p = row * 6 + _position;
                    if (row < 0)
                        break;
                end
                row = row + 1;
                bit_p = row * 6 + _position;
            end
        endcase
   
        if (_tetrominoes === 3'd0) begin
            map[bit_p] = 1;
            map[bit_p + 1] = 1;
            map[bit_p + 6] = 1;
            map[bit_p + 7] = 1;
        end
        else if (_tetrominoes === 3'd1) begin
            map[bit_p] = 1;
            map[bit_p + 6] = 1;
            map[bit_p + 12] = 1;
            map[bit_p + 18] = 1;
        end
        else if (_tetrominoes === 3'd2) begin
            map[bit_p] = 1;
            map[bit_p + 1] = 1;
            map[bit_p + 2] = 1;
            map[bit_p + 3] = 1;
        end
        else if (_tetrominoes === 3'd3) begin
            map[bit_p + 1] = 1;
            map[bit_p + 7] = 1;
            map[bit_p + 12] = 1;
            map[bit_p + 13] = 1;
        end
        else if (_tetrominoes === 3'd4) begin
            map[bit_p] = 1;
            map[bit_p + 6] = 1;
            map[bit_p + 7] = 1;
            map[bit_p + 8] = 1;
        end
        else if (_tetrominoes === 3'd5) begin
            map[bit_p] = 1;
            map[bit_p + 1] = 1;
            map[bit_p + 6] = 1;
            map[bit_p + 12] = 1;
        end
        else if (_tetrominoes === 3'd6) begin
            map[bit_p + 1] = 1;
            map[bit_p + 6] = 1;
            map[bit_p + 7] = 1;
            map[bit_p + 12] = 1;
        end
        else if (_tetrominoes === 3'd7) begin
            map[bit_p] = 1;
            map[bit_p + 1] = 1;
            map[bit_p + 7] = 1;
            map[bit_p + 8] = 1;
        end

        for (line = 0; line <= 11; line = line + 1) begin

            if (map[line*6] && map[line*6 + 1] && map[line*6 + 2] && 
                map[line*6 + 3] && map[line*6 + 4] && map[line*6 + 5]) begin

                score_in = score_in + 1;

                for (i = line; i > 0; i = i - 1) begin
                    map[i*6]     = map[(i-1)*6];
                    map[i*6 + 1] = map[(i-1)*6 + 1];
                    map[i*6 + 2] = map[(i-1)*6 + 2];
                    map[i*6 + 3] = map[(i-1)*6 + 3];
                    map[i*6 + 4] = map[(i-1)*6 + 4];
                    map[i*6 + 5] = map[(i-1)*6 + 5];
                end

                map[0] = 0;
                map[1] = 0;
                map[2] = 0;
                map[3] = 0;
                map[4] = 0;
                map[5] = 0;

                line = line - 1;
           
            end
        end
    end

    check_fail ;
    /*if (tetris != map[71:0])begin
        $display("************************************************************");  
		$display("                                                            ");    
		$display("                     	  SPEC-7 FAIL                         ");
		$display("                                                            ");    
		$display("************************************************************");
		repeat (2) @(negedge clk);
		$finish;
    end*/
endtask


task check_fail ;
begin
    fail_out = 0 ;
    if (map[90:72] !== 0) begin
        fail_out = 1 ;
    end
end endtask   






/*task score_valid_low_task; begin
    while(score_valid === 1'b0) begin
    	if( score !== 4'b0 || fail !==  1'b0 || tetris_valid !== 1'b0 || tetris !== 72'b0) begin
            $display("************************************************************");  
			$display("                                                            ");    
			$display("                     	  SPEC-5 FAIL                         ");
			$display("                                                            ");    
			$display("************************************************************");
			repeat (2) @(negedge clk);
			$finish;
    	end
		@(negedge clk);
   	end
	@(negedge clk);
	while(tetris_valid === 1'b0)begin
		if(tetris !== 72'b0 )begin
			$display("************************************************************");  
			$display("                                                            ");    
			$display("                     	  SPEC-5 FAIL                         ");
			$display("                                                            ");    
			$display("************************************************************");
			repeat (2) @(negedge clk);
			$finish;
		end
	@(negedge clk);
	end

end endtask*/

task score_valid_low_task;
    time start_time, current_time;
    time TIMEOUT = 10000; 
begin
    start_time = $time; 

    if(score_valid === 1'b0) begin
        if (score !== 4'b0 || fail !== 1'b0 || tetris_valid !== 1'b0 || tetris !== 72'b0) begin
            $display("************************************************************");  
            $display("                                                            ");    
            $display("                      SPEC-5 FAIL                           ");
            $display("                                                            ");    
            $display("************************************************************");
            repeat (2) @(negedge clk);
            $finish;
        end
        
        current_time = $time;
        if (current_time - start_time > TIMEOUT) begin
            $display("************************************************************");  
            $display("                                                            ");    
            $display("                       TIMEOUT ERROR                        ");
            $display("                                                            ");    
            $display("************************************************************");
            $finish;
        end
        
        @(negedge clk);
    end

    @(negedge clk);

    start_time = $time; 
end
endtask

task tetris_rst; begin
    if(tetris_valid === 0)begin
	if(tetris !== 72'b0 )begin
			$display("************************************************************");  
			$display("                                                            ");    
			$display("                     	  SPEC-5 FAIL                         ");
			$display("                                                            ");    
			$display("************************************************************");
			repeat (2) @(negedge clk);
			$finish;
	end
	@(negedge clk);
	end
end endtask





task wait_out_valid_task; begin
    latency = 1;
	@(negedge in_valid);
    while(score_valid !== 1'b1) begin
        latency = latency + 1;
    	if(latency === 1000) begin
            $display("************************************************************");  
			$display("                                                            ");    
			$display("                     	  SPEC-6 FAIL                         ");
			$display("                                                            ");    
			$display("************************************************************");
			repeat (2) @(negedge clk);
			$finish;
    	end
    	@(negedge clk);
   	end
    if(latency === 0) latency = 1;
    //total_latency = total_latency + latency;
end endtask



task score_valid_cycle_task; begin
    while(score_valid == 1'b1) begin
        latency = latency + 1;
    	if(latency == 2) begin
            $display("************************************************************");  
			$display("                                                            ");    
			$display("                     	  SPEC-8 FAIL                         ");
			$display("                                                            ");    
			$display("************************************************************");
			//repeat(9)@(negedge clk);
			$finish;
    	end
    	@(negedge clk);
   	end
    if(latency === 0) latency = 1;
    total_latency = total_latency + latency;
end endtask

task tetris_valid_cycle_task; begin
    while(tetris_valid == 1'b1) begin
        latency = latency + 1;
    	if(latency == 2) begin
            $display("************************************************************");  
			$display("                                                            ");    
			$display("                     	  SPEC-8 FAIL                         ");
			$display("                                                            ");    
			$display("************************************************************");
			//repeat(9)@(negedge clk);
			$finish;
    	end
    	@(negedge clk);
   	end
    if(latency === 0) latency = 1;
    total_latency = total_latency + latency;
end endtask




task YOU_PASS_task; begin
    $display("*************************************************************************");
    $display("*                         Congratulations!                              *");
    $display("*                Your execution cycles = %5d cycles          *", total_latency);
    $display("*                Your clock period = %.1f ns          *", CYCLE);
    $display("*                Total cycle = %.1f ns          *", total_latency*CYCLE);
    $display("*************************************************************************");
    $finish;
end endtask

endmodule
// for spec check
// $display("                    SPEC-4 FAIL                   ");
// $display("                    SPEC-5 FAIL                   ");
// $display("                    SPEC-6 FAIL                   ");
// $display("                    SPEC-7 FAIL                   ");
// $display("                    SPEC-8 FAIL                   ");
// for successful design
// $display("                  Congratulations!               ");
// $display("              execution cycles = %7d", total_latency);
// $display("              clock period = %4fns", CYCLE);

