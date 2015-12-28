module axi_mm_systemc ( /*AUTOARG*/
   // Outputs
   m_axi_awaddr, m_axi_awlen, m_axi_awsize, m_axi_awburst,
   m_axi_awprot, m_axi_awvalid, m_axi_awlock, m_axi_awcache,
   m_axi_wdata, m_axi_wstrb, m_axi_wlast, m_axi_wvalid, m_axi_bready,
   m_axi_araddr, m_axi_arlen, m_axi_arsize, m_axi_arburst,
   m_axi_arprot, m_axi_arvalid, m_axi_arlock, m_axi_arcache,
   m_axi_rready, BRAM_RdData_A, BRAM_RdData_B,
   // Inputs
   axi_aclk, axi_aresetn, interrupt, ready, m_axi_awready,
   m_axi_wready, m_axi_bresp, m_axi_bvalid, m_axi_arready,
   m_axi_rdata, m_axi_rresp, m_axi_rlast, m_axi_rvalid, BRAM_Rst_A,
   BRAM_Clk_A, BRAM_En_A, BRAM_WE_A, BRAM_Addr_A, BRAM_WrData_A,
   BRAM_Rst_B, BRAM_Clk_B, BRAM_En_B, BRAM_WE_B, BRAM_Addr_B,
   BRAM_WrData_B
   );
   input axi_aclk;
   input axi_aresetn;
   input interrupt;
   input ready;
   output [31:0] m_axi_awaddr;
   output [7:0]  m_axi_awlen;
   output [2:0]  m_axi_awsize;
   output [1:0]  m_axi_awburst;
   output [2:0]  m_axi_awprot;
   output 	 m_axi_awvalid;
   input 	 m_axi_awready;
   output 	 m_axi_awlock;
   output [3:0]  m_axi_awcache;
   output [31:0] m_axi_wdata;
   output [3:0]  m_axi_wstrb;
   output 	 m_axi_wlast;
   output 	 m_axi_wvalid;
   input 	 m_axi_wready;
   input [1:0] 	 m_axi_bresp;
   input 	 m_axi_bvalid;
   output 	 m_axi_bready;
   output [31:0] m_axi_araddr;
   output [7:0]  m_axi_arlen;
   output [2:0]  m_axi_arsize;
   output [1:0]  m_axi_arburst;
   output [2:0]  m_axi_arprot;
   output 	 m_axi_arvalid;
   input 	 m_axi_arready;
   output 	 m_axi_arlock;
   output [3:0]  m_axi_arcache;
   input [31:0]  m_axi_rdata;
   input [1:0] 	 m_axi_rresp;
   input 	 m_axi_rlast;
   input 	 m_axi_rvalid;
   output 	 m_axi_rready;

   input 	 BRAM_Rst_A;
   input 	 BRAM_Clk_A;
   input 	 BRAM_En_A;
   input [3:0] 	 BRAM_WE_A;
   input [31:0]  BRAM_Addr_A;
   input [31:0]  BRAM_WrData_A;
   output [31:0] BRAM_RdData_A;

   input 	 BRAM_Rst_B;
   input 	 BRAM_Clk_B;
   input 	 BRAM_En_B;
   input [3:0] 	 BRAM_WE_B;
   input [31:0]  BRAM_Addr_B;
   input [31:0]  BRAM_WrData_B;
   output [31:0] BRAM_RdData_B;   
   
endmodule
