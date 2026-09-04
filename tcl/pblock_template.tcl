# Apply after the implemented design is open and u_pattern exists.
# The clock-region location is the one shown in the supplied lab. Confirm it
# visually on your exact board/project before committing the floorplan.
set rp [get_cells u_pattern]
set_property HD.RECONFIGURABLE 1 $rp

if {[llength [get_pblocks pblock_u_pattern]] == 0} {
    create_pblock pblock_u_pattern
}
resize_pblock [get_pblocks pblock_u_pattern] -add {CLOCKREGION_X1Y2:CLOCKREGION_X1Y2}
add_cells_to_pblock [get_pblocks pblock_u_pattern] $rp
set_property CONTAIN_ROUTING true [get_pblocks pblock_u_pattern]
set_property SNAP_TO_GRID true [get_pblocks pblock_u_pattern]

report_drc -ruledeck methodology_checks -file pblock_methodology_drc.rpt
