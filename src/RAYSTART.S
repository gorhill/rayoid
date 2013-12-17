
.include 'H:\\STRUCT_S.IN'

**************************************************************************
*
*	RAYSTART.S

Start:
	bra.s   Start0

*	Stack size entry
	dc.l	_StkSize

Start0:
	move.l  4(A7),A3

	move.l	A3,_BasePage

*	base page size includes stack size
	move.l	BP_TEXTSIZE(A3),A0
	adda.l	BP_DATASIZE(A3),A0
	adda.l	BP_BSSSIZE(A3),A0
	adda	#256,A0

	move.l	A3,D0
	add.l	A0,D0
	andi.b	#$FC,D0
	move.l	D0,A7

	move.l	A0,-(A7)
	move.l	A3,-(A7)
	clr		-(A7)
	move	#74,-(A7)
	trap	#1
	lea		12(A7),A7

	jsr		main(PC)

	move	D0,-(SP)
	move	#76,-(A7)
	trap	#1

.data

DataVar::
	dc.w	0						;  0 - zero
	dc.w	0						;  2 - sum
	dc.w	0						;  4 - xor
	dc.w	DataEnd - DataBeg		;  6 - size

DataBeg:							;  8 - donnees

Langue::
	dc.w	1

S1Stats::
	dc.l	500
	dc.b	'Ray'
	dcb.b	13,0
	dcb.b	40,0

C2Stats::
	dc.w	0		; nombre de victoire
	dc.w	0		; nombre de defaite
	dc.w	0		; rang
	dc.b	'Raymond Hill',0,0,0,0	; nom ou alias du joueur

S1KeyCfg::
	dc.b	$2C,$2D,$36,$35,$34,$39,$01,$00

S2TKey1Cfg::
	dc.b	$1E,$1F,$22,$21,$20,$0F,$01,$00

S2TKey2Cfg::
	dc.b	$50,$4D,$6C,$6B,$6A,$72,$01,$00

S2MKey1Cfg::
	dc.b	$2C,$2D,$36,$35,$34,$39,$01,$00

C2KeyCfg::
	dc.b	$2C,$2D,$36,$35,$34,$39,$53,$3B
	dc.b	$3C,$32,$52,$13,$44,$26,$00,$00

CopyRight::
	dc.b	'~cCopyright 1992 Raymond Hill',0
	dc.b	'Programme : RAYOID.PRG'
	dc.b	'Fichiers connexes : RAYOID.FRA et RAYOID.ENG'
	dc.b	'Auteur : Raymond Hill'
	dc.b	'Copyright 1992'

	.even

OwnerE:
	dcb.b	32,0
OwnerF:
	dcb.b	32,0

	.even

DataEnd:

_Owner::
	dc.l	OwnerE
	dc.l	OwnerF

errno::
	dc.w	0

.even

.bss

_BasePage::
	ds.l	1

.end
