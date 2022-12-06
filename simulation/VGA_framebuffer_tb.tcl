# Self checking testbench for the VGA loader module.
# This testbench checks the external behaviour for every
# relevant edge case.
# To run: include VGA_loader_tb.vhd, VGA_loader.vhd and 
# VGA_char_pkg.vhd in a ModelSim project and compile.
# Type the following command in the ModelSim terminal:
# "source <PATH_TO_THIS_FILE>" to run the script
# The last message printed indicates if the module works correctly
# WARNING: This script will take a couple of minutes to complete

namespace eval ::VGAFramebufferTB {

	# Load the simulation
	vsim work.VGA_framebuffer_tb -t fs

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
	variable vActive [examine VGA_Char_Pkg.c_V_ACTIVE]
	variable vAddrRange [expr $hActive*$vActive-1]

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

	proc writeByte { address data } {
		force WrAddress [dec2bin $address 16]
		force Data $data
		force WrEn 1
		runClockCycles 1
		force WrEn 0
	}

	proc readBit { address expectedValue } {
		force RdAddress [dec2bin $address 19]
		force RdEn 1
		runClockCycles 1
		checkSignal q $expectedValue
		force RdEn 0
	}

	proc readByte { address expectedValue } {
		force RdEn 1
		for { set i 0 } { $i < 8 } { incr i } {
			force RdAddress [dec2bin [expr [expr $address*8]+$i] 19]
			runClockCycles 1
			checkSignal q [string index $expectedValue [expr 7-$i]] 
		}
		force RdEn 0
	}

	force WrEn 0
	force RdEn 0
	# Case #1: Check initial value
	printMsg "Case #1: Check initial value"
	readBit 0 0

	#Case #2: Write first bit
	printMsg "Case #2: Write first bit"
	writeByte 0 00000001
	readBit 0 1

	#Case #3: Write byte
	printMsg "Case #3: Write multiple bits"
	writeByte 0 10101010
	readByte 0 10101010

	#Case #4: Write byte at other address
	printMsg "Case #4: Write byte at other address"
	writeByte 4 11111111
	readByte 4 11111111

	set str 10011001010110100011011000111011
	writeByte 0 [string range $str 0 7]

	if { $errorCount == 0 } {
		printMsg "Test: OK"
	} else {
		printMsg "Test: Failure ($errorCount errors)"
	}
}