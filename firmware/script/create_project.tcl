# create_project.tcl - Create Vivado project for Zynq Ultrascale+ MPSoC

# Parse command line arguments
if {$argc < 5} {
    puts "Usage: vivado -mode batch -source create_project.tcl -tclargs <project_name> <part> <board> <rtl_dir> <constr_dir>"
    exit 1
}

set project_name [lindex $argv 0]
set part [lindex $argv 1]
set board [lindex $argv 2]
set rtl_dir [lindex $argv 3]
set constr_dir [lindex $argv 4]

# Create project
puts "Creating project: $project_name"
create_project $project_name project/$project_name -part $part -force

# Set board if specified
if {$board ne ""} {
    set_property board_part $board [current_project]
}

# Add RTL sources (link, don't copy)
puts "Adding RTL sources from $rtl_dir"
set rtl_files [glob -nocomplain $rtl_dir/*.v $rtl_dir/*.sv $rtl_dir/*.vhd]
if {[llength $rtl_files] > 0} {
    add_files -norecurse $rtl_files
}

# Add constraint files (link, don't copy)
puts "Adding constraints from $constr_dir"
set xdc_files [glob -nocomplain $constr_dir/*.xdc]
if {[llength $xdc_files] > 0} {
    add_files -fileset constrs_1 -norecurse $xdc_files
}

# Create block design
puts "Creating block design..."
source ../script/create_block_design.tcl
create_mpsoc_block_design $project_name

# Generate wrapper for block design
set bd_file [get_files -of_objects [get_filesets sources_1] *.bd]
if {$bd_file ne ""} {
    puts "Generating HDL wrapper for block design"
    make_wrapper -files $bd_file -top
    set wrapper_file [get_files -of_objects [get_filesets sources_1] *_wrapper.v]
    if {$wrapper_file eq ""} {
        set wrapper_file [get_files -of_objects [get_filesets sources_1] *_wrapper.vhd]
    }
    add_files -norecurse $wrapper_file
    set_property top [file rootname [file tail $wrapper_file]] [current_fileset]
    update_compile_order -fileset sources_1
}

# Save project
puts "Saving project..."
save_project_as $project_name project/$project_name -force

puts "Project created successfully!"
