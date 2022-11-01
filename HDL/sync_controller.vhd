LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY sync_controller is
	PORT (
			CLK			:	in		STD_LOGIC;
			RST			:	in		STD_LOGIC;
			H_SYNC		:	out	STD_LOGIC;
			V_SYNC		:	out	STD_LOGIC;
			H_BUF_SYNC	: 	out	STD_LOGIC;
			V_BUF_SYNC	:	out 	STD_LOGIC;
			BLANK			:	out	STD_LOGIC
		);
END sync_controller;

ARCHITECTURE behaviour OF sync_controller IS
	constant HD		:	integer	:=	799;	--Horizontal definition
	constant HFP	:	integer	:=	24;	--Horizontal front porch
	constant HSP	:	integer	:=	72;	--Horizontal sync pulse
	constant HBP	:	integer	:=	100;	--ho rizontal back porch
	
	constant VD		:	integer	:=	479;	--Vertical definition
	constant VFP	:	integer	:=	1;	--Vertical front porch
	constant VSP	:	integer	:=	7;		--Vertical sync pulse
	constant VBP	:	integer	:=	30;	--Vertical back porch
	
	signal H_POS	: integer := 0;	--horizontal position
	signal V_POS	: integer := 0;	--vertical position	

	
BEGIN

position:PROCESS(CLK, RST)
BEGIN
	IF(RST = '1') THEN
		H_POS <= 0;
		V_POS <= 0;
	ELSIF(rising_edge(CLK)) THEN
		IF(H_POS < HD + HFP + HSP + HBP) THEN
			H_POS <= H_POS + 1;
		ELSE
			H_POS <= 0;
			IF(V_POS < VD + VFP + VSP + VBP) THEN
				V_POS <= V_POS + 1;
			ELSE
				V_POS <= 0;
			END IF;
		END IF;
	END IF;
END PROCESS;

diplay_syncs:PROCESS(CLK)
BEGIN
	IF(rising_edge(CLK)) THEN
		IF(H_POS > HD + HFP AND H_POS <= HD + HFP + HSP) THEN
			H_SYNC <= '0';
		ELSE
			H_SYNC <= '1';
		END IF;
		IF(V_POS > VD + VFP AND V_POS <= VD + VFP + VSP) THEN
			V_SYNC <= '0';
		ELSE
			V_SYNC <= '1';
		END IF;
	END IF;
END PROCESS;

buffer_syncs:PROCESS(CLK)
BEGIN
	IF(rising_edge(CLK)) THEN
		IF(H_POS = HD + HFP + HSP + HBP) THEN
			IF(V_POS = VD + VFP + VSP + VBP) THEN
				V_BUF_SYNC <= '1';
			ELSE
				H_BUF_SYNC <= '1';
			END IF;
		ELSE
			H_BUF_SYNC <= '0';
			V_BUF_SYNC <= '0';
		END IF;
	END IF;
END PROCESS;

Blanking:PROCESS(CLK)
BEGIN
	IF(rising_edge(CLK)) THEN
		IF(H_POS > HD + 1 OR V_POS > VD + 1) THEN
			BLANK <= '0';
		ELSE
			BLANK <= '1';
		END IF;
	END IF;
END PROCESS;
end behaviour;