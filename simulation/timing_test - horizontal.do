#vga timing module sync and counter test

force RST 0
force CLK 0 0, 1 20 -r 40 ns
run 100000 ns