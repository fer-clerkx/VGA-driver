# Self checking testbench for the VGA timing module.
# This testbench checks the external behaviour for every
# relevant edge case.
# To run: include VGA_timing_tb.vhd, VGA_timing.vhd and 
# VGA_char_pkg.vhd in a ModelSim project and compile.
# Type the following command in the ModelSim terminal:
# "source <PATH_TO_THIS_FILE>" to run the script
# The last message printed indicates if the module works correctly

namespace eval ::VGATimingTB {

	# Load the simulation
	vsim -onfinish stop work.VGA_timing_tb -t fs

	# Load the waveform
	if {[file exists wave.do]} {
		do wave.do
	}

	# Read the clock period constant from the VHDL TB
	variable clockPeriod [examine c_CLK_PERIOD]

	# Strip the braces: "{10 ns}" => "10 ns"
	variable clockPeriod [string trim $clockPeriod "{}"]

	# Split the number and the time unit
	variable timeUnits [lindex $clockPeriod 1]
	variable clockPeriod [lindex $clockPeriod 0]

	# This will get incremented on every error
	variable errorCount 0

	# Read the pixel timing from the VHDL constants
	variable hActive [examine VGA_Char_Pkg.c_H_ACTIVE]
	variable hFP [examine VGA_Char_Pkg.c_H_FP]
	variable hSP [examine VGA_Char_Pkg.c_H_SP]
	variable hBP [examine VGA_Char_Pkg.c_H_BP]
	variable hTotal [examine VGA_Char_Pkg.c_H_TOTAL]
  
	variable vActive [examine VGA_Char_Pkg.c_V_ACTIVE]
	variable vFP [examine VGA_Char_Pkg.c_V_FP]
	variable vSP [examine VGA_Char_Pkg.c_V_SP]
	variable vBP [examine VGA_Char_Pkg.c_V_BP]
	variable vTotal [examine VGA_Char_Pkg.c_V_TOTAL]

	variable hPol [examine VGA_Char_Pkg.c_H_POL]
	variable vPol [examine VGA_Char_Pkg.c_V_POL]
	variable blankPol [examine VGA_Char_Pkg.c_BLANK_POL]

	# Timestamp and print to the transcript window
	proc printMsg { msg } {
		global now
		variable timeUnits
		echo $now $timeUnits: $msg
	}

	proc runClockCycles { count } {
		variable clockPeriod
		variable timeUnits

		set t [expr {$clockPeriod * $count}]
		run $t $timeUnits
	}

	proc checkSignal { signalName expectedVal } {
		variable errorCount

		set val [examine $signalName]
		if {$val != $expectedVal} {
			printMsg "ERROR: $signalName=$val (expected=$expectedVal)"
			incr errorCount
		}
	}

	proc checkRdAddress { hVal vVal } {
		variable errorCount
		variable hActive
		set correctAddr [expr $hVal + $vVal*$hActive]
		set correctbAddr [dec2bin $correctAddr 19]
		set DUTAddr [examine Rd_Addr]
		if {$DUTAddr != $correctbAddr} {
			printMsg "ERROR: Rd_Addr=$DUTAddr (expected=$correctbAddr)"
			incr errorCount
		}
	}

	proc dec2bin {i {width {}}} {
		set res {}
		if {$i<0} {
			set sign -
			set i [expr {abs($i)}]
		} else {
			set sign {}
		}

		while {$i>0} {
			set res [expr {$i%2}]$res
			set i [expr {$i/2}]
		}

		if {$res eq {}} {set res 0}

		if {$width ne {}} {
			append d [string repeat 0 $width] $res
			set res [string range $d [string length $res] end]
		}
		return $sign$res
	}

	# Function handles signal polarity, 1 is active, 0 is inactive
	proc checkPorts { expectedBlankValue expectedHValue expectedVValue expectedEnableValue } {
		variable hPol
		variable vPol
		variable blankPol
		if { $expectedHValue == 1 } {
			checkSignal H_Sync $hPol
		} else {
			checkSignal H_Sync [expr !$hPol]
		}
		if { $expectedVValue == 1 } {
			checkSignal V_Sync $vPol
		} else {
			checkSignal V_Sync [expr !$vPol]
		}
		if { $expectedBlankValue == 1 } {
			checkSignal Blank $blankPol
		} else {
			checkSignal Blank [expr !$blankPol]
		}
		checkSignal Rd_En $expectedEnableValue
	}

	# Initialize testbench
	force Rst 0
	run -all

	# Case #1: first active pixel, first active line
	printMsg "Case #1: first active pixel, first active line"
	checkPorts 1 0 0 1
	checkRdAddress 0 0

	# Case #2: second active pixel, first active line
	printMsg "Case #2: second active pixel, first active line"
	runClockCycles 1
	checkPorts 0 0 0 1
	checkRdAddress 1 0

	# Case #3: last active pixel, first active line
	printMsg "Case #3: last active pixel, first active line"
	runClockCycles [expr $hActive-2]
	checkPorts 0 0 0 1
	checkRdAddress [expr $hActive-1] 0

	# Case #4: first FP pixel, first active line
	printMsg "Case #4: first FP pixel, first active line"
	runClockCycles 1
	checkPorts 0 0 0 0

	# Case #5: second FP pixel, first active line
	printMsg "Case #5: second FP pixel, first active line"
	runClockCycles 1
	checkPorts 1 0 0 0

	# Case #6: first sync pixel, first active line
	printMsg "Case #6: first sync pixel, first active line"
	runClockCycles [expr $hFP-1]
	checkPorts 1 0 0 0

	# Case #7: second sync pixel, first active line
	printMsg "Case #7: second sync pixel, first active line"
	runClockCycles 1
	checkPorts 1 1 0 0

	# Case #8: first BP pixel, first active line
	printMsg "Case #8: first BP pixel, first active line"
	runClockCycles [expr $hSP-1]
	checkPorts 1 1 0 0

	# Case #9: second BP pixel, first active line
	printMsg "Case #9: second BP pixel, first active line"
	runClockCycles 1
	checkPorts 1 0 0 0

	# Case #10: last BP pixel, first active line
	printMsg "Case #10: last BP pixel, first active line"
	runClockCycles [expr $hBP-2]
	checkPorts 1 0 0 0


	# Case #11: first active pixel, last active line
	printMsg "Case #11: first active pixel, last active line"
	runClockCycles [expr $hTotal * [expr $vActive-2] + 1]
	checkPorts 1 0 0 1
	checkRdAddress 0 [expr $vActive-1]

	# Case #12: second active pixel, last active line
	printMsg "Case #12: second active pixel, last active line"
	runClockCycles 1
	checkPorts 0 0 0 1
	checkRdAddress 1 [expr $vActive-1]

	# Case #13: last active pixel, last active line
	printMsg "Case #13: last active pixel, last active line"
	runClockCycles [expr $hActive-2]
	checkPorts 0 0 0 1
	checkRdAddress [expr $hActive-1] [expr $vActive-1]

	# Case #14: first FP pixel, last active line
	printMsg "Case #14: first FP pixel, last active line"
	runClockCycles 1
	checkPorts 0 0 0 0

	# Case #15: second FP pixel, last active line
	printMsg "Case #15: second FP pixel, last active line"
	runClockCycles 1
	checkPorts 1 0 0 0

	# Case #16: first sync pixel, last active line
	printMsg "Case #16: first sync pixel, last active line"
	runClockCycles [expr $hFP-1]
	checkPorts 1 0 0 0

	# Case #17: second sync pixel, last active line
	printMsg "Case #17: second sync pixel, last active line"
	runClockCycles 1
	checkPorts 1 1 0 0

	# Case #18: first BP pixel, last active line
	printMsg "Case #18: first BP pixel, last active line"
	runClockCycles [expr $hSP-1]
	checkPorts 1 1 0 0

	# Case #19: second BP pixel, last active line
	printMsg "Case #19: second BP pixel, last active line"
	runClockCycles 1
	checkPorts 1 0 0 0

	# Case #20: last BP pixel, last active line
	printMsg "Case #20: last BP pixel, last active line"
	runClockCycles [expr $hBP-2]
	checkPorts 1 0 0 0


	# Case #21: first active pixel, first FP line
	printMsg "Case #21: first active pixel, first FP line"
	runClockCycles 1
	checkPorts 1 0 0 0

	# Case #22: second active pixel, first FP line
	printMsg "Case #22: second active pixel, first FP line"
	runClockCycles 1
	checkPorts 1 0 0 0

	# Case #23: first sync pixel, first FP line
	printMsg "Case #23: first sync pixel, first FP line"
	runClockCycles [expr $hActive+$hFP-1]
	checkPorts 1 0 0 0

	# Case #24: second sync pixel, first FP line
	printMsg "Case #24: second sync pixel, first FP line"
	runClockCycles 1
	checkPorts 1 1 0 0

	# Case #25: first BP pixel, first FP line
	printMsg "Case #25: first BP pixel, first FP line"
	runClockCycles [expr $hSP-1]
	checkPorts 1 1 0 0

	# Case #26: second BP pixel, first FP line
	printMsg "Case #26: second BP pixel, first FP line"
	runClockCycles 1
	checkPorts 1 0 0 0


	# Case #27: first active pixel, first sync line
	printMsg "Case #27: first active pixel, first sync line"
	runClockCycles [expr $hBP-1 + $hTotal*[expr $vFP-1]]
	checkPorts 1 0 0 0

	# Case #28: second active pixel, first sync line
	printMsg "Case #28: second active pixel, first sync line"
	runClockCycles 1
	checkPorts 1 0 1 0

	# Case #29: first sync pixel, first sync line
	printMsg "Case #29: first sync pixel, first sync line"
	runClockCycles [expr $hActive + $hFP - 1]
	checkPorts 1 0 1 0

	# Case #30: second sync pixel, first sync line
	printMsg "Case #30: second sync pixel, first sync line"
	runClockCycles 1
	checkPorts 1 1 1 0

	# Case #31: first BP pixel, first sync line
	printMsg "Case #31: first BP pixel, first sync line"
	runClockCycles [expr $hSP-1]
	checkPorts 1 1 1 0

	# Case #32: second BP pixel, first sync line
	printMsg "Case #32: second BP pixel, first sync line"
	runClockCycles 1
	checkPorts 1 0 1 0


	# Case #33: first active pixel, first BP line
	printMsg "Case #33: first active pixel, first BP line"
	runClockCycles [expr $hBP-1 + $hTotal*[expr $vSP-1]]
	checkPorts 1 0 1 0

	# Case #34: second active pixel, first BP line
	printMsg "Case #34: second active pixel, first BP line"
	runClockCycles 1
	checkPorts 1 0 0 0

	# Case #35: first sync pixel, first BP line
	printMsg "Case #35: first sync pixel, first BP line"
	runClockCycles [expr $hActive+$hFP-1]
	checkPorts 1 0 0 0

	# Case #36: second sync pixel, first BP line
	printMsg "Case #36: second sync pixel, first BP line"
	runClockCycles 1
	checkPorts 1 1 0 0

	# Case #37: first BP pixel, first BP line
	printMsg "Case #37: first BP pixel, first BP line"
	runClockCycles [expr $hSP-1]
	checkPorts 1 1 0 0

	# Case #38: second BP pixel, first BP line
	printMsg "Case #38: second BP pixel, first BP line"
	runClockCycles 1
	checkPorts 1 0 0 0


	# Case #39: last BP pixel, last BP line
	printMsg "Case #39: last BP pixel, last BP line"
	runClockCycles [expr $hBP-2 + $hTotal*[expr $vBP-1]]
	checkPorts 1 0 0 0


	# Case 40: reset test, maximum address
	printMsg "Case 40: reset test, maximum address"
	runClockCycles [expr $hTotal*$vActive-1]
	force Rst 1
	runClockCycles 1
	force Rst 0
	checkRdAddress 0 0

	if { $errorCount == 0 } {
		printMsg "Test: OK"
	} else {
		printMsg "Test: Failure ($errorCount errors)"
	}
}