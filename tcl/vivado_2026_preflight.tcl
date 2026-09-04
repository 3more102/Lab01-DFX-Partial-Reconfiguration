# Vivado 2026.x preflight for the ZCU102 DFX lab.
# Checks the installed device, ZCU102 board files, and DFX Decoupler IP before
# project creation so version/installation issues fail early and clearly.

puts "=== Lab01 DFX Vivado Preflight ==="
puts "Vivado version: [version -short]"

set required_part xczu9eg-ffvb1156-2-e
set failures 0

if {[llength [get_parts -quiet $required_part]]} {
    puts "PASS: Device part available: $required_part"
} else {
    puts "FAIL: Device part missing: $required_part"
    incr failures
}

set boards [get_board_parts -quiet *zcu102*]
if {[llength $boards]} {
    puts "PASS: ZCU102 board definition(s) found:"
    foreach b $boards { puts "  $b" }
} else {
    puts "FAIL: No ZCU102 board definition found."
    incr failures
}

set dfx_decouplers [get_ipdefs -all -quiet *dfx_decoupler*]
if {[llength $dfx_decouplers]} {
    puts "PASS: DFX Decoupler IP found:"
    foreach ip $dfx_decouplers { puts "  $ip" }
} else {
    puts "FAIL: DFX Decoupler IP is unavailable in the installed IP catalog."
    incr failures
}

# These core commands are the project-independent pieces used later in the lab.
foreach cmd {create_pblock resize_pblock update_design lock_design read_checkpoint write_checkpoint pr_verify write_bitstream} {
    if {[llength [info commands $cmd]]} {
        puts "PASS: Tcl command available: $cmd"
    } else {
        puts "FAIL: Tcl command unavailable: $cmd"
        incr failures
    }
}

if {$failures != 0} {
    error "Vivado DFX preflight failed with $failures issue(s). Fix the installation before continuing."
}

puts "PRECHECK PASS: Vivado installation is ready for the ZCU102 DFX lab."
