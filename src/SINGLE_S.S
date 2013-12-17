**************************************************************************
*
*	Gestion du mode de jeu a un joueur

.include 'h:\\struct_s.in'

**************************************************************************
*
*	Interruption VBL cycle couleur pour hi score

S1VBL1::
	move	.count(PC),D0
	addq	#1,D0
	cmpi	#168,D0
	blt.s	.1
	moveq	#0,D0
.1:	move	D0,.count
	lsr		#2,D0
	add		D0,D0
	move	.colors(PC,D0),$FFFF8250
	clr		$FFFF8240
	rts

.count:
	dc.w	0
.colors:
	dc.w	$700,$710,$720,$730,$740,$750,$760
	dc.w	$770,$670,$570,$470,$370,$270,$170
	dc.w	$070,$071,$072,$073,$074,$075,$076
	dc.w	$077,$067,$057,$047,$037,$027,$017
	dc.w	$007,$107,$207,$307,$407,$507,$607
	dc.w	$707,$706,$705,$704,$703,$702,$701

*	Flasher l'ecran pour indiquer destruction globale

S1VBL2::
	move	#$FFF,$FFFF8240
	move.l	#S1VBL1,AuxVBL+2
	rts

**************************************************************************
*
*	Creer une floppee d'asteroide selon niveau
*
*	void S1AstCreate( void )
*
*	if ( S1Level >= 4 )
*		S1NAst = S1NCible = 8;
*	else
*		S1NAst = S1NCible = S1Level + 4;
*	S1Level++;
*
*	for ( ii = 0; ii < S1NAst; ii++, _asteroid++ ) {
*
*		_asteroid->xpos = rand() % 320;
*		_asteroid->ypos = rand() % 192;
*		side = rand() & 3;
*		switch ( side ) {
*			/* haut */
*			case 0:
*				_asteroid->ypos = 0;
*				break;
*			/* droit */
*			case 1:
*				_asteroid->xpos = 319;
*				break;
*			/* bas */
*			case 2:
*				_asteroid->ypos = 191;
*				break;
*			/* gauche */
*			case 3:
*				_asteroid->xpos = 0;
*				break;
*			}
*
*		_asteroid->on = 1;
*		_asteroid->image = 0;
*		_asteroid->xposfrac = _asteroid->yposfrac = 0;
*		while ( (_asteroid->xvit = (rand() % 256) - 128) == 0 );
*		while ( (_asteroid->yvit = (rand() % 256) - 128) == 0 );
*		}

S1AstCreate::

.SAVREGS reg D3/A3

	movem.l	#.SAVREGS,-(SP)

	lea		Asteroids,A3

*	nombre d'asteroide proportionnel au niveau

	move	S1Level(PC),D0
	move	D0,D3
	addq	#2,D3
	cmpi	#8,D3
	ble.s	.1
	moveq	#8,D3
.1:	move	D3,S1NAst
	move	D3,S1NCible
	addq	#1,D0
	move	D0,S1Level

	subq	#1,D3
.loop:

.xpos:
	jsr		FastRand(PC)		; position x
	divu	#320,D0
	swap	D0
	move	D0,AST_XPOS(A3)

.ypos:
	jsr		FastRand(PC)		; position y
	divu	#192,D0
	swap	D0
	move	D0,AST_XPOS(A3)

	jsr		FastRand(PC)		; cote ou doit apparaitre l'asteroide
	andi	#3,D0
	add		D0,D0
	add		D0,D0
	jmp		.vects(PC,D0)
.vects:
	jmp		.haut(PC)
	jmp		.droit(PC)
	jmp		.bas(PC)
	jmp		.gauche(PC)
.haut:
	clr		AST_YPOS(A3)
	bra.s	.xvit
.droit:
	move	#319,AST_XPOS(A3)
	bra.s	.xvit
.bas:
	move	#191,AST_YPOS(A3)
	bra.s	.xvit
.gauche:
	clr		AST_XPOS(A3)

.xvit:
	jsr		FastRand(PC)
	andi	#255,D0
	subi	#127,D0
	beq.s	.xvit
	move	D0,AST_XVIT(A3)

.yvit:
	jsr		FastRand(PC)
	andi	#255,D0
	subi	#127,D0
	beq.s	.yvit
	move	D0,AST_YVIT(A3)

	move	#1,(A3)
	moveq	#0,D0
	move	D0,AST_IMG(A3)
	move.l	D0,AST_XPOSFRAC(A3)

.next:
	lea		AST_SZOF(A3),A3
	dbf		D3,.loop

	movem.l	(SP)+,#.SAVREGS
	rts

**************************************************************************
*
*	Deplacer l'ensemble des asteroides
*
*	void S1AstMove( void )
*
*	for ( ii = 0; ii < S1NAst; ii++, _asteroid++ ) {
*		if ( _asteroid->on == 0 )
*			continue;
*		S1CalcPos(_asteroid->xvit,_asteroid->yvit,(POSITION *)&_asteroid->xpos);
*		}

S1AstMove::
	move.l	A3,-(SP)
	move	D3,-(SP)

	lea		Asteroids,A3
	move	S1NAst(PC),D3
	bra.s	.test
.loop:
	tst		(A3)
	beq.s	.next
	lea		AST_XPOS(A3),A0
	movem	AST_XVIT(A3),D0/D1
	jsr		S1CalcPos(PC)
.next:
	lea		AST_SZOF(A3),A3
.test:
	dbf		D3,.loop

	move	(SP)+,D3
	move.l	(SP)+,A3
	rts

**************************************************************************
*
*	Effacer les asteroides de l'ecran cache
*
*	void S1AstClear( void )
*
*	for ( ii = 0; ii < S1NAst; ii++, _asteroid++ )
*		SpriteClear(_asteroid->scradr);

S1AstClear::
	move.l	A3,-(SP)
	move	D3,-(SP)

	lea		Asteroids+AST_SCRADR,A3
	move	S1NAst(PC),D3
	bra.s	.test
.loop:
	move.l	A3,A0				;  4
	jsr		SpriteClear(PC)		; 18
	lea		AST_SZOF(A3),A3		;  8
.test:
	dbf		D3,.loop			; 10

	move	(SP)+,D3
	move.l	(SP)+,A3
	rts

**************************************************************************
*
*	Dessiner asteroides dans ecran cache
*
*	void S1AstDraw( void )
*
*	for ( ii = 0; ii < S1NAst; ii++, _asteroid++ ) {
*		if ( _asteroid->on == 0 )
*			continue;
*		if ( _asteroid->on > 0 ) {
*			if ( S1SprScreen(_asteroid->xpos,_asteroid->ypos,&AstImg[_asteroid->image]) )
*				SpriteDraw(&AstImg[_asteroid->image],_asteroid->scradr);
*			_asteroid->scrbox = AstImg[_asteroid->image].box;
*			}
*		else {
*			if ( S1SprScreen(_asteroid->xpos,_asteroid->ypos,&ExplodeImg[_asteroid->image >> 1]) )
*				SpriteDraw(&ExplodeImg[_asteroid->image >> 1],_asteroid->scradr);
*			_asteroid->image++;
*			if ( (_asteroid->image >> 1) == 8 ) {
*				_asteroid->on = 0;
*				S1NCible--;
*				}
*			}
*		}

S1AstDraw::

.SAVREGS reg D3/D4/A2/A3/A4/A5

	movem.l	#.SAVREGS,-(SP)

	lea		AstImg,A5
	lea		ExplImg,A4
	lea		Asteroids,A3
	move	S1NAst(PC),D3
	bra		.test
.loop:
	tst		(A3)
	beq		.next
	bmi.s	.expl

.draw:
	move.l	A5,A2
	lea		SprIdx(PC),A0
	move	AST_IMG(A3),D0
	add		D0,D0
	adda	0(A0,D0),A2				; A2 = &AstImg[_asteroid->image]
	move.l	A2,A0					; calculer donnees ecran
	movem	AST_XPOS(A3),D0/D1
	jsr		S1SprScreen(PC)
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
	bra.s	.next

.expl:
	move.l	A4,A2
	lea		SprIdx(PC),A0
	move	AST_IMG(A3),D0
	lsr		#1,D0
	add		D0,D0
	adda	0(A0,D0),A2				; A2 = &ExplImg[_asteroid->image >> 1]
	move.l	A2,A0					; calculer donnees ecran
	movem	AST_XPOS(A3),D0/D1
	jsr		S1SprScreen(PC)
	beq.s	.2
	lea		AST_SCRADR(A3),A1		; dessiner
	move.l	A2,A0
	jsr		SpriteDraw(PC)
.2:	move	AST_IMG(A3),D0
	addq	#1,D0
	move	D0,AST_IMG(A3)
	cmpi	#16,D0
	bne.s	.next
	clr		(A3)
	subq	#1,S1NCible

.next:
	lea		AST_SZOF(A3),A3
.test:
	dbf		D3,.loop

	movem.l	(SP)+,#.SAVREGS
	rts

**************************************************************************
*
*	Creer un objet extraterrestre ou bonus
*
*	void S1AlnCreate( void )
*
*	0 = petit alien
*	1 = gros alien
*	2 = fire power 1
*	3 = fire power 2
*	4 = zap
*	5 = 1K
*	6 = auto fire

S1AlnCreate::

	lea		Alien,A1
	tst		(A1)					; ALN_ON(A1)
	bne.s	.bye

	subq	#1,ALN_COUNT(A1)
	bgt.s	.bye
	clr		ALN_COUNT(A1)

	move	S1Level(PC),D0
	subq	#2,D0
	bmi.s	.bye

	move	S1NCible(PC),D0
	subq	#3,D0
	bmi.s	.bye

	jsr		FastRand(PC)

	move	D0,D1
	lsr		#6,D1
	add		D1,D1
	move	.alntype(PC,D1),D2	; si negatif, augmente fire power
	bpl.s	.1

	move	Joueur+JR_MISTYPE,D1
	add		D1,D1
	move	.firepow(PC,D1),D2

.1:	move	D2,ALN_TYPE(A1)

	move	D0,D1
	andi	#1,D1
	add		D1,D1
	move	.alnxpos(PC,D1),ALN_XPOS(A1)
	move	.alnxvit(PC,D1),D1
	tst		D2
	sne		D2
	andi	#1,D2
	asr		D2,D1
	move	D1,ALN_XVIT(A1)

	move	D0,D1
	andi	#127,D1
	addi	#32,D1
	move	D1,ALN_YPOS(A1)
	clr		ALN_YVIT(A1)

	clr.l	ALN_XPOSFRAC(A1)

	move	#1,(A1)					; ALN_ON(A1)

.bye:
	rts

.alntype:	dc.w	-1,5,5,4,4,1,1,1,1,1,1,0,0,0,0,0
.firepow:	dc.w	2,3,6
.alnxpos:	dc.w	0,319
.alnxvit:	dc.w	128,-128

**************************************************************************
*
*	Deplacer l'objet auxiliaire (extraterrestre ou boni) et le missile
*	correspondant.
*
*	void S1AlnMove( void )
*
*	Le petit extraterrestre tire avec intelligence 7 fois sur 8
*	Le gros extraterrestre tire avec intelligence 1 fois sur 8

S1AlnMove::

.SAVREGS reg D3/D4/A3

	movem.l	#.SAVREGS,-(SP)

	lea		Alien,A3

.alnmove:
	tst		(A3)					; ALN_ON(A3)
	ble.s	.mismove

	jsr		FastRand(PC)			; vitesse y varie aleatoirement
	cmpi	#16,D0
	bge.s	.alncalcpos

	lea		.alnyvit(PC),A0			; modifier vitesse y
	move.b	0(A0,D0),D1
	ext		D1
	move	D1,ALN_YVIT(A3)

.alncalcpos:
	lea		ALN_XPOS(A3),A0			; calculer nouvelle position
	movem	ALN_XVIT(A3),D0/D1
	jsr		S1CalcPos(PC)

	move	ALN_XPOS(A3),D0			; verifier si objet quitte l'ecran
	bmi.s	.alnoff
	cmpi	#320,D0
	blt.s	.mismove

.alnoff:
	move	#300,ALN_COUNT(A3)		; 60 secondes avant prochain objet
	clr		(A3)					; ALN_ON(A3)

.mismove:
	tst		ALN_MIS+MIS_ON(A3)		; missile extraterrestre en action
	ble.s	.mismake				; non

	subq	#1,ALN_MIS+MIS_ON(A3)
	beq		.bye

	lea		ALN_MIS+MIS_XPOS(A3),A0	; obtenir nouvelle position du missile
	movem	ALN_MIS+MIS_XVIT(A3),D0/D1
	jsr		S1CalcPos(PC)
	bra		.bye

.mismake:
	tst		(A3)					; ALN_ON(A3)
	ble		.bye

	move	ALN_TYPE(A3),D0			; seul les extraterrestres tirent
	cmpi	#2,D0
	bge		.bye

	moveq	#98,D1
	lsl		D0,D1
	moveq	#120,D0
	lea		SplCoucou,A0
	jsr		SplOn(PC)

	move	#24,ALN_IMAGE(A3)		; ouvrir le couvercle
	move	#63,ALN_MIS+MIS_ON(A3)	; activer missile
	move.l	ALN_XPOS(A3),ALN_MIS+MIS_XPOS(A3)
	move.l	ALN_XPOSFRAC(A3),ALN_MIS+MIS_XPOSFRAC(A3)

	jsr		FastRand(PC)
	move	D0,D4					; D4 = valeur aleatoire

	lea		Joueur,A0
	tst		JR_HYPER(A0)			; joueur dans l'hyper espace ?
	bne.s	.misrand				; oui
	tst		JR_ENERGIE(A0)
	beq.s	.misrand

	move	D4,D0
	andi	#7,D0
	move	ALN_TYPE(A3),D1
	lsl		#3,D1					; intelligence selon type d'extraterrestre
	add		D0,D1
	move.b	.alnsmart(PC,D1),D0		; tir intelligent ?
	beq.s	.misrand				; non

	movem	JR_XPOS(A0),D2/D3		; obtenir direction du tir
	movem	ALN_XPOS(A3),D0/D1
	jsr		S1GetDir(PC)
	bpl.s	.misvit

.misrand:
	move	D4,D0
	andi	#15,D0

.misvit:
	add		D0,D0
	lea		MisXVit(PC),A0
	move	0(A0,D0),D1
	add		D1,D1
	add		D1,D1
	move	D1,ALN_MIS+MIS_XVIT(A3)
	lea		MisYVit(PC),A0
	move	0(A0,D0),D1
	add		D1,D1
	add		D1,D1
	move	D1,ALN_MIS+MIS_YVIT(A3)

.bye:
	movem.l	(SP)+,#.SAVREGS
	rts

.alnsmart:
	dc.b	0,0,1,1,1,1,1,1
	dc.b	0,0,0,0,0,0,0,1
.alnyvit:
	dc.b	-64,-64,-64,-64,-64,0,0,0,0,0,0,64,64,64,64,64

**************************************************************************
*
*	Dessiner l'extraterrestre ou le bonus
*
*	void S1AlnDraw( void )

S1AlnDraw::

.SAVREGS reg A2/A3

	movem.l	#.SAVREGS,-(SP)

	lea		Alien,A3
	move	(A3),D0				; ALN_ON(A3)
	beq		.mis_draw
	bmi		.expl_draw			; sequence explosive

.aln_draw:
	move	ALN_TYPE(A3),D0		; dessiner selon type d'objet (alien ou bonus)
	add		D0,D0
	add		D0,D0
	jmp		.draw_vects(PC,D0)
.draw_vects:
	jmp		.aln1(PC)
	jmp		.aln2(PC)
	jmp		.aid1(PC)
	jmp		.aid2(PC)
	jmp		.aid3(PC)
	jmp		.aid4(PC)
	jmp		.aid5(PC)
.aln1:
.aln2:
	lea		AlnImg,A2
	lea		SprIdx(PC),A0
	move	ALN_IMAGE(A3),D0
	beq.s	.2
	subq	#1,D0
	move	D0,ALN_IMAGE(A3)
	moveq	#2,D0
.2:	add		ALN_TYPE(A3),D0
	add		D0,D0
	adda	0(A0,D0),A2			; A2 = &AlnImg[idx]

	move.l	A2,A0
	movem	ALN_XPOS(A3),D0/D1
	jsr		S1SprScreen(PC)
	beq.s	.aln_savbox

	lea		ALN_SCRADR(A3),A1
	move.l	A2,A0
	jsr		SpriteDraw(PC)
	bra.s	.aln_savbox

.aid1:
.aid2:
.aid3:
.aid4:
.aid5:
	lea		BonusImg,A2
	lea		SprIdx(PC),A0
	move	ALN_TYPE(A3),D0
	subq	#2,D0
	add		D0,D0
	adda	0(A0,D0),A2				; A2 = &BonusImg[idx]

	move.l	A2,A0
	movem	ALN_XPOS(A3),D0/D1
	jsr		S1SprScreen(PC)
	beq.s	.aln_savbox

	lea		ALN_SCRADR(A3),A1
	move.l	A2,A0
	jsr		SpriteDraw(PC)

.aln_savbox:
	lea		ALN_SCRBOX(A3),A0		; obtenir boite ecran
	move	(A2)+,D0				; [x1,y1-x2,y2[
	move	D0,(A0)+
	move	(A2)+,D1
	move	D1,(A0)+
	add		(A2)+,D0
	move	D0,(A0)+
	add		(A2)+,D1
	move	D1,(A0)+
	bra.s	.mis_draw

.expl_draw:
	move	ALN_IMAGE(A3),D0
	addq	#1,D0
	move	D0,ALN_IMAGE(A3)
	cmpi	#16,D0
	bge.s	.expl_off

	lea		ExplImg,A2
	lea		SprIdx(PC),A0
	andi	#$FFFE,D0
	adda	0(A0,D0),A2				; A2 = &ExplImg[idx]

	move.l	A2,A0
	movem	ALN_XPOS(A3),D0/D1
	jsr		S1SprScreen(PC)
	beq.s	.mis_draw

	lea		ALN_SCRADR(A3),A1
	move.l	A2,A0
	jsr		SpriteDraw(PC)
	bra.s	.mis_draw

.expl_off:
	move	#300,ALN_COUNT(A3)
	clr		(A3)					; ALN_ON(A3)

.mis_draw:
	tst		ALN_MIS+MIS_ON(A3)
	beq.s	.bye

	lea		AlnImg+(4*SPR_SZOF),A2
	lea		SprIdx(PC),A0
	move	ALN_MIS+MIS_TYPE(A3),D0
	add		D0,D0
	adda	0(A0,D0),A2				; A2 = &AlnImg[idx]

	move.l	A2,A0
	movem	ALN_MIS+MIS_XPOS(A3),D0/D1
	jsr		S1SprScreen(PC)
	beq.s	.mis_savbox

	lea		ALN_MIS+MIS_SCRADR(A3),A1
	move.l	A2,A0
	jsr		SpriteDraw(PC)

.mis_savbox:
	lea		ALN_MIS+MIS_SCRBOX(A3),A0	; obtenir boite ecran
	move	(A2)+,D0					; [x1,y1-x2,y2[
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

**************************************************************************
*
*	Effacer l'extraterrestre de l'ecran cache
*
*	void S1AlnClear( void )

S1AlnClear::
	lea		Alien+ALN_SCRADR,A0
	jsr		SpriteClear(PC)
	lea		Alien+ALN_MIS+MIS_SCRADR,A0
	jsr		SpriteClear(PC)
	rts

**************************************************************************
*
*	Attendre que le vaisseau soit hors de danger.
*
*	int S1WaitSafe( void )
*
*	La routine retourne 1 si la zone ou doit apparaitre le vaisseau est
*	libre de tout danger.
*
*	if ( Alien.on != 0 || Alien.mis.on != 0 )
*		return (0);
*	CollConf(&SafeBox);
*	for ( ii = 0; ii < S1NAst; ii++, _asteroid++ ) {
*		if ( _asteroid->on <= 0 )
*			continue;
*		if ( CollOr(&_asteroid->scrbox) )
*			return (0);
*		}
*	return (1);

S1WaitSafe::

.SAVREGS reg D3/A3

	movem.l	#.SAVREGS,-(SP)

	lea		Alien,A0
	tst		(A0)			; ALN_ON(A0)
	bne.s	.zero
	tst		ALN_MIS+MIS_ON(A0)
	bne.s	.zero

	lea		.safeframe(PC),A0
	jsr		CollConf(PC)

	lea		Asteroids,A3
	move	S1NAst(PC),D3
	bra.s	.test
.loop:
	tst		(A3)			; AST_ON(A3)
	ble.s	.next
	lea		AST_SCRBOX(A3),A0
	jsr		CollOr(PC)
	bne.s	.zero
.next:
	lea		AST_SZOF(A3),A3
.test:
	dbf		D3,.loop

	movem.l	(SP)+,#.SAVREGS
	moveq	#1,D0
	rts

.zero:
	movem.l	(SP)+,#.SAVREGS
	moveq	#0,D0
	rts

.safeframe:
	dc.w	160-(80/2),96-(60/2)
	dc.w	160-(80/2)+80,96-(60/2)+80

**************************************************************************
*
*	Initialiser les donnees du joueur
*
*	void S1JrReset( void )
*
*	_joueur->dir = 0;
*	_joueur->xpos = 160;
*	_joueur->ypos = 96;
*	_joueur->xposfrac = _joueur->yposfrac = 0;
*	_joueur->xvit = _joueur->yvit = 0;
*	_joueur->xvitfrac = _joueur->yvitfrac = 0;
*	_joueur->dommage = 55;
*	_joueur->moteur = 0;
*	_joueur->energie = 1;
*	_joueur->hyper = 0;
*	for ( ii = 0; ii < NMISSILE; ii++ )
*		_joueur->missiles[ii].on = 0;

S1JrReset::
	lea		Joueur,A0

	move	#160,JR_XPOS(A0)
	move	#96,JR_YPOS(A0)
	move	#31,JR_DOMMAGE(A0)
	move	#1,JR_ENERGIE(A0)

	moveq	#0,D0
	move	D0,(A0)				; JR_DIR(A0)
	move.l	D0,JR_XPOSFRAC(A0)
	move.l	D0,JR_XVIT(A0)
	move.l	D0,JR_XVITFRAC(A0)
	move	D0,JR_MOTOR(A0)
	move	D0,JR_HYPER(A0)
	move	D0,JR_MISTYPE(A0)
	move	D0,JR_AUTOFIRE(A0)

	lea		JR_MIS(A0),A1
	moveq	#7,D1
.loop:
	move	D0,(A1)
	lea		MIS_SZOF(A1),A1
	dbf		D1,.loop
	rts

**************************************************************************
*
*	Deplacer les missiles du joueur
*
*	void S1MisMove( void )
*
*	tir = ((_joueur->move & 8) != 0 && (_joueur->oldmove & 8) == 0 && _joueur->energie > 0);
*
*	for ( ii = 0; ii < NMISSILE; ii++, _missile++ ) {
*
*		if ( _missile->on == 0 ) {
*			if ( tir != 0 ) {
*				(*SplOn._proc)(&SplFire,0,98);
*				_missile->on = 63;
*				_missile->xpos = _joueur->xpos + MisXPos[_joueur->dir >> (DIR_FRAC/32)];
*				_missile->ypos = _joueur->ypos + MisYPos[_joueur->dir >> (DIR_FRAC/32)];
*				_missile->xposfrac = _joueur->xposfrac;
*				_missile->yposfrac = _joueur->yposfrac;
*				_missile->xvit = _joueur->xvit + MisXVit[_joueur->dir >> (DIR_FRAC/32)];
*				_missile->yvit = _joueur->yvit + MisYVit[_joueur->dir >> (DIR_FRAC/32)];
*				tir = 0;
*				}
*			}
*		else {
*			if ( --_missile->on )
*				S1CalcPos(_missile->xvit,_missile->yvit,(POSITION *)&_missile->xpos);
*			}
*		}

S1MisMove::

.SAVREGS reg D3/D4/A2/A3

	movem.l	#.SAVREGS,-(SP)

	lea		Joueur,A2

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
	bne		.move

.make:
	tst		D4						; creer un missile ?
	beq		.next					; non

	move	JR_MISTYPE(A2),D0		; agir selon type de missile
	move	D0,MIS_TYPE(A3)

	add		D0,D0
	add		D0,D0
	jmp		.vects(PC,D0)
.vects:
	jmp		.mis1(PC)
	jmp		.mis2(PC)
	jmp		.mis3(PC)
.mis1:
	moveq	#98,D1
	moveq	#0,D0
	lea		SplFire1,A0
	jsr		SplOn(PC)
	move	#63,(A3)			; MIS_ON(A3)
	bra.s	.initpos
.mis2:
	moveq	#177,D1
	moveq	#0,D0
	lea		SplFire2,A0
	jsr		SplOn(PC)
	move	#63,(A3)			; MIS_ON(A3)
	bra.s	.initpos
.mis3:
	moveq	#0,D1
	moveq	#0,D0
	lea		SplFire3,A0
	jsr		SplOn(PC)
	move	#63,(A3)			; MIS_ON(A3)

.initpos:
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
	jsr		S1CalcPos(PC)

.next:
	lea		MIS_SZOF(A3),A3
	dbf		D3,.loop

	movem.l	(SP)+,#.SAVREGS
	rts

**************************************************************************
*
*	Dessiner les missiles du joueur
*
*	void S1MisDraw( void )
*
*	for ( ii = 0; ii < NMISSILE; ii++, _missile++ ) {
*		if ( _missile->on == 0 )
*			continue;
*		mis_idx = _missile->on >> 4;
*		if ( S1SprScreen(_missile->xpos,_missile->ypos,&MisImg[mis_idx]) )
*			SpriteDraw(&MisImg[mis_idx],_missile->scradr);
*		_missile->scrbox = MisImg[mis_idx].box;
*		}

S1MisDraw::

.SAVREGS reg D3/A2/A3/A4

	movem.l	#.SAVREGS,-(SP)

	lea		.mis_img(PC),A4
	lea		Joueur+JR_MIS,A3

	moveq	#7,D3
.loop:
	move	(A3),D0				; MIS_ON(A3)
	beq.s	.next

	lea		SprIdx(PC),A0

	move	MIS_TYPE(A3),D1		; image selon type de missile
	add		D1,D1
	add		D1,D1
	jmp		.vects(PC,D1)
.vects:
	jmp		.mis1(PC)
	jmp		.mis2(PC)
	jmp		.mis3(PC)
.mis1:
	move.l	(A4),A2
	bra.s	.draw
.mis2:
	move.l	4(A4),A2
	bra.s	.draw
.mis3:
	move.l	8(A4),A2

.draw:
	lsr		#3,D0
	andi	#$FFFE,D0
	adda	0(A0,D0),A2

	move.l	A2,A0				; obtenir donnees ecran
	movem	MIS_XPOS(A3),D0/D1
	jsr		S1SprScreen(PC)
	beq.s	.savbox

	lea		MIS_SCRADR(A3),A1	; dessiner sprite
	move.l	A2,A0
	jsr		SpriteDraw(PC)

.savbox:
	lea		MIS_SCRBOX(A3),A0	; sauver boite ecran
	move	(A2)+,D0			; [x1,y1-x2,y2[
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

.mis_img:
	dc.l	MisImg,BigMisImg,GazMisImg

**************************************************************************
*
*	Effacer missile du joueur de l'ecran
*
*	void S1MisClear( void )

S1MisClear::

	move.l	A3,-(SP)

	lea		Joueur+JR_MIS+MIS_SCRADR,A3

	.rept	7
	move.l	A3,A0
	jsr		SpriteClear(PC)
	lea		MIS_SZOF(A3),A3
	.endr
	move.l	A3,A0
	jsr		SpriteClear(PC)

	move.l	(SP)+,A3
	rts

**************************************************************************
*
*	Dessiner joueur dans ecran cache
*
*	void S1JrDraw( void )
*
*	if ( _joueur->energie > 0 ) {
*		if ( _joueur->hyper > 0 )
*			_joueur->hyper--;
*		if ( _joueur->hyper != 0 )
*			return;
*		index = _joueur->dir >> (DIR_FRAC/32);
*		_vaisseau = &_joueur->vaisseau[index];
*		if ( S1SprScreen(_joueur->xpos,_joueur->ypos,_vaisseau) )
*			SpriteDraw(_vaisseau,_joueur->savship);
*		_joueur->scrbox = _vaisseau->box;
*		if ( _joueur->moteur ) {
*			if ( S1SprScreen(_joueur->xpos,_joueur->ypos,&MotorImg[index]) )
*				SpriteDraw(&MotorImg[index],_joueur->savfire);
*			}
*		}
*	else {
*		if ( _joueur->dommage > 0 ) {
*			index = _joueur->dommage >> 3;
*			if ( S1SprScreen(_joueur->xpos,_joueur->ypos,&ExplImg[index]) )
*				SpriteDraw(&ExplImg[index],_joueur->savship);
*			_joueur->dommage--;
*			}
*		}

S1JrDraw::

.SAVREGS reg D3/A2/A3

	movem.l	#.SAVREGS,-(SP)

	lea		Joueur,A3

	tst		JR_ENERGIE(A3)
	ble.s	.expl

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
	jsr		S1SprScreen(PC)
	beq.s	.savbox
	lea		JR_SAVSHIP(A3),A1
	move.l	A2,A0
	jsr		SpriteDraw(PC)

.savbox:
	lea		JR_SCRBOX(A3),A0
	move	(A2)+,D0			; [x1,y1-x2,y2[
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
	jsr		S1SprScreen(PC)
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
	jsr		S1SprScreen(PC)
	beq.s	.bye
	lea		JR_SAVSHIP(A3),A1
	move.l	A2,A0
	jsr		SpriteDraw(PC)

.bye:
	movem.l	(SP)+,#.SAVREGS
	rts

**************************************************************************
*
*	Traiter joueur selon etat du joystick
*
*	void S1JrMove( void )

S1JrMove::

	move.l	A3,-(SP)

	lea		Joueur,A3

	addq.l	#1,JR_COUNTER(A3)

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
	add		JR_XVIT(A3),D0
	cmpi	#512,D0
	blt.s	.xvitok
	move	#511,D0
	bra.s	.xvitok
.xfracneg:
	neg		D0
	move	D0,D1
	andi	#63,D1
	neg		D1
	move	D1,JR_XVITFRAC(A3)
	lsr		#6,D0
	neg		D0
	add		JR_XVIT(A3),D0
	cmpi	#-512,D0
	bgt.s	.xvitok
	move	#-511,D0
.xvitok:
	move	D0,JR_XVIT(A3)

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
	add		JR_YVIT(A3),D0
	cmpi	#512,D0
	blt.s	.yvitok
	move	#511,D0
	bra.s	.yvitok
.yfracneg:
	neg		D0
	move	D0,D1
	andi	#63,D1
	neg		D1
	move	D1,JR_YVITFRAC(A3)
	lsr		#6,D0
	neg		D0
	add		JR_YVIT(A3),D0
	cmpi	#-512,D0
	bgt.s	.yvitok
	move	#-511,D0
.yvitok:
	move	D0,JR_YVIT(A3)

.move:
	lea		JR_XPOS(A3),A0
	movem	JR_XVIT(A3),D0/D1
	jsr		S1CalcPos(PC)

.bye:
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
*	int S1GetMove( void )
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

S1GetMove::
	move	Joueur+JR_MOVE,Joueur+JR_OLDMOVE

	lea		KeyStat(PC),A0
	lea		S1KeyCfg,A1
	move	#%10000000,D0
	moveq	#0,D1

*	fire
	move.b	KEY_FIRE(A1),D1
	tst.b	KBD_KEYSTAT(A0,D1)
	beq.s	.hyper
	tst		Joueur+JR_AUTOFIRE
	beq.s	.1
	move	Joueur+JR_COUNTER+2,D1
	add		D1,D1
	andi	#8,D1
	or		D1,D0
	bra.s	.hyper
.1:	or		#%00001000,D0

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
*	Lire clavier
*
*	int S1LookKeybd( void )
*
*	keycode = LookKeybd();
*	if ( keycode == 1 ) {
*		while ( LookKeybd() == 0 );
*		}
*	else {
*		if ( keycode == 0x61 )
*			JouteStatus = 3;
*		}
*	return ( JouteStatus );

S1LookKeybd::
	jsr		LookKeybd(PC)
	cmp.b	S1KeyCfg+KEY_PAUSE,D0	; pause ?
	bne.s	.chkundo
.pause:
	jsr		LookKeybd(PC)
	beq.s	.pause
	move	JouteStatus,D0
	rts
.chkundo:
	cmpi	#$61,D0			; Undo (quitter) ?
	bne.s	.bye
	move	#3,JouteStatus
.bye:
	move	JouteStatus,D0
	rts

**************************************************************************
*
*	Afficher le nouveau nombre de vaisseau auxiliaire
*
*	void S1ShowSpare( int newnum )
*
*	char str[16];
*
*	if ( newnum == S1NShip )
*		return;
*	S1NShip = newnum;
*	if ( newnum >= 6 ) {
*		str[0] = '~';
*		str[1] = '4';
*		MyLToA(&str[2],(long)newnum);
*		StrRight(&str[2],2);
*		_ShowStr(64,192,str);
*		PutImage(160,74,80,192,16,8);
*		ClrImage(96,192,48,8);
*		}
*	else {
*		index = 0;
*		while ( newnum-- ) {
*			CpyImage(160,60,64 + (index << 4),192,16,8);
*			index++;
*			}
*		if ( index < 5 )
*			ClrImage(64 + (index << 4),192,(5 - index) * 16,8);
*		}

S1ShowSpare::

.SAVREGS reg D3/D4

	cmp		S1NShip(PC),D0
	beq		.bye

	movem.l	#.SAVREGS,-(SP)

	move	D0,S1NShip

	cmpi	#5,D0
	ble.s	.under6

.over5:
	ext.l	D0
	lea		.str+2(PC),A0
	jsr		MyLToA(PC)

	moveq	#2,D0
	lea		.str+2(PC),A0
	jsr		StrRight(PC)

	moveq	#0,D2
	lea		.str(PC),A0
	move	#192,D1
	moveq	#64,D0
	jsr		_ShowStr(PC)

	move	#7,-(SP)
	move	#16,-(SP)
	move	#192,-(SP)
	moveq	#80,D2
	moveq	#60,D1
	move	#160,D0
	jsr		CpyImage(PC)
	addq.l	#6,SP

	move	#8,-(SP)
	moveq	#48,D2
	move	#192,D1
	moveq	#96,D0
	jsr		ClrImage(PC)
	addq.l	#2,SP
	bra.s	.brk

.under6:
	moveq	#64,D3
	move	D0,D4
	bra.s	.test
.loop:
	move	#7,-(SP)
	move	#16,-(SP)
	move	#192,-(SP)
	move	D3,D2
	moveq	#60,D1
	move	#160,D0
	jsr		CpyImage(PC)
	addq.l	#6,SP

	addi	#16,D3
.test:
	subq	#1,D4
	bge.s	.loop

	cmpi	#144,D3
	bge.s	.brk

	move	#8,-(SP)
	move	#144,D2
	sub		D3,D2
	move	#192,D1
	move	D3,D0
	jsr		ClrImage(PC)
	addq.l	#2,SP

.brk:
	move	#8,-(SP)
	moveq	#80,D2
	move	#192,D1
	moveq	#64,D0
	jsr		CopyZone(PC)
	addq.l	#2,SP

	movem.l	(SP)+,#.SAVREGS

.bye:
	rts

.str:	dc.b	'~4'
		dcb.b	6,0

**************************************************************************
*
*	void S1PtsDraw( int points )
*
*	Afficher le pointage courant d'un joueur

S1PtsDraw::
	move.l	Joueur+JR_POINTS,D0
	cmp.l	.oldpts(PC),D0		; changement depuis dernier affichage ?
	beq.s	.bye				; non
	move.l	D0,.oldpts
	move.l	D0,D2
	move	#192,D1
	moveq	#0,D0
	jsr		DrawNumber(PC)
.bye:
	rts

.oldpts:
	dc.l	-1

**************************************************************************
*
*	Boucle de jeu principale
*
*	void S1Play( void );
*
*	Interne
*		A5 = Joueur
*		A4 = Alien
*		D5 = mode courant
*		D4 = compteur
*
*	Note
*		mode 0 = normal
*		mode 2 = nouveau vaisseau
*		mode 4 = nouvelle vague d'asteroide

S1Play::

.SAVREGS reg D4/D5/A4/A5

	movem.l	#.SAVREGS,-(SP)

	lea		Joueur,A5		; A5 = Joueur
	lea		Alien,A4		; A4 = Alien

	moveq	#2,D5			; D5 = mode (nouveau vaisseau)

*	initialiser boucle selon mode de jeu
.init_loop:
	jmp		.v0(PC,D5)
.v0:
	bra.s	.main_loop	; rien a initialiser
	bra.s	.010
	bra.s	.020

*	nouveau vaisseau
.010:
	jsr		S1JrReset(PC)
	move	S1NShip(PC),D0
	beq		.break
	subq	#1,D0
	jsr		S1ShowSpare(PC)
	clr		JR_ENERGIE(A5)
	bra.s	.main_loop

*	nouvelle vague d'asteroide
.020:
	moveq	#120,D4

.main_loop:

*	creer un alien (ou boni)
	jmp		.v1(PC,D5)
.v1:
	bra.s	.10
	bra.s	.11
	bra.s	.11
.10:
	jsr		S1AlnCreate(PC)
.11:

*	gerer le clavier
	jsr		S1LookKeybd(PC)

*	obtenir mouvement du joueur
	jsr		S1GetMove(PC)
	jmp		.v2(PC,D5)
.v2:
	bra.s	.20
	bra.s	.21
.20:
	move	D0,JR_MOVE(A5)
.21:

*	deplacer joueur
	jmp		.v3(PC,D5)
.v3:
	bra.s	.30
	bra.s	.31
.30:
	jsr		S1JrMove(PC)
.31:

*	deplacer alien, missiles, asteroides
	jsr		S1AlnMove(PC)
	jsr		S1MisMove(PC)
	jsr		S1AstMove(PC)

*	attendre que l'ecran soit bascule
	jsr		SwapWait(PC)

*	quitter le jeu ?
	move	JouteStatus,D0
	bne		.break

*	nettoyer l'ecran cache
	lea		JR_SAVSHIP(A5),A0
	jsr		SpriteClear(PC)
	lea		JR_SAVFIRE(A5),A0
	jsr		SpriteClear(PC)
	jsr		S1AlnClear(PC)
	jsr		S1MisClear(PC)
	jsr		S1AstClear(PC)

*	dessiner joueur
	jmp		.v4(PC,D5)
.v4:
	bra.s	.40
	bra.s	.41
.40:
	jsr		S1JrDraw(PC)
.41:

*	dessiner alien, missiles, asteroides et points
	jsr		S1MisDraw(PC)
	jsr		S1AstDraw(PC)
	jsr		S1AlnDraw(PC)
	jsr		S1PtsDraw(PC)

*	basculer ecran
	jsr		SwapScreen(PC)

*	gestion des collisions
	jsr		S1Collision(PC)

*	test de fin de boucle selon mode courant
.term_loop:
	jmp		.v5(PC,D5)
.v5:
	bra.s	.500
	bra.s	.510
	bra.s	.520

*	mode 0 - vaisseau detruit ou plus d'asteroide ?
.500:
	tst		JR_DOMMAGE(A5)		; vaisseau detruit ?
	bne.s	.501
	moveq	#2,D5
	bra		.init_loop
.501:
	move	S1NCible(PC),D0		; plus d'asteroide ?
	bne		.main_loop
	moveq	#4,D5
	bra		.init_loop

*	mode 2 - vaisseau hors de danger ?
.510:
	jsr		S1WaitSafe(PC)
	beq		.main_loop
	move	#1,JR_ENERGIE(A5)
	moveq	#0,D5
	bra		.init_loop

*	mode 4 - nouvelle vague d'asteroide
.520:
	tst		ALN_ON(A4)
	bne		.main_loop
	tst		ALN_MIS+MIS_ON(A4)
	bne		.main_loop
	dbf		D4,.main_loop
	jsr		S1AstCreate(PC)
	move	#600,ALN_COUNT(A4)
	moveq	#0,D5
	bra		.init_loop

.break:
	movem.l	(SP)+,#.SAVREGS
	rts

**************************************************************************
*
*	Donnees relatives au mode SINGLE

S1NCible::	dc.w	0
S1NAst::	dc.w	0
S1NShip::	dc.w	0
S1Level::	dc.w	0
S1Bonus::	dc.l	0

.end
