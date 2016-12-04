	NOP
	NOP
	NOP
	NOP

	ldi r16, $03
	push r16
	rcall fonction
	push r16
	pop r17
	pop r18


fonction:	inc r16
		push r16
		inc r16
		pop r16
		ret
	
	
