
.include 'H:\\STRUCT_S.IN'

**************************************************************************
*
*	Verifier si un sprite est dans la portion visible
*
*	int C2SprScreen(int xpos,int ypos,SPRITE *);
*
*	Le rectangle clippe resultant est place dans ClipSprite.

C2SprScreen::

	sub		SPR_XHOT(A0),D0
	sub		Joueur+JR_XPOS,D0
	cmpi	#-(SPACE_W/2),D0
	bgt.s	.1
	addi	#SPACE_W,D0
	bra.s	.2
.1:	cmpi	#(SPACE_W/2),D0
	blt.s	.2
	subi	#SPACE_W,D0

.2:	sub		SPR_YHOT(A0),D1
	sub		Joueur+JR_YPOS,D1
	cmpi	#-(SPACE_H/2),D1
	bgt.s	.3
	addi	#SPACE_H,D1
	bra.s	.4
.3:	cmpi	#(SPACE_H/2),D1
	blt.s	.4
	subi	#SPACE_H,D1

.4:	addi	#144,D0
	move	D0,(A0)+			; SPR_BOX+GX(A0)
	addi	#90,D1
	move	D1,(A0)+			; SPR_BOX+GY(A0)

	cmpi	#272,D0				;  8
	blt.s	.5					; 10
	moveq	#0,D0				;  4
	rts							; 16
.5:	cmpi	#176,D1				;  8
	blt.s	.6					; 10
	moveq	#0,D0				;  4
	rts							; 16
.6:	add		(A0)+,D0			;  8
	cmpi	#16,D0				;  8
	bgt.s	.7					; 10
	moveq	#0,D0				;  4
	rts							; 16
.7:	add		(A0)+,D1			;  8
	cmpi	#4,D1				;  8
	bgt.s	.8					; 10
	moveq	#0,D0				;  4
	rts							; 16

*	si on arrive ici, c'est que le sprite est dans la zone visible

.8:	subq.l	#8,A0				;  8
	lea		ClipSprite(PC),A1	;  8

*	plus grand x1

	move	(A0)+,D0			;  8
	move	D0,D2				;  4
	cmpi	#16,D2				;  8
	bge.s	.x					; 10
	moveq	#16,D2				;  4
.x:	move	D2,(A1)+			;  8

*	plus petit x2

	add		2(A0),D0			; 12
	cmpi	#272,D0				;  8
	ble.s	.width				; 10
	move	#272,D0				;  8
.width:
	sub		D2,D0				;  4
	move	D0,2(A1)			; 12

*	plus grand y1

	move	(A0)+,D1			;  8
	move	D1,D2				;  4
	cmpi	#4,D2				;  8
	bge.s	.y					; 10
	moveq	#4,D2				;  4
.y:	move	D2,(A1)+			;  8

*	plus petit y2

	add		2(A0),D1			; 12
	cmpi	#176,D1				;  8
	ble.s	.height				; 10
	move	#176,D1				;  8
.height:
	sub		D2,D1				;  4
	move	D1,2(A1)			; 12

	moveq	#1,D0				;  4
	rts							; 16

**************************************************************************
*
*	Dessiner joueurs
*
*	void C2JrDraw( JOUEUR *_joueur )

C2JrDraw::

	movem.l	D3/A2/A3,-(SP)

	move.l	A0,A3

	tst		JR_ID(A3)			; joueur a dessiner
	bne		C2Jr1Draw

C2Jr0Draw:
	move	JR_ENERGIE(A3),D0
	ble		Jr0Expl

	lea		SprIdx(PC),A0
	move	(A3),D0				; JR_DIR(A3)
	lsr		#2,D0
	add		D0,D0
	move	0(A0,D0),D3			; D3 = index de sprite

	lea		JR_SHIPIMG(A3),A2
	adda	D3,A2				; A2 = sprite

	move	#144,D0
	moveq	#90,D1
	sub		SPR_XHOT(A2),D0
	sub		SPR_YHOT(A2),D1
	movem	D0/D1,(A2)			; SPR_BOX(A2)

	move.l	A2,A0
	lea		ClipSprite(PC),A1
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+

	lea		JR_SAVSHIP(A3),A1
	move.l	A2,A0
	move	JR_HIT(A3),D0		; joueur touche ?
	bne.s	.mask				; oui
	jsr		SpriteDraw(PC)
	bra.s	Jr0Motor
.mask:
	subq	#1,D0
	move	D0,JR_HIT(A3)
	jsr		SpriteMask(PC)

Jr0Motor:
	tst		JR_MOTOR(A3)		; moteur en action ?
	beq.s	.bye

	lea		MotorImg,A2
	adda	D3,A2

	move	#144,D0
	moveq	#90,D1
	sub		SPR_XHOT(A2),D0
	sub		SPR_YHOT(A2),D1
	movem	D0/D1,(A2)			; SPR_BOX(A2)

	move.l	A2,A0
	lea		ClipSprite(PC),A1
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+

	lea		JR_SAVFIRE(A3),A1
	move.l	A2,A0
	jsr		SpriteDraw(PC)
.bye:
	movem.l	(SP)+,D3/A2/A3
	rts

Jr0Expl:
	beq.s	Jr0Pod

	move	D0,D3
	addq	#1,D0
	move	D0,JR_ENERGIE(A3)

	lea		ExplImg,A2
	lea		SprIdx(PC),A0
	addi	#31,D3
	lsr		#2,D3
	add		D3,D3
	adda	0(A0,D3),A2

	move.l	A2,A0
	movem	JR_EXPLX(A3),D0/D1
	jsr		C2SprScreen(PC)
	beq.s	Jr0Pod

	lea		JR_SAVEXPL(A3),A1
	move.l	A2,A0
	jsr		SpriteDraw(PC)

Jr0Pod:
	lea		PodImg,A2
	lea		SprIdx(PC),A0
	move	JR_COUNTER+2(A3),D0
	lsr		#2,D0
	andi	#2,D0
	adda	0(A0,D0),A2

	move	#144,D0
	moveq	#90,D1
	sub		SPR_XHOT(A2),D0
	sub		SPR_YHOT(A2),D1
	movem	D0/D1,(A2)		; SPR_BOX(A2)

	move.l	A2,A0
	lea		ClipSprite(PC),A1
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+

	lea		JR_SAVSHIP(A3),A1
	move.l	A2,A0
	jsr		SpriteDraw(PC)

	movem.l	(SP)+,D3/A2/A3
	rts

C2Jr1Draw:
	move	JR_ENERGIE(A3),D0
	ble.s	Jr1Expl

	lea		SprIdx(PC),A0
	move	(A3),D0			; JR_DIR(A3)
	lsr		#2,D0
	add		D0,D0
	move	0(A0,D0),D3		; D3 = index de sprite

	lea		JR_SHIPIMG(A3),A2
	adda	D3,A2			; A2 = sprite

	move.l	A2,A0
	movem	JR_XPOS(A3),D0/D1
	jsr		C2SprScreen(PC)
	beq.s	Jr1Motor

	lea		JR_SAVSHIP(A3),A1
	move.l	A2,A0
	move	JR_HIT(A3),D0	; joueur touche ?
	bne.s	.mask			; oui

	tst		JR_INVIS(A3)
	bne.s	Jr1Motor
	jsr		SpriteDraw(PC)
	bra.s	Jr1Motor

.mask:
	subq	#1,D0
	move	D0,JR_HIT(A3)
	jsr		SpriteMask(PC)

Jr1Motor:
	tst		JR_MOTOR(A3)	; moteur en action ?
	beq.s	.bye

	lea		MotorImg,A2
	adda	D3,A2

	move.l	A2,A0
	movem	JR_XPOS(A3),D0/D1
	jsr		C2SprScreen(PC)
	beq.s	.bye

	lea		JR_SAVFIRE(A3),A1
	move.l	A2,A0
	jsr		SpriteDraw(PC)
.bye:
	movem.l	(SP)+,D3/A2/A3
	rts

Jr1Expl:
	beq.s	Jr1Pod

	move	D0,D3
	addq	#1,D0
	move	D0,JR_ENERGIE(A3)

	lea		ExplImg,A2
	lea		SprIdx(PC),A0
	addi	#31,D3
	lsr		#2,D3
	add		D3,D3
	adda	0(A0,D3),A2

	move.l	A2,A0
	movem	JR_EXPLX(A3),D0/D1
	jsr		C2SprScreen(PC)
	beq.s	.bye

	lea		JR_SAVSHIP(A3),A1
	move.l	A2,A0
	jsr		SpriteDraw(PC)

.bye:
	movem.l	(SP)+,D3/A2/A3
	rts

Jr1Pod:
	movem.l	(SP)+,D3/A2/A3
	rts

**************************************************************************
*
*	Effacer les sprites relatifs aux joueurs

C2JrClear::
	lea		Joueur+(JR_SZOF*0)+JR_SAVSHIP,A0
	jsr		SpriteClear(PC)
	lea		Joueur+(JR_SZOF*0)+JR_SAVFIRE,A0
	jsr		SpriteClear(PC)
	lea		Joueur+(JR_SZOF*0)+JR_SAVEXPL,A0
	jsr		SpriteClear(PC)
	lea		Joueur+(JR_SZOF*1)+JR_SAVSHIP,A0
	jsr		SpriteClear(PC)
	lea		Joueur+(JR_SZOF*1)+JR_SAVFIRE,A0
	jsr		SpriteClear(PC)
	lea		Joueur+(JR_SZOF*1)+JR_SAVEXPL,A0
	jsr		SpriteClear(PC)
	rts

**************************************************************************
*
*	Calculer position selon vitesse
*
*	void C2CalcPos(int xvit,int yvit,POSITION *);

C2CalcPos::

.XPOS = 0
.YPOS = 2
.XPOSFRAC = 4
.YPOSFRAC = 6

.DECALEUR = 5
.MASQUEUR = 31

.xdo:
	tst		D0					; traiter vitesse horizontale
	beq.s	.ydo				; vitesse nulle
	add		.XPOSFRAC(A0),D0	; accumuler position fractionnelle
	beq.s	.xok
	bpl.s	.xpos				; positive

.xneg:
	neg		D0
	move	D0,D2
	lsr		#.DECALEUR,D2		; D2 = partie entiere de delta x fractionnel
	andi	#.MASQUEUR,D0		; D0 = partie fractionnel de delta x fractionnel
	sub		D2,(A0)
	neg		D0
	bra.s	.xwrap

.xpos:
	move	D0,D2
	lsr		#.DECALEUR,D2		; D2 = partie entiere de delta x fractionnel
	andi	#.MASQUEUR,D0		; D0 = partie fractionnel de delta x fractionnel
	add		D2,(A0)

.xwrap:
	andi	#(SPACE_W-1),(A0)

.xok:
	move	D0,.XPOSFRAC(A0)

.ydo:
	tst		D1					; traiter vitesse verticale
	beq.s	.bye				; nulle
	add		.YPOSFRAC(A0),D1	; accumuler position fractionnelle
	beq.s	.yok
	bpl.s	.ypos				; positive

.yneg:
	neg		D1
	move	D1,D2
	lsr		#.DECALEUR,D2		; D2 = partie entiere de delta y fractionnel
	andi	#.MASQUEUR,D1		; D1 = partie fractionnel de delta y fractionnel
	sub		D2,.YPOS(A0)
	neg		D1
	bra.s	.ywrap

.ypos:
	move	D1,D2
	lsr		#.DECALEUR,D2		; D2 = partie entiere de delta y fractionnel
	andi	#.MASQUEUR,D1		; D1 = partie fractionnel de delta y fractionnel
	add		D2,.YPOS(A0)

.ywrap:
	andi	#(SPACE_H-1),.YPOS(A0)

.yok:
	move	D1,.YPOSFRAC(A0)

.bye:
	rts

**************************************************************************
*
*	Obtenir mouvement du joueur au clavier
*
*	int C2GetMv1( void );

C2GetMv1::

.LROT = 0
.RROT = 1
.FIRE = 2
.MOTOR = 3
.BRAKE = 4
.HYPER = 5
.INVIS = 6
.GETCRYO = 7
.LETCRYO = 8
.REFILL = 11
.SURRENDER = 12
.PIEGE = 13

	lea		KeyStat(PC),A0
	lea		C2KeyCfg,A1
	move	#%10000000,D0
	moveq	#0,D1

*	fire

	move.b	.FIRE(A1),D1
	tst.b	KBD_KEYSTAT(A0,D1)
	beq.s	.invis
	ori		#%00001000,D0

*	actions

.invis:
	move.b	.INVIS(A1),D1
	tst.b	KBD_KEYSTAT(A0,D1)
	beq.s	.hyper
	ori		#$10,D0
	bra.s	.frein
.hyper:
	move.b	.HYPER(A1),D1
	tst.b	KBD_KEYSTAT(A0,D1)
	beq.s	.getcryo
	ori		#$20,D0
	bra.s	.frein
.getcryo:
	move.b	.GETCRYO(A1),D1
	tst.b	KBD_KEYSTAT(A0,D1)
	beq.s	.letcryo
	ori		#$30,D0
	bra.s	.frein
.letcryo:
	move.b	.LETCRYO(A1),D1
	tst.b	KBD_KEYSTAT(A0,D1)
	beq.s	.refill
	ori		#$40,D0
	bra.s	.frein
.refill:
	move.b	.REFILL(A1),D1
	tst.b	KBD_KEYSTAT(A0,D1)
	beq.s	.piege
	ori		#$50,D0
	bra.s	.frein
.piege:
	move.b	.PIEGE(A1),D1
	tst.b	KBD_KEYSTAT(A0,D1)
	beq.s	.surrender
	ori		#$60,D0
	bra.s	.frein
.surrender:
	move.b	.SURRENDER(A1),D1
	tst.b	KBD_KEYSTAT(A0,D1)
	beq.s	.frein
	ori		#$70,D0

*	mouvements

.frein:
	move.b	.BRAKE(A1),D1
	tst.b	KBD_KEYSTAT(A0,D1)
	beq.s	.rrot
	or		#%00000010,D0
	rts

.rrot:
	move.b	.RROT(A1),D1
	tst.b	KBD_KEYSTAT(A0,D1)
	beq.s	.lrot
	or		#%00000101,D0
	bra.s	.motor

.lrot:
	move.b	.LROT(A1),D1
	tst.b	KBD_KEYSTAT(A0,D1)
	beq.s	.motor
	or		#%00000011,D0

.motor:
	move.b	.MOTOR(A1),D1
	tst.b	KBD_KEYSTAT(A0,D1)
	beq.s	.bye
	addq	#1,D0

.bye:
	rts

**************************************************************************
*
*	Initialiser les donnees d'un joueur
*
*	void C2JrReset( void )

C2JrReset::

	moveq	#0,D0

	lea		Joueur,A1
	moveq	#0,D1

.loop:

	move	D1,JR_ID(A1)
	move	D0,(A1)				; JR_DIR(A1)
	move.l	D0,JR_XPOSFRAC(A1)
	move.l	D0,JR_XVIT(A1)
	move.l	D0,JR_XVITFRAC(A1)
	move	#31,JR_DOMMAGE(A1)
	move	D0,JR_MOTOR(A1)
	move	D0,JR_HIT(A1)
	move	D0,JR_CRYOGEN(A1)
	move	D0,JR_INVIS(A1)
	move	D0,JR_MINE(A1)
	move	#8192,JR_ENERGIE(A1)
	move	D0,JR_MISTYPE(A1)
	move	D0,JR_NBASE(A1)
	move	D0,JR_NFULLBASE(A1)
	move.l	D0,JR_COUNTER(A1)
	move.l	D0,JR_PODCNT(A1)
	move	D0,JR_MIS+(MIS_SZOF*0)+MIS_ON(A1)
	move	D0,JR_MIS+(MIS_SZOF*1)+MIS_ON(A1)
	lea		JR_SAVSHIP(A1),A0
	move.l	D0,(A0)+
	move.l	D0,(A0)+
	move.l	D0,(A0)+
	move.l	D0,(A0)+
	lea		JR_SAVFIRE(A1),A0
	move.l	D0,(A0)+
	move.l	D0,(A0)+
	move.l	D0,(A0)+
	move.l	D0,(A0)+

	lea		JR_SZOF(A1),A1
	addq	#1,D1
	cmpi	#2,D1
	blt.s	.loop

	rts

**************************************************************************
*
*	Boucle principale
*
*	void C2Play( int mode )
*
*	Note
*		mode = 0 alors Demo
*		mode = 1 alors Modem

C2Play::

.SAVREGS reg D3/D4/D5/D7/A3/A4/A5

	movem.l	#.SAVREGS,-(SP)

	move	D0,D4					; D4 = mode de jeu (demo ou modem)

	lea		Joueur,A3				; A3 = Joueur
	lea		JR_SZOF*0(A3),A4		; A4 = maitre
	lea		JR_SZOF*1(A3),A5		; A5 = esclave
	move	Maitre,D0
	bne.s	.1
	exg		A4,A5

.1:

	move	MoveScale,D5			; D5 = MoveScale
	moveq	#0,D7					; D7 = iteration

*	initialiser mouvement
	move	#$80,D3					; D3 = nxtmove
	move	D3,JR_MOVE(A4)
	move	D3,JR_MOVE(A5)

*	selon mode de jeu...
	tst		D4						; jeu par modem (ou midi) ?
	beq.s	.loop					; non

*	synchroniser les deux joueurs
	jsr		SyncStart(PC)
	bne		.bye

*	transmettre mouvement initial avec anticipation
	move	D3,D0
	jsr		MdmWrByte(PC)

.loop:

	move	JR_MOVE(A4),JR_OLDMOVE(A4)
	move	JR_MOVE(A5),JR_OLDMOVE(A5)

	move	D7,D0					; if ((iteration & MoveScale) == 0)
	and		D5,D0
	bne.s	.4

*	obtenir mouvement des joueurs selon mode de jeu
	tst		D4
	bne.s	.modem


*	mode demo
.demo:
	jsr		C2GetMv1(PC)
	move	D0,JR_MOVE(A3)

	; lire et traiter action au clavier
	jsr		LookKeybd(PC)
	beq.s	.4

	; quitter le jeu ?
	cmpi	#$61,D0				; Undo ?
	bne.s	.4					; non
	move	#3,JouteStatus
	bra.s	.4


*	mode modem
.modem:
	move	D3,JR_MOVE(A3)				; _joueur[0].move = nxtmove
	clr		JR_MOVE+JR_SZOF(A3)			; _joueur[1].move = 0
.mdm_loop:
	jsr		RecvModem(PC)
	tst		D0
	bne.s	.4							; obligation de quitter la boucle
	tst		JR_MOVE+JR_SZOF(A3)			; tant que _joueur[1].move == 0
	beq.s	.mdm_loop
	jsr		C2GetMv1(PC)				; nxtmove = C2GetMv1()
	move	D0,D3
	jsr		MdmWrByte(PC)				; transmettre mouvement anticipe

	; lire et traiter action au clavier
	jsr		LookKeybd(PC)
	beq.s	.4

	; transmettre un message a l'adversaire ?
	cmp.b	C2KeyCfg+10,D0
	bne.s	.4
	moveq	#1,D0
	jsr		MdmPost(PC)


.4:

*	marquer position (radar ami) ?
	lea		KeyStat(PC),A0
	moveq	#0,D0
	move.b	C2KeyCfg+9,D0
	tst.b	KBD_KEYSTAT(A0,D0)
	beq.s	.5
	move	JR_XPOS(A3),JR_RADRXPOS(A3)
	move	JR_YPOS(A3),JR_RADRYPOS(A3)

.5:

*	deplacer joueurs
	move.l	A4,A0
	jsr		C2JrMove(PC)
	move.l	A5,A0
	jsr		C2JrMove(PC)

*	un des joueurs se rend ?
	move	C2Winner(PC),D0
	bne		.bye

*	deplacer missiles
	move.l	A4,A0
	jsr		C2MisMove(PC)
	move.l	A5,A0
	jsr		C2MisMove(PC)

*	deplacer etoiles
	jsr		C2StarMove(PC)

*	attendre que l'ecran soit bascule
	jsr		SwapWait(PC)

*	quitter le jeu ?
	move	JouteStatus,D0
	bne		.bye

*	effacer joueurs
	jsr		C2JrClear(PC)

*	effacer missiles et mine furtive
	jsr		C2MisClear(PC)

*	effacer les bases
	jsr		C2BaseClear(PC)

*	effacer	etoiles
	jsr		C2StarClear(PC)

*	dessiner etoiles
	jsr		C2StarDraw(PC)

*	dessiner joueurs
	move.l	A4,A0
	jsr		C2JrDraw(PC)
	move.l	A5,A0
	jsr		C2JrDraw(PC)

*	dessiner missiles
	move.l	A4,A0
	jsr		C2MisDraw(PC)
	move.l	A5,A0
	jsr		C2MisDraw(PC)

*	dessiner mine furtive
	jsr		C2PiegeDraw(PC)

*	dessiner bases
	jsr		C2BaseDraw(PC)

*	dessiner jauges
	jsr		C2EnerDraw(PC)
	jsr		JrRadrDraw(PC)
	jsr		BsRadrDraw(PC)
	jsr		JrMapDraw(PC)
	jsr		InvisDraw(PC)
	jsr		PiegeDraw(PC)
	jsr		C2CryoDraw(PC)

*	basculer ecran
	jsr		SwapScreen(PC)

*	detecter et traiter les collisions
	jsr		BaseDo(PC)
	move.l	A4,A0
	move.l	A5,A1
	jsr		C2JrColl(PC)
	move.l	A5,A0
	move.l	A4,A1
	jsr		C2JrColl(PC)

*	iteration++
	addq	#1,D7

*	verifier si le jeu se termine
.jr1_end:
	tst		JR_NBASE(A4)
	bne.s	.jr2_end
	tst		JR_CRYOGEN(A4)
	bne.s	.jr2_end
	move	JR_ID(A4),D0
	eori	#1,D0
	addq	#2,D0
	move	D0,C2Winner
	bra.s	.bye

.jr2_end:
	tst		JR_NBASE(A5)
	bne		.loop
	tst		JR_CRYOGEN(A5)
	bne		.loop
	move	JR_ID(A5),D0
	eori	#1,D0
	addq	#2,D0
	move	D0,C2Winner

.bye:
	movem.l	(SP)+,#.SAVREGS
	rts

C2Winner::
	dc.w	0

.end
