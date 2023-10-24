;; ASM Code to control Position
ORG 0
Start:
	IN		Key1
	AND		Bit0
	JPOS	GetPos
	JUMP	Start	
	
GetPos:
	IN		Switches
	STORE	UserPos
	SHIFT	-8
	AND		Bit0
	JPOS	Negate
	LOAD	UserPos
	AND		BitMask
	STORE	UserPos
	JPOS	MoveForward
	JUMP	Done

Negate:
	LOAD	UserPos
	AND		BitMask
	STORE	UserPos
	SUB		UserPos
	SUB		UserPos
	STORE	UserPos
	JUMP	MoveBackward

MoveForward:
	AND		Bit0
	LOAD	PWMForward
	OUT		PWM
	CALL	Delay
	JUMP	Check
	
MoveBackward:
	LOAD 	PWMBackward
	OUT		PWM
	CALL	Delay
	JUMP	Check
	
Check:
	LOAD	PWMStop
	OUT		PWM
	IN		QD
	OUT		Hex0
	STORE	CurrQDData
	LOAD	UserPos
	SUB		CurrQDData
	JNEG	CheckNeg
	JPOS	CheckPos
	JUMP	Done

CheckNeg:
	Sub		Minus12
	JPOS	Done
	JUMP	MoveBackward

CheckPos:
	Sub		Plus12
	JNEG	Done
	JUMP	MoveForward

Done:
	LOAD	CurrQDData
	OUT		Hex0
	JUMP	Loop

Loop:
	JUMP	Loop


;; For each read, wait two seconds
Delay:
	OUT    Timer
WaitingLoop:
	IN     Timer
	ADDI 	-10
	JNEG   WaitingLoop
	RETURN
	


;;Useful values
Bit0:      		DW &B0000000000000001
Bit1:      		DW &B0000000000000010
Bit2:      		DW &B0000000000000100
Bit3:      		DW &B0000000000001000
Bit4:      		DW &B0000000000010000
Bit5:      		DW &B0000000000100000
Bit6:      		DW &B0000000001000000
Bit7:      		DW &B0000000010000000
Bit8:      		DW &B0000000100000000
Bit9:      		DW &B0000001000000000
BitMask:   		DW &B0000000011111111
PWMForward:		DW &B0000000000101111
PWMBackward:	DW &B0000000000011111
PWMStop:		DW &B0000000000000000
Plus12:			DW	12
Minus12:		DW	-12



; Peri. Addr
Switches:  		EQU &H000
LEDs:      		EQU &H001
Timer:     		EQU &H002
Hex0:      		EQU &H004
Hex1:      		EQU &H005
INC:	   		EQU &H0F0
QD:		   		EQU &H0F1
PWM:	   		EQU &H0F2
RAND:	   		EQU &H006
KEY1:	   		EQU &H007

; Use for storing data
UserPos:		DW	0
CurrQDData:		DW	0