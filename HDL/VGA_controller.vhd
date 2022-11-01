LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
LIBRARY WORK;

ENTITY VGA_controller IS
	PORT(
		I_CLK, I_RST : IN STD_LOGIC;
		I_INPUT : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		O_BLANK : OUT STD_LOGIC;
		O_H, O_V : OUT STD_LOGIC;
		O_CLK, O_LOCKED : OUT STD_LOGIC;
		O_RED, O_GREEN, O_BLUE : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END VGA_controller;

ARCHITECTURE behaviour OF VGA_controller IS
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
			  SEL  : IN INTEGER RANGE 0 TO 36;
			  H_LIB_SYNC : IN STD_LOGIC;
			  V_LIB_SYNC : IN STD_LOGIC;
			  PIX : OUT STD_LOGIC
		);
	END COMPONENT;
	
	COMPONENT video_controller
		PORT(clk     : IN STD_LOGIC;
		     rst     : IN STD_LOGIC;
			  mode	 : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			  a		 : IN INTEGER RANGE 0 TO 127;
			  b		 : IN INTEGER RANGE 0 TO 127;
			  c		 : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
			  oper	 : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			  answer0 : IN INTEGER RANGE 0 TO 7;
			  answer1 : IN INTEGER RANGE 0 TO 7;
			  reward0 : IN INTEGER RANGE 0 TO 7;
			  reward1 : IN INTEGER RANGE 0 TO 7;
			  h_sync  : IN STD_LOGIC;
			  v_sync  : IN STD_LOGIC;
			  sel     : OUT INTEGER RANGE 0 TO 36
		);
	END COMPONENT;
	
	SIGNAL w_h_sync : STD_LOGIC;
	SIGNAL w_v_sync : STD_LOGIC;
	SIGNAL h_lib_sync : STD_LOGIC := '0';
	SIGNAL v_lib_sync : STD_LOGIC := '0';
	SIGNAL w_clk : STD_LOGIC;
	SIGNAL w_sel : INTEGER RANGE 0 TO 36;
	SIGNAL w_rst : STD_LOGIC;
	SIGNAL w_pix : STD_LOGIC;

BEGIN
	O_CLK <= w_clk;
	w_rst <= NOT(I_RST);
	O_RED <= (OTHERS => w_pix);
	O_GREEN <= (OTHERS => w_pix);
	O_BLUE <= (OTHERS => w_pix);
	
	PROCESS(w_clk)
	BEGIN
		IF(rising_edge(w_clk)) THEN
			h_lib_sync <= w_h_sync;
			v_lib_sync <= w_v_sync;
		END IF;
	END PROCESS;
				
	sync : sync_controller
	PORT MAP(CLK => w_clk,
				RST => w_rst,
				H_SYNC => O_H,
				V_SYNC => O_V,
				H_BUF_SYNC => w_h_sync,
				V_BUF_SYNC => w_v_sync,
				BLANK => O_BLANK);
				
	manip: PLL
	PORT MAP(refclk => I_CLK,
		      rst => w_rst,
		      outclk_0 => w_clk,
		      locked => O_LOCKED);
		 
	lib : char_library
	PORT MAP(CLK => w_clk,
	         RST => w_rst,
				SEL => w_sel,
				H_LIB_SYNC => h_lib_sync,
				V_LIB_SYNC => v_lib_sync,
				PIX => w_pix);
				
	video : video_controller
	PORT MAP(clk => w_clk,
	         rst => w_rst,
				mode => I_INPUT,		--mode
				a => 0,	--a
				b => 127,		--b
				c => "011110010010",
				oper => "01",			--oper
				answer0 => 5,		--answer0
				answer1 => 3,		--answer1
				reward0 => 6,		--reward0
				reward1 => 0,		--reward1
				sel => w_sel,
				h_sync => w_h_sync,
				v_sync => w_v_sync);
END behaviour;