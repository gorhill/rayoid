**************************************************************************
*
*	Gestion du mode simple a deux joueur - collisions

.include 'H:\\STRUCT_S.IN'

**************************************************************************
*
*	Collision d'un asteroide avec un joueur (routine accessoire de
*	S2Collision).
*
*	Entree
*		A2 = Joueur
*
*	Sortie
*		D0 = indicateur de collision

_S2CollAstJr:

	tst		JR_ENERGIE(A2)
	ble.s	.nocoll
	tst		JR_HYPER(A2)
	bne.s	.nocoll
	lea		JR_SCRBOX(A2),A0
	jsr		CollAnd(PC)
	beq.s	.nocoll
	moveq	#160,D1
	moveq	#127,D0
	lea		SplJuron,A0
	jsr		SplOn(PC)
	moveq	#0,D0
	move.l	D0,JR_XVIT(A2)
	move	D0,JR_ENERGIE(A2)

.iscoll:
	moveq	#1,D0
	rts

.nocoll:
	moveq	#0,D0
	rts

**************************************************************************
*
*	Collision des missiles d'un joueur avec quelque chose (routine
*	accessoire de S2Collision).
*
*	Entree
*		A2 = Joueur
*
*	Sortie
*		D0 = nombre de collision detectee

_S2CollMis:

	clr		-(SP)				; nombre de collision detecte

	lea		JR_MIS(A2),A2

.1:	tst		(A2)				; MIS_ON(A2)
	beq.s	.2
	lea		MIS_SCRBOX(A2),A0
	lea		CollFrame(PC),A1
	cmpm	(A1)+,(A0)+
	bge.s	.2
	cmpm	(A1)+,(A0)+
	bge.s	.2
	cmpm	(A1)+,(A0)+
	ble.s	.2
	cmpm	(A1)+,(A0)+
	ble.s	.2
	jsr		_CollOr(PC)
	beq.s	.2
	clr		(A2)				; MIS_ON(A2)
	addq	#1,(SP)

.2:	lea		MIS_SZOF(A2),A2
	tst		(A2)				; MIS_ON(A2)
	beq.s	.3
	lea		MIS_SCRBOX(A2),A0
	lea		CollFrame(PC),A1
	cmpm	(A1)+,(A0)+
	bge.s	.3
	cmpm	(A1)+,(A0)+
	bge.s	.3
	cmpm	(A1)+,(A0)+
	ble.s	.3
	cmpm	(A1)+,(A0)+
	ble.s	.3
	jsr		_CollOr(PC)
	beq.s	.3
	clr		(A2)
	addq	#1,(SP)

.3:	lea		MIS_SZOF(A2),A2
	tst		(A2)				; MIS_ON(A2)
	beq.s	.4
	lea		MIS_SCRBOX(A2),A0
	lea		CollFrame(PC),A1
	cmpm	(A1)+,(A0)+
	bge.s	.4
	cmpm	(A1)+,(A0)+
	bge.s	.4
	cmpm	(A1)+,(A0)+
	ble.s	.4
	cmpm	(A1)+,(A0)+
	ble.s	.4
	jsr		_CollOr(PC)
	beq.s	.4
	clr		(A2)
	addq	#1,(SP)

.4:	lea		MIS_SZOF(A2),A2
	tst		(A2)				; MIS_ON(A2)
	beq.s	.5
	lea		MIS_SCRBOX(A2),A0
	lea		CollFrame(PC),A1
	cmpm	(A1)+,(A0)+
	bge.s	.5
	cmpm	(A1)+,(A0)+
	bge.s	.5
	cmpm	(A1)+,(A0)+
	ble.s	.5
	cmpm	(A1)+,(A0)+
	ble.s	.5
	jsr		_CollOr(PC)
	beq.s	.5
	clr		(A2)
	addq	#1,(SP)

.5:	lea		MIS_SZOF(A2),A2
	tst		(A2)				; MIS_ON(A2)
	beq.s	.6
	lea		MIS_SCRBOX(A2),A0
	lea		CollFrame(PC),A1
	cmpm	(A1)+,(A0)+
	bge.s	.6
	cmpm	(A1)+,(A0)+
	bge.s	.6
	cmpm	(A1)+,(A0)+
	ble.s	.6
	cmpm	(A1)+,(A0)+
	ble.s	.6
	jsr		_CollOr(PC)
	beq.s	.6
	clr		(A2)
	addq	#1,(SP)

.6:	lea		MIS_SZOF(A2),A2
	tst		(A2)				; MIS_ON(A2)
	beq.s	.7
	lea		MIS_SCRBOX(A2),A0
	lea		CollFrame(PC),A1
	cmpm	(A1)+,(A0)+
	bge.s	.7
	cmpm	(A1)+,(A0)+
	bge.s	.7
	cmpm	(A1)+,(A0)+
	ble.s	.7
	cmpm	(A1)+,(A0)+
	ble.s	.7
	jsr		_CollOr(PC)
	beq.s	.7
	clr		(A2)
	addq	#1,(SP)

.7:	lea		MIS_SZOF(A2),A2
	tst		(A2)				; MIS_ON(A2)
	beq.s	.8
	lea		MIS_SCRBOX(A2),A0
	lea		CollFrame(PC),A1
	cmpm	(A1)+,(A0)+
	bge.s	.8
	cmpm	(A1)+,(A0)+
	bge.s	.8
	cmpm	(A1)+,(A0)+
	ble.s	.8
	cmpm	(A1)+,(A0)+
	ble.s	.8
	jsr		_CollOr(PC)
	beq.s	.8
	clr		(A2)
	addq	#1,(SP)

.8:	lea		MIS_SZOF(A2),A2
	tst		(A2)				; MIS_ON(A2)
	beq.s	.9
	lea		MIS_SCRBOX(A2),A0
	lea		CollFrame(PC),A1
	cmpm	(A1)+,(A0)+
	bge.s	.9
	cmpm	(A1)+,(A0)+
	bge.s	.9
	cmpm	(A1)+,(A0)+
	ble.s	.9
	cmpm	(A1)+,(A0)+
	ble.s	.9
	jsr		_CollOr(PC)
	beq.s	.9
	clr		(A2)
	addq	#1,(SP)

.9:	move	(SP)+,D0
	rts

**************************************************************************
*
*	Gestion des collisions entre les differents objets
*
*	Asteroides avec joueurs
*	Asteroides avec missiles
*	Missiles avec joueurs ennemis
*	Nova avec joueurs
*
*	A5 = Asteroids
*	A4 = maitre
*	A3 = esclave
*
*	D7 = S1NAst courant
*	D5 = compteur d'asteroide

S2Collision::

SAVREGS reg D4/D5/A2/A3/A4/A5

	movem.l	#SAVREGS,-(SP)

	lea		Asteroids,A5
	lea		Joueur,A4			; A4 = maitre
	lea		JR_SZOF(A4),A3		; A3 = esclave
	tst		Maitre
	bne.s	ast_all
	exg		A4,A3

ast_all:
	move	S2NAst(PC),D5
	bra.s	ast_test

ast_loop:

	lea		AST_SCRBOX(A5),A0
	jsr		CollConf(PC)

*	asteroide avec joueurs

ast_master:
	move.l	A4,A2
	bsr		_S2CollAstJr

ast_slave:
	move.l	A3,A2
	bsr		_S2CollAstJr

*	asteroide avec missiles des joueurs

ast_mis_master:
	move.l	A4,A2
	bsr		_S2CollMis
	move	D0,D4

ast_mis_slave:
	move.l	A3,A2
	bsr		_S2CollMis
	or		D0,D4
	beq.s	ast_next

ast_mis_coll:
	moveq	#98,D1
	moveq	#0,D0
	lea		SplTic,A0
	jsr		SplOn(PC)

ast_next:
	lea		AST_SZOF(A5),A5
ast_test:
	dbf		D5,ast_loop

master_misSlave:
	tst		JR_ENERGIE(A4)
	ble.s	slave_misMaster
	tst		JR_HYPER(A4)
	bne.s	slave_misMaster

	lea		JR_SCRBOX(A4),A0
	jsr		CollConf(PC)

	move.l	A3,A2
	bsr		_S2CollMis
	beq.s	master_nova
	asl		#7,D0				; 128 unites d'energie pour chaque tir
	move	JR_MISTYPE(A3),D1	; dommage selon type de missile
	lsl		D1,D0
	sub		D0,JR_ENERGIE(A4)
	move	#2,JR_HIT(A4)

master_nova:
	tst		JR_MISTYPE(A4)
	bne		slave_misMaster
	lea		Novas,A0
	tst		(A0)
	beq.s	slave_misMaster
	lea		NOVA_SCRBOX(A0),A0
	jsr		CollOr(PC)
	beq.s	slave_misMaster
	move	#1,JR_MISTYPE(A4)
	moveq	#98,D1
	moveq	#0,D0
	lea		SplPastille,A0
	jsr		SplOn(PC)

slave_misMaster:
	tst		JR_ENERGIE(A3)
	ble.s	bye
	tst		JR_HYPER(A3)
	bne.s	bye

	lea		JR_SCRBOX(A3),A0
	jsr		CollConf(PC)

	move.l	A4,A2
	bsr		_S2CollMis
	beq.s	slave_nova
	asl		#7,D0				; 128 unites d'energie pour chaque tir
	move	JR_MISTYPE(A4),D1	; dommage selon type de missile
	lsl		D1,D0
	sub		D0,JR_ENERGIE(A3)
	move	#2,JR_HIT(A3)

slave_nova:
	tst		JR_MISTYPE(A3)
	bne		bye
	lea		Novas,A0
	tst		(A0)
	beq.s	bye
	lea		NOVA_SCRBOX(A0),A0
	jsr		CollOr(PC)
	beq.s	bye
	move	#1,JR_MISTYPE(A3)
	moveq	#98,D1
	moveq	#0,D0
	lea		SplPastille,A0
	jsr		SplOn(PC)

bye:
	movem.l	(SP)+,#SAVREGS
	rts

.end
