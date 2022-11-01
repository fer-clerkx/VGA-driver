LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY video_controller IS
	PORT(clk     : IN STD_LOGIC;
	     rst     : IN STD_LOGIC;
		  mode	 : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		  a		 : IN INTEGER RANGE 0 TO 127;
		  b		 : IN INTEGER RANGE 0 TO 127;
		  c		 : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
		  oper	 : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		  answer0 : IN INTEGER RANGE 0 TO 7;
		  answer1 : IN INTEGER RANGE 0 TO 7;
		  reward0 : IN INTEGER RANGE 0 TO 7;
		  reward1 : IN INTEGER RANGE 0 TO 7;
		  h_sync  : IN STD_LOGIC;
		  v_sync  : IN STD_LOGIC;
		  sel     : OUT INTEGER RANGE 0 TO 36
	);
END video_controller;

ARCHITECTURE behaviour OF video_controller IS
	TYPE matrix IS ARRAY(11 DOWNTO 0, 24 DOWNTO 0) OF INTEGER RANGE 0 TO 36;
	TYPE t_number IS ARRAY(2 DOWNTO 0) OF INTEGER RANGE 0 TO 36;
	
	SIGNAL picture : matrix := (OTHERS => (OTHERS => 36));
BEGIN
	render:PROCESS(clk, rst)
		VARIABLE v_a : INTEGER RANGE 0 TO 127;
		VARIABLE v_b : INTEGER RANGE 0 TO 127;
		VARIABLE number_a : t_number;
		VARIABLE number_b : t_number;
		VARIABLE number_c : t_number;
		VARIABLE v_oper : INTEGER RANGE 31 to 34;
	BEGIN
		IF(rising_edge(clk)) THEN
			v_a := a;
			number_a(0) := v_a mod 10;
			v_a := v_a / 10;
			number_a(1) := v_a mod 10;
			number_a(2) := v_a / 10;
			
			v_b := b;
			number_b(0) := v_b mod 10;
			v_b := v_b / 10;
			number_b(1) := v_b mod 10;
			number_b(2) := v_b / 10;
			
			number_c(0) := to_integer(unsigned(c(3 DOWNTO 0)));
			IF(number_c(0) = 10) THEN
				number_c(0) := 36;
			END IF;
			number_c(1) := to_integer(unsigned(c(7 DOWNTO 4)));
			IF(number_c(1) = 10) THEN
				number_c(1) := 36;
			END IF;
			number_c(2) := to_integer(unsigned(c(11 DOWNTO 8)));
			IF(number_c(2) = 10) THEN
				number_c(2) := 36;
			END IF;
			
			CASE oper IS
				WHEN "00" => v_oper := 32;
				WHEN "01" => v_oper := 31;
				WHEN "10" => v_oper := 33;
				WHEN "11" => v_oper := 34;
				WHEN OTHERS => NULL;
			END CASE;
			
			CASE mode IS
				WHEN "00" => picture <= (5 => (7 => 17, 8 => 19, 9 => 11, 10 => 20, 11 => 21, 12 => 21, 
												13 => 13, 14 => 11, 15 => 23, 16 => 35, OTHERS => 36),
												OTHERS => (OTHERS => 36));
				WHEN "01" => picture <= (5 => (9 => 11, 10 => 20, 11 => 21, 12 => 21, 13 => 13, 14 => 11,
														 15 => 23, 16 => 35, OTHERS => 36),
												OTHERS => (OTHERS => 36));
				WHEN "10" => picture <= (0 => (4 => 10, 5 => 19, 6 => 22, 7 => 25, 8 => 13, 9 => 21, 10 => 22,
														 14 => 21, 15 => 13, 16 => 25, 17 => 10, 18 => 21, 19 => 12, 20 => 22,
														 OTHERS => 36),
												 1 => (6 => answer0, 7 => 34, 8 => answer1, 16 => reward0, 17 => 34, 
														 18 => reward1, OTHERS => 36),
												 5 => (7 => number_a(0), 8 => number_a(1), 9 => number_a(2), 10 => v_oper, 
												 11 => number_b(0), 12 => number_b(1), 13 => number_b(2), 14 => 30, 
												 15 => number_c(0), 16 => number_c(1), 17 => number_c(2), OTHERS => 36),
												 OTHERS => (OTHERS => 36));
												
				WHEN OTHERS => picture <= (OTHERS => (OTHERS => 36));
			END CASE;
		END IF;
	END PROCESS;
	
	output:PROCESS(clk, rst)
		VARIABLE h_pix : INTEGER RANGE 0 TO 799 := 0;
		VARIABLE v_pix : INTEGER RANGE 0 TO 479 := 0;
	BEGIN
		IF(rst = '1') THEN
			h_pix := 0;
			v_pix := 0;
		ELSIF(rising_edge(clk)) THEN
			sel <= picture(v_pix / 40, h_pix / 32);
			IF(v_sync = '1') THEN
				h_pix := 0;
				v_pix := 0;
			ELSIF(h_sync = '1' AND v_pix < 479) THEN
				h_pix := 0;
				v_pix := v_pix + 1;
			ELSIF(h_pix < 799) THEN
				h_pix := h_pix + 1;
			END IF;
		END IF;
	END PROCESS;
END behaviour;