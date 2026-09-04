# Creates the source project and imports the lab RTL/XDC.
# The ZynqMP block design and DFX Decoupler are intentionally completed in the
# Vivado GUI/DFX Wizard because board automation and decoupler interface naming
# are version/project dependent.
set root [file normalize [file dirname [info script]]/..]
set proj_dir "$root/vivado"
file mkdir $proj_dir

create_project lab01_dfx "$proj_dir/lab01_dfx" -part xczu9eg-ffvb1156-2-e -force
set_property board_part xilinx.com:zcu102:part0:3.3 [current_project]
set_property target_language Verilog [current_project]
set_property simulator_language Mixed [current_project]

add_files -norecurse [list \
    "$root/rtl/heartbeat_ctr.sv" \
    "$root/rtl/pattern_chaser.sv" \
    "$root/rtl/pattern_lfsr.sv"]
add_files -fileset constrs_1 -norecurse "$root/constr/leds.xdc"
update_compile_order -fileset sources_1

puts "\nNEXT GUI STEPS (from the supplied lab):"
puts "1. Create sys.bd and add Zynq UltraScale+ MPSoC; Run Block Automation."
puts "2. Enable M_AXI_HPM0_FPD and set FCLK0=100 MHz."
puts "3. Add AXI GPIO: CH1 output width 2; CH2 input width 32."
puts "4. Add heartbeat_ctr as module reference and connect count to GPIO CH2."
puts "5. Add pattern_chaser as module reference named u_pattern."
puts "6. Connect clk=FCLK0, rst_n=dfx_ctrl[1], led[7:0] external."
puts "7. Run DFX Wizard: mark u_pattern RP; add DFX Decoupler on led with safe 0x00."
puts "8. Connect decouple=dfx_ctrl[0]. Validate BD and create HDL wrapper."
puts "9. Open synthesized/implemented design and source tcl/pblock_template.tcl."
