library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.VGA_Char_Pkg.all;

use std.textio.all;

entity VGA_framebuffer_tb is
end entity VGA_framebuffer_tb;

architecture SIM of VGA_framebuffer_tb is

	constant c_CLK_HZ		: integer := 100e6;
	constant c_CLK_PERIOD	: time := 1 sec / c_CLK_HZ;

	signal Clk	: std_logic := '0';

	signal Data			: std_logic_vector(7 downto 0);
	signal RdAddress	: std_logic_vector(18 downto 0);
	signal RdEn			: std_logic;
	
	signal WrAddress	: std_logic_vector(15 downto 0);
	signal WrEn			: std_logic;
	signal Q			: std_logic;

begin

	Clk <= not Clk after c_CLK_PERIOD / 2;

	DUT : entity work.VGA_framebuffer(SYN)
	port map (
		rdclock		=> Clk,
		wrclock		=> Clk,
		data		=> Data,
		rdaddress	=> RdAddress,
		rden		=> RdEn,
		wraddress	=> WrAddress,
		wren		=> WrEn,
		q(0)		=> Q
	);

end architecture SIM;