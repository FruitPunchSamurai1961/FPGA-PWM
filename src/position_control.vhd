LIBRARY IEEE;
LIBRARY LPM;

USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE LPM.LPM_COMPONENTS.ALL;


ENTITY position_control IS
    PORT(CLK,
        RESETN,
        CS          : IN 	 STD_LOGIC;
        Position    : IN    STD_LOGIC_VECTOR(15 DOWNTO 0);
		  IO_WRITE    : IN    STD_LOGIC;
		  IO_DATA     : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
END position_control;

ARCHITECTURE a OF position_control IS
	SIGNAL	desiredPosition : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL	moveToMake		 : STD_LOGIC_VECTOR(15 DOWNTO 0);


	
	SIGNAL IO_OUT    : STD_LOGIC;
	
	
	TYPE state_type is (init, stay,forward,backward);
	SIGNAL state : state_type;
	
	BEGIN
	IO_BUS: lpm_bustri
	GENERIC MAP (
		lpm_width => 16
	)
	PORT MAP (
		data     => moveToMake,
		enabledt => IO_OUT,
		tridata  => IO_DATA
	);
	
	IO_OUT <= (CS AND NOT(IO_WRITE));
	
	
	-- This process is for handling the data that will be recieved from SCOMP
   IO_Handler: PROCESS (RESETN, CS, IO_WRITE)
    BEGIN

        IF (RESETN = '0') THEN
            desiredPosition <= x"0000";
        ELSIF (rising_edge(CS) AND IO_WRITE = '1') THEN -- on an OUT, we take in whatever value was put onto the bus
            desiredPosition <= IO_DATA(15 DOWNTO 0);
        END IF;

    END PROCESS;
	
	 
	

	-- This is basically a state machine where we keep checking where we are and which state we should go to
	-- If we're in stay, we stay there until the desired Position is changed
	-- In all states, we check if the Position we're at is the in the range of desired - 12 <= curr <= desired + 12
	PROCESS(RESETN,CLK)
	BEGIN
		IF RESETN = '0' THEN
			state <= init;
		ELSIF RISING_EDGE(CLK) THEN
			CASE state IS
				WHEN init=>
					IF desiredPosition + 12 < Position THEN
						state <= backward;
					ELSIF Position < desiredPosition - 12 THEN
						state <= forward;
					ELSE
						state <= stay;
					END IF;
				
				WHEN forward=>
					IF desiredPosition + 12 < Position THEN
						state <= backward;
					ELSIF Position < desiredPosition - 12 THEN
						state <= forward;
					ELSE
						state <= stay;
					END IF;
					
				WHEN backward=>
					IF desiredPosition + 12 < Position THEN
						state <= backward;
					ELSIF Position < desiredPosition - 12 THEN
						state <= forward;
					ELSE
						state <= stay;
					END IF;
					
				WHEN stay=>
					IF desiredPosition + 12 < Position THEN
						state <= backward;
					ELSIF Position < desiredPosition - 12 THEN
						state <= forward;
					ELSE
						state <= stay;
					END IF;					
				WHEN others=>
					state <= init;
			END CASE;
		END IF;
	END PROCESS;
	
	process (state)
	begin
		case state is
			when init =>
				moveToMake <= "0000000000000000";
			when stay =>
				moveToMake <= "0000000000000000";
			when backward =>
				moveToMake <= "0000000000101111";
			when forward =>
				moveToMake <= "0000000000011111";
			when others =>
				moveToMake <= "0000000000000000";
		end case;
	end process;
END a;
