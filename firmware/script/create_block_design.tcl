# create_block_design.tcl - Create Zynq Ultrascale+ MPSoC block design

proc create_mpsoc_block_design {bd_name} {
    # Create block design
    create_bd_design $bd_name
    
    # Add Zynq UltraScale+ MPSoC
    set zynq_mpsoc [create_bd_cell -type ip -vlnv xilinx.com:ip:zynq_ultra_ps_e:3.5 zynq_ultra_ps_e_0]
    
    # Configure PS with common settings
    set_property -dict [list \
        CONFIG.PSU__USE__M_AXI_GP0 {1} \
        CONFIG.PSU__USE__M_AXI_GP1 {0} \
        CONFIG.PSU__USE__M_AXI_GP2 {0} \
        CONFIG.PSU__USE__S_AXI_GP0 {0} \
        CONFIG.PSU__USE__S_AXI_GP1 {0} \
        CONFIG.PSU__USE__S_AXI_GP2 {0} \
        CONFIG.PSU__USE__S_AXI_GP3 {0} \
        CONFIG.PSU__USE__S_AXI_GP4 {0} \
        CONFIG.PSU__USE__S_AXI_GP5 {0} \
        CONFIG.PSU__USE__S_AXI_GP6 {0} \
        CONFIG.PSU__CRL_APB__PL0_REF_CTRL__FREQMHZ {100} \
        CONFIG.PSU__FPGA_PL0_ENABLE {1} \
        CONFIG.PSU__GPIO_EMIO__PERIPHERAL__ENABLE {1} \
        CONFIG.PSU__NUM_FABRIC_RESETS {1} \
    ] $zynq_mpsoc
    
    # Create AXI interconnect for PL connectivity
    set axi_interconnect [create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_0]
    set_property -dict [list CONFIG.NUM_SI {1} CONFIG.NUM_MI {1}] $axi_interconnect
    
    # Add processing system reset
    set ps_reset [create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_0]
    
    # Connect clocks
    connect_bd_net [get_bd_pins $zynq_mpsoc/pl_clk0] [get_bd_pins $axi_interconnect/ACLK]
    connect_bd_net [get_bd_pins $zynq_mpsoc/pl_clk0] [get_bd_pins $axi_interconnect/S00_ACLK]
    connect_bd_net [get_bd_pins $zynq_mpsoc/pl_clk0] [get_bd_pins $axi_interconnect/M00_ACLK]
    connect_bd_net [get_bd_pins $zynq_mpsoc/pl_clk0] [get_bd_pins $ps_reset/slowest_sync_clk]
    
    # Connect resets
    connect_bd_net [get_bd_pins $zynq_mpsoc/pl_resetn0] [get_bd_pins $ps_reset/ext_reset_in]
    connect_bd_net [get_bd_pins $ps_reset/peripheral_aresetn] [get_bd_pins $axi_interconnect/ARESETN]
    connect_bd_net [get_bd_pins $ps_reset/peripheral_aresetn] [get_bd_pins $axi_interconnect/S00_ARESETN]
    connect_bd_net [get_bd_pins $ps_reset/peripheral_aresetn] [get_bd_pins $axi_interconnect/M00_ARESETN]
    
    # Connect PS master to interconnect
    connect_bd_intf_net [get_bd_intf_pins $zynq_mpsoc/M_AXI_HPM0_FPD] [get_bd_intf_pins $axi_interconnect/S00_AXI]
    
    # Create example AXI GPIO for testing
    set axi_gpio [create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_0]
    set_property -dict [list CONFIG.C_GPIO_WIDTH {8} CONFIG.C_ALL_OUTPUTS {1}] $axi_gpio
    
    # Connect GPIO to interconnect
    connect_bd_intf_net [get_bd_intf_pins $axi_interconnect/M00_AXI] [get_bd_intf_pins $axi_gpio/S_AXI]
    connect_bd_net [get_bd_pins $zynq_mpsoc/pl_clk0] [get_bd_pins $axi_gpio/s_axi_aclk]
    connect_bd_net [get_bd_pins $zynq_mpsoc/pl_clk0] [get_bd_pins $zynq_mpsoc/maxihpm0_fpd_aclk]
    connect_bd_net [get_bd_pins $ps_reset/peripheral_aresetn] [get_bd_pins $axi_gpio/s_axi_aresetn]
    
    # Make GPIO external
    create_bd_port -dir O -from 7 -to 0 gpio_out
    connect_bd_net [get_bd_pins $axi_gpio/gpio_io_o] [get_bd_ports gpio_out]
    
    # Assign addresses
    assign_bd_address
    
    # Validate design
    validate_bd_design
    
    # Save block design
    save_bd_design
    
    puts "Block design created successfully!"
}
 
