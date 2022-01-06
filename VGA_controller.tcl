# Copyright (C) 2017  Intel Corporation. All rights reserved.
# Your use of Intel Corporation's design tools, logic functions 
# and other software and tools, and its AMPP partner logic 
# functions, and any output files from any of the foregoing 
# (including device programming or simulation files), and any 
# associated documentation or information are expressly subject 
# to the terms and conditions of the Intel Program License 
# Subscription Agreement, the Intel Quartus Prime License Agreement,
# the Intel MegaCore Function License Agreement, or other 
# applicable license agreement, including, without limitation, 
# that your use is for the sole purpose of programming logic 
# devices manufactured by Intel and sold by Intel or its 
# authorized distributors.  Please refer to the applicable 
# agreement for further details.

# Quartus Prime: Generate Tcl File for Project
# File: VGA_controller.tcl
# Generated on: Fri Dec 24 14:05:53 2021

# Load Quartus Prime Tcl Project package
package require ::quartus::project

set need_to_close_project 0
set make_assignments 1

# Check that the right project is open
if {[is_project_open]} {
	if {[string compare $quartus(project) "VGA_controller"]} {
		puts "Project VGA_controller is not open"
		set make_assignments 0
	}
} else {
	# Only open if not already open
	if {[project_exists VGA_controller]} {
		project_open -revision VGA_controller VGA_controller
	} else {
		project_new -revision VGA_controller VGA_controller
	}
	set need_to_close_project 1
}

# Make assignments
if {$make_assignments} {
	set_global_assignment -name FAMILY "Cyclone V"
	set_global_assignment -name DEVICE 5CSEMA5F31C6
	set_global_assignment -name TOP_LEVEL_ENTITY VGA_driver
	set_global_assignment -name ORIGINAL_QUARTUS_VERSION 17.0.0
	set_global_assignment -name PROJECT_CREATION_TIME_DATE "14:23:42  NOVEMBER 15, 2021"
	set_global_assignment -name LAST_QUARTUS_VERSION "17.0.0 Lite Edition"
	set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
	set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0
	set_global_assignment -name MAX_CORE_JUNCTION_TEMP 85
	set_global_assignment -name ERROR_CHECK_FREQUENCY_DIVISOR "-1"
	set_global_assignment -name EDA_SIMULATION_TOOL "ModelSim-Altera (Verilog)"
	set_global_assignment -name EDA_TIME_SCALE "1 ps" -section_id eda_simulation
	set_global_assignment -name EDA_OUTPUT_DATA_FORMAT "VERILOG HDL" -section_id eda_simulation
	set_global_assignment -name VHDL_FILE VGA_controller.vhd
	set_global_assignment -name VHDL_FILE char_library.vhd
	set_global_assignment -name VHDL_FILE BUFFER.vhd
	set_global_assignment -name QIP_FILE clock_divider.qip
	set_global_assignment -name SIP_FILE clock_divider.sip
	set_global_assignment -name VHDL_FILE VGA_driver.vhd
	set_global_assignment -name POWER_PRESET_COOLING_SOLUTION "23 MM HEAT SINK WITH 200 LFPM AIRFLOW"
	set_global_assignment -name POWER_BOARD_THERMAL_MODEL "NONE (CONSERVATIVE)"
	set_global_assignment -name VHDL_FILE sync_controller.vhd
	set_global_assignment -name PARTITION_NETLIST_TYPE SOURCE -section_id Top
	set_global_assignment -name PARTITION_FITTER_PRESERVATION_LEVEL PLACEMENT_AND_ROUTING -section_id Top
	set_global_assignment -name PARTITION_COLOR 16764057 -section_id Top
	set_global_assignment -name PROJECT_IP_REGENERATION_POLICY ALWAYS_REGENERATE_IP
	set_global_assignment -name SOURCE_FILE clock_divider.cmp
	set_location_assignment PIN_F10 -to BLANK
	set_location_assignment PIN_B11 -to H_SYNC
	set_location_assignment PIN_AF14 -to I_CLK
	set_location_assignment PIN_V16 -to O_locked
	set_location_assignment PIN_J14 -to OutputBlue
	set_location_assignment PIN_E11 -to OutputGreen
	set_location_assignment PIN_F13 -to OutputRed
	set_location_assignment PIN_AA14 -to RST
	set_location_assignment PIN_D11 -to V_SYNC
	set_location_assignment PIN_A11 -to O_CLK
	set_location_assignment PIN_AB12 -to I_READ
	set_instance_assignment -name PARTITION_HIERARCHY root_partition -to | -section_id Top

	# Commit assignments
	export_assignments

	# Close project
	if {$need_to_close_project} {
		project_close
	}
}
