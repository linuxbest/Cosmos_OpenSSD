do tb_setup.do

#c

vlog -suppress 2902 -novopt -incr -work work ../../systemc/nand_ssd.v
vlog -suppress 2902 -novopt -incr -work work ../../systemc/nand/nand_model.v +incdir+../../systemc/nand/
vlog -suppress 2902 -novopt -incr -work work ../../systemc/nand/nand_die_model.v +incdir+../../systemc/nand/

sccom -work axi_systemc_v1_00_a -ggdb -I ../../systemc/ ../../systemc/axi_mm_systemc.cpp

sccom -work work -ggdb ../../systemc/osChip.c

#LIBRARY_PATH=/usr/lib/i386-linux-gnu

sccom -link -lib axi_systemc_v1_00_a -lib work

s

do ../../systemc/wave/top.do
do ../../systemc/wave/ssd.do
do ../../systemc/wave/fsc.do
do ../../systemc/wave/end.do

run 10us
