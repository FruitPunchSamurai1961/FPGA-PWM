; Program that runs position control and velocity control
; The idea is to have user input Position A, which the QD then gets to, POSITION B, which QD gets to
; We can also then output the distance between the two for the user to know
; Then, the user specifices the time, and we get a velocity that we have the QD get to which will then be outputted to the user

; The problem to solve: User only has the starting point and the ending point and the time to reach it. Our use case is someone who wants to know the distance between the two and the velocity they'll
; have to go in order to reach their chosen spots.

; One cool thing we can also implement is asking user for the general speed limit, and using that we can tell them whether or not they'll be able to make it in time.


ORG 0
; Main Function. Currently just asks for inital position, then calls position control and then outputs it to hex display, does the same for B. Finally outputs the velocity that the user should travel at.
Start:
	CALL	GetPositionA
	CALL	PerformPositionControl
	CALL	DisplayQD
	CALL	GetPositionB
	CALL	PerformPositionControl
	CALL	DisplayQD
	CALL	GetTimeInput
	CALL	PerformVelocityControl
	CALL	DisplayRPM
	JUMP	Done
	
; -----------------------------------------------------------------------CODE FOR POSITION A----------------------------------------------------------------------------------------------------------------
; Keep looping until Key1 is pressed which means that user has selected the position they'll like for A
GetPositionA:
	IN		Key1
	AND		Bit0
	JPOS	InputPositionA
	JUMP	GetPositionA

; If we get here, that means that the user has given us a position via Switches. Get that value, store in memory just in case, and then give it to the PositionCont Periphal
InputPositionA:
	IN		Switches
	STORE	PosA
	OUT		PositionCont
	RETURN
	

; -----------------------------------------------------------------------CODE FOR POSITION B----------------------------------------------------------------------------------------------------------------


; Keep looping until Key1 is pressed which means that user has selected the position they'll like for B
GetPositionB:
	IN		Key1
	AND		Bit0
	JPOS	InputPositionB
	JUMP	GetPositionB

; If we get here, that means that the user has given us a position via Switches. Get that value, store in memory just in case, and then give it to the PositionCont Periphal
InputPositionB:
	IN		Switches
	STORE	PosB
	OUT		PositionCont
	RETURN

	

; -----------------------------------------------------------------------CODE FOR Time Input----------------------------------------------------------------------------------------------------------------

; Same as the other. Keep waiting till the user inputs the time they'll like to reach the said location in.
GetTimeInput:
	IN		Key1
	AND		Bit0
	JPOS	InputTime
	JUMP	GetTimeInput


;; Get time, and then load posB and subtract from it posA. We have the change in position and all we have to do is divide with the change in time.
InputTime:
	IN		Switches
	STORE	Time
	LOAD	PosB
	SUB		PosA
	STORE	Dist
	JUMP	CalcVelc

; TODO: I think we can just have a function that either keeps adding or keeps subtracting till we can't anymore e.g. -4/2 => would be -2/2 (add one to velocity) then 0/2 add one to (velocity)
; Once we get the desired velocity just give that value to the Velocity_Control Periphal
CalcVelc:
	NOP
	RETURN	



; -------------------------------------------------------------- General Function to Calculate Position and Calcuate Velocity ------------------------------------------------------------------------------
; Here, we should output whatever ever direction PositionCont wants the QD to go in, send that to PWM which will cause the Motor to move in said direction.
; When the PositionCont Output is zero, we know we're at the correction position, so we can just return
PerformPositionControl:
	IN		PositionCont
	OUT		HEX0
	OUT		PWM
	JPOS	PerformPositionControl
	JNEG	PerformPositionControl
	RETURN

PerformVelocityControl:
	IN		VelocityCont
	OUT		HEX0
	IN		VelocityCont
	OUT		PWM
	JPOS	PerformVelocityControl
	JNEG	PerformVelocityControl
	RETURN




;; Infinite Loop	
Done:
	JUMP	Done


; Helper Functions to "print" onto the HEX Display. Helps with Debugging
DisplayQD:
	IN		QD
	OUT		HEX0
	RETURN

DisplayRPM:
	IN		RPM
	OUT		HEX0
	RETURN

DisplayPositionControl:
	IN		PositionCont
	OUT		HEX0
	RETURN
	


; Use for storing Values and others are values to use for easy-to-read assembly
PosA:	DW	0
PosB:	DW	0
Velc:	DW	0
Time:	DW  0
Dist:	DW	0
Bit0:   DW &B0000000001



;; Periphal Address

Switches:  				EQU &H000
LEDs:      				EQU &H001
Timer:     				EQU &H002
Hex0:      				EQU &H004
Hex1:      				EQU &H005
INC:	   				EQU &H0F0
QD:		   				EQU &H0F1
PWM:	   				EQU &H0F2
RPM:	   				EQU &H006
Key1:	   				EQU &H007
VelocityCont:		    EQU &H008
PositionCont:		    EQU &H009