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
# Generated on: Wed Jan 19 00:43:02 2022

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
	set_global_assignment -name ORIGINAL_QUARTUS_VERSION 17.0.0
	set_global_assignment -name PROJECT_CREATION_TIME_DATE "16:25:21  DECEMBER 23, 2021"
	set_global_assignment -name LAST_QUARTUS_VERSION "17.0.0 Lite Edition"
	set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
	set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0
	set_global_assignment -name MAX_CORE_JUNCTION_TEMP 85
	set_global_assignment -name ERROR_CHECK_FREQUENCY_DIVISOR 256
	set_global_assignment -name EDA_SIMULATION_TOOL "ModelSim-Altera (VHDL)"
	set_global_assignment -name EDA_TIME_SCALE "1 ps" -section_id eda_simulation
	set_global_assignment -name EDA_OUTPUT_DATA_FORMAT VHDL -section_id eda_simulation
	set_global_assignment -name PROJECT_IP_REGENERATION_POLICY ALWAYS_REGENERATE_IP
	set_global_assignment -name POWER_PRESET_COOLING_SOLUTION "23 MM HEAT SINK WITH 200 LFPM AIRFLOW"
	set_global_assignment -name POWER_BOARD_THERMAL_MODEL "NONE (CONSERVATIVE)"
	set_global_assignment -name VHDL_INPUT_VERSION VHDL_2008
	set_global_assignment -name VHDL_SHOW_LMF_MAPPING_MESSAGES OFF
	set_global_assignment -name TIMEQUEST_MULTICORNER_ANALYSIS ON
	set_global_assignment -name NUM_PARALLEL_PROCESSORS ALL
	set_global_assignment -name SOURCE_FILE PLL.cmp
	set_global_assignment -name SDC_FILE VGA_controller.sdc
	set_global_assignment -name VHDL_FILE video_controller.vhd
	set_global_assignment -name VHDL_FILE sync_controller.vhd
	set_global_assignment -name VHDL_FILE PLL.vhd -library PLL
	set_global_assignment -name VHDL_FILE char_library.vhd
	set_global_assignment -name VHDL_FILE char_buffer.vhd
	set_global_assignment -name QIP_FILE PLL.qip
	set_global_assignment -name SIP_FILE PLL.sip
	set_global_assignment -name VHDL_FILE VGA_controller.vhd
	set_global_assignment -name PARTITION_NETLIST_TYPE SOURCE -section_id Top
	set_global_assignment -name PARTITION_FITTER_PRESERVATION_LEVEL PLACEMENT_AND_ROUTING -section_id Top
	set_global_assignment -name PARTITION_COLOR 16764057 -section_id Top
	set_location_assignment PIN_AF14 -to I_CLK
	set_location_assignment PIN_A11 -to O_CLK
	set_location_assignment PIN_AA14 -to I_RST
	set_location_assignment PIN_F10 -to O_BLANK
	set_location_assignment PIN_V16 -to O_LOCKED
	set_location_assignment PIN_B11 -to O_H
	set_location_assignment PIN_D11 -to O_V
	set_location_assignment PIN_B13 -to O_BLUE[0]
	set_location_assignment PIN_G13 -to O_BLUE[1]
	set_location_assignment PIN_H13 -to O_BLUE[2]
	set_location_assignment PIN_F14 -to O_BLUE[3]
	set_location_assignment PIN_H14 -to O_BLUE[4]
	set_location_assignment PIN_F15 -to O_BLUE[5]
	set_location_assignment PIN_G15 -to O_BLUE[6]
	set_location_assignment PIN_J14 -to O_BLUE[7]
	set_location_assignment PIN_J9 -to O_GREEN[0]
	set_location_assignment PIN_J10 -to O_GREEN[1]
	set_location_assignment PIN_H12 -to O_GREEN[2]
	set_location_assignment PIN_G10 -to O_GREEN[3]
	set_location_assignment PIN_G11 -to O_GREEN[4]
	set_location_assignment PIN_G12 -to O_GREEN[5]
	set_location_assignment PIN_F11 -to O_GREEN[6]
	set_location_assignment PIN_E11 -to O_GREEN[7]
	set_location_assignment PIN_A13 -to O_RED[0]
	set_location_assignment PIN_C13 -to O_RED[1]
	set_location_assignment PIN_E13 -to O_RED[2]
	set_location_assignment PIN_B12 -to O_RED[3]
	set_location_assignment PIN_C12 -to O_RED[4]
	set_location_assignment PIN_D12 -to O_RED[5]
	set_location_assignment PIN_E12 -to O_RED[6]
	set_location_assignment PIN_F13 -to O_RED[7]
	set_location_assignment PIN_W15 -to I_INPUT[1]
	set_location_assignment PIN_AA15 -to I_INPUT[0]
	set_location_assignment PIN_AC12 -to I_INPUT[3]
	set_location_assignment PIN_AF9 -to I_INPUT[4]
	set_location_assignment PIN_AF10 -to I_INPUT[5]
	set_location_assignment PIN_AD11 -to I_INPUT[6]
	set_location_assignment PIN_AD12 -to I_INPUT[7]
	set_location_assignment PIN_AE11 -to I_INPUT[8]
	set_location_assignment PIN_AC9 -to I_INPUT[9]
	set_location_assignment PIN_AD10 -to I_INPUT[10]
	set_location_assignment PIN_AE12 -to I_INPUT[11]
	set_location_assignment PIN_AB12 -to I_INPUT[2]
	set_instance_assignment -name PARTITION_HIERARCHY root_partition -to | -section_id Top

	# Commit assignments
	export_assignments

	# Close project
	if {$need_to_close_project} {
		project_close
	}
}
