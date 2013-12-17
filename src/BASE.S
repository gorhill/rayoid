
.include 'H:\\STRUCT_S.IN'

**************************************************************************
*
*	Gestion des bases
*
*	Pour chaque base
*
*		Faire evoluer la base
*
*		Pour joueur
*			Si base ennemie
*				Si joueur dans zone de defense
*					Base ennemie attaque joueur
*				Pour chaque missile joueur
*					Verifier si la base ennemie est atteinte
*			Si base amie ou neutre
*				Si joueur charge ou decharge et contact est etablie
*					Modifier etat de la base
*
*	Type de base
*		-1 = non-developpe
*		 0 = detruite joueur 1
*		 1 = detruite joueur 2
*		 2 = en developpement joueur 1
*		 3 = en developpement joueur 2
*		 4 = developpe joueur 1
*		 5 = developpe joueur 2

BaseDo::

SAVREGS reg D3/D4/D5/D7/A2/A3/A4/A5

	movem.l	#SAVREGS,-(SP)

	lea		Joueur,A5
	lea		JR_SZOF(A5),A4
	tst		Maitre
	bne.s	master_init
	exg		A5,A4

master_init:
	clr.l	JR_NBASE(A5)
	move	JR_MOVE(A5),D5		; D5 = action joueur maitre
	andi	#$70,D5				; isoler action
	beq.s	slave_init
	cmpi	#$50,D5				; faire le plein ?
	beq.s	slave_init
	move	JR_OLDMOVE(A5),D0
	andi	#$70,D0
	cmp		D0,D5
	bne.s	slave_init
	moveq	#0,D5

slave_init:
	clr.l	JR_NBASE(A4)
	move	JR_MOVE(A4),D4		; D4 = action joueur esclave
	andi	#$70,D4				; isoler action
	beq.s	base_do
	cmpi	#$50,D4				; faire le plein ?
	beq.s	base_do
	move	JR_OLDMOVE(A4),D0
	andi	#$70,D0
	cmp		D0,D4
	bne.s	base_do
	moveq	#0,D4

base_do:
	lea		Bases,A3
	moveq	#NBASE-1,D7

base_loop:

*	faire evoluer la base selon type

	move	BASE_MODE(A3),D0
	addq	#1,D0
	add		D0,D0
	add		D0,D0
	jmp		.vects(PC,D0)
.vects:
	jmp		neutre(PC)
	jmp		neutre(PC)
	jmp		neutre(PC)
	jmp		build(PC)
	jmp		build(PC)
	jmp		base(PC)
	jmp		base(PC)

neutre:

.master:
	cmpi	#$40,D5					; maitre colonise ?
	bne.s	.slave					; non
	tst		JR_CRYOGEN(A5)			; chargement disponible ?
	beq.s	.slave					; non
	movem	JR_XPOS(A5),D0/D1		; contact etabli ?
	movem	BASE_XPOS(A3),D2/D3
	bsr		CalcDist
	cmpi	#16,D0
	bge.s	.slave
	cmpi	#16,D1
	bge.s	.slave
	moveq	#0,D5
	move	#CRYO_UNIT,BASE_ENERGIE(A3)	; decharger colonie sur la base
	subq	#1,JR_CRYOGEN(A5)
	move	JR_ID(A5),D2
	addq	#2,D2
	move	D2,BASE_MODE(A3)
	addq	#1,JR_NBASE(A5)
	clr		BASE_COUNTER(A3)
	tst		BASE_MAP(A3)
	beq		base_next
	movem	BASE_XPOS(A3),D0/D1
	jsr		BsMapDraw(PC)
	bra		base_next

.slave:
	cmpi	#$40,D4					; esclave colonise ?
	bne		base_next				; non
	tst		JR_CRYOGEN(A4)			; chargement disponible ?
	beq		base_next				; non
	movem	JR_XPOS(A4),D0/D1		; contact etabli ?
	movem	BASE_XPOS(A3),D2/D3
	bsr		CalcDist
	cmpi	#16,D0
	bge		base_next
	cmpi	#16,D1
	bge		base_next
	moveq	#0,D4
	move	#CRYO_UNIT,BASE_ENERGIE(A3)	; decharger colonie sur la base
	subq	#1,JR_CRYOGEN(A4)
	move	JR_ID(A4),D2
	addq	#2,D2
	move	D2,BASE_MODE(A3)
	addq	#1,JR_NBASE(A4)
	clr		BASE_COUNTER(A3)
	tst		BASE_MAP(A3)
	beq		base_next
	movem	BASE_XPOS(A3),D0/D1
	jsr		BsMapDraw(PC)
	bra		base_next

build:
	move	BASE_ENERGIE(A3),D0		; vitesse de developpement selon
	moveq	#10,D1					; importance de la colonie
	lsr		D1,D0
	add		D0,BASE_COUNTER(A3)
	cmpi	#16384,BASE_COUNTER(A3)	; base completement developpee ?
	blt.s	.master
	addq	#2,BASE_MODE(A3)
	clr		BASE_COUNTER(A3)
	tst		BASE_MAP(A3)
	beq.s	.master
	move	BASE_MODE(A3),D2
	movem	BASE_XPOS(A3),D0/D1
	jsr		BsMapDraw(PC)

.master:
	move	BASE_MODE(A3),D0
	andi	#1,D0
	cmp		JR_ID(A5),D0
	bne.s	.master_ennemi

.master_ami:
	addq	#1,JR_NBASE(A5)
	move.l	A5,A2
	move	D5,D2
	bsr		base_ami
	beq.s	.slave_ennemi
	moveq	#0,D5			; action maitre consommee
.slave_ennemi:
	move.l	A4,A2
	bsr		base_ennemi
	bra.s	base_next

.master_ennemi:
	addq	#1,JR_NBASE(A4)
	move.l	A5,A2
	bsr		base_ennemi
.slave_ami:
	move.l	A4,A2
	move	D4,D2
	bsr.s	base_ami
	beq.s	base_next
	moveq	#0,D4			; action esclave consommee
	bra.s	base_next

base:
	addq	#1,BASE_COUNTER(A3)
	cmpi	#BS_ENERMAX,BASE_ENERGIE(A3)
	bge.s	.master
	move	BASE_COUNTER(A3),D0
	andi	#3,D0
	seq		D0
	neg.b	D0
	add		D0,BASE_ENERGIE(A3)

.master:
	move	BASE_MODE(A3),D0
	andi	#1,D0
	cmp		JR_ID(A5),D0
	bne.s	.master_ennemi

.master_ami:
	addq	#1,JR_NBASE(A5)
	addq	#1,JR_NFULLBASE(A5)
	move.l	A5,A2
	move	D5,D2
	bsr.s	base_ami
	beq.s	.slave_ennemi
	moveq	#0,D5			; action maitre consommee
.slave_ennemi:
	move.l	A4,A2
	bsr		base_ennemi
	bra.s	base_next

.master_ennemi:
	addq	#1,JR_NBASE(A4)
	addq	#1,JR_NFULLBASE(A4)
	move.l	A5,A2
	bsr		base_ennemi
.slave_ami:
	move.l	A4,A2
	move	D4,D2
	bsr.s	base_ami
	beq.s	base_next
	moveq	#0,D4			; action esclave consommee

base_next:
	lea		BASE_SZOF(A3),A3
	dbf		D7,base_loop

	movem.l	(SP)+,#SAVREGS
	rts

**************************************************************************
*
*	Traiter interaction base-joueur pour base amie
*
*	Entree
*		A3 = base
*		A2 = joueur
*		D2 = action
*	Sortie
*		D0 = action consommee

base_ami:
	tst		JR_ENERGIE(A2)			; joueur a perdu son vaisseau ?
	ble.s	pod						; oui
	tst		D2						; action presente ?
	beq.s	.bye
	cmpi	#$30,D2					; prendre colonie ?
	beq		get_cryo
	cmpi	#$40,D2					; coloniser ?
	beq		let_cryo
	cmpi	#$50,D2					; reparer vaisseau ?
	beq		refill
	moveq	#1,D0					; action consommee
.bye:
	rts

pod:
	movem	JR_XPOS(A2),D0/D1		; zone d'influence ?
	movem	BASE_XPOS(A3),D2/D3
	bsr		CalcDist
	cmpi	#128,D0
	bge.s	.bye
	cmpi	#86,D1
	bge.s	.bye
	cmpi	#8,D0					; contact etabli ?
	bge.s	.tract
	cmpi	#8,D1
	bge.s	.tract
.newship:
	move	#8192,JR_ENERGIE(A2)
	move	#1,BASE_ENERGIE(A3)
	clr.l	JR_XVIT(A2)
	clr.l	JR_XVITFRAC(A2)
	rts
.tract:
	movem	JR_XPOS(A2),D0/D1
	movem	BASE_XPOS(A3),D2/D3
	jsr		C2GetDir(PC)
	add		D0,D0
	lea		misXVit(PC),A0
	move	0(A0,D0),D1
	add		D1,JR_XVIT(A2)
	lea		misYVit(PC),A0
	move	0(A0,D0),D1
	add		D1,JR_YVIT(A2)
	moveq	#31,D0
	lea		JR_XVIT(A2),A0
	jsr		TrapVit(PC)
.bye:
	rts

get_cryo:
	cmpi	#8,JR_CRYOGEN(A2)		; chargement est a son maximum ?
	bge.s	.ok						; oui
	movem	JR_XPOS(A2),D0/D1		; contact etabli ?
	movem	BASE_XPOS(A3),D2/D3
	bsr		CalcDist
	cmpi	#16,D0
	bge.s	.fail
	cmpi	#16,D1
	bge.s	.fail
	cmpi	#BS_ENERMIN,BASE_ENERGIE(A3)	; colonie disponible ?
	ble.s	.ok								; non
	addq	#1,JR_CRYOGEN(A2)				; retirer colonie
	subi	#CRYO_UNIT,BASE_ENERGIE(A3)
.ok:
	moveq	#1,D0					; action consommee
	rts
.fail:
	moveq	#0,D0					; action non-consommee
	rts

let_cryo:
	tst		JR_CRYOGEN(A2)			; chargement disponible ?
	beq.s	.ok						; non
	movem	JR_XPOS(A2),D0/D1		; contact etabli ?
	movem	BASE_XPOS(A3),D2/D3
	bsr		CalcDist
	cmpi	#16,D0
	bge.s	.fail
	cmpi	#16,D1
	bge.s	.fail
	cmpi	#BS_ENERMAX-CRYO_UNIT,BASE_ENERGIE(A3)	; base saturee ?
	bgt.s	.ok										; oui
	addi	#CRYO_UNIT,BASE_ENERGIE(A3)	; decharger colonie sur la base
	subq	#1,JR_CRYOGEN(A2)
.ok:
	moveq	#1,D0					; action consommee
	rts
.fail:
	moveq	#0,D0					; action non-consommee
	rts

refill:
	movem	JR_XPOS(A2),D0/D1		; contact etabli ?
	movem	BASE_XPOS(A3),D2/D3
	bsr		CalcDist
	cmpi	#16,D0
	bge.s	.fail
	cmpi	#16,D1
	bge.s	.fail
	move	BASE_ENERGIE(A3),D0		; vitesse de reparation selon
	moveq	#10,D1					; energie de la base
	lsr		D1,D0
	add		D0,JR_ENERGIE(A2)
	sub		D0,BASE_ENERGIE(A3)
	cmpi	#JR_ENERMAX,JR_ENERGIE(A2)
	ble.s	.ok
	move	JR_ENERGIE(A2),D0
	subi	#JR_ENERMAX,D0
	move	#JR_ENERMAX,JR_ENERGIE(A2)
	add		D0,BASE_ENERGIE(A3)
.ok:
	moveq	#1,D0					; action consommee
	rts
.fail:
	moveq	#0,D0					; action non-consommee
	rts


**************************************************************************
*
*	Traiter interaction base-joueur pour base ennemie
*
*	Entree
*		A3 = base
*		A2 = joueur
*	Sortie
*		void

base_ennemi:

base_attack:
	tst		BASE_MIS+MIS_ON(A3)			; attaque en cours ?
	bmi.s	.misbye
	bne.s	.miscoll

	tst		JR_ENERGIE(A2)				; joueur hors-jeu ?
	ble		jr_attack					; oui

	movem	BASE_XPOS(A3),D0/D1			; zone de defense ?
	movem	JR_XPOS(A2),D2/D3
	bsr		CalcDist
	cmpi	#144,D0
	bge		jr_attack
	cmpi	#128,D1
	bge		jr_attack

	jsr		rand(PC)					; la base se defend
	andi	#127,D0
	addi	#63,D0
	move	D0,BASE_MIS+MIS_ON(A3)		; duree aleatoire
	jsr		rand(PC)
	andi	#3,D0
	move	D0,BASE_MIS+MIS_TYPE(A3)	; vitesse max aleatoire
	move.l	BASE_XPOS(A3),BASE_MIS+MIS_XPOS(A3)
	move.l	BASE_XPOSFRAC(A3),BASE_MIS+MIS_XPOSFRAC(A3)
	clr.l	BASE_MIS+MIS_XVIT(A3)
	bra		jr_attack

.misbye:
	addq	#1,BASE_MIS+MIS_ON(A3)		; missile en phase terminale
	bne		.mismov
	bra		jr_attack

.miscoll:
	movem	BASE_MIS+MIS_XPOS(A3),D0/D1	; joueur touche ?
	movem	JR_XPOS(A2),D2/D3
	bsr		CalcDist
	cmpi	#6,D0
	bge.s	.mison
	cmpi	#6,D1
	bge.s	.mison

	clr		BASE_MIS+MIS_ON(A3)
	move	#2,JR_HIT(A2)
	subi	#BSJR_HIT,JR_ENERGIE(A2)
	bgt.s	jr_attack

	move.l	A2,A0
	bsr		MakePod

	bra.s	jr_attack

.mison:
	subq	#1,BASE_MIS+MIS_ON(A3)		; deplacer le missile de la base
	bne.s	.misdir
	move	#-15,BASE_MIS+MIS_ON(A3)
	bra.s	.mismov

.misdir:
	movem	JR_XPOS(A2),D2/D3
	movem	BASE_MIS+MIS_XPOS(A3),D0/D1
	jsr		C2GetDir(PC)
	bmi.s	jr_attack
	add		D0,D0
	lea		misXVit(PC),A0
	move	0(A0,D0),D1
	add		D1,BASE_MIS+MIS_XVIT(A3)
	lea		misYVit(PC),A0
	move	0(A0,D0),D1
	add		D1,BASE_MIS+MIS_YVIT(A3)

	lea		misType(PC),A0
	move	BASE_MIS+MIS_TYPE(A3),D0
	move.b	0(A0,D0),D0
	lea		BASE_MIS+MIS_XVIT(A3),A0
	jsr		TrapVit(PC)

.mismov:
	lea		BASE_MIS+MIS_XPOS(A3),A0
	movem	BASE_MIS+MIS_XVIT(A3),D0/D1
	jsr		C2CalcPos(PC)

jr_attack:

.mis_1:
	tst		JR_MIS+(MIS_SZOF*0)+MIS_ON(A2)	; missile # 1 actif ?
	beq.s	.mis_2

	movem	BASE_XPOS(A3),D0/D1				; base touchee ?
	movem	JR_MIS+(MIS_SZOF*0)+MIS_XPOS(A2),D2/D3
	bsr		CalcDist
	cmpi	#8,D0
	bge.s	.mis_2
	cmpi	#8,D1
	bge.s	.mis_2

	clr		JR_MIS+(MIS_SZOF*0)+MIS_ON(A2)

	lea		JrBsDamage(PC),A0
	move	JR_MIS+(MIS_SZOF*0)+MIS_TYPE(A2),D0

	move	D0,D1
	addq	#2,D1
	move	D1,BASE_HIT(A3)

	add		D0,D0
	move	0(A0,D0),D0					; D0 = dommage selon type de missile

	sub		D0,BASE_ENERGIE(A3)
	bgt.s	.mis_2
	clr		BASE_ENERGIE(A3)
	move	#31,BASE_COUNTER(A3)
	clr		BASE_MIS+MIS_ON(A3)
	move	BASE_MODE(A3),D2
	andi	#1,D2
	move	D2,BASE_MODE(A3)
	tst		BASE_MAP(A3)
	beq.s	.mis_2
	movem	BASE_XPOS(A3),D0/D1
	jsr		BsMapDraw(PC)

.mis_2:
	tst		JR_MIS+(MIS_SZOF*1)+MIS_ON(A2)	; missile # 2 actif ?
	beq.s	.bye

	movem	BASE_XPOS(A3),D0/D1		; base touchee ?
	movem	JR_MIS+(MIS_SZOF*1)+MIS_XPOS(A2),D2/D3
	bsr		CalcDist
	cmpi	#8,D0
	bge.s	.bye
	cmpi	#8,D1
	bge.s	.bye

	clr		JR_MIS+(MIS_SZOF*1)+MIS_ON(A2)

	lea		JrBsDamage(PC),A0
	move	JR_MIS+(MIS_SZOF*0)+MIS_TYPE(A2),D0

	move	D0,D1
	addq	#2,D1
	move	D1,BASE_HIT(A3)

	add		D0,D0
	move	0(A0,D0),D0					; D0 = dommage selon type de missile

	sub		D0,BASE_ENERGIE(A3)
	bgt.s	.bye
	clr		BASE_ENERGIE(A3)
	move	#31,BASE_COUNTER(A3)
	clr		BASE_MIS+MIS_ON(A3)
	move	BASE_MODE(A3),D2
	andi	#1,D2
	move	D2,BASE_MODE(A3)
	tst		BASE_MAP(A3)
	beq.s	.bye
	movem	BASE_XPOS(A3),D0/D1
	jsr		BsMapDraw(PC)

.bye:
	rts

**************************************************************************
*
*	Collision missile/mine furtive et joueur adverse
*
*	void C2JrColl( JOUEUR *_predateur, JOUEUR *_proie )
*
*	A0 = _predateur
*	A1 = _proie

C2JrColl::

.SAVREGS reg D3/A3/A4

	tst		JR_ENERGIE(A1)
	bgt.s	.doit
	rts

.doit:
	movem.l	#.SAVREGS,-(SP)

	move.l	A0,A3
	move.l	A1,A4

.mis_1:
	tst		JR_MIS+MIS_ON(A3)
	beq.s	.mis_2
	movem	JR_MIS+MIS_XPOS(A3),D0/D1	; joueur ennemi touche ?
	movem	JR_XPOS(A4),D2/D3
	bsr		CalcDist
	cmpi	#6,D0
	bge.s	.mis_2
	cmpi	#6,D1
	bge.s	.mis_2

	clr		JR_MIS+MIS_ON(A3)

	lea		JrJrDamage(PC),A0
	move	JR_MIS+MIS_TYPE(A3),D0

	move	D0,D1
	addq	#1,D1
	move	D1,JR_HIT(A4)

	add		D0,D0
	move	0(A0,D0),D0				; D0 = dommage selon type de missile

	sub		D0,JR_ENERGIE(A4)
	bgt.s	.mis_2

	move.l	A4,A0
	bsr.s	MakePod
	bra.s	.bye

.mis_2:
	tst		JR_MIS+MIS_SZOF+MIS_ON(A3)
	beq.s	.piege
	movem	JR_MIS+MIS_SZOF+MIS_XPOS(A3),D0/D1	; joueur ennemi touche ?
	movem	JR_XPOS(A4),D2/D3
	bsr		CalcDist
	cmpi	#6,D0
	bge.s	.piege
	cmpi	#6,D1
	bge.s	.piege

	clr		JR_MIS+MIS_SZOF+MIS_ON(A3)

	lea		JrJrDamage(PC),A0
	move	JR_MIS+MIS_SZOF+MIS_TYPE(A3),D0

	move	D0,D1
	addq	#1,D1
	move	D1,JR_HIT(A4)

	add		D0,D0
	move	0(A0,D0),D0				; D0 = dommage selon type de missile

	sub		D0,JR_ENERGIE(A4)
	bgt.s	.piege

	move.l	A4,A0
	bsr.s	MakePod
	bra.s	.bye

.piege:
	tst		JR_MINE(A3)			; mine furtive en action ?
	beq.s	.bye
	movem	JR_MINEXPOS(A3),D0/D1		; joueur ennemi touche ?
	movem	JR_XPOS(A4),D2/D3
	bsr		CalcDist
	cmpi	#6,D0
	bge.s	.bye
	cmpi	#6,D1
	bge.s	.bye
	clr		JR_MINE(A3)
	move.l	A4,A0
	bsr.s	MakePod

.bye:
	movem.l	(SP)+,#.SAVREGS
	rts

**************************************************************************
*
*	Ejecter pod lors de la destruction du vaisseau

MakePod:
	move	#-31,JR_ENERGIE(A0)
	clr		JR_CRYOGEN(A0)
	clr		JR_INVIS(A0)

	move.l	JR_XPOS(A0),JR_EXPLX(A0)

	jsr		rand(PC)					; direction arbitraire
	andi	#14,D0
	move	.podXVit(PC,D0),JR_XVIT(A0)
	move	.podYVit(PC,D0),JR_YVIT(A0)

	jsr		rand(PC)					; vitesse arbitraire
	andi	#7,D0
	subi	#4,D0
	add		JR_XVIT(A0),D0
	ori		#1,D0
	move	D0,JR_XVIT(A0)

	jsr		rand(PC)
	andi	#7,D0
	subi	#4,D0
	add		JR_YVIT(A0),D0
	ori		#1,D0
	move	D0,JR_YVIT(A0)

	tst		JR_ID(A0)
	bne.s	.bye
	moveq	#112,D1
	moveq	#0,D0
	lea		SplExplode,A0
	jsr		SplOn(PC)

.bye:
	rts

.podXVit:	dc.w	24,58,-24,-58,-24,-58,24,58
.podYVit:	dc.w	58,24,58,24,-58,-24,-58,-24

**************************************************************************
*
*	Calculer position relative de deux objets
*
*	Entree
*		x1 = D0
*		y1 = D1
*		x2 = D2
*		y2 = D3
*	Sortie
*		D0 = distance absolue x
*		D1 = distance absolue y

CalcDist::

.x:	sub		D2,D0
	cmpi	#-(SPACE_W/2),D0
	bgt.s	.1
	addi	#SPACE_W,D0
	bpl.s	.y
	neg		D0
	bra.s	.y
.1:	cmpi	#(SPACE_W/2),D0
	blt.s	.absx
	subi	#SPACE_W,D0
	bpl.s	.y
	neg		D0
	bra.s	.y
.absx:
	tst		D0
	bpl.s	.y
	neg		D0

.y:	sub		D3,D1
	cmpi	#-(SPACE_H/2),D1
	bgt.s	.2
	addi	#SPACE_H,D1
	bpl.s	.bye
	neg		D1
	rts
.2:	cmpi	#(SPACE_H/2),D1
	blt.s	.absy
	subi	#SPACE_H,D1
	bpl.s	.bye
	neg		D1
	rts
.absy:
	tst		D1
	bpl.s	.bye
	neg		D1
.bye:
	rts

misXVit:	dc.w	0,3,6,7,8,7,6,3,0,-3,-6,-7,-8,-7,-6,-3
misYVit:	dc.w	-8,-7,-6,-3,0,3,6,7,8,7,6,3,0,-3,-6,-7
misType:	dc.b	80,64,48,32

**************************************************************************
*
*	Creer une floppee d'asteroide pret a etre colonise

BaseCreate::

.SAVREGS reg D3/D4/D5/A4/A5

	movem.l	#.SAVREGS,-(SP)

	lea		Bases,A5
	moveq	#(NBASE-1),D5

.ii_loop:
	moveq	#BASE_SZOF,D0
	move.l	A5,A0
	jsr		MemClear(PC)

	move	#-1,BASE_MODE(A5)

.xy_pos:
	jsr		rand(PC)			; obtenir position x de l'asteroide
	andi	#(SPACE_W-1),D0
	move	D0,BASE_XPOS(A5)

	jsr		rand(PC)			; obtenir position y de l'asteroide
	andi	#(SPACE_H-1),D0
	move	D0,BASE_YPOS(A5)

	lea		Bases,A4			; s'assurer que la distance minimum
	moveq	#(NBASE-1),D4		; entre deux asteroides est respectee
	sub		D5,D4
	bra.s	.jj_test
.jj_loop:
	movem	BASE_XPOS(A5),D0/D1
	movem	BASE_XPOS(A4),D2/D3
	bsr		CalcDist
	cmpi	#(SPACE_W/64),D0
	blt.s	.xy_pos
	cmpi	#(SPACE_H/64),D1
	blt.s	.xy_pos
	lea		BASE_SZOF(A4),A4
.jj_test:
	dbf		D4,.jj_loop

.ii_next:
	lea		BASE_SZOF(A5),A5
	dbf		D5,.ii_loop

	movem.l	(SP)+,#.SAVREGS
	rts

**************************************************************************
*
*	Dessiner les bases et missiles de base dans l'ecran cache
*
*	void C2BaseDraw( void )

C2BaseDraw::

.SAVREGS reg D3/D4/A2/A3

	movem.l	#.SAVREGS,-(SP)

	lea		Bases,A3
	moveq	#NBASE-1,D3

.loop:
	move	BASE_MODE(A3),D0
	addq	#1,D0
	add		D0,D0
	add		D0,D0
	jmp		.vects(PC,D0)
.vects:
	jmp		.nil(PC)	; non developpe
	jmp		.m0(PC)		; detruite joueur 1
	jmp		.m1(PC)		; detruite joueur 2
	jmp		.m2(PC)		; developpement joueur 1
	jmp		.m3(PC)		; developpement joueur 2
	jmp		.m4(PC)		; developpe joueur 1
	jmp		.m5(PC)		; developpe joueur 2

.nil:
	lea		AstImg,A2
	moveq	#0,D4
	bra		.brk
.m0:
	lea		BaseImg+(SPR_SZOF*4),A2
	move	BASE_COUNTER(A3),D4
	beq		.brk
	subq	#1,BASE_COUNTER(A3)
	bra		.brk
.m1:
	lea		BaseImg+(SPR_SZOF*9)+(SPR_SZOF*4),A2
	move	BASE_COUNTER(A3),D4
	beq		.brk
	subq	#1,BASE_COUNTER(A3)
	bra		.brk
.m2:
	lea		BaseImg+(SPR_SZOF*5),A2
	lea		SprIdx(PC),A0
	move	BASE_COUNTER(A3),D0
	moveq	#12,D1
	lsr		D1,D0
	add		D0,D0
	adda	0(A0,D0),A2
	moveq	#0,D4
	bra.s	.brk
.m3:
	lea		BaseImg+(SPR_SZOF*14),A2
	lea		SprIdx(PC),A0
	move	BASE_COUNTER(A3),D0
	moveq	#12,D1
	lsr		D1,D0
	add		D0,D0
	adda	0(A0,D0),A2
	moveq	#0,D4
	bra.s	.brk
.m4:
	lea		BaseImg,A2
	lea		SprIdx(PC),A0
	move	BASE_ENERGIE(A3),D1		; max = 16384
	subq	#1,D1					; max devient 16383
	rol		#5,D1
	andi	#7,D1
	subq	#7,D1
	neg		D1
	move	BASE_COUNTER(A3),D0
	lsr		D1,D0
	andi	#3,D0
	add		D0,D0
	adda	0(A0,D0),A2
	moveq	#0,D4
	bra.s	.brk
.m5:
	lea		BaseImg+(SPR_SZOF*9),A2
	lea		SprIdx(PC),A0
	move	BASE_ENERGIE(A3),D1
	subq	#1,D1
	rol		#5,D1
	andi	#7,D1
	subq	#7,D1
	neg		D1
	move	BASE_COUNTER(A3),D0
	lsr		D1,D0
	andi	#3,D0
	add		D0,D0
	adda	0(A0,D0),A2
	moveq	#0,D4

.brk:
	tst		BASE_HIT(A3)
	beq.s	.onscreen
	subq	#1,BASE_HIT(A3)

.onscreen:
	move.l	A2,A0
	movem	BASE_XPOS(A3),D0/D1
	jsr		C2SprScreen(PC)
	beq.s	.misdraw

.basedraw:
	lea		BASE_SCRADR(A3),A1
	move.l	A2,A0
	tst		BASE_HIT(A3)
	bne.s	.mask
	jsr		SpriteDraw(PC)
	bra.s	.baseexpl
.mask:
	jsr		SpriteMask(PC)

.baseexpl:
	move	D4,D0
	beq.s	.map
	lea		ExplImg,A2
	lea		SprIdx(PC),A0
	subi	#31,D0
	neg		D0
	lsr		#1,D0
	andi	#$FFFE,D0
	adda	0(A0,D0),A2
	move.l	A2,A0
	movem	BASE_XPOS(A3),D0/D1
	jsr		C2SprScreen(PC)
	beq.s	.map
	lea		BASE_MIS+MIS_SCRADR(A3),A1
	move.l	A2,A0
	jsr		SpriteDraw(PC)

.map:
	tst		BASE_MAP(A3)
	bne.s	.misdraw
	move	BASE_MODE(A3),D2
	movem	BASE_XPOS(A3),D0/D1
	jsr		BsMapDraw(PC)
	move	#1,BASE_MAP(A3)

.misdraw:
	tst		BASE_MIS+MIS_ON(A3)
	beq.s	.next
	bmi.s	.misexpl

	lea		MineImg,A2
	lea		SprIdx(PC),A0
	move	BASE_MODE(A3),D0
	andi	#1,D0
	add		D0,D0
	move	BASE_COUNTER(A3),D1
	lsr		#4,D1
	andi	#1,D1
	add		D1,D0
	add		D0,D0
	adda	0(A0,D0),A2
	move.l	A2,A0
	movem	BASE_MIS+MIS_XPOS(A3),D0/D1
	jsr		C2SprScreen(PC)
	beq.s	.next
	lea		BASE_MIS+MIS_SCRADR(A3),A1
	move.l	A2,A0
	jsr		SpriteDraw(PC)
	bra.s	.next

.misexpl:
	lea		ExplImg,A2
	lea		SprIdx(PC),A0
	move	BASE_MIS+MIS_ON(A3),D0
	addi	#15,D0
	andi	#$FFFE,D0
	adda	0(A0,D0),A2
	move.l	A2,A0
	movem	BASE_MIS+MIS_XPOS(A3),D0/D1
	jsr		C2SprScreen(PC)
	beq.s	.next
	lea		BASE_MIS+MIS_SCRADR(A3),A1
	move.l	A2,A0
	jsr		SpriteDraw(PC)

.next:
	lea		BASE_SZOF(A3),A3
	dbf		D3,.loop

	movem.l	(SP)+,#.SAVREGS
	rts

**************************************************************************
*
*	Effacer les bases de l'ecran cache
*
*	void C2BaseClear( void )

C2BaseClear::
	move.l	A3,-(SP)
	move.l	D3,-(SP)

	lea		Bases,A3
	moveq	#NBASE-1,D3

.loop:
	lea		BASE_SCRADR(A3),A0
	jsr		SpriteClear(PC)
	lea		BASE_MIS+MIS_SCRADR(A3),A0
	jsr		SpriteClear(PC)
	lea		BASE_SZOF(A3),A3
	dbf		D3,.loop

	move.l	(SP)+,D3
	move.l	(SP)+,A3
	rts

**************************************************************************

JrBsDamage:
	dc.w	64,128,192,256,320,384,448,512
JrJrDamage:
	dc.w	16,32,48,64,80,96,112,128

.end
