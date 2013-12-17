
.include 'H:\\STRUCT_S.IN'

**************************************************************************
*
*	Traiter action et mouvement du joueur
*
*	void C2JrMove( JOUEUR *_joueur )
*
*	A0 = _joueur

C2JrMove::

SAVREGS reg D3/A3

	movem.l	#SAVREGS,-(SP)

	move.l	A0,A3

	move	JR_MOVE(A3),D0			; D0 = mouvement du joueur
	andi	#$70,D0					; D0 = action du joueur
	cmpi	#$70,D0					; reddition du joueur ?
	bne.s	.1						; non
	move	JR_ID(A3),D0
	eori	#1,D0
	addq	#4,D0
	move	D0,C2Winner
	bra		bye

.1:
	tst		JR_ENERGIE(A3)
	bgt.s	do_it

	move	#$80,D0
	move	D0,JR_MOVE(A3)
	addq.l	#1,JR_PODCNT(A3)

do_it:
	addq.l	#1,JR_COUNTER(A3)

*	traiter mode d'invisibilite

	tst		JR_INVIS(A3)
	beq.s	action

	subq	#1,JR_ENERGIE(A3)
	cmpi	#256,JR_ENERGIE(A3)		; energie minimum requise pour invisibilite
	bge.s	action
	clr		JR_INVIS(A3)

*	traiter les actions

action:
	tst		D0						; action disponible ?
	beq		move					; non

	move	JR_OLDMOVE(A3),D1
	andi	#$70,D1
	cmp		D1,D0
	beq		move

*	invisibilite ?

invis:
	cmpi	#$10,D0
	bne.s	hyper
	cmpi	#256,JR_ENERGIE(A3)		; energie minimale requise
	ble		move
	eori	#1,JR_INVIS(A3)			; bascule indicateur
	bra		move

*	hyper espace ?

hyper:
	cmpi	#$20,D0
	bne.s	piege
	cmpi	#512,JR_ENERGIE(A3)		; energie minimale requise
	ble.s	move

	subi	#512,JR_ENERGIE(A3)		; consommation d'energie

	jsr		rand(PC)				; nouvelle position x
	andi	#(SPACE_W-1),D0
	move	D0,JR_XPOS(A3)

	jsr		rand(PC)				; nouvelle position y
	andi	#(SPACE_H-1),D0
	move	D0,JR_YPOS(A3)

	moveq	#0,D0
	move.l	D0,JR_XPOSFRAC(A3)
	move.l	D0,JR_XVIT(A3)
	move.l	D0,JR_XVITFRAC(A3)

	tst		JR_ID(A3)				; modifier decor stellaire si joueur 0
	bne.s	move

	move.l	A2,-(SP)
	lea		Stars,A2
	move	NStars(PC),D3
	subq	#1,D3
.loop:
	moveq	#0,D1
	moveq	#0,D0
	move.l	A2,A0
	jsr		C2StarCreate(PC)
	lea		STAR_SZOF(A2),A2
	dbf		D3,.loop
	move.l	(SP)+,A2
	bra.s	move

*	lacher mine furtive ?

piege:
	cmpi	#$60,D0
	bne.s	move
	tst		JR_MINE(A3)				; mine furtive deja en action ?
	bne.s	move
	move	#1,JR_MINE(A3)
	move.l	JR_XPOS(A3),JR_MINEXPOS(A3)
	move.l	JR_XVIT(A3),JR_MINEXVIT(A3)

*	traiter mouvements du joueur

move:

	move	JR_MOVE(A3),D0
	andi	#7,D0
	add		D0,D0
	add		D0,D0
	jmp		.vects(PC,D0)
.vects:
	jmp		repos(PC)
	jmp		accel(PC)
	jmp		frein(PC)
	jmp		lrot(PC)
	jmp		lrot_accel(PC)
	jmp		rrot(PC)
	jmp		rrot_accel(PC)
	jmp		bye(PC)

repos:
	clr		JR_MOTOR(A3)
	bra		calcpos

accel:
	move	#1,JR_MOTOR(A3)
	bra		motor

*	le frein doit etre inversement proportionnel au chargement du vaisseau

frein:
	moveq	#0,D0
	move	D0,JR_MOTOR(A3)
	move.l	D0,JR_XVITFRAC(A3)

	move	JR_CRYOGEN(A3),D0
	move.b	.inertie(PC,D0),D0
	move	D0,D1
	subq	#1,D1

	move	JR_XVIT(A3),D2
	muls	D1,D2
	divs	D0,D2
	move	D2,JR_XVIT(A3)

	move	JR_YVIT(A3),D2
	muls	D1,D2
	divs	D0,D2
	move	D2,JR_YVIT(A3)

	bra		calcpos

.inertie:	dc.b	8,8,16,16,24,24,32,32,40,40

lrot:
	clr		JR_MOTOR(A3)
	move	(A3),D0					; JR_DIR(A3)
	subq	#1,D0
	andi	#63,D0
	move	D0,(A3)					; JR_DIR(A3)
	bra		calcpos

lrot_accel:
	move	#1,JR_MOTOR(A3)
	move	(A3),D0					; JR_DIR(A3)
	subq	#1,D0
	andi	#63,D0
	move	D0,(A3)					; JR_DIR(A3)
	bra.s	motor

rrot:
	clr		JR_MOTOR(A3)
	move	(A3),D0					; JR_DIR(A3)
	addq	#1,D0
	andi	#63,D0
	move	D0,(A3)					; JR_DIR(A3)
	bra		calcpos

rrot_accel:
	move	#1,JR_MOTOR(A3)
	move	(A3),D0					; JR_DIR(A3)
	addq	#1,D0
	andi	#63,D0
	move	D0,(A3)					; JR_DIR(A3)

*	l'acceleration est inversement proportionnelle au chargement

motor:
	clr		JR_MOTOR(A3)
	tst		JR_ENERGIE(A3)			; energie disponible suffisante ?
	ble		calcpos

	move	#1,JR_MOTOR(A3)
	subq	#1,JR_ENERGIE(A3)		; consommation d'energie
	bgt.s	.1

	move	#1,JR_ENERGIE(A3)		; energie minimale

.1:	move	(A3),D2					; JR_DIR(A3)
	lsr		#2,D2
	add		D2,D2
	lea		ShipXVit(PC),A0
	move	0(A0,D2),D0				; D0 = vitesse x
	lea		ShipYVit(PC),A0
	move	0(A0,D2),D1				; D1 = vitesse y

	move	JR_CRYOGEN(A3),D2		; D2 = chargement
	lsr		#1,D2
	asr		D2,D0					; D0 = vitesse x avec inertie
	asr		D2,D1					; D1 = vitesse y avec inertie

xvit:
	move	JR_XVITFRAC(A3),D2
	add		D0,D2
	bmi.s	xfracneg
xfracpos:
	move	D2,D3
	andi	#127,D3
	move	D3,JR_XVITFRAC(A3)
	lsr		#7,D2
	add		JR_XVIT(A3),D2
	cmpi	#127,D2
	ble.s	xvitok
	moveq	#127,D2
	bra.s	xvitok
xfracneg:
	neg		D2
	move	D2,D3
	andi	#127,D3
	neg		D3
	move	D3,JR_XVITFRAC(A3)
	lsr		#7,D2
	neg		D2
	add		JR_XVIT(A3),D2
	cmpi	#-127,D2
	bge.s	xvitok
	moveq	#-127,D2
xvitok:
	move	D2,JR_XVIT(A3)

yvit:
	move	JR_YVITFRAC(A3),D2
	add		D1,D2
	bmi.s	yfracneg
yfracpos:
	move	D2,D3
	andi	#127,D3
	move	D3,JR_YVITFRAC(A3)
	lsr		#7,D2
	add		JR_YVIT(A3),D2
	cmpi	#127,D2
	ble.s	yvitok
	moveq	#127,D2
	bra.s	yvitok
yfracneg:
	neg		D2
	move	D2,D3
	andi	#127,D3
	neg		D3
	move	D3,JR_YVITFRAC(A3)
	lsr		#7,D2
	neg		D2
	add		JR_YVIT(A3),D2
	cmpi	#-127,D2
	bge.s	yvitok
	moveq	#-127,D2
yvitok:
	move	D2,JR_YVIT(A3)

calcpos:
	lea		JR_XPOS(A3),A0
	movem	JR_XVIT(A3),D0/D1
	jsr		C2CalcPos(PC)

bye:
	movem.l	(SP)+,#SAVREGS
	rts

.end
