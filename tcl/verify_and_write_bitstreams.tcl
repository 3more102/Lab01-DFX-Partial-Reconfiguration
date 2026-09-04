# Verify routed configurations, then generate full and partial bitstreams.
set root [file normalize [file dirname [info script]]/..]
set a "$root/build/config_a/routed.dcp"
set b "$root/build/config_b/routed.dcp"
set bits "$root/build/bitstreams"
file mkdir $bits

if {![file exists $a]} { error "Missing $a" }
if {![file exists $b]} { error "Missing $b" }

# AMD UG909 requires comparing two routed DCPs; do not generate bitstreams
# unless the static logic is verified compatible.
pr_verify -full_check $a $b -file "$bits/pr_verify.log"

open_checkpoint $a
write_bitstream -force -no_partial_bitfile "$bits/full_chaser.bit"
write_bitstream -force -cell u_pattern "$bits/partial_chaser.bit"
close_project

open_checkpoint $b
write_bitstream -force -no_partial_bitfile "$bits/full_lfsr.bit"
write_bitstream -force -cell u_pattern "$bits/partial_lfsr.bit"
close_project

puts "[DFX] Bitstreams generated in $bits"
