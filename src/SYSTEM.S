
.include 'ATARI.S'
.include 'H:\\STRUCT_S.IN'

**************************************************************************
*
*	Installer mon gestionnaire de systeme

_InitSys::

	; aller en superviseur
	clr.l	-(SP)
	move	#$20,-(SP)
	trap	#1
	addq.l	#6,SP

	move	#$2700,SR

	lea		savAlls,A0
	move.l	USP,A1
	move.l	A1,(A0)+
	move.l	D0,(A0)+		; ssp
	move.b	iera,(A0)+
	move.b	ierb,(A0)+
	move.b	imra,(A0)+
	move.b	imrb,(A0)+
	move.b	vr,(A0)+
	move.b	tacr,(A0)+
	move.b	tbcr,(A0)+
	move.b	tcdcr,(A0)+
	move.l	$70,(A0)+		; VBL
	move.l	timer_a,(A0)+	; timer a
	move.l	timer_b,(A0)+	; timer b
	move.l	timer_c,(A0)+	; timer c
	move.l	RS232_rbf,(A0)+
	move.l	RS232_re,(A0)+
	move.l	RS232_tbe,(A0)+
	move.l	RS232_te,(A0)+
	move.l	kbd_midi,(A0)+
	move.l	RS232_cts,(A0)+
	move.l	RS232_dcd,(A0)+
	move.b	syncmode,D0
	move.b	D0,(A0)+
	lsr		#1,D0
	andi	#1,D0
	move	D0,SyncMode

	move.l	#Null_IT,$70

	; inhiber 6301
.wait1:
	btst	#1,kbdctl
	beq.s	.wait1
	move.b	#$13,kbddata

	; inhiber acia midi
	move.b	#3,midictl

	; initialiser mfp

	moveq	#0,D0
	move.b	D0,iera
	move.b	D0,ierb
	move.b	D0,imra
	move.b	D0,imrb
	move.b	D0,tacr
	move.b	D0,tbcr
	bclr	#3,vr

	; timer b - basculeur d'ecran

	move.b	#200,tbdr
	stop	#$2300
	stop	#$2300
	move.b	#8,tbcr

	; installer et activer interruptions utilisees

	move	#$2700,SR

	move.l	#MyVBL,$70
	move.l	#MyTimerA,timer_a
	move.l	#MyTimerB,timer_b
	move.l	#MyTimerC,timer_c
	move.l	#RS232recv,RS232_rbf
	move.l	#MyKeybMidi,kbd_midi

	move.b	#$31,iera
	move.b	#$60,ierb
	move.b	#$31,imra
	move.b	#$60,imrb

	; echantillonnage
	bsr		InitGI
	move.b	#98,tadr

	; initialiser acia clavier
.wait2:
	btst	#1,kbdctl				; activer mode joystick
	beq.s	.wait2
	move.b	#$14,kbddata
.kflush:
	btst	#0,kbdctl
	beq.s	.kfok
	move.b	kbddata,D0
	bra.s	.kflush
.kfok:

	; initialiser acia midi
	move.b	#$95,midictl

	move	#$2300,SR

	rts

_TermSys::

	move	#$2700,SR

	moveq	#0,D0
	move.b	D0,iera
	move.b	D0,ierb
	move.b	D0,imra
	move.b	D0,imrb

	lea		savAlls,A0
	move.l	(A0)+,A1
	move.l	A1,USP
	move.l	(A0)+,D1		; D1 = old ssp
	move.b	(A0)+,iera
	move.b	(A0)+,ierb
	move.b	(A0)+,imra
	move.b	(A0)+,imrb
	move.b	(A0)+,vr
	move.b	(A0)+,tacr
	move.b	(A0)+,tbcr
	move.b	(A0)+,tcdcr
	move.l	(A0)+,$70		; VBL
	move.l	(A0)+,timer_a	; timer a
	move.l	(A0)+,timer_b	; timer b
	move.l	(A0)+,timer_c	; timer c
	move.l	(A0)+,RS232_rbf
	move.l	(A0)+,RS232_re
	move.l	(A0)+,RS232_tbe
	move.l	(A0)+,RS232_te
	move.l	(A0)+,kbd_midi
	move.l	(A0)+,RS232_cts
	move.l	(A0)+,RS232_dcd
	move.b	(A0)+,syncmode
	
.wait:
	btst	#1,kbdctl				; desactiver mode joystick
	beq.s	.wait
	move.b	#$15,kbddata

	; vider acia clavier

.kflush:
	btst	#0,kbdctl
	beq.s	.kfok
	move.b	kbddata,D0
	bra.s	.kflush
.kfok:

	move	#$2300,SR

	; retour en mode utilisateur
	move.l	D1,-(SP)
	move	#$20,-(SP)
	trap	#1
	addq.l	#6,SP

	rts

InitGI:
	lea     .data(PC),A0
	move.b  (A0)+,D0
.loop:
	move.b  D0,giselect
	move.b  (A0)+,giwrite
	move.b  (A0)+,D0
	bpl.s   .loop
	move.b	#8,giselect
	rts
.data:
	dc.b $00,$00,$01,$00,$02,$00,$03,$00
 	dc.b $04,$00,$05,$00,$06,$00,$07,$FF
	dc.b $08,$00,$09,$00,$0A,$00,$FF,$FF


MyVBL:
	move.l	A0,-(SP)
	move.l	D0,-(SP)

.chk_pal:
	move.l	_NewPalette(PC),D0	; changer palette de couleur ?
	beq.s	.aux				; non
	move.l	A1,-(SP)
	move.l	D0,A0
	lea		color0,A1			; A1 = palette hardware
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	clr.l	_NewPalette
	move.l	(SP)+,A1

.aux:
	jsr		AuxVBL(PC)

	move.l	(SP)+,D0
	move.l	(SP)+,A0
	rte

AuxVBL::
	jmp		NullProc

Null_IT:
	rte

MyTimerB:
	tst.l	_NewScreen					; 20 - basculer ecran ?
	beq.s	.bye						; 10 - non
	move.b	_NewScreen+2(PC),dbasel		; 20
	move.b	_NewScreen+1(PC),dbaseh		; 20
	clr.l	_NewScreen					; 28
.bye:
	rte									; 20

ScreenSync::

.wait1:
	btst	#1,kbdctl					; inhiber 6301
	beq.s	.wait1
	move.b	#$13,kbddata
	move.b	#3,midictl					; inhiber acia midi

	moveq	#0,D0						; inhiber interruption mfp
	move.b	D0,iera
	move.b	D0,ierb
	move.b	D0,imra
	move.b	D0,imrb
	move.b	D0,tbcr

	stop	#$2300						; basculer frequence
	bchg	#1,syncmode
	stop	#$2300
	move.b	#200,tbdr
	move.b	#8,tbcr

	move.b	#$31,iera					; permettre interruption mfp
	move.b	#$60,ierb
	move.b	#$31,imra
	move.b	#$60,imrb

.wait2:
	btst	#1,kbdctl					; reactiver 6301
	beq.s	.wait2
	move.b	#$11,kbddata
	move.b	#$95,midictl				; reactiver acia midi

	move.b	syncmode,D0					; obtenir nouvelle sync
	lsr		#1,D0
	andi	#1,D0
	move	D0,SyncMode
	rts

SyncMode::
	dc.w	0

**************************************************************************
*
*	Interruption clavier-midi

MyKeybMidi:

	movem.l	D0/D1/D3/A0,-(SP)

.loop:
	jsr		MidiRecv(PC)
	jsr		MyKeyb(PC)

	btst	#4,gpip			; interruption se maintient ?
	beq.s	.loop			; oui

	movem.l	(SP)+,D0/D1/D3/A0
	rte

**************************************************************************
*
*	Interruption MIDI

MidiRecv::
	jmp		midiNul

midiNul:
	move.b	midictl,D3		; interruption midi ?
	bpl.s	.bye			; non
	btst	#0,D3			; octet disponible ?
	beq.s	.ovrun			; non
	move.b	mididata,D0		; lire octet
.ovrun:
	btst	#5,D3			; overrun ?
	beq.s	.bye
	move.b	mididata,D0

.bye:
	rts

midiRecv:
	move.b	midictl,D3		; interruption midi ?
	bpl.s	.bye			; non
	btst	#0,D3			; octet disponible ?
	beq.s	.ovrun			; non
	lea		IOBuffer(PC),A0
	move	INWRITE(A0),D0
	move.b	mididata,INBUF(A0,D0)
	addq	#1,D0
	andi	#255,D0
	move	D0,INWRITE(A0)
	addq	#1,INSIZE(A0)
.ovrun:
	btst	#5,D3			; overrun ?
	beq.s	.bye
	move.b	mididata,D0
.bye:
	rts

**************************************************************************
*
*	Traiter interruption clavier

MyKeyb:
	move.b	kbdctl,D3		; interruption keyboard ?
	bpl.s	.bye			; non
	btst	#0,D3			; octet disponible ?
	beq.s	.ovrun			; non
	moveq	#0,D0
	move.b	kbddata,D0		; lire octet
	jsr		myKeyb(PC)		; traiter octet
.ovrun:
	btst	#5,D3			; overrun ?
	beq.s	.bye
	move.b	kbddata,D0
.bye:
	rts

**************************************************************************
*
*	octet 0x00 - 0x75 = cle enfoncee
*	octet 0x80 - 0xF5 = cle relachee
*	octet 0xF6 = lire memoire 6301 (7)
*	octet 0xF7 = etat de la souris, position absolue (5)
*	octet 0xF8 - 0xFB = etat de la souris, relative (2)
*	octet 0xFC = lire horloge (6)
*	octet 0xFD = etat des manettes de jeu (2)
*	octet 0xFE - 0xFF = manettes de jeu (1)

myKeyb:

	moveq	#0,D1
	lea		KeyStat(PC),A0
	move.b	(A0),D1
	jmp		.vects(PC,D1)
.vects:
	jmp		.anything(PC)
	jmp		.unused(PC)
	jmp		.unused(PC)
	jmp		.unused(PC)
	jmp		.unused(PC)
	jmp		.unused(PC)
	jmp		.joy0(PC)
	jmp		.joy1(PC)

.idx:	dc.b	04,08,12,12,12,12,16,20,24,28
.cnt:	dc.b	07,05,02,02,02,02,06,02,01,01

.anything:
	cmp.b	#$F6,D0			; packet ?
	bcs.s	.is_key			; non

	; il s'agit d'un packet
	subi	#$F6,D0			; initialiser traitement du packet
	move.b	.idx(PC,D0),(A0)+
	move.b	.cnt(PC,D0),(A0)+
	rts

	; cle enfoncee ou relachee
.is_key:
	tst.b	D0				; cle enfoncee ?
	bmi.s	.key_off		; non

.key_on:

.capslock:
	cmpi.b	#$3A,D0			; CapsLock ?
	bne.s	.1				; non
	eori.b	#1,120(A0)
.1:	move.b	D0,2(A0)		; derniere cle enfoncee
	st		4(A0,D0)		; activer indicateur correspondant
	rts

.key_off:
	subi	#$80,D0			; obtenir scan-code
	move.b	D0,3(A0)		; derniere cle relachee
	sf		4(A0,D0)		; raz indicateur correspondant
	rts

	; joystick 0
.joy0:
	clr		(A0)
	move.b	D0,D1
	andi	#15,D1
	move.b	.joyval(PC,D1),D1
	andi	#$80,D0
	lsr		#4,D0
	or		D0,D1
	ori		#$80,D1
	move.b	D1,132(A0)
	rts

	; joystick 1
.joy1:
	clr		(A0)
	move.b	D0,D1
	andi	#15,D1
	move.b	.joyval(PC,D1),D1
	andi	#$80,D0
	lsr		#4,D0
	or		D0,D1
	ori		#$80,D1
	move.b	D1,133(A0)
	rts

.joyval:
	dc.b	0,1,2,-1,3,4,2,-1,5,6,2,0

.even

	; packet dont j'ai rien a branler
.unused:
	subq.b	#1,1(A0)		; nombre d'octet a recevoir
	bgt.s	.bye			; reception du packet terminee
	clr		(A0)
.bye:
	rts

KeyStat::
	dc.b	0				;  0 - packet couramment recu
	dc.b	0				;  1 - nombre d'octet a recevoir
	dc.b	0				;  2 - derniere cle enfoncee
	dc.b	0				;  3 - derniere cle relachee
	dcb.b	120,0			;  4 - indicateurs de cle enfoncee
	dc.b	0				;120 - etat du CapsLock
	dcb.b	7,0				;121 - reserves

JoyData0:
	dc.b	$80				;132 - etat de la manette 0

JoyData1:
	dc.b	$80				;133 - etat de la manette 1

.even

**************************************************************************
*
*	Regarder si une cle est pressee au clavier
*
*	int LookKeybd( void );

LookKeybd::
	lea		KeyStat+KBD_KEYON(PC),A0
	move	SR,D1
	ori		#$700,SR
	move.b	(A0),D0			;  8
	clr.b	(A0)			; 12
	move	D1,SR			; 12
	ext		D0
	rts

**************************************************************************
*
*	Eliminer la derniere cle tape
*
*	void ClrKeybd( void );

ClrKeybd::
	lea		KeyStat+KBD_KEYON(PC),A0
	clr.b	(A0)
	rts

**************************************************************************
*
*	Obtenir le nom d'une cle selon scancode et langue
*
*	void GetKeyName( char *_str, int scancode )

GetKeyName::
	move.b	KeyNameIdx(PC,D0),D1
	bmi.s	.noname
.isname:
	lea		_KeyName(PC),A1
	ext		D1
	add 	Langue,D1
	add		D1,D1
	add		D1,D1
	move.l	(A1,D1),A1

.loop:
	move.b	(A1)+,(A0)+
	bne.s	.loop
	rts
.noname:
	move.l	_KeyTable,A1
	move.l	8(A1),A1
	move.b	(A1,D0),(A0)+
	clr.b	(A0)
	rts

**************************************************************************
*
*	Nom des cles selon scan-code

KeyNameIdx:
	dc.b	-1,0,-1,-1,-1,-1,-1,-1		; $00-$07
	dc.b	-1,-1,-1,-1,-1,-1,2,4		; $08-$0F
	dc.b	-1,-1,-1,-1,-1,-1,-1,-1		; $10-$17
	dc.b	-1,-1,-1,-1,6,8,-1,-1		; $18-$1F
	dc.b	-1,-1,-1,-1,-1,-1,-1,-1		; $20-$27
	dc.b	-1,-1,10,-1,-1,-1,-1,-1		; $28-$2F
	dc.b	-1,-1,-1,-1,-1,-1,12,-1		; $30-$37
	dc.b	14,16,18,20,22,24,26,28		; $38-$3F
	dc.b	30,32,34,36,38,-1,-1,40		; $40-$47
	dc.b	42,-1,90,46,-1,48,92,-1		; $48-$4F
	dc.b	44,-1,50,52,-1,-1,-1,-1		; $50-$57
	dc.b	-1,-1,-1,-1,-1,-1,-1,-1		; $58-$5F
	dc.b	-1,54,56,64,66,68,70,84		; $60-$67
	dc.b	86,88,78,80,82,72,74,76		; $68-$6F
	dc.b	60,62,58,-1,-1,-1,-1,-1		; $70-$77

_KeyName:
	dc.l	.esc,.esc				;  0
	dc.l	.backspace,.backspace	;  2
	dc.l	.tab,.tab				;  4
	dc.l	.return,.return			;  6
	dc.l	.control,.control		;  8
	dc.l	.lshift_e,.lshift_f		; 10
	dc.l	.rshift_e,.rshift_f		; 12
	dc.l	.alternate,.alternate	; 14
	dc.l	.space_e,.space_f		; 16
	dc.l	.capslock,.capslock		; 18
	dc.l	.f1,.f1					; 20
	dc.l	.f2,.f2					; 22
	dc.l	.f3,.f3					; 24
	dc.l	.f4,.f4					; 26
	dc.l	.f5,.f5					; 28
	dc.l	.f6,.f6					; 30
	dc.l	.f7,.f7					; 32
	dc.l	.f8,.f8					; 34
	dc.l	.f9,.f9					; 36
	dc.l	.f10,.f10				; 38
	dc.l	.clrhome,.clrhome		; 40
	dc.l	.up,.up					; 42
	dc.l	.down,.down				; 44
	dc.l	.left,.left				; 46
	dc.l	.right,.right			; 48
	dc.l	.insert,.insert			; 50
	dc.l	.delete,.delete			; 52
	dc.l	.undo,.undo				; 54
	dc.l	.help,.help				; 56
	dc.l	.enter,.enter			; 58
	dc.l	.pav0_e,.pav0_f			; 60
	dc.l	.pavpts_e,.pavpts_f		; 62
	dc.l	.pavparg_e,.pavparg_f	; 64
	dc.l	.pavpard_e,.pavpard_f	; 66
	dc.l	.pavdiv_e,.pavdiv_f		; 68
	dc.l	.pavmul_e,.pavmul_f		; 70
	dc.l	.pav1_e,.pav1_f			; 72
	dc.l	.pav2_e,.pav2_f			; 74
	dc.l	.pav3_e,.pav3_f			; 76
	dc.l	.pav4_e,.pav4_f			; 78
	dc.l	.pav5_e,.pav5_f			; 80
	dc.l	.pav6_e,.pav6_f			; 82
	dc.l	.pav7_e,.pav7_f			; 84
	dc.l	.pav8_e,.pav8_f			; 86
	dc.l	.pav9_e,.pav9_f			; 88
	dc.l	.pavmin_e,.pavmin_f		; 90
	dc.l	.pavpls_e,.pavpls_f		; 92

.esc:		dc.b	'ESC',0
.backspace:	dc.b	'BACKSPACE',0
.tab:		dc.b	'TAB',0
.return:	dc.b	'RETURN',0
.control:	dc.b	'CONTROL',0
.lshift_e:	dc.b	'LEFT SHIFT',0
.lshift_f:	dc.b	'SHIFT GAUCHE',0
.rshift_e:	dc.b	'RIGHT SHIFT',0
.rshift_f:	dc.b	'SHIFT DROIT',0
.alternate:	dc.b	'ALTERNATE',0
.space_e:	dc.b	'SPACE BAR',0
.space_f:	dc.b	'ESPACE',0
.capslock:	dc.b	'CAPSLOCK',0
.f1:		dc.b	'F1',0
.f2:		dc.b	'F2',0
.f3:		dc.b	'F3',0
.f4:		dc.b	'F4',0
.f5:		dc.b	'F5',0
.f6:		dc.b	'F6',0
.f7:		dc.b	'F7',0
.f8:		dc.b	'F8',0
.f9:		dc.b	'F9',0
.f10:		dc.b	'F10',0
.clrhome:	dc.b	'CLR/HOME',0
.up:		dc.b	1,0
.down:		dc.b	2,0
.left:		dc.b	3,0
.right:		dc.b	4,0
.insert:	dc.b	'INSERT',0
.delete:	dc.b	'DELETE',0
.undo:		dc.b	'UNDO',0
.help:		dc.b	'HELP',0
.enter:		dc.b	'ENTER',0
.pav0_e:	dc.b	'0 OF PAD',0
.pav0_f:	dc.b	'0 DU PAVê',0
.pav1_e:	dc.b	'1 OF PAD',0
.pav1_f:	dc.b	'1 DU PAVê',0
.pav2_e:	dc.b	'2 OF PAD',0
.pav2_f:	dc.b	'2 DU PAVê',0
.pav3_e:	dc.b	'3 OF PAD',0
.pav3_f:	dc.b	'3 DU PAVê',0
.pav4_e:	dc.b	'4 OF PAD',0
.pav4_f:	dc.b	'4 DU PAVê',0
.pav5_e:	dc.b	'5 OF PAD',0
.pav5_f:	dc.b	'5 DU PAVê',0
.pav6_e:	dc.b	'6 OF PAD',0
.pav6_f:	dc.b	'6 DU PAVê',0
.pav7_e:	dc.b	'7 OF PAD',0
.pav7_f:	dc.b	'7 DU PAVê',0
.pav8_e:	dc.b	'8 OF PAD',0
.pav8_f:	dc.b	'8 DU PAVê',0
.pav9_e:	dc.b	'9 OF PAD',0
.pav9_f:	dc.b	'9 DU PAVê',0
.pavpts_e:	dc.b	'. OF PAD',0
.pavpts_f:	dc.b	'. DU PAVê',0
.pavparg_e:	dc.b	'( OF PAD',0
.pavparg_f:	dc.b	'( DU PAVê',0
.pavpard_e:	dc.b	') OF PAD',0
.pavpard_f:	dc.b	') DU PAVê',0
.pavdiv_e:	dc.b	'/ OF PAD',0
.pavdiv_f:	dc.b	'/ DU PAVê',0
.pavmul_e:	dc.b	'* OF PAD',0
.pavmul_f:	dc.b	'* DU PAVê',0
.pavmin_e:	dc.b	'- OF PAD',0
.pavmin_f:	dc.b	'- DU PAVê',0
.pavpls_e:	dc.b	'+ OF PAD',0
.pavpls_f:	dc.b	'+ DU PAVê',0

.even

**************************************************************************
*
*	Gestion du port et midi RS-232

INREAD = 0
INWRITE = 2
INSIZE = 4
INBUF = 6

**************************************************************************
*
*	Installer routines modem ou midi selon mode
*
*	void MdmSetMode( int mode )
*
*	0 = modem
*	1 = midi

MdmMode::
	dc.w	0

MdmSetMode::
	tst		D0
	bne		.midi

.modem:
	move.l	#midiNul,MidiRecv+2
	move.l	#RS232recv,RS232_rbf

	move.l	#mdmWrByte,MdmWrByte+2
	move.l	#mdmWrStr,MdmWrStr+2
	move.l	#mdmWrBloc,MdmWrBloc+2
	move.l	#mdmRdByte,MdmRdByte+2
	move.l	#mdmRdClr,MdmRdClr+2

	move.l	#mdmConf,MdmConf+2
	move.l	#mdmConnect,MdmConnect+2
	move.l	#mdmReset,MdmReset+2

	bsr		MdmRdClr
	rts

.midi:
	move.l	#RS232nul,RS232_rbf
	move.l	#midiRecv,MidiRecv+2

	move.l	#midWrByte,MdmWrByte+2
	move.l	#midWrStr,MdmWrStr+2
	move.l	#midWrBloc,MdmWrBloc+2
	move.l	#midRdByte,MdmRdByte+2
	move.l	#midRdClr,MdmRdClr+2

	move.l	#midConf,MdmConf+2
	move.l	#midConnect,MdmConnect+2
	move.l	#midReset,MdmReset+2

	bsr		MdmRdClr
	rts

**************************************************************************
*
*	Verifier si le modem est en ligne

MdmConnect::
	jmp		mdmConnect

mdmConnect:
	btst	#1,gpip
	seq		D0
	andi	#1,D0
	rts

midConnect:
	moveq	#1,D0
	rts

**************************************************************************
*
*	Configurer modem : 0=1200, 1=2400
*
*	void MdmConf( int bauds );

MdmConf::
	jmp		mdmConf

mdmConf:
	clr.b	rsr				; inhiber rx et tx
	clr.b	tsr

	andi.b	#$F8,tcdcr		; arreter timer d
	move.b	.dr(PC,D0),tddr
	move.b	.cr(PC,D0),D1
	or.b	D1,tcdcr

	move.b	#$88,ucr

	move.b	#1,rsr			; reactiver rx et tx
	move.b	#1,tsr
	rts

.cr:	dc.b	1,1
.dr:	dc.b	16,8

midConf:
	rts

**************************************************************************
*
*	Interruption RS232 receive buffer full

RS232recv:
	btst	#7,rsr
	beq.s	.bye
	move	D0,-(SP)
	move.l	SP,USP
	lea		IOBuffer(PC),SP
	move	INWRITE(SP),D0
	move.b	udr,INBUF(SP,D0)
	addq	#1,D0
	andi	#255,D0
	move	D0,INWRITE(SP)
	addq	#1,INSIZE(SP)
	move.l	USP,SP
	move	(SP)+,D0
.bye:
	rte

RS232nul:
	btst	#7,rsr
	beq.s	.bye
	move.b	udr,.dummy
.bye:
	rte

.dummy:		dc.w	0

**************************************************************************
*
*	Remettre a zero le contenu du buffer de reception
*
*	void MdmRdClr( void )

MdmRdClr::
	jmp		mdmRdClr

mdmRdClr:
midRdClr:
	lea		IOBuffer(PC),A0
	clr		(A0)+
	clr		(A0)+
	clr		(A0)+
	rts

**************************************************************************
*
*	Lire un octet en provenance du port RS232
*
*	int MdmRdByte( void )

MdmRdByte::
	jmp		mdmRdByte

mdmRdByte:
midRdByte:
	lea		IOBuffer(PC),A0
	moveq	#-1,D0				; pas d'octet disponible par defaut
	tst		INSIZE(A0)			; octet disponible ?
	beq.s	.bye				; non
	moveq	#0,D0
	move	INREAD(A0),D1
	move.b	INBUF(A0,D1),D0		; lire octet
	addq	#1,D1
	andi	#255,D1
	move	D1,INREAD(A0)
	subq	#1,INSIZE(A0)
.bye:
	tst		D0
	rts

**************************************************************************
*
*	Transmettre un octet sur le port RS232
*
*	void MdmWrByte( char c )

MdmWrByte::
	jmp		mdmWrByte

mdmWrByte:
	btst	#7,tsr
	beq.s	mdmWrByte
	move.b	D0,udr
	rts

midWrByte:
	btst	#1,midictl
	beq.s	midWrByte
	move.b	D0,mididata
	rts

**************************************************************************
*
*	Transmettre une chaine de caractere au modem
*
*	void MdmWrStr( char *_str )
*
*	A0 = _str

MdmWrStr::
	jmp		mdmWrStr

mdmWrStr:
midWrStr:
.loop:
	move.b	(A0)+,D0
	beq.s	.bye
	bsr		MdmWrByte
	bra.s	.loop
.bye:
	rts

**************************************************************************
*
*	Transmettre un bloc d'octet au modem
*
*	int MdmWrBloc( char *_bloc, int len )
*
*	Entree
*		A0 = _bloc
*		D0 = len
*	Sortie
*		D0 = checksum des octets transmis

MdmWrBloc::
	jmp		mdmWrBloc

mdmWrBloc:
midWrBloc:
	moveq	#0,D2
	move	D0,D1
	bra.s	.next
.loop:
	move.b	(A0)+,D0
	add.b	D0,D2
	bsr		MdmWrByte
.next:
	dbf		D1,.loop
	move	D2,D0
	rts

**************************************************************************
*
*	Reinitialiser le modem (ou midi)
*
*	void MdmReset( void )

MdmReset::
	jmp		mdmReset

mdmReset:
	moveq	#'+',D0
	bsr		MdmWrByte
	move.l	#333,D0
	jsr		Delai
	moveq	#'+',D0
	bsr		MdmWrByte
	move.l	#333,D0
	jsr		Delai
	moveq	#'+',D0
	bsr		MdmWrByte
	move.l	#1000,D0
	jsr		Delai
	lea		.atz(PC),A0
	bsr		MdmWrStr
	move.l	#334,D0
	jsr		Delai
.bye:
	rts

.atz:
	dc.b	13,'ATZ',13,0

.even

midReset:
	rts

IOBuffer:
	dc.w	0	; inread
	dc.w	0	; inwrite
	dc.w	0	; insize
	dcb.b	256,0

.bss

savAlls:	ds.l	16

.end
