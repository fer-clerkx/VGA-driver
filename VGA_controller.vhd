LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY vga_controller IS
	PORT(
		CLK, RST	: IN  STD_LOGIC;
		OUT_BUFF	: OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
		);
END vga_controller;

ARCHITECTURE behaviour OF vga_controller IS
	TYPE state IS (S0, S1, S2, S3);
	SIGNAL PS	: state := S0;		--Present state
	SIGNAL NS	: state;				--Next state
BEGIN
	next_state_decoder:PROCESS(PS)
	BEGIN
		CASE PS IS
			WHEN S0 =>
				NS <= S1;
			WHEN S1 =>
				NS <= S2;
			WHEN S2 =>
				NS <= S3;
			WHEN S3 =>
				NS <= S3;
		END CASE;
	END PROCESS;
	
	memory:PROCESS(CLK, RST)
	BEGIN
		IF(RST = '1') THEN
			PS <= S0;
		ELSIF(rising_edge(CLK)) THEN
			PS <= NS;
		END IF;
	END PROCESS;
	
	output_decoder:PROCESS(PS)
	BEGIN
		CASE PS IS
			WHEN S0 =>
				OUT_BUFF <= "01";
			WHEN S1 =>
				OUT_BUFF <= "10";
			WHEN S2 =>
				OUT_BUFF <= "00";
			WHEN S3 =>
				OUT_BUFF <= "00";
		END CASE;
	END PROCESS;
END behaviour;
			