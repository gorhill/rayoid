
.include 'H:\\STRUCT_S.IN'

**************************************************************************
*
*	Mode Simple - Afficher sprite dans ecran cache
*
*	void SpriteMask(SPRITE *,SCRADR *);
*
*	A0 = _sprite
*	A1 = _scradr

SpriteMask::

	move.l	A2,-(SP)

	move	(A0),D0
	sub		ScreenBox+GX(PC),D0
	bpl.s	.xpos

.xneg:
	move	D0,D1
	neg		D1
	subq	#1,D1
	lsr		#4,D1
	addq	#1,D1					; D1 = x_word
	addi	#16,D0
	andi	#15,D0					; D0 = x_offset
	add		D0,D0
	add		D0,D0
	move.l	SPR_MASKS(A0,D0),A2		; A2 = pointeur sur le masque a utiliser
	move	ClipSprite+GY(PC),D2
	sub		SPR_BOX+GY(A0),D2		; D2 = y_line
	add		D2,D2
	add		D2,D1
	add		D1,D1
	adda	D1,A2					; A2 = _msk
	bra.s	.3

.xpos:
	andi	#15,D0					; D0 = x_offset
	add		D0,D0
	add		D0,D0
	move.l	SPR_MASKS(A0,D0),A2		; A2 = pointeur sur le masque a utiliser
	move	ClipSprite+GY(PC),D1
	sub		SPR_BOX+GY(A0),D1		; D1 = y_line
	beq.s	.3
	add		D1,D1
	add		D1,D1
	adda	D1,A2					; A2 = _msk

.3:	adda	Hide8Screen(PC),A1

	move.l	_HideScreen(PC),A0
	movem	ClipSprite+GX(PC),D0/D1
	jsr		FindXYIdx(PC)
	adda	D0,A0					; A0 = adresse ecran

	move	ClipSprite+GX(PC),D0
	andi	#15,D0
	add		ClipSprite+GW(PC),D0
	addi	#15,D0
	lsr		#2,D0					; D0 = w_word
	andi	#$FFFC,D0
	move	D0,(A1)+				; wword x 4

	move	ClipSprite+GH(PC),D1	; D1 = h_line
	add		D1,D1
	add		D1,D1
	move	D1,(A1)+				; hline x 4

	move.l	A0,(A1)+				; adresse ecran

	jmp		.vects(PC,D0)
.vects:
	jmp		nil(PC)
	jmp		w1(PC)
	jmp		w2(PC)
	jmp		nil(PC)
	jmp		nil(PC)

nil:
	move.l	(SP)+,A2
	rts

w1:
	jmp		.vects(PC,D1)
.vects:
	jmp		.0(PC)
	jmp		.1(PC)
	jmp		.2(PC)
	jmp		.3(PC)
	jmp		.4(PC)
	jmp		.5(PC)
	jmp		.6(PC)
	jmp		.7(PC)
	jmp		.8(PC)
	jmp		.9(PC)
	jmp		.10(PC)
	jmp		.11(PC)
	jmp		.12(PC)
	jmp		.13(PC)
	jmp		.14(PC)
	jmp		.15(PC)
	jmp		.16(PC)
.16:
	move	(A2)+,D0
	not		D0
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	addq.l	#2,A2
	lea		152(A0),A0
.15:
	move	(A2)+,D0
	not		D0
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	addq.l	#2,A2
	lea		152(A0),A0
.14:
	move	(A2)+,D0
	not		D0
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	addq.l	#2,A2
	lea		152(A0),A0
.13:
	move	(A2)+,D0
	not		D0
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	addq.l	#2,A2
	lea		152(A0),A0
.12:
	move	(A2)+,D0
	not		D0
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	addq.l	#2,A2
	lea		152(A0),A0
.11:
	move	(A2)+,D0
	not		D0
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	addq.l	#2,A2
	lea		152(A0),A0
.10:
	move	(A2)+,D0
	not		D0
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	addq.l	#2,A2
	lea		152(A0),A0
.9:
	move	(A2)+,D0
	not		D0
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	addq.l	#2,A2
	lea		152(A0),A0
.8:
	move	(A2)+,D0
	not		D0
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	addq.l	#2,A2
	lea		152(A0),A0
.7:
	move	(A2)+,D0
	not		D0
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	addq.l	#2,A2
	lea		152(A0),A0
.6:
	move	(A2)+,D0
	not		D0
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	addq.l	#2,A2
	lea		152(A0),A0
.5:
	move	(A2)+,D0
	not		D0
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	addq.l	#2,A2
	lea		152(A0),A0
.4:
	move	(A2)+,D0
	not		D0
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	addq.l	#2,A2
	lea		152(A0),A0
.3:
	move	(A2)+,D0
	not		D0
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	addq.l	#2,A2
	lea		152(A0),A0
.2:
	move	(A2)+,D0
	not		D0
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	addq.l	#2,A2
	lea		152(A0),A0
.1:
	move	(A2)+,D0
	not		D0
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
.0:
	move.l	(SP)+,A2
	rts

w2:
	jmp		.vects(PC,D1)
.vects:
	jmp		.0(PC)
	jmp		.1(PC)
	jmp		.2(PC)
	jmp		.3(PC)
	jmp		.4(PC)
	jmp		.5(PC)
	jmp		.6(PC)
	jmp		.7(PC)
	jmp		.8(PC)
	jmp		.9(PC)
	jmp		.10(PC)
	jmp		.11(PC)
	jmp		.12(PC)
	jmp		.13(PC)
	jmp		.14(PC)
	jmp		.15(PC)
	jmp		.16(PC)
.16:
	move	(A2)+,D0	;  8
	not		D0			;  4
	or		D0,(A0)+	; 12
	or		D0,(A0)+	; 12
	or		D0,(A0)+	; 12
	or		D0,(A0)+	; 12
	move	(A2)+,D0	;  8
	not		D0			;  4
	or		D0,(A0)+	; 12
	or		D0,(A0)+	; 12
	or		D0,(A0)+	; 12
	or		D0,(A0)+	; 12
	lea		144(A0),A0	;  8
.15:
	move	(A2)+,D0
	not		D0
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	move	(A2)+,D0
	not		D0
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	lea		144(A0),A0
.14:
	move	(A2)+,D0
	not		D0
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	move	(A2)+,D0
	not		D0
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	lea		144(A0),A0
.13:
	move	(A2)+,D0
	not		D0
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	move	(A2)+,D0
	not		D0
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	lea		144(A0),A0
.12:
	move	(A2)+,D0
	not		D0
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	move	(A2)+,D0
	not		D0
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	lea		144(A0),A0
.11:
	move	(A2)+,D0
	not		D0
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	move	(A2)+,D0
	not		D0
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	lea		144(A0),A0
.10:
	move	(A2)+,D0
	not		D0
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	move	(A2)+,D0
	not		D0
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	lea		144(A0),A0
.9:
	move	(A2)+,D0
	not		D0
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	move	(A2)+,D0
	not		D0
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	lea		144(A0),A0
.8:
	move	(A2)+,D0
	not		D0
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	move	(A2)+,D0
	not		D0
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	lea		144(A0),A0
.7:
	move	(A2)+,D0
	not		D0
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	move	(A2)+,D0
	not		D0
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	lea		144(A0),A0
.6:
	move	(A2)+,D0
	not		D0
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	move	(A2)+,D0
	not		D0
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	lea		144(A0),A0
.5:
	move	(A2)+,D0
	not		D0
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	move	(A2)+,D0
	not		D0
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	lea		144(A0),A0
.4:
	move	(A2)+,D0
	not		D0
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	move	(A2)+,D0
	not		D0
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	lea		144(A0),A0
.3:
	move	(A2)+,D0
	not		D0
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	move	(A2)+,D0
	not		D0
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	lea		144(A0),A0
.2:
	move	(A2)+,D0
	not		D0
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	move	(A2)+,D0
	not		D0
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	lea		144(A0),A0
.1:
	move	(A2)+,D0
	not		D0
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	move	(A2)+,D0
	not		D0
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
.0:
	move.l	(SP)+,A2
	rts

.end
