
.include 'H:\\STRUCT_S.IN'

**************************************************************************
*
*	DATAVAR.S
*	Raymond Hill
*	Gestion des parametres variables (hi score, clavier, etc)

**************************************************************************
*
*	Verifier si les donnees de configuration sont valides

DataCheck::

	move	D3,-(SP)

	lea		DataVar,A0
	lea		8(A0),A1		; A1 = donnees
	moveq	#0,D0			; D0 = sum
	moveq	#0,D1			; D1 = xor
	move	6(A0),D2		; D2 = size en octet
	lsr		#1,D2			; D2 = size en mot
	subq	#1,D2			; ajuster pour dbf
.loop:
	move	(A1)+,D3
	add		D3,D0
	eor		D3,D1
	dbf		D2,.loop

	move	(SP)+,D3

	swap	D0
	move	D1,D0			; D0 = nouvelle valeur
	move.l	2(A0),D1		; D1 = valeur originale
	move.l	D0,2(A0)		; sauvegarde nouvelle valeur
	cmp.l	D0,D1			; changement detecte ?
	sne		D0
	andi	#1,D0
	rts

**************************************************************************
*
*	Reinitialiser les donnees de configuration
*
*	void DataClear( void );

DataClear::
	lea		DataVar+2,A0
	clr.l	(A0)+
	addq.l	#4,A0
	moveq	#82,D0
	jsr		MemClear(PC)
	rts

**************************************************************************
*
*	Decrypter la zone de donnees de configuration

DataDecrypt::
	lea		DataVar,A0

	tst		(A0)				; decryptage necessaire ?
	beq.s	.bye				; non

	move	6(A0),D1			; nombre d'octet a decrypter
	subq	#1,D1				; ajuster pour dbf
	lea		8(A0),A1			; zone a decrypter

	move.l	#-'RHIL',-(SP)		; code d'encryptage

	move.l	SP,A0
	moveq	#0,D0
.loop:
	move.b	0(A0,D0),D2
	sub.b	D2,(A1)+
	addq	#1,D0
	andi	#3,D0
	dbf		D1,.loop

	addq.l	#4,SP
.bye:
	rts

**************************************************************************
*
*	Encrypter la zone de donnees de configuration

DataEncrypt::
	lea		DataVar,A0

	tst		(A0)				; encryptage necessaire ?
	beq.s	.bye				; non

	move	6(A0),D1			; nombre d'octet a encrypter
	subq	#1,D1				; ajuster pour dbf
	lea		8(A0),A1			; zone a encrypter

	move.l	#-'RHIL',-(SP)		; code d'encryptage

	move.l	SP,A0
	moveq	#0,D0
.loop:
	move.b	0(A0,D0),D2
	add.b	D2,(A1)+
	addq	#1,D0
	andi	#3,D0
	dbf		D1,.loop

	addq.l	#4,SP
.bye:
	rts

.end
