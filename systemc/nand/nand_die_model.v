/* ---------------------------------------------------------------------------
*
*    File Name:  nand_die_model.V
*        Model:  BUS Functional
* Dependencies:  nand_parameters.vh
*
*        Email:  modelsupport@micron.com
*      Company:  Micron Technology, Inc.
*  Part Number:  MT29F
*
*  Description:  Micron NAND Verilog Model
*
*   Limitation:
*
*         Note:  This model does not model bit errors on read or write.
                 This model is a superset of all supported Micron NAND devices.
                 The model is configured for a particular device's parameters 
                 and features by the required include file, nand_parameters.vh.
*
*   Disclaimer:  THESE DESIGNS ARE PROVIDED "AS IS" WITH NO WARRANTY
*                WHATSOEVER AND MICRON SPECIFICALLY DISCLAIMS ANY
*                IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR
*                A PARTICULAR PURPOSE, OR AGAINST INFRINGEMENT.
*
*                Copyright © 2006-2008 Micron Semiconductor Products, Inc.
*                All rights reserved
*
* Rev  Author          Date        Changes
* ---  --------------- ----------  -------------------------------
* 3.0      smk          10/13/2006  - Update of all previous NAND models. (2.x and below)
*                                     First release of new model capable of 
*                                     supporting all NAND products
* 3.1      smk          11/01/2006  - Added support for get/set features commands.
* 3.2      smk          11/28/2006  - Added ONFI read parameters support.
* 3.3      smk          01/09/2007  - Improved error handling
* 3.4      smk          01/18/2007  - Fixed page read problem when readmemh is
*                                     used to preload the flash array.
*                                     Fixed read behavior when Ce_n transitions
*                                     before Re_n
* 3.5      smk          06/13/2007  - Improved ONFI parameters page support  
* 4.0      smk          08/14/2007  - Fixed typo in clear_data_register task
*                                   - Fixed max block addressing issue
*                                   - Fixed IO tristate issue when Ce_n transitions under
*                                     certail conditions
*                                   - Disabled Erase during OTP mode
* 4.1      smk          11/7/2007   - Fixed problem where model did not exit read_unique_id mode. 
* 4.11     smk          11/16/2007  - Fixed read problem after change column addr following a 
*									  return to read mode after read status (78h-00h-05h-E0h) 
* 4.12     smk          01/16/2008  - Fixed 00h issue following multi-die-status read after
*                                     a non-multiplane operation on multi-plane devices with 
*									  multiple dies per CE
*						01/16/2008  - Fixed column addressing issue 
* 4.20     smk          02/12/2008  - Fixed CACHE READ LAST causing false error on
*                                   - block boundary crossing.
*                                   - Fixed missing Data and Dqs on last data byte read
* 4.21     smk          02/29/2008  - Fixed various ONFI 2.0 High-Speed NAND timing checks
* 4.22     smk          04/18/2008  - Fixed bad Io value when Re_n and Rb_n transition too
*                                     closely together
*                                   - Fixed tCAD issues
*							        - Fixed false tCSS timing violations during status read
* 4.30     smk          05/12/2008  - Added ONFI OTP lock_by_page support for certain devices
*                                   - Added boot block support for certain devices
*                                   - More tCAD fixes for high-speed nand devices
* 4.40     jmk          06/18/2008  - Fixed reset for ONFI features register 1
* 4.43     jjc          07/26/2008  - modified die_select to fix status_read cmd issued to ce2# device
* 4.50     jjc          08/18/2008  - qualified sync mode ale_del and cle_del to write operations fixes
*                                     read status 70h col_counter issue.  
*                                   - Added latch column address disable for erase block commands
*                                   - Commented clear_queued_planes from 00h read page commands
*                                   - Added logic to clear_queued_planes following read completion commands
*                                   - Added Copyback2 command qualifier to Cache Mode Command 11h for queuing
* 4.60    jjc           08/26/2008  - Added support for DAO part, including removal of cache register
*                                     dependency on program page with bypass_cache.  Added programmable MLC/SLC
*                                     and Bits Per Cell logic, common col counter fn, feature registers.
* 4.61    jjc           09/10/08    - added check for read following cache ready, array busy on program page
*                                   - Added sync to async mode for Reset command FFh.  
*                                   - Modified sync output data task with precomputed values to speed sims.  
*                                   - Added Program Page Cache Last Page timing support. 
* 4.62    jjc           09/16/08    - CMD 00h modified to reflect the switch from status mode to read mode,
*                                     rather than a guaranteed read operation.  
*                                     Read operation is signaled with address cycles.
* 4.62_col jjc          09/30/08    - Removed column loops, initializing of whole mem array in assoc array mode.
*                                   - Moved initializing mem array to write and erase tasks increasing performance.
* 4.63    jjc           10/15/08    - BPC_MAX, data reg, data reg out fixes for syntax issues related to vcs sims.
* 4.64   jjc            10/28/08    - Updated Feature Address for Drive Strength Output with M51H part
* 4.90   jjc            10/16/08    - Generated pre-computed values to improve performance.
*                                   - nand_mode[0] set onfi features and page sizing updates.
*                                   - sub_col_cnt divide fix.
* 5.00   jjc            11/05/08    - OTP fixes for addressing overflow limits and initialization. Added support for otp array in nand mode[0].
*                                   - Fixed Feature Address support for Drive Strength Output, between 80h and 10h addresses.
*                                   - Added Boot Block Lock Support.  Removed dependence of COL BITS from col counter.  
*                                   - Fixed type casting issues. Updated onfi features.  
*                                   - Fixed Random data read command issue following mult status read.  
*                                   - Allow set features to complete with WP# active.  
*                                   - Fixed error with Read Parameter Page cmd EC in nand_mode[0].
* 5.10   jjc            11/11/08    - Fixed Multi-die issue with Read ID Command.  
*                                   - Fixed memory_write and memory read tasks to handle DQ_BITS to page transfers to mem_array.  
* 5.20   jjc            12/10/08    - Added Multi-plane and Multi-Lun support.
*                                   - Fixed Race condition on clear_queued_planes.  
*                                   - Fix: clear sub col cnt during read cache sequ and read cache last ops
*                                   - Fix: disable ready during cache op, waiting for prev. cache to complete.
* 5.21   jjc            12/18/08    - Fix: Read Status prior to Read Command, needed to clear queued planes 
*                                           for MP/TP, added saw_cmnd_00h_stat logic.
* 5.22  jjc             1/14/09     - Fix: Blck Limit Exceeded error, remove = number of blocks, only greater than.  
* 5.30   jjc            1/5/09      - Added multiplane qualifiers for MP vs 2P.  Updated column counter for async data.  
*                                   - Moved copy_datareg_to_cachereg into load reg cache mode task.  
*                                   - Removed col valid from 3Ah cmd, 00h cmd should have set.  
* 6.00  jjc             1/30/09     - Multi-Lun back to back reads and erase blocks to different dies: 
*                                     removed task timing issues, allows die-select and cmd ident.  
*                                   - Modified column address logic for multi-lun operations, including change read column/write column ops and
*                                     die-select updates.
*                                   - Modified async read data output to support MLC data outputs.  
*                                   - Added Multi-plane with cache support.  
*                                   - Modified Mulitple plane access to two-plane device plane addresses to return to plane 0 with cmd completion.  
*                                   - Updated support for variable number of otp program partial cmds independent of non-otp program partial cmds.  
* 6.10  jjc             2/12/09      - Added clear ONFI Read signal in Read ID cmd.  Read ID (90h) following Read Parameter Page (ECh), did not
*                                     clear ONFI Read signal, thus Read ID did not load data into the data output.  
*                                   - Added CE Setup check in sync mode.  
*                                   - Sync Mode Reset updates.  
--------------------------------------------------------------------------- */
`timescale 1ns / 1ps

module nand_die_model (Io, Cle, Ale, Ce_n_i, Clk_We_n, Wr_Re_n, Wp_n, Rb_n, Pre, Lock, Dqs, ML_rdy, Rb_lun_n, PID);

`include "nand_parameters.vh"

//-----------------------------------------------------------------
// DEBUG options
//-----------------------------------------------------------------
// DEBUG[0] = debug
// DEBUG[1] = multi die debug
// DEBUG[2] = data debug
// DEBUG[3] = command debug
// DEBUG[4] = queued planes debug
parameter DEBUG = 5'b00000;

// set this parameter to match the inverse of the timescale "a / b" ratio
// This parameter is used to make small adjustments to timing checks that
//  have rounding problems that arise from large numbers and time resolution
//  For example: 1ns / 1ps,   TS_RES_ADJUST = 0.001
//  example 2:   1ps / 1ps,    TS_RES_ADJUST = 1
parameter TS_RES_ADJUST = 0.001;

//----------------------------------
//Model limit parmaeters
//----------------------------------
parameter MAX_BLOCKS =  (1 << BLCK_BITS) -1;
parameter MAX_COL    =   (1 << COL_BITS) -1;
parameter MAX_ROWS   =   (1 << ROW_BITS) -1;
parameter NUM_ONFI_PARAMS =             768; //# of required ONFI parameter bytes (including redundancies) 
parameter PRELOAD_SIZE    =               0; // Redefine this param during instantiation if defining INIT_MEM to preload mem_array via readmemh

//----------------------------------
//Supported command set parameters
//----------------------------------
parameter CMD_BASIC     =   4'h0;
parameter CMD_NEW       =   4'h1;
parameter CMD_ID2       =   4'h2;
parameter CMD_UNIQUE    =   4'h3;
parameter CMD_OTP       =   4'h4;
parameter CMD_2PLANE    =   4'h5;
parameter CMD_ONFI      =   4'h6;
parameter CMD_LOCK      =   4'h7;
parameter CMD_DRVSTR    =   4'h8;
parameter CMD_FEATURES  =   4'h9;
parameter CMD_ONFIOTP   =   4'hA;
parameter CMD_PAGELOCK  =   4'hB;
parameter CMD_BOOTLOCK  =   4'hD;
parameter CMD_MP        =   4'hE;
// Multi-die device indentifier
parameter CMD_MPRDWC    =   4'hF;
//----------------------------------
parameter mds = 3'b000;

//------------------------------------
// Ports declaration and assignment
//------------------------------------
inout [DQ_BITS - 1 : 0] Io;
input                   Cle;
input                   Ale;
input                   Ce_n_i;
input                   Clk_We_n;  // Clk active high, We_n active low.
input                   Wr_Re_n;   // Wr_n active low, Re_n active low.  
input                   Wp_n;
output                  Rb_n;
input                   Pre;
input                   Lock;
inout 				    Dqs;
output                  ML_rdy;  // multi-LUN checks 
output                  Rb_lun_n;  // multi-LUN checks 
input [ 2 : 0]          PID;

//Since this model supports both async and sync parts, we'll re-assign the sync input pins
// to make the coding of the model consistent for both

    wire bypass_cache =1'b0;
    reg  sync_mode;

    //Clk and Wr_n are HS sync only 
    reg     Clk         = 0;
    reg     Wr_n        = 0;
    reg     Wr_n_int    = 0;

wire                     We_n   = Clk_We_n;
wire                     Re_n   = Wr_Re_n ;

wire                     Rb_n;
reg  [DQ_BITS - 1 : 0]   Io_buf; //also Dq in sync mode
wire [DQ_BITS - 1 : 0]   Io_wire; 
wire 					 Dqs_wire;
reg						 Dqs_buf;
reg                      Rb_n_int;

//----------------------------------------
// Data storage and addressing variables
//----------------------------------------
`ifdef PACK
reg [(BPC_MAX*DQ_BITS) - 1 : 0] data_reg_packed0[0 : NUM_COL - 1]; //data register for each plane
reg [(BPC_MAX*DQ_BITS) - 1 : 0] data_reg_packed1[0 : NUM_COL - 1]; //data register for each plane
reg [(BPC_MAX*DQ_BITS) - 1 : 0] data_reg_packed2[0 : NUM_COL - 1]; //data register for each plane
reg [(BPC_MAX*DQ_BITS) - 1 : 0] data_reg_packed3[0 : NUM_COL - 1]; //data register for each plane
reg [(BPC_MAX*DQ_BITS) - 1 : 0] cache_reg_packed0[0 : NUM_COL - 1]; //cache register for each plane
reg [(BPC_MAX*DQ_BITS) - 1 : 0] cache_reg_packed1[0 : NUM_COL - 1]; //cache register for each plane
reg [(BPC_MAX*DQ_BITS) - 1 : 0] cache_reg_packed2[0 : NUM_COL - 1]; //cache register for each plane
reg [(BPC_MAX*DQ_BITS) - 1 : 0] cache_reg_packed3[0 : NUM_COL - 1]; //cache register for each plane
reg [(BPC_MAX*DQ_BITS) - 1 : 0] mem_array_packed [0 : NUM_ROW - 1] [0 : NUM_COL - 1]; //Main flash memory array
`endif 
reg [PAGE_SIZE - 1 : 0]         data_reg[0:NUM_PLANES -1]; //data register for each plane
reg [PAGE_SIZE - 1 : 0]         cache_reg[0:NUM_PLANES -1]; //cache register for each plane
reg [PAGE_SIZE - 1 : 0]         bit_mask; //cache register for each plane
reg [(BPC_MAX*DQ_BITS) - 1 : 0] data_out_reg; //data register for each plane
reg [PAGE_SIZE - 1 : 0]         OTP_array [0 : OTP_ADDR_MAX - 1];
reg [DQ_BITS - 1 : 0]           special_array [0 : MAX_COL]; //Special array for Read_ID_2 and Read_Unique
reg [PAGE_SIZE - 1 : 0]         mem_array [0 : NUM_ROW - 1]; //Main flash memory array
reg [ROW_BITS -1 :0]            memory_addr [0 : NUM_ROW - 1];
integer                         memory_index; // page based
integer                         memory_used;
reg [DQ_BITS - 1 : 0]           datain_reg[0:NUM_PLANES -1][7:0]; //data register for each plane
reg [2 : 0]                     datain_index;
reg [DQ_BITS - 1 : 0]           data;
reg [DQ_BITS - 1 : 0]           status_register; //nand device status
reg [DQ_BITS - 1 : 0]           status_register1;
reg                             abort_en     = 1'b0; 
reg [1:0]                       clr_fail_bit = 0; 
reg [1:0]                       fail_bit     = 0; 
reg [7 : 0]                     DriveStrength;
reg [COL_BITS -1 : 0]           col_addr; //decoded column address
reg [COL_BITS -1 : 0]           temp_col_addr;  // captures column address to be used when address phases complete with decoded die select 
reg [COL_BITS -1 : 0]           col_addr_dup;  // replaces column address during 85h cmds with row address phases.  
reg [31          : 0]           new_addr;
reg [ROW_BITS -1 : 0]           row_addr [0:NUM_PLANES -1]; //decoded row address
reg [ROW_BITS -1 : 0]           row_addr_last[0:NUM_PLANES -1];
reg [ROW_BITS -1 : 0]           copyback2_addr;
reg [COL_BITS -1 : 0]           multiplane_col_addr; //2plane decoded column address
reg [BLCK_BITS-1 : 0]           erase_block_addr;
reg [ROW_BITS -1 : 0]           otp_prog_addr;
reg                             array_prog_2plane;
reg [7:0]                       id_reg_addr;
reg [ROW_BITS -1 : 0]           cmnd_35h_row_addr;
reg [3 : 0]                     pp_counter [0 : NUM_ROW -1]; //support for # of partial page programming checks
reg [ROW_BITS -1 : 0]           pp_addr [0 : NUM_ROW -1];
reg [ROW_BITS -1 : 0]           pp_index;
reg [ROW_BITS -1 : 0]           pp_used;
reg [3 : 0]                     otp_counter [0 : OTP_ADDR_MAX-1]; //support for # of OTP partial page programming checks
reg                             OTP_page_locked [ 0 : OTP_ADDR_MAX]; // supports the OTP page by lock feature (not supported in all OTP devices)
reg [PAGE_BITS-1 : 0]           seq_page [0 : MAX_BLOCKS]; //allows checks for prohibited random page programming
reg [ROW_BITS -1 : 0]           UnlockAddrLower;
reg [ROW_BITS -1 : 0]           UnlockAddrUpper;
reg [3:0]                       BootBlockLocked; //some devices have blocks 0,1,2,3 as lockable 'boot' blocks
reg IoX;
reg IoX_enable;

reg dqs_en = 0;                 //used in sync mode for devices that support it
reg drive_dqs = 0;              //indicate when model needs to start driving DQS
reg release_dqs = 0;            //indicate when model should release DQS
reg first_dqs = 0;              //used in HS timing checks
reg first_clk = 1;              //used in HS timing checks
reg new_clk   = 1;              //used in HS timing checks
wire [PAGE_BITS -1 : 0]          page_address = new_addr[PAGE_BITS-1:0];
wire [BLCK_BITS -1 : 0]          block_addr   = new_addr[(BLCK_BITS-1+PAGE_BITS):PAGE_BITS];
reg  [1:0]                       LA;
reg                              id_cmd_lun; // selects LUN to return target data on id commands, related to LUNs per target 

reg   load_cache_en;
reg   load_cache_en_r;
reg   ld_reg_en;
reg   ld_page_addr_good;
integer ldthisPlane;
integer ld_mem_mp_index; //local multi-plane memory index
reg [ROW_BITS -1 : 0] ld_load_row_addr; //multi-plane plane decoded row address

reg [ROW_BITS -1 : 0] eb_lock_addr;
integer eb_thisPlane;
reg   [PAGE_BITS - 1 : 0] eb_page;
reg eb_unlocked_erase;
reg eb_boot_fail;
integer e;
integer eb_delay;

reg erase_blk_en  ;
reg erase_blk_en_r;
reg erase_blk_pls ;

//-----------------------------------------------
// Command decode, control, and state variables
//-----------------------------------------------
wire            Ce_n    ;  
reg             cmnd_70h;  // status mode 70h or 78h, else read mode
reg             cmnd_78h;  // status mode 70h or 78h, else read mode
reg             cmnd_85h;  // random data input/ change write column indicator, used to capture col addr
reg             multiplane_op_rd;
reg             multiplane_op_wr;
reg             multiplane_op_erase;
reg             cache_op;
reg             saw_cmnd_65h;
reg             saw_cmnd_00h;  // indicator that switched to read mode with 00h (read mode) command.
reg             saw_cmnd_00h_stat; 
reg             saw_cmnd_60h;
reg             saw_cmnd_60h_clear; 
reg             do_read_id_2;
reg             do_read_unique;
reg             OTP_mode;
reg             OTP_pagelock;
reg             OTP_write;
reg             OTP_read;
reg             OTP_locked;
reg             ONFI_read;
reg             disable_md_stat;
reg             ALLOWLOCKCOMMAND;
reg             LOCKTIGHT;
reg             LOCK_DEVICE;
reg             LockInvert;
reg             edo_mode;
reg [2:0]       thisDieNumber;
reg             PowerUp_Complete;
reg             ResetComplete;
reg             Rb_flush_n;
reg             Rb_abort_n;
reg             die_select;
reg [7:0]       lastCmd;
reg [NUM_PLANES >> 2:0] active_plane;
reg queued_plane [0: NUM_PLANES-1];
reg queued_plane_cache [0: NUM_PLANES-1];
wire plane0;
wire plane1;
assign plane0 = queued_plane[0];
assign plane1 = queued_plane[1];
reg             rd_pg_cache_seqtl;
reg             multiplane_op_rd_cache;
integer         lun_addr;
reg             array_prog_done;
reg             otp_prog_done;
reg             array_load_done;
reg             cache_prog_last;
reg             col_valid;
reg             row_valid;
reg             cache_valid;
reg             rd_out;
reg             copyback =1'b0;
reg             copyback2;
reg             queued_copyback2;
reg             queued_load;
reg             erase_done;
reg             we_adl_active;
reg             saw_posedge_dqs;
reg             sync_output_active;
reg             dqs_enable;
reg             wait_for_cen;
reg             queue_status_output;
reg             check_idle;
wire            address_enable;
wire            command_enable;
wire            datain_sync;
wire            datain_async;
wire            data_out_enable_async;
wire            dqs_out_enable;
reg             col_addr_dis;
reg             MLC_SLC;
reg             reset_cmd;
reg             disable_ready_n;  // sequential cache read will continue busy even if previous read completes.  

reg timezero;
reg clr_que_en_rd;
reg clr_que_en_wr;
reg ml_prohibit_cmd;
reg ml_rdy;

reg   [0:0]                nand_mode  = 0;
reg             boot_block_lock_mode =1'b0;

//----------------------------------------
// Counters
//----------------------------------------
reg [COL_CNT_BITS -1 : 0]   col_counter; 
reg [1           : 0]   sub_col_cnt;
reg [1           : 0]   sub_col_cnt_init;
integer                 addr_start;
integer                 addr_stop;
integer                 pl_cnt;
integer                 i;
reg [ROW_BITS -1 : 0]   j;
reg [COL_BITS -1 : 0]   k;
reg [3:0]               ROW_BYTES;
reg [3:0]               COL_BYTES;
reg [3:0]               ADDR_BYTES;

//----------------------------------------
// Timing checks
//----------------------------------------
realtime    tm_we_n_r;      //We_n rise timestamp
realtime    tm_we_n_r_ale;  //used in tCCS calculation
realtime    tm_we_n_f;      //We_n fall timestamp
realtime    tm_re_n_r;      //Re_n rise timestamp
realtime    tm_re_n_f;      //Re_n fall timestamp
realtime    tm_ce_n_r;      //Ce_n rise timestamp
realtime    tm_ce_n_f;      //Ce_n fall timestamp
realtime    tm_ale_r;       //Ale rise timestamp
realtime    tm_ale_f;       //Ale fall timestamp
realtime    tm_cle_r;       //Cle rise timestamp
realtime    tm_cle_f;       //Cle fall timestamp
realtime    tm_io_ztodata;  //high-z to data transition timestamp
realtime    tm_io_datatoz;  //data to high-z transition timestamp
realtime    tm_rb_n_r;      //Rb_n rise timestamp
realtime    tm_rb_n_f;      //Rb_n fall timestamp
realtime    tm_wp_n;        //Wp_n transition timestamp
realtime    tm_we_ale_r;    //Used in tADL timing violation calculation
realtime    tm_we_data_r;
realtime    tprog_done;     //array program done timestamp
realtime    tload_done;     //array load done timestamp
realtime    t_readtox;
realtime    t_readtoz;
time        UnlockTightTimeLow; 
time        UnlockTightTimeHigh; 
real        tWB_delay;
initial tWB_delay = tWB_max;      // will be assigned to either async or sync mode tWB value
integer ld_delay;

//Continuous Assignments
assign Io = Io_wire;
assign Dqs = Dqs_wire;  //sync mode only
assign Dqs_wire = (dqs_en) ? Dqs_buf : 1'bz;   //sync mode only
assign Io_wire = rd_out ? Io_buf : IoX ? {DQ_BITS{1'bx}} : {DQ_BITS{1'bz}};
assign Rb_n     = (Rb_n_int & Rb_flush_n & Rb_abort_n)? 1'bz : 1'b0; // open-drain active low : HIGH = 1'bz, LOW = 1'b0
assign Rb_lun_n = (Rb_n_int & Rb_flush_n & Rb_abort_n)? 1'b1 : 1'b0; // open-drain active low : HIGH = 1'bz, LOW = 1'b0

//----------------------------------------
// Error codes and reporting
//----------------------------------------
parameter   ERR_MAX_REPORTED =  -1; // >0 = report errors up to ERR_MAX_REPORTED, <0 = report all errors
parameter   ERR_MAX =           -1;  // >0 = stop the simulation after ERR_MAX has been reached, <0 = never stop the simulation
parameter   ERR_CODES =         10; // track up to 10 different error codes
parameter   MSGLENGTH =        256;
reg  [8*MSGLENGTH:1]           msg;
integer     ERR_MAX_INT =  ERR_MAX;
wire [ERR_CODES : 1]       EXP_ERR;
assign EXP_ERR = {ERR_CODES {1'b0}}; // the model expects no errors.  Can only be changed for debug by 'force' statement in testbench.
// Enumerated error codes (0 = unused)
parameter   ERR_MISC   =  1;
parameter   ERR_CMD    =  2;
parameter   ERR_STATUS =  3;
parameter   ERR_CACHE  =  4;
parameter   ERR_ADDR   =  5;  //seq page, 2plane, page read cache mode, internal data move addressing restrictions
parameter   ERR_MEM    =  6;
parameter   ERR_LOCK   =  7;
parameter   ERR_OTP    =  8;
parameter   ERR_TIM    =  9; //timing errors
parameter   ERR_NPP    = 10;

integer     errcount [1:ERR_CODES];
integer     warnings;
integer     errors;
integer     failures;
reg [8*12-1:0] err_strings [1:ERR_CODES];
initial begin : INIT_ERRORS
    integer i;
    warnings = 0;
    errors = 0;
    failures = 0;
    for (i=1; i<=ERR_CODES; i=i+1) begin
        errcount[i] = 0;
    end
    err_strings[ERR_MISC    ] =         "MISC";
    err_strings[ERR_CMD     ] =          "CMD";
    err_strings[ERR_STATUS  ] =       "STATUS";
    err_strings[ERR_CACHE   ] =        "CACHE";
    err_strings[ERR_ADDR    ] =         "ADDR";
    err_strings[ERR_MEM     ] =          "MEM";
    err_strings[ERR_LOCK    ] =         "LOCK";
    err_strings[ERR_NPP     ] = "Partial Page";
    err_strings[ERR_TIM     ] =       "Timing";
end 

//----------------------------------------
// Initialization
//----------------------------------------
initial begin
    PowerUp_Complete    =   1'b0;
    ResetComplete       =   1'b0;
    timezero            =   1'b0;
    timezero           <=#1 1'b1;
    copyback2           =   1'b0;
    Rb_flush_n          =   1'b1;
    Rb_abort_n          =   1'b1;
    cache_prog_last     =   1'b0;
    `ifdef SO
     sync_mode          =   1'b1;
    `else
     sync_mode          =   1'b0;
    `endif             
    clr_que_en_rd       =   1'b0;
    clr_que_en_wr       =   1'b0;
    ml_prohibit_cmd     =   1'b0;
    ml_rdy              =   1'b1;
    array_load_done     =   1'b0;
    array_prog_done     =   1'b0;
    active_plane        =      0;
    Rb_n_int            =   1'b1;
    tprog_done          =      0;
    tload_done          =      0;
    t_readtox           =      0;
    t_readtoz           =      0;
    edo_mode            =      0;
    col_valid           =   1'b0;
    col_addr            =      0;
    temp_col_addr       =      0;
    row_valid           =   1'b0;
    wait_for_cen        =   1'b0;
    queue_status_output =   1'b0;
    col_addr_dis        =   1'b0;
    datain_index        =      0;
    reset_cmd           =   1'b0;
    for (i=0;i<NUM_PLANES;i=i+1) begin
        row_addr[i] = 0;
    end
    clear_queued_planes;
    rd_pg_cache_seqtl   =   1'b0;
    multiplane_op_rd_cache = 1'b0;
    queued_copyback2    =   1'b0;
    queued_load         =   1'b0;
    cache_valid         =   1'b0;
    multiplane_op_erase =   1'b0;
    multiplane_op_rd    =   1'b0;
    multiplane_op_wr    =   1'b0;
    cache_op            =   1'b0;
    erase_done          =   1'b1;
    saw_cmnd_00h        =   1'b0;
    saw_cmnd_00h_stat   =   1'b0;
    saw_cmnd_65h        =   1'b0;
    do_read_id_2        =   1'b0;
    do_read_unique      =   1'b0;
    addr_start          =      0;
    addr_stop           =      0;
    sync_output_active  =   1'b0;
    dqs_enable          =   1'b0;
    LockInvert          =      1;
    OTP_mode            =      0;
    OTP_pagelock        = FEATURE_SET[CMD_PAGELOCK];
    OTP_locked          =   1'b0;
    OTP_write           =   1'b0;
    OTP_read            =   1'b0;
    ONFI_read           =   1'b0;
    rd_out              =   1'b0;
    pl_cnt              =      0;
    check_idle          =      0;
    UnlockAddrLower     = {ROW_BITS{1'b0}};
    UnlockAddrUpper     = {ROW_BITS{1'b1}};
    BootBlockLocked     =   4'h0;
    Io_buf             <= {DQ_BITS{1'bz}};
    IoX_enable          =   1'b0;
    IoX                 =   1'b0;
    sub_col_cnt_init    =      0;
    sub_col_cnt         =      0;
    MLC_SLC             =   1'b0;
    disable_ready_n     =   1'b1;
    load_cache_en       =   1'b0;
    load_cache_en_r     =   1'b0;
    ld_reg_en           =   1'b0;
    cmnd_85h            =   1'b0;

    erase_blk_en        =   1'b0;
    erase_blk_en_r      =   1'b0;
    erase_blk_pls       =   1'b0;
    eb_delay            = (tLBSY_min - tWB_delay);
    
    //Time output format
    $timeformat (-9, 3, " ns", 1);
    $sformat(msg, "Device is Powering Up ...");
    INFO(msg);
              
    if((NUM_DIE/NUM_CE) == 2) begin
        if((mds ==3'h0) | (mds ==3'h2) | (mds ==3'h4) | (mds ==3'h6)) id_cmd_lun = 1'b1;  // each target has 2 LUNs, and one LUN returns id data (avoids collisions)
    end else 
        id_cmd_lun = 1'b1;  // each target has 1 LUN, the LUN returns target data

    //Determine how many address cycles we need
    if (ROW_BITS > 16) ROW_BYTES = 3;
    else if (ROW_BITS > 8) ROW_BYTES = 2;
    else ROW_BYTES = 1;
    if (COL_BITS > 16) COL_BYTES = 3;
    else if (COL_BITS > 8) COL_BYTES = 2;
    else COL_BYTES = 1;
    ADDR_BYTES = ROW_BYTES + COL_BYTES;

    // Initialize memory array to all FFs
    // also initialize partial page counters to all 00s
    `ifdef FullMem
        for (j = 0; j <= NUM_ROW - 1; j = j + 1) begin
            pp_counter[j] = {4{1'b0}};
            mem_array [j] = {PAGE_SIZE{1'b1}};
            end
    `endif
    for (j=0; j< OTP_ADDR_MAX; j=j+1) begin
        otp_counter[j] = 3'b000;
    end
    for (j=0; j<= MAX_BLOCKS ; j=j+1) begin
        seq_page[j] = {PAGE_BITS{1'b0}};
    end
    `ifdef FullMem
    `else
        memory_used = 0;
        pp_used = 0;
    `endif

    // initialize the OTP page locking tracker (for devices that support OTP lock by page)
    for (j=0;j < OTP_ADDR_MAX; j=j+1) begin
        OTP_page_locked[j] = 0;
    end
    
    init_onfi_params; // initialize read-only ONFI parameters, defined in ONFI spec

    //In multiple die configurations, we need a way to individually identify each device
    thisDieNumber = mds;
    if(mds%2==0) die_select = 1'b1;
    `ifdef INIT_MEM
    /*
    `ifdef x8
       $readmemh ("data.8.init", mem_array);
       $readmemh ("read_unq.8.init", special_array);
       $readmemh ("otp.8.init", OTP_array);
    `else
       $readmemh ("data.16.init", mem_array);
       $readmemh ("read_unq.16.init", special_array);
       $readmemh ("otp.16.init", OTP_array);
    `endif
    `ifdef FullMem
    `else
       //to use associative arrays with readmemh, we need to 
       //predefine the amount of data preloaded
       for (memory_used=0; memory_used<PRELOAD_SIZE; memory_used=memory_used+1) begin
           memory_addr[memory_used] = memory_used;
       end
    `endif
    */
    `else
        for (j=0; j < OTP_ADDR_MAX; j=j+1) begin
            OTP_array [j] = {PAGE_SIZE{1'b1}};
        end
        //Set manufacturer's ID to 0 until defined (complement is all FF's)
        for (k =0; k < 512 ; k=k+32) begin
            for (j=0;j<16;j=j+1) begin
                special_array [k+j] = {DQ_BITS{1'b0}};
                   special_array [k+j+16] = {DQ_BITS{1'b1}};
            end
        end
           for (k = 512; k < MAX_COL; k = k + 1) begin
            special_array [k] = {DQ_BITS{1'b0}};
           end
    `endif

    status_register1      = 0;
`ifdef x16
    status_register [15:8] = 8'h00;  // DEFAULT
`endif
    // rdy/ardy per LUN, fail_bit per plane ???
    status_register [6:0] = 7'b1100000;  // DEFAULT:  IO ready, Array ready, 0 0 0, FAIL/PASS(prev), FAIL/PASS(current)
    if (Wp_n == 1'b1) begin
        status_register [7] = 1'b1;
    end else begin
        status_register [7] = 1'b0;
    end
    for (pl_cnt=0;pl_cnt<NUM_PLANES;pl_cnt=pl_cnt+1) begin
        clear_cache_register(pl_cnt);
        clear_data_register(pl_cnt);
    end

    //Need this 1 so power up completes before any timing or data checks 
    #1;
    `ifdef PRE
        // this preloads the 1st page into the data register
        if (Pre) begin
            $sformat(msg,"Starting Power-On Preload ...");
            INFO(msg);
            Rb_n_int <= 0;
            status_register [6:5] = 2'b00;
                `ifdef FullMem
                    cache_reg[active_plane] = mem_array [{ROW_BITS{1'b0}}];
                `else
                    if (memory_addr_exists({ROW_BITS{1'b0}})) begin
                        cache_reg[active_plane] = mem_array[memory_index];
                    end else begin
                        cache_reg[active_plane] = {PAGE_SIZE{1'b1}};
                    end
                `endif
            go_busy(tRPRE_max-1);
            status_register [6:5] = 2'b11;
            $sformat(msg,"PO_read complete");
            INFO(msg);
        end
    `endif
    col_counter = 0;
    Rb_n_int <= 1;
    if (Lock === 1) begin
        ALLOWLOCKCOMMAND   = 1;   // Lock commands valid if Lock active on power-up
    end else begin
        ALLOWLOCKCOMMAND   = 0;   // Lock commands valid if Lock active on power-up
    end
    LOCKTIGHT = 1'b0;
    LOCK_DEVICE = 1'b0;
    DriveStrength = 8'h00;
    `ifdef SHORT_RESET
        PowerUp_Complete = #tRST_ready   1'b1;
    `else
        PowerUp_Complete = #tRST_powerup 1'b1;
    `endif 
    $sformat(msg,"PowerUp Complete.");
    INFO(msg);
end   

//---------------------------------------------------
// TASKS
//---------------------------------------------------

//---------------------------------------------------
// TASK: INFO("msg")
//---------------------------------------------------
task INFO;
   input [MSGLENGTH*8:1] msg;
begin
  $display("%m at time %t: %0s", $time, msg);
end
endtask

//---------------------------------------------------
// TASK: WARN("msg")
//---------------------------------------------------
task WARN;
   input [MSGLENGTH*8:1] msg;
begin
  $display("%m at time %t: %0s", $time, msg);
  warnings = warnings + 1;
end
endtask

//---------------------------------------------------
// TASK: ERROR(errcode, "msg")
//---------------------------------------------------
task ERROR;
   input [7:0] errcode;
   input [MSGLENGTH*8:1] msg;
begin

    errcount[errcode] = errcount[errcode] + 1;
    errors = errors + 1;

    if ((errcount[errcode] <= ERR_MAX_REPORTED) || (ERR_MAX_REPORTED < 0))
        if ((EXP_ERR[errcode] === 1) && ((errcount[errcode] <= ERR_MAX_INT) || (ERR_MAX_INT < 0))) begin
            $display("Caught expected violation at time %t: %0s", $time, msg);        
        end else begin
            $display("%m at time %t: %0s", $realtime, msg);
        end
    if (errcount[errcode] == ERR_MAX_REPORTED) begin
        $sformat(msg, "Reporting for %s has been disabled because ERR_MAX_REPORTED has been reached.", err_strings[errcode]);
        INFO(msg);
    end

    //overall model maximum error limit
    if ((errcount[errcode] > ERR_MAX_INT) && (ERR_MAX_INT >= 0)) begin
        STOP;
    end
end
endtask

//---------------------------------------------------
// TASK: FAIL("msg")
//---------------------------------------------------
task FAIL;
   input [MSGLENGTH*8:1] msg;
begin
   $display("%m at time %t: %0s", $time, msg);
   failures = failures + 1;
   STOP;
end
endtask

//---------------------------------------------------
// TASK: Stop()
//---------------------------------------------------
task STOP;
begin
  $display("%m at time %t: %d warnings, %d errors, %d failures", $time, warnings, errors, failures);
  $stop(0);
end
endtask

//---------------------------------------------------
// TASK: memory_write (block, page, col, data)
// This task is used to preload data into the memory, OTP, and Special arrays.
//---------------------------------------------------
    task memory_write;
        input  [BLCK_BITS-1:0] block;
        input  [PAGE_BITS-1:0]  page;
        input  [COL_BITS -1:0]   col;
        input  [1:0]   memory_select;
        input  [DQ_BITS-1:0]    data;
        reg    [ROW_BITS-1:0]   addr;
        reg    [ROW_BITS-1:0]  page_addr;
        reg    [PAGE_SIZE-1:0] ld_mask;
        begin
            // chop off the lowest address bits
            addr = {block, page, col};
            page_addr = {block, page};
            ld_mask = ({DQ_BITS{1'b1}} << (col * DQ_BITS)); // shifting left zero-fills
            case (memory_select)
                0:  begin
                `ifdef FullMem
                    mem_array[addr]       = (mem_array[addr] & ~ld_mask) | (data<<(col * DQ_BITS));
                `else
                    if (memory_addr_exists(page_addr)) begin
                        memory_addr[memory_index] = page_addr;
                        mem_array[memory_index] = (mem_array[memory_index] & ~ld_mask) | (data<<(col * DQ_BITS));
                    end else if (memory_used > NUM_ROW ) begin
                        $sformat (msg, "Memory overflow.  Write to Address %h with Data %h will be lost.\nYou must increase the NUM_ROW parameter or define FullMem.", addr, data);
                        FAIL(msg);
                    end else begin
                        pp_counter[memory_used]  = {4{1'b0}}; //initialize partial page counter
                        memory_addr[memory_used] = page_addr;
                        mem_array[memory_used] = ({PAGE_SIZE{1'b1}} &  ~ld_mask) | (data<<(col * DQ_BITS));
                        memory_used  = memory_used  + 1'b1;  
                        memory_index = memory_index + 1'b1;
                    end
                `endif
                end
                1:    OTP_array[page]       = (OTP_array[page] & ~ld_mask) | (data<<(col * DQ_BITS));
                2:    special_array[col]    = data;
            endcase
        end
    endtask

//---------------------------------------------------
// TASK: memory_write (block, page, col, data)
// This task is used to read data from the memory, OTP, and Special arrays.
//---------------------------------------------------
    task memory_read;
        input  [BLCK_BITS-1:0] block;
        input  [PAGE_BITS-1:0]  page;
        input  [COL_BITS-1:0]    col;
        output [DQ_BITS-1:0]    data;
        reg    [ROW_BITS-1:0]   page_addr;
        begin
            page_addr = {block, page};
`ifdef FullMem
            data = mem_array[page_addr] >> (col * DQ_BITS);
`else
            if (memory_addr_exists(page_addr)) begin
                data = mem_array[memory_index] >> (col * DQ_BITS);
            end else begin
                data = {DQ_BITS{1'b1}};
            end
`endif
//            $display("Memory index %0d memory address (%0h) data=%0h", memory_index,  memory_addr[memory_index], data);
        end
    endtask

//-----------------------------------------------------------------
// TASK : corrupt_page (tsk_row_addr)
// Corrupt a page of memory.
// Called during reset of a program operation.
//-----------------------------------------------------------------
task corrupt_page;
    input [ROW_BITS -1: 0] tsk_row_addr;
    integer i;
begin
    if (DEBUG[0]) begin $sformat(msg, "Corrupting addr=%0h due to reset", tsk_row_addr); INFO(msg); end
    `ifdef FullMem
            mem_array [tsk_row_addr] = {PAGE_SIZE{1'bx}};
    `else
        //if used memory address in associative array has same row addr as corrupt task, corrupt with x's
        for (i=0; i< memory_used; i=i+1) begin
            if (memory_addr[i] === tsk_row_addr) begin
                    mem_array[i] =  {PAGE_SIZE{1'bx}};
            end
        end
    `endif
end
endtask

//-----------------------------------------------------------------
// TASK : corrupt_block (tsk_block_addr)
// Corrupt a block of memory.
// Called during reset of an erase operation.
//-----------------------------------------------------------------
task corrupt_block;
    input [BLCK_BITS -1: 0] tsk_block_addr;
    reg [COL_BITS -1 : 0] col;
    reg [COL_BITS -1 : 0] page;
    integer i;
begin
    if (DEBUG[0]) begin $sformat(msg, "Corrupting block addr=%0h due to reset", tsk_block_addr); INFO(msg); end
    `ifdef FullMem
        page = 0;
        repeat (NUM_PAGE) begin
                mem_array [{tsk_block_addr, page}] = {PAGE_SIZE{1'bx}};
            page = page +1;
        end
    `else
        //if used memory address in associative array has same block addr as corrupt task, corrupt with x's
        for (i=0; i< memory_used; i=i+1) begin
            //check to see if existing used address location matches block being corrupted
            if (memory_addr[i][(ROW_BITS) -1 : (PAGE_BITS)] === tsk_block_addr) begin
                    mem_array[i] = {PAGE_SIZE{1'bx}};
            end
        end
    `endif
end
endtask

//-----------------------------------------------------------------
// TASK : corrupt_otp_page (tsk_row_addr)
// Corrupt a page of OTP memory.
// Called during reset of an OTP program operation.
//-----------------------------------------------------------------
task corrupt_otp_page;
    input [ROW_BITS -1: 0] tsk_row_addr;
begin
    if (DEBUG[0]) begin $sformat(msg, "Corrupting OTP addr=%0h due to reset", tsk_row_addr); INFO(msg); end
    OTP_array [tsk_row_addr] = {PAGE_SIZE{1'bx}};
end
endtask

//-----------------------------------------------------------------
// TASK : clear_data_register (plane)
// Completely clears a data register for the input plane to all FF's.
//-----------------------------------------------------------------
task clear_data_register;
    input [1:0] plane;
begin
    data_reg[plane] = {PAGE_SIZE {1'b1}}; 
end
endtask

//-----------------------------------------------------------------
// TASK : clear_cache_register (plane)
// Completely clears a cache register for the input plane to all FF's.
//-----------------------------------------------------------------
task clear_cache_register;
    input [1:0] plane;
begin
    cache_reg[plane] = {PAGE_SIZE{1'b1}};
end
endtask

//-----------------------------------------------------------------
// TASK : copy_queued_planes
//  Simple copy queued planes to use during cache operations following 00-30h, 00-31h (used in cache_mode)
//-----------------------------------------------------------------
task copy_queued_planes;
    integer num_plane;
begin
    for (num_plane = 0; num_plane < NUM_PLANES; num_plane = num_plane +1) begin
        queued_plane_cache[num_plane] = queued_plane[num_plane];
    end
    multiplane_op_rd_cache = multiplane_op_rd;
end
endtask

//-----------------------------------------------------------------
// TASK : copy_cachereg_to_datareg( multiplane )
//  Simple copy of cache_reg to the data_reg (used in cache_mode)
//-----------------------------------------------------------------
task copy_cachereg_to_datareg;
    integer num_plane;
begin
    for (num_plane = 0; num_plane < NUM_PLANES; num_plane = num_plane +1) begin
        if (queued_plane[num_plane]) begin //if the plane is queued for the next multi-plane op
            data_reg[num_plane] = cache_reg[num_plane];
            `ifdef PACK
            for (i = 0; i <= NUM_COL - 1; i = i + 1) begin
                case (num_plane)
                    0 : data_reg_packed0[i] = cache_reg_packed0[i];
                    1 : data_reg_packed1[i] = cache_reg_packed1[i];
                    2 : data_reg_packed2[i] = cache_reg_packed2[i];
                    3 : data_reg_packed3[i] = cache_reg_packed3[i];
                endcase
            end
            `endif
        end
    end
end
endtask

//-----------------------------------------------------------------
// TASK : load_reg_cache_mode
// Loads cache register from data register.  
//-----------------------------------------------------------------
task load_reg_cache_mode;
    integer temp_delay;
    integer num_plane;
begin
//    #tWB_delay;
    temp_delay = tWB_delay;
    Rb_n_int <= #temp_delay 1'b0;
    disable_ready_n <= #temp_delay 1'b0;
    status_register [6:5] <= #temp_delay 2'b00;

    //-----------------------------------------------------------------
    // copy_datareg_to_cachereg( multiplane ) Simple copy of data_reg to the cache_reg (used in cache_mode)
    //-----------------------------------------------------------------
    for (num_plane = 0; num_plane < NUM_PLANES; num_plane = num_plane +1) begin
        if ((      queued_plane[num_plane] & ~rd_pg_cache_seqtl) | 
            (queued_plane_cache[num_plane] &  rd_pg_cache_seqtl) ) begin //if the plane is queued for the next multi-plane op
            cache_reg[num_plane] <= #temp_delay data_reg[num_plane];
            `ifdef PACK
            for (i = 0; i <= NUM_COL - 1; i = i + 1) begin
                case (num_plane)
                    0 : cache_reg_packed0[i] <= #temp_delay data_reg_packed0[i] ;
                    1 : cache_reg_packed1[i] <= #temp_delay data_reg_packed1[i] ;
                    2 : cache_reg_packed2[i] <= #temp_delay data_reg_packed2[i] ;
                    3 : cache_reg_packed3[i] <= #temp_delay data_reg_packed3[i] ;
                endcase
            end
            `endif
        end
    end

    go_busy(tDCBSYR1_max+temp_delay);
    // have to wait if previous data reg load is not done (cached reads)
    if (~array_load_done) begin
        queued_load = 1;
        while (~array_load_done) begin
            #1;
        end
        disable_ready_n = 1'b1;
    end else begin
       Rb_n_int <= 1'b1; // Device Ready
       disable_ready_n <= 1'b1;
       status_register[6] = 1'b1;
       if (lastCmd == 8'h3F)   status_register [5] = 1'b1;
    end
    queued_load = 0;
    //if page read cache mode, need to load next page to data_reg
    if (lastCmd === 8'h31) begin
        //will load page from mem, but not drive Rb_n busy (since cache mode)
        if (DEBUG[0]) begin $sformat(msg, "Loading next page for cache read addr=%0h", row_addr[active_plane]); INFO(msg); end
    end
end
endtask

//-----------------------------------------------------------------
// TASK : load_cache_register (multiplane, cache_mode)
// Loads cache register from memory array.  
//-----------------------------------------------------------------
task load_cache_register;
    input multiplane;
    input cache_mode;
    integer thisPlane;
    reg [ROW_BITS -1 : 0] load_row_addr; //multi-plane plane decoded row address
    reg page_addr_good;
    integer mem_mp_index; //local multi-plane memory index
    integer delay;
    integer temp_delay;
    
begin
    // Delay For RB# (tWB)
    page_addr_good = 0;
    temp_delay = 0;

    //for cache reads, first transfer data_reg->cache_reg    
    if (cache_mode) begin
        load_reg_cache_mode;
        if (lastCmd !== 8'h3F) 
            status_register [5] = 1'b0;
    end else begin
//        #tWB_delay
        temp_delay = tWB_delay;
        Rb_n_int <= #temp_delay 1'b0;
        status_register[6:5] = #temp_delay 2'b00;
    end

    array_load_done = #temp_delay 1'b0;

    if (multiplane) begin
    end else begin
        //internal data move only allowed within the same plane
        if (lastCmd === 8'h35) cmnd_35h_row_addr = row_addr[active_plane];
    end

    //check that any queued read addresses meet the multi-plane addressing requirements
    check_plane_addresses;

    //-----------------------------------------------------------------------------
    // Read From Memory Array
    //-----------------------------------------------------------------------------

    for (thisPlane =0; thisPlane < NUM_PLANES; thisPlane=thisPlane+1) begin : plane_loop
        if (OTP_read && (thisPlane == 0)) begin : otp_read
            cache_reg[active_plane] = #temp_delay OTP_array[row_addr[active_plane]];
            if (row_addr[active_plane] >= OTP_ADDR_MAX) begin
                $sformat(msg, "Error: OTP Read Address overflow.  Block must be 0 and page < OTP_ADDR_MAX.  Block=%0h Page=%0h  OTP_ADDR_MAX=%0h", row_addr[active_plane][ROW_BITS-1:PAGE_BITS], row_addr[active_plane][PAGE_BITS-1:0], OTP_ADDR_MAX); ERROR(ERR_OTP, msg); 
            end 
        end else if (ONFI_read && (thisPlane == 0)) begin : onfi_read
            if(~nand_mode[0])   cache_reg[active_plane] = #temp_delay onfi_params_array_unpacked;
        end else begin //regular_read
            // cant do any loading if already in special read_id_2 or read_unique states
            // only way out is reset or power down/up
            if (~do_read_id_2 && ~do_read_unique && queued_plane[thisPlane]) begin : no_id_2
                //if this plane is queued for loading
                    //set up the address to load
                load_row_addr = row_addr[thisPlane]; //old-style regular 2plane addressing scheme
                //now check to see if the address already exists
                page_addr_good = 0;
                `ifdef FullMem
                `else
                if (memory_addr_exists(load_row_addr)) begin
                    page_addr_good = 1;
                    mem_mp_index = memory_index;  // memory addr exists returns the index assoc. with load row addr
                end
                `endif
                if (cache_mode) begin
                    `ifdef FullMem
                        data_reg[thisPlane] = #temp_delay mem_array [load_row_addr];
                    `else
                        if (page_addr_good) begin
                            data_reg[thisPlane] = #temp_delay mem_array[mem_mp_index];
                            if (DEBUG[2]) begin $sformat(msg, "Transferring Read data from array block=%0h, page=%0h to data_reg=%d)", memory_addr[memory_index][(ROW_BITS -1) : (PAGE_BITS)], memory_addr[memory_index][(PAGE_BITS -1) : 0], thisPlane); INFO(msg); end
                        end else begin
                            data_reg[thisPlane] = #temp_delay {PAGE_SIZE{1'b1}};
                        end
                    `endif
                end else begin
                    `ifdef FullMem
                        cache_reg[thisPlane] = #temp_delay mem_array [load_row_addr];
                    `else
                        if (page_addr_good) begin
                            cache_reg[thisPlane] = #temp_delay mem_array[mem_mp_index];
                        end else begin
                            cache_reg[thisPlane] = #temp_delay {PAGE_SIZE{1'b1}};
                        end
                        if (DEBUG[2]) begin $sformat(msg, "Read %0h data from memory block=%0h, page=%0h)", cache_reg[thisPlane],  memory_addr[memory_index][(ROW_BITS -1) : (PAGE_BITS)], memory_addr[memory_index][(PAGE_BITS -1) : 0]); INFO(msg); end
                    `endif
                end
            end else begin
                //else we are in do_read_id_2 or do_read_unique and will be reading out of the special array
                // need to go busy like normal page read
            end // no_id_2
        end // : regular_read
    end
    // -------------------------------------------------------------------------
    // device op delay
    // -------------------------------------------------------------------------
    OTP_read = #temp_delay 1'b0;
    delay = tR_max + temp_delay;
    if (~cache_mode) begin
        if (~copyback2) begin
            copy_cachereg_to_datareg;  //if not in cache mode, cache_reg and data_reg are tied together
        end
        //ONFI parts start tR_max after tWB delay, older parts start tR_max immediately on posedge We_n
    end
    tload_done = ($realtime + delay);
    array_load_done <= #(delay) 1'b1;
    if (copyback2) begin
        go_busy((tR_max+temp_delay));
        program_page_from_datareg(multiplane); 
    end
end
endtask

// replaces load_cache_register
always @(*)
begin
    ld_reg_en <= #tWB_delay ((load_cache_en & ~load_cache_en_r) | (~load_cache_en & load_cache_en_r));
    load_cache_en_r <= #1 load_cache_en;
end 

always @(posedge ld_reg_en)
begin
    if(cache_op) begin
    ld_page_addr_good = 0;
    end else begin
        Rb_n_int <= 1'b0;
        status_register[6:5] = 2'b00;
        array_load_done = 1'b0;
        ld_page_addr_good = 0;
        
        if (multiplane_op_rd) begin
        end else begin
            //internal data move only allowed within the same plane
            if (lastCmd === 8'h35) cmnd_35h_row_addr = row_addr[active_plane];
        end

        //check that any queued read addresses meet the multi-plane addressing requirements
        check_plane_addresses;

        //-----------------------------------------------------------------------------
        // Read From Memory Array
        //-----------------------------------------------------------------------------

        for (ldthisPlane =0; ldthisPlane < NUM_PLANES; ldthisPlane=ldthisPlane+1) begin : plane_loop
            if (OTP_read && (ldthisPlane == 0)) begin : otp_read
                cache_reg[active_plane] = OTP_array[row_addr[active_plane]];
                if (row_addr[active_plane] >= OTP_ADDR_MAX) begin
                    $sformat(msg, "Error: OTP Read Address overflow.  Block must be 0 and page < OTP_ADDR_MAX.  Block=%0h Page=%0h  OTP_ADDR_MAX=%0h", row_addr[active_plane][ROW_BITS-1:PAGE_BITS], row_addr[active_plane][PAGE_BITS-1:0], OTP_ADDR_MAX); ERROR(ERR_OTP, msg); 
                end 
            end else if (ONFI_read && (ldthisPlane == 0)) begin : onfi_read
                if(~nand_mode[0])   cache_reg[active_plane] = onfi_params_array_unpacked;
            end else begin //regular_read
                // cant do any loading if already in special read_id_2 or read_unique states
                // only way out is reset or power down/up
                if (~do_read_id_2 && ~do_read_unique && queued_plane[ldthisPlane]) begin : no_id_2
                    //if this plane is queued for loading
                        //set up the address to load


                    ld_load_row_addr = row_addr[ldthisPlane]; //old-style regular 2plane addressing scheme
                    //now check to see if the address already exists
                    ld_page_addr_good = 0;
                    `ifdef FullMem
                    `else
                    if (memory_addr_exists(ld_load_row_addr)) begin
                        ld_page_addr_good = 1;
                        ld_mem_mp_index = memory_index;  // memory addr exists returns the index assoc. with load row addr
                    end
                    `endif
                    if (cache_op) begin
                        `ifdef FullMem
                            data_reg[ldthisPlane] = mem_array [ld_load_row_addr];
                        `else
                            if (ld_page_addr_good) begin
                                data_reg[ldthisPlane] = mem_array[ld_mem_mp_index];
                                if (DEBUG[2]) begin $sformat(msg, "Transferring Read data from array block=%0h, page=%0h to data_reg=%d)", memory_addr[memory_index][(ROW_BITS -1) : (PAGE_BITS)], memory_addr[memory_index][(PAGE_BITS -1) : 0], ldthisPlane); INFO(msg); end
                            end else begin
                                data_reg[ldthisPlane] = {PAGE_SIZE{1'b1}};
                            end
                        `endif
                    end else begin
                        `ifdef FullMem
                            cache_reg[ldthisPlane] = mem_array [ld_load_row_addr];
                        `else
                            if (ld_page_addr_good) begin
                                cache_reg[ldthisPlane] = mem_array[ld_mem_mp_index];
                            end else begin
                                cache_reg[ldthisPlane] = {PAGE_SIZE{1'b1}};
                            end
                            if (DEBUG[2]) begin $sformat(msg, "Read %0h data from memory block=%0h, page=%0h)", cache_reg[ldthisPlane],  memory_addr[memory_index][(ROW_BITS -1) : (PAGE_BITS)], memory_addr[memory_index][(PAGE_BITS -1) : 0]); INFO(msg); end
                        `endif
                    end
                end else begin
                    //else we are in do_read_id_2 or do_read_unique and will be reading out of the special array
                    // need to go busy like normal page read
                end // no_id_2
            end // : regular_read
        end

        // -------------------------------------------------------------------------
        // device op delay
        // -------------------------------------------------------------------------
        OTP_read = 1'b0;
        ld_delay = tR_max;
        if (~cache_op) begin
            if (~copyback2) begin
                copy_cachereg_to_datareg;  //if not in cache mode, cache_reg and data_reg are tied together
            end
            //ONFI parts start tR_max after tWB delay, older parts start tR_max immediately on posedge We_n

        end
        tload_done = ($realtime + ld_delay);
        array_load_done <= #(ld_delay) 1'b1;
        if (copyback2) begin
            go_busy(ld_delay);
            program_page_from_datareg(multiplane_op_rd); 
        end

        // from 30h cmd begin 
        if (multiplane_op_rd & NUM_PLANES==2) begin
            active_plane <= #(ld_delay) 0;
        end

        multiplane_op_rd    <= #(ld_delay) 1'b0;
        multiplane_op_wr    <= #(ld_delay) 1'b0;
        multiplane_op_erase <= #(ld_delay) 1'b0;
        cache_valid         <= #(ld_delay) 1'b0;
        // from 30h cmd end

    end 
end 

//-----------------------------------------------------------------
// TASK : sync_output_data
// Drives drive output data on Dq in sync mode
//-----------------------------------------------------------------
//--- data -> tri-state transition
//sync mode output transition from DQ data->X->Z
task sync_output_data;
    input [DQ_BITS -1 : 0] dataOut;
begin
end
endtask

//-----------------------------------------------------------------
// TASK : output_status 
// Drives status_register onto IO bus
//-----------------------------------------------------------------
task output_status;
begin
    if (sync_mode && ~Wr_n && ~Ce_n && die_select && ((cmnd_70h === 1'b1) || (cmnd_78h === 1'b1))) begin
        if (cmnd_78h && disable_md_stat) begin
            $sformat(msg, "MULTI-DIE STATUS READ (78h) IS PROHIBITED DURING AND AFTER POWER-UP RESET, OTP OPERATIONS, READ PARAMETERS, READ ID, READ UNIQUE ID, and GET/SET FEATURES.");
            INFO(msg);
        end else begin
            if(nand_mode[0])
                sync_output_data(status_register1);
            else 
                sync_output_data(status_register);
        end        
    end else
    //cmd 70h only works on the last selected die
    if (~sync_mode && ~Re_n && ~Ce_n && We_n && die_select && ((cmnd_70h === 1'b1) || (cmnd_78h === 1'b1))) begin
        if (cmnd_78h && disable_md_stat) begin
            $sformat(msg, "MULTI-DIE STATUS READ (78h) IS PROHIBITED DURING AND AFTER POWER-UP RESET, OTP OPERATIONS, READ PARAMETERS, READ ID, READ UNIQUE ID, and GET/SET FEATURES.");
            INFO(msg);
        end else begin
            // determine whether CE access time or RE access time dominates
            // then queue the status register for output on IO after the appropriate delay
            if (tCEA_max - tREA_max < $realtime - tm_ce_n_f) begin
                queue_status_output <= #tREA_max 1'b1;
            end else begin
                queue_status_output <= #(tm_ce_n_f + tCEA_max - $realtime) 1'b1;
            end
        end
    end
end
endtask

// when we see this trigger go high, it's time to output status
always @(posedge queue_status_output) begin
    //cancel the output if we've already gone inactive and tRHOH is met (Io is being driven X's)
    if (~(Re_n && IoX_enable)) begin
        if(nand_mode[0])
            Io_buf <= status_register1;
        else
            Io_buf <= status_register;
        rd_out <= 1'b1;
    end
    queue_status_output <= 0;
end

// ----------------------------------------------------------
// Multi-LUN Ready logic.
// Reset, ID, and Config commands prohibit Multi-LUN operations while Array is busy.  
// ----------------------------------------------------------
always @(*) begin
    if(Clk_We_n & command_enable) begin 
        case (Io[7:0])
        8'h90, 8'hEC, 8'hED, 8'hEE, 8'hEF, 8'hFC, 8'hFF:
            ml_prohibit_cmd = 1'b1;
        default :
            ml_prohibit_cmd = 1'b0;
        endcase
    end 
    
    if(ml_prohibit_cmd & ~status_register[5])  
        ml_rdy = 1'b0;
    else if (status_register[5])  
        ml_rdy =1'b1;
end 
assign ML_rdy = ml_rdy;

//-----------------------------------------------------------------
// TASK : erase_block (twolpanes, block_one, page_one, block_two, page_two)
// Erases a block of data in the memory array (clears to FF's)
//-----------------------------------------------------------------
task erase_block;
    reg [ROW_BITS -1 : 0] lock_addr;
    integer thisPlane;
    reg   [COL_BITS - 1: 0]   col;
    reg   [PAGE_BITS - 1 : 0] page;
    reg unlocked_erase;
    reg boot_fail;
    integer i;
    integer delay;
begin
    #tWB_delay; // Delay For RB# (tWB)
    erase_done = 0;
    boot_fail = 0;
    Rb_n_int <= 1'b0;   // Go busy
    status_register [6 : 5] = 2'b00;

    //check that any queued erase blocks meet the multi-plane addressing requirements
    check_plane_addresses;

    //first see if device was locked on powerup
    unlocked_erase =  ~ALLOWLOCKCOMMAND;
    //now see if any of the to-be-programmed address violate the current LockBlock constraints (for devices that support this)
    for (thisPlane=0; thisPlane < NUM_PLANES; thisPlane=thisPlane+1) begin
        lock_addr = row_addr[thisPlane];        
        if (LockInvert) begin
            unlocked_erase = unlocked_erase || (queued_plane[thisPlane] && ((lock_addr < UnlockAddrLower) || (lock_addr > UnlockAddrUpper)));
        end else begin
            unlocked_erase = unlocked_erase || (queued_plane[thisPlane] && ((lock_addr >= UnlockAddrLower) || (lock_addr <= UnlockAddrUpper)));
        end
    end

    // SMK : Erase now needs to check to see if address is same as a locked boot block
    for (thisPlane=0; thisPlane < NUM_PLANES; thisPlane=thisPlane+1) begin
        if (unlocked_erase && queued_plane[thisPlane])
            // boot blocks only need two address bits for blocks 0,1,2,3
            unlocked_erase = ~BootBlockLocked[row_addr[thisPlane][PAGE_BITS+1:PAGE_BITS]];
            boot_fail = 1;
    end

    //now proceed if address is unlocked and valid
    if (unlocked_erase) begin : unlocked_erase_block
        col  = 0;
        page = 0;
        for (thisPlane=0; thisPlane < NUM_PLANES; thisPlane=thisPlane+1) begin : plane_loop
            if (queued_plane[thisPlane]) begin //only proceed if this plane is queued to be erase
                erase_block_addr = row_addr[thisPlane][ROW_BITS-1:PAGE_BITS];
                if (1) begin $sformat(msg, "ERASE: Interleave=%h, Block=%h", thisPlane, erase_block_addr); INFO(msg);  end
                //Main reset implementation block
            `ifdef FullMem
                repeat (NUM_PAGE) begin : page_loop
                    mem_array [{erase_block_addr, page}] = {PAGE_SIZE{1'b1}};
                    pp_counter[{erase_block_addr,page}] = {4{1'b0}}; //reset partial page counter
                    page = page + 1'b1;
                end // page_loop
                seq_page[erase_block_addr] = {PAGE_BITS{1'b0}}; //reset sequential page counter for this block
            `else
                //use associative array erase block here
                for (i=0; i<memory_used; i=i+1) begin : mem_loop
                    //check to see if existing used address location matches block being erased
                    if (memory_addr[i][(ROW_BITS) -1 : (PAGE_BITS)] === erase_block_addr) begin
                        mem_array[i] = {PAGE_SIZE{1'b1}};
                        pp_counter[i] = {4{1'b0}};
                        seq_page[erase_block_addr] = {PAGE_BITS{1'b0}};
                    end
                end // mem_loop
            `endif
            end //if (queued_plane)
        end // plane_loop
        
        // Delay for RB# (tBERS) that grabs 70, 78, and FF commands while busy
        delay = tBERS_min;
        Rb_n_int <= #(delay) 1'b1;   // not busy anymore
        status_register [6 : 5] <= #(delay) 2'b11;
        erase_done <= #(delay) 1'b1;
        output_status;
    end else begin //unlocked_erase
        // else block was locked and cannot be erased
        if (boot_fail) begin
            $sformat (msg, "Not Erasing Block %0h. Boot Block is Locked.", new_addr[ROW_BITS-1:PAGE_BITS]);
        end else begin
            $sformat (msg, "Not Erasing Block %0h UnlockAddrLowr=%0h UnlockAddrUpr=%0h", new_addr[ROW_BITS-1:PAGE_BITS], UnlockAddrLower, UnlockAddrUpper);
        end
        INFO(msg);
        //  Delay for RB# (tBERS)
        status_register [7] = 1'b0;
        delay = (tLBSY_min - tWB_delay);
        go_busy(delay);
        Rb_n_int <= 1'b1;   // not busy anymore
        status_register [6:5] = 2'b11;
        erase_done = 1;
        if (LOCK_DEVICE) begin
            status_register [7] = 1'b0;
        end else begin
            status_register [7] = 1'b1;
        end
    end // unlocked_erase_block
end
endtask


//-----------------------------------------------------------------
// replaces erase_block task
//-----------------------------------------------------------------
always @(*)
begin
    erase_blk_pls <= #tWB_delay ((erase_blk_en & ~erase_blk_en_r) | (~erase_blk_en & erase_blk_en_r));
    erase_blk_en_r <= #1 erase_blk_en;
end 

//-----------------------------------------------------------------
// Erases a block of data in the memory array (clears to FF's) after tWB_delay
//-----------------------------------------------------------------
always @(posedge erase_blk_pls)
begin
//    #tWB_delay; // Delay For RB# (tWB)
    erase_done = 1'b0;
    eb_boot_fail = 1'b0;
    Rb_n_int <= 1'b0;   // Go busy
    status_register [6 : 5] = 2'b00;

    //check that any queued erase blocks meet the multi-plane addressing requirements
    check_plane_addresses;

    //first see if device was locked on powerup
    eb_unlocked_erase =  ~ALLOWLOCKCOMMAND;
    //now see if any of the to-be-programmed address violate the current LockBlock constraints (for devices that support this)
    for (eb_thisPlane=0; eb_thisPlane < NUM_PLANES; eb_thisPlane=eb_thisPlane+1) begin
        eb_lock_addr = row_addr[eb_thisPlane];        
        if (LockInvert) begin
            eb_unlocked_erase = eb_unlocked_erase || (queued_plane[eb_thisPlane] && ((eb_lock_addr < UnlockAddrLower) || (eb_lock_addr > UnlockAddrUpper)));
        end else begin
            eb_unlocked_erase = eb_unlocked_erase || (queued_plane[eb_thisPlane] && ((eb_lock_addr >= UnlockAddrLower) || (eb_lock_addr <= UnlockAddrUpper)));
        end
    end

    // SMK : Erase now needs to check to see if address is same as a locked boot block
    for (eb_thisPlane=0; eb_thisPlane < NUM_PLANES; eb_thisPlane=eb_thisPlane+1) begin
        if (eb_unlocked_erase && queued_plane[eb_thisPlane])
            // boot blocks only need two address bits for blocks 0,1,2,3
            eb_unlocked_erase = ~BootBlockLocked[row_addr[eb_thisPlane][PAGE_BITS+1:PAGE_BITS]];
            eb_boot_fail = 1'b1;
    end

    //now proceed if address is unlocked and valid
    if (eb_unlocked_erase) begin : unlocked_erase_block
        eb_page = 0;
        for (eb_thisPlane=0; eb_thisPlane < NUM_PLANES; eb_thisPlane=eb_thisPlane+1) begin : plane_loop
            if (queued_plane[eb_thisPlane]) begin //only proceed if this plane is queued to be erase
                erase_block_addr = row_addr[eb_thisPlane][BLCK_BITS+PAGE_BITS-1:PAGE_BITS];
                if (1) begin $sformat(msg, "ERASE: interleave/plane=%h, Block=%h", eb_thisPlane, erase_block_addr); INFO(msg);  end
                //Main reset implementation block
            `ifdef FullMem
                repeat (NUM_PAGE) begin : page_loop
                    mem_array [{erase_block_addr,eb_page}] = {PAGE_SIZE{1'b1}};
                    pp_counter[{erase_block_addr,eb_page}] = {4{1'b0}}; //reset partial page counter
                    eb_page = eb_page + 1'b1;
                end // page_loop
                seq_page[erase_block_addr] = {PAGE_BITS{1'b0}}; //reset sequential page counter for this block
            `else
                //use associative array erase block here
                for (e=0; e<memory_used; e=e+1) begin : mem_loop
                    //check to see if existing used address location matches block being erased
                    if (memory_addr[e][BLCK_BITS+PAGE_BITS-1:PAGE_BITS] === erase_block_addr) begin
                        mem_array[e] = {PAGE_SIZE{1'b1}};
                        pp_counter[e] = {4{1'b0}};
                        seq_page[erase_block_addr] = {PAGE_BITS{1'b0}};
                    end
                end // mem_loop
            `endif
            end //if (queued_plane)
        end // plane_loop
        
        // Delay for RB# (tBERS)
        Rb_n_int <= #(tBERS_min) 1'b1;   // not busy anymore
        status_register [6 : 5] <= #(tBERS_min) 2'b11;
        erase_done <= #(tBERS_min) 1'b1;
//        output_status;
        // from d0h cmd begin
        multiplane_op_erase <= #tBERS_min 1'b0;
        multiplane_op_rd    <= #tBERS_min 1'b0;
        multiplane_op_wr    <= #tBERS_min 1'b0;
        cache_op            <= #tBERS_min 1'b0;
        // from d0h cmd end
    end else begin //eb_unlocked_erase
        // else block was locked and cannot be erased
        if (eb_boot_fail) begin
            $sformat (msg, "Not Erasing Block %0h. Boot Block is Locked.", new_addr[ROW_BITS-1:PAGE_BITS]);
        end else begin
            $sformat (msg, "Not Erasing Block %0h UnlockAddrLowr=%0h UnlockAddrUpr=%0h", new_addr[ROW_BITS-1:PAGE_BITS], UnlockAddrLower, UnlockAddrUpper);
        end
        INFO(msg);
        //  Delay for RB# (tBERS)
        status_register [7] = 1'b0;
//        go_busy(delay);
        Rb_n_int <= #eb_delay 1'b1;   // not busy anymore
        status_register [6:5] <= #eb_delay 2'b11;
        erase_done <= #eb_delay 1'b1;
        if (LOCK_DEVICE) begin
            status_register [7] <= #eb_delay 1'b0;
        end else begin
            status_register [7] <= #eb_delay 1'b1;
        end
        // from d0h cmd begin
        multiplane_op_erase <= #eb_delay 1'b0;
        multiplane_op_rd    <= #eb_delay 1'b0;
        multiplane_op_wr    <= #eb_delay 1'b0;
        cache_op            <= #eb_delay 1'b0;
        // from d0h cmd end
    end // unlocked_erase_block
end

//-----------------------------------------------------------------
// TASK : inc_otpc (row_addr_tsk)
// Increments and checks OTP partial page counter for devices that
// support partial page programming.
//-----------------------------------------------------------------
task inc_otpc;        
    input [ROW_BITS - 1 : 0] row_addr_tsk; //OTP row address to check in partial page counter
begin
    //All nand devices with OTP support have an OTP partial page programming limit of OTP_NPP
    if (otp_counter[row_addr_tsk] < OTP_NPP) begin
        otp_counter[row_addr_tsk] = otp_counter[row_addr_tsk] + 1;
        if (DEBUG[0]) begin $sformat(msg, "OTP  partial page programming : Page=%0h  Count=%d  Limit=%1d", row_addr_tsk, otp_counter[row_addr_tsk], OTP_NPP); INFO(msg); end
    end else begin
        otp_counter[row_addr_tsk] = otp_counter[row_addr_tsk] + 1;
        $sformat(msg, "OTP partial page programming limit reached.  Page=%0h  Count=%d  Limit=%1d", row_addr_tsk, otp_counter[row_addr_tsk], OTP_NPP);
        ERROR(ERR_OTP, msg);
    end
end
endtask

//-----------------------------------------------------------------
// TASK : inc_pp (row_addr_tsk)
// Increments and check partial page counter for devices that
// support partial page programming.
//-----------------------------------------------------------------
task inc_pp;
    input [ROW_BITS -1: 0] row_addr_tsk; //row address to check in partial page counter
    reg [ROW_BITS -1: 0] index;
begin
`ifdef FullMem
    index = row_addr_tsk;
`else
    if (!pp_addr_exists(row_addr_tsk)) begin
           pp_used = pp_used + 1;
    end
    pp_addr[pp_index] = row_addr_tsk;
    index = pp_index;
`endif            
    if (DEBUG[2]) begin $sformat(msg, "Partial page counter:  Block=%0h, Page=%0h  Count=%d  Limit=%1d", row_addr_tsk[ROW_BITS-1:PAGE_BITS], row_addr_tsk[PAGE_BITS-1:0], pp_counter[index] +1, NPP); INFO(msg); end
    if (pp_counter[index] < NPP) begin
        pp_counter[index] = pp_counter[index] + 1;
    end else begin
        $sformat(msg, "Partial page programming limit reached.  Block=%0h Page=%0h Limit=%1d", row_addr_tsk[ROW_BITS-1:PAGE_BITS], row_addr_tsk[PAGE_BITS-1:0], NPP);
        ERROR(ERR_NPP, msg);
    end
end
endtask

//-----------------------------------------------------------------
// TASK : check_block (row_addr_tsk)
// Checks block for illegal random page programming
//-----------------------------------------------------------------
task check_block;
    input [ROW_BITS -1: 0] row_addr_tsk;
    reg [BLCK_BITS -1: 0] blck_addr_tsk;
    reg [PAGE_BITS -1: 0] page_tsk;
begin
    blck_addr_tsk = row_addr_tsk[ROW_BITS -1 : PAGE_BITS];
    page_tsk = row_addr_tsk[PAGE_BITS -1 : 0];
    if (page_tsk == seq_page[blck_addr_tsk]) begin 
        // don't need to do anything here, programming to same page already in seq_page block checker
    end    else if (page_tsk == (seq_page[blck_addr_tsk] +1)) begin
           // increment page in sequential page checker for this block
        seq_page[blck_addr_tsk] = seq_page[blck_addr_tsk] +1;
        if (DEBUG[2]) begin $sformat (msg, "Programming to  Block=%0h  Page=%0h", blck_addr_tsk, page_tsk); INFO(msg); end
    end else begin
        $sformat(msg, "Random page programming within a block is prohibited! Block=%0h, Page=%0h, last page=%0h", blck_addr_tsk, page_tsk, seq_page[blck_addr_tsk]);
        ERROR(ERR_ADDR, msg);
    end
end
endtask


//-----------------------------------------------------------------
// TASK : program_page (multiplane, cache_op)
// Programs a page of data from cache register 
// to data register.
//-----------------------------------------------------------------
task program_page;
    input multiplane;
    input prog_cache_op;
    integer thisPlane;

begin
    if (DEBUG[0]) begin $sformat(msg, "START CACHE ARRAY PROGRAMMING, multiplane=%d, prog_cache_op=%d", multiplane, prog_cache_op); INFO(msg); end
    // Delay For RB# (tWB)
    go_busy(tWB_delay);
    Rb_n_int <= 1'b0;
    status_register [6 : 5] = 2'b00;
    
    queued_copyback2 = 1; //useful when 8'h10 ends a copyback2 cache program to let
                                  //the model know not to drive status bits and Rb_n as ready
                                  //until the last copyback program is executed
    
    //copy cache regs to data regs for planes that will be programmed
    if (~bypass_cache)  copy_cachereg_to_datareg;
    row_valid = 1'b0;

    // if cache prog, last program may still be active
    // need to wait for it to finish
    if (~array_prog_done) go_busy (tprog_done - $realtime);
       //wait for array programming to finish (in case array_prog_done doesn't go
       // high unti end of current timestep)
    wait(array_prog_done);
    queued_copyback2 <= 0;
    
    if (prog_cache_op === 1) begin
        // this is for cache mode program ops
        // now wait for delay to transfer cache_reg -> data_reg
        go_busy(tCBSY_min);    
        if (lastCmd === 8'h10) begin
            prog_cache_op = 1'b0;
        end else begin
            Rb_n_int <= 1'b1;
            //only cache bit in status register changes here
            status_register [6] = 1'b1;
        end
    end
    //if this is  a copyback op, no program executes here.
    // If this is the last program page in a copyback cache operation, we'll
    if (~copyback2) begin
        program_page_from_datareg(multiplane); 
    end
    
    copyback2 = 0;
end
endtask

//-----------------------------------------------------------------
// TASK : program_page_from_datareg (multiplane, cache_mode)
// Programs a page of data from data register 
// to flash memory array.
//-----------------------------------------------------------------
task program_page_from_datareg;
    input multiplane;
    integer thisPlane;
    reg [ROW_BITS -1 : 0] array_prog_addr;
    reg [ROW_BITS -1 : 0] lock_addr;
    reg otp_prog_fail;
    integer page_count, otp_count;
    reg page_addr_good;
    reg unlocked_write;
    integer mem_mp_index;  //local 2plane memory index for associative addressing
    integer delay;
    
begin
    unlocked_write = 0;
    if (DEBUG[0]) begin $sformat (msg, "PROGRAM PAGE FROM DATAREG, multiplane=%d, cache_op=%d", multiplane, cache_op); INFO(msg); end
    array_prog_done = 1'b0;
    array_prog_2plane = 1'b0;
    status_register[5] = 1'b0;

    if (multiplane) begin
    end    else begin
        if (FEATURE_SET[CMD_2PLANE]) begin
            if (row_addr[active_plane][PAGE_BITS] != cmnd_35h_row_addr[PAGE_BITS]) begin
                $sformat(msg, "Invalid operation.  Internal Data Move is only allowed within the same plane.  Addr from=%0h  Addr to=%0h", cmnd_35h_row_addr, row_addr[active_plane]);
                ERROR(ERR_ADDR, msg);
            end
        end
    end

    //check that any queued program addresses meet the multi-plane addressing requirements
    check_plane_addresses;

    //first see if device was locked on powerup
    unlocked_write =  ~ALLOWLOCKCOMMAND;
    //now see if any of the to-be-programmed address violate the current LockBlock constraints (for devices that support this)
    for (thisPlane=0; thisPlane < NUM_PLANES; thisPlane=thisPlane+1) begin
        lock_addr = row_addr[thisPlane];        
        if (LockInvert) begin
            unlocked_write = unlocked_write || (queued_plane[thisPlane] && ((lock_addr < UnlockAddrLower) || (lock_addr > UnlockAddrUpper)));
        end else begin
            unlocked_write = unlocked_write || (queued_plane[thisPlane] && ((lock_addr >= UnlockAddrLower) && (lock_addr <= UnlockAddrUpper)));
        end
    end

    // ----------------------------------------------------------------------------------------------------
    // SMK : put boot block check here (for devices that support this)
    // ----------------------------------------------------------------------------------------------------
        //only stay unlocked if this is an unlocked boot block (no need to do this check during regular OTP mode)
    if (~OTP_write) begin
        for (thisPlane=0; thisPlane < NUM_PLANES; thisPlane=thisPlane+1) begin
            if (unlocked_write && queued_plane[thisPlane])
                // boot blocks only need two address bits for blocks 0,1,2,3
                unlocked_write = ~BootBlockLocked[row_addr[thisPlane][PAGE_BITS+1:PAGE_BITS]];
        end
    end

    // ----------------------------------------------------------------------------------------------------

    //now proceed if address is unlocked and valid
    if (unlocked_write) begin : unlocked_write_command

        page_count = 1'b0;
        otp_count = 1'b0;
        otp_prog_fail = 0;
        // Write to Memory Array
                
        for (thisPlane = 0; thisPlane < NUM_PLANES; thisPlane = thisPlane + 1) begin : plane_loop
            if (OTP_write && (thisPlane == 0)) begin : otp_page_write
                otp_prog_addr = row_addr[active_plane];
                if((|otp_prog_addr[ROW_BITS-1:PAGE_BITS]) | (otp_prog_addr[PAGE_BITS-1:0] >= OTP_ADDR_MAX)) begin : OTP_prog_overflow
                    $sformat(msg, "Error: OTP Program Address Overflow, block addr not equal 0 or page address >= %0h:  block addr =%0h  page addr =%0h",OTP_ADDR_MAX, (otp_prog_addr[ROW_BITS-1:PAGE_BITS]), otp_prog_addr[PAGE_BITS-1:0]);
                    ERROR(ERR_OTP, msg);
                end
                // if the whole OTP is locked or this page is locked (when OTP lock_by_page is enabled), the operation fails
                if (OTP_locked || OTP_page_locked[otp_prog_addr]) begin : OTP_locked_block
                    $sformat(msg, "OTP Program FAILED - OTP Protected!  Aborting program operation ...");
                    ERROR(ERR_OTP, msg);
                    status_register [7 : 5] = 3'b011;
                    otp_prog_fail = 1;
                    
    // ----------------------------------------------------------------------------------------------------
    // SMK : put all M58A ONFI OTP PAGE LOCK stuff BELOW this line
    // ----------------------------------------------------------------------------------------------------
                // SMK : OTP_page_locked is new addition to memory elements.  Use during OTP lock_by_page enabled ops
                // SMK : BootBlockLocked [3:0] is new addition to memory elements.  Use during Boot block lock
                     
                // Here we check for the ONFI specific OTP Lock command/address sequence
                //  page byte = enabled OTP lock        (lock by page disabled)
                //            = OTP page lock address   (lock by page enabled, EFh-90h-03h-00h-00h-00h)  
                //            = Boot lock block address (lock by page enabled, EFh-90h-04h-00h-00h-00h)  
                end else if (((otp_prog_addr[(PAGE_BITS-1):0] == 1) || (onfi_features[8'h90] >= 3))
                                && (col_addr == 0) && FEATURE_SET[CMD_ONFIOTP]) begin
                    // new OTP with FEATURES access uses page 1 and col addr 0 to protect the OTP
                    case (onfi_features[8'h90])
                    //bit 0 = OTP; bit 1 = PROTECT
                    1: begin
                            if (data_reg[active_plane][7:0] == 0) begin
                                if (otp_prog_addr[7:0] == 1) begin
                                   $sformat(msg,"OTP will now be PROTECTED"); INFO(msg);
                                   if (DEBUG[2]) begin
                                       $sformat(msg,"OTP protect : Found address 0x00,0x00,0x01,0x00,0x00 with 0x00 data."); INFO(msg);
                                   end
                                   OTP_locked = 1'b1;
                                end
                            end else begin
                                $sformat(msg, "Illegal OTP protect command : First byte of data after 0x00,0x00,0x01,0x00,0x00 OTP address must be 0x00.");
                                ERROR(ERR_OTP, msg);
                            end
                       end
                        
                    3: begin
                            // EFH-90h-03h... is the only way to execute an OTP lock by page operation
                            if (FEATURE_SET[CMD_PAGELOCK]) begin
                                if (col_counter == 1) begin
                                    // this is an OTP lock by page operation
                                    OTP_page_locked[otp_prog_addr[7:0]] = 1'b1;
                                    $sformat(msg,"OTP mode with PROTECT bit is now set on page %0h", otp_prog_addr[7:0]);
                                    INFO(msg);
                                end else begin
                                    $sformat(msg, "Illegal OTP protect command : Only one data byte allowed during OTP protect command sequence.");
                                    ERROR(ERR_OTP, msg);
                                end
                            end else begin
                                $sformat(msg, "Illegal OTP operation : This device is not configured to support OTP lock by page.");
                                ERROR(ERR_OTP, msg);
                            end
                       end
                    endcase
                    
    // ----------------------------------------------------------------------------------------------------
    // SMK : put all M58A ONFI OTP PAGE LOCK stuff ABOVE this line
    // ----------------------------------------------------------------------------------------------------
                    
                end else if ((8'h02 > otp_prog_addr[(PAGE_BITS -1):0]) || (OTP_ADDR_MAX < otp_prog_addr[(PAGE_BITS -1):0])) begin
                       $sformat(msg, "OTP Prorgram FAILED - OTP page address out of bound! Page address = %0h", otp_prog_addr[(PAGE_BITS-1):0]);
                       ERROR(ERR_OTP, msg);
                       otp_prog_fail = 1;
                       status_register[7] = 1'b0;
                end else begin
                    if(OTP_NPP == 1) begin
                        // only program if OTP data is still FF's
                        if (&OTP_array[otp_prog_addr]) begin
                            otp_prog_done = 1'b0;
                            OTP_array [otp_prog_addr] = data_reg[active_plane];
                            if (otp_count == 0) inc_otpc(otp_prog_addr);
                            otp_count = 1'b1;
                            if (DEBUG[2]) begin $sformat(msg, "OTP Program from Data Register = %0h", data_reg[active_plane]); INFO(msg); end
                        end else begin
                            // if OTP data is not FF's, report error if data reg is trying to program new values
                            if (~(&data_reg[active_plane])) begin
                                   $sformat(msg, "OTP program attempted to write to previously programmed address = %0h.  Cannot overwrite.", otp_prog_addr);
                                   ERROR(ERR_OTP, msg);
                            end
                        end
                    end else begin
                        otp_prog_done = 1'b0;
                        OTP_array [otp_prog_addr] = data_reg[active_plane] & OTP_array [otp_prog_addr];
                        if (otp_count == 0) inc_otpc(otp_prog_addr);
                        otp_count = 1'b1;
                        if (DEBUG[2]) begin $sformat(msg, "OTP Program from Data Register = %0h", data_reg[active_plane]); INFO(msg); end
                    end 
                end //OTP_locked_block
            end else if (boot_block_lock_mode) begin
                if (col_counter == 1) begin
                    if(row_addr[active_plane][ROW_BITS-1:PAGE_BITS] >= NUM_BOOT_BLOCKS) begin 
                        $sformat(msg,"WARNING: Boot block %0h can not be locked. Block %0h is the boot block lock upper limit", row_addr[active_plane][ROW_BITS-1:PAGE_BITS], (NUM_BOOT_BLOCKS-1)); WARN(msg);
                    end else begin 
                        // boot block is part of NAND Flash array, not OTP array.  Once boot block is locked, can not be unlocked.  
                        BootBlockLocked[row_addr[active_plane][PAGE_BITS+BOOT_BLOCK_BITS-1:PAGE_BITS]] = 1'b1;
                        $sformat(msg,"Boot block %0h will now be locked", row_addr[active_plane][ROW_BITS-1:PAGE_BITS]); INFO(msg);
                    end 
                end else begin
                    $sformat(msg, "Illegal command: Only one data byte allowed during boot block locking command sequence.");  ERROR(ERR_CMD, msg);
                end
            end else begin //page_write
                //set up the address to load
                if (queued_plane[thisPlane]) begin : queued_plane_section //only proceed if this plane is queued to program
                    array_prog_addr = row_addr[thisPlane]; //old-style regular 2plane addressing scheme

                    page_addr_good = 0;
                    `ifdef FullMem
                    `else
                    if (memory_addr_exists(array_prog_addr)) begin
                        page_addr_good = 1;
                        mem_mp_index = memory_index;
                    end else begin
                        pp_counter[memory_index]  = {4{1'b0}}; //initialize partial page counter
                        memory_addr[memory_index] = array_prog_addr;
                        mem_array [memory_index]  = {PAGE_SIZE{1'b1}}; // initialize array row data
                        `ifdef PACK
                        for (i = 0; i <= NUM_COL - 1; i = i + 1) begin
                            mem_array_packed [memory_index][i]  = {(DQ_BITS*BPC_MAX){1'b1}}; // initialize array row data
                        end 
                        `endif 
                        memory_used  = memory_used + 1'b1;
                        mem_mp_index = memory_index;
                        memory_index = memory_index + 1'b1;
                    end
                    `endif
                    
                        if (DEBUG[2]) begin $sformat(msg, "Programmed %0h to memory location (%0h, %0h)", data_reg[active_plane],  array_prog_addr[(ROW_BITS -1) : (PAGE_BITS)], array_prog_addr[(PAGE_BITS -1) : 0]); INFO(msg); end
                        //program the array
                        `ifdef FullMem
                        mem_array [array_prog_addr] = data_reg[thisPlane] & mem_array [array_prog_addr];
                        `else
                        if (memory_used > NUM_ROW) begin
                            $sformat (msg, "Memory overflow.  Write to Address %h with Data %h will be lost.\nYou must increase the NUM_ROW parameter or define FullMem.", {array_prog_addr,i}, data_reg[thisPlane[0]][i]);
                            FAIL(msg);
                        end else begin
                            mem_array[mem_mp_index] =  data_reg[thisPlane] & mem_array [mem_mp_index];
                            `ifdef PACK
                            for (i = 0; i <= NUM_COL - 1; i = i + 1) begin
                                case (thisPlane)
                                0 : mem_array_packed[mem_mp_index][i] = data_reg_packed0[i] & mem_array_packed [mem_mp_index][i];
                                1 : mem_array_packed[mem_mp_index][i] = data_reg_packed1[i] & mem_array_packed [mem_mp_index][i];
                                2 : mem_array_packed[mem_mp_index][i] = data_reg_packed2[i] & mem_array_packed [mem_mp_index][i];
                                3 : mem_array_packed[mem_mp_index][i] = data_reg_packed3[i] & mem_array_packed [mem_mp_index][i];
                                endcase
                            end
                            `endif 
                        end
                        `endif
                    inc_pp(array_prog_addr);
                    check_block(array_prog_addr);
                end // queued_plane_section
            end //page_write
        end //plane_loop
                   
        OTP_write = 1'b0;
        // Set Delay for RB# (tPROG)
        case (lastCmd) 
            8'h10 : begin
                if (otp_prog_fail) delay = tOBSY_max;
                else if(cache_prog_last) delay = tLPROG_cache_typ;
                else delay = tPROG_typ;
            end
            8'h15 : delay = tPROG_typ;
            8'h11 : delay = tDBSY_min;
            8'hA0 : delay = tOBSY_max;
        endcase 
        tprog_done = ($realtime + delay);
        array_prog_done <= #(delay) 1'b1;
        otp_prog_done   <= #(delay) 1'b1;

    end else begin
        // else if block is locked
        if (BootBlockLocked[row_addr[active_plane][PAGE_BITS+1:PAGE_BITS]]) begin
            $sformat(msg, "LOCKED: Not Programing Block 0x%0h.  Boot Block has been locked.", row_addr[active_plane][BLCK_BITS-1:PAGE_BITS]);
        end else begin
            $sformat(msg, "LOCKED: Not Programing Block 0x%0h, page 0x%0h, UnlockAddrLowr=%0h UnlockAddrUpr=%0h, invert=%0d", row_addr[active_plane][BLCK_BITS-1:PAGE_BITS], row_addr[active_plane][PAGE_BITS-1:0], UnlockAddrLower, UnlockAddrUpper, LockInvert);
        end
        WARN(msg);
        status_register [7] = 1'b0;
        delay = tLBSY_min;
        go_busy(delay);
        array_prog_done = 1'b1;
        Rb_n_int <= 1'b1;   // not busy anymore
        status_register [6:5] = 2'b11;
        if (LOCK_DEVICE) begin
            status_register [7] = 1'b0;
        end else begin
            status_register [7] = 1'b1;
        end
    end //unlocked_write_command
end
endtask

//-----------------------------------------------------------------
// TASK : clear_queued_planes()
//      ensures that all planes are not queued as active until
//      addressed by the next command.
//-----------------------------------------------------------------
task clear_queued_planes;
    integer i;
begin
    for (i=0;i<NUM_PLANES; i=i+1) begin
        queued_plane[i] = 0;
        if(DEBUG[4]) begin $sformat(msg, "INFO: Cleared queued plane %0d. Value %d", i, queued_plane[i]); INFO(msg); end 
    end
end
endtask

//-----------------------------------------------------------------
// TASK : finish_array_prog
// Cleans up status register and busy signals once array
// programming has finished.
//-----------------------------------------------------------------
task finish_array_prog;
begin
    if (DEBUG[0]) begin $sformat(msg, "PROGRAM DATA REG DONE."); INFO(msg); end
    //if not a cache op, device goes ready
    // Also, if not the last tLPROG of final cache program pages for copyback2, 
    //   device will go ready
    if (~cache_op && ~(queued_copyback2 && ~copyback2)) begin
        Rb_n_int <= 1'b1; // Device Ready
        status_register [6] = 2'b1;           
        if (~nand_mode[0]) status_register[5] = 1;
        output_status;
    end else begin
        cache_prog_last = 1'b0;
        output_status;
    end
end
endtask

//-----------------------------------------------------------------
// TASK : finish_array_load
// Cleans up status register and busy signals once reading
// from the flash memory array has finished.
//-----------------------------------------------------------------
task finish_array_load;
begin
    if (DEBUG[0]) begin $sformat(msg, "ARRAY LOAD COMPLETE."); INFO(msg); end
    if ((lastCmd === 8'h3F) && queued_load) begin
        queued_load = 0;
    end else begin
        Rb_n_int <= disable_ready_n;
        if (copyback2) begin
            status_register[6:5] = 2'b10;
        end else begin
        status_register [6] = 2'b1;           
        if (~nand_mode[0]) status_register[5] = 1;
        end
        output_status;
    end
end
endtask

//-----------------------------------------------------------------
// TASK : go_busy (delay)
// Device goes busy for specified delay while still checking 
// for status and reset commands.
//-----------------------------------------------------------------
task go_busy;
    input delay;
    integer delay;
    reg saw_edge_we_n;
    reg last_we_n;
    realtime tstep;  //step through at a rate just under tWP;  that all we need for this busy task to work
begin
    if (DEBUG[0]) begin $sformat(msg, "busy delay of %t ns ", delay); INFO(msg); end
    if (sync_mode) begin
    end else begin
        //tstep = tWP_min - (2* 1000 * TS_RES_ADJUST);
        tstep = 2 * (1000 * TS_RES_ADJUST);
    end
    last_we_n = We_n;
    while (delay > 0) begin  : delay_loop
        if ((delay -tstep) >= 0) begin
            #tstep;
        end else begin
            #delay;
        end
        delay = delay - tstep;
        if (delay < 0) delay = 0;
        if (last_we_n !== We_n) begin
            saw_edge_we_n = 1'b1;
        end else begin
            saw_edge_we_n = 1'b0;
        end
        last_we_n = We_n;
        if (Cle && We_n && ~Ale && Re_n && ~Ce_n && saw_edge_we_n) begin
            if ((Io [7 : 0] === 8'h70) && die_select && (cmnd_70h === 1'b0)) begin
                if (DEBUG[3]) begin $sformat(msg, "STATUS READ WHILE BUSY : MODE = STATUS"); INFO(msg); end
                cmnd_70h = 1'b1;
                cmnd_78h = 1'b0;
            end else if ((Io [7 : 0] === 8'h78) && ~disable_md_stat) begin
                if (DEBUG[1]) begin $sformat(msg, "MULTI DIE READ STATUS READ WHILE BUSY : MODE = STATUS"); INFO(msg); end
                cmnd_70h = 1'b0;
                cmnd_78h = 1'b1;
                addr_start = COL_BYTES +1;
                addr_stop  =  ADDR_BYTES;
                row_valid = 1'b0;
            end else if (Io [7 : 0] === 8'hFF) begin
                $sformat(msg, "RESET WHILE BUSY - ABORT");
                INFO(msg);
                lastCmd = 8'hFF;
                nand_reset(1);
                disable delay_loop; //exit out of this loop
            end
        end
    end // delay_loop
end
endtask   


//-----------------------------------------------------------------
// FUNCTION : memory_addr_exists (addr)
// Checks to see if memory address is already used in
// associative array.
 //-----------------------------------------------------------------
function memory_addr_exists;
    input [ROW_BITS -1:0] addr;
begin : index
    memory_addr_exists = 0;
    for (memory_index=0; memory_index<memory_used; memory_index=memory_index+1) begin
        if (memory_addr[memory_index] == addr) begin
            if (DEBUG[2]) begin $display("Memory index %0d memory address (%0h)", memory_index,  memory_addr[memory_index]); end
            memory_addr_exists = 1;
            disable index;
        end
    end
end
endfunction


//-----------------------------------------------------------------
// FUNCTION : pp_addr_exists (addr)
// Checks to see if memory address is already used in
// partial page programming associative array.
//-----------------------------------------------------------------
function pp_addr_exists;
    input [(ROW_BITS) -1:0] addr;
begin : pp_func
    pp_addr_exists = 0;
    for (pp_index=0; pp_index<pp_used; pp_index=pp_index+1) begin
        if (pp_addr[pp_index] == addr) begin
            pp_addr_exists = 1;
            disable pp_func;
        end
    end
end
endfunction

//-----------------------------------------------------------------
// function : fn_inc_col_counter
//  Common function to increment col_counter. 
//-----------------------------------------------------------------
function    [COL_CNT_BITS -1 : 0]  fn_inc_col_counter  ;
    input   [COL_CNT_BITS -1  : 0] col_counter         ;
    input                          mlc_slc             ;
    input   [1:0]                  bpc                 ;
    input   [1:0]                  sub_col_cnt         ;
begin
        case (bpc)
            3'b010 : if(sub_col_cnt ==2'b01) fn_inc_col_counter = col_counter + 1'b1; else fn_inc_col_counter = col_counter;
            3'b011 : if(sub_col_cnt ==2'b10) fn_inc_col_counter = col_counter + 1'b1; else fn_inc_col_counter = col_counter;
            3'b100 : if(sub_col_cnt ==2'b11) fn_inc_col_counter = col_counter + 1'b1; else fn_inc_col_counter = col_counter;
            default:                         fn_inc_col_counter = col_counter + 1'b1; // bpc =1 
        endcase
end
endfunction

//-----------------------------------------------------------------
// function : fn_sub_col_cnt
//  Function to increment column sub count 
//-----------------------------------------------------------------
function    [1:0]   fn_sub_col_cnt      ;
    input   [1:0]   sub_col_cnt         ;
    input           mlc_slc             ;
    input   [2:0]   bpc                 ;
    input   [1:0]   sub_col_cnt_init    ;  // sub col cnt init enables counting
begin
        case (bpc)
            3'b010 : if (sub_col_cnt ==2'b01)
                        fn_sub_col_cnt = 0; // roll count over for next column
                     else
                        fn_sub_col_cnt = sub_col_cnt + 1'b1;
            3'b011 : if (sub_col_cnt ==2'b10)  
                        fn_sub_col_cnt = 0;  // roll count over for next column
                     else
                        fn_sub_col_cnt = sub_col_cnt + 1'b1;
            3'b100 : if (sub_col_cnt ==2'b11)  
                        fn_sub_col_cnt = 0;  // roll count over for next column
                     else
                        fn_sub_col_cnt = sub_col_cnt_init & (sub_col_cnt + 1'b1);
            default: fn_sub_col_cnt = sub_col_cnt; // BPC =1 don't need sub cnt
        endcase
end
endfunction

//-----------------------------------------------------------------
// TASK : nand_reset (soft_reset)
// Resets the device.
// 0 = power on reset
// 1 = soft reset 
//-----------------------------------------------------------------
task nand_reset;
    input soft_reset;
    reg dev_was_busy;
    integer delay;
begin
    ResetComplete = 1'b0;
    if (Rb_n_int === 1'b0) begin
        dev_was_busy = 1'b1;
    end else begin
        dev_was_busy = 1'b0;
    end
    $sformat(msg, "Entering Reset ...");
    INFO(msg);

    //reset read status states
    disable_rdStatus;
    // Delay For RB# (tWB)
    `ifdef SYNC2ASYNCRESET
        if (lastCmd === 8'hFF && sync_mode)     sync_mode <= #tITC_max 1'b0;
    `endif
    #tWB_delay;
    Rb_n_int = 1'b0;
    disable_ready_n = 1'b1;
    if (soft_reset) begin
        // reset during regular op
        // Delay for RB# (tRST)
        if (dev_was_busy) begin : busy_interrupt
            //array read interrupted
            if (~array_load_done) begin
                delay = tRST_read;
                //array program interrupted
            end else if (~array_prog_done) begin
                delay = tRST_prog;
                if (~otp_prog_done) begin
                    corrupt_otp_page(otp_prog_addr); //OTP program interrupted
                end else begin
                    for (i=0;i<NUM_PLANES;i=i+1) begin
                        if (queued_plane[i]) corrupt_page(row_addr[i]); //regular array program interrupted
                    end
                    
                end
            //erase interrupted
            end else if (~erase_done) begin
                //when interrupting go_busy task, model is already #1 ahead
                delay = (tRST_erase-1);
                for (i=0;i<NUM_PLANES;i=i+1) begin
                    if (queued_plane[i]) corrupt_block(row_addr[i][ROW_BITS-1:PAGE_BITS]);
                end
            end
        end else begin
            delay = tRST_ready;
        end // busy_interrupt
    end
       
    //clear flags and set status to busy
    status_register [6 : 5] = 2'b00;
    col_valid       = 1'b0;
    col_addr        = 0;
    temp_col_addr   = 0;
    row_valid       = 1'b0;
    for (i=0;i<NUM_PLANES;i=i+1) begin
        row_addr[i] = 0;
    end
    clear_queued_planes;
    rd_pg_cache_seqtl = 1'b0;
    multiplane_op_rd_cache = 1'b0;
    cache_valid     = 1'b0;
    multiplane_op_erase   = 1'b0;
    multiplane_op_rd      = 1'b0;
    multiplane_op_wr      = 1'b0;
    copy_queued_planes;  // clear cache queued planes and mp rd op cache flag on reset
    cache_op        = 1'b0;
    disable_md_stat = 1'b0;
    saw_cmnd_00h    = 1'b0;
    saw_cmnd_00h_stat    = 1'b0;
    saw_cmnd_65h    = 1'b0;
    do_read_id_2    = 1'b0;
    do_read_unique  = 1'b0;
    addr_start      = 0;
    addr_stop       = 0;
    active_plane    = 0;
    otp_prog_done   = 1'b1;
    edo_mode        = 0;
    erase_done      = 1'b1;
    Io_buf         <= {DQ_BITS{1'bz}};

    if (lastCmd === 8'hFF) begin
    end
    //device now goes busy for appropriate reset time
    if (soft_reset) begin
        go_busy(delay);
    end else begin
        //else this is a power-on reset
        //multi-die status read disabled after initial reset
        disable_md_stat = 1'b1;
`ifdef SHORT_RESET
        go_busy(tRST_ready);
`else
        go_busy(tRST_powerup);
`endif
    end

    // Ready
    Rb_n_int       <= 1'b1;
    tprog_done      = 0;
    tload_done      = 0;
    t_readtox       = 0;
    t_readtoz       = 0;
    array_prog_done = 1'b1;
    array_load_done = 1'b1;
    status_register [6 : 5] = 2'b11;
    $sformat(msg, "Reset Complete");
    INFO(msg);
    ResetComplete   = 1'b1;
end
endtask

//-----------------------------------------------------------------
// TASK : disable_rdStatus
// Resets status flags to put device back in read mode
//-----------------------------------------------------------------
task disable_rdStatus;
begin
    cmnd_70h = 1'b0;
    cmnd_78h = 1'b0;
end
endtask

//-----------------------------------------------------------------
// TASK : update_features
// Selects the new operating characteristics based on the ONFI 
//  parameters feature address
//-----------------------------------------------------------------
task update_features;
    input [7:0] featAddr;
    begin
        case (featAddr)
            8'h01 : begin //Timing mode
                    end    
            8'h10 : begin //  Programmable Output Drive Strength
                        if (DEBUG[2]) $display("Programmable I/O Drive Strength is not implemented in this model.");
                    end
            8'h80 : begin //  Programmable Output Drive Strength
                        if (DEBUG[2]) $display("Programmable I/O Drive Strength is not implemented in this model.");
                    end
            8'h81 : begin // Programmable R/B# pull-down strength
                        if (DEBUG[2]) $display("Programmable R/B# Pull-Down Strength  is not implemented in this model.");          
                    end
            
            8'h90 : begin //OTP operating mode
                        OTP_mode     = onfi_features[featAddr][0] & FEATURE_SET[CMD_ONFIOTP];
                        OTP_pagelock = onfi_features[featAddr][1] & FEATURE_SET[CMD_PAGELOCK] & FEATURE_SET[CMD_ONFIOTP]; 
                        boot_block_lock_mode = onfi_features[featAddr][2] & FEATURE_SET[CMD_BOOTLOCK];

                        if (FEATURE_SET[CMD_ONFIOTP] & onfi_features[featAddr][0]) begin //set = OTP mode, clear= normal op mode
                            $sformat(msg,"Entering OTP mode ..."); INFO(msg);
                            // check lock by page enabled and protect bit is set (not all devices support this feature)
                            if (FEATURE_SET[CMD_PAGELOCK] & onfi_features[featAddr][1]) begin
                                $sformat(msg, "Protect bit is set.  Enabling OTP protect by page ..."); INFO(msg);
                            end
                        end else if (FEATURE_SET[CMD_BOOTLOCK] & onfi_features[featAddr][2] ) begin
                            $sformat(msg,"Entering Boot Block Lock Mode ..."); INFO(msg);
                        end else begin
                            $sformat(msg,"Entering Normal Operating mode ..."); INFO(msg);
                            //OTP_locked does not get reset when we leave OTP mode
                        end
                        if(~OTP_mode) status_register[7] = Wp_n;
                    end
            8'h91 : begin
                    end
            
            default: begin $sformat(msg, "This ONFI Feature address is reserved."); WARN(msg); end
       endcase
    end
endtask


//-----------------------------------------------------------------
// TASK : check_plane_addresses
// Loops through each plane to see if there is a queued
//  address for the current operation.  Checks to ensure that
//  multi-plane address rules are not violated.
//-----------------------------------------------------------------
task check_plane_addresses;
    integer thisPlane;
    reg [ROW_BITS -1 : 0] current_addr;
    reg [ROW_BITS -1 : 0] first_addr;
    reg addr_good;
    integer num_addresses; 
begin
    num_addresses = 0;
    addr_good = 0;
    for (thisPlane=0; thisPlane <NUM_PLANES; thisPlane=thisPlane+1) begin
        if (queued_plane[thisPlane]) begin
            if(DEBUG[4]) begin $sformat(msg, "INFO: Checked queued plane %0d. Value %0d", thisPlane, queued_plane[thisPlane]); INFO(msg); end 
            if (num_addresses > 0) begin
                current_addr = row_addr[thisPlane];
                    array_prog_2plane = 1'b1;
                    if (NUM_PLANES > 2) begin
                        if (~copyback & (current_addr[PAGE_BITS + (NUM_PLANES >> 2):PAGE_BITS] == first_addr[PAGE_BITS + (NUM_PLANES >> 2):PAGE_BITS])) begin
                            $sformat(msg, "Multi-plane address error. -> LSB's of Interleave/Plane addresses need to be different in multi plane operations. Interleave1=%h Interleave2=%h", current_addr[PAGE_BITS + (NUM_PLANES >> 2):PAGE_BITS], first_addr[PAGE_BITS + (NUM_PLANES >> 2):PAGE_BITS]);
                            ERROR(ERR_ADDR, msg);  // Verify different Plane addresses.  
                        end 
                        // copyback ops have identical interleave/plane address between read/program, the cache register is assoc with interleave/plane so no check is needed, need to check 2plane ???.  
                        if (copyback & FEATURE_SET[CMD_2PLANE] & (current_addr[PAGE_BITS + (NUM_PLANES >> 2):PAGE_BITS] != first_addr[PAGE_BITS + (NUM_PLANES >> 2):PAGE_BITS])) begin
                            $sformat(msg, "Copyback address error. -> Interleave/Plane Address must be identical. Interleave1=%h Interleave2=%h", current_addr[PAGE_BITS + (NUM_PLANES >> 2):PAGE_BITS], first_addr[PAGE_BITS + (NUM_PLANES >> 2):PAGE_BITS]);
                            ERROR(ERR_ADDR, msg);  // Verify same Plane Address.  
                        end 
                    end else begin
                        // no need to check for copyback mode, because only one interleave/plane.  
                        if (~copyback & (current_addr[PAGE_BITS] == first_addr[PAGE_BITS])) begin
                            $sformat(msg, "Multi-plane address error. -> LSB's of block addr violate multi plane addressing requirements. Block1=%h Block2=%h", current_addr[ROW_BITS-1:PAGE_BITS], first_addr[ROW_BITS-1:PAGE_BITS]);
                            ERROR(ERR_ADDR, msg);  // Verify that Plane addresses are different.  
                        end 
                    end
                    if (current_addr[PAGE_BITS-1:0] != first_addr[PAGE_BITS-1:0]) begin
                        $sformat(msg, "Multi-plane address error. -> Page address must be identical for multi plane op Page1=%b Page2=%b", current_addr[PAGE_BITS-1:0], first_addr[PAGE_BITS-1:0]);
                        ERROR(ERR_ADDR, msg);  // ??? multiplane errors with incomplete write clear_queued_planes uncomment with fix
                    end 
                    if(DEBUG[4]) begin $sformat(msg, "INFO: number of planes %0d", (NUM_PLANES >> 2)); INFO(msg); end 
                    if (current_addr[ROW_BITS-1:ROW_BITS-(NUM_DIE/NUM_CE)] != first_addr[ROW_BITS-1:ROW_BITS-(NUM_DIE/NUM_CE)]) begin
                        $sformat(msg, "Multi-plane address error. -> MSB's of block addr must be identical for multi plane op  Block1=%h  Block2=%h ", current_addr[ROW_BITS-1:PAGE_BITS], first_addr[ROW_BITS-1:PAGE_BITS]); 
                        ERROR(ERR_ADDR, msg);  // ??? issue with multiple reads to same page separated by another page read.  
                    end
                num_addresses = num_addresses + 1;
            end else begin
                num_addresses = 1;
                first_addr = row_addr[thisPlane];
            end //if num_addresses
        end //if queued plane
    end // for thisPlane
end
endtask

//-----------------------------------------------------------------
// Array prog/load scheduler
//-----------------------------------------------------------------


always @ (posedge array_prog_done) begin
    finish_array_prog;
end

always @ (posedge array_load_done) begin
    finish_array_load;
end


assign Ce_n =Ce_n_i;


//-----------------------------------------------------------------
// Write Protect
//-----------------------------------------------------------------
always @ (Wp_n) begin 
    // Original datasheet had Wp_n pin as a async-only pin
//    if (sync_mode == 0) begin
        status_register [7] = Wp_n;
        tm_wp_n <= $realtime;
         // holding Wp_low locks all block
        UnlockAddrLower = {ROW_BITS{1'b0}};
        UnlockAddrUpper = {ROW_BITS{1'b1}};
        LockInvert = 1;
        if (Wp_n === 1'b0) begin
            UnlockTightTimeLow = $time;
        end else begin
            UnlockTightTimeHigh = $time; 
`ifdef KEEP_LOCKTIGHT_AFTER_WPN
`else
            // some devices do not allow exiting lock-tight when Wp_n is held low
            // for 100ns
            if ((UnlockTightTimeHigh-UnlockTightTimeLow > 100) && FEATURE_SET[CMD_LOCK]) begin
                $sformat (msg, "INFO: LOCK TIGHT disabled - Wp_n low > 100ns");
                INFO(msg);
                LOCKTIGHT = 1'b0;
            end // UnlockTightTimeHigh
`endif
        end //Wp_n === 1'b0
//    end // sync_mode
end 

//-----------------------------------------------------------------
// Address input
//-----------------------------------------------------------------

// Set active plane and lock/unlock address range once address is valid
// Also do checks here to ensure we are not violating block boundaries or addressing rules
always @ (posedge row_valid) begin
    if (FEATURE_SET[CMD_2PLANE] | FEATURE_SET[CMD_MP]) begin
        //multi-die status read should not affect which plane is active
        if (~cmnd_78h) begin
            active_plane = new_addr[PAGE_BITS + (NUM_PLANES >> 2) : PAGE_BITS];
            if (lastCmd == 8'h06) begin
                //if this is just a select cache register command, don't change the saved page address
                //  even if the 8'h06-8'hE0 command inputs a different page address.  This will keep 
                //  multi-plane sequential cache reads working properly.
                row_addr[active_plane] = {new_addr[ROW_BITS-1:PAGE_BITS],row_addr[active_plane][PAGE_BITS-1:0]};
            end else begin
                row_addr[active_plane] = new_addr[ROW_BITS -1 : 0];
            end
        end
    end else begin
        //single plane address assignment
        if (~cmnd_78h) row_addr[active_plane] = new_addr[ROW_BITS -1 : 0];
    end
    if (lastCmd === 8'h23) begin
        UnlockAddrLower = {row_addr[active_plane][ROW_BITS-1:PAGE_BITS],{PAGE_BITS{1'b0}}}; // remove page bits
        if (DEBUG[2]) begin $sformat (msg, "UnlockAddrLower = %0h", UnlockAddrLower); INFO(msg); end
    end
    if (lastCmd === 8'h24) begin
        UnlockAddrUpper = {row_addr[active_plane][ROW_BITS-1:PAGE_BITS],{PAGE_BITS{1'b0}}}; // remove page bits
        LockInvert = row_addr[active_plane][0];
        if (DEBUG[2]) begin $sformat (msg, "UnlockAddrUpper=%0h  LockInvert=%0h", UnlockAddrUpper, LockInvert); INFO(msg); end
    end
    if (lastCmd === 8'h8C) begin
        copyback2_addr = new_addr[ROW_BITS -1 : 0];  //address will be used in copyback2 operation
    end
end


//address state enable is same for both sync and async mode
assign address_enable = (~Cle && Ale && ~Ce_n && Re_n);
// Address Latch
always @ (posedge We_n) begin
    if (address_enable) begin : latch_address
        if (saw_cmnd_00h) begin
            //need to distinguish between a status->00h read mode and a regular 00h->address->30h read page op
/*
            if (saw_cmnd_00h_stat)
                clear_queued_planes;  // ??? need to eval multiplane queues.  (latch address 00h)
            saw_cmnd_00h_stat = 1'b0;
*/
            saw_cmnd_00h = 1'b0;
            lastCmd = 8'h00;
            col_valid = 1'b0;
            row_valid = 1'b0;
            addr_start = 1;
            addr_stop = ADDR_BYTES;
        end
        we_adl_active <= 1'b0;
        tm_we_ale_r <= $realtime;

        // latch special read_id address (for devices that support ONFI or read_id)
        if ((addr_start === 1'b1) && (addr_stop === 1'b0)) begin : special_address
            id_reg_addr [7:0] = Io [7 : 0];
            col_counter = 0;
            //special case for read ONFI params (ECh with 00h address cycle)
            if ((ONFI_read === 1'b1) && (id_reg_addr === 8'h00)) begin
                col_valid  = 1'b1;
                col_addr = 0;
                new_addr = 0;
                row_valid  = 1'b1;
                load_cache_register(0,0);
            end else if ((do_read_unique === 1'b1) && (id_reg_addr === 8'h00)) begin
                $sformat(msg, "Manufacturer's Unique ID not defined in this behavioral model.  Will use 128'h0.");
                INFO(msg);
                col_valid = 1'b1;
                load_cache_register(0,0); 
                
                //now check for get_features address
            end else if (lastCmd === 8'hEE) begin
                case (check_feat_addr(id_reg_addr,nand_mode[0]))
                    0 : begin
                        $sformat(msg, "INVALID ONFI GET FEATURES ADDRESS 0x%2h.", id_reg_addr);  ERROR(ERR_ADDR, msg);
                    end
                endcase
                go_busy(tWB_delay);
                Rb_n_int <= 1'b0;
                status_register[6:5]=2'b00;
                go_busy(tFEAT);
                status_register[6:5]<=2'b11;
                Rb_n_int <=1'b1;
            //now check for set_features address
            end else if (lastCmd === 8'hEF) begin
                case (check_feat_addr(id_reg_addr,nand_mode[0]))
                    0 : begin
                        $sformat(msg, "INVALID ONFI SET FEATURES ADDRESS 0x%2h.", id_reg_addr);  ERROR(ERR_ADDR, msg);
                    end
                endcase
            end // set_features 
        end else begin
            ONFI_read = 1'b0;
            do_read_unique = 1'b0;
        end //special address

        // Latch Column
        if ((addr_start <= COL_BYTES) && (addr_start <= addr_stop) && ~col_valid  && ~col_addr_dis && ~nand_mode[0]) begin : latch_col_addr
            //ONFI read stays valid until another valid command and address are issued
            ONFI_read = 1'b0;
            case (addr_start)
                1 : begin
                        temp_col_addr [7 : 0] = Io [7 : 0];
                        if ((sync_mode) && (temp_col_addr[0] !== 1'b0) && ((lastCmd != 8'hEE) && die_select)) begin
                            $sformat(msg, "LSB of column address must be 0 in sync mode.  lastCmd=%2h", lastCmd);
                            ERROR(ERR_ADDR, msg);
                        end
                    end                
                2 : begin 
                        temp_col_addr [COL_BITS - 1 : 8] = Io [(COL_BITS -8 - 1) : 0];
                        if(lastCmd ==8'h05) begin
                            if(die_select) 
                                col_addr = temp_col_addr;
                            else
                                temp_col_addr = col_addr;
                        end
                        if(lastCmd ==8'h85 | cmnd_85h) begin
                            if(die_select) begin
                                col_addr_dup = col_addr;
                                col_addr = temp_col_addr;
                            end else begin
                                temp_col_addr = col_addr;
                            end
                        end 
                    end 
            endcase
            if (addr_start >= 2) begin
                col_valid = 1'b1;
            end
        end // latch_col_addr

        // Latch Row
        if ((addr_start >= (COL_BYTES +1)) && (addr_start <= addr_stop) && ~nand_mode[0]) begin : latch_row_addr
            case (addr_start)
                3 : begin
                    if(lastCmd ==8'h85 | cmnd_85h) begin
                        col_addr = col_addr_dup;  // col_addr will be set with complete address phases.  
                    end 
                    row_addr_last[active_plane] = new_addr[ROW_BITS -1 : 0];
                    row_valid     = 1'b0; //once we receive the 3rd cycle of addresses, the row address is no longer valid
                    new_addr [ 7 : 0] = Io [7 : 0];
                end
                4 : begin
                    new_addr [15 : 8] = Io [7 : 0];
                    if (ROW_BITS == 17) begin
                        LA[0] = Io [7];
                    end
                end
                5 : begin
                    new_addr [(ROW_BITS -1):16] = Io [(ROW_BITS -1 -16):0];
                    if (~row_valid) begin
                        case (LUN_BITS)
                        2       : begin
                                    LA[1] = Io [(ROW_BITS -1) -16];
                                    LA[0] = Io [(ROW_BITS -2) -16]; 
                                  end 
                        1       : begin 
                                    LA[1] = 1'b0;
                                    LA[0] = Io [(ROW_BITS -1) -16]; 
                                  end
                        default : begin 
                                    LA[1] = 1'b0;
                                    LA[0] = 1'b0;
                                  end 
                        endcase 
                        if (DEBUG[1]) begin $sformat(msg, "Lun Addr0 %d  : Lun Addr1 %d", LA[0], LA[1]); INFO(msg); end
                    end
                    //here we determine if this die model is the active device based
                    // on the row address
                    if ((NUM_DIE / NUM_CE) == 4) begin
                        if ( LA[1:0] == thisDieNumber[1:0]) begin
                            die_select = 1'b1;
                            if (DEBUG[1]) begin $sformat(msg, "DIE %d ACTIVE", thisDieNumber); INFO(msg); end
                            if (saw_cmnd_00h_stat) begin 
                                clear_queued_planes;  // ??? need to eval multiplane queues.  (latch address 00h)
                                saw_cmnd_00h_stat = 1'b0;
                            end
                            col_addr = temp_col_addr;  // wait to assign col addr until die_select has been determined.  
                            if (saw_cmnd_60h) begin 
                                if(saw_cmnd_60h_clear) begin 
                                    clear_queued_planes;
                                    saw_cmnd_60h_clear = 1'b0;
                                end 
                                saw_cmnd_60h = 1'b0;
                                lastCmd = 8'h60;
                            end
                        end else begin
                            die_select = 1'b0;
                            if (DEBUG[1]) begin $sformat(msg, "DIE %d INACTIVE", thisDieNumber); INFO(msg); end
                            temp_col_addr = col_addr;
                            if (saw_cmnd_60h) begin 
                                saw_cmnd_60h_clear = 1'b0;
                                saw_cmnd_60h = 1'b0;
                            end
                        end
                    end else if ((NUM_DIE / NUM_CE) == 2) begin
                        if ( LA[0] == thisDieNumber[0]) begin
                            die_select = 1'b1;
                            if (DEBUG[1]) begin $sformat(msg, "DIE %d ACTIVE", thisDieNumber); INFO(msg); end
                            if (saw_cmnd_00h_stat) begin 
                                clear_queued_planes;  // ??? need to eval multiplane queues.  (latch address 00h)
                                saw_cmnd_00h_stat = 1'b0;
                            end
                            col_addr = temp_col_addr;  // wait to assign col addr until die_select has been determined.  
                            if (saw_cmnd_60h) begin 
                                if(saw_cmnd_60h_clear) begin 
                                    clear_queued_planes;
                                    saw_cmnd_60h_clear = 1'b0;
                                end 
                                lastCmd = 8'h60;
                            end
                        end else begin
                            die_select = 1'b0;
                            if (DEBUG[1]) begin $sformat(msg, "DIE %d INACTIVE", thisDieNumber); INFO(msg); end
                            temp_col_addr = col_addr;
                            if (saw_cmnd_60h) begin 
                                saw_cmnd_60h_clear = 1'b0;
                                saw_cmnd_60h = 1'b0;
                            end
                        end
                    end else begin
                        die_select = 1'b1;
                        if (DEBUG[1]) begin $sformat(msg, "DIE %d ACTIVE", thisDieNumber); INFO(msg); end
                        if (saw_cmnd_00h_stat) begin 
                            clear_queued_planes;  // ??? need to eval multiplane queues.  (latch address 00h)
                            saw_cmnd_00h_stat = 1'b0;
                        end
                        col_addr = temp_col_addr;  // wait to assign col addr until die_select has been determined.  
                        if (saw_cmnd_60h) begin 
                            if(saw_cmnd_60h_clear) begin 
                                clear_queued_planes;
                                saw_cmnd_60h_clear = 1'b0;
                            end 
                            lastCmd = 8'h60;
                        end
                    end
                    if(new_addr[PAGE_BITS-1:0] > NUM_PAGE) begin
                        $sformat(msg, "Error: Page Limit Exceeded.  Page=%2h Page Limit=%2h", new_addr[PAGE_BITS-1:0], NUM_PAGE);
                        ERROR(ERR_ADDR, msg);
                    end 

                    if(die_select & (new_addr[BLCK_BITS-1+PAGE_BITS:PAGE_BITS] > NUM_BLCK)) begin
                        $sformat(msg, "Block Limit Exceeded.  Block=%2h Block Limit=%2h", new_addr[BLCK_BITS-1+PAGE_BITS:PAGE_BITS], NUM_BLCK);
                        ERROR(ERR_ADDR, msg);
                    end 
                end
            endcase
            if (DEBUG[0]) begin 
                $sformat (msg, "Latch Address (%0h) = %0h", addr_start, Io [7 : 0]);
                INFO(msg);
            end
            //make sure interleaved ops don't allow the inactive die to continue when
            // the address is out of it's range
            if ((addr_start >= ADDR_BYTES) & die_select) begin
                row_valid = 1'b1;
            end
        end // latch_row_addr

        // Increase Address Counter
        addr_start = addr_start + 1;

    end // latch_address
end

//-----------------------------------------------------------------
// Command input
//-----------------------------------------------------------------

//command state enable is same for both sync and async modes
assign command_enable = (Cle & ~Ale & ~Ce_n & Re_n);

always @ (posedge We_n) begin : cLatch
    if (command_enable) begin : Cle_enable
        //Make sure reset was first command issued after powerup for devices that require it
        `ifdef SO
        if (~ResetComplete & FEATURE_SET[CMD_ONFI] & ((Io[7:0] != 8'hFF) & (Io[7:0] != 8'hFC)) ) begin : reset_check
        `else
        if (~ResetComplete & FEATURE_SET[CMD_ONFI] & (Io[7:0] != 8'hFF) ) begin : reset_check
        `endif
            if (nand_mode[0]) begin
                $sformat(msg, "This device must receive reset command before any operations are allowed.");
                ERROR(ERR_CMD, msg);
            end else begin
            $sformat(msg, "This device must receive reset command before any operations are allowed.");
            ERROR(ERR_CMD, msg);
            end
        end    

        if (Rb_n_int === 1'b1) begin : cLatch_unbusy

            if (DEBUG[3]) begin $sformat(msg, "Command Latched = %2Hh", Io[7:0]); INFO(msg); end

            // *******************************
            // Command (00h) : PAGE READ START
            // *******************************
            if (Io [7 : 0] === 8'h00) begin : cmnd_00h
                abort_en = 1'b0;
                cmnd_85h = 1'b0;
                saw_cmnd_60h = 1'b0;
                saw_cmnd_60h_clear = 1'b0;
                if(~nand_mode[0] & ~(lastCmd === 8'h31) & status_register[6] & ~status_register[5]) begin $sformat(msg, "ERROR: Read Operation while array busy"); INFO(msg); end   // ??? verify for all models
                if(~nand_mode[0] & ~(cmnd_78h | cmnd_70h)) begin
                    //if not in status mode, then this is the start of a read command
                    if ((lastCmd == 8'h00) & row_valid & FEATURE_SET[CMD_2PLANE]) begin
                        if (DEBUG[1]) begin $sformat(msg, "TWO PLANE Latch Second 00h Command"); INFO(msg); end
                        multiplane_op_rd    = 1'b1;
                        multiplane_op_wr    = 1'b0;
                        multiplane_op_erase = 1'b0;
                        queued_plane[active_plane] = 1;
                        if(DEBUG[4]) begin $sformat(msg, "INFO: Page Read Start Set queued plane %0d. Value %0d", active_plane, queued_plane[active_plane]); INFO(msg); end 
                    end else if (~(multiplane_op_rd | cache_op)) begin
                        //as long as this isn't a multi-plane read or cache read or multi-LUN read, clear the plane queue
                        saw_cmnd_00h = 1'b1;
                        saw_cmnd_00h_stat = 1'b1;
//                        clear_queued_planes;
                    end                    
                    
                    lastCmd = 8'h00;
                    disable_rdStatus;
                    saw_cmnd_00h = 1'b1;
                    addr_start = 1;
                    addr_stop = ADDR_BYTES;
                end                 
                else if (~(lastCmd === 8'h00) & (cmnd_70h || cmnd_78h)) begin
                    //don't set cmnd_00h high, as we are just returning to read mode from status mode
                    saw_cmnd_00h = 1'b1;
                    saw_cmnd_00h_stat = 1'b1;
                    disable_rdStatus;
                end

                if(~nand_mode[0]) begin
                    cache_op <= 1'b0;
                    disable_md_stat = 1'b0;
                end 
            end //cmnd_00h

            // ***************************************
            // Command (05h) : RANDOM DATA READ START/CHANGE READ COLUMN
            // ***************************************
            else if (Io [7 : 0] === 8'h05) begin 
                
                cmnd_85h = 1'b0;
                saw_cmnd_60h = 1'b0;
                saw_cmnd_60h_clear = 1'b0;
                // Some devices disable random read during cache mode
                if ((saw_cmnd_00h || (lastCmd === 8'h30) || (lastCmd === 8'h35) || (lastCmd === 8'h3F) || (lastCmd === 8'hE0) || cache_op) && row_valid) begin
                    saw_cmnd_00h = 1'b0;
                    saw_cmnd_00h_stat = 1'b0;
                    lastCmd = 8'h05;
                    disable_rdStatus;
                    col_valid = 1'b0;
                    addr_start = 1;
                    addr_stop = COL_BYTES;
                end 
                abort_en = 1'b0;
            end

            // ***********************************************
            // Command (06h) : MULTI-PLANE RANDOM DATA READ START/SELECT CACHE REGISTER
            // ***********************************************
            else if ((Io [7 : 0] === 8'h06) & (FEATURE_SET[CMD_2PLANE] | FEATURE_SET[CMD_MP])) begin
                cmnd_85h = 1'b0;
                saw_cmnd_00h = 1'b0;  // clear because E0 is used to qualify 05 command read mode.
                saw_cmnd_00h_stat = 1'b0;
                saw_cmnd_60h = 1'b0;
                saw_cmnd_60h_clear = 1'b0;
                abort_en = 1'b0;
                // Command ([06h] -> E0h)
                lastCmd = 8'h06;
                disable_rdStatus;
                col_valid = 1'b0;
                row_valid = 1'b0;
                addr_start = 1;
                addr_stop = ADDR_BYTES;
            end
        
            // ***************************************
            // Command (10h) : PROGRAM PAGE CONFIRM
            // ***************************************
            else if ((Io [7 : 0] === 8'h10) && die_select) begin
                cmnd_85h = 1'b0;
                datain_index = 0;
                saw_cmnd_00h = 1'b0;
                saw_cmnd_00h_stat = 1'b0;
                saw_cmnd_60h = 1'b0;
                saw_cmnd_60h_clear = 1'b0;
                if ((cache_op === 1) && ~nand_mode[0]) begin
                    cache_prog_last = 1'b1;
                end
                if ((row_valid && ~nand_mode[0]) 
                   ) begin
                    queued_plane[active_plane] = 1;
                    if(DEBUG[4]) begin $sformat(msg, "INFO: Program Page Set queued plane %0d. Value %0d", active_plane, queued_plane[active_plane]); INFO(msg); end 
                    //program_page
                    if (((lastCmd === 8'hA5) && ~nand_mode[0]) 
                       ) begin
                        //8'hA5 -> OTP DATA PROTECT.  No programming, but there is busy time.
                        lastCmd = 8'h10;
                        if (~nand_mode[0]) OTP_locked = 1'b1;

                        #tWB_delay;
                        Rb_n_int = 1'b0;
                        status_register [6] = 1'b0;

                        if(~nand_mode[0]) begin 
                            status_register [5] = 1'b0;  
                            go_busy(tPROG_typ); 
                        end 
                        Rb_n_int <= 1'b1;   // not busy anymore
                        status_register [6] = 1'b1;
                        if(~nand_mode[0]) status_register [5] = 1'b1;
                    end else begin
                        if(~nand_mode[0]) begin
                            lastCmd = 8'h10;
                            copyback2 = 0;
                            program_page(multiplane_op_wr,cache_op);
                        end
                    end
                // SMK : ADD ERRORS for bad address or command here
                end
                // SMK : ADD ERRORS for bad address or command here

                multiplane_op_wr    = 1'b0;
                multiplane_op_rd    = 1'b0;
                multiplane_op_erase = 1'b0;
                cache_op <= 1'b0;
            end
    
            // ********************************************************
            // Command (11h) : MULTI-PLANE PROGRAM PAGE, 1st PLANE CONFIRM
            // ********************************************************
            else if ((Io [7 : 0] === 8'h11) & (FEATURE_SET[CMD_2PLANE] | FEATURE_SET[CMD_MP])) begin 

                cmnd_85h = 1'b0;
                saw_cmnd_00h = 1'b0;
                saw_cmnd_00h_stat = 1'b0;
                saw_cmnd_60h = 1'b0;
                saw_cmnd_60h_clear = 1'b0;
                abort_en = 1'b0;
                if (((lastCmd === 8'h80) || (lastCmd === 8'h85) || (lastCmd === 8'h8C)) && row_valid) begin
                    queued_plane[active_plane] = 1;
                    if(DEBUG[4]) begin $sformat(msg, "INFO: Multi-Plane Program Page Set queued plane %0d. Value %0d", active_plane, queued_plane[active_plane]); INFO(msg); end 
                    multiplane_op_wr = FEATURE_SET[CMD_MP] | FEATURE_SET[CMD_2PLANE];
                    multiplane_op_rd = 1'b0;
                    multiplane_op_erase = 1'b0;
                    lastCmd = 8'h11;
                    //can't actually write to mem_array yet because final program command not seen
                    //busy time required to switch planes
                    #tWB_delay;
                    Rb_n_int = 1'b0;
                    status_register[6:5] = 2'b00;
                    go_busy(tDBSY_min);
                    status_register[6:5] = 2'b11;
                    Rb_n_int <= 1'b1;
                end 
            end
    
            // ********************************************************
            // Command (15h) : PROGRAM PAGE CACHE MODE CONFIRM
            // ********************************************************
            else if ((Io [7 : 0] === 8'h15) && die_select) begin
                cmnd_85h = 1'b0;
                abort_en = 1'b0;
                saw_cmnd_00h = 1'b0;
                saw_cmnd_00h_stat = 1'b0;
                saw_cmnd_60h = 1'b0;
                saw_cmnd_60h_clear = 1'b0;
                if (boot_block_lock_mode) begin
                    $sformat(msg, "Error: Program Page Cache Mode Command %0h not allowed in boot block lock mode.", Io[7:0]); ERROR(ERR_CMD, msg); 
                end
                    
                if (((lastCmd === 8'h80) || (lastCmd === 8'h8C)) && row_valid) begin
                    queued_plane[active_plane] = 1;
                    if(DEBUG[4]) begin $sformat(msg, "INFO: Program Page Cache Set queued plane %0d. Value %0d", active_plane, queued_plane[active_plane]); INFO(msg); end 
                    lastCmd = 8'h15;
                    cache_op <= 1'b1;
                    if(FEATURE_SET[CMD_2PLANE])
                        program_page (multiplane_op_wr, 1'b1);  // 2-Plane ops
                    else begin 
                        program_page (1'b0, 1'b1);  // need to revisit mp ???
                        multiplane_op_rd    = 1'b0;
                        multiplane_op_erase = 1'b0;
                        multiplane_op_wr    = 1'b0;
                    end 
                    
                    //copyback2 program cache 8Ch->15h
                    copyback2 = 0;
                end
            end

            // ********************************************************
            // Command (23h) : BLOCK UNLOCK START
            // ********************************************************
            else if ((Io [7 : 0] === 8'h23) && Wp_n && FEATURE_SET[CMD_LOCK]) begin
                cmnd_85h = 1'b0;
                abort_en = 1'b0;
                saw_cmnd_00h = 1'b0;
                saw_cmnd_00h_stat = 1'b0;
                saw_cmnd_60h = 1'b0;
                saw_cmnd_60h_clear = 1'b0;
                if (ALLOWLOCKCOMMAND && ~LOCKTIGHT) begin
                    clear_queued_planes;
                    lastCmd = 8'h23;
                    disable_rdStatus;
                    row_valid = 1'b0;
                    col_valid = 1'b0;
                    addr_start = COL_BYTES +1;
                    addr_stop = ADDR_BYTES;                     
                    cache_op <= 1'b0;
                    disable_md_stat = 1'b0;
                end else begin
                    $sformat(msg, "Command 23h - IGNORED - Lock commands are disabled");
                    WARN(msg);
                end
                if(FEATURE_SET[CMD_MP] & die_select) multiplane_op_rd    = 1'b0;
            end
    
            // ********************************************************
            // Command (24h) : BLOCK UNLOCK CONFIRM
            // ********************************************************
            else if ((Io [7 : 0] === 8'h24) && FEATURE_SET[CMD_LOCK]) begin
                cmnd_85h = 1'b0;
                abort_en = 1'b0;
                saw_cmnd_00h = 1'b0;
                saw_cmnd_00h_stat = 1'b0;
                saw_cmnd_60h = 1'b0;
                saw_cmnd_60h_clear = 1'b0;
                if (ALLOWLOCKCOMMAND && ~LOCKTIGHT) begin
                    if (row_valid) begin
                        lastCmd = 8'h24;
                        row_valid = 1'b0;
                        col_valid = 1'b0;
                        addr_start = COL_BYTES +1;
                        addr_stop = ADDR_BYTES;
                        LOCK_DEVICE = 1'b0;
                        status_register[7] = 1'b1;    
                    end
                end else begin
                    $sformat(msg, "Command 24h - IGNORED - Lock commands are disabled");
                    WARN(msg);
                end
                if(FEATURE_SET[CMD_MP] & die_select) multiplane_op_rd    = 1'b0;
            end
       
            // ********************************************************
            // Command (2Ah) : BLOCK LOCK
            // ********************************************************
            else if ((Io [7 : 0] === 8'h2A) && FEATURE_SET[CMD_LOCK]) begin
                cmnd_85h = 1'b0;
                abort_en = 1'b0;
                saw_cmnd_00h = 1'b0;
                saw_cmnd_00h_stat = 1'b0;
                saw_cmnd_60h = 1'b0;
                saw_cmnd_60h_clear = 1'b0;
                if (ALLOWLOCKCOMMAND && ~LOCKTIGHT) begin
                    clear_queued_planes;
                    lastCmd = 8'h2A;
                    disable_rdStatus;
                    UnlockAddrLower = {ROW_BITS{1'b0}};
                    UnlockAddrUpper = {ROW_BITS{1'b1}};
                    LockInvert = 1'b1;
                    status_register[7] = 1'b0;
                    LOCK_DEVICE = 1'b1;       
                    cache_op <= 1'b0;
                    disable_md_stat = 1'b0;
                end else begin
                       $sformat(msg, "Command 2Ah - IGNORED - Lock commands are disabled");
                       WARN(msg);
                end
                if(FEATURE_SET[CMD_MP] & die_select) multiplane_op_rd    = 1'b0;
            end
       
            // ********************************************************
            // Command (2Ch) : BLOCK LOCK TIGHT
            // ********************************************************
            else if ((Io [7 : 0] === 8'h2C) && FEATURE_SET[CMD_LOCK]) begin
                cmnd_85h = 1'b0;
                abort_en = 1'b0;
                saw_cmnd_00h = 1'b0;
                saw_cmnd_00h_stat = 1'b0;
                saw_cmnd_60h = 1'b0;
                saw_cmnd_60h_clear = 1'b0;
                if (ALLOWLOCKCOMMAND && ~LOCKTIGHT) begin
                    lastCmd = 8'h2C;
                    disable_rdStatus;
                    LOCKTIGHT = 1'b1;
                    LOCK_DEVICE = 1'b0;
                    status_register[7] = 1'b1;        
                    cache_op <= 1'b0;
                    disable_md_stat = 1'b0;
                end else begin
                    $sformat(msg, "Command 2Ch - IGNORED - Lock commands are disabled");
                    WARN(msg);
                end
                if(FEATURE_SET[CMD_MP] & die_select) multiplane_op_rd    = 1'b0;
            end
        
            // ********************************************************
            // Command (30h) : PAGE READ CONFIRM
            // ********************************************************
            else if (Io [7 : 0] === 8'h30) begin
                cmnd_85h = 1'b0;
                abort_en = 1'b0;
                saw_cmnd_00h = 1'b0;
                saw_cmnd_00h_stat = 1'b0;
                saw_cmnd_60h = 1'b0;
                saw_cmnd_60h_clear = 1'b0;
                if (~nand_mode[0]) begin 
                    if (OTP_mode) begin //OTP_mode
                        OTP_read = 1'b1;
                        disable_md_stat = 1'b1;
                        disable_rdStatus;
                        lastCmd = 8'h30;
                        col_counter = 0;
                        sub_col_cnt = sub_col_cnt_init;  // reset sub col count
                        load_cache_register (0, 0);
                        cache_valid = 1'b0;
                    end //OTP_mode
                    else if ((lastCmd === 8'h00) && row_valid && ~saw_cmnd_65h) begin //page_read
                        lastCmd = 8'h30;
                        col_counter = 0;
                        sub_col_cnt = sub_col_cnt_init;  // reset sub col count
                        queued_plane[active_plane] = 1;
                        copy_queued_planes;
                        if(DEBUG[4]) begin $sformat(msg, "INFO: Page Read Confirm Set queued plane %0d. Value %0d", active_plane,queued_plane[active_plane]); INFO(msg); end 
//                        load_cache_register (multiplane_op_rd, 0);
                        load_cache_en = ~ load_cache_en;
                        // pre-ONFI 2.0 : for 2plane ops, pulsing Re_n after 2plane page read should output from Plane 0 first
                        // ONFI 2.0 : last plane addressed in a multiplane operation becomes active read plane
/*  
                        if (multiplane_op_rd) begin
                            active_plane = 0;
                        end
                        multiplane_op_rd    = 1'b0;
                        multiplane_op_wr    = 1'b0;
                        multiplane_op_erase = 1'b0;
                        cache_valid = 1'b0;
*/
                    end  //page_read
                    else if ((lastCmd === 8'hAF) && row_valid) begin //OTP_read
                        lastCmd = 8'h30;
                        col_counter = 0;
                        sub_col_cnt = sub_col_cnt_init;  // reset sub col count
                        load_cache_register (0, 0);
                        cache_valid = 1'b0;
                    end //OTP_read
                    else if ((lastCmd === 8'h00) && row_valid && saw_cmnd_65h && (thisDieNumber == 3'b000)) begin //special_ID
                    //These are the special read unique and read id2 commands 
                    //(only supported on first die in a multi-die package)
                        lastCmd = 8'h30;
                        //pre-ONFI way of accessing READ UNIQUE ID and READ ID2
                        if (col_addr == 512) begin  // hex 200 (LSB of second Column Address = 02h)
                            if (FEATURE_SET[CMD_ID2]) begin
                                do_read_id_2 = 1'b1;
`ifdef x8
                                    col_counter = 512;  // Byte 512 for x8
`else
                                    col_counter = 256;  // Byte 512 for x16
`endif
                                load_cache_register(0,0); 
                            end else begin
                                $sformat(msg, "READ ID2 Command is not supported by this device.");
                                ERROR(ERR_CMD, msg);
                            end
                        end else if (col_addr == 0) begin
                            if (FEATURE_SET[CMD_UNIQUE]) begin
                                $sformat(msg, "Manufacturer's Unique ID not yet defined for this model.  Will use 128'h0.");
                                INFO(msg);
                                do_read_unique = 1'b1;
                                col_counter = 0;
                                load_cache_register(0,0); 
                            end else begin
                                $sformat(msg, "READ UNIQUE Command is not supported by this device.");
                                ERROR(ERR_CMD, msg);
                            end
                        end else begin
                            $sformat(msg, "Invalid col_addr when attemping read_id_2 or read_unique, col_addr=%0hh", col_addr);
                            ERROR(ERR_ADDR, msg);
                        end
                        saw_cmnd_65h = 1'b0; 
                    end //special_ID
                end 
            end

            // ********************************************************
            // Command (31h) : PAGE READ CACHE MODE
            // ********************************************************
            else if (Io [7 : 0] === 8'h31) begin

                cmnd_85h = 1'b0;
                saw_cmnd_00h = 1'b0;  // clear because cache_op is used to qualify 05 command read mode.
                // support either seq cache (30h->31h->3Fh) or ONFI random cache page (30h->00h->address->31h->3Fh)
                //   31h only valid after 30h or 31h, or can we insert a rand
                saw_cmnd_00h_stat = 1'b0;
                saw_cmnd_60h = 1'b0;
                saw_cmnd_60h_clear = 1'b0;
                if (row_valid && FEATURE_SET[CMD_NEW] && die_select && ~nand_mode[0]) begin
                    // Reset Column Address
                    col_addr = 0;
                    col_counter = 0;
                    sub_col_cnt = sub_col_cnt_init;  // reset sub col count
                    cache_op <= 1'b1;
                    //If sequential page read cache mode, use same queued planes as for read page for cached read
                    if ((lastCmd === 8'h00) && FEATURE_SET[CMD_ONFI]) begin
                        queued_plane[active_plane] = 1'b1;
                        copy_queued_planes;
                        if(DEBUG[4]) begin $sformat(msg, "INFO: Page Read Cache Set queued plane %0d Value %0d", active_plane, queued_plane[active_plane]); INFO(msg); end 
                    end else begin
                        row_addr[active_plane] = {row_addr[active_plane][(ROW_BITS -1) : (PAGE_BITS)], (row_addr[active_plane] [(PAGE_BITS -1) : 0] + 1'b1)};
                        if (row_addr[active_plane][PAGE_BITS-1:0] === {(PAGE_BITS){1'b0}}) begin
                            $sformat(msg, "CACHED PAGE READ cannot cross block boundaries. Block=%0h   Page=%0h ", row_addr[active_plane][ROW_BITS-1:PAGE_BITS], (row_addr[active_plane][PAGE_BITS-1:0] -1'b1));
                            ERROR(ERR_CACHE, msg);
                        end
                    end
                    lastCmd = 8'h31;
                    disable_rdStatus;
                    load_cache_register (0, 1);  // Load cache
                    if (NUM_PLANES==2 & (
                        (rd_pg_cache_seqtl & multiplane_op_rd_cache) | (~rd_pg_cache_seqtl & multiplane_op_rd)) ) begin
                       active_plane <= 0;
                    end
                    cache_valid = 1'b1;
                    abort_en = 1'b0;
                    rd_pg_cache_seqtl = 1'b0;
                end //row_valid
                if(FEATURE_SET[CMD_NEW] && die_select && ~nand_mode[0]) begin multiplane_op_rd = 1'b0; multiplane_op_erase = 1'b0; multiplane_op_wr = 1'b0; end 
            end
    
            
            // ********************************************************
            // Command (35h) : COPYBACK READ CONFIRM
            // ********************************************************
            else if ((Io [7 : 0] === 8'h35) && die_select) begin

                cmnd_85h = 1'b0;
                saw_cmnd_00h = 1'b0;
                saw_cmnd_00h_stat = 1'b0;
                saw_cmnd_60h = 1'b0;
                saw_cmnd_60h_clear = 1'b0;
                abort_en = 1'b0;
                if (row_valid) begin
                    lastCmd = 8'h35;
                    //col_counter must be set to 0 so designs supporting Re# pulses after h35 work correctly
                    col_counter = 0;
                    copyback = 1'b1;
                    queued_plane[active_plane] = 1;
                    if(DEBUG[4]) begin $sformat(msg, "INFO: Copyback Read Set queued plane %0d. Value %0d", active_plane, queued_plane[active_plane]); INFO(msg); end 
                    load_cache_register (multiplane_op_rd, cache_op);

                    //pre-ONFI 2.0 : for 2plane ops, pulsing Re_n after 2plane page read should
                    // output from Plane 0 first
                    // ONFI 2.0 : last plane addressed in a multiplane operation becomes active read plane
                    if (multiplane_op_rd) begin
                        active_plane = 0;
                    end
                end
                multiplane_op_rd    = 1'b0;
                multiplane_op_wr    = 1'b0;
                multiplane_op_erase = 1'b0;
                cache_op = 1'b0;
                copyback = 1'b0;
            end
    
            // ********************************************************
            // Command (3Fh) : PAGE READ CACHE MODE LAST
            // ********************************************************
            else if ((Io [7 : 0] === 8'h3F) && FEATURE_SET[CMD_NEW]) begin
                cmnd_85h = 1'b0;
                abort_en = 1'b0;
                saw_cmnd_00h = 1'b0;
                saw_cmnd_00h_stat = 1'b0;
                saw_cmnd_60h = 1'b0;
                saw_cmnd_60h_clear = 1'b0;

                if ((lastCmd !== 8'h3F) && row_valid) begin
                    lastCmd = 8'h3F;
                    disable_rdStatus;
                    // Reset Column Address
                    col_addr = 0;
                    col_counter = 0;
                    sub_col_cnt = sub_col_cnt_init;  // reset sub col count

                    if(FEATURE_SET[CMD_MPRDWC]) rd_pg_cache_seqtl = 1'b1;
                    load_cache_register (0, 1); 
                    
                    if (NUM_PLANES==2 & (
                        (rd_pg_cache_seqtl & multiplane_op_rd_cache) | (~rd_pg_cache_seqtl & multiplane_op_rd)) ) begin
                       active_plane = 0;
                    end
                    rd_pg_cache_seqtl = 1'b0;

                    cache_valid = 1'b1;
                    cache_op <= 0;
                    clear_queued_planes;
                    
                    // MP not supported with cache mode.  
                    multiplane_op_rd    = 1'b0;
                    multiplane_op_wr    = 1'b0;
                    multiplane_op_erase = 1'b0;
                    copy_queued_planes;  // clears MP queued planes and multi-plane op rd cache flag.
                end else if ((lastCmd === 8'h3F) && row_valid) begin
                    $sformat(msg, "Illegal use of 3Fh command.");
                    ERROR(ERR_CMD, msg);
                end
            end
    
            // ********************************************************
            // Command (60h) : BLOCK ERASE START
            // ********************************************************
            else if (Io [7 : 0] === 8'h60) begin
                cmnd_85h = 1'b0;
                abort_en = 1'b0;
                saw_cmnd_00h = 1'b0;
                saw_cmnd_00h_stat = 1'b0;

                if (~Wp_n) begin
                    $sformat(msg, "Wp_n = 0,  ERASE operation disabled.");
                    WARN(msg);
                end else if (OTP_mode) begin
                    $sformat(msg, "Device in OTP mode.  ERASE operation disabled.");
                    WARN(msg);
                end else begin 
                    if (((lastCmd === 8'h60) || (lastCmd === 8'hD1)) && row_valid && FEATURE_SET[CMD_2PLANE]) begin
                        //2nd half of 2-plane erase
                        multiplane_op_erase = 1'b1;
                        multiplane_op_rd = 1'b0;
                        multiplane_op_wr = 1'b0;
                        if (lastCmd === 8'h60) begin 
                            queued_plane[active_plane] = 1;  
                            if(DEBUG[4]) begin $sformat(msg, "INFO: Block Erase Set queued plane %0d. Value %0d", active_plane,queued_plane[active_plane]); INFO(msg); end 
                        end
                        lastCmd = 8'h60;
                    end else if (~multiplane_op_erase) begin
                        saw_cmnd_60h = 1'b1;
                        saw_cmnd_60h_clear = 1'b1;
//                        clear_queued_planes;  // only clear if to this die
                    end else begin
                        saw_cmnd_60h = 1'b1;
                        saw_cmnd_60h_clear = 1'b0;
                    end 
//                    lastCmd = 8'h60;
                    disable_rdStatus;
                    row_valid = 1'b0;
                    addr_start = COL_BYTES +1;
                    addr_stop = ADDR_BYTES;
                end       
                cache_op <= 1'b0;
                disable_md_stat = 1'b0;
            end
    
            // ********************************************************
            // Command (65h) : READ ID/UNIQUE (pre-ONFI implementation)
            //   30h->65h->00h->address->30h
            // ********************************************************
            else if ((Io [7 : 0] === 8'h65) && (FEATURE_SET[CMD_ID2] || FEATURE_SET[CMD_UNIQUE])) begin

                cmnd_85h = 1'b0;
                saw_cmnd_00h = 1'b0;
                saw_cmnd_00h_stat = 1'b0;
                saw_cmnd_60h = 1'b0;
                saw_cmnd_60h_clear = 1'b0;
                abort_en = 1'b0;
                if (lastCmd == 8'h30) begin
                    lastCmd = 8'h65;
                    saw_cmnd_65h = 1'b1;
                end
            end

            // ********************************************************
            // Command (70h) : READ STATUS
            // ********************************************************
            else if ((Io [7 : 0] === 8'h70) && die_select) begin
            // SMK : ADD nand mode[0] SUPPORT HERE

                saw_cmnd_00h = 1'b0;
                saw_cmnd_00h_stat = 1'b0;
                saw_cmnd_60h = 1'b0;
                saw_cmnd_60h_clear = 1'b0;
                // Status
                cmnd_70h = 1'b1;
                cmnd_78h = 1'b0;
            end
    
            // ********************************************************
            // Command (78h) : MULTI-PLANE READ STATUS
            // ********************************************************
            else if (Io [7 : 0] === 8'h78) begin

                saw_cmnd_00h = 1'b0;
                saw_cmnd_00h_stat = 1'b0;
                saw_cmnd_60h = 1'b0;
                saw_cmnd_60h_clear = 1'b0;
                // Status
                if (disable_md_stat) begin
                    //some operations make this command illegal
                    $sformat(msg, "MULTI-DIE STATUS READ (78h) IS PROHIBITED DURING AND AFTER POWER-UP RESET, OTP OPERATIONS, READ PARAMETERS, READ ID, READ UNIQUE ID, and GET/SET FEATURES.");
                    ERROR(ERR_STATUS, msg);
                end else begin
                    cmnd_70h = 1'b0;
                    cmnd_78h = 1'b1;
                    lastCmd = 8'h78;
                    addr_start = COL_BYTES +1;
                    addr_stop = ADDR_BYTES;
                    row_valid = 1'b0;
                end
            end
    
            // ********************************************************
            // Command (7Ah) : BLOCK LOCK READ STATUS
            // ********************************************************
            else if ((Io [7 : 0] === 8'h7A) && (die_select) && FEATURE_SET[CMD_LOCK]) begin

                cmnd_85h = 1'b0;
                saw_cmnd_00h = 1'b0;
                saw_cmnd_00h_stat = 1'b0;
                saw_cmnd_60h = 1'b0;
                saw_cmnd_60h_clear = 1'b0;
                   // Status
                lastCmd = 8'h7A;
                disable_rdStatus;
                addr_start = COL_BYTES +1;
                addr_stop = ADDR_BYTES;
                row_valid = 1'b0;
            end

            // ********************************************************
            // Command (80h) : PROGRAM PAGE START
            // ********************************************************
            else if (Io [7 : 0] === 8'h80) begin

                cmnd_85h = 1'b0;
                saw_cmnd_00h = 1'b0;
                saw_cmnd_00h_stat = 1'b0;
                saw_cmnd_60h = 1'b0;
                saw_cmnd_60h_clear = 1'b0;
                abort_en = 1'b0;
                if (~Wp_n) begin //Write-protect
                    $sformat(msg, "Wp_n = 0,  PROGRAM operation disabled.");
                    WARN(msg);
                end else begin //end write protect ; else start program
                    lastCmd = 8'h80;
                    disable_rdStatus;
                    col_valid = 1'b0;
                    row_valid = 1'b0;
                    addr_start = 1'b1;
                    addr_stop = ADDR_BYTES;
                    col_counter = 0;
                    sub_col_cnt = sub_col_cnt_init;  // reset sub col count
                    if (OTP_mode) begin
                        OTP_write = 1'b1;
                        disable_md_stat = 1'b1;
                        disable_rdStatus;
                    end else begin
                        //Initial 80h command clears registers of all devices.
                        //If this is 2nd half of multiplane op, don't want to clear registers.
                        if (~multiplane_op_wr) begin
                            for (pl_cnt=0;pl_cnt<NUM_PLANES;pl_cnt=pl_cnt+1) begin //plane_loop
                                clear_cache_register(pl_cnt);
                                clear_queued_planes;
                            end //plane_loop
                        end //multiplane op write
                        multiplane_op_rd    = 1'b0;  // prog page clears all cache registers on a selected target, not just lun
                        multiplane_op_erase = 1'b0;
                    end //OTP_mode if:else
                end //program
                disable_md_stat = 1'b0;
            end
        
            // ************************************************************
            // Command (85h) : COPYBACK PROGRAM START or RANDOM DATA INPUT
            // ************************************************************
            else if (Io [7 : 0] === 8'h85) begin

                cmnd_85h = 1'b0;
                saw_cmnd_00h = 1'b0;
                saw_cmnd_00h_stat = 1'b0;
                saw_cmnd_60h = 1'b0;
                saw_cmnd_60h_clear = 1'b0;
                abort_en = 1'b0;
                if (row_valid) begin
                    if ((lastCmd === 8'h11) && FEATURE_SET[CMD_ONFI]) begin
                    //ONFI devices support 85h-11h-85h-10h for internal data move
                        queued_plane[active_plane] = 1;
                        if(DEBUG[4]) begin $sformat(msg, "INFO: Cmd 85h Set queued plane %0d. Value %0d", active_plane, queued_plane[active_plane]); INFO(msg); end 
                        col_valid = 1'b0;
                        row_valid = 1'b0;
                        lastCmd = 8'h85;
                        disable_rdStatus;
                        addr_start = 1;
                        addr_stop = ADDR_BYTES;
                        col_counter = 0;
                        sub_col_cnt = sub_col_cnt_init;  // reset sub col count
                        disable_md_stat = 1'b0;
                    end
                    //if address is already valid, then this is a random data input
                    else if ((lastCmd === 8'h85) | (lastCmd === 8'h80) | (lastCmd === 8'hA0) | (lastCmd === 8'h8C)) begin  
                        col_valid = 1'b0;
                        // Don't clear row address and row valid status here even if this is a 5-cycle 
                        // address input for ONFI 2.0 devices.
                        // At the very least we will require 2 address cycles, up to 5.  If only 2, then row address
                        // will remain the same
                        col_counter = 0;
                        sub_col_cnt = sub_col_cnt_init;  // reset sub col count
                        //do net set lastCmd here since this is just random data input and not the start of a command
                        addr_start = 1;
                        addr_stop = ADDR_BYTES;
                        cmnd_85h = 1'b1;
                    end
                    else begin //end row_valid (random data input) ; else start copyback
                    //else this is the first 85h for internal data move (not random data input)
                      if (~Wp_n) begin
                        $sformat(msg, "Wp_n = 0,  PROGRAM operation disabled.");
                        WARN(msg);
                      end else begin
                        //if this is the first of a multi-LUN copyback operation, clear the plane queue
//                        if (~multiplane_op) begin
//                            clear_queued_planes;  // ??? (command latch 85h), later specs donot allow this to clear.
//                        end
                        col_valid = 1'b0;
                        row_valid = 1'b0;
                        lastCmd = 8'h85;
                        disable_rdStatus;
                        addr_start = 1;
                        addr_stop = ADDR_BYTES;
                        col_counter = 0;
                        sub_col_cnt = sub_col_cnt_init;  // reset sub col count
                        disable_md_stat = 1'b0;
                      end
                    end

                    if(FEATURE_SET[CMD_MP]) multiplane_op_rd    = 1'b0;
                end //end copyback          
            end
    


            // ********************************************************
            // Command (90h) : READ ID
            // Only 1 LUN returns data, to avoid collisions
            // ********************************************************
            else if (Io [7 : 0] === 8'h90 & id_cmd_lun) begin
                cmnd_85h = 1'b0;
                saw_cmnd_00h = 1'b0;
                saw_cmnd_00h_stat = 1'b0;
                saw_cmnd_60h = 1'b0;
                saw_cmnd_60h_clear = 1'b0;
                abort_en = 1'b0;
                clear_queued_planes;  // ??? (command latch 90h)
                lastCmd = 8'h90;
                disable_rdStatus;
                col_valid = 1'b0;
                row_valid = 1'b0;
                addr_start = 1;
                addr_stop = 0;
                col_counter = 0;
                cache_op <= 1'b0;
                disable_md_stat = 1'b0;
                ONFI_read = 1'b0;
                if(FEATURE_SET[CMD_MP]) multiplane_op_rd    = 1'b0;
            end
    
            // ********************************************************
            // Command (A0h) : OTP DATA PROGRAM START
            // ********************************************************
            else if ((Io [7 : 0] === 8'hA0) && FEATURE_SET[CMD_OTP]) begin

                cmnd_85h = 1'b0;
                saw_cmnd_00h = 1'b0;
                saw_cmnd_00h_stat = 1'b0;
                saw_cmnd_60h = 1'b0;
                saw_cmnd_60h_clear = 1'b0;
                abort_en = 1'b0;
                // Command (A0)
                clear_queued_planes;  // ??? (command latch a0h)
                OTP_write = 1'b1;
                disable_md_stat = 1'b1;
                lastCmd = 8'hA0;
                disable_rdStatus;
                col_valid = 1'b0;
                row_valid = 1'b0;
                addr_start = 1'b1;
                addr_stop = ADDR_BYTES;
                col_counter = 0;
            end
     
            // ********************************************************
            // Command (A5h) : OTP DATA PROTECT 
            // ********************************************************
            else if ((Io [7 : 0] === 8'hA5) && FEATURE_SET[CMD_OTP]) begin

                cmnd_85h = 1'b0;
                saw_cmnd_00h = 1'b0;
                saw_cmnd_00h_stat = 1'b0;
                saw_cmnd_60h = 1'b0;
                saw_cmnd_60h_clear = 1'b0;
                abort_en = 1'b0;
                // Command (A5)
                clear_queued_planes; // ??? (command latch a5h)
                lastCmd = 8'hA5;
                disable_rdStatus;
                col_valid = 1'b0;
                row_valid = 1'b0;
                addr_start = 1'b1;
                addr_stop = ADDR_BYTES;
                col_counter = 0;
                if (DEBUG[3]) begin $sformat(msg, "OTP Protect"); INFO(msg); end
            end

            // ********************************************************
            // Command (AFh) : OTP DATA READ START 
            // ********************************************************
            else if ((Io [7 : 0] === 8'hAF) && FEATURE_SET[CMD_OTP]) begin

                cmnd_85h = 1'b0;
                saw_cmnd_00h = 1'b0;
                saw_cmnd_00h_stat = 1'b0;
                saw_cmnd_60h = 1'b0;
                saw_cmnd_60h_clear = 1'b0;
                abort_en = 1'b0;
                clear_queued_planes; // ??? (command latch afh)
                OTP_read = 1'b1;
                disable_md_stat = 1'b1;
                lastCmd = 8'hAF;
                disable_rdStatus;
                col_valid = 1'b0;
                row_valid = 1'b0;
                addr_start = 1;
                addr_stop = ADDR_BYTES;
            end
 
            // ********************************************************
            // Command (B8h) : PROGRAMMABLE IO DRIVESTRENGTH
            // ********************************************************
            else if ((Io [7 : 0] === 8'hB8) & FEATURE_SET[CMD_DRVSTR]) begin

                cmnd_85h = 1'b0;
                saw_cmnd_00h = 1'b0;
                saw_cmnd_00h_stat = 1'b0;
                saw_cmnd_60h = 1'b0;
                saw_cmnd_60h_clear = 1'b0;
                abort_en = 1'b0;
                clear_queued_planes; // ??? (command latch b8h)
                lastCmd = 8'hB8;
                disable_rdStatus;
                cache_op <= 1'b0;
                disable_md_stat = 1'b0;
            end
    
            // ********************************************************
            // Command (D0h) : BLOCK ERASE CONFIRM
            // ********************************************************
            else if (Io [7 : 0] === 8'hD0) begin

                cmnd_85h = 1'b0;
                saw_cmnd_00h = 1'b0;
                saw_cmnd_00h_stat = 1'b0;
                saw_cmnd_60h = 1'b0;
                saw_cmnd_60h_clear = 1'b0;
                abort_en = 1'b0;
                if ((lastCmd === 8'h60) && row_valid && Wp_n) begin
                    lastCmd = 8'hD0;
                    queued_plane[active_plane] = 1;
                    if(DEBUG[4]) begin $sformat(msg, "INFO: Block Erase Confirm Set queued plane %0d. Value %0d", active_plane, queued_plane[active_plane]); INFO(msg); end 
//                    erase_block;                    
                    erase_blk_en = ~ erase_blk_en;
//                    multiplane_op_erase = 1'b0;
//                    multiplane_op_rd    = 1'b0;
//                    multiplane_op_wr    = 1'b0;
//                    cache_op <= 1'b0;
                end
            end

            // ********************************************************
            // Command (D1h) : MULTI-PLANE BLOCK ERASE CONFIRM
            // ********************************************************
            else if ((Io[7:0] === 8'hD1) & FEATURE_SET[CMD_ONFI] & (FEATURE_SET[CMD_2PLANE] | FEATURE_SET[CMD_MP])) begin

                cmnd_85h = 1'b0;
                saw_cmnd_00h = 1'b0;
                saw_cmnd_00h_stat = 1'b0;
                saw_cmnd_60h = 1'b0;
                saw_cmnd_60h_clear = 1'b0;
                abort_en = 1'b0;
                if ((lastCmd === 8'h60) && row_valid) begin
                    queued_plane[active_plane] = 1;
                    if(DEBUG[4]) begin $sformat(msg, "INFO: Multi-Plane Block Erase Set queued plane %0d. Value %0d", active_plane, queued_plane[active_plane]); INFO(msg); end 
                    lastCmd = 8'hD1;
                    multiplane_op_erase = 1'b1;
                    multiplane_op_rd    = 1'b0;
                    multiplane_op_wr    = 1'b0;
                    go_busy(tWB_delay);
                    Rb_n_int = 1'b0;
                    status_register[6:5]=2'b00;
                    go_busy(tDBSY_min);
                    status_register[6:5]<=2'b11;
                    Rb_n_int <=1'b1;
                end
            end
    
            // ********************************************************
            // Command (E0h) : RANDOM DATA READ CONFIRM, CHANGE READ COLUMN/SELECT CACHE REGISTER CONFIRM
            // ********************************************************
            else if (Io [7 : 0] === 8'hE0) begin

                cmnd_85h = 1'b0;
                saw_cmnd_00h = 1'b0;
                saw_cmnd_00h_stat = 1'b0;
                saw_cmnd_60h = 1'b0;
                saw_cmnd_60h_clear = 1'b0;
                abort_en = 1'b0;
                if ((lastCmd === 8'h06) && row_valid) begin
                    lastCmd = 8'hE0;
                    col_counter = 0;
                    sub_col_cnt = sub_col_cnt_init;  // reset sub col count
                    cache_valid = 1'b0;                    
                end 
                else if ((lastCmd === 8'h05) && col_valid) begin
                    lastCmd = 8'hE0;
                    col_counter = 0;
                    sub_col_cnt = sub_col_cnt_init;  // reset sub col count
                end
            end

            // ********************************************************
            // Command (ECh) : ONFI READ PARAMETER PAGE
            // Only 1 LUN returns data, to avoid collisions
            // ********************************************************
            else if ((Io [7 : 0] === 8'hEC) & FEATURE_SET[CMD_ONFI] & id_cmd_lun) begin
            // SMK : ADD nand mode[0] SUPPORT HERE

                cmnd_85h = 1'b0;
                saw_cmnd_00h = 1'b0;
                saw_cmnd_00h_stat = 1'b0;
                saw_cmnd_60h = 1'b0;
                saw_cmnd_60h_clear = 1'b0;
                abort_en = 1'b0;
                clear_queued_planes;
                lastCmd = 8'hEC;
                disable_rdStatus;
                ONFI_read = 1'b1;  // enables Read Parameter_Page Command
                col_valid = 1'b0;
                row_valid = 1'b0;
                addr_start = 1;
                addr_stop = 0;
                col_counter = 0;
                disable_md_stat = 1'b1;
                if(FEATURE_SET[CMD_MP]) multiplane_op_rd    = 1'b0;
            end

            // ********************************************************
            // Command (EDh) : ONFI READ UNIQUE ID
            // Only 1 LUN returns data, to avoid collisions
            // ********************************************************
            else if ((Io[7:0] === 8'hED) & FEATURE_SET[CMD_UNIQUE] & FEATURE_SET[CMD_ONFI] & id_cmd_lun) begin
                
            // SMK : ADD nand mode[0] SUPPORT HERE

                cmnd_85h = 1'b0;
                saw_cmnd_00h = 1'b0;
                saw_cmnd_00h_stat = 1'b0;
                saw_cmnd_60h = 1'b0;
                saw_cmnd_60h_clear = 1'b0;
                abort_en = 1'b0;
                clear_queued_planes;
                lastCmd = 8'hED;
                disable_md_stat = 1'b1;
                do_read_unique  = 1'b1;  // enables Read_Unique_ID Command
                col_valid  = 1'b0;
                addr_start = 1;
                addr_stop  = 0;
                if(FEATURE_SET[CMD_MP]) multiplane_op_rd    = 1'b0;
            end

            // ********************************************************
            // Command (EEh) : GET FEATURES
            // Only 1 LUN returns data, to avoid collisions
            // ********************************************************
            else if ((Io [7 : 0] === 8'hEE) & FEATURE_SET[CMD_FEATURES] & id_cmd_lun) begin
            // SMK : ADD nand mode[0] SUPPORT HERE

                cmnd_85h = 1'b0;
                saw_cmnd_00h = 1'b0;
                saw_cmnd_00h_stat = 1'b0;
                saw_cmnd_60h = 1'b0;
                saw_cmnd_60h_clear = 1'b0;
                abort_en = 1'b0;
                clear_queued_planes;
                disable_md_stat = 1'b1;
                lastCmd = 8'hEE;
                disable_rdStatus;
                col_valid = 1'b0;
                row_valid = 1'b0;
                addr_start = 1;
                addr_stop = 0;
                col_counter = 0;
                if(FEATURE_SET[CMD_MP]) multiplane_op_rd    = 1'b0;
            end

            // ********************************************************
            // Command (EFh) : SET FEATURES
            // ********************************************************
            else if ((Io [7 : 0] === 8'hEF) && FEATURE_SET[CMD_FEATURES]) begin

                cmnd_85h = 1'b0;
                saw_cmnd_00h = 1'b0;
                saw_cmnd_00h_stat = 1'b0;
                saw_cmnd_60h = 1'b0;
                saw_cmnd_60h_clear = 1'b0;
                abort_en = 1'b0;
                clear_queued_planes;
                disable_md_stat = 1'b1;
                lastCmd <= 8'hEF;
                disable_rdStatus;
                col_valid = 1'b0;
                row_valid = 1'b0;
                addr_start = 1;
                addr_stop = 0;
                col_counter = 0;
                if(FEATURE_SET[CMD_MP]) multiplane_op_rd    = 1'b0;
            end
                                    
            // ********************************************************
            // Command (FCh) : SYNCHRONOUS RESET
            // ********************************************************
            else if (Io [7 : 0] === 8'hFC) begin
                cmnd_85h = 1'b0;
                saw_cmnd_00h = 1'b0;
                saw_cmnd_00h_stat = 1'b0;
                saw_cmnd_60h = 1'b0;
                saw_cmnd_60h_clear = 1'b0;
                abort_en = 1'b0;
                //set lastCmd register 
                if (sync_mode) begin
                    lastCmd = 8'hFC;
                    if (~ResetComplete)
                        nand_reset (1'b0);
                    else
                        nand_reset (1'b1);
                end else begin
                    $sformat(msg,"Illegal synchronous reset command.  Device is not in synchronous operation.");
                    ERROR(ERR_CMD, msg);
                end
            end

            // ********************************************************
            // Command (FFh) : RESET
            // ********************************************************
            else if (Io [7 : 0] === 8'hFF) begin
            // SMK : ADD nand mode[0] SUPPORT HERE
                //set lastCmd register 
                cmnd_85h = 1'b0;
                saw_cmnd_00h = 1'b0;
                saw_cmnd_00h_stat = 1'b0;
                saw_cmnd_60h = 1'b0;
                saw_cmnd_60h_clear = 1'b0;
                abort_en = 1'b0;
                lastCmd = 8'hFF;
                if (nand_mode[0]) reset_cmd = 1;
                if (~ResetComplete) begin
                    nand_reset (1'b0);
                end else begin
                    nand_reset (1'b1);
                end
            end
            // ********************************************************
            // Command (??h) : UNSUPPORTED COMMAND
            // ********************************************************
            else if (die_select) begin
                $sformat(msg, "Unsupported command = %00h", Io[7:0]);
                ERROR(ERR_CMD, msg);
            end
        end //  cLatch_unbusy
        
        //-----------------------------------------------
        //------Command input during busy ---------------
        //-----------------------------------------------
        else if (Rb_n_int === 1'b0) begin 
            //else we are busy and only certain commands are allowed
            
            // even when busy we need to do status and reset
            if (DEBUG[3]) begin
                $sformat(msg, "Attempting to latch command %0h while busy ...", Io); 
                INFO(msg);
            end

            // ********************************************************
            // Command (70h) : READ STATUS (DURING BUSY)
            // ********************************************************
            if ((Io [7 : 0] === 8'h70) && (die_select)) begin
            // SMK : ADD nand mode[0] SUPPORT HERE
                saw_cmnd_00h = 1'b0;
                saw_cmnd_00h_stat = 1'b0;
                if (DEBUG[3]) begin $sformat (msg, "Command Latched = %2hh", Io[7:0]); INFO(msg); end
                // Status
                cmnd_70h = 1'b1;
                cmnd_78h = 1'b0;
            end

            // ********************************************************
            // Command (78h) : MULTI-PLANE READ STATUS (DURING BUSY)
            // ********************************************************
            else if (~nand_mode[0] && (Io [7 : 0] === 8'h78)) begin
                saw_cmnd_00h = 1'b0;
                saw_cmnd_00h_stat = 1'b0;
                if (DEBUG[3]) begin $sformat(msg, "Command Latched = %2hh", Io[7:0]); INFO(msg); end
                // Status
                cmnd_78h = 1'b1;
                cmnd_70h = 1'b0;
                addr_start = COL_BYTES +1;
                addr_stop = ADDR_BYTES;
                row_valid = 1'b0;
            end

            // ********************************************************
            // Command (FCh) : SYNCHRONOUS RESET
            // ********************************************************
            else if (~nand_mode[0] && (Io [7 : 0] === 8'hFC)) begin
                //set lastCmd register
                cmnd_85h = 1'b0;
                saw_cmnd_00h = 1'b0;
                saw_cmnd_00h_stat = 1'b0;
                // ??? saw_cmd_60 support 
                abort_en = 1'b0;
                if (sync_mode) begin
                    lastCmd = 8'hFC;
                    nand_reset (1'b1);
                end else begin
                    $sformat(msg,"Illegal synchronous reset command.  Device is not in synchronous operation.");
                    ERROR(ERR_CMD, msg);
                end
            end

            // ********************************************************
            // Command (FFh) : RESET (DURING BUSY)
            // ********************************************************
            else if (Io [7 : 0] === 8'hFF) begin
                cmnd_85h = 1'b0;
                saw_cmnd_00h = 1'b0;
                saw_cmnd_00h_stat = 1'b0;
                abort_en = 1'b0;
                if (DEBUG[3]) begin $sformat(msg, "Command Latched = %2hh", Io[7:0]); INFO(msg); end
                lastCmd = 8'hFF;
                nand_reset (1'b1);
            end            
            else begin
             // else this is a non-status command during busy.
             // since this could be an interleaved die operation, tell this device
             //  to look at the upcoming address cycles to de-select the die if needed
                if(die_select) begin
                col_valid = 1'b0;
                row_valid = 1'b0;
                addr_start = 1;
                addr_stop = ADDR_BYTES;
            end
            end
        end // : cLatch_unbusy/busy_command
    end // : Cle_enable
end    // : cLatch

//-----------------------------------------------------------------
// Column Address Disable
//-----------------------------------------------------------------
always @ (posedge Clk_We_n) begin : ColAddrDisBlk
    if (Cle && ~Ale && ~Ce_n && Wr_Re_n && Io [7 : 0] === 8'h60)
        col_addr_dis <= 1'b1;  
    else if(Cle && ~Ale && ~Ce_n && Wr_Re_n && (Io [7 : 0] === 8'hD1 || Io [7 : 0] === 8'hD0))
        col_addr_dis <= 1'b0;  
    else if(Cle && ~Ale && ~Ce_n && Wr_Re_n && col_addr_dis && ~(Io [7 : 0] === 8'hD1 || Io [7 : 0] === 8'hD0)) begin
        col_addr_dis <= 1'b0;  
        $sformat(msg, "Error: Erase Block command terminated unexpectedly.");
        end
end

//-----------------------------------------------------------------
// Data input
//-----------------------------------------------------------------



//async mode data input
assign datain_async = ~Cle & ~Ale & ~Ce_n & Re_n & Rb_n_int & ~sync_mode;
always @(posedge We_n) begin
    if (datain_async)
    begin : latch_data_async
        //only async mode needs these two variables set for tADL calculation
        if (die_select && ~sync_mode) begin
            we_adl_active <= 1'b1;
            tm_we_data_r <= $realtime;
        end
        if (lastCmd === 8'hEF) begin   // wp_N no effect
        //also need to recognize here that the SET FEATURES command will apply to all LUNs per chip-enable
            //Only allowed for ONFI devices
            case (col_counter)
                0:  begin
                        if((id_reg_addr == 8'h80) & DRIVESTR_EN[1]) 
                            onfi_features[8'h10][7:0]       = Io;  // for backwards compatability feature address 80h =10h
                        else                     
                            onfi_features[id_reg_addr][7:0] = Io;
                    end  //P1
                1:  begin
                        if ((id_reg_addr == 8'h60) || (id_reg_addr == 8'h92)) begin
                            onfi_features[id_reg_addr][15:8] = Io;
                        end else begin
                            onfi_features[id_reg_addr][15:8]  = 8'h00;
                        end
                    end  //P2
                2:  begin
                        // This is the only feature address that uses sub-parameter bytes 2 and 3
                        if (id_reg_addr == 8'h92) begin
                            onfi_features[id_reg_addr][23:16] = Io;
                        end else begin
                            onfi_features[id_reg_addr][23:16]  = 8'h00;
                        end
                    end  //P3
                3:  begin
                        // This is the only feature address that uses sub-parameter bytes 2 and 3
                        if (id_reg_addr == 8'h92) begin
                            onfi_features[id_reg_addr][31:24] = Io;
                        end else begin
                            onfi_features[id_reg_addr][31:24]  = 8'h00;
                        end
                        //now we store the data
                        go_busy(tWB_delay);
                        Rb_n_int = 1'b0;
                        status_register[6:5]=2'b00;
                        go_busy(tFEAT);
                        //now update the design based on the input features parameters
                        update_features(id_reg_addr);
                        status_register[6:5]<=2'b11;
                        Rb_n_int <=1'b1;
                    end  //P4
            endcase
            col_counter = col_counter + 1;
        end

        // non-nand mode[0] data input
        else if (die_select & ~nand_mode[0] & Wp_n & col_valid & row_valid) begin
            if((col_addr + col_counter) <= (NUM_COL - 1))  begin
                if (DEBUG[2]) begin
                    $sformat (msg, "Latch Data (%0h : %0h : %0h + %0h) = %0h",
                        row_addr[active_plane][(ROW_BITS-1):(PAGE_BITS)], row_addr[active_plane][(PAGE_BITS-1):0], col_addr, col_counter, Io);
                    INFO(msg);
                end
                // creates window of 1s, DQ BITS wide starting at the column address which I/O data will go in cache reg
                bit_mask = ({DQ_BITS{1'b1}} << ((((col_counter+col_addr)*BPC_MAX)+sub_col_cnt)*DQ_BITS)); // shifting left zero-fills
                 //mask clears cache reg entry so can or in I/O data
                cache_reg[active_plane] = (cache_reg[active_plane] & ~bit_mask) | ( Io << ((((col_counter+col_addr)*BPC_MAX)+sub_col_cnt)*DQ_BITS));

                `ifdef PACK
                    case (active_plane)
                    0 : cache_reg_packed0 [col_addr + col_counter] = Io;
                    1 : cache_reg_packed1 [col_addr + col_counter] = Io;
                    2 : cache_reg_packed2 [col_addr + col_counter] = Io;
                    3 : cache_reg_packed3 [col_addr + col_counter] = Io;
                    endcase             
                `endif
                col_counter = fn_inc_col_counter(col_counter, MLC_SLC, BPC, sub_col_cnt);
                sub_col_cnt = fn_sub_col_cnt(sub_col_cnt, MLC_SLC, BPC, sub_col_cnt_init) ;
            end else begin
                $sformat (msg, "Error Data Input Overflow block=%0h : page=%0h : column=%0h : column limit=%0h ",
                    row_addr[active_plane][(ROW_BITS-1):(PAGE_BITS)], row_addr[active_plane][(PAGE_BITS-1):0], (col_addr+col_counter), (NUM_COL - 1));  ERROR(ERR_ADDR,msg);
            end
        end else if (die_select & lastCmd === 8'hB8) begin   // wp_N no effect ???
            DriveStrength = (Io & 8'b00001100);
        end
    end // latch_data_async
end


always @(MLC_SLC)
begin
    sub_col_cnt_init =  {2{ 1'b0  }} ;

    sub_col_cnt = 0;  // reset sub col count
end

//-----------------------------------------------------------------
// Data output
//-----------------------------------------------------------------

assign data_out_enable_async = (~sync_mode && ~Cle && ~Ale && ~Ce_n && We_n && die_select);
always @ (negedge Re_n) begin
    //#############################
    // ASYNC MODE OUTPUT
    //#############################
    //Async Mode status output 
    if(data_out_enable_async && ((cmnd_70h === 1'b1) || (cmnd_78h === 1'b1))) begin
    // 70h only works on the last addressed die
        output_status;
    end else begin
    //only need to go here if not a status reg read
    if (die_select && ~sync_mode) begin : rd_die_select
        if (data_out_enable_async && (Rb_n_int === 1'b1)) begin : not_busy
            //Read ID2 and Read Unique take precedence.  Only way out is reset or power up/down
            //-----------------
            if (do_read_id_2) begin
                //-----------------
                //Read ID2
                //-----------------
                if (DEBUG[0]) begin $sformat(msg, "ReadID2 (%0d)", col_counter); INFO(msg); end
                    Io_buf <= #tREA_max special_array[col_counter];
                    rd_out <= #tREA_max 1'b1;

                    col_counter = col_counter + 1;

            end else if (do_read_unique) begin
                //-----------------
                //Read Unique
                //-----------------
                if (DEBUG[0]) begin $sformat(msg, "ReadUnique (%0h)=%h", col_counter, special_array[col_counter]); INFO(msg); end
                Io_buf <= #tREA_max special_array[col_counter];
                rd_out <= #tREA_max 1'b1;

                col_counter = col_counter + 1;
            end else if (lastCmd === 8'hEE) begin
                //-----------------
                //Read Features
                //-----------------
                case (col_counter)
                    0       : begin
                            if((id_reg_addr == 8'h80) & DRIVESTR_EN[1]) data = onfi_features[8'h10][07:00];
                            else                                        data = onfi_features[id_reg_addr][07:00];
                    end 
                    1       : data = onfi_features[id_reg_addr][15:08];
                    2       : data = onfi_features[id_reg_addr][23:16];
                    3       : data = onfi_features[id_reg_addr][31:24];
                    default : data = 8'h00;
                endcase

                if (tCEA_max - tREA_max < $realtime - tm_ce_n_f) begin
                    //negedge is far enough away from negedge Ce_n, use tREA
                    Io_buf <= #(tREA_max) data;
                    rd_out <= #(tREA_max) 1'b1;
                end else begin
                    //negedge Re_n close to negedge Ce_n, use tCEA
                    Io_buf <= #(tm_ce_n_f + tCEA_max - $realtime) data;
                    rd_out <= #(tm_ce_n_f + tCEA_max - $realtime) 1'b1;
                end
                col_counter = col_counter + 1;

            //-----------------
            // Normal Page Read
            //-----------------
            end else if (~nand_mode[0] && (lastCmd !== 8'h7A) && col_valid && row_valid && ((col_addr + col_counter) <= (NUM_COL - 1))) begin
                // Data Buffer
                // determine whether CE access time or RE access time dominates
                 if (cache_op === 1) begin
                // use cache mode timing
                    if (tCEA_cache_max - tREA_cache_max < $realtime - tm_ce_n_f) begin
                        //negedge is far enough away from negedge Ce_n, use tREA
                        if (DEBUG[2]) begin $sformat(msg, "Using tREA cache timing"); INFO(msg); end
                        Io_buf <= #(tREA_cache_max) cache_reg[active_plane] >> ((((col_counter+col_addr) * BPC_MAX) + sub_col_cnt) * DQ_BITS);
                        rd_out <= #(tREA_cache_max) 1'b1;
                    end else begin
                        //negedge Re_n close to negedge Ce_n, use tCEA
                        if (DEBUG[2]) begin $sformat(msg, "Using tCEA cache timing"); INFO(msg); end
                        Io_buf <= #(tm_ce_n_f + tCEA_cache_max - $realtime) cache_reg[active_plane] >> ((((col_counter+col_addr) * BPC_MAX) + sub_col_cnt) * DQ_BITS);
                        rd_out <= #(tm_ce_n_f + tCEA_cache_max - $realtime) 1'b1;
                    end
                end else begin
                    //regular read, no cache mode
                    if (tCEA_max - tREA_max < $realtime - tm_ce_n_f) begin
                        //negedge is far enough away from negedge Ce_n, use tREA
                        if (DEBUG[2]) begin $sformat(msg, "Using tREA timing"); INFO(msg); end
                        Io_buf <= #(tREA_max) cache_reg[active_plane] >> ((((col_counter+col_addr) * BPC_MAX) + sub_col_cnt) * DQ_BITS);
                        rd_out <= #(tREA_max) 1'b1;
                    end else begin
                        //negedge Re_n close to negedge Ce_n, use tCEA
                        if (DEBUG[2]) begin $sformat(msg, "Using tCEA timing"); INFO(msg); end
                        Io_buf <= #(tm_ce_n_f + tCEA_max - $realtime) cache_reg[active_plane] >> ((((col_counter+col_addr) * BPC_MAX) + sub_col_cnt) * DQ_BITS);
                        rd_out <= #(tm_ce_n_f + tCEA_max - $realtime) 1'b1;
                    end
                end
   
                if (DEBUG[2]) begin
                       $sformat(msg, "Data Read (%0h : %0h : %0h + %0h) = %0h",
                             row_addr[active_plane][(ROW_BITS-1):(PAGE_BITS)], row_addr[active_plane][(PAGE_BITS-1):0], col_addr, col_counter, cache_reg[active_plane] [col_addr + col_counter]);
                       INFO(msg);
                end
    
                col_counter = fn_inc_col_counter(col_counter, MLC_SLC, BPC, sub_col_cnt)  ;
                sub_col_cnt = fn_sub_col_cnt(sub_col_cnt, MLC_SLC, BPC, sub_col_cnt_init) ;


            //-----------------
            //some designs support reading out of cache register right after read for internal data move
            //-----------------
            end else if (~col_valid && ~row_valid && (lastCmd === 8'h35)) begin
                // use cache mode timing
                if (tCEA_cache_max - tREA_cache_max < $realtime - tm_ce_n_f) begin
                    //negedge is far enough away from negedge Ce_n, use tREA
                    if (DEBUG[2]) begin $sformat(msg, "Using tREA cache timing"); INFO(msg); end
                    Io_buf <= #(tREA_cache_max) cache_reg[active_plane] >> ((((col_counter+col_addr) * BPC_MAX) + sub_col_cnt) * DQ_BITS);
                    rd_out <= #(tREA_cache_max) 1'b1;
                end else begin
                    //negedge Re_n close to negedge Ce_n, use tCEA
                    if (DEBUG[2]) begin $sformat(msg, "Using tCEA cache timing"); INFO(msg); end
                    Io_buf <= #(tm_ce_n_f + tCEA_cache_max - $realtime) cache_reg[active_plane] >> ((((col_counter+col_addr) * BPC_MAX) + sub_col_cnt) * DQ_BITS);
                    rd_out <= #(tm_ce_n_f + tCEA_cache_max - $realtime) 1'b1;
                end
                col_counter = fn_inc_col_counter(col_counter, MLC_SLC, BPC, sub_col_cnt)  ;
                sub_col_cnt = fn_sub_col_cnt(sub_col_cnt, MLC_SLC, BPC, sub_col_cnt_init) ;

            //-----------------
            // extra case to drive data bus high z after column boundary is reached
            //-----------------
            end else if (~cmnd_70h && ~cmnd_78h && col_valid && row_valid && ((col_addr + col_counter) > (NUM_COL - 1))) begin                
                rd_out <= #(tREA_max) 1'b0;

            end else if (lastCmd === 8'h7A) begin
                //-----------------
                //Lock Status Read
                //-----------------
                if (DEBUG[0]) begin $sformat(msg, "BLOCK LOCK READ STATUS\n"); INFO(msg); end
                if (~ALLOWLOCKCOMMAND) begin
                    // device was not locked on startup, cannot be locked later
                    Io_buf <= #(tREA_max) 8'h06;
                    rd_out <= #(tREA_max) 1'b1;
                       if (DEBUG[0]) begin $sformat(msg, "Lock Status Read=%0hh at address  %0h", 8'h06, row_addr[active_plane][ROW_BITS-1:PAGE_BITS] ); INFO(msg); end
                end else begin
                    rd_out <= #(tREA_max) 1'b1;
                    if ((UnlockAddrLower <= row_addr[active_plane]) && (row_addr[active_plane] <= UnlockAddrUpper)) begin
                        Io_buf <= #(tREA_max) {{(DQ_BITS-3){1'b0}}, ~LockInvert, ~LOCKTIGHT, LOCKTIGHT};
                        if (DEBUG[0]) begin 
                            $sformat(msg, "Lock Status Read=%0hh at address  %0h", {{(DQ_BITS-3){1'b0}}, ~LockInvert, ~LOCKTIGHT, LOCKTIGHT}, row_addr[active_plane] ); 
                            INFO(msg); 
                        end
                    end else begin
                        Io_buf <= #(tREA_max) {{(DQ_BITS-3){1'b0}}, LockInvert, ~LOCKTIGHT, LOCKTIGHT};
                        if (DEBUG[0]) begin
                            $sformat(msg, "Lock Status Read=%0hh at address  %0h", {{(DQ_BITS-3){1'b0}}, LockInvert, ~LOCKTIGHT, LOCKTIGHT}, row_addr[active_plane] );
                            INFO(msg);
                        end
                    end
                end

            end else if (lastCmd === 8'hB8) begin
                //-----------------
                //Read DriveStrength
                //-----------------
                Io_buf <= #tREAIO_max DriveStrength;
                rd_out <= #tREAIO_max 1'b1;
                if (DEBUG[0]) begin $sformat(msg, "DriveStrength=%0h", DriveStrength); INFO(msg); end
                
            end else if (lastCmd === 8'h90) begin    
                if (id_reg_addr === 8'h00) begin : regular_id_read
                    //-----------------
                    //Read ID
                    //-----------------
                    // Reset Counter
                    if (col_counter > (NUM_ID_BYTES - 1)) begin
                        col_counter = 0;
                       end
                    case (col_counter)
                        0 : Io_buf <= #(tREA_max) READ_ID_BYTE0;
                        1 : Io_buf <= #(tREA_max) READ_ID_BYTE1;
                        2 : Io_buf <= #(tREA_max) READ_ID_BYTE2;
                        3 : Io_buf <= #(tREA_max) READ_ID_BYTE3;
                        4 : Io_buf <= #(tREA_max) READ_ID_BYTE4;
                    endcase
                    rd_out <= #(tREA_max) 1'b1;    
                    if (DEBUG[0]) begin $sformat(msg, "Read ID (%0h)", col_counter); INFO(msg); end

                    col_counter = col_counter + 1;

                end else if ((id_reg_addr === 8'h20) && (FEATURE_SET[CMD_ONFI])) begin : onfi_id_read
                    //-----------------
                    //Read ONFI ID
                    //-----------------
                       // Reset Counter
                    if (col_counter > 3) begin
                           $sformat(msg, "ONFI read beyond 4 bytes is indeterminate.");
                           ERROR(ERR_MISC, msg);
                           IoX_enable <= #(tREA_max) 1'b1;
                           rd_out <= #(tREA_max) 1'b0;
                    end
            
                    case (col_counter)
                        0 : begin
                            Io_buf <= #(tREA_max) 8'h4F; //'O'
                            rd_out <= #(tREA_max) 1'b1 ;
                        end
                        1 : begin
                            Io_buf <= #(tREA_max) 8'h4E; //'N'
                            rd_out <= #(tREA_max) 1'b1 ;
                        end
                        2 : begin
                            Io_buf <= #(tREA_max) 8'h46; //'F'
                            rd_out <= #(tREA_max) 1'b1 ;
                        end
                        3 : begin
                            Io_buf <= #(tREA_max) 8'h49; //'I'
                            rd_out <= #(tREA_max) 1'b1 ;
                        end
                    endcase
    
                    if (DEBUG[0]) begin $sformat(msg, "ONFI Read ID (%0h)", col_counter); INFO(msg); end

                       col_counter = col_counter + 1;
                end //onfi_id_read
            end else if (Pre) begin
                //----------------------
                //Power-On Preload read
                //----------------------
                //if none of the above is true, check for pre-load read on devices that support it
                rd_out <= #(tREA_max) 1'b1;
                Io_buf <= #(tREA_max) cache_reg[active_plane] >> ((((col_counter+col_addr) * BPC_MAX) + sub_col_cnt) * DQ_BITS);
                col_counter = fn_inc_col_counter(col_counter, MLC_SLC, BPC, sub_col_cnt)  ;
                sub_col_cnt = fn_sub_col_cnt(sub_col_cnt, MLC_SLC, BPC, sub_col_cnt_init) ;
            end else begin             
                //-----------------
                //No valid data 
                //-----------------
                // If we get here, bad read -- out of bounds or unknown
                rd_out <= #(tREA_max) 1'b0;
                $sformat(msg, "DATA NOT Transfered on Re_n");
                ERROR(ERR_MISC, msg);
            end
        end else begin  //not_busy block : else (if busy)
            //this will output zz's if Re_n is toggled during busy with a status command
            if (~(cmnd_70h || cmnd_78h))    rd_out <= #(tREA_max) 1'b0;

        end // : not_busy
    end end// : rd_die_select
end


//#####################################################
// Tri - stating the IO bus
//
//  This section control the tri-stating of the IO
//  bus based on when Re_n and Ce_n transition.
//#####################################################

//---------------------------
//  Re_n->IO transitions
//---------------------------

// disable IO output on posedge Re_n or Ce_n 
always @ (posedge Re_n) begin
    //posedge Re_n with Ce_n low
    if (data_out_enable_async && Re_n) begin
        //schedule these transitions
        IoX_enable <= #(tRHOH_min) 1'b1;
        IoX_enable <= #(tRHZ_max-1) 1'b1;
        IoX_enable <= #(tRHZ_max) 1'b0;
        rd_out <= #tRHOH_min 1'b0;     
        t_readtox = ($realtime + tRHOH_min);
        t_readtoz = ($realtime + tRHZ_max);
    end
end

`ifdef EDO
    always @ (negedge Re_n) begin
        //negedge Re_n in devices that support EDO read mode utilizes tRLOH_min
        if (data_out_enable_async && ~Re_n && edo_mode) begin
            if (($realtime + tRLOH_min) > (tm_re_n_r + tRHOH_min)) begin
                IoX <= #(tRLOH_min) 1'b1;
                IoX <= #(tRHZ_max) 1'b0;
                rd_out <= #(tRLOH_min) 1'b0;
                t_readtox = ($realtime + tRLOH_min);
                t_readtoz = ($realtime + tRHZ_max);
            end
        end
    end
`endif
  
//---------------------------
//  Ce_n->IO transitions
//---------------------------

// reschedule these transitions for special timing cases
always @ (posedge Ce_n) begin
if(~sync_mode) begin
    //----------------------------------
    //posedge Ce_n with Re_n already low 
    //----------------------------------
    // (if Ce_n->high and Re_n->low switch at same time, ignore this)
    if (~Cle && ~Ale && ~Re_n && We_n && (tm_re_n_f != $realtime) && (tm_re_n_f != 0)) begin
        if (DEBUG[2]) $display("tm_re_n_f=%0t, realtime=%0t, cen=%0d, ren=%0d", tm_re_n_f, $realtime, Ce_n, Re_n);
        //schedule these transitions
        IoX_enable  <= #(tCOH_min) 1'b1;
        if (cache_op) begin
            IoX_enable  <= #(tCHZ_cache_max) 1'b0;
            t_readtoz <= ($realtime + tCHZ_cache_max);
        end else begin
            IoX_enable  <= #(tCHZ_max) 1'b0;
            t_readtoz <= ($realtime + tCHZ_max);
        end
        t_readtox <= ($realtime + tCOH_min);
        rd_out <= #tCOH_min 1'b0;
    end else
    //----------------------------------
     //posedge Ce_n and posedge Re_n at same time
    //----------------------------------
    if (~Cle && ~Ale && Re_n && We_n && rd_out) begin
        if (tm_re_n_f > t_readtoz) begin
             //This can only happen when Ce_n and Re_n go high at the same time
             // therefore this part is needed since we can't say whether the posedge Re_n
             // always block or this code will be executed first.

            //last rising edge of Re_n is more than tRHZ_max away from this edge
            // therefore Ce timing dominates
            IoX_enable <= #(tCOH_min) 1'b1;
            if (cache_op) begin
                IoX_enable  <= #(tCHZ_cache_max) 1'b0;
                t_readtoz <= ($realtime + tCHZ_cache_max);
            end else begin
                IoX_enable  <= #(tCHZ_max) 1'b0;
                t_readtoz <= ($realtime + tCHZ_max);
            end
            rd_out <= #tCOH_min 1'b0;
            t_readtox <= ($realtime + tCOH_min);
        end else begin
          //else Re_n is high and the Re_n based Io transitions were already
          //scheduled.  So here we check to see whether Ce_n based Io transitions
          //are more critical than Re_n based transitions already scheduled during
          // this timestamp.
            if (($realtime + tCOH_min) < t_readtox) begin
                IoX_enable <= #(tCOH_min) 1'b1;
                rd_out <= #tCOH_min 1'b0;
                t_readtox <= $realtime + tCOH_min;
            end
            if (cache_op) begin
                if (($realtime + tCHZ_cache_max) < t_readtoz) begin
                    t_readtoz <= $realtime + tCHZ_cache_max;
                    IoX_enable <= #(tCHZ_cache_max) 1'b0; 
                end
            end else begin
                if (($realtime + tCHZ_max) < t_readtoz) begin
                    t_readtoz <= $realtime + tCHZ_max;
                    IoX_enable <= #(tCHZ_max) 1'b0; 
                end
            end
        end
    end else begin
        //default case for Ce_n going high during Io==X's, disable Io if not high-z
        if (Io_wire !== {DQ_BITS{1'bz}}) begin
            if (Io_wire === {DQ_BITS{1'bx}}) begin
                //if we are already x's, then there is the possibility that a scheduled data->x->z
                //from the last read is going to overwrite our scheduled Z's transition here.  So, we
                // add additional logic here to ensure the posedge of Ce_n result in the correct 
                // Io transitions at the right time

                //don't proceed if previous read is closer to tri-stating than tCHZ
                if ((tm_re_n_r + tRHZ_max) > ($realtime + tCHZ_max)) begin
                    //need this part to ensure that IoX_enable transitions from 1->0 so
                    // the always block below will catch it and disable X's
                    if (cache_op) begin
                        IoX_enable <= #(tCHZ_cache_max -1) 1'b1;
                    end else begin
                        IoX_enable <= #(tCHZ_max -1) 1'b1;
                    end
                    t_readtox <= $realtime; //doesn't matter what we set this to if we are already X's
                    //now schedule the X->Z transition
                    if (cache_op) begin
                        IoX_enable <= #(tCHZ_cache_max) 1'b0;
                        t_readtoz <= ($realtime + tCHZ_cache_max);
                    end else begin
                        IoX_enable <= #(tCHZ_max) 1'b0;
                        t_readtoz <= ($realtime + tCHZ_max);
                    end
                    rd_out <= 1'b0;  //output should already be disabled if x's
                end 
                
            end //Io_wire !== x's
        end //Io_wire !== z's
    end
end //sync_mode
end //posedge Ce_n



//enable X's on output
always @(posedge IoX_enable) begin
    if (t_readtox == $realtime) begin
        IoX <= 1'b1;
        rd_out <= 1'b0;
    end
end

//disable X's on output
always @(negedge IoX_enable) begin
    if (t_readtoz == $realtime) begin
        IoX <= 1'b0;
    end
end


//#############################################################################
// Timing checks
//#############################################################################

/*
// ??? check for read to command violations.  
always @(posedge Re_n)
begin
    if(~sync_mode) begin 
        tm_ReHi_WeLo = 1'b1; 
        tm_ReHi_WeLo = #tRHW_min 1'b0;
    end
end 

always @ (negedge We_n) begin
    if(tm_ReHI_WeLo & ~We_n & ~sync_mode & Cle & ~(Io[7:0] ==8'h78 | Io[7:0] ==8'h70)) begin
        $sformat(msg,"tRHW violation: Re_n High to We_n low violation %t ", $realtime); ERROR(ERR_TIM, msg);    
    end
end 
*/
    
always @ (posedge We_n) begin 
    if (~PowerUp_Complete & Cle & ~Ce_n & We_n) begin $sformat(msg,"Warning: Command or Data Transfer during NAND Power-on-Reset"); WARN(msg); end
end 

always @ (We_n) begin
  if (~sync_mode & PowerUp_Complete) begin
    if (~We_n) begin : negedge_We_n
        if (~Ce_n) begin
             if (cache_op === 1) begin
                // special cache mode timing checks
                if ($realtime - tm_we_n_f < tWC_cache_min) begin $sformat(msg,"Cache Mode tWC violation on We_n by %t ", tm_we_n_f + tWC_cache_min - $realtime); ERROR(ERR_TIM, msg); end
                if ($realtime - tm_we_n_r < tWH_cache_min) begin $sformat(msg,"Cache Mode tWH violation on We_n by %t ", tm_we_n_r + tWH_cache_min - $realtime); ERROR(ERR_TIM, msg); end
             end else if (lastCmd === 8'hB8) begin
                if ($realtime - tm_we_n_f < tWCIO_min) begin $sformat(msg,"tWCIO violation on We_n by %t ", tm_we_n_f + tWCIO_min - $realtime); ERROR(ERR_TIM, msg); end
                if ($realtime - tm_we_n_r < tWHIO_min) begin $sformat(msg,"tWHIO violation on We_n by %t ", tm_we_n_r + tWHIO_min - $realtime); ERROR(ERR_TIM, msg); end
             end else begin
                if ($realtime - tm_we_n_f < tWC_min) begin $sformat(msg,"tWC violation on We_n by %t ", tm_we_n_f + tWC_min - $realtime); ERROR(ERR_TIM, msg); end
                if ($realtime - tm_we_n_r < tWH_min) begin $sformat(msg,"tWH violation on We_n by %t ", tm_we_n_r + tWH_min - $realtime); ERROR(ERR_TIM, msg); end
                if ($realtime - tm_re_n_r < tRHW_min) begin $sformat(msg,"tRHW violation on We_n by %t ", tm_re_n_r + tRHW_min - $realtime); ERROR(ERR_TIM, msg); end
            end
            tm_we_n_f <= $realtime;
        end
    end else begin : posedge_We_n
        if (~Ce_n) begin
            if (cache_op === 1) begin
                // special cache mode timing checks
                if ((lastCmd == 8'h85) && ~Ale && ~Cle && ~(cmnd_70h || cmnd_78h)) begin
                    if ($realtime - tm_we_n_r_ale < tCCS_cache_min) begin $sformat(msg,"Cache Mode tCCS violation on We_n by %t", tm_we_n_r_ale + tCCS_cache_min - $realtime); ERROR(ERR_TIM,msg); end
                end
                if ($realtime - tm_we_n_f < tWP_cache_min) begin $sformat(msg,"Cache Mode tWP violation on We_n by %t ", tm_we_n_f + tWP_cache_min - $realtime); ERROR(ERR_TIM, msg); end
                if ($realtime - tm_cle_r < tCLS_cache_min) begin $sformat(msg,"Cache Mode tCLS violation on We_n by %t ", tm_cle_r + tCLS_cache_min - $realtime); ERROR(ERR_TIM, msg); end
                if ($realtime - tm_cle_f < tCLS_cache_min) begin $sformat(msg,"Cache Mode tCLS violation on We_n by %t ", tm_cle_f + tCLS_cache_min - $realtime); ERROR(ERR_TIM, msg); end
                if ($realtime - tm_ce_n_f < tCS_cache_min) begin $sformat(msg,"Cache Mode tCS violation on We_n by %t ", tm_ce_n_f + tCS_cache_min - $realtime); ERROR(ERR_TIM, msg); end
                if ($realtime - tm_io_ztodata < tDS_cache_min) begin $sformat(msg,"Cache Mode tDS violation on We_n by %t ", tm_io_ztodata + tDS_cache_min - $realtime); ERROR(ERR_TIM, msg); end
                if ($realtime - tm_ale_r < tALS_cache_min) begin $sformat(msg,"Cache Mode tALS violation on We_n by %t ", tm_ale_r + tALS_cache_min - $realtime); ERROR(ERR_TIM, msg); end
                if ($realtime - tm_ale_f < tALS_cache_min) begin $sformat(msg,"Cache Mode tALS violation on We_n by %t ", tm_ale_f + tALS_cache_min - $realtime); ERROR(ERR_TIM, msg); end
                if ($realtime - tm_wp_n < tWW_cache_min) begin $sformat(msg,"Cache Mode tWW violation on We_n by %t ", tm_wp_n + tWW_cache_min - $realtime); ERROR(ERR_TIM, msg); end
            end else if (lastCmd === 8'hB8) begin
                if ($realtime - tm_we_n_f < tWPIO_min) begin $sformat(msg,"tWPIO violation on We_n by %t ", tm_we_n_f + tWPIO_min - $realtime); ERROR(ERR_TIM, msg); end
                if ($realtime - tm_cle_r < tCLSIO_min) begin $sformat(msg,"tCLSIO violation on We_n by %t ", tm_cle_r + tCLSIO_min - $realtime); ERROR(ERR_TIM, msg); end
                if ($realtime - tm_cle_f < tCLSIO_min) begin $sformat(msg,"tCLSIO violation on We_n by %t ", tm_cle_f + tCLSIO_min - $realtime); ERROR(ERR_TIM, msg); end
                if ($realtime - tm_io_ztodata < tDSIO_min) begin $sformat(msg,"tDSIO violation on We_n by %t ", tm_io_ztodata + tDSIO_min - $realtime); ERROR(ERR_TIM, msg); end
            end else if ((lastCmd == 8'h85) && ~Ale && ~Cle && ~(cmnd_70h || cmnd_78h)) begin
                if ($realtime - tm_we_n_r_ale < tCCS_min) begin $sformat(msg,"Cache Mode tCCS violation on We_n by %t", tm_we_n_r_ale + tCCS_min - $realtime); ERROR(ERR_TIM,msg); end
            end else begin
                if ($realtime - tm_we_n_f < tWP_min) begin $sformat(msg,"tWP violation on We_n by %t ", tm_we_n_f + tWP_min - $realtime); ERROR(ERR_TIM, msg); end
                if ($realtime - tm_ale_r < tALS_min) begin $sformat(msg,"tALS violation on We_n by %t ", tm_ale_r + tALS_min - $realtime); ERROR(ERR_TIM, msg); end
                if ($realtime - tm_ale_f < tALS_min) begin $sformat(msg,"tALS violation on We_n by %t ", tm_ale_f + tALS_min - $realtime); ERROR(ERR_TIM, msg); end
                if ($realtime - tm_cle_r < tCLS_min) begin $sformat(msg,"tCLS violation on We_n by %t ", tm_cle_r + tCLS_min - $realtime); ERROR(ERR_TIM, msg); end
                if ($realtime - tm_cle_f < tCLS_min) begin $sformat(msg,"tCLS violation on We_n by %t ", tm_cle_f + tCLS_min - $realtime); ERROR(ERR_TIM, msg); end
                if ($realtime - tm_ce_n_f < tCS_min) begin $sformat(msg,"tCS violation on We_n by %t ", tm_ce_n_f + tCS_min - $realtime); ERROR(ERR_TIM, msg); end
                if ($realtime - tm_wp_n < tWW_min) begin $sformat(msg,"tWW violation on We_n by %t ", tm_wp_n + tWW_min - $realtime); ERROR(ERR_TIM, msg); end
                if ($realtime - tm_io_ztodata < tDS_min) begin $sformat(msg,"tDS violation on We_n by %t ", tm_io_ztodata + tDS_min - $realtime); ERROR(ERR_TIM, msg); end
                if ((we_adl_active && ~Ale && ~Cle) && ($realtime - tm_we_ale_r < tADL_min)) begin 
                        $sformat(msg,"tADL violation on We_n by %t ", tm_we_ale_r + tADL_min - $realtime); ERROR(ERR_TIM, msg); 
                        $display("tm_we_ale_r=%0t , tm_we_data_r=%0t", tm_we_ale_r, tm_we_data_r);
                    end
            end
        end
        tm_we_n_r <= $realtime;
        if (Ale) tm_we_n_r_ale <= $realtime;
    end //posedge_We_n
  end
end


always @ (Re_n) begin
  if (~sync_mode & PowerUp_Complete) begin
    if (~Re_n) begin : negedge_Re_n
        if (~Ce_n) begin
            if (cache_op === 1) begin
                // special cache mode timing checks
                if ((lastCmd == 8'hE0) && ~(cmnd_70h || cmnd_78h)) begin
                    if ($realtime - tm_we_n_r < tCCS_cache_min) begin $sformat(msg,"Cache Mode tCCS violation on Re_n by %t", tm_we_n_r + tCCS_cache_min - $realtime); ERROR(ERR_TIM,msg); end
                end
                if ($realtime - tm_io_datatoz < tIR_cache_min) begin $sformat(msg,"Cache Mode tIR violation on Re_n by %t ", tm_io_datatoz + tIR_cache_min - $realtime); ERROR(ERR_TIM, msg); end
                if ($realtime - tm_re_n_f < tRC_cache_min) begin $sformat(msg,"Cache Mode tRC violation on Re_n by %t ", tm_re_n_f + tRC_cache_min - $realtime); ERROR(ERR_TIM, msg); end
                if ($realtime - tm_re_n_r < tREH_cache_min) begin $sformat(msg,"Cache Mode tREH violation on Re_n by %t ", tm_re_n_r + tREH_cache_min - $realtime); ERROR(ERR_TIM, msg); end
                if ($realtime - tm_we_n_r < tWHR_cache_min) begin $sformat(msg,"Cache Mode tWHR violation on Re_n by %t ", tm_we_n_r + tWHR_cache_min - $realtime); ERROR(ERR_TIM, msg); end
            end else if (lastCmd === 8'hB8) begin
                if ($realtime - tm_we_n_r < tWHRIO_min) begin $sformat(msg,"tWHRIO violation on Re_n by %t ", tm_we_n_r + tWHRIO_min - $realtime); ERROR(ERR_TIM, msg); end
            end else if ((lastCmd == 8'hE0) && ~(cmnd_70h || cmnd_78h)) begin
                    if ($realtime - tm_we_n_r < tCCS_min) begin $sformat(msg,"Cache Mode tCCS violation on Re_n by %t", tm_we_n_r + tCCS_min - $realtime); ERROR(ERR_TIM,msg); end
            end else begin
                if ($realtime - tm_ale_f < tAR_min) begin $sformat(msg,"tAR violation on Re_n by %t ", tm_ale_f + tAR_min - $realtime); ERROR(ERR_TIM, msg); end
                if ($realtime - tm_cle_f < tCLR_min) begin $sformat(msg,"tCLR violation on Re_n by %t ", tm_cle_f + tCLR_min - $realtime); ERROR(ERR_TIM, msg); end
                if ($realtime - tm_re_n_f < tRC_min) begin $sformat(msg,"tRC violation on Re_n by %t ", tm_re_n_f + tRC_min - $realtime); ERROR(ERR_TIM, msg); end
                if ($realtime - tm_re_n_r < tREH_min) begin $sformat(msg,"tREH violation on Re_n by %t ", tm_re_n_r + tREH_min - $realtime); ERROR(ERR_TIM, msg); end
                if ($realtime - tm_we_n_r < tWHR_min) begin $sformat(msg,"tWHR violation on Re_n by %t ", tm_we_n_r + tWHR_min - $realtime); ERROR(ERR_TIM, msg); end
                if ($realtime - tm_io_datatoz < tIR_min) begin $sformat(msg,"tIR violation on Re_n by %t ", tm_io_datatoz + tIR_min - $realtime); ERROR(ERR_TIM, msg); end
                if (($realtime - tm_rb_n_r < tRR_min) && ~cmnd_78h && ~cmnd_70h) begin $sformat(msg,"tRR violation on Re_n by %t ", tm_rb_n_r + tRR_min - $realtime); ERROR(ERR_TIM, msg); end
            end
`ifdef EDO
            //read EDO mode, not supported by all devices
            if (($realtime - tm_re_n_f) < tEDO_RC) begin
                edo_mode = 1'b1;
                if (DEBUG[0]) begin $sformat(msg,"tRC less than %0d, EDO READ MODE enabled.", tEDO_RC); INFO(msg); end
            end else begin
                edo_mode = 1'b0;
            end
`endif
        end
        tm_re_n_f <= $realtime;
    end else begin : posedge_Re_n
        if (~Ce_n) begin
            if (cache_op === 1) begin
                // special cache mode timing checks
                if ($realtime - tm_re_n_f < tRP_cache_min) begin $sformat(msg,"Cache Mode tRP violation on Re_n by %0t", tm_re_n_f + tRP_cache_min - $realtime); ERROR(ERR_TIM, msg); end
            end else if (lastCmd === 8'hB8) begin
                if ($realtime - tm_re_n_f < tRPIO_min) begin $sformat(msg,"tRPIO violation on Re_n by %0t", tm_re_n_f + tRPIO_min - $realtime); ERROR(ERR_TIM, msg); end
            end else begin
                if ($realtime - tm_re_n_f < tRP_min) begin $sformat(msg,"tRP violation on Re_n by %0t", tm_re_n_f + tRP_min - $realtime); ERROR(ERR_TIM, msg); end
            end
        end
        tm_re_n_r <= $realtime;
    end // posedge_Re_n
  end
end

always @ (Ce_n) begin
    if (~Ce_n) begin
        tm_ce_n_f <= $realtime;
    end else begin
        if (PowerUp_Complete && ~sync_mode) begin
            if (cache_op === 1) begin
                // special cache mode timing checks
                if ($realtime - tm_we_n_r < tCH_cache_min) begin $sformat(msg,"Cache Mode tCH violation on Re_n by %0t", tm_we_n_r + tCH_cache_min - $realtime);  ERROR(ERR_TIM, msg); end
            end    else begin
                //avoid timing violation during sim init if Ce_n starts as anything other than 1'b1
                if (($realtime - tm_we_n_r < tCH_min) && (tm_we_n_r > 0)) begin $sformat(msg,"tCH violation on Re_n by %0t", tm_we_n_r + tCH_min - $realtime); ERROR(ERR_TIM, msg); end
            end
        end
        tm_ce_n_r <= $realtime;
    end
end

always @ (Rb_n) begin
    if (~Rb_n) begin
        tm_rb_n_f <= $realtime;
    end else begin
        tm_rb_n_r <= $realtime;
    end
end

always @ (Cle) begin
  if (~Ce_n) begin
    if (~Cle) begin
        tm_cle_f <= $realtime;
    end else begin
        tm_cle_r <= $realtime;
    end
    if (PowerUp_Complete && ~sync_mode) begin
        if (cache_op === 1) begin
            // special cache mode timing checks
            if ($realtime - tm_we_n_r < tCLH_cache_min) begin $sformat(msg,"Cache Mode tCLH violation on Cle by %0t", tm_we_n_r + tCLH_cache_min - $realtime); ERROR(ERR_TIM, msg); end
        end else if (lastCmd === 8'hB8) begin
            if ($realtime - tm_we_n_r < tCLHIO_min) begin $sformat(msg,"tCLHIO violation on Cle by %0t", tm_we_n_r + tCLHIO_min - $realtime); ERROR(ERR_TIM, msg); end
        end else begin
            if ($realtime - tm_we_n_r < tCLH_min) begin $sformat(msg,"tCLH violation on Cle by %0t", tm_we_n_r + tCLH_min - $realtime); ERROR(ERR_TIM, msg); end
        end
    end
  end //~sync_mode && ~Ce_n
end

always @ (Ale) begin
  if (~Ce_n) begin
    if (~Ale) begin
        tm_ale_f <= $realtime;
    end else begin
        tm_ale_r <= $realtime;
    end
    if (PowerUp_Complete && ~sync_mode) begin
        if (cache_op === 1) begin
            // special cache mode timing checks
            if ($realtime - tm_we_n_r < tALH_cache_min) begin $sformat(msg,"Cache Mode tALH violation on Ale by %0t", tm_we_n_r + tALH_cache_min - $realtime); ERROR(ERR_TIM, msg); end
        end else begin
            if ($realtime - tm_we_n_r < tALH_min) begin $sformat(msg,"tALH violation on Ale by %0t", tm_we_n_r + tALH_min - $realtime); ERROR(ERR_TIM, msg); end
        end
    end
  end //~sync_mode && ~Ce_n
end

always @ (Io_buf) begin
  if (~sync_mode && ~Ce_n) begin
    if ((Io_buf === {DQ_BITS{1'bx}}) && ($realtime == t_readtox)) begin
        if (PowerUp_Complete) begin
            if (cache_op === 1) begin
            // special cache mode timing checks
                if ($realtime - tm_we_n_r < tDH_cache_min) begin $sformat(msg,"Cache Mode tDH violation on IO by %0t", tm_we_n_r + tDH_cache_min - $realtime); ERROR(ERR_TIM, msg); end
                if (edo_mode) begin
                    if ((0 < ($realtime - tm_re_n_f)) && (($realtime - tm_re_n_f)  < tRLOH_cache_min)) begin $sformat(msg,"Cache Mode tRLOH violation on IO by %0t", tm_re_n_f + tRLOH_cache_min - $realtime); ERROR(ERR_TIM, msg); end
                end
            end else if (lastCmd === 8'hB8) begin
                if ($realtime - tm_we_n_r < tDHIO_min) begin $sformat(msg,"tDHIO violation on IO by %0t", tm_we_n_r + tDHIO_min - $realtime); ERROR(ERR_TIM, msg); end
            end else begin
                if ($realtime - tm_we_n_r < tDH_min) begin $sformat(msg,"tDH violation on IO by %0t", tm_we_n_r + tDH_min - $realtime); ERROR(ERR_TIM, msg); end
                if ($realtime - tm_ce_n_r < tCOH_min) begin $sformat(msg,"tCOH violation on IO by %0t", tm_ce_n_r + tCOH_min - $realtime); ERROR(ERR_TIM, msg); end
                if ($realtime - tm_re_n_r < tRHOH_min) begin $sformat(msg,"tRHOH violation on IO by %0t", tm_re_n_r + tRHOH_min - $realtime); ERROR(ERR_TIM, msg); end
                if (edo_mode) begin
                    if ((0 < ($realtime - tm_re_n_f)) && (($realtime - tm_re_n_f)  < tRLOH_min)) begin $sformat(msg,"tRLOH violation on IO by %0t", tm_re_n_f + tRLOH_min - $realtime); ERROR(ERR_TIM, msg); end
                end
            end
        end
        tm_io_datatoz <= $realtime;
    end else begin
        tm_io_ztodata <= $realtime;
    end
  end //~sync_mode && ~Ce_n
end


endmodule

