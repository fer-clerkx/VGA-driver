#vga buffer output test to simulate if the buffer outputs pixels in the correct order

force CLK 0 0, 1 20 -r 40 ns
force RST 0
force DATA 1010101

force R_ENABLE 1
force H_BUFFER_SYNC 1
force V_BUFFER_SYNC 1
run 40000

force H_BUFFER_SYNC 0
force V_BUFFER_SYNC 0
force R_ENABLE 0
run 500

force H_BUFFER_SYNC 1
run 40

force H_BUFFER_SYNC 0
run 500