-- IO DECODER for SCOMP
-- This eliminates the need for a lot of AND decoders or Comparators 
--    that would otherwise be spread around the top-level BDF

LIBRARY IEEE;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY IO_DECODER IS

  PORT
  (
    IO_ADDR       : IN STD_LOGIC_VECTOR(10 downto 0);
    IO_CYCLE      : IN STD_LOGIC;
    SWITCH_EN     : OUT STD_LOGIC;
    LED_EN        : OUT STD_LOGIC;
    TIMER_EN      : OUT STD_LOGIC;
    HEX0_EN       : OUT STD_LOGIC;
    HEX1_EN       : OUT STD_LOGIC;
    I2C_CMD_EN    : OUT STD_LOGIC;
    I2C_DATA_EN   : OUT STD_LOGIC;
    I2C_RDY_EN    : OUT STD_LOGIC;
    DP_EN         : OUT STD_LOGIC;
	 INC_EN			: OUT STD_LOGIC;
	 QD_EN			: OUT STD_LOGIC;
	 PWM_EN			: OUT STD_LOGIC;
	 KEY_EN			: OUT	STD_LOGIC;
	 RPM_EN			: OUT STD_LOGIC;
	 VCTR_EN			: OUT STD_LOGIC;
	 PCTR_EN			: OUT STD_LOGIC
  );

END ENTITY;

ARCHITECTURE a OF IO_DECODER IS

  SIGNAL  ADDR_INT  : INTEGER RANGE 0 TO 2047;
  
begin

  ADDR_INT <= TO_INTEGER(UNSIGNED(IO_ADDR));
        
  SWITCH_EN    <= '1' WHEN (ADDR_INT = 16#000#) and (IO_CYCLE = '1') ELSE '0';
  LED_EN       <= '1' WHEN (ADDR_INT = 16#001#) and (IO_CYCLE = '1') ELSE '0';
  TIMER_EN     <= '1' WHEN (ADDR_INT = 16#002#) and (IO_CYCLE = '1') ELSE '0';
  HEX0_EN      <= '1' WHEN (ADDR_INT = 16#004#) and (IO_CYCLE = '1') ELSE '0';
  HEX1_EN      <= '1' WHEN (ADDR_INT = 16#005#) and (IO_CYCLE = '1') ELSE '0';
  RPM_EN 		<= '1' WHEN (ADDR_INT = 16#006#) and (IO_CYCLE = '1') ELSE '0';  
  KEY_EN 		<= '1' WHEN (ADDR_INT = 16#007#) and (IO_CYCLE = '1') ELSE '0';
  VCTR_EN 		<= '1' WHEN (ADDR_INT = 16#008#) and (IO_CYCLE = '1') ELSE '0';  
  PCTR_EN 		<= '1' WHEN (ADDR_INT = 16#009#) and (IO_CYCLE = '1') ELSE '0'; 
  I2C_CMD_EN   <= '1' WHEN (ADDR_INT = 16#090#) and (IO_CYCLE = '1') ELSE '0';
  I2C_DATA_EN  <= '1' WHEN (ADDR_INT = 16#091#) and (IO_CYCLE = '1') ELSE '0';
  I2C_RDY_EN   <= '1' WHEN (ADDR_INT = 16#092#) and (IO_CYCLE = '1') ELSE '0';
  DP_EN        <= '1' WHEN (ADDR_INT = 16#0E0#) and (IO_CYCLE = '1') ELSE '0';
  INC_EN			<= '1' WHEN (ADDR_INT = 16#0F0#) and (IO_CYCLE = '1') ELSE '0';
  QD_EN			<= '1' WHEN (ADDR_INT = 16#0F1#) and (IO_CYCLE = '1') ELSE '0';
  PWM_EN			<= '1' WHEN (ADDR_INT = 16#0F2#) and (IO_CYCLE = '1') ELSE '0';   
END a;

