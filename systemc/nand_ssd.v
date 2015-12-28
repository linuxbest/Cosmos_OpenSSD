// nand_ssd.v --- 
// 
// Filename: nand_ssd.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Sun Dec 27 15:47:41 2015 (-0800)
// Version: 
// Last-Updated: 
//           By: 
//     Update #: 0
// URL: 
// Keywords: 
// Compatibility: 
// 
// 

// Commentary: 
// 
// 
// 
// 

// Change log:
// 
// 
// 

// -------------------------------------
// Naming Conventions:
// 	active low signals                 : "*_n"
// 	clock signals                      : "clk", "clk_div#", "clk_#x"
// 	reset signals                      : "rst", "rst_n"
// 	generics                           : "C_*"
// 	user defined types                 : "*_TYPE"
// 	state machine next state           : "*_ns"
// 	state machine current state        : "*_cs"
// 	combinatorial signals              : "*_com"
// 	pipelined or register delay signals: "*_d#"
// 	counter signals                    : "*cnt*"
// 	clock enable signals               : "*_ce"
// 	internal version of output port    : "*_i"
// 	device pins                        : "*_pin"
// 	ports                              : - Names begin with Uppercase
// Code:
module nand_ssd (/*AUTOARG*/
   // Outputs
   RB, DQS,
   // Inouts
   DQ,
   // Inputs
   CLE, ALE, CEN, CLK, WPN, WRN
   );

   inout [7:0] DQ;
   input       CLE;
   input       ALE;
   input [7:0] CEN;
   input       CLK;
   input       WPN;
   input       WRN;
   output [7:0] RB;
   output 	DQS;

   wire [3:0] Rb_tar_n;
   wire [3:0] ml_rdy;

   wire Lock;
   wire Pre;
   wire [2:0] PID;

   assign Pre  = 1'b0;
   assign Lock = 1'b0;
   assign PID  = 3'h0;

   nand_die_model #(.mds(3'h0)) uut_0 (DQ,  CLE,  ALE,  CEN[0],  CLK,  WRN,  WPN, RB,  Pre, Lock, DQS, ml_rdy[0], Rb_tar_n[0], PID);
   defparam uut_0.DEBUG = 5'b1_1111;

endmodule
//
// nand_ssd.v ends here
