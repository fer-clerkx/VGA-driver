LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
LIBRARY WORK;

ENTITY VGA_controller IS
	PORT(
		I_CLK, I_RST : IN STD_LOGIC;
		O_RED, O_BLANK : OUT STD_LOGIC;
		O_H, O_V : OUT STD_LOGIC;
		O_CLK, O_LOCKED : OUT STD_LOGIC;
		O_GREEN, O_BLUE : OUT STD_LOGIC
	);
END VGA_controller;

ARCHITECTURE behaviour OF VGA_controller IS

	COMPONENT char_buffer
		PORT(CLK				   : IN STD_LOGIC;
			  RST				   : IN STD_LOGIC;
			  DATA				: IN STD_LOGIC_VECTOR(6 DOWNTO 0);
			  H_BUFFER_SYNC	: IN STD_LOGIC;
			  V_BUFFER_SYNC	: IN STD_LOGIC;
			  R_ENABLE			: IN STD_LOGIC;
			  PIX_OUT	      : OUT STD_LOGIC
		);
	END COMPONENT;

	COMPONENT sync_controller
		PORT(CLK			   : in STD_LOGIC;
			  RST			   : in STD_LOGIC;
			  H_SYNC		   : out STD_LOGIC;
			  V_SYNC		   : out STD_LOGIC;
			  H_BUF_SYNC	: out STD_LOGIC;
			  V_BUF_SYNC	: out STD_LOGIC;
			  BLANK			: out STD_LOGIC
		);
	END COMPONENT;
	
	COMPONENT PLL
		PORT(refclk : IN STD_LOGIC;
			  rst : IN STD_LOGIC;
			  outclk_0 : OUT STD_LOGIC;
			  locked : OUT STD_LOGIC
		);
	END COMPONENT;
	
	COMPONENT char_library
		PORT(CLK  : IN STD_LOGIC;
		     RST  : IN STD_LOGIC;
			  SEL  : IN INTEGER RANGE 0 TO 27;
			  DATA : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
		);
	END COMPONENT;
	
	COMPONENT video_controller
		PORT(clk     : IN STD_LOGIC;
		     rst     : IN STD_LOGIC;
			  sel     : OUT INTEGER RANGE 0 TO 27;
			  enable  : OUT STD_LOGIC;
			  lib_rst : OUT STD_LOGIC;
			  buf_rst : OUT STD_LOGIC
		);
	END COMPONENT;
	
	SIGNAL w_h_sync : STD_LOGIC;
	SIGNAL w_v_sync : STD_LOGIC;
	SIGNAL w_clk : STD_LOGIC;
	SIGNAL w_pix : STD_LOGIC;
	SIGNAL w_data : STD_LOGIC_VECTOR(6 DOWNTO 0);
	SIGNAL w_sel : INTEGER RANGE 0 TO 27;
	SIGNAL w_read : STD_LOGIC;
	SIGNAL w_lib_rst : STD_LOGIC;
	SIGNAL w_buf_rst : STD_LOGIC;

BEGIN
	O_CLK <= w_clk;
	O_RED <= w_pix;
	O_GREEN <= w_pix;
	O_BLUE <= w_pix;

	buf : char_buffer
	PORT MAP(CLK => w_clk,
				RST => w_buf_rst,
				DATA => w_data,
				H_BUFFER_SYNC => w_h_sync,
				V_BUFFER_SYNC => w_v_sync,
				R_ENABLE => w_read,
				PIX_OUT => w_pix);
				
	sync : sync_controller
	PORT MAP(CLK => w_clk,
				RST => NOT(I_RST),
				H_SYNC => O_H,
				V_SYNC => O_V,
				H_BUF_SYNC => w_h_sync,
				V_BUF_SYNC => w_v_sync,
				BLANK => O_BLANK);
				
	divider : PLL
	PORT MAP(refclk => I_CLK,
		      rst => NOT(I_RST),
		      outclk_0 => w_clk,
		      locked => O_LOCKED);
		 
	lib : char_library
	PORT MAP(CLK => w_clk,
	         RST => w_lib_rst,
				SEL => w_sel,
				DATA => w_data);
				
	video : video_controller
	PORT MAP(clk => w_clk,
	         rst => NOT(I_RST),
				sel => w_sel,
				enable => w_read,
				lib_rst => w_lib_rst,
				buf_rst => w_buf_rst);
END behaviour;