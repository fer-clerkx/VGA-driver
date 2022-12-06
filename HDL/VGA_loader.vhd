library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.VGA_Char_Pkg.all;

entity VGA_loader is
	port (
		--Global interface
		i_clk			: in	std_logic;
		i_rst			: in	std_logic;
		
		--User interface
		i_wr_req	: in t_WR_REQ;
		i_valid		: in std_logic;
		o_ready		: out std_logic;
		o_active	: out std_logic;

		--Buffer interface
		o_wr_data	: out std_logic_vector(7 downto 0);
		o_wr_en		: out std_logic;
		o_wr_addr	: out std_logic_vector(15 downto 0);

		--Timing interface
		i_v_sync	: in std_logic
		);
end entity VGA_loader;

architecture RTL of VGA_loader is

	signal r_Wr_Req : t_WR_REQ := (sel => 0,
								   scale => 0,
								   h_addr => 0,
								   v_addr => 0);
	signal r_H_Offset : integer range 0 to 7 := 0;
	signal r_V_Offset : integer range 0 to 79 := 0;
	signal r_State : integer range 0 to 1 := 0;

begin

	HANDSHAKE_FSM : process(i_clk, i_rst)
	begin
		if i_rst = '1' then
			o_ready <= '0';
			r_State <= 0;
			o_wr_en <= '0';
		elsif rising_edge(i_clk) then
			case r_State is
				when 0 =>
					o_wr_en <= '0';
					if i_v_sync = c_V_POL then
						o_active <= '0';
						o_ready <= '1';
						r_H_Offset <= 0;
						r_V_Offset <= 0;
						if o_ready = '1' and i_valid = '1' then
							r_Wr_Req <= i_wr_req;
							o_Ready <= '0';
							r_State <= 1;
						end if;
					else
						o_active <= '1';
						o_ready <= '0';
					end if;
				
				when 1 =>
					o_ready <= '0';
					o_wr_en <= '1';

					if i_v_sync = not c_V_POL then
						r_State <= 0;
						r_H_Offset <= 0;
						r_V_Offset <= 0;
						o_active <= '1';
						o_wr_en <= '0';
					elsif r_H_Offset < 2**r_Wr_Req.scale - 1 then
						r_H_Offset <= r_H_Offset + 1;
					elsif r_V_Offset < 10 * 2**r_Wr_Req.scale - 1 then
						r_H_Offset <= 0;
						r_V_Offset <= r_V_Offset + 1;
					else
						r_State <= 0;
						o_ready <= '1';
					end if;
						
			end case;
		end if;
	end process;

	LOAD : process(i_clk)
		variable v_H_Addr	: integer range 0 to c_H_ACTIVE-1;
		variable v_V_Addr	: integer range 0 to c_V_ACTIVE-1;
		variable v_Wr_Addr	: integer range 0 to c_H_ACTIVE*c_V_ACTIVE-1;
		variable v_Wr_Data	: std_logic_vector(7 downto 0);
	begin
		if rising_edge(i_clk) then
			if r_State = 1 then
				-- Frame limit
				if r_Wr_Req.h_addr + r_H_Offset*8 > c_H_ACTIVE-8 then
					v_H_Addr := c_H_ACTIVE-8;
				else
					v_H_Addr := r_Wr_Req.h_addr + r_H_Offset*8;
				end if;
				if r_Wr_Req.v_addr + r_V_Offset > c_V_ACTIVE-1 then
					v_V_Addr := c_V_ACTIVE-1;
				else
					v_V_Addr := r_Wr_Req.v_addr + r_V_Offset;
				end if;
				v_Wr_Addr := (v_H_Addr + (v_V_Addr*c_H_ACTIVE))/8;
				o_wr_addr <= std_logic_vector(to_unsigned(v_Wr_Addr, 16));
				
				for i in 0 to 7 loop
					v_Wr_Data(i) := c_LIB(r_Wr_Req.sel)(r_V_Offset / 2**r_Wr_Req.scale)(i);
				end loop;
				case r_Wr_Req.scale is
					when 0 =>
						o_wr_data(7 downto 0) <= v_Wr_Data;
					when 1 =>
						o_wr_data(7 downto 6) <= (others => v_Wr_Data(3 + r_H_Offset*4));
						o_wr_data(5 downto 4) <= (others => v_Wr_Data(2 + r_H_Offset*4));
						o_wr_data(3 downto 2) <= (others => v_Wr_Data(1 + r_H_Offset*4));
						o_wr_data(1 downto 0) <= (others => v_Wr_Data(0 + r_H_Offset*4));
					when 2 =>
						o_wr_data(7 downto 4) <= (others => v_Wr_Data(1 + r_H_Offset*2));
						o_wr_data(3 downto 0) <= (others => v_Wr_Data(0 + r_H_Offset*2));
					when 3 =>
						o_wr_data(7 downto 0) <= (others => v_Wr_Data(r_H_Offset));
				end case;
			end if;
		end if;
	end process;
	
end architecture RTL;