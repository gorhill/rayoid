**************************************************************************
*
*	Gestion du mode de jeu a un joueur - collisions

.include 'H:\\STRUCT_S.IN'

**************************************************************************
*
*	Gestion des collisions entre les differents objets
*
*	A5 = _asteroid
*	A4 = _joueur
*	A3 = _alien
*
*	D7 = S1NAst courant
*	D5 = compteur d'asteroide

S1Collision::

SAVREGS reg D3/D4/D5/D7/A2/A3/A4/A5

	movem.l	#SAVREGS,-(SP)
	clr		-(SP)				; auto hit sur la pile

	lea		Asteroids,A5
	lea		Joueur,A4
	lea		Alien,A3

*	missiles du joueur avec extraterrestre

aln_jrmis:
	tst		(A3)				; ALN_ON(A3)
	ble		alnmis_jr

	lea		ALN_SCRBOX(A3),A0
	jsr		CollConf(PC)

	lea		JR_MIS(A4),A2
	moveq	#7,D4
.loop:
	tst		(A2)				; MIS_ON(A2)
	beq.s	.next
	lea		MIS_SCRBOX(A2),A0
	jsr		CollOr(PC)			; collision ?
	beq.s	.next				; non
	move	ALN_TYPE(A3),D0		; agir selon type (alien ou bonus)
	add		D0,D0
	add		D0,D0
	jmp		.vects(PC,D0)
.vects:
	jmp		.aln1(PC)
	jmp		.aln2(PC)
	jmp		aln_jr(PC)			; transparent pour les missiles
	jmp		aln_jr(PC)
	jmp		aln_jr(PC)
	jmp		aln_jr(PC)
	jmp		aln_jr(PC)
.aln1:
	moveq	#98,D1
	moveq	#127,D0
	lea		SplJuron,A0
	jsr		SplOn(PC)
	add.l	#500,JR_POINTS(A4)
	move	#-1,(A3)		; ALN_ON(A3)
	moveq	#0,D0
	move	D0,(A2)			; MIS_ON(A2)
	move	D0,ALN_IMAGE(A3)
	bra		alnmis_jr
.aln2:
	moveq	#160,D1
	moveq	#127,D0
	lea		SplJuron,A0
	jsr		SplOn(PC)
	add.l	#200,JR_POINTS(A4)
	move	#-1,(A3)		; ALN_ON(A3)
	moveq	#0,D0
	move	D0,(A2)			; MIS_ON(A2)
	move	D0,ALN_IMAGE(A3)
	bra		alnmis_jr
.next:
	lea		MIS_SZOF(A2),A2
	dbf		D4,.loop

*	joueur avec auxiliaire (alien ou bonus)

aln_jr:
	tst		JR_ENERGIE(A4)
	ble		ast_all
	tst		JR_HYPER(A4)
	bne		ast_all
	tst		(A3)				; ALN_ON(A3)
	ble		alnmis_jr
	lea		JR_SCRBOX(A4),A0
	jsr		CollAnd(PC)			; collision ?
	beq		alnmis_jr			; non
	move	#300,ALN_COUNT(A3)
	move	ALN_TYPE(A3),D0		; agir selon type
	add		D0,D0
	add		D0,D0
	jmp		.vects(PC,D0)
.vects:
	jmp		.aln1(PC)
	jmp		.aln2(PC)
	jmp		.aid1(PC)
	jmp		.aid2(PC)
	jmp		.aid3(PC)
	jmp		.aid4(PC)
	jmp		.aid5(PC)
.aln1:
	moveq	#127,D1
	moveq	#127,D0
	lea		SplOuch,A0
	jsr		SplOn(PC)
	add.l	#500,JR_POINTS(A4)
	move	#-1,(A3)		; ALN_ON(A3)
	moveq	#0,D0
	move	D0,ALN_IMAGE(A3)
	move	D0,JR_ENERGIE(A4)
	bra		ast_all
.aln2:
	moveq	#127,D1
	moveq	#127,D0
	lea		SplOuch,A0
	jsr		SplOn(PC)
	add.l	#200,JR_POINTS(A4)
	move	#-1,(A3)		; ALN_ON(A3)
	moveq	#0,D0
	move	D0,ALN_IMAGE(A3)
	move	D0,JR_ENERGIE(A4)
	bra		ast_all
.aid1:
	moveq	#98,D1
	moveq	#127,D0
	lea		SplPastille,A0
	jsr		SplOn(PC)
	move	#1,JR_MISTYPE(A4)
	clr		(A3)			; ALN_ON(A3)
	bra.s	alnmis_jr
.aid2:
	moveq	#98,D1
	moveq	#127,D0
	lea		SplPastille,A0
	jsr		SplOn(PC)
	move	#2,JR_MISTYPE(A4)
	clr		(A3)			; ALN_ON(A3)
	bra.s	alnmis_jr
.aid3:
	move	#1,(SP)
	move.l	#S1VBL2,AuxVBL+2
	clr		(A3)			; ALN_ON(A3)
	bra.s	alnmis_jr
.aid4:
	moveq	#98,D1
	moveq	#127,D0
	lea		SplPastille,A0
	jsr		SplOn(PC)
	addi.l	#1000,JR_POINTS(A4)
	clr		(A3)			; ALN_ON(A3)
	bra.s	alnmis_jr
.aid5:
	moveq	#98,D1
	moveq	#127,D0
	lea		SplPastille,A0
	jsr		SplOn(PC)
	move	#1,JR_AUTOFIRE(A4)
	clr		(A3)			; ALN_ON(A3)

*	joueur avec missile extraterrestre

alnmis_jr:
	tst		ALN_MIS+MIS_ON(A3)
	beq.s	ast_all
	tst		JR_ENERGIE(A4)
	ble.s	ast_all
	tst		JR_HYPER(A4)
	bne.s	ast_all

	lea		ALN_MIS+MIS_SCRBOX(A3),A0
	jsr		CollConf(PC)

	lea		JR_SCRBOX(A4),A0
	jsr		CollAnd(PC)
	beq.s	ast_all

	lea		.spl(PC),A0
	move	ALN_TYPE(A3),D0
	lsl		#3,D0
	adda	D0,A0
	move	(A0)+,D1
	moveq	#127,D0
	move.l	(A0)+,A0
	jsr		SplOn(PC)
	moveq	#0,D0
	move	D0,ALN_MIS+MIS_ON(A3)
	move	D0,JR_ENERGIE(A4)
	bra.s	ast_all

.spl:	dc.w	98
		dc.l	SplRire1
		dc.w	0
		dc.w	192
		dc.l	SplRire2
		dc.w	0

ast_all:

	move	S1NAst(PC),D7
	move	D7,D5
	bra		ast_test

ast_loop:

	tst		(A5)				; asteroide encore solide ?
	ble		ast_next			; non

	lea		AST_SCRBOX(A5),A0
	jsr		CollConf(PC)

	tst		(SP)				; auto hit en action ?
	bne		ast_hit				; oui

*	asteroide avec joueur

ast_jr:
	tst		JR_ENERGIE(A4)
	ble.s	ast_aln
	tst		JR_HYPER(A4)
	bne.s	ast_aln
	lea		JR_SCRBOX(A4),A0
	jsr		CollAnd(PC)
	beq.s	ast_aln
	moveq	#127,D1
	moveq	#127,D0
	lea		SplOuch,A0
	jsr		SplOn(PC)
	moveq	#0,D0
	move.l	D0,JR_XVIT(A4)
	move	D0,JR_ENERGIE(A4)
	bra		ast_hit

*	asteroide avec alien

ast_aln:
	tst		(A3)				; ALN_ON(A3)
	ble.s	ast_jrmis
	lea		ALN_SCRBOX(A3),A0
	jsr		CollAnd(PC)			; collision ?
	beq.s	ast_jrmis			; non
	move	ALN_TYPE(A3),D0		; agir selon type (alien ou bonus)
	add		D0,D0
	add		D0,D0
	jmp		.vects(PC,D0)
.vects:
	jmp		.aln1(PC)
	jmp		.aln2(PC)
	jmp		.aid1(PC)
	jmp		.aid2(PC)
	jmp		.aid3(PC)
	jmp		.aid4(PC)
	jmp		.aid5(PC)
.aln1:
	moveq	#98,D1
	moveq	#127,D0
	lea		SplJuron,A0
	jsr		SplOn(PC)
	move	#-1,(A3)			; ALN_ON(A3)
	clr		ALN_IMAGE(A3)
	bra		ast_hit
.aln2:
	moveq	#160,D1
	moveq	#127,D0
	lea		SplJuron,A0
	jsr		SplOn(PC)
	move	#-1,(A3)			; ALN_ON(A3)
	clr		ALN_IMAGE(A3)
	bra		ast_hit
.aid1:						; transparent aux asteroides
.aid2:
.aid3:
.aid4:
.aid5:

*	asteroide avec missiles du joueur

ast_jrmis:
	lea		CollFrame(PC),A0
	move.l	A0,D4
	lea		JR_MIS(A4),A2

.1:	tst		(A2)					; MIS_ON(A2)
	beq.s	.2
	lea		MIS_SCRBOX(A2),A0
	move.l	D4,A1
	cmpm	(A1)+,(A0)+
	bge.s	.2
	cmpm	(A1)+,(A0)+
	bge.s	.2
	cmpm	(A1)+,(A0)+
	ble.s	.2
	cmpm	(A1)+,(A0)+
	ble.s	.2
	jsr		_CollOr(PC)
	bne		.is_coll
.2:	lea		MIS_SZOF(A2),A2
	tst		(A2)					; MIS_ON(A2)
	beq.s	.3
	lea		MIS_SCRBOX(A2),A0
	move.l	D4,A1
	cmpm	(A1)+,(A0)+
	bge.s	.3
	cmpm	(A1)+,(A0)+
	bge.s	.3
	cmpm	(A1)+,(A0)+
	ble.s	.3
	cmpm	(A1)+,(A0)+
	ble.s	.3
	jsr		_CollOr(PC)
	bne		.is_coll
.3:	lea		MIS_SZOF(A2),A2
	tst		(A2)					; MIS_ON(A2)
	beq.s	.4
	lea		MIS_SCRBOX(A2),A0
	move.l	D4,A1
	cmpm	(A1)+,(A0)+
	bge.s	.4
	cmpm	(A1)+,(A0)+
	bge.s	.4
	cmpm	(A1)+,(A0)+
	ble.s	.4
	cmpm	(A1)+,(A0)+
	ble.s	.4
	jsr		_CollOr(PC)
	bne		.is_coll
.4:	lea		MIS_SZOF(A2),A2
	tst		(A2)					; MIS_ON(A2)
	beq.s	.5
	lea		MIS_SCRBOX(A2),A0
	move.l	D4,A1
	cmpm	(A1)+,(A0)+
	bge.s	.5
	cmpm	(A1)+,(A0)+
	bge.s	.5
	cmpm	(A1)+,(A0)+
	ble.s	.5
	cmpm	(A1)+,(A0)+
	ble.s	.5
	jsr		_CollOr(PC)
	bne		.is_coll
.5:	lea		MIS_SZOF(A2),A2
	tst		(A2)					; MIS_ON(A2)
	beq.s	.6
	lea		MIS_SCRBOX(A2),A0
	move.l	D4,A1
	cmpm	(A1)+,(A0)+
	bge.s	.6
	cmpm	(A1)+,(A0)+
	bge.s	.6
	cmpm	(A1)+,(A0)+
	ble.s	.6
	cmpm	(A1)+,(A0)+
	ble.s	.6
	jsr		_CollOr(PC)
	bne.s	.is_coll
.6:	lea		MIS_SZOF(A2),A2
	tst		(A2)					; MIS_ON(A2)
	beq.s	.7
	lea		MIS_SCRBOX(A2),A0
	move.l	D4,A1
	cmpm	(A1)+,(A0)+
	bge.s	.7
	cmpm	(A1)+,(A0)+
	bge.s	.7
	cmpm	(A1)+,(A0)+
	ble.s	.7
	cmpm	(A1)+,(A0)+
	ble.s	.7
	jsr		_CollOr(PC)
	bne.s	.is_coll
.7:	lea		MIS_SZOF(A2),A2
	tst		(A2)					; MIS_ON(A2)
	beq.s	.8
	lea		MIS_SCRBOX(A2),A0
	move.l	D4,A1
	cmpm	(A1)+,(A0)+
	bge.s	.8
	cmpm	(A1)+,(A0)+
	bge.s	.8
	cmpm	(A1)+,(A0)+
	ble.s	.8
	cmpm	(A1)+,(A0)+
	ble.s	.8
	jsr		_CollOr(PC)
	bne.s	.is_coll
.8:	lea		MIS_SZOF(A2),A2
	tst		(A2)					; MIS_ON(A2)
	beq.s	ast_alnmis
	lea		MIS_SCRBOX(A2),A0
	move.l	D4,A1
	cmpm	(A1)+,(A0)+
	bge.s	ast_alnmis
	cmpm	(A1)+,(A0)+
	bge.s	ast_alnmis
	cmpm	(A1)+,(A0)+
	ble.s	ast_alnmis
	cmpm	(A1)+,(A0)+
	ble.s	ast_alnmis
	jsr		_CollOr(PC)
	beq.s	ast_alnmis

.is_coll:
	subq	#1,MIS_TYPE(A2)
	bgt.s	ast_hit
	clr		(A2)				; MIS_ON(A2)
	bra.s	ast_hit

*	asteroide avec missile de l'extraterrestre

ast_alnmis:
	tst		ALN_MIS+MIS_ON(A3)
	beq		ast_next
	lea		ALN_MIS+MIS_SCRBOX(A3),A0
	jsr		CollOr(PC)
	beq		ast_next
	clr		ALN_MIS+MIS_ON(A3)

*	asteroide est touche

ast_hit:
	moveq	#98,D1
	moveq	#0,D0
	lea		SplExplode,A0
	jsr		SplOn(PC)

	move	AST_IMG(A5),D2

	move	D2,D0
	add		D0,D0
	add		D0,D0
	lea		AstImgPts(PC),A0
	move.l	0(A0,D0),D0
	add.l	D0,JR_POINTS(A4)

	move	D2,D0
	add		D0,D0
	lea		AstImgNxt(PC),A0
	move	0(A0,D0),D2
	move	D2,AST_IMG(A5)
	beq		ast_off

	lea		Asteroids,A2
	move	D7,D0
	lsl		#3,D0
	move	D0,D1
	add		D1,D1
	add		D1,D1
	add		D1,D0				; x 40 = sizeof(ASTEROID)
	adda	D0,A2				; A2 = nouvel asteroide

	move	#1,(A2)
	move	D2,AST_IMG(A2)

	jsr		FastRand(PC)
	andi	#15,D0
	subq	#7,D0
	add		AST_XPOS(A5),D0
	move	D0,AST_XPOS(A2)

	jsr		FastRand(PC)
	andi	#15,D0
	subq	#7,D0
	add		AST_YPOS(A5),D0
	move	D0,AST_YPOS(A2)

	moveq	#64,D4				; vitesse selon grosseur de l'asteroide
	lsl		D2,D4
	subq	#1,D4
	move	D4,D3
	lsr		#1,D3

	jsr		FastRand(PC)
	and		D4,D0
	sub		D3,D0
	add		AST_XVIT(A5),D0
	move	D0,AST_XVIT(A2)

	jsr		FastRand(PC)
	and		D4,D0
	sub		D3,D0
	add		AST_YVIT(A5),D0
	move	D0,AST_YVIT(A2)

	jsr		FastRand(PC)
	and		D4,D0
	sub		D3,D0
	add		D0,AST_XVIT(A5)

	jsr		FastRand(PC)
	and		D4,D0
	sub		D3,D0
	add		D0,AST_YVIT(A5)

	addq	#1,D7
	addq	#1,S1NCible
	bra.s	ast_next

ast_off:
	move	#-1,(A5)
	clr		AST_IMG(A5)

ast_next:
	lea		AST_SZOF(A5),A5
ast_test:
	dbf		D5,ast_loop

	move	D7,S1NAst

*	verifier si joueur atteint le bonus courant

jr_bonus:
	move.l	JR_POINTS(A4),D0
	cmp.l	S1Bonus(PC),D0
	blt.s	bye

	move	S1NShip(PC),D0
	addq	#1,D0
	jsr		S1ShowSpare(PC)
	addi.l	#5000,S1Bonus

bye:
	addq.l	#2,SP				; espace auto hit
	movem.l	(SP)+,#SAVREGS
	rts

AstImgPts:
	dc.l	5,10,20
AstImgNxt:
	dc.w	1,2,0

.end
