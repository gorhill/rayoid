
.include 'H:\\STRUCT_S.IN'

**************************************************************************
*
*	Obtenir la direction d'un objet relativement a un autre.
*
*	int C2GetDir( int xref, int yref, int xobj, int yobj );
*
*	     0
*	  7  |  1
*	6----_----2
*	  5  |  3
*	     4

C2GetDir::

.x:	sub		D2,D0				; delta x
	cmpi	#-(SPACE_W/2),D0
	bgt.s	.xchk
	addi	#SPACE_W,D0
	bra.s	.y
.xchk:
	cmpi	#(SPACE_W/2),D0
	blt.s	.y
	subi	#SPACE_W,D0

.y:	sub		D3,D1				; delta y
	cmpi	#-(SPACE_H/2),D1
	bgt.s	.ychk
	addi	#SPACE_H,D1
	bra.s	.xcalc
.ychk:
	cmpi	#(SPACE_H/2),D1
	blt.s	.xcalc
	subi	#SPACE_H,D1

.xcalc:
	moveq	#4,D2
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
	cmpi	#3,D1
	ble		.4
	cmpi	#11,D1
	ble		.3
	cmpi	#24,D1
	ble		.2
	cmpi	#80,D1
	ble.s	.1
	moveq	#0,D0
	rts

.xneg_yneg:
	neg.l	D1
	lsl		D2,D1
	divu	D0,D1
	cmpi	#3,D1
	ble.s	.4
	cmpi	#11,D1
	ble.s	.5
	cmpi	#24,D1
	ble.s	.6
	cmpi	#80,D1
	ble.s	.7
	moveq	#8,D0
	rts

.xpos:
	ext.l	D1
	bmi.s	.xpos_yneg

.xpos_ypos:
	lsl		D2,D1
	divu	D0,D1
	cmpi	#3,D1
	ble.s	.12
	cmpi	#11,D1
	ble.s	.13
	cmpi	#24,D1
	ble.s	.14
	cmpi	#80,D1
	ble.s	.15
	moveq	#0,D0
	rts

.xpos_yneg:
	neg.l	D1
	lsl		D2,D1
	divu	D0,D1
	cmpi	#3,D1
	ble.s	.12
	cmpi	#11,D1
	ble.s	.11
	cmpi	#24,D1
	ble.s	.10
	cmpi	#80,D1
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
*	Mise a jour du radar d'ennemi du joueur 1
*
*	void JrRadrDraw( void )

JrRadrDraw::

	move.l	D3,-(SP)

	lea		Joueur,A0

	tst		JR_SZOF+JR_ENERGIE(A0)	; navette de survie ?
	ble.s	.out
	tst		JR_SZOF+JR_INVIS(A0)	; joueur invisible ?
	bne.s	.out

	movem	JR_XPOS+(JR_SZOF*0)(A0),D0/D1
	movem	JR_XPOS+(JR_SZOF*1)(A0),D2/D3
	jsr		CalcDist(PC)

	cmpi	#512,D0
	bgt.s	.out
	cmpi	#512,D1
	ble.s	.in

.out:
	moveq	#-1,D0
	bra.s	.check

.in:
	movem	Joueur+JR_XPOS,D0/D1
	movem	Joueur+JR_SZOF+JR_XPOS,D2/D3
	jsr		C2GetDir(PC)

.check:
	move.l	(SP)+,D3

	andi	#$FFFE,D0
	cmp		.radarStat(PC),D0	; mise a jour necessaire ?
	bne.s	.draw				; non

	rts

.radarStat:	dc.w	-1
			dc.w	7104
.radarImgs:	dc.w	7040,7048,7056,7064,7072,7080,7088,7096

.draw:
	move	D0,.radarStat

	move.l	A2,-(SP)

	move.l	_SavLogScreen,A0
	adda	.radarImgs(PC,D0),A0	; A0 = image source
	movem.l	_Screens(PC),A1/A2		; A1/A2 = ecran destination
	lea		8624(A1),A1
	lea		8624(A2),A2

	.rept	15
	move.l	(A0)+,D0
	move.l	(A0)+,D1
	movem.l	D0/D1,(A1)
	movem.l	D0/D1,(A2)
	lea		152(A0),A0
	lea		160(A1),A1
	lea		160(A2),A2
	.endr

	move.l	(SP)+,A2
	rts

**************************************************************************
*
*	Mise a jour du radar de base du joueur 1
*
*	void BsRadrDraw( void )

BsRadrDraw::

	lea		Joueur,A0

	move.l	D3,-(SP)

	movem	JR_XPOS(A0),D0/D1
	movem	JR_RADRXPOS(A0),D2/D3
	jsr		C2GetDir(PC)

	move.l	(SP)+,D3

	andi	#$FFFE,D0
	cmp		.radarStat(PC),D0	; mise a jour necessaire ?
	bne.s	.draw				; non
	rts

.radarStat:	dc.w	-1
			dc.w	7176
.radarImgs:	dc.w	7112,7120,7128,7136,7144,7152,7160,7168

.draw:
	move	D0,.radarStat

	move.l	A2,-(SP)

	move.l	_SavLogScreen,A0
	adda	.radarImgs(PC,D0),A0	; A0 = image source
	movem.l	_Screens(PC),A1/A2		; A1/A2 = ecran destination
	lea		12304(A1),A1
	lea		12304(A2),A2

	.rept	15
	move.l	(A0)+,D0
	move.l	(A0)+,D1
	movem.l	D0/D1,(A1)
	movem.l	D0/D1,(A2)
	lea		152(A0),A0
	lea		160(A1),A1
	lea		160(A2),A2
	.endr

	move.l	(SP)+,A2
	rts

**************************************************************************
*
*	Dessiner niveau d'energie du joueur 1
*
*	void C2EnerDraw( void );
*
*	Concu pour un niveau d'energie de 8192 maximum

EnerStat:	dc.w	-1
EnerImgs:	dc.w	$0000,$8000,$C000,$E000,$F000,$F800,$FC00,$FE00
			dc.w	$FF00,$FF80,$FFC0,$FFE0,$FFF0,$FFF8,$FFFC,$FFFE
			dc.w	$FFFF

C2EnerDraw::
	move	Joueur+JR_ENERGIE,D0
	bpl.s	.1					; oui
	clr		D0
.1:	addi	#511,D0
	lsr		#8,D0
	andi	#$FFFE,D0
	cmp		EnerStat(PC),D0		; mise a jour necessaire ?
	bne.s	.draw				; non
	rts

.draw:
	move	D0,EnerStat
	move	EnerImgs(PC,D0),D2	; D2 = image source

	movem.l	_Screens(PC),A0/A1	; A0/A1 = ecrans destination
	lea		1586(A0),A0
	lea		1586(A1),A1

	add		D0,D0				; couleur selon niveau
	jmp		.color(PC,D0)
.color:
	jmp		.red(PC)
	jmp		.red(PC)
	jmp		.red(PC)
	jmp		.red(PC)
	jmp		.red(PC)
	jmp		.yellow(PC)
	jmp		.yellow(PC)
	jmp		.yellow(PC)
	jmp		.yellow(PC)
	jmp		.green(PC)
	jmp		.green(PC)
	jmp		.green(PC)
	jmp		.green(PC)
	jmp		.green(PC)
	jmp		.green(PC)
	jmp		.green(PC)
	jmp		.green(PC)

.green:
	moveq	#0,D1
	.rept	5
	move	D2,(A0)+
	move.l	D1,(A0)+
	move	D2,(A1)+
	move.l	D1,(A1)+
	lea		154(A0),A0
	lea		154(A1),A1
	.endr
	rts

.yellow:
	moveq	#0,D1
	move	D2,D1
	.rept	5
	move	D2,(A0)+
	move.l	D1,(A0)+
	move	D2,(A1)+
	move.l	D1,(A1)+
	lea		154(A0),A0
	lea		154(A1),A1
	.endr
	rts

.red:
	moveq	#0,D1
	move	D2,D0
	swap	D2
	move	D0,D2
	.rept	5
	move	D1,(A0)+
	move.l	D2,(A0)+
	move	D1,(A1)+
	move.l	D2,(A1)+
	lea		154(A0),A0
	lea		154(A1),A1
	.endr
	rts

**************************************************************************
*
*	Dessiner base sur map (coordonnees = 288,98)
*
*	void BsMapDraw( int xpos, int ypos, int type )
*
*	-1 = asteroide
*	 0 = base detruite joueur 1
*	 1 = base detruite joueur 2
*	 2 = base en developpement joueur 1
*	 3 = base en developpement joueur 2
*	 4 = base developpee joueur 1
*	 5 = base developpee joueur 2

BsMapDraw::

	lea		MapImg(PC),A0
	lsr		#6,D0
	andi	#$FFFC,D0
	move.l	0(A0,D0),D0				; pixel a allumer

	lea		YIdx(PC),A0
	lsr		#7,D1
	andi	#$FFFE,D1
	move	0(A0,D1),D1				; ligne a mettre a jour

	movem.l	_Screens(PC),A0/A1		; adresses ecran
	lea		15984(A0),A0
	lea		15984(A1),A1
	adda	D1,A0
	adda	D1,A1

	move.l	D0,D1
	not.l	D1

	addq	#1,D2
	add		D2,D2
	add		D2,D2
	jmp		.vects(PC,D2)
.vects:
	jmp		.nil(PC)	; non developpe - rouge fonce (10)
	jmp		.0(PC)		; detruite joueur 1 - vert fonce (14)
	jmp		.1(PC)		; detruite joueur 2 - bleu fonce (8)
	jmp		.2(PC)		; developpement joueur 1 - vert moyen (3)
	jmp		.3(PC)		; developpement joueur 2 - bleu moyen (7)
	jmp		.4(PC)		; developpe joueur 1 - vert clair (4)
	jmp		.5(PC)		; developpe joueur 2 - bleu clair (6)
.nil:
	and		D1,(A0)+
	or		D0,(A0)+
	and		D1,(A0)+
	or		D0,(A0)+
	and		D1,(A1)+
	or		D0,(A1)+
	and		D1,(A1)+
	or		D0,(A1)+
	rts
.0:	and		D1,(A0)+
	or		D0,(A0)+
	or.l	D0,(A0)+
	and		D1,(A1)+
	or		D0,(A1)+
	or.l	D0,(A1)+
	rts
.1:	and.l	D1,(A0)+
	and		D1,(A0)+
	or		D0,(A0)+
	and.l	D1,(A1)+
	and		D1,(A1)+
	or		D0,(A1)+
	rts
.2:	or.l	D0,(A0)+
	and.l	D1,(A0)+
	or.l	D0,(A1)+
	and.l	D1,(A1)+
	rts
.3:	or.l	D0,(A0)+
	or		D0,(A0)+
	and		D1,(A0)+
	or.l	D0,(A1)+
	or		D0,(A1)+
	and		D1,(A1)+
	rts
.4:	and.l	D1,(A0)+
	or		D0,(A0)+
	and		D1,(A0)+
	and.l	D1,(A1)+
	or		D0,(A1)+
	and		D1,(A1)+
	rts
.5:	and		D1,(A0)+
	or		D0,(A0)+
	or		D0,(A0)+
	and		D1,(A0)+
	and		D1,(A1)+
	or		D0,(A1)+
	or		D0,(A1)+
	and		D1,(A1)+
	rts

**************************************************************************
*
*	Dessiner joueur sur map (coordonnees = 288,99)
*
*	void JrMapDraw( void )

JrMapDraw::
	rol		.counter
	bcc.s	.bye

	movem.l	_Screens(PC),A0/A1		; restaurer map sur ecran 1
	lea		15984(A0),A0
	lea		15984(A1),A1
	adda	.oldyidx(PC),A0
	adda	.oldyidx(PC),A1
	move.l	(A1)+,(A0)+
	move.l	(A1)+,(A0)+

	eori	#1,.state
	beq.s	.bye

	movem	Joueur+JR_XPOS,D0/D1

	lsr		#6,D0
	andi	#$FFFC,D0
	move.l	MapImg(PC,D0),D0		; pixel a allumer

	lea		YIdx(PC),A0
	lsr		#7,D1
	andi	#$FFFE,D1
	move	0(A0,D1),D1				; ligne a mettre a jour
	move	D1,.oldyidx

	move.l	_Screens(PC),A0			; adresse ecran
	lea		15984(A0),A0
	adda	D1,A0
	or.l	D0,(A0)+
	or.l	D0,(A0)+
.bye:
	rts

.oldyidx:	dc.w	0
.counter:	dc.w	$8080
.state:		dc.w	0

MapImg:
	dc.l	$80008000,$40004000,$20002000,$10001000
	dc.l	$08000800,$04000400,$02000200,$01000100
	dc.l	$00800080,$00400040,$00200020,$00100010
	dc.l	$00080008,$00040004,$00020002,$00010001

**************************************************************************
*
*	Dessiner jauge de chargement cryogenique
*
*	void C2CryoDraw( int energie );
*
*	Concu pour un niveau d'energie de 16384 maximum
*	Chaque pixel vaut 1024 unites d'energie cryogenique

CryoStat:	dc.w	0
CryoImgs:	dc.w	9688,9696,9704,9712,9720,9728,9736,9744,9752

C2CryoDraw::
	move	Joueur+JR_CRYOGEN,D0
	cmp		CryoStat(PC),D0		; mise a jour necessaire ?
	bne.s	.draw				; non
	rts

.draw:
	move.l	A2,-(SP)

	move	D0,CryoStat

	move.l	_SavLogScreen,A0
	add		D0,D0
	adda	CryoImgs(PC,D0),A0

	movem.l	_Screens(PC),A1/A2	; A1/A2 = ecrans destination
	lea		26224(A1),A1
	lea		26224(A2),A2

	.rept	13
	move.l	(A0)+,D0
	move.l	(A0)+,D1
	movem.l	D0/D1,(A1)
	movem.l	D0/D1,(A2)
	lea		152(A0),A0
	lea		160(A1),A1
	lea		160(A2),A2
	.endr

	move.l	(SP)+,A2
	rts

**************************************************************************
*
*	Dessiner temoin d'invisibilite
*
*	void InvisDraw( void );

InvisStat:	dc.w	-1

InvisDraw::
	move	Joueur+JR_INVIS,D0
	cmp		InvisStat(PC),D0
	bne.s	.draw
	rts

.draw:
	move.l	A2,-(SP)

	move	D0,InvisStat

	move.l	_SavLogScreen,A0
	lea		8624(A0),A0
	lsl		#3,D0
	adda	D0,A0				; A0 = image source

	movem.l	_Screens(PC),A1/A2
	lea		19664(A1),A1
	lea		19664(A2),A2		; A1/A2 = ecrans destination

	.rept	6
	move.l	(A0)+,D0	; 12
	move.l	(A0)+,D1	; 12
	movem.l	D0/D1,(A1)	; 24
	movem.l	D0/D1,(A2)	; 24
	lea		152(A0),A0	;  8
	lea		160(A1),A1	;  8
	lea		160(A2),A2	;  8
	.endr
	move.l	(A0)+,D0	; 12
	move.l	(A0)+,D1	; 12
	movem.l	D0/D1,(A1)	; 24
	movem.l	D0/D1,(A2)	; 24

	move.l	(SP)+,A2
	rts

**************************************************************************
*
*	Dessiner temoin de mine furtive
*
*	void PiegeDraw( void );

PiegeStat:	dc.w	-1

PiegeDraw::
	move	Joueur+JR_MINE,D0
	cmp		PiegeStat(PC),D0
	bne.s	.draw
	rts

.draw:
	move.l	A2,-(SP)

	move	D0,PiegeStat

	move.l	_SavLogScreen,A0
	lea		7504(A0),A0
	lsl		#3,D0
	adda	D0,A0				; A0 = image source

	movem.l	_Screens(PC),A1/A2
	lea		21744(A1),A1
	lea		21744(A2),A2		; A1/A2 = ecrans destination

	.rept	6
	move.l	(A0)+,D0	; 12
	move.l	(A0)+,D1	; 12
	movem.l	D0/D1,(A1)	; 24
	movem.l	D0/D1,(A2)	; 24
	lea		152(A0),A0	;  8
	lea		160(A1),A1	;  8
	lea		160(A2),A2	;  8
	.endr
	move.l	(A0)+,D0	; 12
	move.l	(A0)+,D1	; 12
	movem.l	D0/D1,(A1)	; 24
	movem.l	D0/D1,(A2)	; 24

	move.l	(SP)+,A2
	rts

.end
