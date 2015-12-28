// axi_systemc.v --- 
// 
// Filename: axi_systemc.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Tue Apr  8 22:07:07 2014 (-0700)
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
module axi_systemc (/*AUTOARG*/
   // Outputs
   s_axi_wready, s_axi_rvalid, s_axi_rresp, s_axi_rlast, s_axi_rid,
   s_axi_rdata, s_axi_bvalid, s_axi_bresp, s_axi_bid, s_axi_awready,
   s_axi_arready, m_axi_wvalid, m_axi_wstrb, m_axi_wlast, m_axi_wdata,
   m_axi_rready, m_axi_bready, m_axi_awvalid, m_axi_awsize,
   m_axi_awprot, m_axi_awlock, m_axi_awlen, m_axi_awcache,
   m_axi_awburst, m_axi_awaddr, m_axi_arvalid, m_axi_arsize,
   m_axi_arprot, m_axi_arlock, m_axi_arlen, m_axi_arcache,
   m_axi_arburst, m_axi_araddr,
   // Inputs
   s_axi_wvalid, s_axi_wstrb, s_axi_wlast, s_axi_wdata, s_axi_rready,
   s_axi_bready, s_axi_awvalid, s_axi_awsize, s_axi_awprot,
   s_axi_awlock, s_axi_awlen, s_axi_awid, s_axi_awcache,
   s_axi_awburst, s_axi_awaddr, s_axi_arvalid, s_axi_arsize,
   s_axi_arprot, s_axi_arlock, s_axi_arlen, s_axi_arid, s_axi_arcache,
   s_axi_arburst, s_axi_araddr, ready, m_axi_wready, m_axi_rvalid,
   m_axi_rresp, m_axi_rlast, m_axi_rdata, m_axi_bvalid, m_axi_bresp,
   m_axi_awready, m_axi_arready, interrupt, axi_aresetn, axi_aclk,
   s_axi_awregion, s_axi_arregion
   );
   parameter C_INSTANCE         = "";
   parameter C_FAMILY           = "";
   parameter C_S_AXI_ID_WIDTH   = 2;
   parameter C_S_AXI_DATA_WIDTH = 32;
   parameter C_S_AXI_ADDR_WIDTH = 32;
   parameter C_M_AXI_DATA_WIDTH = 32;
   parameter C_M_AXI_ADDR_WIDTH = 32;
   parameter C_S_AXI_SUPPORTS_NARROW_BURST = 0;
   parameter C_BASEADDR         = 32'h00000000;
   parameter C_HIGHADDR         = 32'h01FFFFFF;

   parameter C_S_AXI_PROTOCOL        = "AXI4";
   parameter C_SINGLE_PORT_BRAM      = 0;
   parameter C_S_AXI_CTRL_ADDR_WIDTH = 32;
   parameter C_S_AXI_CTRL_DATA_WIDTH = 32;
   parameter C_ECC                   = 0;
   parameter C_FAULT_INJECT          = 0;
   parameter C_ECC_ONOFF_RESET_VALUE = 1;
   
   /*AUTOINPUT*/
   // Beginning of automatic inputs (from unused autoinst inputs)
   input		axi_aclk;		// To axi_mm_systemc of axi_mm_systemc.v, ...
   input		axi_aresetn;		// To axi_mm_systemc of axi_mm_systemc.v, ...
   input		interrupt;		// To axi_mm_systemc of axi_mm_systemc.v
   input		m_axi_arready;		// To axi_mm_systemc of axi_mm_systemc.v
   input		m_axi_awready;		// To axi_mm_systemc of axi_mm_systemc.v
   input [1:0]		m_axi_bresp;		// To axi_mm_systemc of axi_mm_systemc.v
   input		m_axi_bvalid;		// To axi_mm_systemc of axi_mm_systemc.v
   input [31:0]		m_axi_rdata;		// To axi_mm_systemc of axi_mm_systemc.v
   input		m_axi_rlast;		// To axi_mm_systemc of axi_mm_systemc.v
   input [1:0]		m_axi_rresp;		// To axi_mm_systemc of axi_mm_systemc.v
   input		m_axi_rvalid;		// To axi_mm_systemc of axi_mm_systemc.v
   input		m_axi_wready;		// To axi_mm_systemc of axi_mm_systemc.v
   input		ready;			// To axi_mm_systemc of axi_mm_systemc.v
   input [C_S_AXI_ADDR_WIDTH-1:0] s_axi_araddr;	// To axi_bram_ctrl of axi_bram_ctrl.v
   input [1:0]		s_axi_arburst;		// To axi_bram_ctrl of axi_bram_ctrl.v
   input [3:0]		s_axi_arcache;		// To axi_bram_ctrl of axi_bram_ctrl.v
   input [C_S_AXI_ID_WIDTH-1:0] s_axi_arid;	// To axi_bram_ctrl of axi_bram_ctrl.v
   input [7:0]		s_axi_arlen;		// To axi_bram_ctrl of axi_bram_ctrl.v
   input		s_axi_arlock;		// To axi_bram_ctrl of axi_bram_ctrl.v
   input [2:0]		s_axi_arprot;		// To axi_bram_ctrl of axi_bram_ctrl.v
   input [2:0]		s_axi_arsize;		// To axi_bram_ctrl of axi_bram_ctrl.v
   input		s_axi_arvalid;		// To axi_bram_ctrl of axi_bram_ctrl.v
   input [C_S_AXI_ADDR_WIDTH-1:0] s_axi_awaddr;	// To axi_bram_ctrl of axi_bram_ctrl.v
   input [1:0]		s_axi_awburst;		// To axi_bram_ctrl of axi_bram_ctrl.v
   input [3:0]		s_axi_awcache;		// To axi_bram_ctrl of axi_bram_ctrl.v
   input [C_S_AXI_ID_WIDTH-1:0] s_axi_awid;	// To axi_bram_ctrl of axi_bram_ctrl.v
   input [7:0]		s_axi_awlen;		// To axi_bram_ctrl of axi_bram_ctrl.v
   input		s_axi_awlock;		// To axi_bram_ctrl of axi_bram_ctrl.v
   input [2:0]		s_axi_awprot;		// To axi_bram_ctrl of axi_bram_ctrl.v
   input [2:0]		s_axi_awsize;		// To axi_bram_ctrl of axi_bram_ctrl.v
   input		s_axi_awvalid;		// To axi_bram_ctrl of axi_bram_ctrl.v
   input		s_axi_bready;		// To axi_bram_ctrl of axi_bram_ctrl.v
   input		s_axi_rready;		// To axi_bram_ctrl of axi_bram_ctrl.v
   input [C_S_AXI_DATA_WIDTH-1:0] s_axi_wdata;	// To axi_bram_ctrl of axi_bram_ctrl.v
   input		s_axi_wlast;		// To axi_bram_ctrl of axi_bram_ctrl.v
   input [C_S_AXI_DATA_WIDTH/8-1:0] s_axi_wstrb;// To axi_bram_ctrl of axi_bram_ctrl.v
   input		s_axi_wvalid;		// To axi_bram_ctrl of axi_bram_ctrl.v
   // End of automatics
   /*AUTOOUTPUT*/
   // Beginning of automatic outputs (from unused autoinst outputs)
   output [31:0]	m_axi_araddr;		// From axi_mm_systemc of axi_mm_systemc.v
   output [1:0]		m_axi_arburst;		// From axi_mm_systemc of axi_mm_systemc.v
   output [3:0]		m_axi_arcache;		// From axi_mm_systemc of axi_mm_systemc.v
   output [7:0]		m_axi_arlen;		// From axi_mm_systemc of axi_mm_systemc.v
   output		m_axi_arlock;		// From axi_mm_systemc of axi_mm_systemc.v
   output [2:0]		m_axi_arprot;		// From axi_mm_systemc of axi_mm_systemc.v
   output [2:0]		m_axi_arsize;		// From axi_mm_systemc of axi_mm_systemc.v
   output		m_axi_arvalid;		// From axi_mm_systemc of axi_mm_systemc.v
   output [31:0]	m_axi_awaddr;		// From axi_mm_systemc of axi_mm_systemc.v
   output [1:0]		m_axi_awburst;		// From axi_mm_systemc of axi_mm_systemc.v
   output [3:0]		m_axi_awcache;		// From axi_mm_systemc of axi_mm_systemc.v
   output [7:0]		m_axi_awlen;		// From axi_mm_systemc of axi_mm_systemc.v
   output		m_axi_awlock;		// From axi_mm_systemc of axi_mm_systemc.v
   output [2:0]		m_axi_awprot;		// From axi_mm_systemc of axi_mm_systemc.v
   output [2:0]		m_axi_awsize;		// From axi_mm_systemc of axi_mm_systemc.v
   output		m_axi_awvalid;		// From axi_mm_systemc of axi_mm_systemc.v
   output		m_axi_bready;		// From axi_mm_systemc of axi_mm_systemc.v
   output		m_axi_rready;		// From axi_mm_systemc of axi_mm_systemc.v
   output [31:0]	m_axi_wdata;		// From axi_mm_systemc of axi_mm_systemc.v
   output		m_axi_wlast;		// From axi_mm_systemc of axi_mm_systemc.v
   output [3:0]		m_axi_wstrb;		// From axi_mm_systemc of axi_mm_systemc.v
   output		m_axi_wvalid;		// From axi_mm_systemc of axi_mm_systemc.v
   output		s_axi_arready;		// From axi_bram_ctrl of axi_bram_ctrl.v
   output		s_axi_awready;		// From axi_bram_ctrl of axi_bram_ctrl.v
   output [C_S_AXI_ID_WIDTH-1:0] s_axi_bid;	// From axi_bram_ctrl of axi_bram_ctrl.v
   output [1:0]		s_axi_bresp;		// From axi_bram_ctrl of axi_bram_ctrl.v
   output		s_axi_bvalid;		// From axi_bram_ctrl of axi_bram_ctrl.v
   output [C_S_AXI_DATA_WIDTH-1:0] s_axi_rdata;	// From axi_bram_ctrl of axi_bram_ctrl.v
   output [C_S_AXI_ID_WIDTH-1:0] s_axi_rid;	// From axi_bram_ctrl of axi_bram_ctrl.v
   output		s_axi_rlast;		// From axi_bram_ctrl of axi_bram_ctrl.v
   output [1:0]		s_axi_rresp;		// From axi_bram_ctrl of axi_bram_ctrl.v
   output		s_axi_rvalid;		// From axi_bram_ctrl of axi_bram_ctrl.v
   output		s_axi_wready;		// From axi_bram_ctrl of axi_bram_ctrl.v
   // End of automatics

   input [3:0] 		s_axi_awregion;
   input [3:0] 		s_axi_arregion;

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [C_S_AXI_ADDR_WIDTH-1:0] BRAM_Addr_A;	// From axi_bram_ctrl of axi_bram_ctrl.v
   wire [C_S_AXI_ADDR_WIDTH-1:0] BRAM_Addr_B;	// From axi_bram_ctrl of axi_bram_ctrl.v
   wire			BRAM_Clk_A;		// From axi_bram_ctrl of axi_bram_ctrl.v
   wire			BRAM_Clk_B;		// From axi_bram_ctrl of axi_bram_ctrl.v
   wire			BRAM_En_A;		// From axi_bram_ctrl of axi_bram_ctrl.v
   wire			BRAM_En_B;		// From axi_bram_ctrl of axi_bram_ctrl.v
   wire [31:0]		BRAM_RdData_A;		// From axi_mm_systemc of axi_mm_systemc.v
   wire [31:0]		BRAM_RdData_B;		// From axi_mm_systemc of axi_mm_systemc.v
   wire			BRAM_Rst_A;		// From axi_bram_ctrl of axi_bram_ctrl.v
   wire			BRAM_Rst_B;		// From axi_bram_ctrl of axi_bram_ctrl.v
   wire [C_S_AXI_DATA_WIDTH/8+C_ECC*(1+(C_S_AXI_DATA_WIDTH/128))-1:0] BRAM_WE_A;// From axi_bram_ctrl of axi_bram_ctrl.v
   wire [C_S_AXI_DATA_WIDTH/8+C_ECC*(1+(C_S_AXI_DATA_WIDTH/128))-1:0] BRAM_WE_B;// From axi_bram_ctrl of axi_bram_ctrl.v
   wire [C_S_AXI_DATA_WIDTH+C_ECC*8*(1+(C_S_AXI_DATA_WIDTH/128))-1:0] BRAM_WrData_A;// From axi_bram_ctrl of axi_bram_ctrl.v
   wire [C_S_AXI_DATA_WIDTH+C_ECC*8*(1+(C_S_AXI_DATA_WIDTH/128))-1:0] BRAM_WrData_B;// From axi_bram_ctrl of axi_bram_ctrl.v
   // End of automatics
   
   axi_mm_systemc
     axi_mm_systemc (/*AUTOINST*/
		     // Outputs
		     .m_axi_awaddr	(m_axi_awaddr[31:0]),
		     .m_axi_awlen	(m_axi_awlen[7:0]),
		     .m_axi_awsize	(m_axi_awsize[2:0]),
		     .m_axi_awburst	(m_axi_awburst[1:0]),
		     .m_axi_awprot	(m_axi_awprot[2:0]),
		     .m_axi_awvalid	(m_axi_awvalid),
		     .m_axi_awlock	(m_axi_awlock),
		     .m_axi_awcache	(m_axi_awcache[3:0]),
		     .m_axi_wdata	(m_axi_wdata[31:0]),
		     .m_axi_wstrb	(m_axi_wstrb[3:0]),
		     .m_axi_wlast	(m_axi_wlast),
		     .m_axi_wvalid	(m_axi_wvalid),
		     .m_axi_bready	(m_axi_bready),
		     .m_axi_araddr	(m_axi_araddr[31:0]),
		     .m_axi_arlen	(m_axi_arlen[7:0]),
		     .m_axi_arsize	(m_axi_arsize[2:0]),
		     .m_axi_arburst	(m_axi_arburst[1:0]),
		     .m_axi_arprot	(m_axi_arprot[2:0]),
		     .m_axi_arvalid	(m_axi_arvalid),
		     .m_axi_arlock	(m_axi_arlock),
		     .m_axi_arcache	(m_axi_arcache[3:0]),
		     .m_axi_rready	(m_axi_rready),
		     .BRAM_RdData_A	(BRAM_RdData_A[31:0]),
		     .BRAM_RdData_B	(BRAM_RdData_B[31:0]),
		     // Inputs
		     .axi_aclk		(axi_aclk),
		     .axi_aresetn	(axi_aresetn),
		     .interrupt		(interrupt),
		     .ready		(ready),
		     .m_axi_awready	(m_axi_awready),
		     .m_axi_wready	(m_axi_wready),
		     .m_axi_bresp	(m_axi_bresp[1:0]),
		     .m_axi_bvalid	(m_axi_bvalid),
		     .m_axi_arready	(m_axi_arready),
		     .m_axi_rdata	(m_axi_rdata[31:0]),
		     .m_axi_rresp	(m_axi_rresp[1:0]),
		     .m_axi_rlast	(m_axi_rlast),
		     .m_axi_rvalid	(m_axi_rvalid),
		     .BRAM_Rst_A	(BRAM_Rst_A),
		     .BRAM_Clk_A	(BRAM_Clk_A),
		     .BRAM_En_A		(BRAM_En_A),
		     .BRAM_WE_A		(BRAM_WE_A[3:0]),
		     .BRAM_Addr_A	(BRAM_Addr_A[31:0]),
		     .BRAM_WrData_A	(BRAM_WrData_A[31:0]),
		     .BRAM_Rst_B	(BRAM_Rst_B),
		     .BRAM_Clk_B	(BRAM_Clk_B),
		     .BRAM_En_B		(BRAM_En_B),
		     .BRAM_WE_B		(BRAM_WE_B[3:0]),
		     .BRAM_Addr_B	(BRAM_Addr_B[31:0]),
		     .BRAM_WrData_B	(BRAM_WrData_B[31:0]));


   /* axi_bram_ctrl AUTO_TEMPLATE (
    .S_AXI_ACLK        (axi_aclk),
    .S_AXI_ARESETN     (axi_aresetn),
    .ECC\(.*\)         (),
    .S_AXI_CTRL_\(.*\) (),
    .S_AXI_AWID(s_axi_awid[]),
    .S_AXI_AWADDR(s_axi_awaddr[]),
    .S_AXI_AWLEN(s_axi_awlen[]),
    .S_AXI_AWSIZE(s_axi_awsize[]),
    .S_AXI_AWBURST(s_axi_awburst[]),
    .S_AXI_AWLOCK(s_axi_awlock[]),
    .S_AXI_AWCACHE(s_axi_awcache[]),
    .S_AXI_AWPROT(s_axi_awprot[]),
    .S_AXI_AWVALID(s_axi_awvalid[]),
    .S_AXI_AWREADY(s_axi_awready[]),
    .S_AXI_WDATA(s_axi_wdata[]),
    .S_AXI_WSTRB(s_axi_wstrb[]),
    .S_AXI_WLAST(s_axi_wlast[]),
    .S_AXI_WVALID(s_axi_wvalid[]),
    .S_AXI_WREADY(s_axi_wready[]),
    .S_AXI_BID(s_axi_bid[]),
    .S_AXI_BRESP(s_axi_bresp[]),
    .S_AXI_BVALID(s_axi_bvalid[]),
    .S_AXI_BREADY(s_axi_bready[]),
    .S_AXI_ARID(s_axi_arid[]),
    .S_AXI_ARADDR(s_axi_araddr[]),
    .S_AXI_ARLEN(s_axi_arlen[]),
    .S_AXI_ARSIZE(s_axi_arsize[]),
    .S_AXI_ARBURST(s_axi_arburst[]),
    .S_AXI_ARLOCK(s_axi_arlock[]),
    .S_AXI_ARCACHE(s_axi_arcache[]),
    .S_AXI_ARPROT(s_axi_arprot[]),
    .S_AXI_ARVALID(s_axi_arvalid[]),
    .S_AXI_ARREADY(s_axi_arready[]),
    .S_AXI_RID(s_axi_rid[]),
    .S_AXI_RDATA(s_axi_rdata[]),
    .S_AXI_RRESP(s_axi_rresp[]),
    .S_AXI_RLAST(s_axi_rlast[]),
    .S_AXI_RVALID(s_axi_rvalid[]),
    .S_AXI_RREADY(s_axi_rready[]),
    );*/
   axi_bram_ctrl
     #(/*AUTOINSTPARAM*/
       // Parameters
       .C_S_AXI_ADDR_WIDTH		(C_S_AXI_ADDR_WIDTH),
       .C_S_AXI_DATA_WIDTH		(C_S_AXI_DATA_WIDTH),
       .C_S_AXI_ID_WIDTH		(C_S_AXI_ID_WIDTH),
       .C_S_AXI_PROTOCOL		(C_S_AXI_PROTOCOL),
       .C_S_AXI_SUPPORTS_NARROW_BURST	(C_S_AXI_SUPPORTS_NARROW_BURST),
       .C_SINGLE_PORT_BRAM		(C_SINGLE_PORT_BRAM),
       .C_S_AXI_CTRL_ADDR_WIDTH		(C_S_AXI_CTRL_ADDR_WIDTH),
       .C_S_AXI_CTRL_DATA_WIDTH		(C_S_AXI_CTRL_DATA_WIDTH),
       .C_ECC				(C_ECC),
       .C_FAULT_INJECT			(C_FAULT_INJECT),
       .C_ECC_ONOFF_RESET_VALUE		(C_ECC_ONOFF_RESET_VALUE))
   axi_bram_ctrl
     (/*AUTOINST*/
      // Outputs
      .ECC_Interrupt			(),			 // Templated
      .ECC_UE				(),			 // Templated
      .S_AXI_AWREADY			(s_axi_awready),	 // Templated
      .S_AXI_WREADY			(s_axi_wready),		 // Templated
      .S_AXI_BID			(s_axi_bid[C_S_AXI_ID_WIDTH-1:0]), // Templated
      .S_AXI_BRESP			(s_axi_bresp[1:0]),	 // Templated
      .S_AXI_BVALID			(s_axi_bvalid),		 // Templated
      .S_AXI_ARREADY			(s_axi_arready),	 // Templated
      .S_AXI_RID			(s_axi_rid[C_S_AXI_ID_WIDTH-1:0]), // Templated
      .S_AXI_RDATA			(s_axi_rdata[C_S_AXI_DATA_WIDTH-1:0]), // Templated
      .S_AXI_RRESP			(s_axi_rresp[1:0]),	 // Templated
      .S_AXI_RLAST			(s_axi_rlast),		 // Templated
      .S_AXI_RVALID			(s_axi_rvalid),		 // Templated
      .S_AXI_CTRL_AWREADY		(),			 // Templated
      .S_AXI_CTRL_WREADY		(),			 // Templated
      .S_AXI_CTRL_BRESP			(),			 // Templated
      .S_AXI_CTRL_BVALID		(),			 // Templated
      .S_AXI_CTRL_ARREADY		(),			 // Templated
      .S_AXI_CTRL_RDATA			(),			 // Templated
      .S_AXI_CTRL_RRESP			(),			 // Templated
      .S_AXI_CTRL_RVALID		(),			 // Templated
      .BRAM_Rst_A			(BRAM_Rst_A),
      .BRAM_Clk_A			(BRAM_Clk_A),
      .BRAM_En_A			(BRAM_En_A),
      .BRAM_WE_A			(BRAM_WE_A[C_S_AXI_DATA_WIDTH/8+C_ECC*(1+(C_S_AXI_DATA_WIDTH/128))-1:0]),
      .BRAM_Addr_A			(BRAM_Addr_A[C_S_AXI_ADDR_WIDTH-1:0]),
      .BRAM_WrData_A			(BRAM_WrData_A[C_S_AXI_DATA_WIDTH+C_ECC*8*(1+(C_S_AXI_DATA_WIDTH/128))-1:0]),
      .BRAM_Rst_B			(BRAM_Rst_B),
      .BRAM_Clk_B			(BRAM_Clk_B),
      .BRAM_En_B			(BRAM_En_B),
      .BRAM_WE_B			(BRAM_WE_B[C_S_AXI_DATA_WIDTH/8+C_ECC*(1+(C_S_AXI_DATA_WIDTH/128))-1:0]),
      .BRAM_Addr_B			(BRAM_Addr_B[C_S_AXI_ADDR_WIDTH-1:0]),
      .BRAM_WrData_B			(BRAM_WrData_B[C_S_AXI_DATA_WIDTH+C_ECC*8*(1+(C_S_AXI_DATA_WIDTH/128))-1:0]),
      // Inputs
      .S_AXI_ACLK			(axi_aclk),		 // Templated
      .S_AXI_ARESETN			(axi_aresetn),		 // Templated
      .S_AXI_AWID			(s_axi_awid[C_S_AXI_ID_WIDTH-1:0]), // Templated
      .S_AXI_AWADDR			(s_axi_awaddr[C_S_AXI_ADDR_WIDTH-1:0]), // Templated
      .S_AXI_AWLEN			(s_axi_awlen[7:0]),	 // Templated
      .S_AXI_AWSIZE			(s_axi_awsize[2:0]),	 // Templated
      .S_AXI_AWBURST			(s_axi_awburst[1:0]),	 // Templated
      .S_AXI_AWLOCK			(s_axi_awlock),		 // Templated
      .S_AXI_AWCACHE			(s_axi_awcache[3:0]),	 // Templated
      .S_AXI_AWPROT			(s_axi_awprot[2:0]),	 // Templated
      .S_AXI_AWVALID			(s_axi_awvalid),	 // Templated
      .S_AXI_WDATA			(s_axi_wdata[C_S_AXI_DATA_WIDTH-1:0]), // Templated
      .S_AXI_WSTRB			(s_axi_wstrb[C_S_AXI_DATA_WIDTH/8-1:0]), // Templated
      .S_AXI_WLAST			(s_axi_wlast),		 // Templated
      .S_AXI_WVALID			(s_axi_wvalid),		 // Templated
      .S_AXI_BREADY			(s_axi_bready),		 // Templated
      .S_AXI_ARID			(s_axi_arid[C_S_AXI_ID_WIDTH-1:0]), // Templated
      .S_AXI_ARADDR			(s_axi_araddr[C_S_AXI_ADDR_WIDTH-1:0]), // Templated
      .S_AXI_ARLEN			(s_axi_arlen[7:0]),	 // Templated
      .S_AXI_ARSIZE			(s_axi_arsize[2:0]),	 // Templated
      .S_AXI_ARBURST			(s_axi_arburst[1:0]),	 // Templated
      .S_AXI_ARLOCK			(s_axi_arlock),		 // Templated
      .S_AXI_ARCACHE			(s_axi_arcache[3:0]),	 // Templated
      .S_AXI_ARPROT			(s_axi_arprot[2:0]),	 // Templated
      .S_AXI_ARVALID			(s_axi_arvalid),	 // Templated
      .S_AXI_RREADY			(s_axi_rready),		 // Templated
      .S_AXI_CTRL_AWVALID		(),			 // Templated
      .S_AXI_CTRL_AWADDR		(),			 // Templated
      .S_AXI_CTRL_WDATA			(),			 // Templated
      .S_AXI_CTRL_WVALID		(),			 // Templated
      .S_AXI_CTRL_BREADY		(),			 // Templated
      .S_AXI_CTRL_ARADDR		(),			 // Templated
      .S_AXI_CTRL_ARVALID		(),			 // Templated
      .S_AXI_CTRL_RREADY		(),			 // Templated
      .BRAM_RdData_A			(BRAM_RdData_A[C_S_AXI_DATA_WIDTH+C_ECC*8*(1+(C_S_AXI_DATA_WIDTH/128))-1:0]),
      .BRAM_RdData_B			(BRAM_RdData_B[C_S_AXI_DATA_WIDTH+C_ECC*8*(1+(C_S_AXI_DATA_WIDTH/128))-1:0]));
   
endmodule
// 
// axi_systemc.v ends here
