# Build Configuration B from Configuration A using AMD's standard DFX sequence.
# Configuration A must already be fully routed with u_pattern marked
# HD.RECONFIGURABLE and constrained by a legal RP pblock.
set root   [file normalize [file dirname [info script]]/..]
set cfgA   "$root/build/config_a/routed.dcp"
set static "$root/build/config_a/static_routed.dcp"
set rmB    "$root/build/rm/pattern_lfsr_synth.dcp"
set out    "$root/build/config_b"
file mkdir $out

if {![file exists $cfgA]} { error "Missing $cfgA" }
if {![file exists $rmB]}  { error "Missing $rmB" }

# Freeze only the static implementation from Config A.
# AMD UG909 sequence: black-box the RP -> lock static routing -> save static DCP.
open_checkpoint $cfgA
if {[llength [get_cells -quiet u_pattern]] == 0} {
    error "RP cell u_pattern was not found in Configuration A"
}
update_design -cell u_pattern -black_box
lock_design -level routing
write_checkpoint -force $static
close_project

# Populate the frozen static shell with RM-B and implement only the dynamic area.
open_checkpoint $static
read_checkpoint -cell u_pattern -strict $rmB
opt_design
place_design
route_design
write_checkpoint -force "$out/routed.dcp"
write_checkpoint -force -cell u_pattern "$out/pattern_lfsr_routed.dcp"
report_timing_summary -file "$out/timing_summary.rpt"
report_drc -file "$out/drc.rpt"
close_project
puts "[DFX] Configuration B complete: $out/routed.dcp"
