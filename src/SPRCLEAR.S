
.include 'H:\\STRUCT_S.IN'

**************************************************************************
*
*	Effacer sprite de l'ecran cache
*
*	void SprClear( SCRADR *_scradr );

SpriteClear::

	adda	Hide8Screen(PC),A0			; A0 = _scradr
	move.l	SCRADR_SCRN(A0),D1			; D1 = adresse ecran
	beq.s	w0

	move.l	D1,A1						; A1 = adresse ecran

	moveq	#0,D2

	move.l	D2,SCRADR_SCRN(A0)

	move	SCRADR_WWORD(A0),D1			; D1 = wword
	move	SCRADR_HLINE(A0),D0			; D0 = hline

	jmp		.vects(PC,D1)
.vects:
	jmp		w0(PC)
	jmp		w1(PC)
	jmp		w2(PC)
	jmp		w3(PC)
	jmp		w4(PC)

w0:
	rts

w1:
	jmp		.vects(PC,D0)
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
	move.l	D2,(A1)+
	move.l	D2,(A1)+
	lea		152(A1),A1
.15:
	move.l	D2,(A1)+
	move.l	D2,(A1)+
	lea		152(A1),A1
.14:
	move.l	D2,(A1)+
	move.l	D2,(A1)+
	lea		152(A1),A1
.13:
	move.l	D2,(A1)+
	move.l	D2,(A1)+
	lea		152(A1),A1
.12:
	move.l	D2,(A1)+
	move.l	D2,(A1)+
	lea		152(A1),A1
.11:
	move.l	D2,(A1)+
	move.l	D2,(A1)+
	lea		152(A1),A1
.10:
	move.l	D2,(A1)+
	move.l	D2,(A1)+
	lea		152(A1),A1
.9:
	move.l	D2,(A1)+
	move.l	D2,(A1)+
	lea		152(A1),A1
.8:
	move.l	D2,(A1)+
	move.l	D2,(A1)+
	lea		152(A1),A1
.7:
	move.l	D2,(A1)+
	move.l	D2,(A1)+
	lea		152(A1),A1
.6:
	move.l	D2,(A1)+
	move.l	D2,(A1)+
	lea		152(A1),A1
.5:
	move.l	D2,(A1)+
	move.l	D2,(A1)+
	lea		152(A1),A1
.4:
	move.l	D2,(A1)+
	move.l	D2,(A1)+
	lea		152(A1),A1
.3:
	move.l	D2,(A1)+
	move.l	D2,(A1)+
	lea		152(A1),A1
.2:
	move.l	D2,(A1)+
	move.l	D2,(A1)+
	lea		152(A1),A1
.1:
	move.l	D2,(A1)+
	move.l	D2,(A1)+
.0:
	rts

w2:
	pea		.vects(PC,D0)
	move.l	D2,D0
	move.l	D2,D1
	move.l	D2,A0
	rts
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
	movem.l	D0/D1/D2/A0,(A1)
	lea		160(A1),A1
.15:
	movem.l	D0/D1/D2/A0,(A1)
	lea		160(A1),A1
.14:
	movem.l	D0/D1/D2/A0,(A1)
	lea		160(A1),A1
.13:
	movem.l	D0/D1/D2/A0,(A1)
	lea		160(A1),A1
.12:
	movem.l	D0/D1/D2/A0,(A1)
	lea		160(A1),A1
.11:
	movem.l	D0/D1/D2/A0,(A1)
	lea		160(A1),A1
.10:
	movem.l	D0/D1/D2/A0,(A1)
	lea		160(A1),A1
.9:
	movem.l	D0/D1/D2/A0,(A1)
	lea		160(A1),A1
.8:
	movem.l	D0/D1/D2/A0,(A1)
	lea		160(A1),A1
.7:
	movem.l	D0/D1/D2/A0,(A1)
	lea		160(A1),A1
.6:
	movem.l	D0/D1/D2/A0,(A1)
	lea		160(A1),A1
.5:
	movem.l	D0/D1/D2/A0,(A1)
	lea		160(A1),A1
.4:
	movem.l	D0/D1/D2/A0,(A1)
	lea		160(A1),A1
.3:
	movem.l	D0/D1/D2/A0,(A1)
	lea		160(A1),A1
.2:
	movem.l	D0/D1/D2/A0,(A1)
	lea		160(A1),A1
.1:
	movem.l	D0/D1/D2/A0,(A1)
.0:
	rts

w3:
	movem.l	D3-D5,-(SP)
	move.l	D2,D1
	move.l	D2,D3
	move.l	D2,D4
	move.l	D2,D5
	move.l	D2,A0
	jmp		.vects(PC,D0)
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
	movem.l	D1-D5/A0,(A1)
	lea		160(A1),A1
.15:
	movem.l	D1-D5/A0,(A1)
	lea		160(A1),A1
.14:
	movem.l	D1-D5/A0,(A1)
	lea		160(A1),A1
.13:
	movem.l	D1-D5/A0,(A1)
	lea		160(A1),A1
.12:
	movem.l	D1-D5/A0,(A1)
	lea		160(A1),A1
.11:
	movem.l	D1-D5/A0,(A1)
	lea		160(A1),A1
.10:
	movem.l	D1-D5/A0,(A1)
	lea		160(A1),A1
.9:
	movem.l	D1-D5/A0,(A1)
	lea		160(A1),A1
.8:
	movem.l	D1-D5/A0,(A1)
	lea		160(A1),A1
.7:
	movem.l	D1-D5/A0,(A1)
	lea		160(A1),A1
.6:
	movem.l	D1-D5/A0,(A1)
	lea		160(A1),A1
.5:
	movem.l	D1-D5/A0,(A1)
	lea		160(A1),A1
.4:
	movem.l	D1-D5/A0,(A1)
	lea		160(A1),A1
.3:
	movem.l	D1-D5/A0,(A1)
	lea		160(A1),A1
.2:
	movem.l	D1-D5/A0,(A1)
	lea		160(A1),A1
.1:
	movem.l	D1-D5/A0,(A1)
.0:
	movem.l	(SP)+,D3-D5
	rts

w4:
	movem.l	D3/D4/D5/A2/A3,-(SP)
	move.l	D2,D1
	move.l	D2,D3
	move.l	D2,D4
	move.l	D2,D5
	move.l	D2,A0
	move.l	D2,A2
	move.l	D2,A3
	jmp		.vects(PC,D0)
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
	movem.l	D1/D2/D3/D4/D5/A0/A2/A3,(A1)
	lea		160(A1),A1
.15:
	movem.l	D1/D2/D3/D4/D5/A0/A2/A3,(A1)
	lea		160(A1),A1
.14:
	movem.l	D1/D2/D3/D4/D5/A0/A2/A3,(A1)
	lea		160(A1),A1
.13:
	movem.l	D1/D2/D3/D4/D5/A0/A2/A3,(A1)
	lea		160(A1),A1
.12:
	movem.l	D1/D2/D3/D4/D5/A0/A2/A3,(A1)
	lea		160(A1),A1
.11:
	movem.l	D1/D2/D3/D4/D5/A0/A2/A3,(A1)
	lea		160(A1),A1
.10:
	movem.l	D1/D2/D3/D4/D5/A0/A2/A3,(A1)
	lea		160(A1),A1
.9:
	movem.l	D1/D2/D3/D4/D5/A0/A2/A3,(A1)
	lea		160(A1),A1
.8:
	movem.l	D1/D2/D3/D4/D5/A0/A2/A3,(A1)
	lea		160(A1),A1
.7:
	movem.l	D1/D2/D3/D4/D5/A0/A2/A3,(A1)
	lea		160(A1),A1
.6:
	movem.l	D1/D2/D3/D4/D5/A0/A2/A3,(A1)
	lea		160(A1),A1
.5:
	movem.l	D1/D2/D3/D4/D5/A0/A2/A3,(A1)
	lea		160(A1),A1
.4:
	movem.l	D1/D2/D3/D4/D5/A0/A2/A3,(A1)
	lea		160(A1),A1
.3:
	movem.l	D1/D2/D3/D4/D5/A0/A2/A3,(A1)
	lea		160(A1),A1
.2:
	movem.l	D1/D2/D3/D4/D5/A0/A2/A3,(A1)
	lea		160(A1),A1
.1:
	movem.l	D1/D2/D3/D4/D5/A0/A2/A3,(A1)
.0:
	movem.l	(SP)+,D3/D4/D5/A2/A3
	rts

.end
