LIBRARY IEEE;
LIBRARY LPM;

USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE LPM.LPM_COMPONENTS.ALL;


ENTITY Velocity_Control IS
    PORT(VClock,
        RESETN,
        CS          : IN 	 STD_LOGIC;
        Position    : IN 	 STD_LOGIC_VECTOR(15 DOWNTO 0);
		  IO_WRITE    : IN    STD_LOGIC;
		  IO_DATA     : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		  Velocity	  : INOUT   STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
END Velocity_Control;

ARCHITECTURE a OF Velocity_Control IS
	SIGNAL	OldPosition		 : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL	newPosition 	 : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL	Currvelocity	 : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL	desiredVelocity : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL	moveToMake		 : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL	countTillTen	 : STD_LOGIC_VECTOR(3  DOWNTO 0);
	
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
	
   IO_Handler: PROCESS (RESETN, CS,IO_WRITE)
    BEGIN

        IF (RESETN = '0') THEN
            desiredVelocity <= x"0000";
        ELSIF (rising_edge(CS) AND IO_WRITE = '1') THEN -- on an OUT, we take in whatever value was put onto the bus
            desiredVelocity <= IO_DATA(15 DOWNTO 0);
        END IF;

    END PROCESS;
	
	
	PROCESS(RESETN,VClock)
	BEGIN
		IF RESETN = '0' THEN
			newPosition <= x"0000";
			oldPosition <= x"0000";
			Currvelocity <= x"0000";
			countTillTen <= "0000";
			state <= init;
		ELSIF RISING_EDGE(VClock) THEN
			-- Have a counter that counts till 10, then simply do new-old to get velocity which will be in Counts/Sec. 10hz is .1 so waiting for ten cycles is 1 second.
			-- Once we get the velocity, and the desired velocity, we can 
			IF countTillTen = "1010" THEN
				oldPosition <= newPosition;
				newPosition <= Position;
				Currvelocity <= (newPosition - oldPosition);
				countTillTen <= "0000";
				
				-- Now, we check if the velocity is within the range of +-5rpm, if so, we send a STOP output else we send a forward or backwards output for each stage
				CASE state IS
					WHEN init=>
						IF desiredVelocity + 5 < Currvelocity THEN
							state <= backward;
						ELSIF Currvelocity < desiredVelocity - 5 THEN
							state <= forward;
						ELSE
							state <= stay;
						END IF;
					
					WHEN forward=>
						IF desiredVelocity + 5 < Currvelocity THEN
							state <= backward;
						ELSIF Currvelocity < desiredVelocity - 5 THEN
							state <= forward;
						ELSE
							state <= stay;
						END IF;
						
					WHEN backward=>
						IF desiredVelocity + 5 < Currvelocity THEN
							state <= backward;
						ELSIF Currvelocity < desiredVelocity - 5 THEN
							state <= forward;
						ELSE
							state <= stay;
						END IF;
						
					WHEN stay=>
						IF desiredVelocity + 5 < Currvelocity THEN
							state <= backward;
						ELSIF Currvelocity < desiredVelocity - 5 THEN
							state <= forward;
						ELSE
							state <= stay;
						END IF;						
					WHEN others=>
						state <= init;
				END CASE;
				ELSE
					countTillTen <= countTillTen + 1;
			END IF;
		END IF;
	END PROCESS;
	
	-- for each process, we define a forward and backwards motion
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
