library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;

use work.VGA_Char_Pkg.all;

entity VGA_loader_tb is
end entity VGA_loader_tb;

architecture sim of VGA_loader_tb is

    constant c_CLK_HZ : integer := 100e6;
    constant c_CLK_PERIOD : time := 1 sec / c_CLK_HZ;

    signal clk	: std_logic := '0';
    signal rst	: std_logic;

	signal wr_req	: t_WR_REQ;
	signal valid	: std_logic;
	signal ready	: std_logic;
    signal active	: std_logic;

	signal wr_data	: std_logic_vector(7 downto 0);
	signal wr_en	: std_logic;
	signal wr_addr	: std_logic_vector(15 downto 0);
    signal v_sync	: std_logic;

begin

    clk <= not clk after c_CLK_PERIOD / 2;

    DUT : entity work.VGA_loader(RTL)
    port map (
        i_clk		=> clk,
        i_rst		=> rst,
        i_wr_req	=> wr_req,
        i_valid		=> valid,
        o_ready		=> ready,
		o_active	=> active,
        o_wr_data	=> wr_data,
        o_wr_en		=> wr_en,
        o_wr_addr	=> wr_addr,
		i_v_sync	=> v_sync
    );

end architecture sim;