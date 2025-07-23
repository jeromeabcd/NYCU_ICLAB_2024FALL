module Program(input clk, INF.Program_inf inf);
import usertype::*;

typedef enum logic [5:0] {
    IDLE,
	IN_ACT,
	IN_FOMULA,
	IN_MODE,
    IN_DATE ,
	IN_NO ,
	IN_INDEX ,
	INDATA_ACT ,
	READ_DRAM ,
	READ_DRAM_ADDR ,
	CAL ,
    WRITE_DRAM ,
	WAIT ,
	WRITE_BACK ,
	WAIT_B ,
	OUT
} state_t ;

//======================================
//      Register
//======================================
state_t   		current_state, next_state ;
Mode            mode_in ; 
Date         	date_in ; 
Action    	 	action_in ;
Formula_Type    formula_in; 
Data_Dir        early_index;
logic [7:0] pic_no;
logic [5:0] counter;
logic [5:0] counter_cal;
logic signed[11:0] late_A,late_B,late_C,late_D;
logic signed[13:0] early_A,early_B,early_C,early_D;
logic signed[13:0] add1,add2,add3,add4;
logic signed[13:0] addout1,addout2,addout3,addout4;
logic [13:0] R;
logic [11:0] lv1_1,lv1_2,lv1_3,lv1_4;
logic [11:0] lv2_1,lv2_2,lv2_3,lv2_4;
logic [11:0] lv3_1,lv3_2;
logic [11:0] EA,LA,EB,LB,EC,LC,ED,LD;
logic [11:0] GA,GB,GC,GD;
logic [15:0] Threshold;
logic  R_VALID_SIG;

//======================================
//            TOP_FSM
//======================================
always_ff @ ( posedge clk or negedge inf.rst_n) begin : TOP_FSM_SEQ
    if (!inf.rst_n) current_state <= IDLE;
    else current_state <= next_state;
end

always_comb begin : TOP_FSM_COMB
    case(current_state)
        IDLE: begin
            if (inf.sel_action_valid) next_state = IN_ACT ;
            else next_state = IDLE ;
        end
		IN_ACT : begin 
			if (inf.formula_valid) next_state = IN_FOMULA ;
			else if (inf.data_no_valid) next_state = READ_DRAM_ADDR ;
			else next_state = IN_ACT ;
		end
		IN_FOMULA : begin 
			if (inf.mode_valid) next_state = IN_MODE ;
			else next_state = IN_FOMULA ;
		end
        IN_MODE : begin 
			if (inf.date_valid) next_state = IN_DATE ;
			else next_state = IN_MODE ;
		end
        IN_DATE : begin 
			if (inf.data_no_valid) next_state = READ_DRAM_ADDR ;
			else next_state = IN_DATE ;
		end
        READ_DRAM_ADDR : begin 
			if (inf.AR_READY) next_state = READ_DRAM ;
			else next_state = READ_DRAM_ADDR ;
		end
        READ_DRAM : begin 
			if (inf.R_VALID && action_in==Check_Valid_Date) next_state = OUT ;
			else if (R_VALID_SIG==1 && counter==4) next_state = CAL ;
			else next_state = READ_DRAM ;
		end
		CAL: begin 
			if (action_in==Update && counter_cal==2) next_state = WRITE_DRAM ;
			else if (action_in==Index_Check && counter_cal==1) next_state = OUT ;
			else next_state = CAL ;
		end
		WRITE_DRAM: begin 
			if (inf.AW_READY) next_state = WAIT ;
			else next_state = WRITE_DRAM ;
		end
		WAIT: begin 
			if (inf.W_READY) next_state = WAIT_B ;
			else next_state = WAIT ;
		end
		WAIT_B: begin 
			if (inf.B_VALID) next_state = OUT ;
			else next_state = WAIT_B ;
		end
		OUT: begin 
			next_state = IDLE ;
		end
		default: next_state = IDLE;
    endcase
end

//======================================
//       	  IN_DATA
//======================================
always_ff @(posedge clk/* or negedge inf.rst_n*/) begin
	/*if (!inf.rst_n) R_VALID_SIG <= 0 ;
	else */if (current_state==IDLE) R_VALID_SIG <= 0 ;
	else if (inf.R_VALID) R_VALID_SIG <= 1;
	else R_VALID_SIG <= R_VALID_SIG ;
end

always_ff @(posedge clk/* or negedge inf.rst_n*/) begin
	/*if (!inf.rst_n) action_in <= Index_Check ;
	else */if (inf.sel_action_valid) action_in <= inf.D.d_act[0] ;
	else action_in <= action_in ;
end

always_ff @(posedge clk/* or negedge inf.rst_n*/) begin
	/*if (!inf.rst_n) formula_in <= Formula_A ;
	else */if (inf.formula_valid) formula_in <= inf.D.d_formula[0] ;
	else formula_in <= formula_in ;
end

always_ff @(posedge clk/* or negedge inf.rst_n*/) begin
	/*if (!inf.rst_n) mode_in <= Insensitive ;
	else */if (inf.mode_valid) mode_in <= inf.D.d_mode[0] ;
	else mode_in <= mode_in ;
end

always_ff @(posedge clk /*or negedge inf.rst_n*/) begin
	/*if (!inf.rst_n) begin
		date_in.M <= 0 ;
		date_in.D <= 0 ;
	end
	else */if (inf.date_valid)begin
		date_in.M <= inf.D.d_date[0][8:5] ;
		date_in.D <= inf.D.d_date[0][4:0] ;
	end
	else begin
		date_in.M <= date_in.M ;
        date_in.D <= date_in.D ;
	end
end


always_ff @(posedge clk /*or negedge inf.rst_n*/) begin
	/*if (!inf.rst_n) pic_no <= 0 ;
	else */if (inf.data_no_valid) pic_no <= inf.D.d_data_no[0] ;
	else pic_no <= pic_no ;
end

always_ff @(posedge clk/* or negedge inf.rst_n*/) begin
	/*if (!inf.rst_n)begin 
		late_A <= 0 ;
		late_B <= 0 ;
		late_C <= 0 ;
		late_D <= 0 ;
	end
	else */if (current_state == IDLE)begin 
		late_A <= 0 ;
		late_B <= 0 ;
		late_C <= 0 ;
		late_D <= 0 ;
	end
	else if (counter==0 && inf.index_valid)late_A <= inf.D.d_index[0] ;
	else if (counter==1 && inf.index_valid)late_B <= inf.D.d_index[0] ;
	else if (counter==2 && inf.index_valid)late_C <= inf.D.d_index[0] ;
	else if (counter==3 && inf.index_valid)late_D <= inf.D.d_index[0] ;
	else begin
		late_A <= late_A ;
		late_B <= late_B ;
		late_C <= late_C ;
		late_D <= late_D ;
	end
end
//======================================
//       	  counter
//======================================
always_ff @(posedge clk or negedge inf.rst_n) begin 
	if (!inf.rst_n) counter <= 0 ;
	else if (current_state == IDLE) counter <= 0 ;
	else if (inf.index_valid) counter <= counter + 1 ;
	else counter <= counter ;
end

always_ff @(posedge clk or negedge inf.rst_n) begin 
	if (!inf.rst_n) counter_cal <= 0 ;
	else if (current_state == IDLE) counter_cal <= 0 ;
	else if (current_state == CAL) counter_cal <= counter_cal + 1 ;
	else counter_cal <= counter_cal ;
end


//======================================
//       	  READ
//======================================
always_comb begin 
	if (current_state == READ_DRAM_ADDR)begin
        inf.AR_VALID = 1 ;
        inf.AR_ADDR = 17'h1_0000+pic_no*8 ;
    end
	else begin
        inf.AR_VALID = 0 ;
        inf.AR_ADDR = 0 ;
    end
end

always_comb begin 
	if (current_state == READ_DRAM)begin
        inf.R_READY = 1 ;
    end
	else begin
        inf.R_READY = 0 ;
    end
end

//======================================
//       	  WRITE
//======================================

always_comb begin 
	if (current_state == WRITE_DRAM)begin
        inf.AW_VALID = 1 ;
		inf.AW_ADDR = 17'h1_0000+pic_no*8 ;
    end
	else begin
        inf.AW_VALID = 0 ;
		inf.AW_ADDR = 0 ;
    end
end

always_comb begin 
	if (current_state == WAIT)begin
        inf.W_VALID = 1 ;
		inf.W_DATA={early_index.Index_A,early_index.Index_B,4'b0,early_index.M,early_index.Index_C,early_index.Index_D,3'b0,early_index.D} ;
    end
	else begin
        inf.W_VALID = 0 ;
		inf.W_DATA = 0 ;
    end
end

always_comb begin 
	if (current_state == WAIT || current_state == WRITE_BACK || current_state == WAIT_B)begin
        inf.B_READY = 1 ;
    end
	else begin
        inf.B_READY = 0 ;
    end
end

//======================================
//       	  Design
//======================================

always_ff @(posedge clk/* or negedge inf.rst_n*/) begin 
	/*if (!inf.rst_n) begin 
		early_index.M <= 0 ;
		early_index.D <= 0 ;
	end
	else */if (inf.R_VALID)begin
		early_index.M <= inf.R_DATA[39:32];
		early_index.D <= inf.R_DATA[7:0];
	end
	else if (action_in == Update && counter_cal==2)begin
		early_index.M <= date_in.M;
		early_index.D <= date_in.D;
	end
	else begin 
		early_index.M <= early_index.M ;
		early_index.D <= early_index.D ;
	end
end

always_ff @(posedge clk/* or negedge inf.rst_n*/) begin 
	/*if (!inf.rst_n) begin 
		early_index.Index_A <= 0 ;
		early_index.Index_B <= 0 ;
		early_index.Index_C <= 0 ;
		early_index.Index_D <= 0 ;
	end
	else */if (inf.R_VALID)begin
		early_index.Index_A <= inf.R_DATA[63:52];
		early_index.Index_B <= inf.R_DATA[51:40];
		early_index.Index_C <= inf.R_DATA[31:20];
		early_index.Index_D <= inf.R_DATA[19:8];		
	end
	else if (current_state == CAL && action_in == Update && counter_cal==2)begin
		early_index.Index_A <= addout1;
		early_index.Index_B <= addout2;
		early_index.Index_C <= addout3;
		early_index.Index_D <= addout4;	
	end
	else begin 
		early_index.Index_A <= early_index.Index_A ;
        early_index.Index_B <= early_index.Index_B ;
        early_index.Index_C <= early_index.Index_C ;
        early_index.Index_D <= early_index.Index_D ;
	end
end

always_comb begin 
	early_A = early_index.Index_A ;
	early_B = early_index.Index_B ;
	early_C = early_index.Index_C ;
	early_D = early_index.Index_D ;	
end


always_ff @(posedge clk or negedge inf.rst_n) begin   
	if (!inf.rst_n) begin 
		R <= 0;
	end
	else if (formula_in==Formula_A) begin 
		R <= (early_index.Index_A +early_index.Index_B +early_index.Index_C+early_index.Index_D)>>2 ;
	end	
	else if (formula_in==Formula_B) begin 
		R <=  lv2_1 - lv2_4;
	end
	else if (formula_in==Formula_C) begin 
		R <=  lv2_4;
	end
	else if (formula_in==Formula_D || formula_in==Formula_E) begin 
		R <=  lv1_1 + lv1_2 + lv1_3 + lv1_4;
	end
	else if (formula_in==Formula_F) begin 
		R <= (lv3_1 + lv3_2 + lv2_4)/3;
	end
	else if (formula_in==Formula_G) begin 
		R <= (lv2_4>>1) + (lv3_2>>2) + (lv3_1>>2);
	end
	else if (formula_in==Formula_H) begin 
		R <= (GA + GB + GC + GD)>>2;
	end
end

always_comb begin 
	if (formula_in==Formula_B || formula_in==Formula_C ) begin 
		lv1_1 = (early_index.Index_A>early_index.Index_C)?early_index.Index_A:early_index.Index_C;
		lv1_3 = (early_index.Index_A>early_index.Index_C)?early_index.Index_C:early_index.Index_A; 
		lv1_2 = (early_index.Index_B>early_index.Index_D)?early_index.Index_B:early_index.Index_D;
		lv1_4 = (early_index.Index_B>early_index.Index_D)?early_index.Index_D:early_index.Index_B; 
	end
	else if (formula_in==Formula_D) begin 
		lv1_1 = (early_index.Index_A>=2047)?1:0;
		lv1_3 = (early_index.Index_B>=2047)?1:0; 
		lv1_2 = (early_index.Index_C>=2047)?1:0;
		lv1_4 = (early_index.Index_D>=2047)?1:0;
	end
	else if (formula_in==Formula_E) begin 
		lv1_1 = (early_index.Index_A>=late_A)?1:0;
		lv1_3 = (early_index.Index_B>=late_B)?1:0; 
		lv1_2 = (early_index.Index_C>=late_C)?1:0;
		lv1_4 = (early_index.Index_D>=late_D)?1:0;
	end	
	else  begin 
		lv1_1 = (GA>GB)?GA:GB;
		lv1_3 = (GA>GB)?GB:GA; 
		lv1_2 = (GC>GD)?GC:GD;
		lv1_4 = (GC>GD)?GD:GC;
	end					
end


always_ff @(posedge clk/* or negedge inf.rst_n*/) begin   
	/*if (!inf.rst_n) begin 
		Threshold <= 0;
	end
	else */if (formula_in==Formula_A || formula_in==Formula_C ) begin
		if(mode_in==Insensitive)Threshold <= 2047;
		else if(mode_in==Normal)Threshold <= 1023;
		else if(mode_in==Sensitive)Threshold <= 511;
	end
	else if (formula_in==Formula_B || formula_in==Formula_F  || formula_in==Formula_G  || formula_in==Formula_H) begin 
		if(mode_in==Insensitive)Threshold <= 800;
		else if(mode_in==Normal)Threshold <= 400;
		else if(mode_in==Sensitive)Threshold <= 200;
	end
	else if (formula_in==Formula_D || formula_in==Formula_E) begin 
		if(mode_in==Insensitive)Threshold <= 3;
		else if(mode_in==Normal)Threshold <= 2;
		else if(mode_in==Sensitive)Threshold <= 1;
	end	
end


always_comb begin 
	lv2_1 = (lv1_1>lv1_2)?lv1_1:lv1_2;
	lv2_2 = (lv1_1>lv1_2)?lv1_2:lv1_1; 
	lv2_3 = (lv1_3>lv1_4)?lv1_3:lv1_4;
	lv2_4 = (lv1_3>lv1_4)?lv1_4:lv1_3;
	lv3_1 = (lv2_2>lv2_3)?lv2_2:lv2_3;
	lv3_2 = (lv2_2>lv2_3)?lv2_3:lv2_2;  		
end

always_ff @(posedge clk)begin 
	EA <= (early_index.Index_A>late_A)?early_index.Index_A:late_A;
	LA <= (early_index.Index_A>late_A)?late_A:early_index.Index_A;
	EB <= (early_index.Index_B>late_B)?early_index.Index_B:late_B;
	LB <= (early_index.Index_B>late_B)?late_B:early_index.Index_B;
	EC <= (early_index.Index_C>late_C)?early_index.Index_C:late_C;
	LC <= (early_index.Index_C>late_C)?late_C:early_index.Index_C;
	ED <= (early_index.Index_D>late_D)?early_index.Index_D:late_D;
	LD <= (early_index.Index_D>late_D)?late_D:early_index.Index_D;	
end

always_ff  @(posedge clk)begin 
	GA <= EA-LA;
	GB <= EB-LB;
	GC <= EC-LC;
	GD <= ED-LD;
end

always_ff @(posedge clk/* or negedge inf.rst_n*/) begin
	/*if (!inf.rst_n) begin 
		add1 <= 0 ;
		add2 <= 0 ;
		add3 <= 0 ;
		add4 <= 0 ;
	end
	else */if(counter_cal==0)begin
		add1 <= early_A + late_A;
		add2 <= early_B + late_B;
		add3 <= early_C + late_C;
		add4 <= early_D + late_D;
	end
end

always_ff @(posedge clk/* or negedge inf.rst_n*/) begin
	/*if (!inf.rst_n) begin 
		addout1 <= 0 ;
		addout2 <= 0 ;
		addout3 <= 0 ;
		addout4 <= 0 ;
	end
	else */if(counter_cal==1)begin
		addout1 <= (add1>4095)?4095:(add1<0)?0:add1;
		addout2 <= (add2>4095)?4095:(add2<0)?0:add2;
		addout3 <= (add3>4095)?4095:(add3<0)?0:add3;
		addout4 <= (add4>4095)?4095:(add4<0)?0:add4;
	end
end

always_comb begin 
	if (current_state == OUT)begin
        inf.out_valid = 1 ;
    end
	else begin
        inf.out_valid = 0 ;
    end
end

always_comb begin 
	if (current_state == OUT)begin
		if (action_in == Update)begin
			if((add1>4095||add1<0)||(add2>4095||add2<0)||(add3>4095||add3<0)||(add4>4095||add4<0))begin
        		inf.warn_msg  = Data_Warn  ;
				inf.complete  = 0  ;
			end
			else begin
				inf.warn_msg  = No_Warn  ;
				inf.complete  = 1  ;
			end
		end
		else if (action_in == Check_Valid_Date)begin
			if(early_index.M>date_in.M)begin
        		inf.warn_msg  = Date_Warn  ;
				inf.complete  = 0  ;
			end
			else if((early_index.M == date_in.M) && (early_index.D>date_in.D))begin
        		inf.warn_msg  = Date_Warn  ;
				inf.complete  = 0  ;
			end
			else begin
				inf.warn_msg  = No_Warn  ;
				inf.complete  = 1  ;
			end
		end
		else begin
			if(early_index.M>date_in.M)begin
        		inf.warn_msg  = Date_Warn  ;
				inf.complete  = 0  ;
			end
			else if((early_index.M == date_in.M) && (early_index.D>date_in.D))begin
        		inf.warn_msg  = Date_Warn  ;
				inf.complete  = 0  ;
			end
			else if(R>=Threshold)begin
        		inf.warn_msg  = Risk_Warn  ;
				inf.complete  = 0  ;
			end
			else begin
				inf.warn_msg  = No_Warn  ;
				inf.complete  = 1  ;
			end
		end
    end
	else begin
        inf.warn_msg  = No_Warn  ;
		inf.complete  = 0  ;
    end
end

endmodule
