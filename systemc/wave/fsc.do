if { [info exists PathSeparator] } { set ps $PathSeparator } else { set ps "/" }
if { ![info exists fsc] } { set fsc { /tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/ch_controller[0]/ch/way_controller[0]/way } }

set binopt {-logic}
set hexopt {-literal -hex}

eval add wave -noupdate -divider {"ipif"}
add wave -noupdate -logic {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/i_clk}
add wave -noupdate -logic {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/i_clk_200}
add wave -noupdate -logic {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/i_rstn}
add wave -noupdate -logic {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/w_clk_o}

add wave -noupdate -logic        {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/Bus2IP_Clk}
add wave -noupdate -logic        {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/Bus2IP_Resetn}
add wave -noupdate -literal -hex {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/Bus2IP_Addr}
add wave -noupdate -literal -hex {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/Bus2IP_Data}
add wave -noupdate -literal -hex {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/Bus2IP_BE}
add wave -noupdate -logic        {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/Bus2IP_RNW}
add wave -noupdate -logic        {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/Bus2IP_WrCE}
add wave -noupdate -logic        {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/Bus2IP_RdCE}
add wave -noupdate -literal -hex {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/IP2Bus_Data}
add wave -noupdate -logic        {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/IP2Bus_RdAck}
add wave -noupdate -logic        {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/IP2Bus_WrAck}
add wave -noupdate -logic        {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/IP2Bus_Error}

eval add wave -noupdate -divider {"ch ctrl"}
add wave -noupdate -logic        {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/ch_controller[0]/ch/i_bus_clk}
add wave -noupdate -logic        {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/ch_controller[0]/ch/i_slv_rd_sel}
add wave -noupdate -logic        {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/ch_controller[0]/ch/i_slv_wr_sel}
add wave -noupdate -logic        {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/ch_controller[0]/ch/i_slv_data}
add wave -noupdate -logic        {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/ch_controller[0]/ch/o_slv_data}
add wave -noupdate -logic        {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/ch_controller[0]/ch/i_slv_addr}
add wave -noupdate -logic        {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/ch_controller[0]/ch/i_slv_rnw}
add wave -noupdate -logic        {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/ch_controller[0]/ch/o_sp_write_ack}
add wave -noupdate -logic        {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/ch_controller[0]/ch/o_sp_read_ack}
add wave -noupdate -logic        {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/ch_controller[0]/ch/o_sp_write_ack}
add wave -noupdate -logic        {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/ch_controller[0]/ch/i_slv_sp_wr_ack}
add wave -noupdate -logic        {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/ch_controller[0]/ch/i_slv_sp_rd_ack}
add wave -noupdate -logic        {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/ch_controller[0]/ch/w_way_sel}

eval add wave -noupdate -divider {"way ctrl"}
add wave -noupdate -logic        {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/ch_controller[0]/ch/way_controller[0]/way/i_bus_clk}
add wave -noupdate -literal -hex {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/ch_controller[0]/ch/way_controller[0]/way/i_slv_rd_sel}
add wave -noupdate -literal -hex {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/ch_controller[0]/ch/way_controller[0]/way/i_slv_wr_sel}
add wave -noupdate -literal -hex {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/ch_controller[0]/ch/way_controller[0]/way/i_slv_data}
add wave -noupdate -literal -hex {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/ch_controller[0]/ch/way_controller[0]/way/o_slv_data}

add wave -noupdate -logic        {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/ch_controller[0]/ch/way_controller[0]/way/o_status}

eval add wave -noupdate -divider {"nand ctrl"}
add wave -noupdate -logic {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/ch_controller[0]/ch/way_controller[0]/way/nand_ctrl0/i_nc_clk}
add wave -noupdate -logic {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/ch_controller[0]/ch/way_controller[0]/way/nand_ctrl0/i_nc_rstn}

add wave -noupdate -literal -hex {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/ch_controller[0]/ch/way_controller[0]/way/nand_ctrl0/i_command}
add wave -noupdate -logic        {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/ch_controller[0]/ch/way_controller[0]/way/nand_ctrl0/i_cmd_ack}
add wave -noupdate -logic        {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/ch_controller[0]/ch/way_controller[0]/way/nand_ctrl0/o_maddr_ack}
add wave -noupdate -logic        {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/ch_controller[0]/ch/way_controller[0]/way/nand_ctrl0/o_b2m_req}
add wave -noupdate -logic        {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/ch_controller[0]/ch/way_controller[0]/way/nand_ctrl0/i_b2m_cmplt}
add wave -noupdate -logic        {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/ch_controller[0]/ch/way_controller[0]/way/nand_ctrl0/o_m2b_req}
add wave -noupdate -logic        {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/ch_controller[0]/ch/way_controller[0]/way/nand_ctrl0/i_m2b_cmplt}
add wave -noupdate -logic        {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/ch_controller[0]/ch/way_controller[0]/way/nand_ctrl0/o_ready}
add wave -noupdate -literal -hex {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/ch_controller[0]/ch/way_controller[0]/way/nand_ctrl0/o_status}

add wave -noupdate -logic        {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/ch_controller[0]/ch/way_controller[0]/way/nand_ctrl0/w_rst_status}
add wave -noupdate -logic        {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/ch_controller[0]/ch/way_controller[0]/way/nand_ctrl0/w_st_data}
add wave -noupdate -logic        {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/ch_controller[0]/ch/way_controller[0]/way/nand_ctrl0/w_st_data}
add wave -noupdate -logic        {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/ch_controller[0]/ch/way_controller[0]/way/nand_ctrl0/w_asyn_st_cp}
add wave -noupdate -logic        {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/ch_controller[0]/ch/way_controller[0]/way/nand_ctrl0/w_sync_st_cp}

add wave -noupdate -logic        {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/ch_controller[0]/ch/way_controller[0]/way/nand_ctrl0/o_ch_req}
add wave -noupdate -logic        {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/ch_controller[0]/ch/way_controller[0]/way/nand_ctrl0/i_ch_gnt}

add wave -noupdate -literal -hex {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/ch_controller[0]/ch/way_controller[0]/way/nand_ctrl0/o_pb_addr}
add wave -noupdate -literal -hex {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/ch_controller[0]/ch/way_controller[0]/way/nand_ctrl0/i_pb_data}
add wave -noupdate -literal -hex {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/ch_controller[0]/ch/way_controller[0]/way/nand_ctrl0/o_pb_data}
add wave -noupdate -logic        {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/ch_controller[0]/ch/way_controller[0]/way/nand_ctrl0/o_pb_en}
add wave -noupdate -logic        {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/ch_controller[0]/ch/way_controller[0]/way/nand_ctrl0/o_pb_we}

eval add wave -noupdate -divider {"nand ctrl chip"}
add wave -noupdate -logic        {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/ch_controller[0]/ch/way_controller[0]/way/nand_ctrl0/i_clk_o}
add wave -noupdate -literal -hex {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/ch_controller[0]/ch/way_controller[0]/way/nand_ctrl0/i_nand_addr}
add wave -noupdate -literal -hex {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/ch_controller[0]/ch/way_controller[0]/way/nand_ctrl0/i_nand_dq}
add wave -noupdate -literal -hex {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/ch_controller[0]/ch/way_controller[0]/way/nand_ctrl0/o_nand_dq}
add wave -noupdate -logic        {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/ch_controller[0]/ch/way_controller[0]/way/nand_ctrl0/o_nand_dq_t}
add wave -noupdate -logic        {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/ch_controller[0]/ch/way_controller[0]/way/nand_ctrl0/o_nand_cle}
add wave -noupdate -logic        {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/ch_controller[0]/ch/way_controller[0]/way/nand_ctrl0/o_nand_ale}
add wave -noupdate -logic        {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/ch_controller[0]/ch/way_controller[0]/way/nand_ctrl0/o_nand_ce_n}
add wave -noupdate -logic        {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/ch_controller[0]/ch/way_controller[0]/way/nand_ctrl0/o_nand_we_n}
add wave -noupdate -logic        {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/ch_controller[0]/ch/way_controller[0]/way/nand_ctrl0/o_nand_wr_n}
add wave -noupdate -logic        {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/ch_controller[0]/ch/way_controller[0]/way/nand_ctrl0/o_nand_wp_n}
add wave -noupdate -logic        {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/ch_controller[0]/ch/way_controller[0]/way/nand_ctrl0/i_nand_rb}
add wave -noupdate -logic        {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/ch_controller[0]/ch/way_controller[0]/way/nand_ctrl0/i_nand_dqs}
add wave -noupdate -logic        {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/ch_controller[0]/ch/way_controller[0]/way/nand_ctrl0/o_nand_dqs_t}

add wave -noupdate -logic        {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/ch_controller[0]/ch/way_controller[0]/way/nand_ctrl0/o_m_ch_cmplt}
add wave -noupdate -logic        {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/ch_controller[0]/ch/way_controller[0]/way/nand_ctrl0/o_dqs_ce}
add wave -noupdate -logic        {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/ch_controller[0]/ch/way_controller[0]/way/nand_ctrl0/o_sp_en}
add wave -noupdate -logic        {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/ch_controller[0]/ch/way_controller[0]/way/nand_ctrl0/o_prog_start}
add wave -noupdate -logic        {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/ch_controller[0]/ch/way_controller[0]/way/nand_ctrl0/o_prog_end}
add wave -noupdate -logic        {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/ch_controller[0]/ch/way_controller[0]/way/nand_ctrl0/o_read_start}
add wave -noupdate -logic        {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/ch_controller[0]/ch/way_controller[0]/way/nand_ctrl0/o_read_end}
add wave -noupdate -logic        {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/ch_controller[0]/ch/way_controller[0]/way/nand_ctrl0/o_erase_start}
add wave -noupdate -logic        {/tb_tb/dut/sync_ch_ctl_bl16_0/sync_ch_ctl_bl16_0/IPIF_I/ch_controller[0]/ch/way_controller[0]/way/nand_ctrl0/o_erase_end}


