# build_project.tcl - Build Vivado project (synthesis, implementation, bitstream)

# Parse command line arguments
if {$argc < 1} {
    puts "Usage: vivado -mode batch -source build_project.tcl -tclargs <project_name>"
    exit 1
}

set project_name [lindex $argv 0]

# Open project
puts "Opening project: $project_name"
open_project project/$project_name/$project_name.xpr

# Reset runs to ensure clean build
reset_run synth_1
reset_run impl_1

# Launch synthesis
puts "Running synthesis..."
launch_runs synth_1 -jobs 4
wait_on_run synth_1

# Check synthesis results
if {[get_property PROGRESS [get_runs synth_1]] != "100%"} {
    puts "ERROR: Synthesis failed!"
    exit 1
}

# Launch implementation
puts "Running implementation..."
launch_runs impl_1 -jobs 4
wait_on_run impl_1

# Check implementation results
if {[get_property PROGRESS [get_runs impl_1]] != "100%"} {
    puts "ERROR: Implementation failed!"
    exit 1
}

# Generate bitstream
puts "Generating bitstream..."
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1

# Report utilization and timing
puts "Generating reports..."
open_run impl_1
report_utilization -file project/$project_name/${project_name}_utilization.rpt
report_timing_summary -file project/$project_name/${project_name}_timing_summary.rpt

puts "Build completed successfully!"
puts "Bitstream: project/$project_name/$project_name.runs/impl_1/*.bit"

# Close project
close_project
