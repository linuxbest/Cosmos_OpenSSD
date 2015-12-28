//-----------------------------------------------------------------------------
// tb_tb.v
//-----------------------------------------------------------------------------

`timescale 1 ps / 100 fs

`uselib lib=unisims_ver

// START USER CODE (Do not remove this line)

// User: Put your directives here. Code in this
//       section will not be overwritten.

// END USER CODE (Do not remove this line)

module tb_tb
  (
  );

  // START USER CODE (Do not remove this line)

  // User: Put your signals here. Code in this
  //       section will not be overwritten.

  // END USER CODE (Do not remove this line)

  real CLK_P_PERIOD = 10000.000000;
  real CLK_N_PERIOD = 10000.000000;
  real RESET_LENGTH = 160000;

  // Internal signals

  reg CLK_N;
  reg CLK_P;
  reg RESET;
  wire [7:0] sync_ch_ctl_bl16_0_ERASE_END_O_pin;
  wire [7:0] sync_ch_ctl_bl16_0_ERASE_START_O_pin;
  wire [7:0] sync_ch_ctl_bl16_0_OP_FAIL_O_pin;
  wire [7:0] sync_ch_ctl_bl16_0_PROG_END_O_pin;
  wire [7:0] sync_ch_ctl_bl16_0_PROG_START_O_pin;
  wire [7:0] sync_ch_ctl_bl16_0_READ_END_O_pin;
  wire [7:0] sync_ch_ctl_bl16_0_READ_START_O_pin;
  wire sync_ch_ctl_bl16_0_SSD_ALE_pin;
  wire [7:0] sync_ch_ctl_bl16_0_SSD_CEN_pin;
  wire sync_ch_ctl_bl16_0_SSD_CLE_pin;
  wire sync_ch_ctl_bl16_0_SSD_CLK_pin;
  wire sync_ch_ctl_bl16_0_SSD_DQS_pin;
  wire [7:0] sync_ch_ctl_bl16_0_SSD_DQ_pin;
  reg [7:0] sync_ch_ctl_bl16_0_SSD_RB_pin;
  wire sync_ch_ctl_bl16_0_SSD_WPN_pin;
  wire sync_ch_ctl_bl16_0_SSD_WRN_pin;

  tb
    dut (
      .RESET ( RESET ),
      .CLK_P ( CLK_P ),
      .CLK_N ( CLK_N ),
      .sync_ch_ctl_bl16_0_SSD_DQ_pin ( sync_ch_ctl_bl16_0_SSD_DQ_pin ),
      .sync_ch_ctl_bl16_0_SSD_CLE_pin ( sync_ch_ctl_bl16_0_SSD_CLE_pin ),
      .sync_ch_ctl_bl16_0_SSD_ALE_pin ( sync_ch_ctl_bl16_0_SSD_ALE_pin ),
      .sync_ch_ctl_bl16_0_SSD_CEN_pin ( sync_ch_ctl_bl16_0_SSD_CEN_pin ),
      .sync_ch_ctl_bl16_0_SSD_CLK_pin ( sync_ch_ctl_bl16_0_SSD_CLK_pin ),
      .sync_ch_ctl_bl16_0_SSD_WRN_pin ( sync_ch_ctl_bl16_0_SSD_WRN_pin ),
      .sync_ch_ctl_bl16_0_SSD_WPN_pin ( sync_ch_ctl_bl16_0_SSD_WPN_pin ),
      .sync_ch_ctl_bl16_0_SSD_RB_pin ( sync_ch_ctl_bl16_0_SSD_RB_pin ),
      .sync_ch_ctl_bl16_0_SSD_DQS_pin ( sync_ch_ctl_bl16_0_SSD_DQS_pin ),
      .sync_ch_ctl_bl16_0_PROG_START_O_pin ( sync_ch_ctl_bl16_0_PROG_START_O_pin ),
      .sync_ch_ctl_bl16_0_PROG_END_O_pin ( sync_ch_ctl_bl16_0_PROG_END_O_pin ),
      .sync_ch_ctl_bl16_0_READ_START_O_pin ( sync_ch_ctl_bl16_0_READ_START_O_pin ),
      .sync_ch_ctl_bl16_0_READ_END_O_pin ( sync_ch_ctl_bl16_0_READ_END_O_pin ),
      .sync_ch_ctl_bl16_0_ERASE_START_O_pin ( sync_ch_ctl_bl16_0_ERASE_START_O_pin ),
      .sync_ch_ctl_bl16_0_ERASE_END_O_pin ( sync_ch_ctl_bl16_0_ERASE_END_O_pin ),
      .sync_ch_ctl_bl16_0_OP_FAIL_O_pin ( sync_ch_ctl_bl16_0_OP_FAIL_O_pin )
    );

  // Clock generator for CLK_P

  initial
    begin
      CLK_P = 1'b0;
      forever #(CLK_P_PERIOD/2.00)
        CLK_P = ~CLK_P;
    end

  // Clock generator for CLK_N

  initial
    begin
      CLK_N = 1'b1;
      forever #(CLK_N_PERIOD/2.00)
        CLK_N = ~CLK_N;
    end

  // Reset Generator for RESET

  initial
    begin
      RESET = 1'b1;
      #(RESET_LENGTH) RESET = ~RESET;
    end

  // START USER CODE (Do not remove this line)

  // User: Put your stimulus here. Code in this
  //       section will not be overwritten.

   wire [7:0] RB;
   wire       DQS;

   wire [7:0] DQ;

   wire       CLE;
   wire       ALE;
   wire [7:0] CEN;
   wire       CLK;
   wire       WRN;
   wire       WPN;
   
   nand_ssd
     nand_ssd (
	       .DQ			(sync_ch_ctl_bl16_0_SSD_DQ_pin),
	       /*AUTOINST*/
	       // Outputs
	       .RB			(RB[7:0]),
	       .DQS			(DQS),
	       // Inputs
	       .CLE			(CLE),
	       .ALE			(ALE),
	       .CEN			(CEN[7:0]),
	       .CLK			(CLK),
	       .WPN			(WPN),
	       .WRN			(WRN));
   always @(*)
     begin
	sync_ch_ctl_bl16_0_SSD_RB_pin = RB;
     end
   assign sync_ch_ctl_bl16_0_SSD_DQS_pin = DQS;

   assign CLE = sync_ch_ctl_bl16_0_SSD_CLE_pin;
   assign ALE = sync_ch_ctl_bl16_0_SSD_ALE_pin;
   assign CEN = sync_ch_ctl_bl16_0_SSD_CEN_pin;
   assign WPN = sync_ch_ctl_bl16_0_SSD_WPN_pin;
   assign WRN = sync_ch_ctl_bl16_0_SSD_WRN_pin;
   assign CLK = sync_ch_ctl_bl16_0_SSD_CLK_pin;
   
  // END USER CODE (Do not remove this line)

endmodule

