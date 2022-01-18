LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY video_controller IS
	PORT(clk     : IN STD_LOGIC;
	     rst     : IN STD_LOGIC;
		  input   : IN STD_LOGIC_VECTOR(45 DOWNTO 0);
		  sel     : OUT INTEGER RANGE 0 TO 36;
		  enable  : OUT STD_LOGIC;
		  lib_rst : OUT STD_LOGIC;
		  buf_rst : OUT STD_LOGIC
	);
END video_controller;

ARCHITECTURE behaviour OF video_controller IS
	TYPE matrix IS ARRAY(11 DOWNTO 0, 24 DOWNTO 0) OF INTEGER RANGE 0 TO 36;
	TYPE t_number IS ARRAY(2 DOWNTO 0) OF INTEGER RANGE 0 TO 9;
	TYPE t_counter IS ARRAY (1 DOWNTO 0) OF INTEGER RANGE 0 TO 9;
	
	SIGNAL picture : matrix := (OTHERS => (OTHERS => 36));
	SIGNAL hor : INTEGER RANGE 0 TO 24 := 0;
	SIGNAL ver : INTEGER RANGE 0 TO 11 := 0;
	SIGNAL count: INTEGER RANGE 0 TO 9 := 0;
	SIGNAL state : INTEGER RANGE 0 TO 3 := 0;
	SIGNAL w_rst : STD_LOGIC := '0';
BEGIN
	mode:PROCESS(clk, rst)
		VARIABLE last_input : STD_LOGIC_VECTOR(45 DOWNTO 0) := (OTHERS => '0');
		VARIABLE a : INTEGER RANGE 0 TO 127;
		VARIABLE b : INTEGER RANGE 0 TO 127;
		VARIABLE number_a : t_number;
		VARIABLE number_b : t_number;
		VARIABLE number_c : t_number;
		VARIABLE oper : INTEGER RANGE 31 to 34;
		VARIABLE answer : t_counter;
		VARIABLE rewards : t_counter;
	BEGIN
		IF(rst = '1') THEN
			last_input := (OTHERS => '0');
		ELSIF(rising_edge(clk)) THEN
			IF(input /= last_input) THEN
				last_input := input;
				w_rst <= '1';
				a := to_integer(unsigned(input(8 DOWNTO 2)));
				number_a(0) := a mod 10;
				a := a / 10;
				number_a(1) := a mod 10;
				number_a(2) := a / 10;
				b := to_integer(unsigned(input(15 DOWNTO 9)));
				number_b(0) := b mod 10;
				b := b / 10;
				number_b(1) := b mod 10;
				number_b(2) := b / 10;
				number_c(0) := to_integer(unsigned(input(19 DOWNTO 16)));
				number_c(1) := to_integer(unsigned(input(23 DOWNTO 20)));
				number_c(2) := to_integer(unsigned(input(27 DOWNTO 24)));
				CASE input(29 DOWNTO 28) IS
					WHEN "00" => oper := 32;
					WHEN "01" => oper := 31;
					WHEN "10" => oper := 33;
					WHEN "11" => oper := 34;
					WHEN OTHERS => NULL;
				END CASE;
				answer(0) := to_integer(unsigned(input(33 DOWNTO 30)));
				answer(1) := to_integer(unsigned(input(37 DOWNTO 34)));
				rewards(0) := to_integer(unsigned(input(41 DOWNTO 38)));
				rewards(1) := to_integer(unsigned(input(45 DOWNTO 42)));
				CASE input(1 DOWNTO 0) IS
					WHEN "00" => picture <= (5 => (7 => 17, 8 => 19, 9 => 11, 10 => 20, 11 => 21, 12 => 21, 
													13 => 13, 14 => 11, 15 => 23, 16 => 35, OTHERS => 36),
													OTHERS => (OTHERS => 36));
					WHEN "01" => picture <= (5 => (9 => 11, 10 => 20, 11 => 21, 12 => 21, 13 => 13, 14 => 11,
															 15 => 23, 16 => 35, OTHERS => 36),
													OTHERS => (OTHERS => 36));
					WHEN "10" => picture <= (0 => (4 => 10, 5 => 19, 6 => 22, 7 => 25, 8 => 13, 9 => 21, 10 => 22,
															 14 => 21, 15 => 13, 16 => 25, 17 => 10, 18 => 21, 19 => 12, 20 => 22,
															 OTHERS => 36),
													 1 => (6 => answer(0), 7 => 34, 8 => answer(1), 16 => rewards(0), 17 => 34, 
															 18 => rewards(1), OTHERS => 36),
													 5 => (7 => number_a(2), 8 => number_a(1), 9 => number_a(0), 10 => oper, 
													 11 => number_b(2), 12 => number_b(1), 13 => number_b(0), 14 => 30, 
													 15 => number_c(2), 16 => number_c(1), 17 => number_c(0), OTHERS => 36),
													 OTHERS => (OTHERS => 36));
													
					WHEN OTHERS => picture <= (OTHERS => (OTHERS => 36));
				END CASE;
			ELSE
				w_rst <= '0';
			END IF;
		END IF;
	END PROCESS;

	controller:PROCESS(clk, rst, w_rst)
	BEGIN
		IF(rst = '1') THEN
			state <= 0;
		ELSIF(rising_edge(clk)) THEN
			IF(w_rst = '1') THEN
				state <= 0;
			ELSE
				CASE state IS
					WHEN 0 => enable <= '0';
								 lib_rst <= '1';
								 buf_rst <= '1';
								 state <= 1;
					WHEN 1 => enable <= '0';
								 lib_rst <= '0';
								 buf_rst <= '1';
								 state <= 2;
					WHEN 2 => enable <= '1';
								 lib_rst <= '0';
								 buf_rst <= '0';
								 IF(count = 8 AND hor = 24 AND ver = 11) THEN
									state <= 3;
								 END IF;
					WHEN OTHERS =>  enable <= '0';
										 lib_rst <= '0';
										 buf_rst <= '0';
				END CASE;
			END IF;
		END IF;
	END PROCESS;
	
	output:PROCESS(clk, rst, w_rst)
	BEGIN
		IF(rst = '1') THEN
			count <= 0;
			hor <= 0;
			ver <= 0;
		ELSIF(rising_edge(clk)) THEN
			IF(w_rst = '1') THEN
				count <= 0;
				hor <= 0;
				ver <= 0;
			ELSE
				sel <= picture(ver, hor);
				IF(state = 1 OR state = 2) THEN
					IF(count < 9) THEN
						count <= count + 1;
					ELSE
						count <= 0;
						IF(hor < 24) THEN
							hor <= hor + 1;
						ELSE
							hor <= 0;
							IF(ver < 11) THEN
								ver <= ver + 1;
							ELSE
								ver <= 0;
							END IF;
						END IF;
					END IF;
				ELSE
					count <= 0;
					hor <= 0;
					ver <= 0;
				END IF;
			END IF;
		END IF;
	END PROCESS;
end behaviour;