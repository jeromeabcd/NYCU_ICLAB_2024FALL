
// `include "../00_TESTBED/pseudo_DRAM.sv"
`include "Usertype.sv"

program automatic PATTERN(input clk, INF.PATTERN inf);
import usertype::*;
//================================================================
// parameters & integer
//================================================================
parameter DRAM_p_r = "../00_TESTBED/DRAM/dram.dat";
parameter MAX_CYCLE=1000;

//================================================================
// wire & registers 
//================================================================
logic [7:0] golden_DRAM [((65536+8*256)-1):(65536+0)];  // 32 box
parameter CYCLE = 10;


//================================================================
// class random
//================================================================

/**
 * Class representing a random action.
 */
class random_act;
    randc Action act_id;
    constraint range{
        act_id inside{Index_Check, Update, Check_Valid_Date};
    }
endclass

class random_formula;
    randc Formula_Type formula_id;
    constraint range{
        formula_id inside{Formula_A, Formula_B, Formula_C, Formula_D, Formula_E, Formula_F, Formula_G, Formula_H};
    }
endclass

class random_mode;
    randc Mode mode_id;
    constraint range{
        mode_id inside{Insensitive, Normal, Sensitive};
    }
endclass

class random_pic;
    randc logic [7:0] pic_id;
    constraint range{
        pic_id inside{[0:255]};
    }
endclass

//================================================================
//    reg & wire
//================================================================

logic [11:0]Index_A_in,Index_B_in,Index_C_in,Index_D_in;
logic signed[11:0]Index_A_ins,Index_B_ins,Index_C_ins,Index_D_ins;
integer i, j, latency, total_latency, i_pat, t;
random_act act_rand;
random_formula formula_rand;
random_mode  mode_rand;
random_pic pic_rand;
Date date;
logic no_pass_expired;
logic signed[13:0] early_A,early_B,early_C,early_D;
logic signed[13:0] add1,add2,add3,add4;
logic signed[13:0] addout1,addout2,addout3,addout4;
logic [1:0]golden_error;
logic [13:0] R;
logic [11:0] lv1_1,lv1_2,lv1_3,lv1_4;
logic [11:0] lv2_1,lv2_2,lv2_3,lv2_4;
logic [11:0] lv3_1,lv3_2;
logic [11:0] EA,LA,EB,LB,EC,LC,ED,LD;
logic [11:0] GA,GB,GC,GD;
logic [15:0] Threshold;
logic [11:0]golden_index_A;
logic [11:0]golden_index_B;
logic [11:0]golden_index_C;
logic [11:0]golden_index_D;
logic [7:0]golden_month;
logic [7:0]golden_date;
logic [7:0]late_month;
logic [7:0]late_date;

//================================================================
// initial
//================================================================

initial begin 
    $readmemh(DRAM_p_r, golden_DRAM);
    act_rand = new();
    formula_rand = new();
    mode_rand = new();
    pic_rand = new();
    total_latency = 0;
	reset_task;
    for(i_pat = 0; i_pat < 6006; i_pat = i_pat + 1) begin
		input_task;
    	latency = 0;
        wait_out_valid_task;
		check_ans_task;
		$display ("\033[0;%2dmPass Pattern NO. %d    latency = %d  \033[m   act = %d ", 31+(i_pat%7), i_pat, latency, act_rand.act_id);
	end
	PASS_TASK;
    $finish ;
end

//================================================================
// reset_task
//================================================================

task reset_task; begin
    inf.rst_n = 1'b1;
    inf.sel_action_valid = 1'b0;
    inf.formula_valid = 1'b0;
    inf.mode_valid = 1'b0;
    inf.date_valid = 1'b0;
    inf.data_no_valid = 1'b0;
    inf.index_valid = 1'b0;
    inf.D = 'dx;

    force clk = 0;

    #(10); inf.rst_n = 0;
    #(50); inf.rst_n = 1;
    
	release clk;
    // check output reset
    if(inf.out_valid !== 1'b0 || inf.complete !== 1'b0 || inf.warn_msg !== 2'b00) begin
        FAIL_TASK;
        $display("Output signal should be 0");
        repeat(2) @(negedge clk);
        // $finish;
    end
    repeat(2) @(negedge clk);

end
endtask

//================================================================
// input_task
//================================================================

task input_task; begin

    t = $urandom_range(1, 4);
    repeat(t) @(negedge clk);
    inf.sel_action_valid = 'b1;

    if(i_pat < 3601) act_rand.act_id = Index_Check;
    else if(i_pat >= 3601 && i_pat < 4201) act_rand.act_id = (i_pat % 2 == 0) ? Update : Index_Check;
    else if(i_pat >= 4201 && i_pat < 4803) act_rand.act_id = (i_pat % 2 == 0) ? Check_Valid_Date : Index_Check;
    else if(i_pat >= 4803 && i_pat < 5104) act_rand.act_id = Update;
    else if(i_pat >= 5104 && i_pat < 5705) act_rand.act_id = (i_pat % 2 == 0) ? Update : Check_Valid_Date;
    else if(i_pat >= 5705) act_rand.act_id = Check_Valid_Date;
    inf.D = act_rand.act_id;
    @(negedge clk);

    inf.sel_action_valid = 'b0;
    inf.D = 'bx;
    t = $urandom_range(0, 3);
    repeat(t) @(negedge clk);
    //================================================================
    // Index_Check
    //================================================================
    if(act_rand.act_id == Index_Check) begin
        //================================================================
        // formula
        //================================================================
        inf.formula_valid = 'b1;
        if(i_pat < 451) formula_rand.formula_id = Formula_A;
        else if(i_pat >= 451 && i_pat < 901) formula_rand.formula_id = Formula_B;
        else if(i_pat >= 901 && i_pat < 1351) formula_rand.formula_id = Formula_C;
        else if(i_pat >= 1351 && i_pat < 1801) formula_rand.formula_id = Formula_D;
        else if(i_pat >= 1801 && i_pat < 2251) formula_rand.formula_id = Formula_E;
        else if(i_pat >= 2251 && i_pat < 2701) formula_rand.formula_id = Formula_F;
        else if(i_pat >= 2701 && i_pat < 3151) formula_rand.formula_id = Formula_G;
        else if(i_pat >= 3151 && i_pat < 3601) formula_rand.formula_id = Formula_H;
        inf.D = formula_rand.formula_id;
        @(negedge clk);
        inf.formula_valid = 'b0;
        inf.D = 'bx;

        t = $urandom_range(0, 3);
        repeat(t) @(negedge clk);
        //================================================================
        // mode
        //================================================================
        inf.mode_valid = 'b1;
        if(i_pat < 150)                        mode_rand.mode_id = Insensitive;
        else if(i_pat >= 150 && i_pat < 300)   mode_rand.mode_id = Normal;
        else if(i_pat >= 300 && i_pat < 451)   mode_rand.mode_id = Sensitive;//A
        else if(i_pat >= 451 && i_pat < 601)   mode_rand.mode_id = Insensitive;
        else if(i_pat >= 601 && i_pat < 751)   mode_rand.mode_id = Normal;
        else if(i_pat >= 751 && i_pat < 901)   mode_rand.mode_id = Sensitive;//B
        else if(i_pat >= 901 && i_pat < 1051)   mode_rand.mode_id = Insensitive;
        else if(i_pat >= 1051 && i_pat < 1201)   mode_rand.mode_id = Normal;
        else if(i_pat >= 1201 && i_pat < 1351)   mode_rand.mode_id = Sensitive;//C
        else if(i_pat >= 1351 && i_pat < 1501)  mode_rand.mode_id = Insensitive;
        else if(i_pat >= 1501 && i_pat < 1651) mode_rand.mode_id = Normal;
        else if(i_pat >= 1651 && i_pat < 1801) mode_rand.mode_id = Sensitive;//D
        else if(i_pat >= 1801 && i_pat < 1951) mode_rand.mode_id = Insensitive;
        else if(i_pat >= 1951 && i_pat < 2101) mode_rand.mode_id = Normal;
        else if(i_pat >= 2101 && i_pat < 2251) mode_rand.mode_id = Sensitive;//E
        else if(i_pat >= 2251 && i_pat < 2401) mode_rand.mode_id = Insensitive;
        else if(i_pat >= 2401 && i_pat < 2551) mode_rand.mode_id = Normal;
        else if(i_pat >= 2551 && i_pat < 2701) mode_rand.mode_id = Sensitive;//F
        else if(i_pat >= 2701 && i_pat < 2851) mode_rand.mode_id = Insensitive;
        else if(i_pat >= 2851 && i_pat < 3001) mode_rand.mode_id = Normal;
        else if(i_pat >= 3001 && i_pat < 3151) mode_rand.mode_id = Sensitive;//G
        else if(i_pat >= 3151 && i_pat < 3301) mode_rand.mode_id = Insensitive;
        else if(i_pat >= 3301 && i_pat < 3451) mode_rand.mode_id = Normal;
        else if(i_pat >= 3451 && i_pat < 3601) mode_rand.mode_id = Sensitive;//H
        inf.D = mode_rand.mode_id;
        @(negedge clk);
        inf.mode_valid = 'b0;
        inf.D = 'bx;
        t = $urandom_range(0, 3);
        repeat(t) @(negedge clk);
        //================================================================
        // date
        //================================================================
        date.M = $urandom_range(1, 12);
        if(date.M == 2) date.D = $urandom_range(1, 28);
        else if(date.M == 1 || date.M == 3 || date.M == 5 || date.M == 7 || date.M == 8 || date.M == 10 || date.M == 12) date.D = $urandom_range(1, 31);
        else if(date.M == 4 || date.M == 6 || date.M == 9 || date.M == 11) date.D = $urandom_range(1, 30);
        inf.date_valid = 'b1;
        inf.D = date;
        @(negedge clk);
        inf.date_valid = 'b0;
        inf.D = 'bx;
        t = $urandom_range(0, 3);
        repeat(t) @(negedge clk);
        //================================================================
        // data number
        //================================================================
        inf.data_no_valid = 'b1;
        pic_rand.randomize();
        inf.D = pic_rand.pic_id;
        @(negedge clk);
        inf.data_no_valid = 'b0;
        inf.D = 'bx;
        t = $urandom_range(0, 3);
        repeat(t) @(negedge clk);
        //================================================================
        // index A
        //================================================================
        inf.index_valid = 'b1;
        Index_A_in = $urandom_range(0, 4095);
        inf.D = Index_A_in;
        @(negedge clk);
        inf.index_valid = 'b0;
        inf.D = 'bx;
        t = $urandom_range(0, 3);
        repeat(t) @(negedge clk);
        //================================================================
        // index B
        //================================================================
        inf.index_valid = 'b1;
        Index_B_in = $urandom_range(0, 4095);
        inf.D = Index_B_in;
        @(negedge clk);
        inf.index_valid = 'b0;
        inf.D = 'bx;
        t = $urandom_range(0, 3);
        repeat(t) @(negedge clk);
        //================================================================
        // index C
        //================================================================
        inf.index_valid = 'b1;
        Index_C_in = $urandom_range(0, 4095);
        inf.D = Index_C_in;
        @(negedge clk);
        inf.index_valid = 'b0;
        inf.D = 'bx;
        t = $urandom_range(0, 3);
        repeat(t) @(negedge clk);
        //================================================================
        // index D
        //================================================================        
        inf.index_valid = 'b1;
        Index_D_in = $urandom_range(0, 4095);
        inf.D = Index_D_in;
        @(negedge clk);
        inf.index_valid = 'b0;
        inf.D = 'bx;

    end
    //================================================================
    // Update
    //================================================================
    else if(act_rand.act_id == Update) begin
        //================================================================
        // date
        //================================================================
        date.M = $urandom_range(1, 12);
        if(date.M == 1 || date.M == 3 || date.M == 5 || date.M == 7 || date.M == 8 ||
           date.M == 10|| date.M == 12) begin
            date.D = $urandom_range(1, 31);
        end
        else if(date.M == 4 || date.M == 6 || date.M == 9 || date.M == 11) begin
            date.D = $urandom_range(1, 30);
        end
        else if(date.M == 2) begin
            date.D = $urandom_range(1, 28);
        end
        inf.date_valid = 'b1;
        inf.D = date;
        @(negedge clk);
        inf.date_valid = 'b0;
        inf.D = 'bx;
        t = $urandom_range(0, 3);
        repeat(t) @(negedge clk);
        //================================================================
        // data number
        //================================================================
        inf.data_no_valid = 'b1;
        pic_rand.randomize();
        inf.D = pic_rand.pic_id;
        @(negedge clk);
        inf.data_no_valid = 'b0;
        inf.D = 'bx;
        t = $urandom_range(0, 3);
        repeat(t) @(negedge clk);
        //================================================================
        // index A
        //================================================================
        inf.index_valid = 'b1;
        Index_A_in = $urandom_range(0, 4095);
        inf.D = Index_A_in;
        @(negedge clk);
        inf.index_valid = 'b0;
        inf.D = 'bx;
        t = $urandom_range(0, 3);
        repeat(t) @(negedge clk);
        //================================================================
        // index B
        //================================================================
        inf.index_valid = 'b1;
        Index_B_in = $urandom_range(0, 4095);
        inf.D = Index_B_in;
        @(negedge clk);
        inf.index_valid = 'b0;
        inf.D = 'bx;
        t = $urandom_range(0, 3);
        repeat(t) @(negedge clk);
        inf.index_valid = 'b1;
        //================================================================
        // index C
        //================================================================
        Index_C_in = $urandom_range(0, 4095);
        inf.D = Index_C_in;
        @(negedge clk);
        inf.index_valid = 'b0;
        inf.D = 'bx;
        t = $urandom_range(0, 3);
        repeat(t) @(negedge clk);
        inf.index_valid = 'b1;
        //================================================================
        // index D
        //================================================================
        Index_D_in = $urandom_range(0, 4095);
        inf.D = Index_D_in;
        @(negedge clk);
        inf.index_valid = 'b0;
        inf.D = 'bx;
        
    end
    //================================================================
    // Check_Valid_Date
    //================================================================
    else if(act_rand.act_id == Check_Valid_Date) begin
        //================================================================
        // date
        //================================================================
        date.M = $urandom_range(1, 12);
        if(date.M == 1 || date.M == 3 || date.M == 5 || date.M == 7 || date.M == 8 || date.M == 10|| date.M == 12) date.D = $urandom_range(1, 31);
        else if(date.M == 4 || date.M == 6 || date.M == 9 || date.M == 11) date.D = $urandom_range(1, 30);
        else if(date.M == 2) date.D = $urandom_range(1, 28);
        inf.date_valid = 'b1;
        inf.D = date;
        @(negedge clk);
        inf.date_valid = 'b0;
        inf.D = 'bx;
        t = $urandom_range(0, 3);
        repeat(t) @(negedge clk);
        //================================================================
        // data number
        //================================================================  
        inf.data_no_valid = 'b1;
        pic_rand.randomize();
        inf.D = pic_rand.pic_id;
        @(negedge clk);
        inf.data_no_valid = 'b0;
        inf.D = 'bx;
    end

end endtask


//================================================================
// wait_out_valid_task
//================================================================
task wait_out_valid_task; begin
    while(inf.out_valid !== 1'b1) begin
        latency = latency + 1;
        if(latency == 1000) begin
            FAIL_TASK;
            $display("execution latency over 1000 cycle");
        end

        @(negedge clk);
    end
    total_latency = total_latency + latency;
end
endtask

//================================================================
// check_ans_task
//================================================================
task check_ans_task; begin
    late_month             = date.M;
    late_date              = date.D;
    golden_index_A         = {golden_DRAM[65536 + 7 + 8 * pic_rand.pic_id],      golden_DRAM[65536 + 6 + 8 * pic_rand.pic_id][7:4]};
    golden_index_B         = {golden_DRAM[65536 + 6 + 8 * pic_rand.pic_id][3:0], golden_DRAM[65536 + 5 + 8 * pic_rand.pic_id]};
    golden_month           = {golden_DRAM[65536 + 4 + 8 * pic_rand.pic_id]};
    golden_index_C         = {golden_DRAM[65536 + 3 + 8 * pic_rand.pic_id],      golden_DRAM[65536 + 2 + 8 * pic_rand.pic_id][7:4]};
    golden_index_D         = {golden_DRAM[65536 + 2 + 8 * pic_rand.pic_id][3:0], golden_DRAM[65536 + 1 + 8 * pic_rand.pic_id]};
    golden_date            = {golden_DRAM[65536 + 8 * pic_rand.pic_id]};
    case (act_rand.act_id) 
		Index_Check : begin
            EA = (golden_index_A>Index_A_in)?golden_index_A:Index_A_in;
            LA = (golden_index_A>Index_A_in)?Index_A_in:golden_index_A;
            EB = (golden_index_B>Index_B_in)?golden_index_B:Index_B_in;
            LB = (golden_index_B>Index_B_in)?Index_B_in:golden_index_B;
            EC = (golden_index_C>Index_C_in)?golden_index_C:Index_C_in;
            LC = (golden_index_C>Index_C_in)?Index_C_in:golden_index_C;
            ED = (golden_index_D>Index_D_in)?golden_index_D:Index_D_in;
            LD = (golden_index_D>Index_D_in)?Index_D_in:golden_index_D;
            GA = EA-LA;
            GB = EB-LB;
            GC = EC-LC;
            GD = ED-LD;
            if (formula_rand.formula_id==Formula_B || formula_rand.formula_id==Formula_C ) begin 
                lv1_1 = (golden_index_A>golden_index_C)?golden_index_A:golden_index_C;
                lv1_3 = (golden_index_A>golden_index_C)?golden_index_C:golden_index_A; 
                lv1_2 = (golden_index_B>golden_index_D)?golden_index_B:golden_index_D;
                lv1_4 = (golden_index_B>golden_index_D)?golden_index_D:golden_index_B; 
            end
            else if (formula_rand.formula_id==Formula_D) begin 
                lv1_1 = (golden_index_A>=2047)?1:0;
                lv1_3 = (golden_index_B>=2047)?1:0; 
                lv1_2 = (golden_index_C>=2047)?1:0;
                lv1_4 = (golden_index_D>=2047)?1:0;
            end
            else if (formula_rand.formula_id==Formula_E) begin 
                lv1_1 = (golden_index_A>=Index_A_in)?1:0;
                lv1_3 = (golden_index_B>=Index_B_in)?1:0; 
                lv1_2 = (golden_index_C>=Index_C_in)?1:0;
                lv1_4 = (golden_index_D>=Index_D_in)?1:0;
            end	
            else  begin 
                lv1_1 = (GA>GB)?GA:GB;
                lv1_3 = (GA>GB)?GB:GA; 
                lv1_2 = (GC>GD)?GC:GD;
                lv1_4 = (GC>GD)?GD:GC;
            end
            lv2_1 = (lv1_1>lv1_2)?lv1_1:lv1_2;
            lv2_2 = (lv1_1>lv1_2)?lv1_2:lv1_1; 
            lv2_3 = (lv1_3>lv1_4)?lv1_3:lv1_4;
            lv2_4 = (lv1_3>lv1_4)?lv1_4:lv1_3;
            lv3_1 = (lv2_2>lv2_3)?lv2_2:lv2_3;
            lv3_2 = (lv2_2>lv2_3)?lv2_3:lv2_2; 	

            if (formula_rand.formula_id==Formula_A) begin 
                R = (golden_index_A +golden_index_B +golden_index_C+golden_index_D)>>2 ;
            end	
            else if (formula_rand.formula_id==Formula_B) begin 
                R =  lv2_1 - lv2_4;
            end
            else if (formula_rand.formula_id==Formula_C) begin 
                R =  lv2_4;
            end
            else if (formula_rand.formula_id==Formula_D || formula_rand.formula_id==Formula_E) begin 
                R =  lv1_1 + lv1_2 + lv1_3 + lv1_4;
            end
            else if (formula_rand.formula_id==Formula_F) begin 
                R = (lv3_1 + lv3_2 + lv2_4)/3;
            end
            else if (formula_rand.formula_id==Formula_G) begin 
                R = (lv2_4>>1) + (lv3_2>>2) + (lv3_1>>2);
            end
            else begin 
                R = (GA + GB + GC + GD)>>2;
            end

            if (formula_rand.formula_id==Formula_A || formula_rand.formula_id==Formula_C ) begin
                if(mode_rand.mode_id==Insensitive)Threshold = 2047;
                else if(mode_rand.mode_id==Normal)Threshold = 1023;
                else /*if(mode_rand.mode_id==Sensitive)*/Threshold = 511;
            end
            else if (formula_rand.formula_id==Formula_B || formula_rand.formula_id==Formula_F || formula_rand.formula_id==Formula_G || formula_rand.formula_id==Formula_H) begin 
                if(mode_rand.mode_id==Insensitive)Threshold = 800;
                else if(mode_rand.mode_id==Normal)Threshold = 400;
                else /*if(mode_rand.mode_id==Sensitive)*/Threshold = 200;
            end
            else /*if (formula_rand.formula_id==Formula_D || formula_rand.formula_id==Formula_E)*/ begin 
                if(mode_rand.mode_id==Insensitive)Threshold = 3;
                else if(mode_rand.mode_id==Normal)Threshold = 2;
                else /*if(mode_rand.mode_id==Sensitive)*/Threshold = 1;
            end
            
            if (late_month < golden_month) begin
                golden_error = 2'b01;
            end
			else if ((late_month == golden_month) && (late_date < golden_date)) begin
                golden_error = 2'b01;
            end
            else if (R>=Threshold) golden_error = 2'b10;
            else golden_error = 2'b00;
			/*if (golden_month > date.M) begin
                golden_error = 2'b01;
            end
			else if ((golden_month == date.M) && (golden_date > date.D)) begin
                golden_error = 2'b01;
            end
            else if (R>=Threshold) golden_error = 2'b10;
            else golden_error = 2'b00;*/

            if(inf.warn_msg !== golden_error) begin
			FAIL_TASK;
			$display("Wrong Answer");
			$finish;
            end
            else if(inf.complete === 1'b1 && inf.warn_msg != 2'b00) begin
                FAIL_TASK;
                $display("Wrong Answer");
                $finish;
            end
            else if(inf.complete === 1'b0 && inf.warn_msg == 2'b00) begin
                FAIL_TASK;
                $display("Wrong Answer");
                $finish;
            end
			
		end 
		Update : begin 
            early_A = golden_index_A;
            early_B = golden_index_B;
            early_C = golden_index_C;
            early_D = golden_index_D;
            Index_A_ins = Index_A_in;
            Index_B_ins = Index_B_in;
            Index_C_ins = Index_C_in;
            Index_D_ins = Index_D_in;
            add1 = early_A + Index_A_ins;
            add2 = early_B + Index_B_ins;
            add3 = early_C + Index_C_ins;
            add4 = early_D + Index_D_ins;
            addout1 = (add1>4095)?4095:(add1<0)?0:add1;
            addout2 = (add2>4095)?4095:(add2<0)?0:add2;
            addout3 = (add3>4095)?4095:(add3<0)?0:add3;
            addout4 = (add4>4095)?4095:(add4<0)?0:add4;

		if ((add1>4095||add1<0)||(add2>4095||add2<0)||(add3>4095||add3<0)||(add4>4095||add4<0))   golden_error   = 2'b11; 
        else   golden_error   = 2'b00; 
		
		{golden_DRAM[65536 + 7 + 8 * pic_rand.pic_id],      golden_DRAM[65536 + 6 + 8 * pic_rand.pic_id][7:4]} = addout1 ;
        {golden_DRAM[65536 + 6 + 8 * pic_rand.pic_id][3:0], golden_DRAM[65536 + 5 + 8 * pic_rand.pic_id]}      = addout2 ;
        {golden_DRAM[65536 + 4 + 8 * pic_rand.pic_id]}                                                         = date.M  ;
        {golden_DRAM[65536 + 3 + 8 * pic_rand.pic_id],      golden_DRAM[65536 + 2 + 8 * pic_rand.pic_id][7:4]} = addout3 ;
        {golden_DRAM[65536 + 2 + 8 * pic_rand.pic_id][3:0], golden_DRAM[65536 + 1 + 8 * pic_rand.pic_id]}      = addout4 ;
        {golden_DRAM[65536 + 8 * pic_rand.pic_id]}                                                             = date.D  ;

        if(inf.warn_msg !== golden_error) begin
			FAIL_TASK;
			$display("Wrong Answer");
			$finish;
        end
        else if(inf.complete === 1'b1 && inf.warn_msg != 2'b00) begin
			FAIL_TASK;
			$display("Wrong Answer");
			$finish;
        end
        else if(inf.complete === 1'b0 && inf.warn_msg == 2'b00) begin
			FAIL_TASK;
			$display("Wrong Answer");
			$finish;
        end
        
        
		end
		Check_Valid_Date : begin 
			//=========================================================
			// Pass Expired Day Or Not
			//=========================================================
            if (golden_month > date.M) golden_error = 2'b01;
			else if (date.M == golden_month && golden_date > date.D) golden_error = 2'b01;
            else golden_error = 2'b00;

            if(inf.warn_msg !== golden_error) begin
			FAIL_TASK;
			$display("Wrong Answer");
			$finish;
        end
        else if(inf.complete === 1'b1 && inf.warn_msg != 2'b00) begin
			FAIL_TASK;
			$display("Wrong Answer");
			$finish;
        end
        else if(inf.complete === 1'b0 && inf.warn_msg == 2'b00) begin
			FAIL_TASK;
			$display("Wrong Answer");
			$finish;
        end

		end
	endcase 
    
    

end endtask


task FAIL_TASK; begin
    $display("\n");
    $display("\n");
    $display("Wrong Answer");
    $display("\n");
end endtask

task PASS_TASK; begin
    $display("Congratulations");
    $finish;	
end endtask

endprogram
