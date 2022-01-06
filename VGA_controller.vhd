LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY vga_controller IS
	PORT(
		CLK, RST	: IN  STD_LOGIC;
		OUT_BUFF	: OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
		);
END vga_controller;

ARCHITECTURE behaviour OF vga_controller IS
	TYPE state IS (S0, S1, S2, S3, S4, S5, S6);
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
				NS <= S4;
			WHEN S4 =>
				NS <= S5;
			WHEN S5 =>
				NS <= S6;
			WHEN S6 =>
				NS <= S6;
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
				OUT_BUFF <= "0100000";
			WHEN S1 =>
				OUT_BUFF <= "1000000";
			WHEN S2 =>
				OUT_BUFF <= "0000001";
			WHEN S3 =>
				OUT_BUFF <= "0000010";
			WHEN S4 =>
				OUT_BUFF <= "0000011";
			WHEN S5 =>
				OUT_BUFF <= "0000100";
			WHEN S6 =>
				OUT_BUFF <= "0000101";
		END CASE;
	END PROCESS;
END behaviour;
			