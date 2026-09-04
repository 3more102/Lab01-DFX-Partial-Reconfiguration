# Build out-of-context synthesis checkpoints for both RMs.
# Run from the project root in a Vivado 2023.2 Tcl shell.
set root [file normalize [file dirname [info script]]/..]
set part xczu9eg-ffvb1156-2-e
file mkdir "$root/build/rm"

proc build_rm {root part top src outdcp} {
    create_project -in_memory -part $part
    read_verilog -sv $src
    synth_design -mode out_of_context -top $top -part $part
    write_checkpoint -force "$root/build/rm/$outdcp"
    report_utilization -file "$root/build/rm/${top}_utilization.rpt"
    close_project
}

build_rm $root $part pattern_chaser "$root/rtl/pattern_chaser.sv" pattern_chaser_synth.dcp
build_rm $root $part pattern_lfsr   "$root/rtl/pattern_lfsr.sv"   pattern_lfsr_synth.dcp
puts "[DFX] RM checkpoints written to $root/build/rm"
