#vga buffer load test for one char

force RST 0
force CLK 0 0, 1 20 -r 40 ns
force DATA 0000000
run 40

force DATA 0001000
run 40

force DATA 0011100
run 40

force DATA 0111110
run 40

force DATA 1111111
run 40

force DATA 0111110
run 40

force DATA 0011100
run 40

force DATA 0001000
run 40

force DATA 0000000
run 40