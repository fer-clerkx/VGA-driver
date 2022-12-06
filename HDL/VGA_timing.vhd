library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.VGA_Char_Pkg.all;

entity VGA_timing is
    port (
        i_clk	: in std_logic;
        i_rst	: in std_logic;
    	
		o_h_sync	: out std_logic := not c_H_POL;
		o_v_sync	: out std_logic := not c_V_POL;
		o_blank		: out std_logic := not c_BLANK_POL;

		o_rd_addr	: out std_logic_vector(18 downto 0)
    );
end entity VGA_timing;

architecture RTL of VGA_timing is

	signal r_H_Pos	: integer range 0 to c_H_TOTAL-1 := 0;	--horizontal position
	signal r_V_Pos	: integer range 0 to c_V_TOTAL-1 := 0;	--vertical position

	signal r_H_Sync	: std_logic := not c_H_POL;
	signal r_V_Sync	: std_logic := not c_V_POL;
	signal r_Blank	: std_logic := not c_BLANK_POL;

begin

	INC : process(i_clk, i_rst)
	begin
		if i_rst = '1' then
			r_H_Pos <= 0;
			r_V_Pos <= 0;
		elsif rising_edge(i_clk) then
			--Increment horizontal pos
			if r_H_Pos < c_H_TOTAL-1 then
				r_H_Pos <= r_H_Pos + 1;
			else
				r_H_Pos <= 0;
				
				--Increment vertical pos
				if r_V_Pos < c_V_TOTAL-1 then
					r_V_Pos <= r_V_Pos + 1;
				else
					r_V_Pos <= 0;
				end if;
			end if;
		end if;
	end process;

	H_SYNC : process(r_H_Pos)
	begin
		if (r_H_Pos < c_H_ACTIVE + c_H_FP) or (r_H_Pos >= c_H_TOTAL - c_H_BP) then
			r_H_Sync <= not c_H_POL;
		else
			r_H_Sync <= c_H_POL;
		end if;
	end process;

	V_SYNC : process(r_V_Pos)
	begin
		if (r_V_Pos < c_V_ACTIVE + c_V_FP) or (r_V_Pos >= c_V_TOTAL - c_V_BP) then
			r_V_Sync <= not c_V_POL;
		else
			r_V_Sync <= c_V_POL;
		end if;
	end process;

	BLANK : process(r_H_Pos, r_V_Pos)
	begin
		if (r_H_Pos >= c_H_ACTIVE) or (r_V_Pos >= c_V_ACTIVE) then
			r_Blank <= c_BLANK_POL;
		else
			r_Blank <= not c_BLANK_POL;
		end if;
	end process;

	ADDR : process(r_H_Pos, r_V_Pos)
		variable v_H_Pos : integer range 0 to c_H_ACTIVE-1;
		variable v_V_Pos : integer range 0 to c_V_ACTIVE-1;
		variable v_Addr : integer range 0 to (c_H_ACTIVE*c_V_ACTIVe)-1;
	begin
		if r_H_Pos < c_H_ACTIVE then
			v_H_Pos := r_H_Pos;
		else
			v_H_Pos := c_H_ACTIVE-1;
		end if;
		if r_V_Pos < c_V_ACTIVE then
			v_V_Pos := r_V_Pos;
		else
			v_V_Pos := c_V_ACTIVE-1;
		end if;	
		v_Addr := v_H_Pos + (v_V_Pos * c_H_ACTIVE);
		o_rd_addr <= std_logic_vector(to_unsigned(v_Addr, 19));
	end process;

	DELAY : process(i_clk, i_rst)
	begin
		if i_rst = '1' then
			o_h_sync <= not c_H_POL;
			o_v_sync <= not c_V_POL;
			o_blank <= not c_BLANK_POL;
		elsif rising_edge(i_clk) then
			o_h_sync <= r_H_Sync;
			o_v_sync <= r_V_Sync;
			o_blank <= r_Blank;
		end if;
	end process;

end architecture RTL;