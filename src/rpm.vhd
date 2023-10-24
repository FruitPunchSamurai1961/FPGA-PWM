LIBRARY IEEE;
LIBRARY LPM;

USE IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
USE LPM.LPM_COMPONENTS.ALL;

ENTITY rpm IS
	PORT(
		-- At least IO_DATA and a chip select are needed.  Even though
		-- this device will only respond to IN, IO_WRITE is included so
		-- that this device doesn't drive the bus during an OUT.
		velocity 	 : IN    STD_LOGIC_VECTOR(15 DOWNTO 0);
		CLK          : IN    STD_LOGIC;
		RESETN       : IN    STD_LOGIC;
		CS           : IN    STD_LOGIC;
		IO_WRITE     : IN    STD_LOGIC;
		IO_DATA      : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0)
		
	);
END rpm;

ARCHITECTURE a OF rpm IS
	SIGNAL tri_enable : STD_LOGIC; -- enable signal for the tri-state driver
	
	-- We have two because this will be used to display the velocity. We need to keep track of the most recent velocity before the newrate became 0.
	SIGNAL oldrate  : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL newrate  : STD_LOGIC_VECTOR(15 DOWNTO 0);

	BEGIN
	
	tri_enable <= CS and (not IO_WRITE); -- only drive IO_DATA during IN
	
	-- Use LPM function to create tri-state driver for IO_DATA
	IO_BUS: lpm_bustri
	GENERIC MAP (
		lpm_width => 16
	)
	PORT MAP (
		data     => oldrate,   -- Put the value on IO_DATA during IN
		enabledt => tri_enable,
		tridata  => IO_DATA
	);


	
	PROCESS (RESETN, CLK)
	BEGIN
		IF RESETN = '0' THEN
			newrate <= x"0000";
			oldrate <= x"0000";
		ELSIF RISING_EDGE(CLK) THEN
			oldrate <= newrate;
			newrate <= velocity;
		END IF;
	END PROCESS;

END a;

