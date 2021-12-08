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
-- CREATED		"Wed Dec 08 15:21:20 2021"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY VGA_driver IS 
	PORT
	(
		CLK :  IN  STD_LOGIC;
		RST :  IN  STD_LOGIC;
		pin_name1 :  IN  STD_LOGIC;
		SEL :  IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		O_locked :  OUT  STD_LOGIC
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
		 SEL : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 DATA : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
	);
END COMPONENT;

SIGNAL	SYNTHESIZED_WIRE_5 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_6 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_3 :  STD_LOGIC_VECTOR(6 DOWNTO 0);


BEGIN 
SYNTHESIZED_WIRE_6 <= '0';



b2v_inst : char_buffer
PORT MAP(CLK => SYNTHESIZED_WIRE_5,
		 RST => RST,
		 H_BUFFER_SYNC => SYNTHESIZED_WIRE_6,
		 V_BUFFER_SYNC => SYNTHESIZED_WIRE_6,
		 R_ENABLE => pin_name1,
		 DATA => SYNTHESIZED_WIRE_3);


b2v_inst1 : clock_divider
PORT MAP(refclk => CLK,
		 rst => RST,
		 outclk_0 => SYNTHESIZED_WIRE_5,
		 locked => O_locked);


b2v_inst2 : char_library
PORT MAP(CLK => SYNTHESIZED_WIRE_5,
		 SEL => SEL,
		 DATA => SYNTHESIZED_WIRE_3);



END bdf_type;