LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY video_controller IS
	PORT(clk     : IN STD_LOGIC;
	     rst     : IN STD_LOGIC;
		  sel     : OUT INTEGER RANGE 0 TO 27;
		  enable  : OUT STD_LOGIC;
		  lib_rst : OUT STD_LOGIC;
		  buf_rst : OUT STD_LOGIC
	);
END video_controller;

ARCHITECTURE behaviour OF video_controller IS
	TYPE matrix IS ARRAY(11 DOWNTO 0, 24 DOWNTO 0) OF INTEGER RANGE 0 TO 27;
	
	CONSTANT picture : matrix := (OTHERS => (0 => 14, 1 => 11, 2 => 15, 3 => 15, 4 => 16, 5 => 27,
														6 => 20, 7 => 16, 8 => 17, 9 => 15, 10 => 10, 11 => 26,
														OTHERS => 27));
	SIGNAL hor : INTEGER RANGE 0 TO 24 := 0;
	SIGNAL ver : INTEGER RANGE 0 TO 11 := 0;
	SIGNAL count: INTEGER RANGE 0 TO 9 := 0;
	SIGNAL state : INTEGER RANGE 0 TO 3 := 0;
BEGIN
	controller:PROCESS(clk, rst)
	BEGIN
		IF(rst = '1') THEN
			state <= 0;
		ELSIF(rising_edge(clk)) THEN
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
	END PROCESS;
	
	position:PROCESS(clk, rst)
	BEGIN
		IF(rst = '1') THEN
			count <= 0;
			hor <= 0;
			ver <= 0;
		ELSIF(rising_edge(clk)) THEN
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
	END PROCESS;
end behaviour;