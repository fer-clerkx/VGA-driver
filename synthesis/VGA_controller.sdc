## Generated SDC file "Test_bench.out.sdc"

## Copyright (C) 2017  Intel Corporation. All rights reserved.
## Your use of Intel Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Intel Program License 
## Subscription Agreement, the Intel Quartus Prime License Agreement,
## the Intel MegaCore Function License Agreement, or other 
## applicable license agreement, including, without limitation, 
## that your use is for the sole purpose of programming logic 
## devices manufactured by Intel and sold by Intel or its 
## authorized distributors.  Please refer to the applicable 
## agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 17.0.0 Build 595 04/25/2017 SJ Lite Edition"

## DATE    "Sun Jan 09 01:42:12 2022"

##
## DEVICE  "5CSEMA5F31C6"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {I_CLK} -period 20.000 -waveform { 0.000 10.000 } [get_ports { I_CLK }]


#**************************************************************
# Create Generated Clock
#**************************************************************

derive_pll_clocks


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {I_CLK}] -rise_to [get_clocks {I_CLK}] -setup 0.170  
set_clock_uncertainty -rise_from [get_clocks {I_CLK}] -rise_to [get_clocks {I_CLK}] -hold 0.060  
set_clock_uncertainty -rise_from [get_clocks {I_CLK}] -fall_to [get_clocks {I_CLK}] -setup 0.170  
set_clock_uncertainty -rise_from [get_clocks {I_CLK}] -fall_to [get_clocks {I_CLK}] -hold 0.060  
set_clock_uncertainty -fall_from [get_clocks {I_CLK}] -rise_to [get_clocks {I_CLK}] -setup 0.170  
set_clock_uncertainty -fall_from [get_clocks {I_CLK}] -rise_to [get_clocks {I_CLK}] -hold 0.060  
set_clock_uncertainty -fall_from [get_clocks {I_CLK}] -fall_to [get_clocks {I_CLK}] -setup 0.170  
set_clock_uncertainty -fall_from [get_clocks {I_CLK}] -fall_to [get_clocks {I_CLK}] -hold 0.060  


#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

