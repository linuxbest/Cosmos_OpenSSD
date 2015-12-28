////////////////////////////////////////////////
//[Disclaimer]    
//This software code and all associated documentation, comments
//or other information (collectively "Software") is provided 
//"AS IS" without warranty of any kind. MICRON TECHNOLOGY, INC. 
//("MTI") EXPRESSLY DISCLAIMS ALL WARRANTIES EXPRESS OR IMPLIED,
//INCLUDING BUT NOT LIMITED TO, NONINFRINGEMENT OF THIRD PARTY
//RIGHTS, AND ANY IMPLIED WARRANTIES OF MERCHANTABILITY OR FITNESS
//FOR ANY PARTICULAR PURPOSE. MTI DOES NOT WARRANT THAT THE
//SOFTWARE WILL MEET YOUR REQUIREMENTS, OR THAT THE OPERATION OF
//THE SOFTWARE WILL BE UNINTERRUPTED OR ERROR-FREE. FURTHERMORE,
//MTI DOES NOT MAKE ANY REPRESENTATIONS REGARDING THE USE OR THE
//RESULTS OF THE USE OF THE SOFTWARE IN TERMS OF ITS CORRECTNESS,
//ACCURACY, RELIABILITY, OR OTHERWISE. THE ENTIRE RISK ARISING OUT
//OF USE OR PERFORMANCE OF THE SOFTWARE REMAINS WITH YOU. IN NO
//EVENT SHALL MTI, ITS AFFILIATED COMPANIES OR THEIR SUPPLIERS BE
//LIABLE FOR ANY DIRECT, INDIRECT, CONSEQUENTIAL, INCIDENTAL, OR
//SPECIAL DAMAGES (INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS
//OF PROFITS, BUSINESS INTERRUPTION, OR LOSS OF INFORMATION)
//ARISING OUT OF YOUR USE OF OR INABILITY TO USE THE SOFTWARE,
//EVEN IF MTI HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
//Because some jurisdictions prohibit the exclusion or limitation
//of liability for consequential or incidental damages, the above
//limitation may not apply to you.
//
//Copyright 2006-2008 Micron Technology, Inc. All rights reserved.
////////////////////////////////////////////////
`timescale 1ns / 1ps

module tb;


`include "nand_parameters.vh"

initial begin
`ifdef VCD
$dumpfile("nand_model.vcd");
$dumpvars(0,uut);
`endif
end 

    // Ports Declaration
    reg  [DQ_BITS - 1 : 0]   Io;
    reg                      Cle;
    reg                      Ale;
    reg                      Ce_n;
    reg                      Re_n;
    reg                      We_n;
    reg                      Wp_n;
    reg                      Ce2_n;
    reg                      Ce3_n; //reserved for future use
    reg                      Ce4_n; //reserved for future use
    reg                      Pre;
    reg                      Lock;
    reg                      Dqs;
    tri1                     Rb2_n; // pullup
    tri1                     Rb_n;  // pullup
    tri1                     Rb3_n; //reserved for future use
    tri1                     Rb4_n; //reserved for future use


    wire [DQ_BITS - 1 : 0] IO  = Io;
    wire [DQ_BITS - 1 : 0] IO2 = Io;
    // high-speed sync signals
    wire                      Clk;
    wire                      Wr_n = Re_n;

    wire                      Cle2 = Cle ;
    wire                      Ale2 = Ale ;
    wire                      Wp2_n = Wp_n ;
    wire                      Rb_any_n = Rb_n & Rb2_n & Rb3_n & Rb4_n;
    wire                      Clk_We2_n;
    wire                      Wr_Re2_n  = Re_n ;

    wire DQS  = Dqs;
    wire DQS2 = Dqs;

//  some testbench signals here
    wire cache_mode;
    reg  sync_mode;
    wire sync_mode0;
    wire sync_mode1;
    wire any_device_active = ~Ce_n || ~Ce2_n || ~Ce3_n || ~Ce4_n;
    reg rd_verify;
    reg enable_rd_verify;
    reg rd_verify_sync;
    reg [1:0] device;
    reg [DQ_BITS -1 : 0] rd_dq;
    reg [7:0] lastCmd;
    reg [2:0] lastState;
    reg Clk_int = 0;
    reg check_idle = 0;
    reg [2:0] PID  = 0;
    reg [2:0] PID1  = 3'h1;
    //read cycle timing parameters
    real tRP; //read cycle pulse width low
    real tREH;//read cycle high
    real tRC; //read cycle time
    //write cycle timing parameters
    real tWP; //write cycle pulse width low
    real tWH; //write cycle high
    real tWC; //write cycle time
    realtime tm_ren_pos=0;
    realtime tm_ren_neg=0;
    realtime tm_cen_pos=0;
    realtime tm_cen_neg=0;
    realtime tm_wen_pos=0;
    realtime tm_wen_neg=0;
    realtime tm_ale_pos=0;
    realtime tm_ale_neg=0;
    realtime tm_ale_clk=0;
    realtime tm_cle_pos=0;
    realtime tm_cle_neg=0;
    realtime tm_cle_clk=0;
    realtime tm_ce2n_pos=0;
    realtime tm_ce2n_neg=0;
    realtime tm_rbn_pos=0;
    realtime tm_io =0;
    realtime tm_io2 =0;
    realtime tm_cad_r=0;
    realtime tm_clk_pos=0;
    realtime tm_clk_neg=0;
    realtime tm_dqs_pos=0;
    realtime tm_dqs_neg=0;
    real     tCK_sync;
    
    reg        clock_disable; 
    reg [14:0] crc16;
    reg        por;    
    assign                    Clk  = We_n;

    initial begin
        // ----------------------------
        //these toggle times are set to larger values to allow the IO bus to transition back to z before the next read
        //  to demonstrate the data->x->z transition.  For min cycles, set these appropriately. 
        // Redefine these as needed with the set_read_cycle and set_write_cycle tasks.
	    tRP = tCEA_cache_max ; // Re_n low pulse width, adjust as needed
	    tREH = tRHZ_max; // Re_n high width, adjust as needed
    	tRC = tRP + tREH;
        tWP = tWP_cache_min;
        tWC = tWC_cache_min;
		if ((tWC - tWP) > tWH_cache_min) begin
	        tWH = tWC - tWP;
		end else begin
			tWH = tWH_cache_min;
		end
        // ----------------------------

        //initialize some regs that will be used
        rd_verify = 0;
        enable_rd_verify = 0;
        rd_verify_sync = 0;
        device = 0;
        lastCmd = 8'h00;
        lastState = 3'b000;
        Dqs = 1'bz;
        clock_disable = 1;
        por           = 0;
    end


//to determine whether or not the testbench needs to use cache mode timing when driving the NAND inputs,
// we'll keep track of whether any of the NAND dies are in cache mode.
    if(NUM_DIE == 8) begin 
        assign cache_mode = (tb.uut.uut_0.cache_op  || tb.uut.uut_1.cache_op  || tb.uut.uut_2.cache_op  || tb.uut.uut_3.cache_op  || tb.uut.uut_4.cache_op  || tb.uut.uut_5.cache_op  || tb.uut.uut_6.cache_op  || tb.uut.uut_7.cache_op);
        assign sync_mode3 = (tb.uut.uut_6.sync_mode || tb.uut.uut_7.sync_mode);
        assign sync_mode2 = (tb.uut.uut_4.sync_mode || tb.uut.uut_5.sync_mode);
        assign sync_mode1 = (tb.uut.uut_2.sync_mode || tb.uut.uut_3.sync_mode);
        assign sync_mode0 = (tb.uut.uut_0.sync_mode || tb.uut.uut_1.sync_mode);
    end else if(NUM_DIE == 4) begin 
        assign cache_mode = (tb.uut.uut_0.cache_op  || tb.uut.uut_1.cache_op  || tb.uut.uut_2.cache_op  || tb.uut.uut_3.cache_op);
        if(NUM_CE == 2) begin
            assign sync_mode1 = (tb.uut.uut_2.sync_mode || tb.uut.uut_3.sync_mode);
            assign sync_mode0 = (tb.uut.uut_0.sync_mode || tb.uut.uut_1.sync_mode);
        end else begin
            assign sync_mode1 = 1'b0;
            assign sync_mode0 = (tb.uut.uut_0.sync_mode || tb.uut.uut_1.sync_mode || tb.uut.uut_2.sync_mode || tb.uut.uut_3.sync_mode);
        end 
    end else if(NUM_DIE == 2) begin 
        assign cache_mode = (tb.uut.uut_0.cache_op  || tb.uut.uut_1.cache_op);
        if(NUM_CE == 2) begin 
            assign sync_mode1 = (tb.uut.uut_1.sync_mode);
            assign sync_mode0 = (tb.uut.uut_0.sync_mode);
        end else begin
            assign sync_mode1 = 1'b0;
            assign sync_mode0 = (tb.uut.uut_0.sync_mode || tb.uut.uut_1.sync_mode);
        end         
    end else begin
        assign cache_mode = tb.uut.uut_0.cache_op;
        assign sync_mode1 = 1'b0;
        assign sync_mode0 = tb.uut.uut_0.sync_mode;
    end 

    assign Clk_We2_n = We_n ;
    `ifdef BUS2
        always @(*) begin sync_mode = sync_mode1; end 
    `else
        always @(*) begin sync_mode = sync_mode0; end 
    `endif
    
    nand_model uut (

    `ifdef T2B1C1D1
        Ce2_n,
    `else `ifdef T2B2C1D1
        Ce2_n, Rb2_n,
    `else `ifdef T2B2C2D2
        Ce2_n, Rb2_n, IO2, Cle2, Ale2, Clk_We2_n, Wr_Re2_n, Wp2_n,
    `else `ifdef T4B4C2D2
        Ce2_n, Ce3_n, Ce4_n, Rb2_n, Rb3_n, Rb4_n, IO2, Cle2, Ale2, Clk_We2_n, Wr_Re2_n, Wp2_n,
    `endif `endif `endif `endif 
        IO, 
        Cle, 
        Ale, 
        We_n, 
        Re_n, 
        Ce_n, 
        Wp_n, 
        Rb_n
        );


    
    always @(posedge Re_n) begin
        tm_ren_pos = $realtime;
    end
    always @(negedge Re_n) begin
        tm_ren_neg = $realtime;
    end
    always @(posedge We_n) begin
        tm_wen_pos <= $realtime;
    end


    always @(posedge Clk) begin
        tm_clk_pos = $realtime;
        if (sync_mode && any_device_active && Ale && ~Cle) begin
            tm_ale_clk <= $realtime;
        end
        if (sync_mode && any_device_active && ~Ale && Cle) begin
            tm_cle_clk <= $realtime;
        end
    end
    always @(negedge Clk) tm_clk_neg = $realtime;

    always @(negedge We_n) begin
        tm_wen_neg = $realtime;
    end
    always @(posedge Ce_n) begin
        tm_cen_pos = $realtime;
    end
    always @(negedge Ce_n) begin
        tm_cen_neg = $realtime;
    end
    always @(posedge Ce2_n) begin
        tm_ce2n_pos = $realtime;
    end
    always @(negedge Ce2_n) begin
        tm_ce2n_neg = $realtime;
    end
    always @(posedge Cle) begin
        tm_cle_pos = $realtime;
    end
    always @(negedge Cle) begin
        tm_cle_neg = $realtime;
    end
    always @(posedge Ale) begin
        tm_ale_pos = $realtime;
    end
    always @(negedge Ale) begin
        tm_ale_neg = $realtime;
    end
    always @(posedge Rb_any_n) begin
        tm_rbn_pos = $realtime;
    end
    always @(IO) begin
        tm_io = $realtime;
    end
    always @(IO2) begin
        tm_io2 = $realtime;
    end
    
  function    [23           : 0]     fn_row_addr  ;
    input     [BLCK_BITS + LUN_BITS -1 : 0]     blck_addr    ;
    input     [PAGE_BITS -1 : 0]     page_addr    ;
    input                            page_en      ;
    begin
    `ifdef PAGEBITSGT8
        fn_row_addr [07:00] = {8{page_en}} & page_addr [(PAGE_BITS -1 -(PAGE_BITS-8)) : 0];
        fn_row_addr [15:08] = {blck_addr [(15 - PAGE_BITS) : 0], ({(PAGE_BITS-8){page_en}} & page_addr[PAGE_BITS-1: 8])};
            fn_row_addr [23:16] = {{(24 - (BLCK_BITS + LUN_BITS + PAGE_BITS)){1'b0}}, blck_addr [(BLCK_BITS + LUN_BITS -1) : (16 - PAGE_BITS)]};
    `else `ifdef PAGEBITS8
        fn_row_addr [07:00] = {8{page_en}} & page_addr[7 : 0];
        fn_row_addr [15:08] = blck_addr [(15 - PAGE_BITS) : 0];
            fn_row_addr [23:16] = {{(24 - (BLCK_BITS + LUN_BITS + PAGE_BITS)){1'b0}}, blck_addr [(BLCK_BITS + LUN_BITS -1) : (16 - PAGE_BITS)]};
    `else
        fn_row_addr [07:00] = {blck_addr [(7 - PAGE_BITS):0],({PAGE_BITS {page_en}} & page_addr[PAGE_BITS-1:0])};
        fn_row_addr [15:08] = blck_addr [(15 - PAGE_BITS) : (8 - PAGE_BITS)];
            fn_row_addr [23:16] = {{(24 - (BLCK_BITS + LUN_BITS + PAGE_BITS)){1'b0}}, blck_addr [(BLCK_BITS + LUN_BITS -1) : (16 - PAGE_BITS)]};
    `endif `endif
    end
  endfunction

    //lets user define read cycle time parameters
    task set_read_cycle;
    input tRP_new;   //low time
    input tREH_new;  //high time
    real tRP_new;   //low time
    real tREH_new;  //high time
    begin
        tRP = tRP_new;
        tREH = tREH_new;
        tRC = tRP + tREH;
    end
    endtask
    
    //lets user define read cycle time parameters
    task set_write_cycle;
    input tWP_new;
    input tWH_new;
    real tWP_new;
    real tWH_new;
    begin
        tWP = tWP_new;
        tWH = tWH_new;
        tWC = tRP + tREH;
    end
    endtask
    
    task wait_posedge_clk;
    begin
        if (Clk === 1) wait (Clk === 0);
        wait (Clk === 1);
    end
    endtask
    
    task wait_negedge_clk;
    begin
        if (Clk === 0) wait (Clk === 1);
        wait (Clk === 0);
    end
    endtask

    // 0 = dies controlled by Ce_n, 1 = dies controlled by Ce2_n
    task activate_device;
    input dev;
    begin
        device = dev;   //device variable is global
        if (sync_mode) begin //can't transition Ce pin while data is on Io/Dq
        end
        if (dev==1) begin
            if (Ce_n == 0) begin
                Ce_n <= 1;
            end
            Ce2_n <= 0;            
        end else begin
            if (Ce2_n == 0) begin
                Ce2_n <= 1;
            end
            Ce_n <= 0;
        end
    end
    endtask

    
/*
    // ??? device size increases revisit
    // 0 = dies controlled by Ce_n, 1 = dies controlled by Ce2_n
    task activate_device;
    input dev;
    begin
        device = dev;   //device variable is global
        if (sync_mode) begin //can't transition Ce pin while data is on Io/Dq
        end
        if (dev==1) begin  // target = 1
            if (Ce_n == 0 | Ce3_n == 0 | Ce4_n ==0) begin
                Ce_n  <= 1;
                Ce3_n <= 1;
                Ce4_n <= 1;
            end
            Ce2_n <= 0;            
        end else if (dev==2) begin  // target = 2
            if (Ce_n == 0 | Ce2_n == 0 | Ce4_n ==0) begin
                Ce_n  <= 1;
                Ce2_n <= 1;
                Ce4_n <= 1;
            end
            Ce3_n <= 0;            

        end else if (dev==3) begin  // target = 3
            if (Ce_n == 0 | Ce2_n == 0 | Ce3_n ==0) begin
                Ce_n  <= 1;
                Ce2_n <= 1;
                Ce3_n <= 1;
            end
            Ce4_n <= 0;            
        end else begin  // target =0
            if (Ce2_n == 0 | Ce3_n == 0 | Ce4_n == 0 ) begin
                Ce2_n <= 1;
                Ce3_n <= 1;
                Ce4_n <= 1;
            end
            Ce_n <= 0;
        end
    end
    endtask
*/
    
    task disable_device;
    input [1:0] dev;
    begin
        if (sync_mode) begin //can't transition Ce pin while data is on Io/Dq
        end
        case (dev)
        2'b00 : Ce_n  <= 1;
        2'b01 : Ce2_n <= 1;
        2'b10 : Ce3_n <= 1;
        2'b11 : Ce4_n <= 1;
        endcase
    end
    endtask

    // Wait Ready : wait for [ready]->busy->ready
    task wait_ready;
    begin
        if (device == 1) begin
//        if (device == 1 | device ==3) begin  // ??? revisit
            if (Rb2_n === 1) begin
                if (($realtime - tm_wen_pos) < tWB_max) #tWB_max;
                wait (Rb2_n === 1);
            end else if (Rb2_n === 0) begin
                   wait (Rb2_n === 1);
            end
            #tRR_min;
        end else begin
            if (Rb_any_n === 1) begin
                if (sync_mode) begin
                end else begin
                    if (($realtime - tm_wen_pos) < tWB_max) #tWB_max;
                    wait (Rb_any_n === 1);
                end
            end else if (Rb_any_n === 0) begin
                   wait (Rb_any_n === 1);
            end
            #tRR_min;
        end
    end
    endtask


    //pulse Re_n to latch read data
    task latch_read;
//    parameter trl=tRP;
//    parameter trh=(tRC - tRP);
      real tCCS;
      real tCCS_cache;
    begin
        Cle = 0;
        Ale = 0;
        //Determine how long to wait after the last command latch before toggling Re_n
        //  tCCS is required during a column address change
        //  not all designs have tCCS defined, so tWHR would be the default in that case
        tCCS_cache  = (tCCS_cache_min > tWHR_cache_min) ? tCCS_cache_min : tWHR_cache_min;
        tCCS        = (tCCS_min > tWHR_min)             ? tCCS_min       : tWHR_min;
            
        //if last We_n posedge is recent, need to wait to avoid timing violation
        if (cache_mode) begin
            if (($realtime - tm_wen_pos) < tCCS_cache) begin
                #(tCCS_cache - ($realtime - tm_wen_pos));
            end
        end else begin
            if (($realtime - tm_wen_pos) < tCCS) begin
                #(tCCS - ($realtime - tm_wen_pos));
            end
        end
        if (($realtime - tm_rbn_pos) < tRR_min) begin
            #(tRR_min - ($realtime - tm_rbn_pos));
        end
        if (($realtime - tm_cen_neg) < tCLR_min) begin
            #(tCLR_min - ($realtime - tm_cen_neg));
        end        
        Re_n <= 0;
        if (enable_rd_verify) begin //if using this testbench to check the data, enable_rd_verify will be active
            if (cache_mode) begin
                if (tm_cen_neg + tCEA_cache_max > $realtime) begin
                    rd_verify <= #(tCEA_cache_max +1) 1'b1;
                end else begin
                    rd_verify <= #(tREA_cache_max +1) 1'b1;
                end
            end else begin
                if (tm_cen_neg + tCEA_max > $realtime) begin
                    rd_verify <= #(tCEA_max +1) 1'b1;
                end else begin
                    rd_verify <= #(tREA_max +1) 1'b1;
                end
            end  
        end
        #(tRP);
        Re_n <= 1;
        #(tRC-tRP);
    end
    endtask

    //pulse Re_n to latch read data
    //special timing for Programmable DriveStrength
    task latch_read_pio;
    parameter trl=tRPIO_min;
    parameter trh=tRPIO_min;
    begin
        Cle = 0;
        Ale = 0;
          Re_n <= 0;
        if (enable_rd_verify) begin //if using this testbench to check the data, enable_rd_verify will be active
            rd_verify <= #(tREAIO_max +1) 1'b1;
        end  
        #(trl);
          Re_n <= 1;
        #(trh);
    end
    endtask


    task latch_address;
    input [7 : 0] addr_in;

    reg we_setup;
    reg ale_setup;
    reg cle_setup;
    reg ce_setup;
    reg io_setup;
    reg ale_hold;
    reg we_hold;
    reg io_hold;
    begin
        if (sync_mode) begin
        end else begin
            //these allow us to keep track of how far from the previous
            // signal edge we are in real time.  No need to delay the 
            // We_n transitions of timing checks are already met
            we_setup = 0;
            ale_setup = 0;
            cle_setup = 0;
            ce_setup = 0;
            io_setup = 0;
        
            ale_hold = 0;
            we_hold = 0;
            io_hold = 0;
            
            Ale = 1'b1;
            Io[7:0] = addr_in;
`ifdef x16
                Io[15:8] = 8'b0;
`endif
            
            if (($realtime - tm_wen_pos) < tWH) begin
                #($realtime - tm_wen_pos);
            end
            We_n = 1'b0;
        
            //Check Cle        
            if (cache_mode) begin
                if (($realtime - tm_cle_pos) < tCLS_cache_min) begin 
                    cle_setup <= #(tCLS_cache_min - ($realtime - tm_cle_neg)) 1'b1;
                end else begin
                    cle_setup = 1'b1;
                end
            end else begin
                if (($realtime - tm_cle_pos) < tCLS_min) begin 
                    cle_setup <= #(tCLS_min - ($realtime - tm_cle_neg)) 1'b1;
                end else begin
                    cle_setup = 1'b1;
                end
            end
            //Check Ce_n
            if (cache_mode) begin
                if (($realtime - tm_cen_neg) < tCS_cache_min) begin 
                    ce_setup <= #(tCS_cache_min - ($realtime - tm_cen_neg)) 1'b1;
                end else begin
                    ce_setup = 1'b1;
                end
            end else begin
                if (($realtime - tm_cen_neg) < tCS_min) begin 
                    ce_setup <= #(tCS_min - ($realtime - tm_cen_neg)) 1'b1;
                end else begin
                    ce_setup = 1'b1;
                end
            end
            //Check Cle setup
            if (cache_mode) begin
                ale_setup <= #tALS_cache_min 1'b1;
                io_setup  <= #tDS_cache_min 1'b1;
            end else begin
                ale_setup <= #tALS_min 1'b1;
                io_setup  <= #tDS_min 1'b1;
            end
            we_setup <= #tWP 1'b1;
    
            //wait for all setup times to be met
            wait (we_setup && ale_setup && cle_setup && ce_setup && io_setup);
            We_n = 1;
            
            if (cache_mode) begin
                ale_hold <= #tALH_cache_min 1'b1;
                io_hold <= #tDH_cache_min 1'b1;
            end else begin
                ale_hold <= #tALH_min 1'b1;
                io_hold <= #tDH_min 1'b1;
            end
            //user defined or default value
            we_hold <= #tWH 1'b1;
              
            //wait for hold times to be met
            wait (we_hold && io_hold && ale_hold);
            Ale = 0;
            Io = {DQ_BITS{1'bz}};
        end
    end
    endtask



    //latches the command on IO on posedge We_n
    task latch_command;
    input [DQ_BITS - 1 : 0] data_in;
    reg we_setup;
    reg ale_setup;
    reg cle_setup;
    reg ce_setup;
    reg io_setup;
    reg trhw_setup;
    reg cle_hold;
    reg ce_hold;
    reg ale_hold;
    reg we_hold;
    reg io_hold;
    real delay;
    begin
        if (sync_mode & por) begin
        end else begin
            //these allow us to keep track of how far from the previous
            // signal edge we are in real time.  No need to delay the 
            // We_n transitions of timing checks are already met
            we_setup = 0;
            ale_setup = 0;
            cle_setup = 0;
            ce_setup = 0;
            io_setup = 0;
            trhw_setup = 0;

            cle_hold = 0;
            ce_hold = 0;
            ale_hold = 0;
            we_hold = 0;
            io_hold = 0;

            //If pulsing Re_n to read data was the 
            //last op, wait for the x's to clear as 
            //the device may or may not still be driving
            //data during the 'x' time.  Need to wait for 
            //the Io bus to be high impedance.
            `ifdef BUS2
            wait (IO2 !== {DQ_BITS{1'bx}});
            `else
            wait (IO !== {DQ_BITS{1'bx}});
            `endif
            Cle = 1'b1;
            Io = data_in;

            //if we just finished a read, wait for tRHW to be met
            if (($realtime - tm_ren_pos) < tRHW_min) begin 
                trhw_setup <= #(tRHW_min - ($realtime - tm_ren_pos)) 1'b1;
                We_n <= #(tRHW_min - ($realtime - tm_ren_pos)) 1'b0;
                we_setup <= #(tRHW_min - ($realtime-tm_ren_pos) + tWP) 1'b1;
            end else begin
                trhw_setup = 1'b1;
                We_n = 1'b0;
                we_setup <= #tWP 1'b1;
            end
            //Check Ale        
            if (cache_mode) begin
                if (($realtime - tm_ale_neg) < tALS_cache_min) begin 
                    ale_setup <= #(tALS_cache_min - ($realtime - tm_ale_neg)) 1'b1;
                end else begin
                    ale_setup = 1'b1;
                end
            end else begin
                if (($realtime - tm_ale_neg) < tALS_min) begin 
                    ale_setup <= #(tALS_min - ($realtime - tm_ale_neg)) 1'b1;
                end else begin
                    ale_setup = 1'b1;
                end
            end
            //Check Cle setup
            if (cache_mode) begin
                cle_setup <= #tCLS_cache_min 1'b1;
                io_setup  <= #tDS_cache_min 1'b1;
            end else begin
                cle_setup <= #tCLS_min 1'b1;
                io_setup  <= #tDS_min 1'b1;
            end
        
            //Check Ce_n
            #1;
            if (cache_mode) begin
                if ((Ce_n === 1'b0) && (($realtime - tm_cen_neg) < tCS_cache_min)) begin 
                    ce_setup <= #(tCS_cache_min - ($realtime - tm_cen_neg)) 1'b1;
                end else if ((Ce2_n === 1'b0) && (($realtime - tm_ce2n_neg) < tCS_cache_min)) begin
                    ce_setup <= #(tCS_cache_min - ($realtime - tm_ce2n_neg)) 1'b1;
                end else begin
                    ce_setup = 1'b1;
                end
            end else begin
                if ((Ce_n === 1'b0) && (($realtime - tm_cen_neg) < tCS_min)) begin 
                    ce_setup <= #(tCS_min - ($realtime - tm_cen_neg)) 1'b1;
                end else if ((Ce2_n === 1'b0) && (($realtime - tm_ce2n_neg) < tCS_min)) begin
                    ce_setup <= #(tCS_min - ($realtime - tm_ce2n_neg)) 1'b1;
                end else begin
                    ce_setup = 1'b1;
                end
            end
        
            //wait for all setup times to be met
            wait (we_setup && ale_setup && cle_setup && ce_setup && io_setup && trhw_setup);
            We_n = 1;
        
            if (cache_mode) begin
                cle_hold <= #tCLH_cache_min 1'b1;
                ale_hold <= #tALH_cache_min 1'b1;
                io_hold <= #tDH_cache_min 1'b1;
            end else begin
                cle_hold <= #tCLH_min 1'b1;
                ale_hold <= #tALH_min 1'b1;
                io_hold <= #tDH_min 1'b1;
            end
            //user defined or default value
            we_hold <= #tWH 1'b1;
          
            //wait for hold times to be met
            wait (we_hold && io_hold && ale_hold && cle_hold);
            Cle = 0;
            if ((Io[7:0] !== 8'h70) && (Io[7:0] !== 8'h78)) lastCmd = Io;
            Io = {DQ_BITS{1'bz}};
        end
    end
    endtask


    task latch_command_pio;
    input [DQ_BITS - 1 : 0] data_in;
    begin
        #(tRHW_min + tCLSIO_min);  
         We_n = 0;
        Ale = 0;
        Cle = 1;
        Io = data_in;
        #tWPIO_min;     
        We_n = 1;
        #(tWHIO_min + tCLHIO_min); 
        Cle = 0;
        Io = {DQ_BITS{1'bz}};
    end
    endtask


    task latch_data_sync;
        input [DQ_BITS -1: 0] data0_in;
        input [DQ_BITS -1: 0] data1_in;
    begin
    end
    endtask
    
    //pulse we to latch write data

    task latch_data_async;
        input [DQ_BITS - 1 : 0] data_in;
    begin
        We_n = 0;
        Io = data_in;
        //tWP is almost always > tDS_min
        //tWH is almost always > tDH_min
        if (tWP > tDS_min) begin
            #tWP;
        end else begin
            #tDS_min;
        end
        //wait for tCCS if this was a column change
        if ((($realtime - tm_wen_pos) < tCCS_min) && ((lastCmd === 8'h85) || (lastCmd === 8'hE0))) begin
            #(tCCS_min - ($realtime - tm_wen_pos));
        end
        We_n = 1;
        if (tWH > tDH_min) begin
            #tWH;
        end else begin
            #tDH_min;
        end
        Io = {DQ_BITS{1'bz}};
    end
    endtask
    

    task latch_data_pio;
        input [DQ_BITS - 1 : 0] data_in;
    begin
        #(tWPIO_min - (tWHIO_min - tDHIO_min));
      We_n = 0;
        Ale = 0;
        #(tWPIO_min-tDSIO_min);  
        Ale = 0;
        Io = data_in;
        #tWPIO_min;       // 10 ns
      We_n = 1;
        #(tWCIO_min - tWPIO_min);
        //#tDH_min;
        Io = {DQ_BITS{1'bz}};
        #(tWHIO_min-tDHIO_min);
    end
    endtask

    // Status Read (70h)
    task status_read;
    begin
        $display ("%m at time %t", $realtime);
          latch_command (8'h70);
        #tWHR_min;
    end
    endtask

    //No Op
    task nop;
    input trc;
    real trc;
    begin
        #trc;
    end
    endtask

    task go_idle;
    begin
    end
    endtask
    
    // 0 = regular lock, 1 = locktight
    task lock_block;
    input locktight;
    begin
        if (locktight === 1'b1) begin
            latch_command(8'h2C);
        end else begin
            latch_command(8'h2A);
        end
    end
    endtask

    task get_drivestrength;
    begin
        // Decode Command
        latch_command_pio (8'hB8);
        #tWHRIO_min;
    end
    endtask

    task set_drivestrength;
        input [7 : 0] drivestrength;
    begin
        // Decode Command
        latch_command_pio (8'hB8);
        latch_data_pio (drivestrength);
        #tWHRIO_min;
    end
    endtask

    task get_features;
        input [7 : 0] feature_address;
    begin
        latch_command (8'hEE);
        latch_address (feature_address);
        //use wait_ready task to wait for busy to return inactive
        //then use serial_read task to output data
    end
    endtask

    task set_features;
        input [7 : 0] feature_address;
        //these are defined as only 8 bit features regardless of DQ_BITS width
        input [7:0] p1;
        input [7:0] p2;
        input [7:0] p3;
        input [7:0] p4;
    begin

        Ce_n <=0;
        if (feature_address == 8'h01) begin
            Ce2_n <= 0;
        end
        if (sync_mode == 0) begin
            #tCS_min; //avoid CE setup time violation if we're in async mode
        end
        latch_command (8'hEF);
        latch_address (feature_address);
        #tADL_min;
        if (sync_mode) begin
            latch_data_sync (p1,p1);
            latch_data_sync (p2,p2);
            latch_data_sync (p3,p3);
            latch_data_sync (p4,p4);
            go_idle;
        end else begin
            latch_data_async (p1);
            latch_data_async (p2);
            latch_data_async (p3);
            latch_data_async (p4);
        end
    end
    endtask

    // multi die status read
    task multi_die_status_read;
        input [BLCK_BITS + LUN_BITS - 1 : 0] blck_addr;

        reg   [DQ_BITS - 1 : 0] row_addr_1;
        reg   [DQ_BITS - 1 : 0] row_addr_2;
        reg   [DQ_BITS - 1 : 0] row_addr_3;
        reg   [23          :00] tsk_row_addr;
    begin
        // Decode Address
        tsk_row_addr = fn_row_addr(blck_addr, 0, 1'b0);
        row_addr_1 = tsk_row_addr[07:00];
        row_addr_2 = tsk_row_addr[15:08];
        row_addr_3 = tsk_row_addr[23:16];

        // Decode Command
        latch_command (8'h78);
        latch_address (row_addr_1);
        latch_address (row_addr_2);
        latch_address (row_addr_3);
        #(tWHR_min);
    end
    endtask

    // multi die status wo read
    task multi_die_status_wo_read;
        input [BLCK_BITS + LUN_BITS - 1 : 0] blck_addr;

        reg   [DQ_BITS - 1 : 0] row_addr_1;
        reg   [DQ_BITS - 1 : 0] row_addr_2;
        reg   [DQ_BITS - 1 : 0] row_addr_3;
        reg   [23          :00] tsk_row_addr;
    begin
        // Decode Address
        tsk_row_addr = fn_row_addr(blck_addr, 0, 1'b0);
        row_addr_1 = tsk_row_addr[07:00];
        row_addr_2 = tsk_row_addr[15:08];
        row_addr_3 = tsk_row_addr[23:16];

        // Decode Command
        latch_command (8'h78);
        latch_address (row_addr_1);
        latch_address (row_addr_2);
        latch_address (row_addr_3);
    end
    endtask

    // locked block status read
    task block_lock_status_read;
        input [BLCK_BITS + LUN_BITS - 1 : 0] blck_addr;

        reg   [DQ_BITS - 1 : 0] row_addr_1;
        reg   [DQ_BITS - 1 : 0] row_addr_2;
        reg   [DQ_BITS - 1 : 0] row_addr_3;
        reg   [23          : 0] tsk_row_addr;
    begin
        // Decode Address
        tsk_row_addr = fn_row_addr(blck_addr, 0, 1'b0);
        row_addr_1 = tsk_row_addr[07:00];
        row_addr_2 = tsk_row_addr[15:08];
        row_addr_3 = tsk_row_addr[23:16];

        // Decode Command
        latch_command (8'h7A);
        latch_address (row_addr_1);
        latch_address (row_addr_2);
        latch_address (row_addr_3);
        #tWHR_min;
    end
    endtask

    task unlock_block;
        input [BLCK_BITS + LUN_BITS - 1 : 0] blck_addr_one;
        input [BLCK_BITS + LUN_BITS - 1 : 0] blck_addr_two;
        input invert;

        reg   [DQ_BITS - 1 : 0] row_addr_1_one;
        reg   [DQ_BITS - 1 : 0] row_addr_2_one;
        reg   [DQ_BITS - 1 : 0] row_addr_3_one;
        reg   [DQ_BITS - 1 : 0] row_addr_1_two;
        reg   [DQ_BITS - 1 : 0] row_addr_2_two;
        reg   [DQ_BITS - 1 : 0] row_addr_3_two;
        reg   [23          : 0] tsk_row_addr;
        reg   [23          : 0] tsk_row_addr2;

    begin
        tsk_row_addr   = fn_row_addr(blck_addr_one, 0, 1'b0);
        row_addr_1_one = {tsk_row_addr[07:01], (tsk_row_addr[00] | invert)};
        row_addr_2_one = tsk_row_addr[15:08];
        tsk_row_addr2  = fn_row_addr(blck_addr_two, 0, 1'b0);
        row_addr_1_two = {tsk_row_addr2[07:01], (tsk_row_addr2[00] | invert)};
        row_addr_2_two = tsk_row_addr2[15:08];
        row_addr_3_one = tsk_row_addr[23:16];
        row_addr_3_two = tsk_row_addr2[23:16];
        // Decode Command
        latch_command (8'h23);
        latch_address (row_addr_1_one);
        latch_address (row_addr_2_one);
        latch_address (row_addr_3_one);
        latch_command (8'h24);
        latch_address (row_addr_1_two);
        latch_address (row_addr_2_two);
        latch_address (row_addr_3_two);
        #tWHR_min;

    end
    endtask

    // Erase Block (60h -> D0h)
    //      tp     = address is 1st of two planes
    task erase_block;
        input [BLCK_BITS + LUN_BITS - 1 : 0] blck_addr;
        input tp;
        input onfi;

        reg   [DQ_BITS - 1 : 0] row_addr_1;
        reg   [DQ_BITS - 1 : 0] row_addr_2;
        reg   [DQ_BITS - 1 : 0] row_addr_3;
        reg   [23          : 0] tsk_row_addr;
    begin
        // Decode Address
        tsk_row_addr = fn_row_addr(blck_addr, 0, 1'b0);
        row_addr_1 = tsk_row_addr[07:00];
        row_addr_2 = tsk_row_addr[15:08];
        row_addr_3 = tsk_row_addr[23:16];
        // Decode Command
        latch_command (8'h60);
        latch_address (row_addr_1);
        latch_address (row_addr_2);
        latch_address (row_addr_3);
        if (~tp) begin
            latch_command (8'hD0);
        end else if (onfi) begin
            latch_command (8'hD1);
        end
        #tRR_min;
    end
    endtask

    // Multi-Plane Page Read (00h -> 32h)
    // blck_addr = block address
    // page_addr = page address
    //  col_addr = column address
    //
    // This is an ONFI 2.0 command : queues a plane to be read during a multi-plane page read
    //
    task multiplane_read_page;
        input [BLCK_BITS + LUN_BITS - 1 : 0] blck_addr;
        input [PAGE_BITS - 1 : 0] page_addr;
        input [COL_BITS - 1 : 0]  col_addr;

        reg   [DQ_BITS - 1 : 0] col_addr_1;
        reg   [DQ_BITS - 1 : 0] col_addr_2;
        reg   [DQ_BITS - 1 : 0] row_addr_1;
        reg   [DQ_BITS - 1 : 0] row_addr_2;
        reg   [DQ_BITS - 1 : 0] row_addr_3;
        reg   [23          :00] tsk_row_addr;

    begin
        // Decode Address
        col_addr_1 [7 : 0] = col_addr [7 : 0];
        col_addr_2 [7 : 0] = {{(16 - COL_BITS){1'b0}}, col_addr [(COL_BITS -1) : 8]};
        tsk_row_addr = fn_row_addr(blck_addr, page_addr, 1'b1);
        row_addr_1 = tsk_row_addr[07:00];
        row_addr_2 = tsk_row_addr[15:08];
        row_addr_3 = tsk_row_addr[23:16];
        // latch command and address sequence
        latch_command (8'h00);
        latch_address (col_addr_1);
        latch_address (col_addr_2);
        latch_address (row_addr_1);
        latch_address (row_addr_2);
        latch_address (row_addr_3);
        latch_command (8'h32);
    end
    endtask //multiplane_read_page
    
    // Page Read (00h -> [30h])
    // blck_addr = block address
    // page_addr = page address
    //  col_addr = column address
    //      tp     = address is 1st of two planes
    //    idm    = read for internal data move
    //    otp    = OTP page read
    //
    // For twoplane, first issue read_page with tp=1, output == 00h with address
    //                 followed by read_page with tp=0, output == 00h with address and 30h
    //
    task read_page;
        input [BLCK_BITS + LUN_BITS - 1 : 0] blck_addr;
        input [PAGE_BITS - 1 : 0] page_addr;
        input [COL_BITS - 1 : 0]  col_addr;
        input tp;
        input idm;
        input otp;
        input copyback2;

        reg   [DQ_BITS - 1 : 0] col_addr_1;
        reg   [DQ_BITS - 1 : 0] col_addr_2;
        reg   [DQ_BITS - 1 : 0] row_addr_1;
        reg   [DQ_BITS - 1 : 0] row_addr_2;
        reg   [DQ_BITS - 1 : 0] row_addr_3;
        reg   [23          :00] tsk_row_addr;

    begin
        //once another page read starts, we're not in cache page read anymore
        if (otp && (tp || idm)) $display("%m at time %t: ERROR: Illegal task option.  Can't read OTP page with twoplane or internal data move", $realtime);
        // Decode Address
        col_addr_1 [7 : 0] = col_addr [7 : 0];
        col_addr_2 [7 : 0] = {{(16 - COL_BITS){1'b0}}, col_addr [(COL_BITS -1) : 8]};
        tsk_row_addr = fn_row_addr(blck_addr, page_addr, 1'b1);
        row_addr_1 = tsk_row_addr[07:00];
        row_addr_2 = tsk_row_addr[15:08];
        row_addr_3 = tsk_row_addr[23:16];
        // Decode Command
        if (otp) begin
            latch_command (8'hAF);
        end else begin
            latch_command (8'h00);
        end
        latch_address (col_addr_1);
        latch_address (col_addr_2);
        latch_address (row_addr_1);
        if (otp) begin
            latch_address (8'h00);
            latch_address (8'h00);
        end else begin
            latch_address (row_addr_2);
            latch_address (row_addr_3);
        end

        if (~tp) begin
            if (idm) begin
                latch_command (8'h35);
            end else begin
                if (copyback2) begin
                    latch_command (8'h3A);
                end else begin
                    latch_command (8'h30);
                end
            end
        end
        //$display("%m at time %t: INFO: Read Page block addr=%s, page addr=%s, column addr=%s", $realtime,blck_addr, page_addr, col_addr);
    end
    endtask
    
    task cache_read;
    input last;
    begin
        if (last) begin
            latch_command(8'h3F);
        end else begin
            latch_command(8'h31);
        end
    end
    endtask

    task cache_read_random;
      input [BLCK_BITS + LUN_BITS - 1 : 0] blck_addr;
      input [PAGE_BITS - 1 : 0] page_addr;
      input [COL_BITS - 1 : 0]  col_addr;

      reg   [DQ_BITS - 1 : 0] col_addr_1;
      reg   [DQ_BITS - 1 : 0] col_addr_2;
      reg   [DQ_BITS - 1 : 0] row_addr_1;
      reg   [DQ_BITS - 1 : 0] row_addr_2;
      reg   [DQ_BITS - 1 : 0] row_addr_3;
      reg   [23          :00] tsk_row_addr;
    begin
        col_addr_1 [7 : 0] = col_addr [7 : 0];
        col_addr_2 [7 : 0] = {{(16 - COL_BITS){1'b0}}, col_addr [(COL_BITS -1) : 8]};
        tsk_row_addr = fn_row_addr(blck_addr, page_addr, 1'b1);
        row_addr_1 = tsk_row_addr[07:00];
        row_addr_2 = tsk_row_addr[15:08];
        row_addr_3 = tsk_row_addr[23:16];

        latch_command (8'h00);
        latch_address (col_addr_1);
        latch_address (col_addr_2);
        latch_address (row_addr_1);
        latch_address (row_addr_2);
        latch_address (row_addr_3);
        latch_command (8'h31);
    end
    endtask

    //tp =  0 = page random data (2 address cycles)
    //      1 = two-plane random data (5 address cycles)
    task random_data_read;
        input [BLCK_BITS + LUN_BITS - 1 : 0] blck_addr;
        input [PAGE_BITS - 1 : 0] page_addr;
        input [COL_BITS - 1 : 0]  col_addr;
        input tp;

        reg   [DQ_BITS - 1 : 0] col_addr_1;
        reg   [DQ_BITS - 1 : 0] col_addr_2;
        reg   [DQ_BITS - 1 : 0] row_addr_1;
        reg   [DQ_BITS - 1 : 0] row_addr_2;
        reg   [DQ_BITS - 1 : 0] row_addr_3;
        reg   [23          :00] tsk_row_addr;
    begin
        col_addr_1 [7 : 0] = col_addr [7 : 0];
        col_addr_2 [7 : 0] = {{(16 - COL_BITS){1'b0}}, col_addr [(COL_BITS -1) : 8]};
        tsk_row_addr = fn_row_addr(blck_addr, page_addr, 1'b1);
        row_addr_1 = tsk_row_addr[07:00];
        row_addr_2 = tsk_row_addr[15:08];
        row_addr_3 = tsk_row_addr[23:16];

        if (tp) begin
            latch_command (8'h06);
            latch_address (col_addr_1);
            latch_address (col_addr_2);
            latch_address (row_addr_1);
            latch_address (row_addr_2);
            latch_address (row_addr_3);
        end else begin
            latch_command (8'h05);
            latch_address (col_addr_1);
            latch_address (col_addr_2);
        end
        latch_command (8'hE0);
        #tWHR_min;
    end
    endtask

    // Program Page (80h -> 10h)
    // blck_addr = block address
    // page_addr = page address
    //  col_addr = column address
    //      data = your first data value
    //      size = number of serial data to be written
    //   pattern = modify data pattern
    //             00 = no change
    //             01 = inc
       //             10 = dec
      //             11 = random

    //    tp     = address is 1st of two planes
    //    idm    = program for internal data move
    //                 0 = no idm
    //               1 = program for internal data move (for 2plane, 1st half of idm program)
    //    otp    = OTP page read
    //     cache   = cache mode program (not last page)
    //   final  = if low, will not finalize write -- indicates that a random data write will follow
    task program_page;
        input [BLCK_BITS + LUN_BITS - 1 : 0] blck_addr;
        input [PAGE_BITS - 1 : 0] page_addr;
        input [COL_BITS  - 1 : 0] col_addr;
        input [DQ_BITS - 1 : 0] data;
        input [COL_BITS  - 1 : 0] size;
        input             [1 : 0] pattern;
        input tp;
        input idm;
        input otp;
        input cache;
        input copyback2;
        input finalCmd;

        reg   [DQ_BITS - 1 : 0] col_addr_1;
        reg   [DQ_BITS - 1 : 0] col_addr_2;
        reg   [DQ_BITS - 1 : 0] row_addr_1;
        reg   [DQ_BITS - 1 : 0] row_addr_2;
        reg   [DQ_BITS - 1 : 0] row_addr_3;
        reg   [23          :00] tsk_row_addr;
        reg   [COL_BITS  - 1 : 0] i;
    begin

        if (otp && (tp || idm || cache)) $display("%m at time %t: ERROR: Illegal task option.  Can't write OTP page with cache, twoplane, or internal data move commands", $realtime);

        
        // Decode Address
        col_addr_1 [7 : 0] = col_addr [7 : 0];
        col_addr_2 [7 : 0] = {{(16 - COL_BITS){1'b0}}, col_addr [(COL_BITS -1) : 8]};
        tsk_row_addr = fn_row_addr(blck_addr, page_addr, 1'b1);
        row_addr_1 = tsk_row_addr[07:00];
        row_addr_2 = tsk_row_addr[15:08];
        row_addr_3 = tsk_row_addr[23:16];

        // Decode Command
        if (otp) begin
            latch_command (8'hA0);
        end else begin
            if (idm) begin
                latch_command (8'h85);
            end else begin
                if (copyback2) begin
                    latch_command (8'h8C);
                end else begin
                    latch_command (8'h80);
                end
            end
        end
        latch_address (col_addr_1);
        latch_address (col_addr_2);
        latch_address (row_addr_1);
        if (otp) begin
            latch_address (8'h00);
            latch_address (8'h00);
        end else begin
            latch_address (row_addr_2);
            latch_address (row_addr_3);
        end

        #tADL_min;
                
        if (~idm && (size != 0)) begin
        //only input data if not an internal data move
        //random data writes are in a separate task
            write_data(data, size, pattern);
        end

        // Done Program
        if (finalCmd) begin
            if (tp) begin
                latch_command (8'h11);
            end else begin
                if (cache) begin
                    latch_command (8'h15);
                end else begin
                    //if (~idm[0]) begin
                        latch_command (8'h10);
                    //end
                end
            end
        end
    end
    endtask

// write data pattern, addresses already input
    task write_data;
        input [DQ_BITS - 1 : 0] data;
        input integer size;
        input             [1 : 0] pattern;
        integer i;
    begin
        // Decode Pattern
        if (sync_mode) begin
            for (i = 0; i <= size - 1; i = i + 2) begin
            case (pattern)
                2'b00 : latch_data_sync (data,data);
                2'b01 : latch_data_sync (data + i, data + (i+1));
                2'b10 : latch_data_sync (data - i, data - (i+1));
                2'b11 : latch_data_sync ({$random} % {DQ_BITS{1'b1}}, {$random} % {DQ_BITS{1'b1}});
            endcase
            end
            go_idle;
        end else begin
            for (i = 0; i <= size - 1; i = i + 1) begin
            case (pattern)
                2'b00 : latch_data_async (data);
                2'b01 : latch_data_async (data + i);
                2'b10 : latch_data_async (data - i);
                2'b11 : latch_data_async ({$random} % {DQ_BITS{1'b1}});
            endcase
            end
        end
    end
    endtask

    //used to write data to a random col address on current page
    //    tp     = address is 1st of two planes
    //     cache   = cache mode program (not last page)
    //   final  = if low, will not finalize write -- indicates that a random data write will follow
    task random_data_write;
        input [BLCK_BITS + LUN_BITS - 1 : 0]  blck_addr;
        input [PAGE_BITS - 1 : 0]  page_addr;
        input [COL_BITS - 1 : 0]  col_addr;
        input [DQ_BITS - 1 : 0] data;
        input [COL_BITS  - 1 : 0] size;
        input             [1 : 0] pattern;
        input tp;
        input cache;
        input finalCmd;
        input column_only; //used to determine whether this is a 5-address row change, or a 2-address column change

        reg   [DQ_BITS - 1 : 0] col_addr_1;
        reg   [DQ_BITS - 1 : 0] col_addr_2;
        reg   [DQ_BITS - 1 : 0] row_addr_1;
        reg   [DQ_BITS - 1 : 0] row_addr_2;
        reg   [DQ_BITS - 1 : 0] row_addr_3;
        reg   [COL_BITS  - 1 : 0] i;
        reg   [23          :00] tsk_row_addr;
    begin
        col_addr_1 [7 : 0] = col_addr [7 : 0];
        col_addr_2 [7 : 0] = {{(16 - COL_BITS){1'b0}}, col_addr [(COL_BITS -1) : 8]};
        tsk_row_addr = fn_row_addr(blck_addr, page_addr, 1'b1);
        row_addr_1 = tsk_row_addr[07:00];
        row_addr_2 = tsk_row_addr[15:08];
        row_addr_3 = tsk_row_addr[23:16];

        latch_command (8'h85);
        latch_address (col_addr_1);
        latch_address (col_addr_2);
        if (~column_only) begin
            latch_address(row_addr_1);
            latch_address(row_addr_2);
            latch_address(row_addr_3);
        end

        #tADL_min;

        write_data(data, size, pattern);

        if (finalCmd) begin
            if (tp) begin
                latch_command (8'h11);
            end else begin
                if (cache) begin
                    latch_command (8'h15);
                end else begin
                    latch_command (8'h10);
                end
            end
        end
    end
    endtask


    task OTP_protect;
    begin
        // Decode Command
        latch_command (8'hA5);
        latch_address (8'h00);
        latch_address (8'h00);
        latch_address (8'h01);
        latch_address (8'h00);
        latch_address (8'h00);
        latch_command (8'h10);
        wait_ready;
    end
    endtask

    // reset (FFh) - 
    task sync_reset;
    begin
`ifdef SO
        por = 1'b1;
`endif
        latch_command (8'hFC);
    end
    endtask

    // reset (FFh) - 
    task reset;
    begin
            latch_command (8'hFF);
            por = 1'b1;
    end
    endtask


    // Read ID (90h) - 
    task read_id;
    integer i;
    begin
        latch_command (8'h90);
        latch_address (0);
        #tWHR_min
        for (i = 0; i < NUM_ID_BYTES; i = i + 1)
            begin 
                latch_read;   // Byte i
            end
    end
    endtask

    //reads static ONFI regs
    task read_onfi;
    begin
        latch_command (8'h90);
        latch_address (8'h20);
        #tWHR_min;
    end
    endtask

    //command address sequence required to access ONFI parameter data page
    //can't really use serial_read here cuz won't know all expected data
    task read_parameter_page;
    begin
        latch_command (8'hEC);
        latch_address (8'h00);
        crc16 =0;
    end
    endtask

// ??? in development
// Copyright (C) 1999-2003 Easics NV.
// Info: tools@easics.be
// http://www.easics.com                                  
  // polynomial: (0 2 15)
  // data width: 8
  // convention: the first serial data bit is D[7]
  function [14:0] nextCRC15_D8;
    input [7:0] Data;
    input [14:0] CRC;
    reg [7:0] D;
    reg [14:0] C;
    reg [14:0] NewCRC;
  begin
    D = Data;
    C = CRC;
    NewCRC[0] = D[0] ^ C[7];
    NewCRC[1] = D[1] ^ C[8];
    NewCRC[2] = D[2] ^ D[0] ^ C[7] ^ C[9];
    NewCRC[3] = D[3] ^ D[1] ^ C[8] ^ C[10];
    NewCRC[4] = D[4] ^ D[2] ^ C[9] ^ C[11];
    NewCRC[5] = D[5] ^ D[3] ^ C[10] ^ C[12];
    NewCRC[6] = D[6] ^ D[4] ^ C[11] ^ C[13];
    NewCRC[7] = D[7] ^ D[5] ^ C[12] ^ C[14];
    NewCRC[8] = D[6] ^ C[0] ^ C[13];
    NewCRC[9] = D[7] ^ C[1] ^ C[14];
    NewCRC[10] = C[2];
    NewCRC[11] = C[3];
    NewCRC[12] = C[4];
    NewCRC[13] = C[5];
    NewCRC[14] = C[6];
    nextCRC15_D8 = NewCRC;
  end
  endfunction


    // Read speacial
    // special = special page read data
    //             0 = read ID2 
    //             1 = read unique
    task read_special;  // Not inherited from read_id, rather from page_read
    input sel;
    reg [12:0] i;
    begin
        latch_command (8'h30);
        latch_command (8'h65);
        latch_command (8'h00);
        latch_address (0);
        if (sel) begin
            //read_unique
            latch_address (0);
        end else begin
            //read_id2
            latch_address (2);
        end
        latch_address (2);
        latch_address (0);
        latch_address (0);
        latch_command (8'h30);
        wait_ready;
        #tRR_min;
        // Serial Read
        for (i = 0; i <= 255; i = i + 1) 
           begin
              latch_read;   // Byte 0
           end
        #tRR_min;
    end
    endtask

    //new ONFI read unique command sequence
    //leave it up to use to latch read data
    task read_unique;
    begin
        latch_command (8'hED);
        latch_address (0);
        #tRR_min;
    end
    endtask


    //pulse Re_n (async) or wait for Dqs (sync) and compares output data to expected value
    task serial_read;
        input [DQ_BITS -1: 0] data;
        input [1:0] pattern;
        input [ROW_BITS -1: 0] size;
        integer i;
        begin
            // Serial Read
            $display ("%m at time %t: READ DATA : size=%0d,\t data=%0h,\t pattern=%0d", $realtime, size, data, pattern);
            //async serial read
            for (i = 0; i <= size - 1; i = i + 1) begin
                latch_and_check_data(data);
                case (pattern)
                    2'b00 : ;
                    2'b01 : data = data + 1;
                    2'b10 : data = data - 1;
                    2'b11 : data = 0;
                endcase
            end
            #tRR_min;    
        end
    endtask

    task serial_read_pio;
        input [DQ_BITS -1: 0] data;
        begin
                latch_and_check_data_pio(data);
                #tRR_min;
        end
    endtask

    task latch_and_check_data;
    input [DQ_BITS -1: 0] exp_data;
    begin
        if (sync_mode) begin
        end else begin
            rd_dq = exp_data;
            //enable rd verify tells the latch read task
            // whether or not to toggle rd_verify to check data              
            enable_rd_verify = 1'b1;
            latch_read;
            enable_rd_verify = 1'b0;
        end
    end
    endtask

    task latch_and_check_data_pio;
    input [DQ_BITS -1: 0] exp_data;
    begin
        rd_dq = exp_data;
        //rd_verify <= 1;
        enable_rd_verify = 1'b1;
        latch_read_pio;
        enable_rd_verify = 1'b0;
    end
    endtask


    `ifdef BUS2
       always @ (posedge rd_verify ) begin
        if (IO2 !== rd_dq) begin
                $display ("%m at time %t: ERROR: Read data miscompare: Expected = %h, Actual = %h", $realtime, rd_dq, IO2);
        end
        crc16 = nextCRC15_D8(IO2,crc16);
        rd_verify <= #1 1'b0;
       end
    `else
       always @ (posedge rd_verify ) begin
        if (IO !== rd_dq) begin
            $display ("%m at time %t: ERROR: Read data miscompare: Expected = %h, Actual = %h", $realtime, rd_dq, IO);
        end
        crc16 = nextCRC15_D8(IO,crc16);
        rd_verify <= #1 1'b0;
       end
    `endif


    reg test_done;
    initial test_done = 0;

    // End-of-test triggered in 'subtest.vh'
    always @(test_done) begin : all_done
        if (test_done == 1) begin
      #5000
      $display ("%m at time %t: Simulation is Complete", $realtime);
            $stop(0);
            $finish;
        end
    end

wire DEADMAN_REQ = 1'b0;
integer   DEADMAN_TIMER = 0;
parameter DEADMAN_LIMIT = 70000000 ;
always @ (posedge Clk_int)
begin
	if (DEADMAN_REQ == 1'b1)
		DEADMAN_TIMER = 0;
	else
		DEADMAN_TIMER = DEADMAN_TIMER + 1 ;
	if (DEADMAN_TIMER == DEADMAN_LIMIT)
	begin
	    $display ("SWM: No Activity in %d Clocks.  Deadman Timer at time %t!!", DEADMAN_TIMER, $time);    
	    $stop();
	end
end

//    task clear_data_regs;
//    input [1:0] die_num;
//    input [1:0] plane;
//    begin
//        case (die_num)
//            2'b00 : force uut.uut_0.clear_data_register(plane);
//            2'b01 : force uut.uut_1.clear_data_register(plane);
//            2'b10 : force uut.uut_2.clear_data_register(plane);
//            2'b11 : force uut.uut_3.clear_data_register(plane);
//        endcase
//    end
//    endtask
//
//    task clear_cache_regs;
//    input [1:0] die_num;
//    input [1:0] plane;
//    begin
//        case (die_num)
//            2'b00 : force uut.uut_0.clear_cache_register(plane);
//            2'b01 : force uut.uut_1.clear_cache_register(plane);
//            2'b10 : force uut.uut_2.clear_cache_register(plane);
//            2'b11 : force uut.uut_3.clear_cache_register(plane);
//        endcase
//    end
//    endtask

`ifdef INIT_MEM
    initial begin
        #1;
        //
        //preloading of mem_array can be done here
        // This approach is more flexible than readmemh
        //
        //        memory_write(block, page, col, mem_select, data)
        //              mem_select : 0 = flash memory array
        //                           1 = OTP array
        //                           2 = special config data array
        //
        uut.uut_0.memory_write(0,0,0, 0, 8'h00);
        uut.uut_0.memory_write(0,0,1, 0, 8'h01);
        uut.uut_0.memory_write(0,0,2, 0, 8'h02);
        uut.uut_0.memory_write(0,0,3, 0, 8'h03);
        uut.uut_0.memory_write(0,0,4, 0, 8'h04);
        uut.uut_0.memory_write(0,0,5, 0, 8'h05);
        uut.uut_0.memory_write(0,0,6, 0, 8'h06);
        uut.uut_0.memory_write(0,0,(NUM_COL-1), 0, 8'hDA);
        #100;
        uut.uut_0.memory_read(0,0,0);
        uut.uut_0.memory_read(0,0,1);
        uut.uut_0.memory_read(0,0,2);
        uut.uut_0.memory_read(0,0,3);
        uut.uut_0.memory_read(0,0,4);
        uut.uut_0.memory_read(0,0,5);
        uut.uut_0.memory_read(0,0,6);
        uut.uut_0.memory_read(0,0,(NUM_COL-1));
    end
`endif

    
    `include "subtest.vh"
    
endmodule
