# Self checking testbench for the VGA loader module.
# This testbench checks the external behaviour for every
# relevant edge case.
# To run: include VGA_loader_tb.vhd, VGA_loader.vhd and 
# VGA_char_pkg.vhd in a ModelSim project and compile.
# Type the following command in the ModelSim terminal:
# "source <PATH_TO_THIS_FILE>" to run the script
# The last message printed indicates if the module works correctly
# WARNING: This script will take a couple of minutes to complete

namespace eval ::VGALoaderTB {

	# Load the simulation
	vsim work.VGA_loader_tb -t fs

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

	variable vPol [examine VGA_Char_Pkg.c_V_POL]

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

	proc setPorts { validValue vSyncValue } {
		variable vPol
		force valid $validValue
		if { $vSyncValue == 1 } {
			force v_sync $vPol
		} else {
			force v_sync [expr !$vPol]
		}
	}

	proc checkPorts { expectedReady expectedActive expectedEnable } {
		checkSignal ready $expectedReady
		checkSignal active $expectedActive
		checkSignal wr_en $expectedEnable
	}

	proc setReq { selVal scaleVal hVal vVal } {
		force wr_req.sel $selVal -deposit
		force wr_req.scale $scaleVal -deposit
		force wr_req.h_addr $hVal -deposit
		force wr_req.v_addr $vVal -deposit
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

	# Initialize testbench
	force rst 0
	setPorts 0 0
	setReq 0 0 0 0
	runClockCycles 1

	# Case #1: check with valid and v_sync off
	printMsg "Case #1: check with valid and v_sync off"
	checkPorts 0 1 0
	setPorts 0 0
	runClockCycles 3
	checkPorts 0 1 0

	# Case #2: check with valid off and v_sync on
	printMsg "Case #2: check with valid off and v_sync on"
	setPorts 0 1
	runClockCycles 1
	checkPorts 1 0 0
	runClockCycles 2
	checkPorts 1 0 0

	# Case #3: check with valid on and v_sync off
	printMsg "Case #3: check with valid on and v_sync off"
	setPorts 0 0
	runClockCycles 1
	checkPorts 0 1 0
	setPorts 1 0
	runClockCycles 3
	checkPorts 0 1 0

	# Case #4: check with valid and v_sync on
	printMsg "Case #4: check with valid and v_sync on"
	setPorts 0 1
	runClockCycles 1
	checkPorts 1 0 0
	setPorts 1 1
	runClockCycles 1
	setPorts 0 1
	checkPorts 0 0 0
	for { set i 0 } { $i < 10 } { incr i } {
		runClockCycles 1
		set str [examine VGA_Char_Pkg.c_LIB(0)($i)]
		if { $i == 9 } {
			checkPorts 1 0 1
		} else {
			checkPorts 0 0 1
		}
		# Acount for different bit order of c_LIB and framebuffer data port
		checkSignal wr_data [string reverse $str]
		checkSignal wr_addr [dec2bin [expr $hActive*$i/8] 16]
	}
	runClockCycles 1
	checkPorts 1 0 0

	# Case #5: check when valid stays high after handshake
	printMsg "Case #5: check when valid stays high after handshake"
	setPorts 0 1
	runClockCycles 1
	checkPorts 1 0 0
	setPorts 1 1
	setReq 1 0 3 5
	runClockCycles 1
	checkPorts 0 0 0
	for { set i 0 } { $i < 10 } { incr i } {
		runClockCycles 1
		set str [examine VGA_Char_Pkg.c_LIB(1)($i)]
		if { $i == 9 } {
			checkPorts 1 0 1
		} else {
			checkPorts 0 0 1
		}
		# Acount for different bit order of c_LIB and framebuffer data port
		checkSignal wr_data [string reverse $str]
		checkSignal wr_addr [dec2bin [expr [expr $hActive*[expr $i+5] + 0]/8] 16]
	}
	runClockCycles 1
	checkPorts 0 0 0
	setPorts 0 1
	for { set i 0 } { $i < 10 } { incr i } {
		runClockCycles 1
		set str [examine VGA_Char_Pkg.c_LIB(1)($i)]
		if { $i == 9 } {
			checkPorts 1 0 1
		} else {
			checkPorts 0 0 1
		}
		# Acount for different bit order of c_LIB and framebuffer data port
		checkSignal wr_data [string reverse $str]
		checkSignal wr_addr [dec2bin [expr [expr $hActive*[expr $i+5] + 0]/8] 16]
	}
	runClockCycles 1
	checkPorts 1 0 0

	# Case #6: check when v sync goes off during a write
	printMsg "Case #6: check when v sync goes off during a write"
	setPorts 1 1
	runClockCycles 1
	checkPorts 0 0 0
	runClockCycles 1
	checkPorts 0 0 1
	setPorts 1 0
	runClockCycles 1
	checkPorts 0 1 0
	setPorts 0 1
	runClockCycles 1
	checkPorts 1 0 0
	runClockCycles 2
	checkPorts 1 0 0

	# Case #7: check scale 1
	printMsg "Case #7: check scale 1"
	setReq 0 1 0 0
	setPorts 1 1
	runClockCycles 1
	checkPorts 0 0 0
	setPorts 0 1
	for { set i 0 } { $i < 40 } { incr i } {
		runClockCycles 1
		if { $i % 2 == 0 } {
			set str [examine VGA_Char_Pkg.c_LIB(0)([expr $i/4])(0:3)]
		} else {
			set str [examine VGA_Char_Pkg.c_LIB(0)([expr $i/4])(4:7)]
		}
		for { set j 3 } { $j > -1 } {incr j -1} {
			set str [string replace $str $j $j [string repeat [string index $str $j] 2]]
		}
		if { $i == 39 } {
			checkPorts 1 0 1
		} else {
			checkPorts 0 0 1
		}
		# Acount for different bit order of c_LIB and framebuffer data port
		checkSignal wr_data [string reverse $str]
		checkSignal wr_addr [dec2bin [expr [expr $hActive*[expr $i/2]]/8 + $i%2] 16]
	}
	runClockCycles 1
	checkPorts 1 0 0

	# Case #8: check scale 2
	printMsg "Case #8: check scale 2"
	setReq 0 2 0 0
	setPorts 1 1
	runClockCycles 1
	checkPorts 0 0 0
	setPorts 0 1
	for { set i 0 } { $i < 160 } { incr i } {
		runClockCycles 1
		switch [expr $i % 4] {
			0 {
				set str [examine VGA_Char_Pkg.c_LIB(0)([expr $i/16])(0:1)]
			}
			1 {
				set str [examine VGA_Char_Pkg.c_LIB(0)([expr $i/16])(2:3)]
			}
			2 {
				set str [examine VGA_Char_Pkg.c_LIB(0)([expr $i/16])(4:5)]
			}
			3 {
				set str [examine VGA_Char_Pkg.c_LIB(0)([expr $i/16])(6:7)]
			}
		}
		for { set j 1 } { $j > -1 } {incr j -1} {
			set str [string replace $str $j $j [string repeat [string index $str $j] 4]]
		}
		if { $i == 159 } {
			checkPorts 1 0 1
		} else {
			checkPorts 0 0 1
		}
		# Acount for different bit order of c_LIB and framebuffer data port
		checkSignal wr_data [string reverse $str]
		checkSignal wr_addr [dec2bin [expr [expr $hActive*[expr $i/4]]/8 + $i%4] 16]
	}
	runClockCycles 1
	checkPorts 1 0 0

	# Case #9: check scale 3
	printMsg "Case #9: check scale 3"
	setReq 0 3 0 0
	setPorts 1 1
	runClockCycles 1
	checkPorts 0 0 0
	setPorts 0 1
	for { set i 0 } { $i < 640 } { incr i } {
		runClockCycles 1
		set str [examine VGA_Char_Pkg.c_LIB(0)([expr $i/64])([expr $i % 8])]
		set str [string repeat $str 8]
		if { $i == 639 } {
			checkPorts 1 0 1
		} else {
			checkPorts 0 0 1
		}
		# Acount for different bit order of c_LIB and framebuffer data port
		checkSignal wr_data [string reverse $str]
		checkSignal wr_addr [dec2bin [expr [expr $hActive*[expr $i/8]]/8 + $i%8] 16]
	}
	runClockCycles 1
	checkPorts 1 0 0

	# Case #10: check that address rounds down to nearest multiple of 8 h address
	printMsg "Case #10: check that address rounds down to nearest multiple of 8 h address"
	setReq 0 0 7 0
	setPorts 1 1
	runClockCycles 1
	checkPorts 0 0 0
	setPorts 0 1
	for { set i 0 } { $i < 10 } { incr i } {
		runClockCycles 1
		set str [examine VGA_Char_Pkg.c_LIB(0)([expr $i])]
		if { $i == 9 } {
			checkPorts 1 0 1
		} else {
			checkPorts 0 0 1
		}
		# Acount for different bit order of c_LIB and framebuffer data port
		checkSignal wr_data [string reverse $str]
		checkSignal wr_addr [dec2bin [expr $hActive*$i/8] 16]
	}
	runClockCycles 1
	checkPorts 1 0 0

	# Case #11: check maximum address without going over edge of frame
	printMsg "Case #11: check maximum address without going over edge of frame"
	setReq 0 0 [expr $hActive-8] [expr $vActive-10]
	setPorts 1 1
	runClockCycles 1
	checkPorts 0 0 0
	setPorts 0 1
	for { set i 0 } { $i < 10 } { incr i } {
		runClockCycles 1
		set str [examine VGA_Char_Pkg.c_LIB(0)([expr $i])]
		if { $i == 9 } {
			checkPorts 1 0 1
		} else {
			checkPorts 0 0 1
		}
		# Acount for different bit order of c_LIB and framebuffer data port
		checkSignal wr_data [string reverse $str]
		checkSignal wr_addr [dec2bin [expr [expr $hActive*[expr $i + $vActive-10] + $hActive-8]/8] 16]
	}
	runClockCycles 1
	checkPorts 1 0 0

	# Case #12: check going over edge of frame
	printMsg "Case #12: check going over edge of frame"
	setReq 0 1 [expr $hActive-8] [expr $vActive-10]
	setPorts 1 1
	runClockCycles 1
	checkPorts 0 0 0
	setPorts 0 1
	for { set i 0 } { $i < 40 } { incr i } {
		runClockCycles 1
		if { $i % 2 == 0 } {
			set str [examine VGA_Char_Pkg.c_LIB(0)([expr $i/4])(0:3)]
		} else {
			set str [examine VGA_Char_Pkg.c_LIB(0)([expr $i/4])(4:7)]
		}
		for { set j 3 } { $j > -1 } {incr j -1} {
			set str [string replace $str $j $j [string repeat [string index $str $j] 2]]
		}
		if { $i == 39 } {
			checkPorts 1 0 1
		} else {
			checkPorts 0 0 1
		}
		if { $i < 20 } {
			set vAddress [expr $vActive - 10 + [expr $i/2]]
		} else {
			set vAddress [expr $vActive-1]
		}
		# Acount for different bit order of c_LIB and framebuffer data port
		checkSignal wr_data [string reverse $str]
		checkSignal wr_addr [dec2bin [expr [expr $hActive*$vAddress + $hActive-8]/8] 16]
	}
	runClockCycles 1
	checkPorts 1 0 0

	# Case #13: check reset
	printMsg "Case #13: check reset"
	setReq 0 1 0 0
	setPorts 1 1
	runClockCycles 1
	checkPorts 0 0 0
	setPorts 0 1
	for { set i 0 } { $i < 20 } { incr i } {
		runClockCycles 1
		if { $i % 2 == 0 } {
			set str [examine VGA_Char_Pkg.c_LIB(0)([expr $i/4])(0:3)]
		} else {
			set str [examine VGA_Char_Pkg.c_LIB(0)([expr $i/4])(4:7)]
		}
		for { set j 3 } { $j > -1 } {incr j -1} {
			set str [string replace $str $j $j [string repeat [string index $str $j] 2]]
		}
		if { $i == 39 } {
			checkPorts 1 0 1
		} else {
			checkPorts 0 0 1
		}
		# Acount for different bit order of c_LIB and framebuffer data port
		checkSignal wr_data [string reverse $str]
		checkSignal wr_addr [dec2bin [expr [expr $hActive*[expr $i/2]]/8 + $i%2] 16]
	}
	force rst 1
	runClockCycles 1
	checkPorts 0 0 0
	force rst 0
	runClockCycles 1
	checkPorts 1 0 0
	setPorts 1 1
	runClockCycles 1
	checkPorts 0 0 0
	setPorts 0 1
	for { set i 0 } { $i < 40 } { incr i } {
		runClockCycles 1
		if { $i % 2 == 0 } {
			set str [examine VGA_Char_Pkg.c_LIB(0)([expr $i/4])(0:3)]
		} else {
			set str [examine VGA_Char_Pkg.c_LIB(0)([expr $i/4])(4:7)]
		}
		for { set j 3 } { $j > -1 } {incr j -1} {
			set str [string replace $str $j $j [string repeat [string index $str $j] 2]]
		}
		if { $i == 39 } {
			checkPorts 1 0 1
		} else {
			checkPorts 0 0 1
		}
		# Acount for different bit order of c_LIB and framebuffer data port
		checkSignal wr_data [string reverse $str]
		checkSignal wr_addr [dec2bin [expr [expr $hActive*[expr $i/2]]/8 + $i%2] 16]
	}
	runClockCycles 1
	checkPorts 1 0 0

	if { $errorCount == 0 } {
		printMsg "Test: OK"
	} else {
		printMsg "Test: Failure ($errorCount errors)"
	}
}