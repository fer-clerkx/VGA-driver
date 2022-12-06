library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.VGA_Char_Pkg.all;

entity VGA_core is
	port (
		--Global interface
		i_wr_clk	: in std_logic;
		i_rd_clk	: in std_logic;
		i_rst		: in std_logic;
		i_buf_sel	: in std_logic;

		i_wr_req	: in t_WR_REQ;
		i_valid		: in std_logic;
		o_ready		: out std_logic;
		o_active	: out std_logic;

		--VGA interface
		o_h_sync	: out std_logic;
		o_v_sync	: out std_logic;
		o_blank		: out std_logic;
		o_pix		: out std_logic
	);
end entity VGA_core;

architecture RTL of VGA_core is

	signal w_V_Sync		: std_logic;
	signal r_V_Sync		: std_logic;
	signal w_Rd_Addr	: std_logic_vector(18 downto 0);
	signal w_Wr_Data	: std_logic_vector(7 downto 0);
	signal w_Wr_En		: std_logic;
	signal w_Wr_Addr	: std_logic_vector(15 downto 0);
	signal r_Buf_Sel	: std_logic := '0';
	signal w_Pix_1		: std_logic;
	signal w_Pix_2		: std_logic;

begin

	o_v_sync <= w_V_Sync;

	BUFFER_SELECT : process(i_wr_clk)
	begin
		if rising_edge(i_wr_clk) then
			r_Buf_Sel <= i_buf_sel;
		end if;
	end process;

	PIXEL_ROUTE : process(w_Pix_1, w_Pix_2, r_Buf_Sel)
	begin
		if r_Buf_Sel = '1' then
			o_pix <= w_Pix_1;
		else
			o_pix <= w_Pix_2;
		end if;
	end process;

	CROSS_DOMAIN : process(i_wr_clk)
	begin
		if rising_edge(i_wr_clk) then
			r_V_Sync <= w_V_Sync;
		end if;
	end process;

	INST_VGA_TIMING : entity work.VGA_timing(RTL)
	port map (
		i_clk		=> i_rd_clk,
		i_rst		=> i_rst,
		o_h_sync	=> o_h_sync,
		o_v_sync	=> w_V_Sync,
		o_blank		=> o_blank,
		o_rd_addr	=> w_Rd_Addr
	);

	INST_VGA_LOADER : entity work.VGA_loader(RTL)
	port map (
		i_clk		=> i_wr_clk,
		i_rst 		=> i_rst,
		i_wr_req	=> i_wr_req,
		i_valid		=> i_valid,
		o_ready		=> o_ready,
		o_active	=> o_active,
		o_wr_data	=> w_Wr_Data,
		o_wr_en		=> w_Wr_En,
		o_Wr_Addr	=> w_Wr_Addr,
		i_v_sync	=> r_V_Sync
	);

	INST_VGA_BUFFER_1 : entity work.VGA_framebuffer(SYN)
	port map (
		--Read interface
		rdaddress	=> w_Rd_Addr,
		rden		=> r_Buf_Sel,
		rdclock		=> i_rd_clk,
		q(0)		=> w_Pix_1,
		--Write interface
		data		=> w_Wr_Data,
		wraddress	=> w_Wr_Addr,
		wrclock		=> i_wr_clk,
		wren		=> w_Wr_En and not r_Buf_Sel
	);

	INST_VGA_BUFFER_2 : entity work.VGA_framebuffer(SYN)
	port map (
		--Read interface
		rdaddress	=> w_Rd_Addr,
		rden		=> not r_Buf_Sel,
		rdclock		=> i_rd_clk,
		q(0)		=> w_Pix_2,
		--Write interface
		data		=> w_Wr_Data,
		wraddress	=> w_Wr_Addr,
		wrclock		=> i_wr_clk,
		wren		=> w_Wr_En and r_Buf_Sel
	);

end architecture RTL;