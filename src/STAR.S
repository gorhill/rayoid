
.include 'H:\\STRUCT_S.IN'

**************************************************************************
*
*	Mode Simple - Creer les etoiles
*
*	void S2StarCreate( void );

S2StarCreate::

.SAVREGS reg D3/A3

	movem.l	#.SAVREGS,-(SP)

	lea		Stars,A3
	move	NStars(PC),D3
	subq	#1,D3

.loop:
	move	D3,D0
	andi	#3,D0
	move	D0,(A3)				; STAR_MAG(A3)

	jsr		FastRand(PC)
	divu	#320,D0
	swap	D0
	move	D0,STAR_XPOS(A3)

	jsr		FastRand(PC)
	divu	#192,D0
	swap	D0
	move	D0,STAR_YPOS(A3)

	lea		STAR_SZOF(A3),A3
	dbf		D3,.loop

	movem.l	(SP)+,#.SAVREGS
	rts

**************************************************************************
*
*	Creer une nouvelle etoile selon direction. Si xvit et yvit = 0,
*	l'etoile est cree a une position quelconque de l'ecran.
*
*	void C2StarCreate(STAR *,xvit,yvit)

C2StarCreate::

	move	D3,-(SP)
	move	D4,-(SP)

	move	D0,D3
	move	D1,D4

	jsr		FastRand(PC)				; xpos
	andi	#255,D0						; 0-255
	addi	#16,D0
	move	D0,STAR_XPOS(A0)

	jsr		FastRand(PC)				; ypos
	divu	#172,D0						; 0-171
	swap	D0
	addq	#4,D0
	move	D0,STAR_YPOS(A0)

.xtst:
	move	D3,D1							; xvit et yvit != 0 ?
	beq.s	.adjust
	bpl.s	.ytst
	neg		D1
.ytst:
	move	D4,D2
	beq.s	.adjust
	bpl.s	.hasard
	neg		D2
.hasard:
	add		D1,D2
	jsr		FastRand(PC)
	divu	D2,D0
	swap	D0
	sub		D1,D0

.adjust:
	tst		D3
	bpl.s	.xpos
.xneg:
	tst		D4
	bpl.s	.xnegypos

.xnegyneg:
	tst		D0
	bpl.s	.setymin
	move	#16,STAR_XPOS(A0)
	move	(SP)+,D4
	move	(SP)+,D3
	rts
.xnegypos:
	beq.s	.setxmin
	tst		D0
	bpl.s	.setymax
	move	#16,STAR_XPOS(A0)
	move	(SP)+,D4
	move	(SP)+,D3
	rts

.xpos:
	beq.s	.xnul
	tst		D4
	bpl.s	.xposypos
.xposyneg:
	tst		D0
	bpl.s	.setymin
	move	#271,STAR_XPOS(A0)
	move	(SP)+,D4
	move	(SP)+,D3
	rts
.xposypos:
	beq.s	.setxmax
	tst		D0
	bpl.s	.setymax
	move	#271,STAR_XPOS(A0)
	move	(SP)+,D4
	move	(SP)+,D3
	rts

.xnul:
	tst		D4
	bmi.s	.setymin
.xnulypos:
	beq.s	.bye

.setymax:
	move	#175,STAR_YPOS(A0)
	move	(SP)+,D4
	move	(SP)+,D3
	rts

.setxmax:
	move	#271,STAR_XPOS(A0)
	move	(SP)+,D4
	move	(SP)+,D3
	rts

.setxmin:
	move	#16,STAR_XPOS(A0)
	move	(SP)+,D4
	move	(SP)+,D3
	rts

.setymin:
	move	#4,STAR_YPOS(A0)

.bye:
	move	(SP)+,D4
	move	(SP)+,D3
	rts

**************************************************************************
*
*	Deplacer les etoiles
*
*	void C2StarMove( void )

C2StarMove::

.SAVREGS reg D3/D4/D5/D7/A4

	movem	Joueur+JR_XVIT,D0/D1	; D0 et D1 = xvit et yvit du joueur 0
	move	D0,D2
	or		D1,D2					; deplacement nul ?
	bne.s	.move					; non
	rts

.move:
	movem.l	#.SAVREGS,-(SP)

	move	D0,D5
	move	D1,D7
	neg		D5						; deplacement contraire au vaisseau
	neg		D7
	moveq	#0,D3					; decaleur
	moveq	#0,D2					; masqueur

	moveq	#0,D4					; D4 = numero de l'etoile traitee
	lea		Stars,A4				; A4 = Stars
	bra.s	.loop

.decaleur:	dc.b	5,6,7,8,5,6,7,8,5,6,7,8,5,6,7,8
			dc.b	5,6,7,8,5,6,7,8,5,6,7,8,5,6,7,8
.masqueur:	dc.b	31,63,127,255,31,63,127,255,31,63,127,255,31,63,127,255
			dc.b	31,63,127,255,31,63,127,255,31,63,127,255,31,63,127,255

.loop:
	move.b	.decaleur(PC,D4),D3		; D3 = decaleur (partie entiere)
	move.b	.masqueur(PC,D4),D2		; D2 = masqueur (partie fractionnelle)

.xdo:
	move	D5,D1					; traiter vitesse horizontale
	beq.s	.ydo					; vitesse nulle
	add		STAR_XPOSFRAC(A4),D1
	beq.s	.xok
	bpl.s	.xpos					; positive
.xneg:
	neg		D1
	move	D1,D0
	lsr		D3,D0					; D0 = partie entiere de delta x fractionnel
	and		D2,D1					; D1 = partie fractionnel de delta x frationnel
	sub		D0,STAR_XPOS(A4)
	neg		D1
	bra.s	.xok
.xpos:
	move	D1,D0
	lsr		D3,D0					; D0 = partie entiere de delta x fractionnel
	and		D2,D1					; D1 = partie fractionnel de delta x frationnel
	add		D0,STAR_XPOS(A4)
.xok:
	move	D1,STAR_XPOSFRAC(A4)

.ydo:
	move	D7,D1					; traiter vitesse verticale
	beq.s	.check					; nulle
	add		STAR_YPOSFRAC(A4),D1
	beq.s	.yok
	bpl.s	.ypos					; positive
.yneg:
	neg		D1
	move	D1,D0
	lsr		D3,D0					; D0 = partie entiere de delta x fractionnel
	and		D2,D1					; D1 = partie fractionnel de delta x frationnel
	sub		D0,STAR_YPOS(A4)
	neg		D1
	bra.s	.yok
.ypos:
	move	D1,D0
	lsr		D3,D0					; D0 = partie entiere de delta x fractionnel
	and		D2,D1					; D1 = partie fractionnel de delta x frationnel
	add		D0,STAR_YPOS(A4)
.yok:
	move	D1,STAR_YPOSFRAC(A4)

.check:
	move	STAR_XPOS(A4),D0
	subi	#16,D0
	cmpi	#255,D0					; x < 0 ou >= 256 ?
	bhi.s	.create
	move	STAR_YPOS(A4),D0
	subq	#4,D0
	cmpi	#171,D0					; y < 0 ou >= 172 ?
	bls.s	.next

.create:
	move	D7,D1					; yvit
	neg		D1
	move	D5,D0					; xvit
	neg		D0
	move.l	A4,A0
	jsr		C2StarCreate(PC)
	moveq	#0,D2

.next:
	lea		STAR_SZOF(A4),A4
	addq	#1,D4
	cmp		NStars(PC),D4			; fin de la liste ?
	blt		.loop

	movem.l	(SP)+,#.SAVREGS
	rts

**************************************************************************
*
*	Dessiner les etoiles dans l'ecran cache

S2StarDraw::
C2StarDraw::

.SAVREGS reg D3/A2/A3/A4

	movem.l	#.SAVREGS,-(SP)

	lea		_Screens(PC),A4
	move	Hide4Screen(PC),D3		; D3 = index ecran cache
	move.l	(A4,D3),A4				; A4 = ecran a utiliser

	lea		__StarImg,A3			; A3 = liste des pointeurs d'image
	lea		Stars,A2				; A2 = Stars[]
	moveq	#0,D2					; D2 = numero de l'etoile
.loop:
	move	STAR_XPOS(A2),D0		; D1 = position x
	andi	#15,D0					; D1 = index d'image selon xpos
	add.b	.magimg(PC,D2),D0		; D0 = image selon magnitude
	add		D0,D0
	add		D0,D0					; D0 = index selon magnitude et xpos
	move.l	(A3,D0),A0				; A0 = _src

	movem	STAR_XPOS(A2),D0/D1		; trouve index ecran selon x,y
	jsr		FindXYIdx(PC)			; resultat dans D0
	move.l	A4,A1					; A1 = ecran a utiliser
	adda	D0,A1					; A1 = adresse ecran
	move.l	A1,STAR_SCRADR(A2,D3)	; sauvegarde adresse ecran pour effacement ulterieur

	move.l	(A0)+,D0
	or.l	D0,(A1)+
	move.l	(A0)+,D0
	or.l	D0,(A1)+
.next:
	lea		STAR_SZOF(A2),A2
	addq	#1,D2
	cmp		NStars(PC),D2
	blt.s	.loop

	movem.l	(SP)+,#.SAVREGS
	rts

.magimg:
	dc.b	0,16,32,48,0,16,32,48,0,16,32,48,0,16,32,48
	dc.b	0,16,32,48,0,16,32,48,0,16,32,48,0,16,32,48

**************************************************************************
*
*	Effacer les etoiles dans l'ecran cache

S2StarClear::
C2StarClear::

	lea		Stars+STAR_SCRADR,A1	; A1 = Stars
	adda	Hide4Screen(PC),A1
	moveq	#0,D1
	move	NStars(PC),D2
	subq	#1,D2					; D2 = nombre d'etoile a traiter
.loop:
	move.l	(A1),D0					; D0 = adresse ecran
	beq.s	.next
	move.l	D0,A0
	move.l	D1,(A0)+
	move.l	D1,(A0)+
	move.l	D1,(A1)
.next:
	lea		STAR_SZOF(A1),A1
	dbf		D2,.loop

	rts

NStars::	dc.w	0

.end
