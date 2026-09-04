# Run from Vivado Tcl shell:
#   vivado -mode batch -source tcl/run_behavioral_sim.tcl
set origin_dir [file normalize [file dirname [info script]]/..]
set sim_dir    [file normalize "$origin_dir/sim/xsim"]
file mkdir $sim_dir
cd $sim_dir

xvlog -sv \
    "$origin_dir/rtl/heartbeat_ctr.sv" \
    "$origin_dir/rtl/pattern_chaser.sv" \
    "$origin_dir/rtl/pattern_lfsr.sv" \
    "$origin_dir/rtl/dfx_boundary_model.sv" \
    "$origin_dir/tb/tb_dfx_behavior.sv"

xelab tb_dfx_behavior -s tb_dfx_behavior_sim -debug typical
xsim tb_dfx_behavior_sim -runall
