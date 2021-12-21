#vga buffer output test to simulate if the buffer outputs pixels in the correct order

force vga_driver/I_CLK 0 0, 1 10 -r 20 ns
force vga_driver/SEL 0
force vga_driver/I_READ 1
force vga_driver/RST 0
run 13885

#force vga_driver/I_READ 0
#force vga_driver/RST 1
#run 20

#force vga_driver/RST 0
#run 500