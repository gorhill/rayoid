**************************************************************************
*
*	Afficher un nombre dans les deux ecrans (6 chiffres significatifs)
*	x doit etre un multiple de 16
*
*	void DrawNumber( int x, int y, long val )
*
*	D0 = x
*	D1 = y
*	D2 = val

DrawNumber::

.SAVREGS reg A2/A3/A4/A5

	movem.l	#.SAVREGS,-(SP)

	lea		.work(PC),A5

	jsr		FindXYIdx(PC)		; D0 = adresse ecran
	movem.l	_Screens(PC),A1-A2	; A1-A2 = destination ecran
	adda	D0,A1
	adda	D0,A2

	lea		.str(PC),A0			; obtenir les chiffres
	moveq	#-1,D1
.dig6:
	subi.l	#100000,D2
	dbmi	D1,.dig6
	addi.l	#100000,D2
	not		D1
	move	D1,(A0)+
	moveq	#-1,D1		;  4
.dig5:
	subi.l	#10000,D2	;  8
	dbmi	D1,.dig5	; 10
	addi	#10000,D2	;  8
	not		D1			;  4
	move	D1,(A0)+	;  8
	moveq	#-1,D1
.dig4:
	subi	#1000,D2
	dbmi	D1,.dig4
	addi	#1000,D2
	not		D1
	move	D1,(A0)+
	moveq	#-1,D1
.dig3:
	subi	#100,D2
	dbmi	D1,.dig3
	addi	#100,D2
	not		D1
	move	D1,(A0)+
	moveq	#-1,D1
.dig2:
	subi	#10,D2
	dbmi	D1,.dig2
	addi	#10,D2
	not		D1
	move	D1,(A0)+
.dig1:
	move	D2,(A0)+
	lea		.str(PC),A0

	lea		DigitImg(PC),A3
	move.l	A3,A4
	move	(A0)+,D0
	lsl		#3,D0
	adda	D0,A3
	move	(A0)+,D0
	lsl		#3,D0
	adda	D0,A4
	moveq	#7,D0
.lp1:
	move.b	(A3),(A5)+
	move.b	(A4),(A5)+
	move.b	(A3)+,(A5)+
	move.b	(A4)+,(A5)+
	move.l	-(A5),D1
	move.l	D1,(A1)+
	move.l	D1,(A1)+
	move.l	D1,(A2)+
	move.l	D1,(A2)+
	lea		152(A1),A1
	lea		152(A2),A2
	dbf		D0,.lp1

	lea		-1272(A1),A1
	lea		-1272(A2),A2
	lea		DigitImg(PC),A3
	move.l	A3,A4
	move	(A0)+,D0
	lsl		#3,D0
	adda	D0,A3
	move	(A0)+,D0
	lsl		#3,D0
	adda	D0,A4
	moveq	#7,D0
.lp2:
	move.b	(A3),(A5)+
	move.b	(A4),(A5)+
	move.b	(A3)+,(A5)+
	move.b	(A4)+,(A5)+
	move.l	-(A5),D1
	move.l	D1,(A1)+
	move.l	D1,(A1)+
	move.l	D1,(A2)+
	move.l	D1,(A2)+
	lea		152(A1),A1
	lea		152(A2),A2
	dbf		D0,.lp2

	lea		-1272(A1),A1
	lea		-1272(A2),A2
	lea		DigitImg(PC),A3
	move.l	A3,A4
	move	(A0)+,D0
	lsl		#3,D0
	adda	D0,A3
	move	(A0)+,D0
	lsl		#3,D0
	adda	D0,A4
	moveq	#7,D0
.lp3:
	move.b	(A3),(A5)+
	move.b	(A4),(A5)+
	move.b	(A3)+,(A5)+
	move.b	(A4)+,(A5)+
	move.l	-(A5),D1
	move.l	D1,(A1)+
	move.l	D1,(A1)+
	move.l	D1,(A2)+
	move.l	D1,(A2)+
	lea		152(A1),A1
	lea		152(A2),A2
	dbf		D0,.lp3

	movem.l	(SP)+,#.SAVREGS
	rts

.str:
	dcb.w	8,0
.work:
	dcb.b	4,0

**************************************************************************
*
*	Afficher une chaine de caractere dans les deux ecrans
*
*	void _ShowStr( int xdes, int ydes, char *_str, int op )
*
*	int color = -1;
*
*	static char Colors[] = "0123456789abcdef";
*
*	while ( (c = *_str++) != 0 ) {
*		if ( c == '|' ) {
*			color = -1;
*			continue;
*			}
*		if ( c == ESC ) {
*			color = StrFindChar(Colors,*_str++);
*			continue;
*			}
*		DrawChar(xdes,ydes,(int)c,color);
*		xdes += 8;
*		}

_ShowStr::

.SAVREGS reg D3/D4/D5/D7/A3

	movem.l	#.SAVREGS,-(SP)
	move	D2,-(SP)

	move.l	A0,A3
	moveq	#0,D3
	moveq	#-1,D4
	move	D0,D5
	move	D1,D7

	bra.s	.next
.loop:
	cmpi	#'|',D3
	bne.s	.1
	moveq	#-1,D4
	bra.s	.next

.1:	cmpi	#'~',D3
	bne.s	.draw
	moveq	#0,D0
	move.b	(A3)+,D0
	lea		.colors(PC),A0
	jsr		StrFindChar
	move	D0,D4
	bra.s	.next

.draw:
	move	D4,-(SP)
	move	D3,D2
	move	D7,D1
	move	D5,D0
	bsr		DrawChar
	addq.l	#2,SP

	addq	#8,D5

.next:
	move.b	(A3)+,D3
	bne.s	.loop

	addq.l	#2,SP
	movem.l	(SP)+,#.SAVREGS
	rts

.colors:
	dc.b	'0123456789abcdef',0,0

.even

**************************************************************************
*
*	void DrawChar(x,y,c,color,op);
*
*	D0 = x
*	D1 = y
*	D2 = caractere
*	4(SP) = couleur, si -1, affiche tel quel
*	6(SP) = mode d'affichage, 0=replace, 1=or

DrawChar::

.SAVREGS reg A2/A3/A4

	movem.l	#.SAVREGS,-(SP)


	lea		CharMap(PC),A2
	move.b	(A2,D2),D2
	lsl		#3,D2

	lea		Fontes(PC),A0
	adda	D2,A0				; A0 = image du caractere

	move	D0,D2				; preserver x pour usage ulterieur

	jsr		FindXYIdx(PC)		; obtenir index ecran
	move.l	_Screens(PC),A1		; A1 = adresses ecran #0
	adda	D0,A1				; A1 = adresse destination
	lea		8(A1),A2			; A2 = mot suivant

	lea		.decal(PC),A3
	andi	#15,D2
	add		D2,D2
	add		D2,D2				; D2 = index sur routine selon decalage
	move.l	0(A3,D2),A3			; A3 = vecteur sur routine de decalage

	lea		.color(PC),A4
	move	3*4+4(SP),D2
	addq	#1,D2
	add		D2,D2
	add		D2,D2				; D2 = index sur routine selon couleur
	move.l	0(A4,D2),A4			; A4 = vecteur sur routine d'affichage selon couleur

	move	3*4+6(SP),D2
	add		D2,D2
	add		D2,D2				; D2 = index sur routine mode d'affichage
	jmp		.opvects(PC,D2)
.opvects:
	jmp		.replace(PC)
	jmp		.or(PC)

.replace:
	moveq	#7,D2
.repl_lp:
	moveq	#0,D0
	move.b	(A0)+,D0
	moveq	#-1,D1
	clr.b	D1
	jsr		(A3)
	lea		152(A1),A1
	lea		152(A2),A2
	dbf		D2,.repl_lp
	movem.l	(SP)+,#.SAVREGS
	rts

.or:
	moveq	#7,D2
.or_lp:
	moveq	#0,D0
	move.b	(A0)+,D0
	move.l	D0,D1
	not.l	D1
	jsr		(A3)
	lea		152(A1),A1
	lea		152(A2),A2
	dbf		D2,.or_lp
	movem.l	(SP)+,#.SAVREGS
	rts

.decal:
	dc.l	.dec_0,.dec_1,.dec_2,.dec_3,.dec_4,.dec_5,.dec_6,.dec_7
	dc.l	.dec_8,.dec_9,.dec_A,.dec_B,.dec_C,.dec_D,.dec_E,.dec_F
.color:
	dc.l	.col_2,.col_0,.col_1,.col_2,.col_3,.col_4,.col_5,.col_6
	dc.l	.col_7,.col_8,.col_9,.col_A,.col_B,.col_C,.col_D,.col_E
	dc.l	.col_F

.dec_0:
	rol		#8,D0
	rol		#8,D1
	jmp		(A4)
.dec_1:
	rol		#7,D0
	rol		#7,D1
	jmp		(A4)
.dec_2:
	rol		#6,D0
	rol		#6,D1
	jmp		(A4)
.dec_3:
	rol		#5,D0
	rol		#5,D1
	jmp		(A4)
.dec_4:
	rol		#4,D0
	rol		#4,D1
	jmp		(A4)
.dec_5:
	rol		#3,D0
	rol		#3,D1
	jmp		(A4)
.dec_6:
	rol		#2,D0
	rol		#2,D1
	jmp		(A4)
.dec_7:
	rol		#1,D0
	rol		#1,D1
	jmp		(A4)
.dec_8:
	jmp		(A4)
.dec_9:
	ror.l	#1,D0
	ror.l	#1,D1
	jmp		(A4)
.dec_A:
	ror.l	#2,D0
	ror.l	#2,D1
	jmp		(A4)
.dec_B:
	ror.l	#3,D0
	ror.l	#3,D1
	jmp		(A4)
.dec_C:
	ror.l	#4,D0
	ror.l	#4,D1
	jmp		(A4)
.dec_D:
	ror.l	#5,D0
	ror.l	#5,D1
	jmp		(A4)
.dec_E:
	ror.l	#6,D0
	ror.l	#6,D1
	jmp		(A4)
.dec_F:
	move.b	(A0)+,D0
	ror.l	#7,D0
	ror.l	#7,D1
	jmp		(A4)

.col_0:
	pea		.colbit_0(PC)
	pea		.colbit_0(PC)
	pea		.colbit_0(PC)
	jmp		.colbit_0(PC)

.col_1:
	pea		.colbit_0(PC)
	pea		.colbit_0(PC)
	pea		.colbit_0(PC)
	jmp		.colbit_1(PC)

.col_2:
	pea		.colbit_0(PC)
	pea		.colbit_0(PC)
	pea		.colbit_1(PC)
	jmp		.colbit_0(PC)

.col_3:
	pea		.colbit_0(PC)
	pea		.colbit_0(PC)
	pea		.colbit_1(PC)
	jmp		.colbit_1(PC)

.col_4:
	pea		.colbit_0(PC)
	pea		.colbit_1(PC)
	pea		.colbit_0(PC)
	jmp		.colbit_0(PC)

.col_5:
	pea		.colbit_0(PC)
	pea		.colbit_1(PC)
	pea		.colbit_0(PC)
	jmp		.colbit_1(PC)

.col_6:
	pea		.colbit_0(PC)
	pea		.colbit_1(PC)
	pea		.colbit_1(PC)
	jmp		.colbit_0(PC)

.col_7:
	pea		.colbit_0(PC)
	pea		.colbit_1(PC)
	pea		.colbit_1(PC)
	jmp		.colbit_1(PC)

.col_8:
	pea		.colbit_1(PC)
	pea		.colbit_0(PC)
	pea		.colbit_0(PC)
	jmp		.colbit_0(PC)

.col_9:
	pea		.colbit_1(PC)
	pea		.colbit_0(PC)
	pea		.colbit_0(PC)
	jmp		.colbit_1(PC)

.col_A:
	pea		.colbit_1(PC)
	pea		.colbit_0(PC)
	pea		.colbit_1(PC)
	jmp		.colbit_0(PC)

.col_B:
	pea		.colbit_1(PC)
	pea		.colbit_0(PC)
	pea		.colbit_1(PC)
	jmp		.colbit_1(PC)

.col_C:
	pea		.colbit_1(PC)
	pea		.colbit_1(PC)
	pea		.colbit_0(PC)
	jmp		.colbit_0(PC)

.col_D:
	pea		.colbit_1(PC)
	pea		.colbit_1(PC)
	pea		.colbit_0(PC)
	jmp		.colbit_1(PC)

.col_E:
	pea		.colbit_1(PC)
	pea		.colbit_1(PC)
	pea		.colbit_1(PC)
	jmp		.colbit_0(PC)

.col_F:
	pea		.colbit_1(PC)
	pea		.colbit_1(PC)
	pea		.colbit_1(PC)
	jmp		.colbit_1(PC)

.colbit_0:
	and		D1,(A1)+
	swap	D1
	and		D1,(A2)+
	swap	D1
	rts

.colbit_1:
	and		D1,(A1)
	or		D0,(A1)+
	swap	D1
	swap	D0
	and		D1,(A2)
	or		D0,(A2)+
	swap	D1
	swap	D0
	rts

CharMap:
	dc.b	$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F
	dc.b	$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$1A,$1B,$1C,$1D,$1E,$1F
	dc.b	' ','!','"','#','$','%','&',"'",'(',')','*','+',',','-','.','/'
	dc.b	'0','1','2','3','4','5','6','7','8','9',':',';','<','=','>','?'
	dc.b	'@','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O'
	dc.b	'P','Q','R','S','T','U','V','W','X','Y','Z','[','\\',']','^','_'
	dc.b	'`','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O'
	dc.b	'P','Q','R','S','T','U','V','W','X','Y','Z','{','|','}','~',$65
	dc.b	$66,'U',$67,'A','A',$6B,'A',$66,'E','E',$6C,$68,'I','I','A','A'
	dc.b	$67,$05,$05,'O','O','O','U','U','Y','O','U','C',$69,'Y',$6A,'F'
	dc.b	'A','I','O','U','N','N','A','O',$05,$05,$05,$05,$05,$05,$05,$05
	dc.b	'A','O','O','O',$05,$05,$6B,'A','O',$05,$05,$05,$05,$05,$05,$05

*	8 octets par caractere

Fontes::
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00

	dc.b	$10,$38,$7C,$FE,$38,$38,$38,$00 ; 1 - fleche haute
	dc.b	$38,$38,$38,$FE,$7C,$38,$10,$00 ; 2 - fleche basse
	dc.b	$10,$30,$7E,$FE,$7E,$30,$10,$00 ; 3 - fleche gauche
	dc.b	$10,$18,$FC,$FE,$FC,$18,$10,$00 ; 4 - fleche droite

	dc.b	$00,$00,$38,$28,$38,$00,$00,$00 ; o
	dc.b	$00,$00,$38,$28,$38,$00,$00,$00 ; o
	dc.b	$00,$00,$38,$28,$38,$00,$00,$00 ; o
	dc.b	$00,$00,$38,$28,$38,$00,$00,$00 ; o
	dc.b	$00,$00,$38,$28,$38,$00,$00,$00 ; o
	dc.b	$00,$00,$38,$28,$38,$00,$00,$00 ; o
	dc.b	$00,$00,$38,$28,$38,$00,$00,$00 ; o
	dc.b	$00,$00,$38,$28,$38,$00,$00,$00 ; o
	dc.b	$00,$00,$38,$28,$38,$00,$00,$00 ; o
	dc.b	$00,$00,$38,$28,$38,$00,$00,$00 ; o
	dc.b	$00,$00,$38,$28,$38,$00,$00,$00 ; o
	dc.b	$00,$00,$38,$28,$38,$00,$00,$00 ; o
	dc.b	$00,$00,$38,$28,$38,$00,$00,$00 ; o
	dc.b	$00,$00,$38,$28,$38,$00,$00,$00 ; o
	dc.b	$00,$00,$38,$28,$38,$00,$00,$00 ; o
	dc.b	$00,$00,$38,$28,$38,$00,$00,$00 ; o
	dc.b	$00,$00,$38,$28,$38,$00,$00,$00 ; o
	dc.b	$00,$00,$38,$28,$38,$00,$00,$00 ; o
	dc.b	$00,$00,$38,$28,$38,$00,$00,$00 ; o
	dc.b	$00,$00,$38,$28,$38,$00,$00,$00 ; o
	dc.b	$00,$00,$38,$28,$38,$00,$00,$00 ; o
	dc.b	$00,$00,$38,$28,$38,$00,$00,$00 ; o
	dc.b	$00,$00,$38,$28,$38,$00,$00,$00 ; o
	dc.b	$00,$00,$38,$28,$38,$00,$00,$00 ; o
	dc.b	$00,$00,$38,$28,$38,$00,$00,$00 ; o
	dc.b	$00,$00,$38,$28,$38,$00,$00,$00 ; o
	dc.b	$00,$00,$38,$28,$38,$00,$00,$00 ; o

	dc.b	$00,$00,$00,$00,$00,$00,$00,$00 ; espace
	dc.b	$38,$38,$38,$38,$38,$00,$38,$38 ; !
	dc.b	$6C,$6C,$6C,$00,$00,$00,$00,$00 ; "
	dc.b	$6C,$FE,$FE,$6C,$FE,$FE,$6C,$00 ; #
	dc.b	$18,$7C,$E0,$7C,$0E,$7C,$30,$00 ; $
	dc.b	$00,$66,$6E,$1C,$38,$76,$66,$00 ; %
	dc.b	$38,$6C,$38,$78,$EE,$FC,$76,$00 ; &
	dc.b	$18,$18,$30,$00,$00,$00,$00,$00 ; '
	dc.b	$0C,$38,$70,$70,$70,$38,$0C,$00 ; (
	dc.b	$60,$38,$1C,$1C,$1C,$38,$60,$00 ; )
	dc.b	$6C,$38,$FE,$FE,$38,$6C,$00,$00 ; *
	dc.b	$00,$18,$18,$7E,$7E,$18,$18,$00 ; +
	dc.b	$00,$00,$00,$00,$00,$18,$18,$30 ; ,
	dc.b	$00,$00,$00,$7E,$7E,$00,$00,$00 ; -
	dc.b	$00,$00,$00,$00,$00,$30,$30,$00 ; .
	dc.b	$02,$06,$0C,$18,$30,$60,$40,$00 ; /
DigitImg:
	dc.b	$7C,$FE,$EE,$EE,$EE,$FE,$7C,$00 ; 0
	dc.b	$38,$78,$38,$38,$38,$7C,$7C,$00 ; 1
	dc.b	$7C,$FE,$EE,$1C,$38,$7E,$FE,$00 ; 2
	dc.b	$7C,$7E,$0E,$3C,$0E,$FE,$FC,$00 ; 3
	dc.b	$0C,$EC,$EC,$EC,$FE,$FE,$0C,$00 ; 4
	dc.b	$FC,$FC,$E0,$FC,$0E,$FE,$7C,$00 ; 5
	dc.b	$7C,$FC,$E0,$FC,$EE,$FE,$7C,$00 ; 6
	dc.b	$FE,$FE,$1C,$3C,$38,$78,$78,$00 ; 7
	dc.b	$7C,$FE,$EE,$7C,$EE,$FE,$7C,$00 ; 8
	dc.b	$7C,$FE,$EE,$7E,$0E,$7E,$7C,$00 ; 9
	dc.b	$00,$38,$38,$00,$38,$38,$00,$00 ; :
	dc.b	$00,$38,$38,$00,$38,$38,$70,$00 ; ;
	dc.b	$0E,$1C,$38,$70,$38,$1C,$0E,$00 ; <
	dc.b	$00,$7E,$7E,$00,$7E,$7E,$00,$00 ; =
	dc.b	$70,$38,$1C,$0E,$1C,$38,$70,$00 ; >
	dc.b	$7C,$FE,$CE,$1C,$38,$00,$38,$38 ; ?
	dc.b	$7C,$E6,$EE,$EA,$EE,$E0,$7C,$00 ; @
	dc.b	$7C,$FE,$EE,$FE,$EE,$EE,$EE,$00 ; A
	dc.b	$FC,$FE,$EE,$FC,$EE,$FE,$FC,$00 ; B
	dc.b	$7C,$FE,$EE,$E0,$EE,$FE,$7C,$00 ; C
	dc.b	$FC,$FE,$EE,$EE,$EE,$FE,$FC,$00 ; D
	dc.b	$FE,$FE,$E0,$F8,$E0,$FE,$FE,$00 ; E
	dc.b	$FE,$FE,$E0,$F8,$E0,$E0,$E0,$00 ; F
	dc.b	$7E,$FE,$E0,$FE,$EE,$FE,$7E,$00 ; G
	dc.b	$EE,$EE,$EE,$FE,$EE,$EE,$EE,$00 ; H
	dc.b	$7C,$7C,$38,$38,$38,$7C,$7C,$00 ; I
	dc.b	$0E,$0E,$0E,$0E,$EE,$FE,$7C,$00 ; J
	dc.b	$EE,$EE,$FC,$F8,$FC,$EE,$EE,$00 ; K
	dc.b	$E0,$E0,$E0,$E0,$E0,$FE,$FE,$00 ; L
	dc.b	$EE,$FE,$FE,$D6,$EE,$EE,$EE,$00 ; M
	dc.b	$EE,$EE,$F6,$FE,$DE,$EE,$EE,$00 ; N
	dc.b	$7C,$FE,$EE,$EE,$EE,$FE,$7C,$00 ; O
	dc.b	$FC,$FE,$EE,$FE,$FC,$E0,$E0,$00 ; P
	dc.b	$7C,$FE,$EE,$EE,$EE,$FC,$76,$00 ; Q
	dc.b	$FC,$FE,$EE,$FC,$FE,$EE,$EE,$00 ; R
	dc.b	$7C,$FC,$E0,$7C,$0E,$FE,$FC,$00 ; S
	dc.b	$FE,$FE,$38,$38,$38,$38,$38,$00 ; T
	dc.b	$EE,$EE,$EE,$EE,$EE,$FE,$7C,$00 ; U
	dc.b	$EE,$EE,$EE,$EE,$FE,$7C,$38,$00 ; V
	dc.b	$EE,$EE,$EE,$D6,$FE,$FE,$EE,$00 ; W
	dc.b	$EE,$EE,$7C,$38,$7C,$EE,$EE,$00 ; X
	dc.b	$EE,$EE,$EE,$7C,$38,$38,$38,$00 ; Y
	dc.b	$FE,$FE,$DC,$38,$76,$FE,$FE,$00 ; Z
	dc.b	$7C,$70,$70,$70,$70,$70,$7C,$00 ; [
	dc.b	$80,$C0,$60,$30,$18,$0C,$04,$00 ; \
	dc.b	$7C,$1C,$1C,$1C,$1C,$1C,$7C,$00 ; ]
	dc.b	$00,$00,$00,$00,$00,$FC,$FC,$00 ; ^
	dc.b	$60,$70,$38,$18,$00,$00,$00,$00 ; _
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00 ; `

	dc.b	$0E,$18,$18,$30,$18,$18,$0E,$00 ; {
	dc.b	$18,$18,$18,$18,$18,$18,$18,$00 ; |
	dc.b	$70,$18,$18,$0C,$18,$18,$70,$00 ; }
	dc.b	$00,$62,$F2,$9E,$8C,$00,$00,$00 ; ~
	dc.b	$00,$18,$18,$3C,$3C,$7E,$7E,$00 ; delete
	dc.b	$7C,$FE,$EE,$E0,$FE,$7C,$10,$30 ; c cedille
	dc.b	$1C,$FE,$FE,$E0,$F8,$E0,$FE,$FE ; e accent aigu
	dc.b	$6C,$6C,$38,$38,$38,$7C,$7C,$00 ; i tremas
	dc.b	$38,$64,$60,$F8,$60,$FE,$FE,$00 ; livre sterling
	dc.b	$0C,$1E,$36,$3C,$66,$7E,$DC,$80 ; b allemand
	dc.b	$20,$10,$7C,$FE,$EE,$FE,$EE,$00 ; 6B - a accent grave
	dc.b	$70,$FE,$FE,$E0,$F8,$E0,$FE,$FE ; e accent grave

.even

.end
