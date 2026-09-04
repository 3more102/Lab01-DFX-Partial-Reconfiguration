# Creates the source project and imports the lab RTL/XDC.
# Compatible with Vivado 2026.x by discovering the installed ZCU102 board part
# instead of hard-coding a single board-file revision.
set root [file normalize [file dirname [info script]]/..]
set proj_dir "$root/vivado"
file mkdir $proj_dir

set part_name xczu9eg-ffvb1156-2-e
if {![llength [get_parts -quiet $part_name]]} {
    error "Required device part $part_name is not installed in this Vivado installation."
}

create_project lab01_dfx "$proj_dir/lab01_dfx" -part $part_name -force

# Prefer the lab's historical ZCU102 board-part revision when present, but
# accept any installed ZCU102 board revision in newer Vivado releases.
set preferred_board xilinx.com:zcu102:part0:3.3
set zcu102_boards [get_board_parts -quiet *zcu102*]
if {[lsearch -exact $zcu102_boards $preferred_board] >= 0} {
    set board_part $preferred_board
} elseif {[llength $zcu102_boards]} {
    set board_part [lindex $zcu102_boards 0]
} else {
    error "No ZCU102 board definition is installed. Install/enable the ZCU102 board files, then rerun."
}
set_property board_part $board_part [current_project]
puts "INFO: Using Vivado [version -short]"
puts "INFO: Using board part $board_part"

set_property target_language Verilog [current_project]
set_property simulator_language Mixed [current_project]

add_files -norecurse [list \
    "$root/rtl/heartbeat_ctr.sv" \
    "$root/rtl/pattern_chaser.sv" \
    "$root/rtl/pattern_lfsr.sv"]
add_files -fileset constrs_1 -norecurse "$root/constr/leds.xdc"
update_compile_order -fileset sources_1

puts "\nNEXT GUI STEPS (same lab architecture under Vivado 2026.x):"
puts "1. Create sys.bd and add Zynq UltraScale+ MPSoC; Run Block Automation."
puts "2. Enable M_AXI_HPM0_FPD and set FCLK0=100 MHz."
puts "3. Add AXI GPIO: CH1 output width 2; CH2 input width 32."
puts "4. Add heartbeat_ctr as module reference and connect count to GPIO CH2."
puts "5. Add pattern_chaser as module reference named u_pattern."
puts "6. Connect clk=FCLK0, rst_n=dfx_ctrl[1], led[7:0] external."
puts "7. Define u_pattern as the RP and insert DFX Decoupler on led with safe 0x00."
puts "8. Connect decouple=dfx_ctrl[0]. Validate BD and create HDL wrapper."
puts "9. Open synthesized/implemented design and source tcl/pblock_template.tcl."
