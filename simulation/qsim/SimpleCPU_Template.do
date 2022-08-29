onerror {quit -f}
vlib work
vlog -work work SimpleCPU_Template.vo
vlog -work work SimpleCPU_Template.vt
vsim -novopt -c -t 1ps -L cycloneii_ver -L altera_ver -L altera_mf_ver -L 220model_ver -L sgate work.SimpleCPU_Template_vlg_vec_tst
vcd file -direction SimpleCPU_Template.msim.vcd
vcd add -internal SimpleCPU_Template_vlg_vec_tst/*
vcd add -internal SimpleCPU_Template_vlg_vec_tst/i1/*
add wave /*
run -all
