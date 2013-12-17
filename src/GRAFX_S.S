
.include 'H:\\STRUCT_S.IN'

**************************************************************************
*
*	Ouverture du jeu
*
*	Afficher logo a la position 112,92
*
*	void ShowLogo( void )

ShowLogo::

.SAVREGS reg D3/D4/D5/A4

	movem.l	#.SAVREGS,-(SP)
	lea		-SCRADR_SZOF*2(SP),SP

	jsr		AlnSetUp(PC)
	tst		D0
	beq		.bye

	lea		TnyMenu,A0
	jsr		UnTiny(PC)

	lea		ScreenBox(PC),A0
	clr.l	(A0)+
	move	#320,(A0)+
	move	#200,(A0)+

	moveq	#112,D5			; D5 = xpos
	moveq	#5,D3			; D3 = ii

.ii_loop:

	lea		(SP),A0
	moveq	#0,D0
	move.l	D0,(A0)+
	move.l	D0,(A0)+
	move.l	D0,(A0)+
	move.l	D0,(A0)+

	moveq	#127,D1
	moveq	#127,D0
	lea		SplExplode,A0
	jsr		SplOn(PC)

	lea		ExplImg,A4
	moveq	#7,D4			; D4 = jj
.jj_loop:

	move.l	A4,A0
	moveq	#7,D1
	move	D5,D0
	addq	#7,D0
	jsr		S1SprScreen(PC)

	lea		(SP),A1
	move.l	A4,A0
	jsr		SpriteDraw(PC)

	jsr		SwapScreen(PC)

	moveq	#30,D0
	jsr		Delai(PC)

	jsr		SwapWait(PC)

	lea		(SP),A0
	jsr		SpriteClear(PC)

.jj_next:
	lea		SPR_SZOF(A4),A4
	dbf		D4,.jj_loop

	move	#15,-(SP)
	move	#16,-(SP)
	clr		-(SP)
	move	D5,D2
	moveq	#0,D1
	move	D5,D0
	jsr		CpyImage(PC)
	addq.l	#6,SP

	move	#15,-(SP)
	moveq	#16,D2
	moveq	#0,D1
	move	D5,D0
	jsr		CopyZone(PC)
	addq.l	#2,SP

.ii_next:
	addi	#16,D5
	dbf		D3,.ii_loop

*	Faire apparaitre l'extraterrestre

	lea		(SP),A0
	moveq	#0,D0
	move.l	D0,(A0)+
	move.l	D0,(A0)+
	move.l	D0,(A0)+
	move.l	D0,(A0)+
	moveq	#-20,D5
.aln_loop:
	lea		AlnImg,A4
	cmpi	#60,D5
	blt.s	.aln_1
	cmpi	#220,D5
	bge.s	.aln_1
	lea		AlnImg+(SPR_SZOF*2),A4
	cmpi	#80,D5
	blt.s	.aln_1
	cmpi	#84,D5
	bge.s	.aln_1
	moveq	#80,D1
	moveq	#127,D0
	lea		SplRire1,A0
	jsr		SplOn(PC)
.aln_1:
	move.l	A4,A0
	moveq	#92,D1
	move	D5,D0
	jsr		S1SprScreen(PC)
	beq.s	.aln_swap
	lea		(SP),A1
	move.l	A4,A0
	jsr		SpriteDraw(PC)
.aln_swap:
	jsr		SwapScreen(PC)
.aln_wait:
	move.l	_NewScreen(PC),D0
	bne.s	.aln_wait
	lea		(SP),A0
	jsr		SpriteClear(PC)
	addq	#4,D5
	cmpi	#340,D5
	blt.s	.aln_loop

	move.l	#500,D0
	jsr		Delai(PC)

	jsr		SplOff(PC)

.bye:
	jsr		AlnFree(PC)

	lea		SCRADR_SZOF*2(SP),SP
	movem.l	(SP)+,#.SAVREGS
	rts

**************************************************************************
*
*	Retourner -1,0,+1 selon signe d'une variable
*
*	int GetSign( int val );
*
*	D0 = val

GetSign::
	tst		D0
	beq.s	.bye
	smi		D0
	ext		D0
	ori		#1,D0
.bye:
	rts

**************************************************************************
*
*	Limiter la vitesse d'un objet
*
*	void TrapVit( int *_xyvit, int limit );
*
*	A0 = pointeur sur les composants x,y de la vitesse
*	D0 = limite imposee

TrapVit::
	move	D0,D2
	neg		D2

.xvitlo:
	move	(A0)+,D1
	cmp		D2,D1		; xvit < -limit ?
	bge.s	.xvithi		; non
	move	D2,-2(A0)
	bra.s	.yvitlo
.xvithi:
	cmp		D0,D1		; xvit > limit ?
	ble.s	.yvitlo		; non
	move	D0,-2(A0)

.yvitlo:
	move	(A0),D1
	cmp		D2,D1		; yvit < -limit ?
	bge.s	.yvithi		; non
	move	D2,(A0)
	rts
.yvithi:
	cmp		D0,D1		; yvit > limit ?
	ble.s	.bye		; non
	move	D0,(A0)

.bye:
	rts

**************************************************************************
*
*	Obtenir index ecran selon x,y
*
*	int FindXYIdx(x,y);

FindXYIdx::
		lsr		#1,D0
		andi	#$FFF8,D0
		add		D1,D1
		add		YIdx(PC,D1),D0
		rts

YIdx::		; tableau des index selon position y
.yadr	set		0
		.rept	200
		dc.w	.yadr
.yadr	set		.yadr + 160
		.endr

**************************************************************************
*
*	Basculer ecran

SwapScreen::
	lea		_Screens(PC),A0
	movem.l	(A0)+,D0/D1
	eori	#1,(A0)+
	eori	#4,(A0)+
	eori	#8,(A0)+
	beq.s	.1
	exg		D0,D1
.1:	move.l	D1,(A0)+
	move.l	D0,(A0)+
	move.l	D1,(A0)+
	rts

SwapWait::
	lea		_NewScreen(PC),A0
.wait:
	tst.l	(A0)
	bne.s	.wait
	rts

SwapReset::
	lea		_Screens(PC),A0
	movem.l	(A0)+,D0/D1
	move	#1,(A0)+
	move	#4,(A0)+
	move	#8,(A0)+
	move.l	D0,(A0)+
	move.l	D1,(A0)+
	move.l	D0,(A0)+
	bsr		SwapWait
	rts

_Screens::		dcb.l	2,0		;  0
Hide1Screen::	dc.w	0		;  8
Hide4Screen::	dc.w	0		; 10
Hide8Screen::	dc.w	0		; 12
_NewScreen::	dc.l	0		; 14
_HideScreen::	dc.l	0		; 18
_ShowScreen::	dc.l	0		; 22
_NewPalette::	dc.l	ImgPalette	; 26

**************************************************************************
*
*	void CpyImage( int xsrc, int ysrc, int xdes, int ydes, int w, int h )
*
*	Copier une image de l'ecran _SavLogScreen a l'ecran 0
*
*	D0 = xsrc
*	D1 = ysrc
*	D2 = xdes
*	4(SP) = ydes
*	6(SP) = w
*	8(SP) = h

CpyImage::

	move.l	D3,-(SP)

*	obtenir adresse source

	move.l	_SavLogScreen,A0
	jsr		FindXYIdx(PC)
	adda	D0,A0

*	obtenir adresse destination

	move.l	_Screens(PC),A1
	move	D2,D0
	move	1*4+4(SP),D1
	jsr		FindXYIdx(PC)
	adda	D0,A1

	move	1*4+6(SP),D2
	addi	#15,D2
	lsr		#4,D2			; D2 = wword

	moveq	#20,D3
	sub		D2,D3
	lsl		#3,D3			; D3 = nxln

	move	1*4+8(SP),D1
	subq	#1,D1			; D1 = h - 1
	bmi.s	.bye
	subq	#1,D2			; D2 = wword - 1
	bmi.s	.bye
.hloop:
	move	D2,D0
.wloop:
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	dbf		D0,.wloop
	adda	D3,A0
	adda	D3,A1
	dbf		D1,.hloop

.bye:
	move.l	(SP)+,D3
	rts

**************************************************************************
*
*	void ClrImage( int x, int y, int w, int h )
*
*	Effacer une image dans l'ecran 0
*
*	D0 = x
*	D1 = y
*	D2 = w
*	4(SP) = h

ClrImage::

.SAVREGS reg D3/D4

	movem.l	#.SAVREGS,-(SP)

	jsr		FindXYIdx(PC)

	move.l	_Screens(PC),A0
	adda	D0,A0

	addi	#15,D2
	lsr		#4,D2

	moveq	#20,D3
	sub		D2,D3
	lsl		#3,D3			; D3 = nxln

	move	2*4+4(SP),D1
	subq	#1,D1			; D1 = h - 1
	subq	#1,D2			; D2 = wword - 1

	moveq	#0,D4
.hloop:
	move	D2,D0
.wloop:
	move.l	D4,(A0)+
	move.l	D4,(A0)+
	dbf		D0,.wloop
	adda	D3,A0
	dbf		D1,.hloop

	movem.l	(SP)+,#.SAVREGS
	rts

**************************************************************************
*
*	Effacer ecran defini par ScreenBox
*
*	void ClrScreen( void )

ClrScreen::
	lea		ScreenBox+GRECT_SZOF,A0
	move	-(A0),-(SP)
	move	-(A0),D2
	move	-(A0),D1
	move	-(A0),D0
	jsr		ClrImage(PC)
	addq.l	#2,SP
	rts

**************************************************************************
*
*	Copier une zone de l'ecran 0 a l'ecran 1. X et W doivent
*	obligatoirement etre des multiples de 16
*
*	void CopyZone( int x, int y, int w, int h )
*
*	Copier une image dans l'ecran 0 et l'ecran 1
*
*	D0 = x
*	D1 = y
*	D2 = w
*	4(SP) = h

CopyZone::

	move.l	D3,-(SP)

	jsr		FindXYIdx(PC)

	movem.l	_Screens(PC),A0-A1
	adda	D0,A0
	adda	D0,A1

	addi	#15,D2
	lsr		#4,D2			; D2 = wword

	moveq	#20,D3
	sub		D2,D3
	lsl		#3,D3			; D3 = nxln

	move	8(SP),D1
	subq	#1,D1			; D1 = h - 1
	bmi.s	.bye
	subq	#1,D2			; D2 = wword - 1
	bmi.s	.bye
.hloop:
	move	D2,D0
.wloop:
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	dbf		D0,.wloop
	adda	D3,A0
	adda	D3,A1
	dbf		D1,.hloop

.bye:
	move.l	(SP)+,D3
	rts

**************************************************************************
*
*	Decompresser une image TNY
*
*	void UnTiny( char *_tiny );
*
*	Utilisation des registres
*		D2	compteur
*		D5	index ecran
*
*		A0 = octets de controle
*		A1 = octets de donnees
*		A2 = fin de la zone des octets de controle
*		A3 = zone de travail
*		A4 = zone destination

.if	0

UnTiny::

.SAVREGS reg D4/A2/A3/A4

	cmpa.l	.last(PC),A0		; verifier si decompression necessaire
	bne.s	.untiny
	rts

.last:		dc.l	0

.untiny:
	move.l	A0,.last

	movem.l	#.SAVREGS,-(SP)

	move.l	_SavLogScreen,A4	; A4 = adresse destination
	move	(A0)+,D0			; D0 = nombre d'octet de controle
	move	(A0)+,D1			; D1 = nombre d'octet de donnee
	move.l	A0,A1				; A0 = zone de controle
	adda	D0,A1				; A1 = zone de donnee
	move.l	A1,A2				; A2 = fin de la zone de controle

	lea		.work(PC),A3

	moveq	#0,D4				; D4 = index ecran

.tloop:
	move.b	(A0)+,D2			; lire octet de controle
	beq.s	.mword				; motif
	cmpi.b	#1,D2
	beq.s	.cword				; copie
	ext		D2
	bpl.s	.motif
	neg		D2
	bra.s	.copie

.cword:
	move.b	(A0)+,(A3)+			; copie d'une suite de mot
	move.b	(A0)+,(A3)+
	move	-(A3),D2

.copie:
	subq	#1,D2
.cloop:
	move.b	(A1)+,(A3)+
	move.b	(A1)+,(A3)+
	move	-(A3),(A4,D4)
	addi	#160,D4				; next screen row
	cmpi	#32000,D4			; past bottom line ?
	blt.s	.cnext				; no, return
	subi	#31992,D4			; top of next column, same plane
	cmpi	#160,D4				; past end of line ?
	blt.s	.cnext				; no, return
	subi	#158,D4				; next plane
.cnext:
	dbf		D2,.cloop
	cmpa.l	A2,A0				; encore des octets de controle ?
	bcs.s	.tloop
	movem.l	(SP)+,#.SAVREGS
	rts

.mword:
	move.b	(A0)+,(A3)+			; repetition d'un motif
	move.b	(A0)+,(A3)+
	move	-(A3),D2

.motif:
	subq	#1,D2
	move.b	(A1)+,(A3)+
	move.b	(A1)+,(A3)+
	move	-(A3),D0
.mloop:
	move	D0,(A4,D4)
	addi	#160,D4				; next screen row
	cmpi	#32000,D4			; past bottom line ?
	blt.s	.mnext				; no, return
	subi	#31992,D4			; top of next column, same plane
	cmpi	#160,D4				; past end of line ?
	blt.s	.mnext				; no, return
	subi	#158,D4				; next plane
.mnext:
	dbf		D2,.mloop
	cmpa.l	A2,A0				; encore des octets de controle ?
	bcs.s	.tloop
	movem.l	(SP)+,#.SAVREGS
	rts

.work:
	dc.w	0

.endif

**************************************************************************
*
*	Decompresser une image Pack Ice
*
*	void UnTiny( char *_tiny );
*
*	ICE Depack routine as used in JAM packer V4.0
*	Usage :
*		MOVE.L #$packed_data_start_address,A0
*		MOVE.L #$place_to_put_unpacked_data,A1
*		BSR		DEPACK

UnTiny::

.SAVREGS reg D0/D1/D2/D3/D4/D7/A3/A4/A5/A6

	cmpa.l	.last(PC),A0		; verifier si decompression necessaire
	bne.s	.untiny
	rts

.last:		dc.l	0

.untiny:
	move.l	A0,.last
	move.l	_SavLogScreen,A1	; A1 = adresse destination

	movem.l #.SAVREGS,-(SP)

	addq.l	#4,A0				; ignorer 'ICE!'

	move.l	(A0)+,D0
	lea		-8(A0,D0.L),A5

	move.l	(A0)+,D0
	move.l	D0,(SP)

	movea.l A1,A4
	movea.l A1,A6
	adda.l	D0,A6
	movea.l A6,A3
	move.b	-(A5),D7
	bsr		.ice06

	movem.l (SP)+,#.SAVREGS
	rts

.ice06:
	bsr.s	.ice0a
	bcc.s	.ice09
	moveq	#0,D1
	bsr.s	.ice0a
	bcc.s	.ice08
	lea		.ice17(PC),A1
	moveq	#4,D3
.ice07:
	move.l	-(A1),D0
	bsr.s	.ice0c
	swap	D0
	cmp		D0,D1
	dbne	D3,.ice07
	add.l	20(A1),D1
.ice08:
	move.b	-(A5),-(A6)
	dbra	D1,.ice08
.ice09:
	cmpa.l	A4,A6
	bgt.s	.ice0f
	rts

.ice0a:
	add.b	D7,D7
	bne.s	.ice0b
	move.b	-(A5),D7
	addx.b	D7,D7
.ice0b:
	rts

.ice0c:
	moveq	#0,D1
.ice0d:
	add.b	D7,D7
	bne.s	.ice0e
	move.b	-(A5),D7
	addx.b	D7,D7
.ice0e:
	addx	D1,D1
	dbra	D0,.ice0d
	rts

.ice0f:
	lea		.ice18(PC),A1
	moveq	#3,D2
.ice10:
	bsr.s	.ice0a
	dbcc	D2,.ice10
	moveq	#0,D4
	moveq	#0,D1
	move.b	1(A1,D2),D0
	ext		D0
	bmi.s	.ice11
	bsr.s	.ice0c
.ice11:
	move.b	6(A1,D2),D4
	add		D1,D4
	beq.s	.ice13
	lea		.ice19(PC),A1
	moveq	#1,D2
.ice12:
	bsr.s	.ice0a
	dbcc	D2,.ice12
	moveq	#0,D1
	move.b	1(A1,D2),D0
	ext		D0
	bsr.s	.ice0c
	add		D2,D2
	add		6(A1,D2),D1
	bpl.s	.ice15
	sub		D4,D1
	bra.s	.ice15
.ice13:
	moveq	#0,D1
	moveq	#5,D0
	moveq	#-1,D2
	bsr.s	.ice0a
	bcc.s	.ice14
	moveq	#8,D0
	moveq	#$3F,D2
.ice14:
	bsr.s	.ice0c
	add		D2,D1
.ice15:
	lea		2(A6,D4),A1
	adda	D1,A1
	move.b	-(A1),-(A6)
.ice16:
	move.b	-(A1),-(A6)
	dbra	D4,.ice16
	bra		.ice06

	dc.b	$7F,$FF,$00,$0E,$00,$FF,$00,$07,$00,$07,$00,$02,$00,$03,$00,$01
	dc.b	$00,$03,$00,$01
.ice17:
	dc.b	$00,$00,$01,$0D,$00,$00,$00,$0E,$00,$00,$00,$07,$00,$00,$00,$04
	dc.b	$00,$00,$00,$01
.ice18:
	dc.b	$09,$01,$00,$FF,$FF,$08,$04,$02,$01,$00
.ice19:
	dc.b	$0B,$04,$07,$00,$01,$1F,$FF,$FF,$00,$1F

	.even

**************************************************************************

ShipXVit::	dc.w	0,98,181,237,256,237,181,98
			dc.w	0,-98,-181,-237,-256,-237,-181,-98
ShipYVit::	dc.w	-256,-237,-181,-98,0,98,181,237
			dc.w	256,237,181,98,0,-98,-181,-237
MisXPos::	dc.w	0,3,6,7,7,7,6,3,0,-3,-6,-7,-7,-7,-6,-3
MisYPos::	dc.w	-7,-7,-6,-3,0,3,6,7,7,7,6,3,0,-3,-6,-7
MisXVit::	dc.w	0,38,71,92,100,92,71,38
			dc.w	0,-38,-71,-92,-100,-92,-71,-38
MisYVit::	dc.w	-100,-92,-71,-38,0,38,71,92
			dc.w	100,92,71,38,0,-38,-71,-92


.end
