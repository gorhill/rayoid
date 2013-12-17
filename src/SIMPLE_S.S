
.include 'H:\\STRUCT_S.IN'

SCREEN_X = -4
SCREEN_Y = -4
SCREEN_W = 328
SCREEN_H = 200

***************************************************************************
*
*	Verifier si un sprite apparait a l'ecran et retourner rectangle
*	d'intersection dans ClipSprite. ScreenBox est utilise.
*
*	int S1SprScreen(x,y,SPRITE *);
*	int S2SprScreen(x,y,SPRITE *);

S1SprScreen::
S2SprScreen::

	sub		SPR_XHOT(A0),D0
	sub		SPR_YHOT(A0),D1
	movem	D0/D1,(A0)

	lea		ClipSprite(PC),A1

	; plus grand x1

	move	ScreenBox+GX(PC),D1
	move	D0,D2
	cmp		D1,D2
	bge.s	.10
	move	D1,D2
.10:
	move	D2,GX(A1)

	; plus petit x2

	add		SPR_BOX+GW(A0),D0
	add		ScreenBox+GW(PC),D1
	cmp		D0,D1
	bge.s	.30
	move	D1,D0
.30:
	sub		D2,D0			; largeur nulle ?
	bgt.s	.40				; non
	clr		D0
	move	D0,GW(A1)
	rts
.40:
	move	D0,GW(A1)

	; plus grand y1

	move	SPR_BOX+GY(A0),D0
	move	ScreenBox+GY(PC),D1
	move	D0,D2
	cmp		D1,D2
	bge.s	.20
	move	D1,D2
.20:
	move	D2,GY(A1)

	; plus grand y2

	add		SPR_BOX+GH(A0),D0
	add		ScreenBox+GH(PC),D1
	cmp		D0,D1
	bge.s	.50
	move	D1,D0
.50:
	sub		D2,D0
	bge.s	.60
	clr		D0
.60:
	move	D0,GH(A1)
	rts

**************************************************************************
*
*	Calculer position selon vitesse
*
*	void S2CalcPos(int xvit,int yvit,POSITION *);

S1CalcPos::
S2CalcPos::

.XPOS = 0
.YPOS = 2
.XPOSFRAC = 4
.YPOSFRAC = 6

.DECALEUR = 7
.MASQUEUR = 127

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
	andi	#.MASQUEUR,D0		; D0 = partie fractionnel de delta x frationnel
	sub		D2,(A0)
	neg		D0
	cmpi	#-4,(A0)			; debordement ?
	bge.s	.xok				; non
	addi	#328,(A0)
	bra.s	.xok

.xpos:
	move	D0,D2
	lsr		#.DECALEUR,D2		; D2 = partie entiere de delta x fractionnel
	andi	#.MASQUEUR,D0		; D0 = partie fractionnel de delta x frationnel
	add		D2,(A0)
	cmpi	#323,(A0)			; debordement ?
	ble.s	.xok				; non
	subi	#328,(A0)

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
	andi	#.MASQUEUR,D1		; D1 = partie fractionnel de delta y frationnel
	sub		D2,.YPOS(A0)
	neg		D1
	cmpi	#-4,.YPOS(A0)		; debordement ?
	bge.s	.yok				; non
	addi	#200,.YPOS(A0)
	bra.s	.yok

.ypos:
	move	D1,D2
	lsr		#.DECALEUR,D2		; D2 = partie entiere de delta y fractionnel
	andi	#.MASQUEUR,D1		; D1 = partie fractionnel de delta y frationnel
	add		D2,.YPOS(A0)
	cmpi	#195,.YPOS(A0)		; debordement ?
	ble.s	.yok				; non
	subi	#200,.YPOS(A0)

.yok:
	move	D1,.YPOSFRAC(A0)

.bye:
	rts

**************************************************************************
*
*	Obtenir la direction d'un objet relativement a un autre.
*
*	int S1GetDir( int xref, int yref, int xobj, int yobj );
*	int S2GetDir( int xref, int yref, int xobj, int yobj );
*
*	D0,D1 = xref,yref
*	D2,D3 = xobj,yobj
*
*	     0
*	  7  |  1
*	6----8----2
*	  5  |  3
*	     4

S1GetDir::
S2GetDir::

.x:	sub		D2,D0					; delta x
	cmpi	#-(SCREEN_W/2),D0
	bgt.s	.xchk
	addi	#SCREEN_W,D0
	bra.s	.y
.xchk:
	cmpi	#(SCREEN_W/2),D0
	blt.s	.y
	subi	#SCREEN_W,D0

.y:	sub		D3,D1				; delta y
	cmpi	#-(SCREEN_H/2),D1
	bgt.s	.ychk
	addi	#SCREEN_H,D1
	bra.s	.xcalc
.ychk:
	cmpi	#(SCREEN_H/2),D1
	blt.s	.xcalc
	subi	#SCREEN_H,D1

.xcalc:
	moveq	#5,D2
	tst		D0
	beq		.xzer
	bpl.s	.xpos

.xneg:
	neg		D0
	ext.l	D1
	bmi.s	.xneg_yneg

.xneg_ypos:
	lsl		D2,D1
	divu	D0,D1
	cmpi	#6,D1
	ble		.4
	cmpi	#21,D1
	ble		.3
	cmpi	#48,D1
	ble		.2
	cmpi	#161,D1
	ble.s	.1
	moveq	#0,D0
	rts

.xneg_yneg:
	neg.l	D1
	lsl		D2,D1
	divu	D0,D1
	cmpi	#6,D1
	ble.s	.4
	cmpi	#21,D1
	ble.s	.5
	cmpi	#48,D1
	ble.s	.6
	cmpi	#161,D1
	ble.s	.7
	moveq	#8,D0
	rts

.xpos:
	ext.l	D1
	bmi.s	.xpos_yneg

.xpos_ypos:
	lsl		D2,D1
	divu	D0,D1
	cmpi	#6,D1
	ble.s	.12
	cmpi	#21,D1
	ble.s	.13
	cmpi	#48,D1
	ble.s	.14
	cmpi	#161,D1
	ble.s	.15
	moveq	#0,D0
	rts

.xpos_yneg:
	neg.l	D1
	lsl		D2,D1
	divu	D0,D1
	cmpi	#6,D1
	ble.s	.12
	cmpi	#21,D1
	ble.s	.11
	cmpi	#48,D1
	ble.s	.10
	cmpi	#161,D1
	ble.s	.9
	moveq	#8,D0
	rts

.xzer:
	tst		D1
	bmi.s	.8
	beq.s	.nil

.0:	moveq	#0,D0
	rts
.1:	moveq	#1,D0
	rts
.2:	moveq	#2,D0
	rts
.3:	moveq	#3,D0
	rts
.4:	moveq	#4,D0
	rts
.5:	moveq	#5,D0
	rts
.6:	moveq	#6,D0
	rts
.7:	moveq	#7,D0
	rts
.8:	moveq	#8,D0
	rts
.9:	moveq	#9,D0
	rts
.10:
	moveq	#10,D0
	rts
.11:
	moveq	#11,D0
	rts
.12:
	moveq	#12,D0
	rts
.13:
	moveq	#13,D0
	rts
.14:
	moveq	#14,D0
	rts
.15:
	moveq	#15,D0
	rts
.nil:
	moveq	#-1,D0
	rts

**************************************************************************
*
*	Modification de la vitesse des objets dans le champ de gravite
*	d'une nova
*
*	void S2CalcVit( int xobj, int yobj, int xnov, int ynov, int *_xyvit )
*
*	D0 = xobj
*	D1 = yobj
*	D2 = xnov
*	D3 = ynov
*	A0 = _xyvit

S2CalcVit::

	jsr		S2GetDir(PC)
	bmi.s	.bye
	add		D0,D0
	move	.xacc(PC,D0),D1
	add		D1,(A0)+
	move	.yacc(PC,D0),D1
	add		D1,(A0)+
.bye:
	rts

.xacc:	dc.w	0,2,3,4,4,4,3,2,0,-2,-3,-4,-4,-4,-3,-2
.yacc:	dc.w	-4,-4,-3,-2,0,2,3,4,4,4,3,2,0,-2,-3,-4

**************************************************************************
*
*	Gestions de la nova
*
*	void S2NovaCreate( void )
*	void S2NovaMove( void )
*	void S2NovaDraw( void )
*	void S2NovaClear( void )

S2NovaCreate::

	move.l	A3,-(SP)
	move	D3,-(SP)

	lea		Novas,A3
	move	S2Mode(PC),D3

	move	D3,D0
	andi	#8,D0
	move	D0,(A3)				; NOVA_ON(A3)

	jsr		rand(PC)			; position x
	ext.l	D0
	divu	#160,D0
	swap	D0
	addi	#80,D0
	move	D0,NOVA_XPOS(A3)

	jsr		rand(PC)			; position y
	ext.l	D0
	divu	#86,D0
	swap	D0
	addi	#43,D0
	move	D0,NOVA_YPOS(A3)

	clr.l	NOVA_XPOSFRAC(A3)

	clr.l	NOVA_XVIT(A3)
	move	D3,D0
	andi	#16,D0
	beq.s	.bye

	jsr		rand(PC)			; vitesse x
	andi	#127,D0
	subi	#64,D0
	move	D0,NOVA_XVIT(A3)

	jsr		rand(PC)			; vitesse y
	andi	#127,D0
	subi	#64,D0
	move	D0,NOVA_YVIT(A3)

.bye:
	move	(SP)+,D3
	move.l	(SP)+,A3

	rts

S2NovaMove::

	lea		Novas,A1
	tst		(A1)
	beq.s	.bye
	lea		NOVA_XPOS(A1),A0
	movem	NOVA_XVIT(A1),D0/D1
	jsr		S2CalcPos(PC)

.bye:
	rts

S2NovaDraw::

.SAVREGS reg A2/A3

	movem.l	#.SAVREGS,-(SP)

	lea		Novas,A3

	tst		(A3)					; NOVA_ON(A3)
	beq.s	.bye
	addq	#1,NOVA_IMG(A3)
	move	NOVA_IMG(A3),D0
	lsr		#2,D0
	andi	#3,D0
	add		D0,D0
	add		D0,D0
	move.l	.novaimg(PC,D0),A2
	move.l	A2,A0					; calculer donnees ecran
	movem	NOVA_XPOS(A3),D0/D1
	jsr		S2SprScreen(PC)
	beq.s	.savbox
	lea		NOVA_SCRADR(A3),A1		; dessiner
	move.l	A2,A0
	jsr		SpriteDraw(PC)

.savbox:
	lea		NOVA_SCRBOX(A3),A0		; obtenir boite ecran
	move	(A2)+,D0				; [x1,y1-x2,y2[
	move	D0,(A0)+
	move	(A2)+,D1
	move	D1,(A0)+
	add		(A2)+,D0
	move	D0,(A0)+
	add		(A2)+,D1
	move	D1,(A0)+

.bye:
	movem.l	(SP)+,#.SAVREGS
	rts

.novaimg:
	dc.l	NovaImg+(SPR_SZOF*0),NovaImg+(SPR_SZOF*1)
	dc.l	NovaImg+(SPR_SZOF*2),NovaImg+(SPR_SZOF*1)

S2NovaClear::
	lea		Novas+NOVA_SCRADR,A0
	jsr		SpriteClear(PC)
	rts

**************************************************************************
*
*	Gestion des asteroides
*
*	void S2AstCreate( void )

S2AstCreate::

	move.l	A3,-(SP)
	move	D3,-(SP)

	lea		Asteroides,A3

	move	S2NAst(PC),D3
	bra.s	.test
.loop:
	move	#1,(A3)				; AST_ON(A3)

	move	#2,AST_IMG(A3)

	jsr		FastRand(PC)		; marge de 60 pixels minimum
	divu	#200,D0
	swap	D0
	addi	#60,D0
	move	D0,AST_XPOS(A3)

	jsr		FastRand(PC)
	divu	#80,D0
	swap	D0
	addi	#60,D0
	move	D0,AST_YPOS(A3)

	clr.l	AST_XPOSFRAC(A3)

	jsr		FastRand(PC)		; entre -128 et +127
	andi	#255,D0
	subi	#128,D0
	move	D0,AST_XVIT(A3)

	jsr		FastRand(PC)
	andi	#255,D0
	subi	#127,D0
	move	D0,AST_YVIT(A3)
.next:
	lea		AST_SZOF(A3),A3
.test:
	dbf		D3,.loop

	move	(SP)+,D3
	move.l	(SP)+,A3
	rts

**************************************************************************
*
*	Deplacer l'ensemble des asteroides
*
*	void S2AstMove( void )

S2AstMove::

.SAVREGS reg D3/D4/A3/A4

	movem.l	#.SAVREGS,-(SP)

	lea		Novas,A4
	lea		Asteroids,A3

	move	S2NAst(PC),D4
	bra.s	.test

.loop:

	tst		(A4)					; nova active ?
	beq.s	.move
	lea		AST_XVIT(A3),A0
	movem	NOVA_XPOS(A4),D2/D3		; position de la nova
	movem	AST_XPOS(A3),D0/D1		; position de l'asteroide
	jsr		S2CalcVit(PC)

.move:
	lea		AST_XVIT(A3),A0
	move	AST_IMG(A3),D0
	add		D0,D0
	move	.maxvit(PC,D0),D0
	jsr		TrapVit(PC)

	lea		AST_XPOS(A3),A0
	movem	AST_XVIT(A3),D0/D1
	jsr		S2CalcPos(PC)

.next:
	lea		AST_SZOF(A3),A3
.test:
	dbf		D4,.loop

	movem.l	(SP)+,#.SAVREGS
	rts

.maxvit:
	dc.w	128,184,240

**************************************************************************
*
*	Dessiner les asteroides dans l'ecran cache
*
*	void S2AstDraw( void )

S2AstDraw::

.SAVREGS reg D3/A2/A3/A4

	movem.l	#.SAVREGS,-(SP)

	lea		AstImg,A4
	lea		Asteroides,A3
	move	S2NAst(PC),D3
	bra.s	.test
.loop:
	tst		(A3)					; AST_ON(A3)
	beq.s	.next

	move.l	A4,A2
	lea		SprIdx(PC),A0
	move	AST_IMG(A3),D0
	add		D0,D0
	adda	0(A0,D0),A2				; A2 = &AstImg[_asteroid->image]

	move.l	A2,A0					; calculer donnees ecran
	movem	AST_XPOS(A3),D0/D1
	jsr		S2SprScreen(PC)
	beq.s	.savbox

	lea		AST_SCRADR(A3),A1		; dessiner
	move.l	A2,A0
	jsr		SpriteDraw(PC)

.savbox:
	lea		AST_SCRBOX(A3),A0		; obtenir boite ecran
	move	(A2)+,D0				; [x1,y1-x2,y2[
	move	D0,(A0)+
	move	(A2)+,D1
	move	D1,(A0)+
	add		(A2)+,D0
	move	D0,(A0)+
	add		(A2)+,D1
	move	D1,(A0)+

.next:
	lea		AST_SZOF(A3),A3
.test:
	dbf		D3,.loop

	movem.l	(SP)+,#.SAVREGS
	rts

**************************************************************************
*
*	Effacer les asteroides de l'ecran cache
*
*	void S2AstClear( void )

S2AstClear::
	move.l	A3,-(SP)
	move	D3,-(SP)

	lea		Asteroids,A3
	move	S2NAst(PC),D3
	bra.s	.test
.loop:
	lea		AST_SCRADR(A3),A0	;  8
	jsr		SpriteClear(PC)		; 18
	lea		AST_SZOF(A3),A3		;  8
.test:
	dbf		D3,.loop			; 10

	move	(SP)+,D3
	move.l	(SP)+,A3
	rts

**************************************************************************
*
*	Traiter joueur selon etat du joystick
*
*	void S2JrMove( int joueur )

S2JrMove::

	move.l	A3,-(SP)

	lea		Joueur,A3
	tst		D0
	beq.s	.1
	lea		JR_SZOF(A3),A3
.1:
	tst		JR_ENERGIE(A3)
	ble		.move

*	verifier si joueur active l'hyper espace

	move	JR_MOVE(A3),D2		; D2 = mouvements
	move	D2,D0
	andi	#$70,D0				; isoler action
	cmpi	#$20,D0				; hyper espace ?
	bne.s	.ctrl				; non
	tst		JR_HYPER(A3)		; hyper espace deja active ?
	bne		.bye				; oui

	move	#32,JR_HYPER(A3)
	moveq	#0,D0
	move	D0,JR_MOTOR(A3)
	move.l	D0,JR_XPOSFRAC(A3)
	move.l	D0,JR_XVIT(A3)
	move.l	D0,JR_XVITFRAC(A3)

	jsr		FastRand(PC)
	divu	#304,D0
	swap	D0
	addq	#8,D0
	move	D0,JR_XPOS(A3)

	jsr		FastRand(PC)
	divu	#176,D0
	swap	D0
	addq	#8,D0
	move	D0,JR_YPOS(A3)
	bra		.bye

.ctrl:
	andi	#7,D2
	add		D2,D2
	add		D2,D2
	jmp		.vects(PC,D2)
.vects:
	jmp		.repos(PC)
	jmp		.accel(PC)
	jmp		.frein(PC)
	jmp		.lrot(PC)
	jmp		.lrot_accel(PC)
	jmp		.rrot(PC)
	jmp		.rrot_accel(PC)
	jmp		.bye(PC)		; impossible

.repos:
	clr		JR_MOTOR(A3)
	bra		.move

.accel:
	move	#1,JR_MOTOR(A3)
	bra.s	.motor

.frein:
	moveq	#0,D0
	move	D0,JR_MOTOR(A3)
	move.l	D0,JR_XVITFRAC(A3)
	lea		JR_XVIT(A3),A0
	moveq	#1,D0
.fr_lp:
	move	(A0),D1			; _joueur->?vit *= 7 / 8;
	move	D1,D2
	add		D2,D2
	add		D2,D1
	add		D2,D2
	add		D2,D1
	bpl.s	.fr_1
	neg		D1
	lsr		#3,D1
	neg		D1
	bra.s	.fr_2
.fr_1:
	lsr		#3,D1
.fr_2:
	move	D1,(A0)+
	dbf		D0,.fr_lp
	bra		.move

.lrot:
	clr		JR_MOTOR(A3)
	move	(A3),D0
	subq	#1,D0
	andi	#63,D0
	move	D0,(A3)
	bra		.move

.lrot_accel:
	move	#1,JR_MOTOR(A3)
	move	(A3),D0
	subq	#1,D0
	andi	#63,D0
	move	D0,(A3)
	bra.s	.motor

.rrot:
	clr		JR_MOTOR(A3)
	move	(A3),D0
	addq	#1,D0
	andi	#63,D0
	move	D0,(A3)
	bra		.move

.rrot_accel:
	move	#1,JR_MOTOR(A3)
	move	(A3),D0
	addq	#1,D0
	andi	#63,D0
	move	D0,(A3)

.motor:
	move	(A3),D2
	lsr		#2,D2
	add		D2,D2

.xvit:
	move	JR_XVITFRAC(A3),D0
	lea		ShipXVit(PC),A0
	add		0(A0,D2),D0
	bmi.s	.xfracneg
.xfracpos:
	move	D0,D1
	andi	#63,D1
	move	D1,JR_XVITFRAC(A3)
	lsr		#6,D0
	add		D0,JR_XVIT(A3)
	bra.s	.xvitok
.xfracneg:
	neg		D0
	move	D0,D1
	andi	#63,D1
	neg		D1
	move	D1,JR_XVITFRAC(A3)
	lsr		#6,D0
	sub		D0,JR_XVIT(A3)
.xvitok:

.yvit:
	move	JR_YVITFRAC(A3),D0
	lea		ShipYVit(PC),A0
	add		0(A0,D2),D0
	bmi.s	.yfracneg
.yfracpos:
	move	D0,D1
	andi	#63,D1
	move	D1,JR_YVITFRAC(A3)
	lsr		#6,D0
	add		D0,JR_YVIT(A3)
	bra.s	.yvitok
.yfracneg:
	neg		D0
	move	D0,D1
	andi	#63,D1
	neg		D1
	move	D1,JR_YVITFRAC(A3)
	lsr		#6,D0
	sub		D0,JR_YVIT(A3)
.yvitok:

.move:
	lea		JR_XVIT(A3),A0
	move	#511,D0
	jsr		TrapVit(PC)

	lea		JR_XPOS(A3),A0
	movem	JR_XVIT(A3),D0/D1
	jsr		S2CalcPos(PC)

.bye:
	move.l	(SP)+,A3
	rts

**************************************************************************
*
*	Mode Simple - Dessiner un joueur dans ecran cache
*
*	void S2JrDraw( int joueur )

S2JrDraw::

.SAVREGS reg D3/A2/A3

	movem.l	#.SAVREGS,-(SP)

	lea		Joueur,A3
	tst		D0					; joueur # 1 ?
	beq.s	.1					; non
	lea		JR_SZOF(A3),A3
.1:
	tst		JR_ENERGIE(A3)
	ble		.expl

	move	JR_HYPER(A3),D0
	beq.s	.draw
	subq	#1,D0
	move	D0,JR_HYPER(A3)
	bne		.bye

.draw:
	lea		SprIdx(PC),A0
	move	(A3),D0
	lsr		#2,D0
	add		D0,D0
	move	0(A0,D0),D3

	lea		JR_SHIPIMG(A3),A2
	adda	D3,A2					; A2 = &_joueur->vaisseau[index]

	move.l	A2,A0
	movem	JR_XPOS(A3),D0/D1
	jsr		S2SprScreen(PC)
	beq.s	.savbox

	move	JR_HIT(A3),D0
	beq.s	.nohit

	subq	#1,D0
	move	D0,JR_HIT(A3)
	lea		JR_SAVSHIP(A3),A1
	move.l	A2,A0
	jsr		SpriteMask(PC)
	bra.s	.savbox

.nohit:
	lea		JR_SAVSHIP(A3),A1
	move.l	A2,A0
	jsr		SpriteDraw(PC)

.savbox:
	lea		JR_SCRBOX(A3),A0
	move	(A2)+,D0				; [x1,y1-x2,y2[
	move	D0,(A0)+
	move	(A2)+,D1
	move	D1,(A0)+
	add		(A2)+,D0
	move	D0,(A0)+
	add		(A2)+,D1
	move	D1,(A0)+

.motor:
	tst		JR_MOTOR(A3)
	beq.s	.bye
	lea		MotorImg,A2
	adda	D3,A2					; A2 = &MotorImg[index]

	move.l	A2,A0
	movem	JR_XPOS(A3),D0/D1
	jsr		S2SprScreen(PC)
	beq.s	.bye
	lea		JR_SAVFIRE(A3),A1
	move.l	A2,A0
	jsr		SpriteDraw(PC)
	bra.s	.bye

.expl:
	move	JR_DOMMAGE(A3),D0
	ble.s	.bye
	subq	#1,JR_DOMMAGE(A3)
	lea		SprIdx(PC),A0
	lsr		#2,D0
	subq	#7,D0
	neg		D0
	add		D0,D0
	move	0(A0,D0),D3

	lea		ExplImg,A2
	adda	D3,A2					; A2 = &ExplImg[index]

	move.l	A2,A0
	movem	JR_XPOS(A3),D0/D1
	jsr		S2SprScreen(PC)
	beq.s	.bye
	lea		JR_SAVSHIP(A3),A1
	move.l	A2,A0
	jsr		SpriteDraw(PC)

.bye:
	movem.l	(SP)+,#.SAVREGS
	rts

**************************************************************************
*
*	Mode Simple - Traiter les missiles d'un joueur
*
*	void S2MisMove( int joueur );

S2MisMove::

.SAVREGS reg D3/D4/A2/A3

	movem.l	#.SAVREGS,-(SP)

	lea		Joueur,A2
	tst		D0
	beq.s	.do_it
	lea		JR_SZOF(A2),A2

.do_it:
	moveq	#0,D4				; tir non-permis par defaut
	btst	#3,JR_MOVE+1(A2)
	beq.s	.1
	btst	#3,JR_OLDMOVE+1(A2)
	bne.s	.1
	tst		JR_ENERGIE(A2)
	ble.s	.1
	tst		JR_HYPER(A2)
	bne.s	.1
	moveq	#1,D4

.1:	lea		JR_MIS(A2),A3
	moveq	#7,D3

.loop:
	move	(A3),D0					; MIS_ON(A3)
	bne.s	.move

	tst		D4						; creer un missile ?
	beq		.next					; non

.make:
	move	#63,(A3)				; MIS_ON(A3)
	move	JR_MISTYPE(A2),MIS_TYPE(A3)

	moveq	#98,D1
	moveq	#0,D0
	lea		SplFire1,A0
	jsr		SplOn(PC)

	move	(A2),D0
	lsr		#2,D0
	add		D0,D0

	lea		MisXPos(PC),A0
	move	0(A0,D0),D1
	add		JR_XPOS(A2),D1
	move	D1,MIS_XPOS(A3)

	lea		MisYPos(PC),A0
	move	0(A0,D0),D1
	add		JR_YPOS(A2),D1
	move	D1,MIS_YPOS(A3)

	lea		MisXVit(PC),A0
	move	0(A0,D0),D1
	add		D1,D1
	add		D1,D1
	add		JR_XVIT(A2),D1
	move	D1,MIS_XVIT(A3)

	lea		MisYVit(PC),A0
	move	0(A0,D0),D1
	add		D1,D1
	add		D1,D1
	add		JR_YVIT(A2),D1
	move	D1,MIS_YVIT(A3)

	clr.l	MIS_XPOSFRAC(A3)
	moveq	#0,D4
	bra.s	.next

.move:
	subq	#1,D0
	move	D0,(A3)					; MIS_ON(A3)
	beq.s	.next
	lea		MIS_XPOS(A3),A0
	movem	MIS_XVIT(A3),D0/D1
	jsr		S2CalcPos(PC)

.next:
	lea		MIS_SZOF(A3),A3
	dbf		D3,.loop

	movem.l	(SP)+,#.SAVREGS
	rts

**************************************************************************
*
*	Dessiner les missiles d'un joueur
*
*	void S2MisDraw( int joueur );

S2MisDraw::

.SAVREGS reg D3/A2/A3

	movem.l	#.SAVREGS,-(SP)

	lea		Joueur,A3
	tst		D0
	beq.s	.do_it
	lea		JR_SZOF(A3),A3

.do_it:

	lea		JR_MIS(A3),A3
	moveq	#7,D3

.loop:
	move	(A3),D0				; MIS_ON(A3)
	beq.s	.next

	lsr		#2,D0
	andi	#$FFFC,D0
	move	MIS_TYPE(A3),D1
	lsl		#4,D1
	add		D1,D0
	move.l	.misimg(PC,D0),A2

	move.l	A2,A0
	movem	MIS_XPOS(A3),D0/D1
	jsr		S2SprScreen(PC)
	beq.s	.savbox

	lea		MIS_SCRADR(A3),A1
	move.l	A2,A0
	jsr		SpriteDraw(PC)

.savbox:
	lea		MIS_SCRBOX(A3),A0
	move	(A2)+,D0				; [x1,y1-x2,y2[
	move	D0,(A0)+
	move	(A2)+,D1
	move	D1,(A0)+
	add		(A2)+,D0
	move	D0,(A0)+
	add		(A2)+,D1
	move	D1,(A0)+

.next:
	lea		MIS_SZOF(A3),A3
	dbf		D3,.loop

	movem.l	(SP)+,#.SAVREGS
	rts

.misimg:
	dc.l	MisImg+(SPR_SZOF*0),MisImg+(SPR_SZOF*1)
	dc.l	MisImg+(SPR_SZOF*2),MisImg+(SPR_SZOF*3)
	dc.l	BigMisImg+(SPR_SZOF*0),BigMisImg+(SPR_SZOF*1)
	dc.l	BigMisImg+(SPR_SZOF*2),BigMisImg+(SPR_SZOF*3)

**************************************************************************
*
*	Effacer les missiles des deux joueurs de l'ecran
*
*	void S2MisClear( MISSILE *_missiles )

S2MisClear::

	move.l	A3,-(SP)

	lea		Joueur+JR_MIS+MIS_SCRADR,A3
	.rept	7
	move.l	A3,A0				; 8 missiles du joueur # 1
	jsr		SpriteClear(PC)
	lea		MIS_SZOF(A3),A3
	.endr
	move.l	A3,A0
	jsr		SpriteClear(PC)

	lea		Joueur+JR_SZOF+JR_MIS+MIS_SCRADR,A3
	.rept	7
	move.l	A3,A0				; 8 missiles du joueur # 2
	jsr		SpriteClear(PC)
	lea		MIS_SZOF(A3),A3
	.endr
	move.l	A3,A0
	jsr		SpriteClear(PC)

	move.l	(SP)+,A3
	rts

**************************************************************************
*
*	Obtenir mouvement via clavier
*
*	xAAAFMMM
*
*	M = mouvement
*	F = fire
*	A = action
*
*	mouvement
*		0 - repos
*		1 - moteur
*		2 - frein
*		3 - gauche
*		4 - gauche + moteur
*		5 - droit
*		6 - droit + moteur
*	action
*		0 - repos
*		1 - x
*		2 - hyper-espace
*
*	unsigned char move = 0x80;
*
*	/* shift droit = fire */
*	if ( KeyStat.keystat[KEY_FIRE] )
*		move |= 8;
*	/* hyper espace */
*	if ( KeyStat.keystat[KEY_HYPER] )
*		move |= (2 << 4);
*	/* . = frein */
*	if ( KeyStat.keystat[KEY_BRAKE] )
*		move |= 2;
*	else {
*		/* X = rotation droite */
*		if ( KeyStat.keystat[KEY_RROT] )
*			move |= 5;
*		else {
*			/* Z = rotation gauche */
*			if ( KeyStat.keystat[KEY_LROT] )
*				move |= 3;
*			}
*		/* / = reacteur */
*		if ( KeyStat.keystat[KEY_MOTOR] )
*			move += 1;
*		}
*	return ( move );

S2TMv1::
	lea		S2TKey1Cfg,A1
	bra.s	S2Mv

S2TMv2::
	lea		S2TKey2Cfg,A1
	bra.s	S2Mv

S2MMv1::
	lea		S2MKey1Cfg,A1

S2Mv:
	lea		KeyStat(PC),A0
	move	#%10000000,D0
	moveq	#0,D1

*	fire
	move.b	KEY_FIRE(A1),D1
	tst.b	KBD_KEYSTAT(A0,D1)
	beq.s	.hyper
	or		#%00001000,D0

*	hyper espace
.hyper:
	move.b	KEY_HYPER(A1),D1
	tst.b	KBD_KEYSTAT(A0,D1)
	beq.s	.frein
	or		#%00100000,D0

*	frein
.frein:
	move.b	KEY_BRAKE(A1),D1
	tst.b	KBD_KEYSTAT(A0,D1)
	beq.s	.rrot
	or		#%00000010,D0
	rts

*	rotation droite
.rrot:
	move.b	KEY_RROT(A1),D1
	tst.b	KBD_KEYSTAT(A0,D1)
	beq.s	.lrot
	or		#%00000101,D0
	bra.s	.motor

*	rotation gauche
.lrot:
	move.b	KEY_LROT(A1),D1
	tst.b	KBD_KEYSTAT(A0,D1)
	beq.s	.motor
	or		#%00000011,D0

*	reacteur
.motor:
	move.b	KEY_MOTOR(A1),D1
	tst.b	KBD_KEYSTAT(A0,D1)
	beq.s	.bye
	addq	#1,D0
.bye:
	rts

**************************************************************************
*
*	Dessiner niveau d'energie d'un joueur
*
*	void S2EnerDraw( int joueur, int energie );
*
*	Concu pour un niveau d'energie de 8192 maximum
*
*	index = (energie + 128) / 256

S2EnerDraw::
	lea		_Screens(PC),A1
	adda	Hide4Screen(PC),A1
	move.l	(A1),A1

	add		D0,D0
	add		D0,D0
	jmp		.vects(PC,D0)
.vects:
	jmp		.jr1(PC)
	jmp		.jr2(PC)


	; joueur 1
.jr1:
	addi	#128,D1
	bpl.s	.1
	moveq	#0,D1
.1:	lsr		#6,D1
	andi	#$FFFC,D1
	move	.imgs1+0(PC,D1),D0	; D0 = masque lo
	move	.imgs1+2(PC,D1),D1	; D1 = masque hi
	move	D0,D2
	swap	D0
	move	D2,D0
	move	D1,D2
	swap	D1
	move	D2,D1
	lea		30720(A1),A1			; A1 = adresse ecran
	bra		.doit
	rts

.imgs1:
	dc.l	$00000000,$80000000,$C0000000,$E0000000
	dc.l	$F0000000,$F8000000,$FC000000,$FE000000
	dc.l	$FF000000,$FF800000,$FFC00000,$FFE00000
	dc.l	$FFF00000,$FFF80000,$FFFC0000,$FFFE0000
	dc.l	$FFFF0000,$FFFF8000,$FFFFC000,$FFFFE000
	dc.l	$FFFFF000,$FFFFF800,$FFFFFC00,$FFFFFE00
	dc.l	$FFFFFF00,$FFFFFF80,$FFFFFFC0,$FFFFFFE0
	dc.l	$FFFFFFF0,$FFFFFFF8,$FFFFFFFC,$FFFFFFFE
	dc.l	$FFFFFFFF

	; joueur 2
.jr2:
	addi	#128,D1
	bpl.s	.2
	moveq	#0,D1
.2:	lsr		#6,D1
	andi	#$FFFC,D1
	move	.imgs2+0(PC,D1),D0	; D0 = masque lo
	move	.imgs2+2(PC,D1),D1	; D1 = masque hi
	move	D0,D2
	swap	D0
	move	D2,D0
	move	D1,D2
	swap	D1
	move	D2,D1
	lea		30864(A1),A1			; A1 = adresse ecran
	bra		.doit

.imgs2:
	dc.l	$00000000,$00000001,$00000003,$00000007
	dc.l	$0000000F,$0000001F,$0000003F,$0000007F
	dc.l	$000000FF,$000001FF,$000003FF,$000007FF
	dc.l	$00000FFF,$00001FFF,$00003FFF,$00007FFF
	dc.l	$0000FFFF,$0001FFFF,$0003FFFF,$0007FFFF
	dc.l	$000FFFFF,$001FFFFF,$003FFFFF,$007FFFFF
	dc.l	$00FFFFFF,$01FFFFFF,$03FFFFFF,$07FFFFFF
	dc.l	$0FFFFFFF,$1FFFFFFF,$3FFFFFFF,$7FFFFFFF
	dc.l	$FFFFFFFF

.doit:
	.rept	7
	and.l	D0,(A1)+		; 20
	and.l	D0,(A1)+		; 20
	and.l	D1,(A1)+		; 20
	and.l	D1,(A1)+		; 20
	lea		144(A1),A1		;  8
	.endr
	rts

**************************************************************************

*	bit 0-2 = nombre d'astero‹de
*	bit 3 = nova 1
*	bit 4 = nova 1 bouge
*	bit 5 = nova 2
*	bit 6 = nova 2 bouge

S2Mode::
	dc.w	0

S2NAst::
	dc.w	0

.end
