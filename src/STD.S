**************************************************************************
*
*	Transformer un entier long en chaine de caractere (8 chiffres
*	significatifs)
*
*	MyLToA( char *_str, long val )
*
*	A0 = _str
*	D0 = val

MyLToA::
	tst.l	D0			; negatif ?
	bpl.s	.pos		; non

.neg:
	move.b	#'-',(A0)+
	neg.l	D0

.pos:
	cmpi.l	#9999999,D0
	bgt.s	.d8
	cmpi.l	#999999,D0
	bgt.s	.d7
	cmpi.l	#99999,D0
	bgt.s	.d6
	cmpi.l	#9999,D0
	bgt.s	.d5
	cmpi	#999,D0
	bgt.s	.d4
	cmpi	#99,D0
	bgt.s	.d3
	cmpi	#9,D0
	bgt.s	.d2
	bra		.d1

.d8:
	moveq	#-'0',D1
.l8:
	subi.l	#10000000,D0
	dbmi	D1,.l8
	neg		D1
	move.b	D1,(A0)+
	addi.l	#10000000,D0

.d7:
	moveq	#-'0',D1
.l7:
	subi.l	#1000000,D0
	dbmi	D1,.l7
	neg		D1
	move.b	D1,(A0)+
	addi.l	#1000000,D0

.d6:
	moveq	#-'0',D1
.l6:
	subi.l	#100000,D0
	dbmi	D1,.l6
	neg		D1
	move.b	D1,(A0)+
	addi.l	#100000,D0

.d5:
	moveq	#-'0',D1
.l5:
	subi.l	#10000,D0
	dbmi	D1,.l5
	neg		D1
	move.b	D1,(A0)+
	addi	#10000,D0

.d4:
	moveq	#-'0',D1
.l4:
	subi	#1000,D0
	dbmi	D1,.l4
	neg		D1
	move.b	D1,(A0)+
	addi	#1000,D0

.d3:
	moveq	#-'0',D1
.l3:
	subi	#100,D0
	dbmi	D1,.l3
	neg		D1
	move.b	D1,(A0)+
	addi	#100,D0

.d2:
	moveq	#-'0',D1
.l2:
	subi	#10,D0
	dbmi	D1,.l2
	neg		D1
	move.b	D1,(A0)+
	addi	#10,D0

.d1:
	addi	#'0',D0
	move.b	D0,(A0)+
	clr.b	(A0)+

	rts

**************************************************************************
*
*	Copie d'une zone de memoire
*
*	void MemCopy( char *_src, char *_des, long len );

MemCopy::
	tst.l	D0
	ble		.bye

	cmpa.l	A0,A1			; direction du deplacement
	bhi		.mv_right
	beq		.bye			; nul

.mv_left:
	move	A0,D1
	move	A1,D2
	eor		D1,D2
	andi	#1,D2			; adresse paire et impaire ?
	bne.s	.mvb_left
	andi	#1,D1			; adresses impaires ?
	beq.s	.mvl_left

	move.b	(A0)+,(A1)+
	subq.l	#1,D0

.mvl_left:
	move.l	D0,D1			; nombre d'octet a deplacer
	andi.l	#255,D0			; modulo 256
	asr.l	#8,D1			; # bloc de 256 octets
	beq.s	.mvb_left

	movem.l	D3/D4/D5/D7/A2/A3/A4,-(SP)
.mvll_lp:
	movem.l	(A0)+,D2/D3/D4/D5/D7/A2/A3/A4
	movem.l	D2/D3/D4/D5/D7/A2/A3/A4,(A1)
	movem.l	(A0)+,D2/D3/D4/D5/D7/A2/A3/A4
	movem.l	D2/D3/D4/D5/D7/A2/A3/A4,32(A1)
	movem.l	(A0)+,D2/D3/D4/D5/D7/A2/A3/A4
	movem.l	D2/D3/D4/D5/D7/A2/A3/A4,64(A1)
	movem.l	(A0)+,D2/D3/D4/D5/D7/A2/A3/A4
	movem.l	D2/D3/D4/D5/D7/A2/A3/A4,96(A1)
	movem.l	(A0)+,D2/D3/D4/D5/D7/A2/A3/A4
	movem.l	D2/D3/D4/D5/D7/A2/A3/A4,128(A1)
	movem.l	(A0)+,D2/D3/D4/D5/D7/A2/A3/A4
	movem.l	D2/D3/D4/D5/D7/A2/A3/A4,160(A1)
	movem.l	(A0)+,D2/D3/D4/D5/D7/A2/A3/A4
	movem.l	D2/D3/D4/D5/D7/A2/A3/A4,192(A1)
	movem.l	(A0)+,D2/D3/D4/D5/D7/A2/A3/A4
	movem.l	D2/D3/D4/D5/D7/A2/A3/A4,224(A1)
	lea		256(A1),A1
	subq.l	#1,D1
	bne.s	.mvll_lp
	movem.l	(SP)+,D3/D4/D5/D7/A2/A3/A4

.mvb_left:
	move.l	D0,D1			; # byte a deplacer
	andi	#15,D0			; modulo 16
	asr.l	#4,D1
	beq.s	.mvbl_reste
.mvbl_lp:
	.rept	16
	move.b	(A0)+,(A1)+
	.endr
	subq.l	#1,D1
	bne.s	.mvbl_lp
	bra.s	.mvbl_reste

.mvbl_reste_lp:
	move.b	(A0)+,(A1)+
.mvbl_reste:
	dbf		D0,.mvbl_reste_lp
	rts

.mv_right:
	adda.l	D0,A0
	adda.l	D0,A1

	move	A0,D1
	move	A1,D2
	eor		D1,D2
	andi	#1,D2			; adresse paire et impaire ?
	bne.s	.mvb_right
	andi	#1,D1			; adresses impaires ?
	beq.s	.mvl_right

	move.b	-(A0),-(A1)
	subq.l	#1,D0

.mvl_right:
	move.l	D0,D1			; nombre d'octet a deplacer
	andi.l	#255,D0			; modulo 256
	asr.l	#8,D1			; # bloc de 256 octets
	beq.s	.mvb_right

	movem.l	D3/D4/D5/D7/A2/A3/A4,-(SP)
.mvlr_lp:
	movem.l	-32(A0),D2/D3/D4/D5/D7/A2/A3/A4
	movem.l	D2/D3/D4/D5/D7/A2/A3/A4,-(A1)
	movem.l	-64(A0),D2/D3/D4/D5/D7/A2/A3/A4
	movem.l	D2/D3/D4/D5/D7/A2/A3/A4,-(A1)
	movem.l	-96(A0),D2/D3/D4/D5/D7/A2/A3/A4
	movem.l	D2/D3/D4/D5/D7/A2/A3/A4,-(A1)
	movem.l	-128(A0),D2/D3/D4/D5/D7/A2/A3/A4
	movem.l	D2/D3/D4/D5/D7/A2/A3/A4,-(A1)
	movem.l	-160(A0),D2/D3/D4/D5/D7/A2/A3/A4
	movem.l	D2/D3/D4/D5/D7/A2/A3/A4,-(A1)
	movem.l	-192(A0),D2/D3/D4/D5/D7/A2/A3/A4
	movem.l	D2/D3/D4/D5/D7/A2/A3/A4,-(A1)
	movem.l	-224(A0),D2/D3/D4/D5/D7/A2/A3/A4
	movem.l	D2/D3/D4/D5/D7/A2/A3/A4,-(A1)
	movem.l	-256(A0),D2/D3/D4/D5/D7/A2/A3/A4
	movem.l	D2/D3/D4/D5/D7/A2/A3/A4,-(A1)
	lea		-256(A0),A0
	subq.l	#1,D1
	bne.s	.mvlr_lp
	movem.l	(SP)+,D3/D4/D5/D7/A2/A3/A4

.mvb_right:
	move.l	D0,D1			; # byte a deplacer
	andi	#15,D0			; modulo 16
	asr.l	#4,D1
	beq.s	.mvbr_reste
.mvbr_lp:
	.rept	16
	move.b	-(A0),-(A1)
	.endr
	subq.l	#1,D1
	bne.s	.mvbr_lp
	bra.s	.mvbr_reste

.mvbr_reste_lp:
	move.b	-(A0),-(A1)
.mvbr_reste:
	dbf		D0,.mvbr_reste_lp

.bye:
	rts

**************************************************************************
*
*	Remettre a zero le contenu d'une zone memoire
*
*	void MemClear( char *_ptr, long count )


MemClear::
	moveq	#0,D1

**************************************************************************
*
*	Remplir zone memoire avec un caractere particulier
*
*	void MemFill( char *_ptr, long count, char c )

MemFill::

	tst.l	D0				; longueur valide ?
	ble.s	.bye			; non

	move	A0,D2			; verifier si adresse impaire
	andi	#1,D2
	beq.s	.fill

	move.b	D1,(A0)+		; ajuster sur une adresse paire
	subq.l	#1,D0
	
.fill:
	move	D0,D2
	andi	#255,D2			; D2 = modulo 256
	lsr.l	#8,D0			; D0 = nombre de bloc de 256 octets
	beq.s	.next1			; bloc < 256 octets

	lea		.work(PC),A1	; emplir D1 avec le caractere de remplissage
	move.b	D1,(A1)+
	move.b	D1,(A1)+
	move.b	D1,(A1)+
	move.b	D1,(A1)+
	move.l	-(A1),D1

	movem.l	D3/D4/D5/D7/A3/A4,-(SP)
	move.l	D1,D3
	move.l	D1,D4
	move.l	D1,D5
	move.l	D1,D7
	move.l	D1,A1
	move.l	D1,A3
	move.l	D1,A4

.loop512:
	movem.l	D1/D3/D4/D5/D7/A1/A3/A4,(A0)
	movem.l	D1/D3/D4/D5/D7/A1/A3/A4,32(A0)
	movem.l	D1/D3/D4/D5/D7/A1/A3/A4,64(A0)
	movem.l	D1/D3/D4/D5/D7/A1/A3/A4,96(A0)
	movem.l	D1/D3/D4/D5/D7/A1/A3/A4,128(A0)
	movem.l	D1/D3/D4/D5/D7/A1/A3/A4,160(A0)
	movem.l	D1/D3/D4/D5/D7/A1/A3/A4,192(A0)
	movem.l	D1/D3/D4/D5/D7/A1/A3/A4,224(A0)
	lea		256(A0),A0
.next512:
	subq.l	#1,D0
	bne.s	.loop512

	movem.l	(SP)+,D3/D4/D5/D7/A3/A4
	bra.s	.next1

.loop1:
	move.b	D1,(A0)+
.next1:
	dbf		D2,.loop1

.bye:
	rts

.work:		dcb.b	4,0

**************************************************************************
*
*	Sauvegarder et restaurer A6

SaveA6::
	move.l	A6,savA6
	rts

RestA6::
	move.l	savA6(PC),A6
	rts

savA6:		dc.l	0

**************************************************************************
*
*	Nombre pseudo-aleatoire
*
*	void InitRand( int seed );
*	int FastRand();

InitRand::

.SAVREGS reg D3/D4/D5/A3

	movem.l	#.SAVREGS,-(SP)

	jsr		srand(PC)

	lea		randIdx(PC),A3
	clr		(A3)+
	move	#1023,D3
.initlp:
	move	D3,(A3)+
	dbf		D3,.initlp

	lea		randTable(PC),A3
	move	#2047,D3
.mele:
	jsr		rand(PC)
	move	D0,D4
	andi	#1023,D4
	add		D4,D4
	jsr		rand(PC)
	move	D0,D5
	andi	#1023,D5
	add		D5,D5
	move	(A3,D4),D0
	move	(A3,D5),(A3,D4)
	move	D0,(A3,D5)
	dbf		D3,.mele

	movem.l	(SP)+,#.SAVREGS
	rts

FastRand::
	moveq	#0,D0				;  4
	move	randIdx(PC),D0		; 12
	addq	#2,D0				;  4
	andi	#2047,D0			;  8
	move	D0,randIdx			; 16
	move	randTable(PC,D0),D0	; 14
	rts							; 16

randIdx:
	dc.w	0
randTable:
	dcb.w	1024,0

.end
