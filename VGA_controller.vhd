LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY vga_controller is
	PORT (
			CLK			:	in		STD_LOGIC;
			RST			:	in		STD_LOGIC;
			H_SYNC		:	out	STD_LOGIC;
			V_SYNC		:	out	STD_LOGIC;
			H_POS_BUFFER: 	out	STD_LOGIC;
			V_POS_BUFFER:	out 	STD_LOGIC;
			BLANK			:	out	STD_LOGIC
		);
END vga_controller;

ARCHITECTURE behaviour OF vga_controller IS
	constant HD		:	integer	:=	639;	--Horizontal definition
	constant HFP	:	integer	:=	16;	--Horizontal front porch
	constant HSP	:	integer	:=	96;	--Horizontal sync pulse
	constant HBP	:	integer	:=	48;	--ho rizontal back porch
	
	constant VD		:	integer	:=	479;	--Vertical definition
	constant VFP	:	integer	:=	10;	--Vertical front porch
	constant VSP	:	integer	:=	2;		--Vertical sync pulse
	constant VBP	:	integer	:=	33;	--Vertical back porch
	
	signal H_POS	: integer := 0;	--horizontal position
	signal V_POS	: integer := 0;	--vertical position	

	
BEGIN

Horizontal_position:process(CLK,RST)
BEGIN
	if(RST = '1') then
		H_POS <= 0;
	elsif(rising_edge(CLK)) then
		if(H_POS = (HD + HFP + HSP + HBP)) then
			H_POS <= 0;
		else
			H_POS <= H_POS + 1;
		end if;
	end if;
end process;

Vertical_position:process(CLK,RST)
BEGIN
	if(RST = '1') then
		V_POS <= 0;
	elsif(rising_edge(CLK)) then
		if(H_POS = (HD + HFP + HSP + HBP)) then
			if (V_POS = (VD + VFP + VSP + VBP)) then
				V_POS <= 0;
			else
				V_POS <= V_POS + 1;
			end if;
		end if;
	end if;
end process;

Horizontal_sync:process(CLK,RST,H_POS)
BEGIN
	if(RST = '1') then
		H_SYNC <= '0';
	elsif(rising_edge(CLK)) then
		if((H_POS <= (HD + HFP)) or (H_POS > (HD + HSP + HFP))) then
			H_SYNC <= '1';
		else
			H_SYNC <= '0';
			H_POS_BUFFER <= '1';
		end if;
	end if;
end process;

Vertical_sync:process(CLK,RST,V_POS)
BEGIN
	if(RST = '1') then
		V_SYNC <= '0';
	elsif(rising_edge(CLK)) then
		if((V_POS <= (VD + VFP)) or (V_POS > (VD + VSP + VFP))) then
			V_SYNC <= '1';
		else
			V_SYNC <= '0';
			V_POS_BUFFER <= '1';
		end if;
	end if;
end process;

Blanking:PROCESS(CLK,RST)
BEGIN
	IF(RST = '1') THEN
		BLANK <= '0';
	ELSIF(rising_edge(CLK)) THEN
		IF((H_POS > HD) OR (V_POS > VD)) THEN
			BLANK <= '0';
		ELSE
			BLANK <= '1';
		END IF;
	END IF;
END PROCESS;
end architecture;