; Starting code with basic constants and simple subroutine

ORG 0
Start:

	LOAD	SixtyRPM
	OUT		PWM
SpeedControl:
	IN      RPM
	CALL    Abs
	OUT 	HEX0
	IN		velControl
	OUT     PWM
	JUMP    SpeedControl
	;IN   QuadDecoder
	;CALL Mod6
	;CALL DisplayWithNeg
	;JUMP Start

;******************************************************************************
; Abs: 2's complement absolute value
; Returns abs(AC) in AC
; Negate: 2's complement negation
; Returns -AC in AC
;******************************************************************************
 
DisplayWithNeg:
	OUT Hex1
	Call Negate
	OUT Hex0
	RETURN
Abs:
	JPOS   Abs_r        ; If already positive, return
Negate:
	XOR    NegOne       ; Flip all bits
	ADDI   1            ; Add one
Abs_r:
	RETURN
PosMod6:
	SUB Six
	JPOS PosMod6
	JZERO ZeroMod6
	ADD Six
	RETURN
NegMod6:
	ADD Six
	JNEG NegMod6
	RETURN
ZeroMod6:
	RETURN
Mod6:
	JPOS PosMod6
	JNEG NegMod6



; Useful values
Zero:      DW 0
NegOne:    DW -1
Six:	   DW 6
TimerVal:  DW 0
One:
Bit0:      DW &B0000000001
Bit1:      DW &B0000000010
Bit2:      DW &B0000000100
Bit3:      DW &B0000001000
Bit4:      DW &B0000010000
Bit5:      DW &B0000100000
Bit6:      DW &B0001000000
Bit7:      DW &B0010000000
Bit8:      DW &B0100000000
Bit9:      DW &B1000000000
LoByte:    DW &H00FF
HiByte:    DW &HFF00
SixtyRpm:  DW &B0000101111
ThirtyRpm: DW &B0000011000


; IO address constants
Switches:  	EQU &H000
LEDs:      	EQU &H001
Timer:     	EQU &H002
Hex0:      	EQU &H004
Hex1:      	EQU &H005
Incrementer: EQU &H0F0
QuadDecoder: EQU &H0F1	
PWM: 		EQU &H0F2	
RPM: 		EQU &H0F4
velControl: EQU &H0F5
