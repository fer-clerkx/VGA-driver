LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY char_buffer IS
	PORT (
			CLK				:	IN	STD_LOGIC;
			RST				:	IN STD_LOGIC;
			DATA				:	IN	STD_LOGIC_VECTOR(0 TO 6);
			H_BUFFER_SYNC	: 	IN	STD_LOGIC;
			V_BUFFER_SYNC	:	IN STD_LOGIC;
			R_ENABLE			:	IN STD_LOGIC;
			PIX_OUT	      :	OUT STD_LOGIC
		);
END char_buffer;

ARCHITECTURE behaviour OF char_buffer IS

	TYPE char IS ARRAY(9 DOWNTO 0) OF STD_LOGIC_VECTOR(0 TO 7);	--Variable represents one character
	TYPE buffer_matrix IS ARRAY(11 DOWNTO 0, 24 DOWNTO 0) OF char;		--A 2D matrix of characters, containing the entire frame

	SIGNAL var_buffer	: buffer_matrix := (OTHERS=> (OTHERS=> (0 => "00000000",
																				 1 => "00111000",
																				 2 => "01001100",
																				 3 => "01010100",
																				 4 => "01100100",
																				 5 => "01000100",
																				 6 => "01000100",
																				 7 => "00111000",
																				 8 => "00000000",
																				 9 => "00000000"))); 	--Contains all the char's, and thus pixels to be displayed

BEGIN

	load:PROCESS(CLK, RST)		--load row into currently sellected char and row
		VARIABLE CHAR_ROW	  : INTEGER := 0;	--Keeps track which row of a char is selected
		VARIABLE H_CHAR_POS : INTEGER := 0;	--Horizontal position for characters used for loading
		VARIABLE V_CHAR_POS : INTEGER := 0;	--Vertical position for characters used for loading
	BEGIN
		IF(RST = '1') THEN
			V_CHAR_POS := 0;
			H_CHAR_POS := 0;
			CHAR_ROW := 0;
		ELSIF(rising_edge(CLK)) THEN
			IF(R_ENABLE = '1') THEN
				var_buffer(V_CHAR_POS, H_CHAR_POS)(CHAR_ROW) <= DATA & '0';
			END IF;
			IF(CHAR_ROW >= 9) THEN
				CHAR_ROW := 0;
				IF(H_CHAR_POS >= 24) THEN
					H_CHAR_POS := 0;
					IF(V_CHAR_POS >= 11) THEN
						V_CHAR_POS := 0;
					ELSE
						V_CHAR_POS := V_CHAR_POS + 1;
					END IF;
				ELSE
					H_CHAR_POS := H_CHAR_POS + 1;
				END IF;
			ELSE
				CHAR_ROW := CHAR_ROW + 1;
			END IF;
		END IF;
	END PROCESS;
	
	output:PROCESS(CLK, RST)
		VARIABLE H_CHAR  : INTEGER := 0;
		VARIABLE V_CHAR  : INTEGER := 0;
		VARIABLE H_PIX   : INTEGER := 0;
		VARIABLE V_PIX   : INTEGER := 0;
		VARIABLE H_DELAY : INTEGER := 0;
		VARIABLE V_DELAY : INTEGER := 0;
	BEGIN
		IF(RST = '1') THEN
			H_CHAR := 0;
			V_CHAR := 0;
			H_PIX := 0;
			V_PIX := 0;
			H_DELAY := 0;
			V_DELAY := 0;
		ELSIF(rising_edge(CLK)) THEN
			IF(R_ENABLE = '0' AND H_CHAR <= 24 AND V_CHAR <= 11) THEN
				PIX_OUT <= var_buffer(V_CHAR, H_CHAR)(V_PIX)(H_PIX);
			ELSE
				PIX_OUT <= '0';
			END IF;
			
			IF(H_CHAR < 25) THEN
				IF(H_DELAY < 3) THEN
					H_DELAY := H_DELAY + 1;
				ELSE
					H_DELAY := 0;
					IF(H_PIX < 7) THEN
						H_PIX := H_PIX + 1;
					ELSE
						H_PIX := 0;
						H_CHAR := H_CHAR + 1;
					END IF;
				END IF;
			END IF;
			
			IF(V_BUFFER_SYNC = '1') THEN
				H_CHAR := 0;
				H_PIX := 0;
				V_CHAR := 0;
				V_PIX := 0;
				H_DELAY := 0;
				V_DELAY := 0;
			ELSIF(H_BUFFER_SYNC = '1' AND V_CHAR < 12) THEN
				H_CHAR := 0;
				H_PIX := 0;
				H_DELAY := 0;
				IF(V_DELAY < 3) THEN
					V_DELAY := V_DELAY + 1;
				ELSE
					V_DELAY := 0;
					IF(V_PIX < 9) THEN
						V_PIX := V_PIX + 1;
					ELSE
						V_PIX := 0;
						V_CHAR := V_CHAR + 1;
					END IF;
				END IF;
			END IF;
		END IF;
	END PROCESS;
END ARCHITECTURE;