LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY char_buffer IS
	PORT (
			CLK				:	IN	STD_LOGIC;
			RST				:	IN STD_LOGIC;
			DATA				:	IN	STD_LOGIC_VECTOR(6 DOWNTO 0);
			H_BUFFER_SYNC	: 	IN	STD_LOGIC;
			V_BUFFER_SYNC	:	IN STD_LOGIC;
			R_ENABLE			:	IN STD_LOGIC;
			OUTPUT_PIXEL	:	OUT STD_LOGIC
		);
END char_buffer;

ARCHITECTURE behaviour OF char_buffer IS

	TYPE char IS ARRAY(8 DOWNTO 0) OF STD_LOGIC_VECTOR(6 DOWNTO 0);	--Variable represents one character
	TYPE buffer_matrix IS ARRAY(9 DOWNTO 0, 9 DOWNTO 0) OF char;		--A 2D matrix of characters, containing the entire frame

	SIGNAL CHAR_ROW	: INTEGER := 0;	--Keeps track which row of a char is selected
	SIGNAL H_CHAR_POS	: INTEGER := 0;	--Horizontal position for characters used for loading
	SIGNAL V_CHAR_POS : INTEGER := 0;	--Vertical position for characters used for loading
	SIGNAL H_PIXEL_POS: INTEGER := 0;	--Horizontally selected pixel for outputting data
	SIGNAL V_PIXEL_POS: INTEGER := 0;	--Vertically selected pixel for outputting data
	SIGNAL var_buffer	: buffer_matrix; 	--Contains all the char's, and thus pixels to be displayed

BEGIN

	bufferPosCounter:PROCESS(CLK, RST)		--updates selected character in the buffer for loading
	BEGIN
		IF(RST = '1') THEN		--Upon reset, goes back to first character in matrix
			V_CHAR_POS <= 0;
			H_CHAR_POS <= 0;
		ELSIF(rising_edge(CLK)) THEN
			IF(CHAR_ROW = 8) THEN
				IF(H_CHAR_POS >= 9) THEN
					H_CHAR_POS <= 0;
					IF(V_CHAR_POS >= 9) THEN
						V_CHAR_POS <= 0;
					ELSE
						V_CHAR_POS <= V_CHAR_POS + 1;
					END IF;
				ELSE
					H_CHAR_POS <= H_CHAR_POS + 1;
				END IF;
			END IF;
		END IF;
	END PROCESS;
											 
	charRowCounter:PROCESS(CLK, RST)		--Increments which row of a char is selected
	BEGIN
		IF(RST = '1') THEN				--Returns to first row of selected character
			CHAR_ROW <= 0;
		ELSIF (rising_edge(CLK)) THEN
			IF(R_ENABLE = '1') THEN
				IF(CHAR_ROW >= 8) THEN		--When one char is completely loaded, moves to the first row of the next one
					CHAR_ROW <= 0;
				ELSE
					CHAR_ROW <= CHAR_ROW + 1;
				END IF;
			END IF;
		END IF;
	END PROCESS;

	loadRow:PROCESS(CLK)		--Loads one row of bits into the selected char
	BEGIN
		IF(rising_edge(CLK)) THEN
			IF(R_ENABLE = '1') THEN
				var_buffer(V_CHAR_POS, H_CHAR_POS)(CHAR_ROW) <= DATA;
			END IF;
		END IF;
	END PROCESS;
	
	pixelPosCounter:PROCESS(CLK, RST)	--Counts the horizontal and vertical position of the selected pixel
	BEGIN
		IF(RST = '1') THEN
			H_PIXEL_POS <= 0;
			V_PIXEL_POS <= 0;
		ELSIF(rising_edge(CLK)) THEN
			IF(H_BUFFER_SYNC = '1' OR V_BUFFER_SYNC = '1') THEN
				H_PIXEL_POS <= 0;
				IF(H_BUFFER_SYNC = '1') THEN
					V_PIXEL_POS <= V_PIXEL_POS + 1;
				END IF;
				IF(V_BUFFER_SYNC = '1') THEN
					V_PIXEL_POS <= 0;
				END IF;
			ELSE
				H_PIXEL_POS <= H_PIXEL_POS + 1;
			END IF;
		END IF;
	END PROCESS;
	
	pixelOutput:PROCESS(CLK, RST)
		VARIABLE	H_BUFFER_CHAR : INTEGER := 0;	--Selected char within buffer for outputting pixels
		VARIABLE	V_BUFFER_CHAR : INTEGER:= 0;	--Selected char within buffer for outputting pixels
		VARIABLE	H_CHAR_PIXEL : INTEGER:= 0;	--Selected pixel within a char
		VARIABLE	V_CHAR_PIXEL : INTEGER:= 0;	--Selected pixel within a char
	BEGIN
		IF(RST = '1') THEN
			H_BUFFER_CHAR := 0;
			V_BUFFER_CHAR := 0;
			H_CHAR_PIXEL := 0;
			V_CHAR_PIXEL := 0;
		ELSIF(rising_edge(CLK)) THEN
			IF(R_ENABLE = '0') THEN
				H_BUFFER_CHAR := H_PIXEL_POS / 7;
				H_CHAR_PIXEL := H_PIXEL_POS - (H_BUFFER_CHAR * 7);
				V_BUFFER_CHAR := V_PIXEL_POS / 7;
				V_CHAR_PIXEL := V_PIXEL_POS - (V_BUFFER_CHAR * 7);
				OUTPUT_PIXEL <= var_buffer(V_BUFFER_CHAR, H_BUFFER_CHAR)(V_CHAR_PIXEL)(H_CHAR_PIXEL);
			END IF;
		END IF;
	END PROCESS;
END ARCHITECTURE;