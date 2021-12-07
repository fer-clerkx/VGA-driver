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
-- CREATED		"Mon Nov 22 14:44:42 2021"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY VGA_driver IS 
	PORT
	(
		CLK :  IN  STD_LOGIC;
		RST :  IN  STD_LOGIC;
		SEL :  IN  STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END VGA_driver;

ARCHITECTURE bdf_type OF VGA_driver IS 

COMPONENT char_buffer
	PORT(CLK : IN STD_LOGIC;
		 RST : IN STD_LOGIC;
		 H_POS_BUFFER : IN STD_LOGIC;
		 v_POS_BUFFER : IN STD_LOGIC;
		 DATA : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
		 OUTPUT_PIXEL : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT char_library
	PORT(CLK : IN STD_LOGIC;
		 SEL : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 DATA : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
	);
END COMPONENT;

SIGNAL	SYNTHESIZED_WIRE_3 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_2 :  STD_LOGIC_VECTOR(6 DOWNTO 0);


BEGIN 
SYNTHESIZED_WIRE_3 <= '0';



b2v_inst : char_buffer
PORT MAP(CLK => CLK,
		 RST => RST,
		 H_POS_BUFFER => SYNTHESIZED_WIRE_3,
		 v_POS_BUFFER => SYNTHESIZED_WIRE_3,
		 DATA => SYNTHESIZED_WIRE_2);


b2v_inst2 : char_library
PORT MAP(CLK => CLK,
		 SEL => SEL,
		 DATA => SYNTHESIZED_WIRE_2);



END bdf_type;