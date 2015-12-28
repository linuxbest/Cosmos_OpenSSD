if { [info exists PathSeparator] } { set ps $PathSeparator } else { set ps "/" }
if { ![info exists ssd] } { set ssd "/tb_tb/nand_ssd" }

set binopt {-logic}
set hexopt {-literal -hex}

eval add wave -noupdate -divider {"top-level ports"}
eval add wave -noupdate $binopt $ssd${ps}CLK

eval add wave -noupdate $binopt $ssd${ps}CLE
eval add wave -noupdate $binopt $ssd${ps}ALE
eval add wave -noupdate $binopt $ssd${ps}CEN
eval add wave -noupdate $binopt $ssd${ps}WPN
eval add wave -noupdate $binopt $ssd${ps}WRN
eval add wave -noupdate $binopt $ssd${ps}RB
eval add wave -noupdate $binopt $ssd${ps}DQ
eval add wave -noupdate $binopt $ssd${ps}DQS
