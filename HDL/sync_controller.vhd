library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sync_controller is
	port (
		i_clk			: in	std_logic;
		i_rst			: in	std_logic;
		o_h_sync		: out	std_logic;
		o_v_sync		: out	std_logic;
		o_h_buf_sync	: out	std_logic;
		o_v_buf_sync	: out	std_logic;
		o_blank			: out	std_logic
	);
end entity sync_controller;

architecture RTL of sync_controller is

	constant C_HD	: integer := 799;	--Horizontal definition
	constant C_HFP	: integer := 24;	--Horizontal front porch
	constant C_HSP	: integer := 72;	--Horizontal sync pulse
	constant C_HBP	: integer := 100;	--Horizontal back porch
	
	constant C_VD	: integer := 479;	--Vertical definition
	constant C_VFP	: integer := 1;		--Vertical front porch
	constant C_VSP	: integer := 7;		--Vertical sync pulse
	constant C_VBP	: integer := 30;	--Vertical back porch
	
	signal r_H_Pos	: integer := 0;	--horizontal position
	signal r_V_Pos	: integer := 0;	--vertical position	
	
begin

	POSITION : process(i_clk, i_rst)
	begin
		if i_rst = '1' then
			r_H_Pos <= 0;
			r_V_Pos <= 0;
		elsif rising_edge(i_clk)  then
			if r_H_Pos < C_HD + C_HFP + C_HSP + C_HBP then
				r_H_Pos <= r_H_Pos + 1;
			else
				r_H_Pos <= 0;
				if r_V_Pos < C_VD + C_VFP + C_VSP + C_VBP then
					r_V_Pos <= r_V_Pos + 1;
				else
					r_V_Pos <= 0;
				end if;
			end if;
		end if;
	end process;

	DISPLAY_SYNCS : process(i_clk)
	begin
		if rising_edge(i_clk) then
			if r_H_Pos > C_HD + C_HFP and r_H_Pos <= C_HD + C_HFP + C_HSP then
				o_h_sync <= '0';
			else
				o_h_sync <= '1';
			end if;
			if r_V_Pos > C_VD + C_VFP and r_V_Pos <= C_VD + C_VFP + C_VSP then
				o_v_sync <= '0';
			else
				o_v_sync <= '1';
			end if;
		end if;
	end process;

	BUFFER_SYNCS : process(i_clk)
	begin
		if rising_edge(i_clk) then
			if r_H_Pos = C_HD + C_HFP + C_HSP + C_HBP then
				if r_V_Pos = C_VD + C_VFP + C_VSP + C_VBP then
					o_v_buf_sync <= '1';
				else
					o_h_buf_sync <= '1';
				end if;
			else
				o_h_buf_sync <= '0';
				o_v_buf_sync <= '0';
			end if;
		end if;
	end process;

	O_BLANKING : process(i_clk)
	begin
		if rising_edge(i_clk) then
			if r_H_Pos > C_HD + 1 OR r_V_Pos > C_VD + 1 then
				o_blank <= '0';
			else
				o_blank <= '1';
			end if;
		end if;
	end process;

end architecture RTL;