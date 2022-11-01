LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY sync_controller is
	PORT (
		I_CLK				: in	STD_LOGIC;
		I_RST				: in	STD_LOGIC;
		O_H_SYNC			: out	STD_LOGIC;
		O_V_SYNC			: out	STD_LOGIC;
		O_H_BUF_SYNC	: out	STD_LOGIC;
		O_V_BUF_SYNC	: out	STD_LOGIC;
		O_BLANK			: out	STD_LOGIC
	);
END ENTITY sync_controller;

ARCHITECTURE RTL OF sync_controller IS

	constant C_HD	:	integer	:=	799;	--Horizontal definition
	constant C_HFP	:	integer	:=	24;	--Horizontal front porch
	constant C_HSP	:	integer	:=	72;	--Horizontal sync pulse
	constant C_HBP	:	integer	:=	100;	--ho rizontal back porch
	
	constant C_VD	:	integer	:=	479;	--Vertical definition
	constant C_VFP	:	integer	:=	1;		--Vertical front porch
	constant C_VSP	:	integer	:=	7;		--Vertical sync pulse
	constant C_VBP	:	integer	:=	30;	--Vertical back porch
	
	signal H_POS	: integer := 0;	--horizontal position
	signal V_POS	: integer := 0;	--vertical position	

	
BEGIN

position:PROCESS(I_CLK, I_RST)
BEGIN
	IF(I_RST = '1') THEN
		H_POS <= 0;
		V_POS <= 0;
	ELSIF(rising_edge(I_CLK)) THEN
		IF(H_POS < C_HD + C_HFP + C_HSP + C_HBP) THEN
			H_POS <= H_POS + 1;
		ELSE
			H_POS <= 0;
			IF(V_POS < C_VD + C_VFP + C_VSP + C_VBP) THEN
				V_POS <= V_POS + 1;
			ELSE
				V_POS <= 0;
			END IF;
		END IF;
	END IF;
END PROCESS;

diplay_syncs:PROCESS(I_CLK)
BEGIN
	IF(rising_edge(I_CLK)) THEN
		IF(H_POS > C_HD + C_HFP AND H_POS <= C_HD + C_HFP + C_HSP) THEN
			O_H_SYNC <= '0';
		ELSE
			O_H_SYNC <= '1';
		END IF;
		IF(V_POS > C_VD + C_VFP AND V_POS <= C_VD + C_VFP + C_VSP) THEN
			O_V_SYNC <= '0';
		ELSE
			O_V_SYNC <= '1';
		END IF;
	END IF;
END PROCESS;

buffer_syncs:PROCESS(I_CLK)
BEGIN
	IF(rising_edge(I_CLK)) THEN
		IF(H_POS = C_HD + C_HFP + C_HSP + C_HBP) THEN
			IF(V_POS = C_VD + C_VFP + C_VSP + C_VBP) THEN
				O_V_BUF_SYNC <= '1';
			ELSE
				O_H_BUF_SYNC <= '1';
			END IF;
		ELSE
			O_H_BUF_SYNC <= '0';
			O_V_BUF_SYNC <= '0';
		END IF;
	END IF;
END PROCESS;

O_BLANKing:PROCESS(I_CLK)
BEGIN
	IF(rising_edge(I_CLK)) THEN
		IF(H_POS > C_HD + 1 OR V_POS > C_VD + 1) THEN
			O_BLANK <= '0';
		ELSE
			O_BLANK <= '1';
		END IF;
	END IF;
END PROCESS;
end architecture RTL;