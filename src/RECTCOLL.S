
.include 'h:\\struct_s.in'

**************************************************************************
*
*	Routines de detection de collision a repetition
*
*	void CollConf( GRECT *_in )
*		Configurer la routine de detection de collision
*
*	int CollOr( GRECT *_in )
*		Au moins un cote du rectangle resultant doit etre plus grand
*		ou egal a 3 pixels pour qu'une collision soit detectee.
*
*	int CollAnd( GRECT *_in )
*		Chacun des cotes du rectangle resultant doit etre plus grand
*		ou egal a 3 pixels pour qu'une collision soit detectee.
*
*	Les donnees sont en format [x1,y1-x2,y2[

CollConf::
	lea		CollFrame(PC),A1	;  8 - x2,y2,x1,y1
	move.l	4(A0),(A1)+			; 24
	move.l	(A0),(A1)+			; 20
	rts							; 16
								; = 8.5 us
CollFrame::
	dcb.w	4,0

CollOr::

	lea		CollFrame(PC),A1	;  8 - A1 = bx2,by2,bx1,by1

	; verifier que les deux boites se touchent en procedant par
	; elimination :
	;    ax2 < bx1 ou ay2 < by1 ou ax1 > bx2 ou ay1 > by2

	cmpm	(A1)+,(A0)+		; 12 - ax1 >= bx2 ?
	blt.s	.ok1			; 10 - non
	moveq	#0,D0			;  4
	rts						; 16
.ok1:
	cmpm	(A1)+,(A0)+		; 12 - ay1 >= by2 ?
	blt.s	.ok2			; 10 - non
	moveq	#0,D0			;  4
	rts						; 16
.ok2:
	cmpm	(A1)+,(A0)+		; 12 - ax2 <= bx1 ?
	bgt.s	.ok3			; 10 - non
	moveq	#0,D0			;  4
	rts						; 16
.ok3:
	cmpm	(A1)+,(A0)+		; 12 - ay2 <= by1 ?
	bgt.s	.ok4			; 10 - non
	moveq	#0,D0			;  4
	rts						; 16
.ok4:

	; si on arrive ici, c'est que les deux boites se touchent
	; d'une facon ou d'une autre

_CollOr::

	subq.l	#8,A0			;  8
	subq.l	#8,A1			;  8

.checkw:
	; determiner plus grand x1
.pgx1:
	move	(A0),D0			;  8 - D0 = ax1
	move	4(A1),D2		; 12 - D2 = bx1
	cmp		D2,D0			;  4
	bge.s	.ppx2			; 10
	move	D2,D0			;  4
	; determiner plus petit x2
.ppx2:
	move	4(A0),D1		; 12 - D1 = ax2
	move	(A1),D2			;  8 - D2 = bx2
	cmp		D2,D1			;  4
	ble.s	.calcw			; 10
	move	D2,D1			;  4
	; determiner largeur : ppx2 - pgx1 + 1
.calcw:
	sub		D0,D1			;  4
	subq	#3,D1			;  4
	bmi.s	.checkh			; 10
	moveq	#1,D0			;  4
	rts						; 16

.checkh:
	; determiner plus grand y1
.pgy1:
	move	2(A0),D0		; 12 - D0 = ay1
	move	6(A1),D2		; 12 - D2 = by1
	cmp		D2,D0			;  4
	bge.s	.ppy2			; 10
	move	D2,D0			;  4
	; determiner plus petit y2
.ppy2:
	move	6(A0),D1		; 12 - D1 = ay2
	move	2(A1),D2		; 12 - D2 = by2
	cmp		D2,D1			;  4
	ble.s	.calch			; 10
	move	D2,D1			;  4
	; determiner hauteur : ppy2 - pgy1 + 1
.calch:
	sub		D0,D1			;  4
	subq	#3,D1			;  4
	bmi.s	.nocoll			; 10
	moveq	#1,D0			;  4
	rts						; 16

.nocoll:
	moveq	#0,D0
	rts


CollAnd::

	; mode ET

	lea		CollFrame(PC),A1	;  8 - A1 = bx2,by2,bx1,by1

	; verifier que les deux boites se touchent en procedant par
	; elimination :
	;    ax2 < bx1 ou ay2 < by1 ou ax1 > bx2 ou ay1 > by2

	cmpm	(A1)+,(A0)+		; 12
	blt.s	.ok1			; 10
	moveq	#0,D0			;  4
	rts						; 16
.ok1:
	cmpm	(A1)+,(A0)+		; 12
	blt.s	.ok2			; 10
	moveq	#0,D0			;  4
	rts						; 16
.ok2:
	cmpm	(A1)+,(A0)+		; 12
	bgt.s	.ok3			; 10
	moveq	#0,D0			;  4
	rts						; 16
.ok3:
	cmpm	(A1)+,(A0)+		; 12
	bgt.s	.ok4			; 10
	moveq	#0,D0			;  4
	rts						; 16
.ok4:

	; si on arrive ici, c'est que les deux boites se touchent
	; d'une facon ou d'une autre

	subq.l	#8,A0			;  8
	subq.l	#8,A1			;  8

.checkw:
	; determiner plus grand x1
.pgx1:
	move	(A0),D0			;  8 - D0 = ax1
	move	4(A1),D2		; 12 - D2 = bx1
	cmp		D2,D0			;  4
	bge.s	.ppx2			; 10
	move	D2,D0			;  4 - D0 = plus grand x1
	; determiner plus petit x2
.ppx2:
	move	4(A0),D1		;  8 - D1 = ax2
	move	(A1),D2			;  8 - D2 = bx2
	cmp		D2,D1			;  4
	ble.s	.calcw			; 10
	move	D2,D1			;  4 - D1 = plus petit x2
	; determiner largeur : ppx2 - pgx1 + 1
.calcw:
	sub		D0,D1			;  4
	subq	#3,D1			;  4
	bpl.s	.checkh			; 10
	moveq	#0,D0			;  4
	rts

.checkh:
	; determiner plus grand y1
.pgy1:
	move	2(A0),D0		; 12 - D0 = ay1
	move	6(A1),D2		; 12 - D2 = by1
	cmp		D2,D0			;  4
	bge.s	.ppy2			; 10
	move	D2,D0			;  4
	; determiner plus petit y2
.ppy2:
	move	6(A0),D1		; 12 - D1 = ay2
	move	2(A1),D2		; 12 - D2 - by2
	cmp		D2,D1			;  4
	ble.s	.calch			; 10
	move	D2,D1			;  4
	; determiner hauteur : ppy2 - pgy1 + 1
.calch:
	sub		D0,D1			;  4
	subq	#3,D1			;  4
	bmi.s	.nocoll			; 10
	moveq	#1,D0			;  4
	rts						; 16

.nocoll:
	moveq	#0,D0			;  4
	rts						; 16

.end
