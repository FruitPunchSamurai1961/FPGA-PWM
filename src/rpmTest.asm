; Simple test to see if rpm changes or not
ORG 0
Start:
	LOAD	PWMBackward
	OUT		PWM
	CALL	Delay
	IN		RPM
	OUT		HEX0
	JUMP	Start

; Delay for 2 seconds
Delay:
	OUT    Timer
WaitingLoop:
	IN     Timer
	ADDI   -20
	JNEG   WaitingLoop
	RETURN
; Useful values
PWMForward:		DW &B0000000000101111
PWMBackward:	DW &B0000000000011111


Switches:  				EQU &H000
LEDs:      				EQU &H001
Timer:     				EQU &H002
Hex0:      				EQU &H004
Hex1:      				EQU &H005
INC:	   				EQU &H0F0
QD:		   				EQU &H0F1
PWM:	   				EQU &H0F2
RPM:	   				EQU &H006
KEY1:	   				EQU &H007
VelocityCont:		    EQU &H008
PositionCont:		    EQU &H009