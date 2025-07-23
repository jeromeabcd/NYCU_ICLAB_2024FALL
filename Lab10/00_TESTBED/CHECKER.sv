/*
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
NYCU Institute of Electronic
2023 Autumn IC Design Laboratory 
Lab10: SystemVerilog Coverage & Assertion
File Name   : CHECKER.sv
Module Name : CHECKER
Release version : v1.0 (Release Date: Nov-2023)
Author : Jui-Huang Tsai (erictsai.10@nycu.edu.tw)
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*/

`include "Usertype.sv"
module Checker(input clk, INF.CHECKER inf);
import usertype::*;

// integer fp_w;

// initial begin
// fp_w = $fopen("out_valid.txt", "w");
// end

/**
 * This section contains the definition of the class and the instantiation of the object.
 *  * 
 * The always_ff blocks update the object based on the values of valid signals.
 * When valid signal is true, the corresponding property is updated with the value of inf.D
 */

 //Coverage

class Formula_and_mode;
    Formula_Type f_type;
    Mode f_mode;
endclass

Formula_and_mode fm_info = new();

always_ff @(posedge clk) begin
    if (inf.formula_valid) begin
        fm_info.f_type = inf.D.d_formula[0] ;
    end
end

always_ff @(posedge clk) begin
    if (inf.mode_valid) begin
        fm_info.f_mode = inf.D.d_mode[0];
    end
end

//1. Each case of Formula_Type should be select at least 150 times.

covergroup Spec1 @(posedge clk iff(inf.formula_valid));
    option.per_instance = 1;
    option.at_least = 150;
    btype:coverpoint inf.D.d_formula[0] {
        bins F_f_type [] = {[Formula_H:Formula_A]};
    }
endgroup

//2. Each case of Mode should be select at least 150 times.

covergroup Spec2 @(posedge clk iff(inf.mode_valid));
    option.per_instance = 1;
    option.at_least = 150;
    bsize : coverpoint inf.D.d_mode[0] {
        bins F_f_mode [] = {[Sensitive:Insensitive]} ;
    }
endgroup


//3. Create a cross bin for the SPEC1 and SPEC2. Each combination should be selected at least 150 times. (Formula_A,B,C,D,E,F,G,H) x (Insensitive, Normal, Sensitive)

covergroup Spec3 @(negedge clk iff(inf.mode_valid));
    option.per_instance = 1;
    option.at_least = 150;
	cross fm_info.f_type, fm_info.f_mode ;
endgroup


//4. Output signal inf.warn_msg should be “No_Warn”, “Date_Warn”, “Data_Warn“,”Risk_Warn,each at least 50 times.

covergroup Spec4 @(negedge clk iff inf.out_valid);
    option.per_instance = 1;
    option.at_least = 50 ;
	coverpoint inf.warn_msg {
		bins b1 = {No_Warn} ;
		bins b2 = {Date_Warn} ;
		bins b3 = {Risk_Warn} ;
		bins b4 = {Data_Warn} ;
	}
endgroup 

//5. Create the transitions bin for the inf.D.act[0] signal from [Index_Check:Check_Valid_Date] to[Index_Check:Check_Valid_Date]. Each transition should be hit at least 300 times. (sample the value at posedge clk iff inf.sel_action_valid)

covergroup Spec5 @(posedge clk && inf.sel_action_valid);
    coverpoint inf.D.d_act[0]{
        option.at_least = 300;
        bins b[] = (Index_Check, Update, Check_Valid_Date => Index_Check, Update, Check_Valid_Date);
    }
endgroup 

//6. Create a covergroup for variation of Update action with auto_bin_max = 32, and each bin have to hit at least one time.

covergroup Spec6 @(posedge clk && inf.index_valid);
       coverpoint inf.D.d_index[0]{
              option.auto_bin_max = 32;
              option.at_least = 1;
       }
endgroup

Spec1 cov_inst_1 = new();
Spec2 cov_inst_2 = new();
Spec3 cov_inst_3 = new();
Spec4 cov_inst_4 = new();
Spec5 cov_inst_5 = new();
Spec6 cov_inst_6 = new();

//Asseration

//1. All outputs signals (Program.sv) should be zero after reset.

assert_1: assert property ( @(inf.rst_n==0)
              (inf.rst_n==0) |-> (inf.out_valid===0) && (inf.warn_msg===No_Warn) && (inf.complete===0) 
              && (inf.AR_VALID===0)
              && (inf.AR_ADDR===0) && (inf.R_READY===0) && (inf.AW_VALID===0)
              && (inf.AW_ADDR===0) && (inf.W_VALID===0) && (inf.W_DATA===0)
              && (inf.B_READY===0)
       )
       else begin
              $display("Assertion 1 is violated");
	       $fatal;
       end


//2. Latency should be less than 1000 cycles for each operation.

Action act ;
always_ff @(posedge clk or negedge inf.rst_n)  begin
	if (!inf.rst_n)				        act <= 3 ;
	else begin 
		if (inf.sel_action_valid==1) 	act <= inf.D.d_act[0] ;
	end
end

logic [1:0] index_valid_times;
always_ff @(posedge clk or negedge inf.rst_n)  begin
	if (!inf.rst_n)				    index_valid_times <= 0 ;
	else begin 
		if (inf.index_valid==1) 	index_valid_times <= index_valid_times + 1;
	end
end
assert_2_1: assert property ( @(posedge clk)
              (inf.index_valid===1 && index_valid_times==3 && act===Index_Check) |-> (##[1:1000] inf.out_valid===1) 
       )
       else begin
              $display("Assertion 2 is violated");
	       $fatal;
       end
assert_2_2: assert property ( @(posedge clk)
              (inf.index_valid===1 && index_valid_times==3 && act===Update) |-> (##[1:1000] inf.out_valid===1) 
       )
       else begin
              $display("Assertion 2 is violated");
	       $fatal;
       end
assert_2_3: assert property ( @(posedge clk)
              (inf.data_no_valid===1 && act===Check_Valid_Date) |-> (##[1:1000] inf.out_valid===1) 
       )
       else begin
              $display("Assertion 2 is violated");
	       $fatal;
       end

//3. If action is completed (complete=1), warn_msg should be 2’b0 (No_Warn).

assert_3: assert property ( @(negedge clk)
                // (!inf.out_valid) |->(inf.complete===0)
              (inf.complete) |-> (inf.warn_msg === No_Warn)
       )
       else begin
              $display("Assertion 3 is violated");
	       $fatal;
       end


//4. Next input valid will be valid 1-4 cycles after previous input valid fall.

assert_4_1: assert property ( @(posedge clk)
              (inf.sel_action_valid)
              |-> ##[1:4] (inf.formula_valid || inf.date_valid)
       )
       else begin
              $display("Assertion 4 is violated");
	       $fatal;
       end
assert_4_2: assert property ( @(posedge clk)
              (inf.formula_valid)
              |-> ##[1:4] (inf.mode_valid)
       )
       else begin
              $display("Assertion 4 is violated");
	       $fatal;
       end
assert_4_3: assert property ( @(posedge clk)
              (inf.mode_valid)
              |-> ##[1:4] (inf.date_valid)
       )
       else begin
              $display("Assertion 4 is violated");
	       $fatal;
       end
assert_4_4: assert property ( @(posedge clk)
              (inf.date_valid)
              |-> ##[1:4] (inf.data_no_valid)
       )
       else begin
              $display("Assertion 4 is violated");
	       $fatal;
       end
assert_4_5: assert property ( @(posedge clk)
              (inf.data_no_valid && act==Update)
              |-> ##[1:4] (inf.index_valid)
       )
       else begin
            $display("Assertion 4 is violated");
	        $fatal;
       end

assert_4_6: assert property ( @(posedge clk)
       (inf.data_no_valid && act==Index_Check)
       |-> ##[1:4] (inf.index_valid)
        )
        else begin
            $display("Assertion 4 is violated");
            $fatal;
        end

assert_4_7: assert property ( @(posedge clk)
              (inf.index_valid && index_valid_times!=3)
              |-> ##[1:4] (inf.index_valid)
       )
       else begin
              $display("Assertion 4 is violated");
	       $fatal;
       end
//5. All input valid signals won’t overlap with each other.

logic no_in_valid;
assign no_in_valid = !(inf.sel_action_valid || inf.formula_valid || inf.mode_valid || inf.date_valid || inf.data_no_valid || inf.index_valid);
assert_5: assert property ( @(posedge clk)
              $onehot({no_in_valid, inf.sel_action_valid, inf.formula_valid, inf.mode_valid, inf.date_valid, inf.data_no_valid, inf.index_valid})
       )
       else begin
              $display("Assertion 5 is violated");
	       $fatal;
       end

//6. Out_valid can only be high for exactly one cycle.

assert_6: assert property ( @(posedge clk)
              (inf.out_valid===1) |=> (inf.out_valid===0)
       )
       else begin
              $display("Assertion 6 is violated");
	       $fatal;
       end

//7. Next operation will be valid 1-4 cycles after out_valid fall.

assert_7: assert property ( @(posedge clk)
              (inf.out_valid===1) |-> (##[1:4] inf.sel_action_valid)
       )
       else begin
              $display("Assertion 7 is violated");
	       $fatal;
       end

//8. The input date from pattern should adhere to the real calendar. (ex: 2/29, 3/0, 4/31, 13/1 are illegal cases)

assert_8_1_31: assert property ( @(posedge clk)
    ((inf.date_valid===1) && (  inf.D.d_date[0].M == 1  |
                                inf.D.d_date[0].M == 3  |
                                inf.D.d_date[0].M == 5  |
                                inf.D.d_date[0].M == 7  |
                                inf.D.d_date[0].M == 8  |
                                inf.D.d_date[0].M == 10 | 
                                inf.D.d_date[0].M == 12   )) |-> (inf.D.d_date[0].D >= 1 && inf.D.d_date[0].D <= 31)
       )
       else begin
              $display("Assertion 8 is violated");
	       $fatal;
       end
assert_8_2_30: assert property ( @(posedge clk)
    ((inf.date_valid===1) && (  inf.D.d_date[0].M == 4  |
                                inf.D.d_date[0].M == 6  |
                                inf.D.d_date[0].M == 9  |
                                inf.D.d_date[0].M == 11  )) |-> (inf.D.d_date[0].D >= 1 && inf.D.d_date[0].D <= 30)
       )
       else begin
              $display("Assertion 8 is violated");
	       $fatal;
       end
assert_8_3_28: assert property ( @(posedge clk)
    ((inf.date_valid===1) && (  inf.D.d_date[0].M == 2 )) |-> (inf.D.d_date[0].D >= 1 && inf.D.d_date[0].D <= 28)
       )
       else begin
              $display("Assertion 8 is violated");
	       $fatal;
       end
assert_8_4: assert property ( @(posedge clk)
              (inf.date_valid==1) |-> (inf.D.d_date[0].M[3:0] >= 4'd1 && inf.D.d_date[0].M <= 4'd12)
       )
       else begin
        $display("Assertion 8 is violated");
	       $fatal;
       end

//9. The AR_VALID signal should not overlap with the AW_VALID signal.

logic AR_VALID_in_valid;
assign AR_VALID_in_valid = !(inf.AR_VALID||inf.AW_VALID);
assert_9: assert property ( @(posedge clk)
              $onehot({AR_VALID_in_valid, inf.AR_VALID, inf.AW_VALID})
       )
       else begin
              $display("Assertion 9 is violated");
	       $fatal;
       end


endmodule