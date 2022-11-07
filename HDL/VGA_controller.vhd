library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
library pll;

entity VGA_controller is
	port(
		i_clk		: in	std_logic;
		i_rst		: in	std_logic;
		i_input		: in	std_logic_vector(1 downto 0);
		o_blank		: out	std_logic;
		o_h			: out	std_logic;
		o_v			: out	std_logic;
		o_clk		: out	std_logic;
		o_locked	: out	std_logic;
		o_red		: out	std_logic_vector(7 downto 0);
		o_green		: out	std_logic_vector(7 downto 0);
		o_blue		: out	std_logic_vector(7 downto 0)
	);
end entity VGA_controller;

architecture RTL of VGA_controller is

	signal w_H_Sync		: std_logic;
	signal w_V_Sync		: std_logic;
	signal r_H_Lib_Sync	: std_logic := '0';
	signal r_V_Lib_Sync	: std_logic := '0';
	signal w_Clk		: std_logic;
	signal w_Sel		: integer range 0 to 36;
	signal w_Rst		: std_logic;
	signal w_Pix		: std_logic;

begin

	o_clk <= w_Clk;
	w_Rst <= not(i_rst);
	o_red <= (others => w_Pix);
	o_green <= (others => w_Pix);
	o_blue <= (others => w_Pix);
	
	process(w_Clk)
	begin
		if rising_edge(w_Clk) then
			r_H_Lib_Sync <= w_H_Sync;
			r_V_Lib_Sync <= w_V_Sync;
		end if;
	end process;
				
	inst_sync : entity work.sync_controller(RTL)
		port map(
			i_clk => w_Clk,
			i_rst => w_Rst,
			o_h_sync => o_h,
			o_v_sync => o_v,
			o_h_buf_sync => w_H_Sync,
			o_v_buf_sync => w_V_Sync,
			o_blank => o_blank
		);
				
	inst_PLL : entity pll.PLL(rtl)
		port map(
			refclk => i_clk,
			rst => w_Rst,
			outclk_0 => w_Clk,
			locked => o_locked
		);
		 
	inst_lib : entity work.char_library(RTL)
		port map(
			i_clk => w_Clk,
			i_rst => w_Rst,
			i_sel => w_Sel,
			i_h_lib_sync => r_H_Lib_Sync,
			i_v_lib_sync => r_V_Lib_Sync,
			o_pix => w_Pix
		);
				
	inst_video : entity work.video_controller(RTL)
		port map(
			i_clk => w_Clk,
			i_rst => w_Rst,
			I_mode => i_input,		--mode
			I_a => 0,	--a
			I_b => 127,		--b
			I_c => "011110010010",
			I_oper => "01",			--oper
			I_answer0 => 5,		--answer0
			I_answer1 => 3,		--answer1
			I_reward0 => 6,		--reward0
			I_reward1 => 0,		--reward1
			O_sel => w_Sel,
			I_h_sync => w_H_Sync,
			I_v_sync => w_V_Sync
		);
		
end architecture RTL;