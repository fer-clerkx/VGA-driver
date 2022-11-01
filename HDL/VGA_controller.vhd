LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
LIBRARY WORK;
LIBRARY pll;

ENTITY VGA_controller IS
	PORT(
		I_CLK		: IN	STD_LOGIC;
		I_RST		: IN	STD_LOGIC;
		I_INPUT	: IN	STD_LOGIC_VECTOR(1 DOWNTO 0);
		O_BLANK	: OUT	STD_LOGIC;
		O_H		: OUT	STD_LOGIC;
		O_V		: OUT	STD_LOGIC;
		O_CLK		: OUT	STD_LOGIC;
		O_LOCKED	: OUT	STD_LOGIC;
		O_RED		: OUT	STD_LOGIC_VECTOR(7 DOWNTO 0);
		O_GREEN	: OUT	STD_LOGIC_VECTOR(7 DOWNTO 0);
		O_BLUE	: OUT	STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END VGA_controller;

ARCHITECTURE RTL OF VGA_controller IS

	SIGNAL w_h_sync : STD_LOGIC;
	SIGNAL w_v_sync : STD_LOGIC;
	SIGNAL h_lib_sync : STD_LOGIC := '0';
	SIGNAL v_lib_sync : STD_LOGIC := '0';
	SIGNAL w_clk : STD_LOGIC;
	SIGNAL w_sel : INTEGER RANGE 0 TO 36;
	SIGNAL w_rst : STD_LOGIC;
	SIGNAL w_pix : STD_LOGIC;

BEGIN
	O_CLK <= w_clk;
	w_rst <= NOT(I_RST);
	O_RED <= (OTHERS => w_pix);
	O_GREEN <= (OTHERS => w_pix);
	O_BLUE <= (OTHERS => w_pix);
	
	PROCESS(w_clk)
	BEGIN
		IF(rising_edge(w_clk)) THEN
			h_lib_sync <= w_h_sync;
			v_lib_sync <= w_v_sync;
		END IF;
	END PROCESS;
				
	inst_sync : entity work.sync_controller(RTL)
		PORT MAP(
			I_CLK => w_clk,
			I_RST => w_rst,
			O_H_SYNC => O_H,
			O_V_SYNC => O_V,
			O_H_BUF_SYNC => w_h_sync,
			O_V_BUF_SYNC => w_v_sync,
			O_BLANK => O_BLANK
		);
				
	inst_PLL: entity pll.PLL(rtl)
		PORT MAP(
			refclk => I_CLK,
			rst => w_rst,
			outclk_0 => w_clk,
			locked => O_LOCKED
		);
		 
	inst_lib : entity work.char_library(RTL)
		PORT MAP(
			I_CLK => w_clk,
			I_RST => w_rst,
			I_SEL => w_sel,
			I_H_LIB_SYNC => h_lib_sync,
			I_V_LIB_SYNC => v_lib_sync,
			O_PIX => w_pix
		);
				
	inst_video : entity work.video_controller(RTL)
		PORT MAP(
			I_clk => w_clk,
			I_rst => w_rst,
			I_mode => I_INPUT,		--mode
			I_a => 0,	--a
			I_b => 127,		--b
			I_c => "011110010010",
			I_oper => "01",			--oper
			I_answer0 => 5,		--answer0
			I_answer1 => 3,		--answer1
			I_reward0 => 6,		--reward0
			I_reward1 => 0,		--reward1
			O_sel => w_sel,
			I_h_sync => w_h_sync,
			I_v_sync => w_v_sync
		);
		
END ARCHITECTURE RTL;