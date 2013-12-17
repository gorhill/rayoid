
.include 'H:\\STRUCT_S.IN'

**************************************************************************
*
*	Traiter les missiles et mine furtive d'un joueur
*
*	void C2MisMove( JOUEUR *_joueur )

C2MisMove::

	move.l	A3,-(SP)

	move.l	A0,A3				; A3 = _joueur

*	evolution de l'armement selon nombre de base developpee

	lea		.mistype(PC),A0
	move	JR_NFULLBASE(A3),D0
	move.b	0(A0,D0),D0
	cmp		JR_MISTYPE(A3),D0	; arme evolue ?
	ble.s	.movmis1			; non

	move	D0,JR_MISTYPE(A3)

*	deplacer les missiles en action

.movmis1:
	lea		JR_MIS+(MIS_SZOF*0)(A3),A1	; A1 = _joueur->missiles[0]
	tst		(A1)				; MIS_ON(A1)
	beq.s	.movmis2

	subq	#1,(A1)				; MIS_ON(A1)
	beq.s	.movmis2

	lea		MIS_XPOS(A1),A0
	movem	MIS_XVIT(A1),D0/D1
	jsr		C2CalcPos(PC)

.movmis2:
	lea		JR_MIS+(MIS_SZOF*1)(A3),A1	; A1 = _joueur->missiles[1]
	tst		(A1)				; MIS_ON(A1)
	beq.s	.makemis

	subq	#1,(A1)				; MIS_ON(A1)
	beq.s	.makemis

	lea		MIS_XPOS(A1),A0
	movem	MIS_XVIT(A1),D0/D1
	jsr		C2CalcPos(PC)

*	le missile nouvellement cree remplace le plus ancien couramment actif

.makemis:
	tst		JR_ENERGIE(A3)
	ble		.piege
	move	JR_MOVE(A3),D0
	andi	#8,D0
	beq		.piege
	move	JR_OLDMOVE(A3),D0
	andi	#8,D0
	bne		.piege

	lea		JR_MIS+(MIS_SZOF*0)(A3),A0
	lea		JR_MIS+(MIS_SZOF*1)(A3),A1
	move	(A1),D0
	cmp		(A0),D0
	ble.s	.initmis

	move.l	A0,A1

.initmis:
	move	#63,(A1)+				; MIS_ON(A1)
	move	JR_MISTYPE(A3),(A1)+	; MIS_TYPE(A1)
	move	(A3),D2					; JR_DIR(A3)
	lsr		#2,D2
	add		D2,D2

	movem	JR_XPOS(A3),D0/D1
	lea		MisXPos(PC),A0
	add		0(A0,D2),D0
	andi	#(SPACE_W-1),D0
	move	D0,(A1)+			; MIS_XPOS(A1)
	lea		MisYPos(PC),A0
	add		0(A0,D2),D1
	andi	#(SPACE_H-1),D1
	move	D1,(A1)+			; MIS_YPOS(A1)

	move.l	JR_XPOSFRAC(A3),(A1)+	; MIS_XPOSFRAC(A1)

	movem	JR_XVIT(A3),D0/D1
	lea		MisXVit(PC),A0
	add		0(A0,D2),D0
	move	D0,(A1)+			; MIS_XVIT(A1)
	lea		MisYVit(PC),A0
	add		0(A0,D2),D1
	move	D1,(A1)+			; MIS_YVIT(A1)

	tst		JR_ID(A3)
	bne.s	.piege
	moveq	#112,D1				; effet sonore
	moveq	#0,D0
	lea		SplFire1,A0
	jsr		SplOn(PC)

.piege:
	tst		JR_MINE(A3)			; mine furtive en action ?
	beq.s	.bye
	lea		JR_MINEXPOS(A3),A0
	movem	JR_MINEXVIT(A3),D0/D1
	jsr		C2CalcPos(PC)

.bye:
	move.l	(SP)+,A3
	rts

.mistype:
	dc.b	0,0,0,1,1,2,2,3
	dc.b	3,4,4,5,5,6,6,7
	dc.b	7,7,7,7,7,7,7,7
	dc.b	7,7,7,7,7,7,7,7

**************************************************************************
*
*	Dessiner les missiles d'un joueur
*
*	void C2MisDraw( JOUEUR *_joueur )

C2MisDraw::

	move.l	A3,-(SP)
	move.l	A2,-(SP)

	lea		JR_MIS(A0),A3

.mis_1:
	move	(A3),D0				; MIS_ON(A3)
	beq.s	.mis_2

	move	MIS_TYPE(A3),D0		; image selon type de missile
	add		D0,D0
	add		D0,D0
	move.l	.misimg(PC,D0),A2

	move.l	A2,A0
	movem	MIS_XPOS(A3),D0/D1
	jsr		C2SprScreen(PC)
	beq.s	.mis_2

	lea		MIS_SCRADR(A3),A1
	move.l	A2,A0
	jsr		SpriteDraw(PC)

.mis_2:
	lea		MIS_SZOF(A3),A3
	move	(A3),D0				; MIS_ON(A3)
	beq.s	.bye

	move	MIS_TYPE(A3),D0		; image selon type de missile
	add		D0,D0
	add		D0,D0
	move.l	.misimg(PC,D0),A2

	move.l	A2,A0
	movem	MIS_XPOS(A3),D0/D1
	jsr		C2SprScreen(PC)
	beq.s	.bye

	lea		MIS_SCRADR(A3),A1
	move.l	A2,A0
	jsr		SpriteDraw(PC)

.bye:
	move.l	(SP)+,A2
	move.l	(SP)+,A3
	rts

.misimg:
	dc.l	IIIMisImg+(SPR_SZOF*0),IIIMisImg+(SPR_SZOF*1)
	dc.l	IIIMisImg+(SPR_SZOF*2),IIIMisImg+(SPR_SZOF*3)
	dc.l	IIIMisImg+(SPR_SZOF*4),IIIMisImg+(SPR_SZOF*5)
	dc.l	IIIMisImg+(SPR_SZOF*6),IIIMisImg+(SPR_SZOF*7)

**************************************************************************
*
*	Effacer missiles et mine furtive des joueurs de l'ecran
*
*	void C2MisClear( void )

C2MisClear::

*	joueur 0

	lea		Joueur+JR_MIS+(MIS_SZOF*0)+MIS_SCRADR,A0
	jsr		SpriteClear(PC)
	lea		Joueur+JR_MIS+(MIS_SZOF*1)+MIS_SCRADR,A0
	jsr		SpriteClear(PC)
	lea		Joueur+JR_SAVMINE,A0
	jsr		SpriteClear(PC)

*	joueur 1

	lea		Joueur+JR_SZOF+JR_MIS+(MIS_SZOF*0)+MIS_SCRADR,A0
	jsr		SpriteClear(PC)
	lea		Joueur+JR_SZOF+JR_MIS+(MIS_SZOF*1)+MIS_SCRADR,A0
	jsr		SpriteClear(PC)

	rts

**************************************************************************
*
*	Dessiner mine furtive
*
*	void C2PiegeDraw( void )

C2PiegeDraw::
	move.l	A3,-(SP)
	move.l	A2,-(SP)

	lea		Joueur,A3

	move	JR_MINE(A3),D0		; mine furtive en action ?
	beq.s	.bye

	move	JR_COUNTER+2(A3),D0
	lsr		#1,D0
	andi	#4,D0
	move.l	.minimg(PC,D0),A2

	move.l	A2,A0
	movem	JR_MINEXPOS(A3),D0/D1
	jsr		C2SprScreen(PC)
	beq.s	.bye

	lea		JR_SAVMINE(A3),A1
	move.l	A2,A0
	jsr		SpriteDraw(PC)

.bye:
	move.l	(SP)+,A2
	move.l	(SP)+,A3
	rts

.minimg:
	dc.l	PiegeImg+(SPR_SZOF*0),PiegeImg+(SPR_SZOF*1)


	.end
