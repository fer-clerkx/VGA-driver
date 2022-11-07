library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity video_controller is
	port(
		i_clk		: in	std_logic;
		i_rst		: in	std_logic;
		i_mode		: in	std_logic_vector(1 downto 0);
		i_a			: in	integer range 0 to 127;
		i_b			: in	integer range 0 to 127;
		i_c			: in	std_logic_vector(11 downto 0);
		i_oper		: in	std_logic_vector(1 downto 0);
		i_answer0	: in	integer range 0 to 7;
		i_answer1	: in	integer range 0 to 7;
		i_reward0	: in	integer range 0 to 7;
		i_reward1	: in	integer range 0 to 7;
		i_h_sync	: in	std_logic;
		i_v_sync	: in	std_logic;
		o_sel		: out	integer range 0 to 36
	);
end entity video_controller;

architecture RTL of video_controller is

	type t_matrix is array(11 downto 0, 24 downto 0) of integer range 0 to 36;
	type t_number is array(2 downto 0) of integer range 0 to 36;
	
	signal r_Picture : t_matrix := (others => (others => 36));
	
begin

	RENDER : process(i_clk, i_rst)
		variable v_A		: integer range 0 to 127;
		variable v_B		: integer range 0 to 127;
		variable v_Number_A	: t_number;
		variable v_Number_B	: t_number;
		variable v_Number_C	: t_number;
		variable v_I_Oper	: integer range 31 to 34;
	begin
		if rising_edge(i_clk) then
			v_A := i_a;
			v_Number_A(0) := v_A mod 10;
			v_A := v_A / 10;
			v_Number_A(1) := v_A mod 10;
			v_Number_A(2) := v_A / 10;
			
			v_B := i_b;
			v_Number_B(0) := v_B mod 10;
			v_B := v_B / 10;
			v_Number_B(1) := v_B mod 10;
			v_Number_B(2) := v_B / 10;
			
			v_Number_C(0) := to_integer(unsigned(i_c(3 downto 0)));
			if v_Number_C(0) = 10 then
				v_Number_C(0) := 36;
			end if;
			v_Number_C(1) := to_integer(unsigned(i_c(7 downto 4)));
			if v_Number_C(1) = 10 then
				v_Number_C(1) := 36;
			end if;
			v_Number_C(2) := to_integer(unsigned(i_c(11 downto 8)));
			if v_Number_C(2) = 10 then
				v_Number_C(2) := 36;
			end if;
			
			case i_oper is
				when "00" => v_I_Oper := 32;
				when "01" => v_I_Oper := 31;
				when "10" => v_I_Oper := 33;
				when "11" => v_I_Oper := 34;
				when others => null;
			end case;
			
			case i_mode is
				when "00" => r_Picture <= (5 => (7 => 17, 8 => 19, 9 => 11, 10 => 20, 11 => 21, 12 => 21, 
												13 => 13, 14 => 11, 15 => 23, 16 => 35, others => 36),
												others => (others => 36));
				when "01" => r_Picture <= (5 => (9 => 11, 10 => 20, 11 => 21, 12 => 21, 13 => 13, 14 => 11,
														 15 => 23, 16 => 35, others => 36),
												others => (others => 36));
				when "10" => r_Picture <= (0 => (4 => 10, 5 => 19, 6 => 22, 7 => 25, 8 => 13, 9 => 21, 10 => 22,
														 14 => 21, 15 => 13, 16 => 25, 17 => 10, 18 => 21, 19 => 12, 20 => 22,
														 others => 36),
												 1 => (6 => i_answer0, 7 => 34, 8 => i_answer1, 16 => i_reward0, 17 => 34, 
														 18 => i_reward1, others => 36),
												 5 => (7 => v_Number_A(0), 8 => v_Number_A(1), 9 => v_Number_A(2), 10 => v_I_Oper, 
												 11 => v_Number_B(0), 12 => v_Number_B(1), 13 => v_Number_B(2), 14 => 30, 
												 15 => v_Number_C(0), 16 => v_Number_C(1), 17 => v_Number_C(2), others => 36),
												 others => (others => 36));
												
				when others => r_Picture <= (others => (others => 36));
			end case;
		end if;
	end process;
	
	OUTPUT : process(i_clk, i_rst)
		variable v_H_Pix : integer range 0 to 799 := 0;
		variable v_V_Pix : integer range 0 to 479 := 0;
	begin
		if i_rst = '1' then
			v_H_Pix := 0;
			v_V_Pix := 0;
		elsif rising_edge(i_clk) then
			o_sel <= r_Picture(v_V_Pix / 40, v_H_Pix / 32);
			if i_v_sync = '1' then
				v_H_Pix := 0;
				v_V_Pix := 0;
			elsif i_h_sync = '1' and v_V_Pix < 479 then
				v_H_Pix := 0;
				v_V_Pix := v_V_Pix + 1;
			elsif v_H_Pix < 799 then
				v_H_Pix := v_H_Pix + 1;
			end if;
		end if;
	end process;

end architecture RTL;