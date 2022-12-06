library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use std.env.finish;
use work.VGA_Char_Pkg.all;

entity VGA_timing_tb is
end entity VGA_timing_tb;

architecture sim of VGA_timing_tb is

    constant c_CLK_HZ       : integer := 100e6;
    constant c_CLK_PERIOD   : time := 1 sec / c_CLK_HZ;

    signal Clk		: std_logic := '0';
    signal Rst		: std_logic;
    signal H_Sync	: std_logic;
    signal V_Sync	: std_logic;
    signal Blank	: std_logic;
    signal Rd_Addr	: std_logic_vector(18 downto 0);
    signal Rd_En	: std_logic;

begin

	Clk <= not Clk after c_CLK_PERIOD/2;

    DUT : entity work.VGA_timing(RTL)
    port map (
        i_clk		=> Clk,
        i_rst		=> Rst,
        o_h_sync	=> H_Sync,
        o_v_sync	=> V_Sync,
        o_blank		=> Blank,
        o_rd_addr	=> Rd_Addr,
        o_rd_en		=> Rd_En
    );

	FIND_START : process
	begin
		wait until Rd_Addr = std_logic_vector(to_unsigned(0, 19));
		wait until Rd_Addr = std_logic_vector(to_unsigned(0, 19));
		wait until falling_edge(Clk);
		finish;
		wait;
	end process;

end architecture sim;