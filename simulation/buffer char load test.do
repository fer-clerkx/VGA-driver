#vga buffer char load simulation to test the char position signals

force RST 0
force DATA 1010101
force R_ENABLE 1
force CLK 0 0, 1 20 -r 40 ns
run 40000
force rst 1
run 10
force rst 0
run 9990