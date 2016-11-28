
;; test_b -> Storing and retrieving data from memory.
;;                This program sticks a bunch of data
;;                    in memory and then searches for the
;;                    one number that's repeated.
;;                 You should end up with a 7 in R3.

.def ZL = R30
.def ZH = R31
	
	NOP
	NOP
	NOP
	NOP

;; Stores #'s 1 thru 7 in addresses 0 thru 7 "randomly"
;; repeating one #
	LDI   ZL,0x60 		; 5
	ANDI  ZH, 0 		; 6
	LDI   R16, 3
	ST    Z, R16

	INC   ZL
	LDI   R16, 4
	ST    Z, R16
	
	INC   ZL
	LDI   R16, 6
	ST    Z, R16

	INC   ZL
	LDI   R16, 2
	ST    Z, R16

	INC     ZL
	LDI     R16, 7
	ST      Z, R16

	INC     ZL
	ST      Z, R16

	INC     ZL
	LDI     R16, 1
	ST      Z, R16

	INC     ZL
	LDI     R16, 5
	ST      Z, R16

;; Searches for which number is repeated, stores this # in R3.
;; In this case you should end up with 7 in R3.
	EOR   R0,R0
	LDI   ZL,0x60
label1: 
	LD      R16, Z
	ST      Z, R0
	SUBI 	ZL,0x60
	MOV     R3, ZL
	SUBI 	R16,-0x60
	MOV     ZL, R16
	SUBI 	R16, 0x60
	CPI	ZL,0x60
label2: 
	BREQ label2
	RJMP label1
