-- Copyright (C) 2017  Intel Corporation. All rights reserved.
-- Your use of Intel Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Intel Program License 
-- Subscription Agreement, the Intel Quartus Prime License Agreement,
-- the Intel MegaCore Function License Agreement, or other 
-- applicable license agreement, including, without limitation, 
-- that your use is for the sole purpose of programming logic 
-- devices manufactured by Intel and sold by Intel or its 
-- authorized distributors.  Please refer to the applicable 
-- agreement for further details.

-- PROGRAM		"Quartus Prime"
-- VERSION		"Version 17.0.0 Build 595 04/25/2017 SJ Lite Edition"
-- CREATED		"Fri Dec 24 12:59:51 2021"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY VGA_driver IS 
	PORT
	(
		RST :  IN  STD_LOGIC;
		I_CLK :  IN  STD_LOGIC;
		I_READ :  IN  STD_LOGIC;
		O_locked :  OUT  STD_LOGIC;
		H_SYNC :  OUT  STD_LOGIC;
		V_SYNC :  OUT  STD_LOGIC;
		BLANK :  OUT  STD_LOGIC;
		OutputRed :  OUT  STD_LOGIC;
		OutputGreen :  OUT  STD_LOGIC;
		OutputBlue :  OUT  STD_LOGIC;
		O_CLK :  OUT  STD_LOGIC
	);
END VGA_driver;

ARCHITECTURE bdf_type OF VGA_driver IS 

COMPONENT char_buffer
	PORT(CLK : IN STD_LOGIC;
		 RST : IN STD_LOGIC;
		 H_BUFFER_SYNC : IN STD_LOGIC;
		 V_BUFFER_SYNC : IN STD_LOGIC;
		 R_ENABLE : IN STD_LOGIC;
		 DATA : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
		 OUTPUT_PIXEL : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT clock_divider
	PORT(refclk : IN STD_LOGIC;
		 rst : IN STD_LOGIC;
		 outclk_0 : OUT STD_LOGIC;
		 locked : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT char_library
	PORT(CLK : IN STD_LOGIC;
		 RST : IN STD_LOGIC;
		 SEL : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 DATA : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
	);
END COMPONENT;

COMPONENT vga_controller
	PORT(CLK : IN STD_LOGIC;
		 RST : IN STD_LOGIC;
		 OUT_BUFF : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
	);
END COMPONENT;

COMPONENT sync_controller
	PORT(CLK : IN STD_LOGIC;
		 RST : IN STD_LOGIC;
		 H_SYNC : OUT STD_LOGIC;
		 V_SYNC : OUT STD_LOGIC;
		 H_BUF_SYNC : OUT STD_LOGIC;
		 V_BUF_SYNC : OUT STD_LOGIC;
		 BLANK : OUT STD_LOGIC
	);
END COMPONENT;

SIGNAL	CLK :  STD_LOGIC;
SIGNAL	OUTP :  STD_LOGIC_VECTOR(6 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_0 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_1 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_2 :  STD_LOGIC_VECTOR(6 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_8 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_9 :  STD_LOGIC;


BEGIN 
OutputRed <= SYNTHESIZED_WIRE_9;
OutputGreen <= SYNTHESIZED_WIRE_9;
OutputBlue <= SYNTHESIZED_WIRE_9;



b2v_inst : char_buffer
PORT MAP(CLK => CLK,
		 RST => OUTP(1),
		 H_BUFFER_SYNC => SYNTHESIZED_WIRE_0,
		 V_BUFFER_SYNC => SYNTHESIZED_WIRE_1,
		 R_ENABLE => I_READ,
		 DATA => SYNTHESIZED_WIRE_2,
		 OUTPUT_PIXEL => SYNTHESIZED_WIRE_9);


b2v_inst1 : clock_divider
PORT MAP(refclk => I_CLK,
		 rst => SYNTHESIZED_WIRE_8,
		 outclk_0 => CLK,
		 locked => O_locked);


b2v_inst2 : char_library
PORT MAP(CLK => CLK,
		 RST => OUTP(0),
		 SEL => OUTP(6 DOWNTO 2),
		 DATA => SYNTHESIZED_WIRE_2);


b2v_inst3 : vga_controller
PORT MAP(CLK => CLK,
		 RST => SYNTHESIZED_WIRE_8,
		 OUT_BUFF => OUTP);


b2v_inst5 : sync_controller
PORT MAP(CLK => CLK,
		 RST => SYNTHESIZED_WIRE_8,
		 H_SYNC => H_SYNC,
		 V_SYNC => V_SYNC,
		 H_BUF_SYNC => SYNTHESIZED_WIRE_0,
		 V_BUF_SYNC => SYNTHESIZED_WIRE_1,
		 BLANK => BLANK);


SYNTHESIZED_WIRE_8 <= NOT(RST);


O_CLK <= CLK;

END bdf_type;