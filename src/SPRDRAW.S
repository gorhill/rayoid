
.include 'h:\\struct_s.in'

**************************************************************************
*
*	Mode Simple - Afficher sprite dans ecran cache
*
*	void SpriteDraw(SPRITE *,SCRADR *);
*
*	A0 = _sprite
*	A1 = _scradr
*
*	Remarque - 10 juin 1992
*		La sauvegarde/restauration des registres D3/D4/A3/A4 necessite
*		10.5 us a chaque appel de la routine. Des que possible, replacer
*		ces instructions a un niveau superieur.

SpriteDraw::

SAVREGS reg A3/A4/D3/D4

	movem.l	#SAVREGS,-(SP)

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
	move.l	SPR_IMAGES(A0,D0),A3	; A3 = pointeur sur l'image a utiliser
	move.l	SPR_MASKS(A0,D0),A4		; A4 = pointeur sur le masque a utiliser
	move	ClipSprite+GY(PC),D2
	sub		SPR_BOX+GY(A0),D2		; D2 = y_line
	add		D2,D2
	add		D2,D1
	add		D1,D1
	adda	D1,A4					; A4 = _msk
	add		D1,D1
	add		D1,D1
	adda	D1,A3					; A3 = _src
	bra.s	.3

.xpos:
	andi	#15,D0					; D0 = x_offset
	add		D0,D0
	add		D0,D0
	move.l	SPR_IMAGES(A0,D0),A3	; A3 = pointeur sur l'image a utiliser
	move.l	SPR_MASKS(A0,D0),A4		; A4 = pointeur sur le masque a utiliser
	move	ClipSprite+GY(PC),D1
	sub		SPR_BOX+GY(A0),D1		; D1 = y_line
	beq.s	.3
	add		D1,D1
	add		D1,D1
	adda	D1,A4					; A4 = _msk
	add		D1,D1
	add		D1,D1
	adda	D1,A3					; A3 = _src

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
	movem.l	(SP)+,#SAVREGS
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
	movem	(A0),D1-D4	; 28
	move	(A4)+,D0	;  8
	and		D0,D1		;  4
	and		D0,D2		;  4
	and		D0,D3		;  4
	and		D0,D4		;  4
	or		(A3)+,D1	;  8
	or		(A3)+,D2	;  8
	or		(A3)+,D3	;  8
	or		(A3)+,D4	;  8
	movem	D1-D4,(A0)	; 24
	addq.l	#8,A3		;  8
	addq.l	#2,A4		;  8
	lea		160(A0),A0	;  8 = 132
.15:
	movem	(A0),D1-D4
	move	(A4)+,D0
	and		D0,D1
	and		D0,D2
	and		D0,D3
	and		D0,D4
	or		(A3)+,D1
	or		(A3)+,D2
	or		(A3)+,D3
	or		(A3)+,D4
	movem	D1-D4,(A0)
	addq.l	#8,A3
	addq.l	#2,A4
	lea		160(A0),A0
.14:
	movem	(A0),D1-D4
	move	(A4)+,D0
	and		D0,D1
	and		D0,D2
	and		D0,D3
	and		D0,D4
	or		(A3)+,D1
	or		(A3)+,D2
	or		(A3)+,D3
	or		(A3)+,D4
	movem	D1-D4,(A0)
	addq.l	#8,A3
	addq.l	#2,A4
	lea		160(A0),A0
.13:
	movem	(A0),D1-D4
	move	(A4)+,D0
	and		D0,D1
	and		D0,D2
	and		D0,D3
	and		D0,D4
	or		(A3)+,D1
	or		(A3)+,D2
	or		(A3)+,D3
	or		(A3)+,D4
	movem	D1-D4,(A0)
	addq.l	#8,A3
	addq.l	#2,A4
	lea		160(A0),A0
.12:
	movem	(A0),D1-D4
	move	(A4)+,D0
	and		D0,D1
	and		D0,D2
	and		D0,D3
	and		D0,D4
	or		(A3)+,D1
	or		(A3)+,D2
	or		(A3)+,D3
	or		(A3)+,D4
	movem	D1-D4,(A0)
	addq.l	#8,A3
	addq.l	#2,A4
	lea		160(A0),A0
.11:
	movem	(A0),D1-D4
	move	(A4)+,D0
	and		D0,D1
	and		D0,D2
	and		D0,D3
	and		D0,D4
	or		(A3)+,D1
	or		(A3)+,D2
	or		(A3)+,D3
	or		(A3)+,D4
	movem	D1-D4,(A0)
	addq.l	#8,A3
	addq.l	#2,A4
	lea		160(A0),A0
.10:
	movem	(A0),D1-D4
	move	(A4)+,D0
	and		D0,D1
	and		D0,D2
	and		D0,D3
	and		D0,D4
	or		(A3)+,D1
	or		(A3)+,D2
	or		(A3)+,D3
	or		(A3)+,D4
	movem	D1-D4,(A0)
	addq.l	#8,A3
	addq.l	#2,A4
	lea		160(A0),A0
.9:
	movem	(A0),D1-D4
	move	(A4)+,D0
	and		D0,D1
	and		D0,D2
	and		D0,D3
	and		D0,D4
	or		(A3)+,D1
	or		(A3)+,D2
	or		(A3)+,D3
	or		(A3)+,D4
	movem	D1-D4,(A0)
	addq.l	#8,A3
	addq.l	#2,A4
	lea		160(A0),A0
.8:
	movem	(A0),D1-D4
	move	(A4)+,D0
	and		D0,D1
	and		D0,D2
	and		D0,D3
	and		D0,D4
	or		(A3)+,D1
	or		(A3)+,D2
	or		(A3)+,D3
	or		(A3)+,D4
	movem	D1-D4,(A0)
	addq.l	#8,A3
	addq.l	#2,A4
	lea		160(A0),A0
.7:
	movem	(A0),D1-D4
	move	(A4)+,D0
	and		D0,D1
	and		D0,D2
	and		D0,D3
	and		D0,D4
	or		(A3)+,D1
	or		(A3)+,D2
	or		(A3)+,D3
	or		(A3)+,D4
	movem	D1-D4,(A0)
	addq.l	#8,A3
	addq.l	#2,A4
	lea		160(A0),A0
.6:
	movem	(A0),D1-D4
	move	(A4)+,D0
	and		D0,D1
	and		D0,D2
	and		D0,D3
	and		D0,D4
	or		(A3)+,D1
	or		(A3)+,D2
	or		(A3)+,D3
	or		(A3)+,D4
	movem	D1-D4,(A0)
	addq.l	#8,A3
	addq.l	#2,A4
	lea		160(A0),A0
.5:
	movem	(A0),D1-D4
	move	(A4)+,D0
	and		D0,D1
	and		D0,D2
	and		D0,D3
	and		D0,D4
	or		(A3)+,D1
	or		(A3)+,D2
	or		(A3)+,D3
	or		(A3)+,D4
	movem	D1-D4,(A0)
	addq.l	#8,A3
	addq.l	#2,A4
	lea		160(A0),A0
.4:
	movem	(A0),D1-D4
	move	(A4)+,D0
	and		D0,D1
	and		D0,D2
	and		D0,D3
	and		D0,D4
	or		(A3)+,D1
	or		(A3)+,D2
	or		(A3)+,D3
	or		(A3)+,D4
	movem	D1-D4,(A0)
	addq.l	#8,A3
	addq.l	#2,A4
	lea		160(A0),A0
.3:
	movem	(A0),D1-D4
	move	(A4)+,D0
	and		D0,D1
	and		D0,D2
	and		D0,D3
	and		D0,D4
	or		(A3)+,D1
	or		(A3)+,D2
	or		(A3)+,D3
	or		(A3)+,D4
	movem	D1-D4,(A0)
	addq.l	#8,A3
	addq.l	#2,A4
	lea		160(A0),A0
.2:
	movem	(A0),D1-D4
	move	(A4)+,D0
	and		D0,D1
	and		D0,D2
	and		D0,D3
	and		D0,D4
	or		(A3)+,D1
	or		(A3)+,D2
	or		(A3)+,D3
	or		(A3)+,D4
	movem	D1-D4,(A0)
	addq.l	#8,A3
	addq.l	#2,A4
	lea		160(A0),A0
.1:
	movem	(A0),D1-D4
	move	(A4)+,D0
	and		D0,D1
	and		D0,D2
	and		D0,D3
	and		D0,D4
	or		(A3)+,D1
	or		(A3)+,D2
	or		(A3)+,D3
	or		(A3)+,D4
	movem	D1-D4,(A0)
.0:
	movem.l	(SP)+,#SAVREGS
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
	movem.l	(A0),D1-D4	; 44
	move	(A4),D0		;  8
	swap	D0			;  4
	move	(A4)+,D0	;  8
	and.l	D0,D1		;  8
	and.l	D0,D2		;  8
	move	(A4),D0		;  8
	swap	D0			;  4
	move	(A4)+,D0	;  8
	and.l	D0,D3		;  8
	and.l	D0,D4		;  8
	or.l	(A3)+,D1	; 14
	or.l	(A3)+,D2	; 14
	or.l	(A3)+,D3	; 14
	or.l	(A3)+,D4	; 14
	movem.l	D1-D4,(A0)	; 40
	lea		160(A0),A0	;  8 = 220
.15:
	movem.l	(A0),D1-D4
	move	(A4),D0
	swap	D0
	move	(A4)+,D0
	and.l	D0,D1
	and.l	D0,D2
	move	(A4),D0
	swap	D0
	move	(A4)+,D0
	and.l	D0,D3
	and.l	D0,D4
	or.l	(A3)+,D1
	or.l	(A3)+,D2
	or.l	(A3)+,D3
	or.l	(A3)+,D4
	movem.l	D1-D4,(A0)
	lea		160(A0),A0
.14:
	movem.l	(A0),D1-D4
	move	(A4),D0
	swap	D0
	move	(A4)+,D0
	and.l	D0,D1
	and.l	D0,D2
	move	(A4),D0
	swap	D0
	move	(A4)+,D0
	and.l	D0,D3
	and.l	D0,D4
	or.l	(A3)+,D1
	or.l	(A3)+,D2
	or.l	(A3)+,D3
	or.l	(A3)+,D4
	movem.l	D1-D4,(A0)
	lea		160(A0),A0
.13:
	movem.l	(A0),D1-D4
	move	(A4),D0
	swap	D0
	move	(A4)+,D0
	and.l	D0,D1
	and.l	D0,D2
	move	(A4),D0
	swap	D0
	move	(A4)+,D0
	and.l	D0,D3
	and.l	D0,D4
	or.l	(A3)+,D1
	or.l	(A3)+,D2
	or.l	(A3)+,D3
	or.l	(A3)+,D4
	movem.l	D1-D4,(A0)
	lea		160(A0),A0
.12:
	movem.l	(A0),D1-D4
	move	(A4),D0
	swap	D0
	move	(A4)+,D0
	and.l	D0,D1
	and.l	D0,D2
	move	(A4),D0
	swap	D0
	move	(A4)+,D0
	and.l	D0,D3
	and.l	D0,D4
	or.l	(A3)+,D1
	or.l	(A3)+,D2
	or.l	(A3)+,D3
	or.l	(A3)+,D4
	movem.l	D1-D4,(A0)
	lea		160(A0),A0
.11:
	movem.l	(A0),D1-D4
	move	(A4),D0
	swap	D0
	move	(A4)+,D0
	and.l	D0,D1
	and.l	D0,D2
	move	(A4),D0
	swap	D0
	move	(A4)+,D0
	and.l	D0,D3
	and.l	D0,D4
	or.l	(A3)+,D1
	or.l	(A3)+,D2
	or.l	(A3)+,D3
	or.l	(A3)+,D4
	movem.l	D1-D4,(A0)
	lea		160(A0),A0
.10:
	movem.l	(A0),D1-D4
	move	(A4),D0
	swap	D0
	move	(A4)+,D0
	and.l	D0,D1
	and.l	D0,D2
	move	(A4),D0
	swap	D0
	move	(A4)+,D0
	and.l	D0,D3
	and.l	D0,D4
	or.l	(A3)+,D1
	or.l	(A3)+,D2
	or.l	(A3)+,D3
	or.l	(A3)+,D4
	movem.l	D1-D4,(A0)
	lea		160(A0),A0
.9:
	movem.l	(A0),D1-D4
	move	(A4),D0
	swap	D0
	move	(A4)+,D0
	and.l	D0,D1
	and.l	D0,D2
	move	(A4),D0
	swap	D0
	move	(A4)+,D0
	and.l	D0,D3
	and.l	D0,D4
	or.l	(A3)+,D1
	or.l	(A3)+,D2
	or.l	(A3)+,D3
	or.l	(A3)+,D4
	movem.l	D1-D4,(A0)
	lea		160(A0),A0
.8:
	movem.l	(A0),D1-D4
	move	(A4),D0
	swap	D0
	move	(A4)+,D0
	and.l	D0,D1
	and.l	D0,D2
	move	(A4),D0
	swap	D0
	move	(A4)+,D0
	and.l	D0,D3
	and.l	D0,D4
	or.l	(A3)+,D1
	or.l	(A3)+,D2
	or.l	(A3)+,D3
	or.l	(A3)+,D4
	movem.l	D1-D4,(A0)
	lea		160(A0),A0
.7:
	movem.l	(A0),D1-D4
	move	(A4),D0
	swap	D0
	move	(A4)+,D0
	and.l	D0,D1
	and.l	D0,D2
	move	(A4),D0
	swap	D0
	move	(A4)+,D0
	and.l	D0,D3
	and.l	D0,D4
	or.l	(A3)+,D1
	or.l	(A3)+,D2
	or.l	(A3)+,D3
	or.l	(A3)+,D4
	movem.l	D1-D4,(A0)
	lea		160(A0),A0
.6:
	movem.l	(A0),D1-D4
	move	(A4),D0
	swap	D0
	move	(A4)+,D0
	and.l	D0,D1
	and.l	D0,D2
	move	(A4),D0
	swap	D0
	move	(A4)+,D0
	and.l	D0,D3
	and.l	D0,D4
	or.l	(A3)+,D1
	or.l	(A3)+,D2
	or.l	(A3)+,D3
	or.l	(A3)+,D4
	movem.l	D1-D4,(A0)
	lea		160(A0),A0
.5:
	movem.l	(A0),D1-D4
	move	(A4),D0
	swap	D0
	move	(A4)+,D0
	and.l	D0,D1
	and.l	D0,D2
	move	(A4),D0
	swap	D0
	move	(A4)+,D0
	and.l	D0,D3
	and.l	D0,D4
	or.l	(A3)+,D1
	or.l	(A3)+,D2
	or.l	(A3)+,D3
	or.l	(A3)+,D4
	movem.l	D1-D4,(A0)
	lea		160(A0),A0
.4:
	movem.l	(A0),D1-D4
	move	(A4),D0
	swap	D0
	move	(A4)+,D0
	and.l	D0,D1
	and.l	D0,D2
	move	(A4),D0
	swap	D0
	move	(A4)+,D0
	and.l	D0,D3
	and.l	D0,D4
	or.l	(A3)+,D1
	or.l	(A3)+,D2
	or.l	(A3)+,D3
	or.l	(A3)+,D4
	movem.l	D1-D4,(A0)
	lea		160(A0),A0
.3:
	movem.l	(A0),D1-D4
	move	(A4),D0
	swap	D0
	move	(A4)+,D0
	and.l	D0,D1
	and.l	D0,D2
	move	(A4),D0
	swap	D0
	move	(A4)+,D0
	and.l	D0,D3
	and.l	D0,D4
	or.l	(A3)+,D1
	or.l	(A3)+,D2
	or.l	(A3)+,D3
	or.l	(A3)+,D4
	movem.l	D1-D4,(A0)
	lea		160(A0),A0
.2:
	movem.l	(A0),D1-D4
	move	(A4),D0
	swap	D0
	move	(A4)+,D0
	and.l	D0,D1
	and.l	D0,D2
	move	(A4),D0
	swap	D0
	move	(A4)+,D0
	and.l	D0,D3
	and.l	D0,D4
	or.l	(A3)+,D1
	or.l	(A3)+,D2
	or.l	(A3)+,D3
	or.l	(A3)+,D4
	movem.l	D1-D4,(A0)
	lea		160(A0),A0
.1:
	movem.l	(A0),D1-D4
	move	(A4),D0
	swap	D0
	move	(A4)+,D0
	and.l	D0,D1
	and.l	D0,D2
	move	(A4),D0
	swap	D0
	move	(A4)+,D0
	and.l	D0,D3
	and.l	D0,D4
	or.l	(A3)+,D1
	or.l	(A3)+,D2
	or.l	(A3)+,D3
	or.l	(A3)+,D4
	movem.l	D1-D4,(A0)
.0:
	movem.l	(SP)+,#SAVREGS
	rts

**************************************************************************
*
*	Index qui permettent d'acceder rapidement a un sprite particulier a
*	l'interieur d'un tableau

SprIdx::
	dc.w	SPR_SZOF*0,SPR_SZOF*1,SPR_SZOF*2,SPR_SZOF*3
	dc.w	SPR_SZOF*4,SPR_SZOF*5,SPR_SZOF*6,SPR_SZOF*7
	dc.w	SPR_SZOF*8,SPR_SZOF*9,SPR_SZOF*10,SPR_SZOF*11
	dc.w	SPR_SZOF*12,SPR_SZOF*13,SPR_SZOF*14,SPR_SZOF*15
	dc.w	SPR_SZOF*16,SPR_SZOF*17,SPR_SZOF*18,SPR_SZOF*19
	dc.w	SPR_SZOF*20,SPR_SZOF*21,SPR_SZOF*22,SPR_SZOF*23
	dc.w	SPR_SZOF*24,SPR_SZOF*25,SPR_SZOF*26,SPR_SZOF*27
	dc.w	SPR_SZOF*28,SPR_SZOF*29,SPR_SZOF*30,SPR_SZOF*31

.end
