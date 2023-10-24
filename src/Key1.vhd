LIBRARY IEEE;
LIBRARY LPM;

USE IEEE.STD_LOGIC_1164.ALL;
USE LPM.LPM_COMPONENTS.ALL;

ENTITY KEY1 IS
PORT (    CS          : IN    STD_LOGIC;
			 KeyPress    : IN    STD_LOGIC;
			 IO_DATA     : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	 );
END KEY1;

ARCHITECTURE a OF KEY1 IS
  SIGNAL B_DI : STD_LOGIC_VECTOR(15 DOWNTO 0);
  CONSTANT CONST: STD_LOGIC_VECTOR(14 DOWNTO 0) := "000000000000000";

  BEGIN
    -- Use LPM function to create bidirectional I/O data bus
    IO_BUS: lpm_bustri
    GENERIC MAP (
      lpm_width => 16
    )
    PORT MAP (
      data     => B_DI,
      enabledt => CS,
      tridata  => IO_DATA
    );

    PROCESS
    BEGIN
      WAIT UNTIL RISING_EDGE(CS);
      B_DI <= CONST & NOT(KeyPress); -- sample the input on the rising edge of CS
    END PROCESS;

END a;
