if { [info exists PathSeparator] } { set ps $PathSeparator } else { set ps "/" }
if { ![info exists tbpath] } { set tbpath "/tb_tb" }

set binopt {-logic}
set hexopt {-literal -hex}

eval add wave -noupdate -divider {"top-level ports"}
eval add wave -noupdate $binopt $tbpath${ps}CLK_P
eval add wave -noupdate $binopt $tbpath${ps}RESET

#eval add wave -noupdate $binopt $tbpath${ps}CLK_N

eval add wave -noupdate $binopt $tbpath${ps}sync_ch_ctl_bl16_0_SSD_CLK_pin
eval add wave -noupdate $binopt $tbpath${ps}sync_ch_ctl_bl16_0_SSD_CLE_pin
eval add wave -noupdate $binopt $tbpath${ps}sync_ch_ctl_bl16_0_SSD_ALE_pin
eval add wave -noupdate $binopt $tbpath${ps}sync_ch_ctl_bl16_0_SSD_ALE_pin
eval add wave -noupdate $binopt $tbpath${ps}sync_ch_ctl_bl16_0_SSD_CEN_pin
eval add wave -noupdate $binopt $tbpath${ps}sync_ch_ctl_bl16_0_SSD_WRN_pin
eval add wave -noupdate $binopt $tbpath${ps}sync_ch_ctl_bl16_0_SSD_WPN_pin
