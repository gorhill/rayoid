
.include 'H:\\STRUCT_S.IN'

**************************************************************************
*
*	Synchroniser le debut du jeu
*
*	int SyncStart( void )

SyncStart::
	clr		StartSignal
	moveq	#STARTSIGNAL,D0
	jsr		MdmWrByte(PC)
.doloop:
	jsr		RecvModem(PC)
	tst		D0
	bne.s	.break
.while:
	tst		StartSignal
	beq.s	.doloop
.break:
	move	JouteStatus,D0
	rts

**************************************************************************
*
*	Lire un octet sur le modem (ou midi)
*
*	int GetCMdm( void )

GetCMdm::

*	hors jeu ?
	move	JouteStatus,D0
	bne.s	.zero

*	undo ?
	lea		KeyStat(PC),A0
	move.b	KBD_KEYSTAT+$61(A0),D0
	beq.s	.1
	move	#3,JouteStatus
	cmpi.b	#$61,KBD_KEYON(A0)
	bne.s	.zero
	clr.b	KBD_KEYON(A0)
	bra.s	.zero

*	communication coupee ?
.1:	jsr		MdmConnect(PC)
	bne.s	.2
	move	#4,JouteStatus
	bra.s	.zero

*	octet modem disponible ?
.2:	jsr		MdmRdByte(PC)
	bpl.s	.ok

.zero:
	moveq	#0,D0
.ok:
	rts

**************************************************************************
*
*	Attendre un octet sur le modem (ou midi)
*
*	int WaitCMdm( void )

WaitCMdm::

*	hors jeu ?
	move	JouteStatus,D0
	bne.s	.zero

.loop:

*	undo ?
	lea		KeyStat(PC),A0
	move.b	KBD_KEYSTAT+$61(A0),D0
	beq.s	.1
	move	#3,JouteStatus
	cmpi.b	#$61,KBD_KEYON(A0)
	bne.s	.zero
	clr.b	KBD_KEYON(A0)
	bra.s	.zero

*	communication coupee ?
.1:	jsr		MdmConnect(PC)
	bne.s	.2
	move	#4,JouteStatus
	bra.s	.zero

*	octet modem disponible ?
.2:	jsr		MdmRdByte(PC)
	bmi.s	.loop
	rts

.zero:
	moveq	#0,D0
	rts

**************************************************************************
*
*	Transmettre un message via le modem
*
*	void MdmPost( int mode )
*
*	Si mode = 0 -> reception d'un message
*	Si mode = 1 -> transmission d'un message

MdmPostX::		dc.w	0
MdmPostY::		dc.w	0
MdmPostLen::	dc.w	0

color:			dc.b	'6','4'

MdmPost::

SAVREGS reg D3/D4/D5/D7/A5

	movem.l	#SAVREGS,-(SP)

	move	D0,D7				; D7 = mode de reception

	moveq	#82,D1
	moveq	#127,D0
	lea		SplDring,A0
	jsr		SplOn

	lea		-64(SP),SP			; espace pour chaine de caractere

	move.l	SP,A5				; A5 = str

	move.b	#'~',(A5)
	move.b	color(PC,D7),1(A5)	; couleur selon mode
	clr.b	2(A5)

	moveq	#1,D5				; D5 = redraw = 1
	moveq	#0,D4				; D4 = len = 0
	tst		D7					; mode de reception ?
	beq.s	do_loop				; oui

tx_init:
	moveq	#POSTMSG,D0			; signaler l'envoi d'un message au receveur
	jsr		MdmWrByte(PC)

do_loop:
	tst		D5					; redessiner message ?
	beq.s	redraw_ok			; non

	move	MdmPostLen(PC),D0	; justification a gauche
	lea		2(A5),A0
	jsr		StrLeft(PC)

	moveq	#0,D2				; afficher message
	move.l	A5,A0
	movem	MdmPostX(PC),D0/D1
	jsr		_ShowStr

	move.l	#(8*160),D0			; copier dans ecran 1

	move	MdmPostY(PC),D1
	mulu	#160,D1				; D1 = index ecran selon position y

	movem.l	_Screens(PC),A0/A1
	adda	D1,A0
	adda	D1,A1
	jsr		MemCopy(PC)

	moveq	#0,D5

redraw_ok:
	tst		D7					; mode reception ?
	beq.s	rx_getc				; oui

tx_getc:						; lire caractere du modem
	jsr		GetKeyAscii(PC)
	bra.s	parse

rx_getc:						; lire caractere du modem
	jsr		MdmRdByte(PC)
	bmi.s	rx_getc

parse:
	move	D0,D3				; D3 = caractere a traiter
	cmpi	#'\r',D3			; return ?
	beq.s	key_return			; oui
	cmpi	#'\b',D3			; backspace ?
	beq.s	key_bs				; oui
	cmpi	#27,D3				; escape ?
	beq.s	key_esc				; oui
	cmpi	#' ',D3				; >= ' ' ?
	blt		do_loop
	cmpi	#'}',D3				; <= '}' ?
	bgt		do_loop

	moveq	#1,D5				; redraw = 1

	tst		D7					; transmettre caractere ?
	beq.s	.1					; non
	move	D3,D0
	jsr		MdmWrByte(PC)

.1:	cmp		MdmPostLen(PC),D4	; len < MdmPostLen ?
	blt.s	.2					; oui
	lea		3(A5),A1			; strcpy(&str[2],&str[3]);
	lea		2(A5),A0
	jsr		strcpy(PC)
	move.b	D3,1(A5,D4)			; str[MdmPostLen + 1] = key;
	bra		do_loop
.2:	move.b	D3,2(A5,D4)			; str[2 + len] = key
	addq	#1,D4
	clr.b	2(A5,D4)			; str[2 + len] = 0
	bra		do_loop

key_return:
	tst		D7					; transmettre caractere ?
	beq.s	bye					; non
	move	D3,D0
	jsr		MdmWrByte(PC)
	bra.s	bye

key_bs:
	tst		D4					; len > 0 ?
	beq		do_loop				; non
	moveq	#1,D5				; redraw = 1
	subq	#1,D4				; len--
	clr.b	2(A5,D4)			; str[2 + len] = 0
	tst		D7					; transmettre caractere ?
	beq		do_loop				; non
	move	D3,D0
	jsr		MdmWrByte(PC)
	bra		do_loop

key_esc:
	tst		D7					; len > 0 ?
	beq		do_loop				; non
	moveq	#1,D5				; redraw = 1
	clr		D4					; len = 0
	clr.b	2(A5)				; str[2] = 0
	tst		D7					; transmettre caractere ?
	beq		do_loop				; non
	move	D3,D0
	jsr		MdmWrByte(PC)
	bra		do_loop

bye:
	lea		64(SP),SP

	movem.l	(SP)+,#SAVREGS
	rts

.end
