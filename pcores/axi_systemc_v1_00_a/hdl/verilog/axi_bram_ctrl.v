// axi_bram_ctrl.v --- 
// 
// Filename: axi_bram_ctrl.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Wed Apr  9 10:28:24 2014 (-0700)
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
module axi_bram_ctrl (/*AUTOARG*/
   // Outputs
   ECC_Interrupt, ECC_UE, S_AXI_AWREADY, S_AXI_WREADY, S_AXI_BID,
   S_AXI_BRESP, S_AXI_BVALID, S_AXI_ARREADY, S_AXI_RID, S_AXI_RDATA,
   S_AXI_RRESP, S_AXI_RLAST, S_AXI_RVALID, S_AXI_CTRL_AWREADY,
   S_AXI_CTRL_WREADY, S_AXI_CTRL_BRESP, S_AXI_CTRL_BVALID,
   S_AXI_CTRL_ARREADY, S_AXI_CTRL_RDATA, S_AXI_CTRL_RRESP,
   S_AXI_CTRL_RVALID, BRAM_Rst_A, BRAM_Clk_A, BRAM_En_A, BRAM_WE_A,
   BRAM_Addr_A, BRAM_WrData_A, BRAM_Rst_B, BRAM_Clk_B, BRAM_En_B,
   BRAM_WE_B, BRAM_Addr_B, BRAM_WrData_B,
   // Inputs
   S_AXI_ACLK, S_AXI_ARESETN, S_AXI_AWID, S_AXI_AWADDR, S_AXI_AWLEN,
   S_AXI_AWSIZE, S_AXI_AWBURST, S_AXI_AWLOCK, S_AXI_AWCACHE,
   S_AXI_AWPROT, S_AXI_AWVALID, S_AXI_WDATA, S_AXI_WSTRB, S_AXI_WLAST,
   S_AXI_WVALID, S_AXI_BREADY, S_AXI_ARID, S_AXI_ARADDR, S_AXI_ARLEN,
   S_AXI_ARSIZE, S_AXI_ARBURST, S_AXI_ARLOCK, S_AXI_ARCACHE,
   S_AXI_ARPROT, S_AXI_ARVALID, S_AXI_RREADY, S_AXI_CTRL_AWVALID,
   S_AXI_CTRL_AWADDR, S_AXI_CTRL_WDATA, S_AXI_CTRL_WVALID,
   S_AXI_CTRL_BREADY, S_AXI_CTRL_ARADDR, S_AXI_CTRL_ARVALID,
   S_AXI_CTRL_RREADY, BRAM_RdData_A, BRAM_RdData_B
   );
   parameter C_S_AXI_ADDR_WIDTH = 32;
   parameter C_S_AXI_DATA_WIDTH = 32;
   parameter C_S_AXI_ID_WIDTH   = 4;
   parameter C_S_AXI_PROTOCOL   = "axi4";
   parameter C_S_AXI_SUPPORTS_NARROW_BURST = 0;
   parameter C_SINGLE_PORT_BRAM = 0;
   parameter C_S_AXI_CTRL_ADDR_WIDTH = 32;
   parameter C_S_AXI_CTRL_DATA_WIDTH = 32;
   parameter C_ECC = 0;
   parameter C_FAULT_INJECT = 0;
   parameter C_ECC_ONOFF_RESET_VALUE = 0;

   input S_AXI_ACLK;
   input S_AXI_ARESETN;
   output ECC_Interrupt;
   output ECC_UE;
   
   input  [C_S_AXI_ID_WIDTH-1:0] S_AXI_AWID;
   input  [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_AWADDR;
   input  [7:0] S_AXI_AWLEN;
   input  [2:0] S_AXI_AWSIZE;
   input  [1:0] S_AXI_AWBURST;
   input  S_AXI_AWLOCK;
   input  [3:0] S_AXI_AWCACHE;
   input  [2:0] S_AXI_AWPROT;
   input  S_AXI_AWVALID;
   output S_AXI_AWREADY;
   
   input [C_S_AXI_DATA_WIDTH-1:0] S_AXI_WDATA;
   input [C_S_AXI_DATA_WIDTH/8-1:0] S_AXI_WSTRB;
   input  S_AXI_WLAST;
   
   input  S_AXI_WVALID;
   output S_AXI_WREADY;
   
   output [C_S_AXI_ID_WIDTH-1:0] S_AXI_BID;
   output [1:0] S_AXI_BRESP;
   
   output S_AXI_BVALID;
   input  S_AXI_BREADY;
   
   input  [C_S_AXI_ID_WIDTH-1:0] S_AXI_ARID;
   input  [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_ARADDR;
   input  [7:0] S_AXI_ARLEN;
   input  [2:0] S_AXI_ARSIZE;
   input  [1:0] S_AXI_ARBURST;
   input  S_AXI_ARLOCK;
   input  [3:0] S_AXI_ARCACHE;
   input  [2:0] S_AXI_ARPROT;
   
   input  S_AXI_ARVALID;
   output S_AXI_ARREADY;
   
   output [C_S_AXI_ID_WIDTH-1:0] S_AXI_RID;
   output [C_S_AXI_DATA_WIDTH-1:0] S_AXI_RDATA;
   output [1:0] S_AXI_RRESP;
   output S_AXI_RLAST;
   
   output S_AXI_RVALID;
   input  S_AXI_RREADY;
   
   input  S_AXI_CTRL_AWVALID;
   output S_AXI_CTRL_AWREADY;
   input  [C_S_AXI_CTRL_ADDR_WIDTH-1:0] S_AXI_CTRL_AWADDR;
   
   input  [C_S_AXI_CTRL_DATA_WIDTH-1:0] S_AXI_CTRL_WDATA;
   input  S_AXI_CTRL_WVALID;
   output S_AXI_CTRL_WREADY;
   
   output [1:0] S_AXI_CTRL_BRESP;
   output S_AXI_CTRL_BVALID;
   input  S_AXI_CTRL_BREADY;
   
   input  [C_S_AXI_CTRL_ADDR_WIDTH-1:0] S_AXI_CTRL_ARADDR;
   input  S_AXI_CTRL_ARVALID;
   output S_AXI_CTRL_ARREADY;
   
   output [C_S_AXI_CTRL_DATA_WIDTH-1:0] S_AXI_CTRL_RDATA;
   output [1:0] S_AXI_CTRL_RRESP ;
   output S_AXI_CTRL_RVALID;
   input  S_AXI_CTRL_RREADY;
   
   output BRAM_Rst_A;
   output BRAM_Clk_A;
   output BRAM_En_A;
   output [C_S_AXI_DATA_WIDTH/8 + C_ECC*(1+(C_S_AXI_DATA_WIDTH/128))-1:0] BRAM_WE_A;
   output [C_S_AXI_ADDR_WIDTH-1:0] BRAM_Addr_A;
   output [C_S_AXI_DATA_WIDTH+C_ECC*8*(1+(C_S_AXI_DATA_WIDTH/128))-1:0] BRAM_WrData_A;
   input  [C_S_AXI_DATA_WIDTH+C_ECC*8*(1+(C_S_AXI_DATA_WIDTH/128))-1:0] BRAM_RdData_A;
	
   output BRAM_Rst_B;
   output BRAM_Clk_B;
   output BRAM_En_B;
   output [C_S_AXI_DATA_WIDTH/8 + C_ECC*(1+(C_S_AXI_DATA_WIDTH/128))-1:0] BRAM_WE_B;
   output [C_S_AXI_ADDR_WIDTH-1:0] BRAM_Addr_B;
   output [C_S_AXI_DATA_WIDTH+C_ECC*8*(1+(C_S_AXI_DATA_WIDTH/128))-1:0] BRAM_WrData_B;
   input  [C_S_AXI_DATA_WIDTH+C_ECC*8*(1+(C_S_AXI_DATA_WIDTH/128))-1:0] BRAM_RdData_B;	     
   
endmodule
// 
// axi_bram_ctrl.v ends here
