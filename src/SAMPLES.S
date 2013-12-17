**************************************************************************
*
*	Fichier
*		SAMPLES.S
*	Auteur
*		Raymond Hill
*	Derniere Modification
*		9 juin 1992
*	Contenu
*		Routines d'echantillonnage. La table d'echantillonnage a ete
*		obtenu du fichier NT_COMP.LZH, logiciel du domaine publique.
*		Les routines sont concues et ecrites par Raymond Hill.

.include "atari.s"

.text

**************************************************************************
*
*	Restitution de son echantillonne
*
*	A6  est EXCLUSIVEMENT reserve a l'echantillonnage
*	D6  est EXCLUSIVEMENT reserve comme registre de travail pour les
*		interruptions MFP
*	USP est EXCLUSIVEMENT reserve comme registre de sauvegarde pour les
*		interruptions MFP
*
*	La routine de restitution necessite 184 cycles par interruption.
*	Pour une frequence de restitution de 6269hz (tacr=4, tadr=98),
*	la routine occupe 14.42% du temps processeur.
*
*	L'interruption Timer C s'occupe a detecter la fin de l'echantillon.
*	La frequence du Timer C est fixe a 200 hz. Par consequent, 48 octets
*	de niveau 0 sont rajoute a la fin de chaque echantillon.

TTSPL = 0
SPLPRIOR = 2
SPLLOOP = 4
SPLBEG = 6
SPLEND = 10

**************************************************************************
*
*	Echantillonnage

	; A0 = pointeur sur la structure SAMPLE
	; D0 = priorite	(D0 >= pour etre joue)
	; D1 = frequence
STSplOn:
	lea		SplParms(PC),A1

	cmp		SPLPRIOR(A1),D0
	blt.s	.bye

	clr.b	tacr			; arreter timer a et c
	move.l	#MyTimerC,timer_c

	move	D0,SPLPRIOR(A1)	; sauvegarder priorite courante

	move	(A0)+,D0
	move.l	(A0)+,A0
	move.l	A0,A6
	move.l	A0,SPLBEG(A1)
	adda	D0,A0
	move.l	A0,SPLEND(A1)

	move.b	D1,tadr			; amorcer interruptions echantillonnage
	move.l	#SplTimerC,timer_c
	move.b	#1,tacr
.bye:
	rts

STSplOff:
	clr.b	tacr
	move.l	#MyTimerC,timer_c
	lea		SplParms(PC),A1
	clr		SPLPRIOR(A1)
	clr		SPLLOOP(A1)
	rts

	; A0 = pointeur sur la structure SAMPLE
	; D0 = priorite
	; D1 = frequence (non utilise pour le dma TT)
TTSplOn:
	move.b	dmasnd+1,D2
	andi	#3,D2
	bne.s	.1
	clr		SplPrior

.1:	cmp		SplPrior(PC),D0
	blt.s	.bye

	move	D0,SplPrior

	subq.l	#4,SP
	move	(A0)+,D0
	move.l	(A0)+,A0
	move.l	A0,(SP)
	lea		1(SP),A1
	move.b	(A1)+,dmasnd+3		; lo base ptr
	move.b	(A1)+,dmasnd+5		; mid base ptr
	move.b	(A1)+,dmasnd+7		; hi base ptr
	adda	D0,A0
	move.l	A0,(SP)
	lea		1(SP),A1
	move.b	(A1)+,dmasnd+15		; hi base ptr
	move.b	(A1)+,dmasnd+17		; mid base ptr
	move.b	(A1)+,dmasnd+19		; lo base ptr
	clr.b	dmasnd+1			; force le sampling a off
	move.b	#$80,dmasnd+33		; mono + 6135 Khz
	move.b	#1,dmasnd+1			; debute le playback
	addq.l	#4,SP
.bye:
	rts

TTSplOff:
	clr.b	dmasnd+1			; force le sampling a off
	clr		SplPrior
	rts

_SplOnProc::
	dc.l	STSplOn
	dc.l	TTSplOn
_SplOffProc::
	dc.l	STSplOff
	dc.l	TTSplOff

SplOn::
	jmp		STSplOn
SplOff::
	jmp		STSplOff

SplParms:

TTSpl::			dc.w	0	; 0
SplPrior::		dc.w	0	; 2
SplLoop::		dc.w	0	; 4
_SampleBeg:		dc.l	0	; 6
_SampleEnd:		dc.l	0	; 10

**************************************************************************
*
*	Detecter la fin d'un echantillon couramment en restitution

MyTimerC::						; 44
	addq.l	#1,_hz_200			; 24
	rte							; 20

SplTimerC:
	addq.l	#1,_hz_200			; 24

	cmpa.l	_SampleEnd(PC),A6	; 18 - fin de l'echantillon ?
	bcc.s	.stop				;  8 - oui
	rte							; 20

.stop:
	move	SplLoop(PC),D6		; 12 - boucler ?
	bne.s	.loop				;  8 - oui
	clr.b	tacr				; 16 - arreter timer a
	move.l	#MyTimerC,timer_c	; 24
	clr		SplPrior			; 20 - remettre priorite a zero
	rte							; 20

.loop:
	move.l	_SampleBeg(PC),A6	; 16
	rte							; 20

**************************************************************************
*
*	Restituer un echantillon sonore

MyTimerA::					; 44
	move.l	SP,USP			;  4
	lea		giselect,SP		;  8
	moveq	#0,D6			;  4
	move.b	(A6)+,D6		;  8
	add		D6,D6			;  4
	add		D6,D6			;  4
	jmp		.vects(PC,D6)	; 14
.vects:
	jmp		.000(PC)		; 10
	jmp		.001(PC)
	jmp		.002(PC)
	jmp		.003(PC)
	jmp		.004(PC)
	jmp		.005(PC)
	jmp		.006(PC)
	jmp		.007(PC)
	jmp		.008(PC)
	jmp		.009(PC)
	jmp		.010(PC)
	jmp		.011(PC)
	jmp		.012(PC)
	jmp		.013(PC)
	jmp		.014(PC)
	jmp		.015(PC)
	jmp		.016(PC)
	jmp		.017(PC)
	jmp		.018(PC)
	jmp		.019(PC)
	jmp		.020(PC)
	jmp		.021(PC)
	jmp		.022(PC)
	jmp		.023(PC)
	jmp		.024(PC)
	jmp		.025(PC)
	jmp		.026(PC)
	jmp		.027(PC)
	jmp		.028(PC)
	jmp		.029(PC)
	jmp		.030(PC)
	jmp		.031(PC)
	jmp		.032(PC)
	jmp		.033(PC)
	jmp		.034(PC)
	jmp		.035(PC)
	jmp		.036(PC)
	jmp		.037(PC)
	jmp		.038(PC)
	jmp		.039(PC)
	jmp		.040(PC)
	jmp		.041(PC)
	jmp		.042(PC)
	jmp		.043(PC)
	jmp		.044(PC)
	jmp		.045(PC)
	jmp		.046(PC)
	jmp		.047(PC)
	jmp		.048(PC)
	jmp		.049(PC)
	jmp		.050(PC)
	jmp		.051(PC)
	jmp		.052(PC)
	jmp		.053(PC)
	jmp		.054(PC)
	jmp		.055(PC)
	jmp		.056(PC)
	jmp		.057(PC)
	jmp		.058(PC)
	jmp		.059(PC)
	jmp		.060(PC)
	jmp		.061(PC)
	jmp		.062(PC)
	jmp		.063(PC)
	jmp		.064(PC)
	jmp		.065(PC)
	jmp		.066(PC)
	jmp		.067(PC)
	jmp		.068(PC)
	jmp		.069(PC)
	jmp		.070(PC)
	jmp		.071(PC)
	jmp		.072(PC)
	jmp		.073(PC)
	jmp		.074(PC)
	jmp		.075(PC)
	jmp		.076(PC)
	jmp		.077(PC)
	jmp		.078(PC)
	jmp		.079(PC)
	jmp		.080(PC)
	jmp		.081(PC)
	jmp		.082(PC)
	jmp		.083(PC)
	jmp		.084(PC)
	jmp		.085(PC)
	jmp		.086(PC)
	jmp		.087(PC)
	jmp		.088(PC)
	jmp		.089(PC)
	jmp		.090(PC)
	jmp		.091(PC)
	jmp		.092(PC)
	jmp		.093(PC)
	jmp		.094(PC)
	jmp		.095(PC)
	jmp		.096(PC)
	jmp		.097(PC)
	jmp		.098(PC)
	jmp		.099(PC)
	jmp		.100(PC)
	jmp		.101(PC)
	jmp		.102(PC)
	jmp		.103(PC)
	jmp		.104(PC)
	jmp		.105(PC)
	jmp		.106(PC)
	jmp		.107(PC)
	jmp		.108(PC)
	jmp		.109(PC)
	jmp		.110(PC)
	jmp		.111(PC)
	jmp		.112(PC)
	jmp		.113(PC)
	jmp		.114(PC)
	jmp		.115(PC)
	jmp		.116(PC)
	jmp		.117(PC)
	jmp		.118(PC)
	jmp		.119(PC)
	jmp		.120(PC)
	jmp		.121(PC)
	jmp		.122(PC)
	jmp		.123(PC)
	jmp		.124(PC)
	jmp		.125(PC)
	jmp		.126(PC)
	jmp		.127(PC)
	jmp		.128(PC)
	jmp		.129(PC)
	jmp		.130(PC)
	jmp		.131(PC)
	jmp		.132(PC)
	jmp		.133(PC)
	jmp		.134(PC)
	jmp		.135(PC)
	jmp		.136(PC)
	jmp		.137(PC)
	jmp		.138(PC)
	jmp		.139(PC)
	jmp		.140(PC)
	jmp		.141(PC)
	jmp		.142(PC)
	jmp		.143(PC)
	jmp		.144(PC)
	jmp		.145(PC)
	jmp		.146(PC)
	jmp		.147(PC)
	jmp		.148(PC)
	jmp		.149(PC)
	jmp		.150(PC)
	jmp		.151(PC)
	jmp		.152(PC)
	jmp		.153(PC)
	jmp		.154(PC)
	jmp		.155(PC)
	jmp		.156(PC)
	jmp		.157(PC)
	jmp		.158(PC)
	jmp		.159(PC)
	jmp		.160(PC)
	jmp		.161(PC)
	jmp		.162(PC)
	jmp		.163(PC)
	jmp		.164(PC)
	jmp		.165(PC)
	jmp		.166(PC)
	jmp		.167(PC)
	jmp		.168(PC)
	jmp		.169(PC)
	jmp		.170(PC)
	jmp		.171(PC)
	jmp		.172(PC)
	jmp		.173(PC)
	jmp		.174(PC)
	jmp		.175(PC)
	jmp		.176(PC)
	jmp		.177(PC)
	jmp		.178(PC)
	jmp		.179(PC)
	jmp		.180(PC)
	jmp		.181(PC)
	jmp		.182(PC)
	jmp		.183(PC)
	jmp		.184(PC)
	jmp		.185(PC)
	jmp		.186(PC)
	jmp		.187(PC)
	jmp		.188(PC)
	jmp		.189(PC)
	jmp		.190(PC)
	jmp		.191(PC)
	jmp		.192(PC)
	jmp		.193(PC)
	jmp		.194(PC)
	jmp		.195(PC)
	jmp		.196(PC)
	jmp		.197(PC)
	jmp		.198(PC)
	jmp		.199(PC)
	jmp		.200(PC)
	jmp		.201(PC)
	jmp		.202(PC)
	jmp		.203(PC)
	jmp		.204(PC)
	jmp		.205(PC)
	jmp		.206(PC)
	jmp		.207(PC)
	jmp		.208(PC)
	jmp		.209(PC)
	jmp		.210(PC)
	jmp		.211(PC)
	jmp		.212(PC)
	jmp		.213(PC)
	jmp		.214(PC)
	jmp		.215(PC)
	jmp		.216(PC)
	jmp		.217(PC)
	jmp		.218(PC)
	jmp		.219(PC)
	jmp		.220(PC)
	jmp		.221(PC)
	jmp		.222(PC)
	jmp		.223(PC)
	jmp		.224(PC)
	jmp		.225(PC)
	jmp		.226(PC)
	jmp		.227(PC)
	jmp		.228(PC)
	jmp		.229(PC)
	jmp		.230(PC)
	jmp		.231(PC)
	jmp		.232(PC)
	jmp		.233(PC)
	jmp		.234(PC)
	jmp		.235(PC)
	jmp		.236(PC)
	jmp		.237(PC)
	jmp		.238(PC)
	jmp		.239(PC)
	jmp		.240(PC)
	jmp		.241(PC)
	jmp		.242(PC)
	jmp		.243(PC)
	jmp		.244(PC)
	jmp		.245(PC)
	jmp		.246(PC)
	jmp		.247(PC)
	jmp		.248(PC)
	jmp		.249(PC)
	jmp		.250(PC)
	jmp		.251(PC)
	jmp		.252(PC)
	jmp		.253(PC)
	jmp		.254(PC)
	jmp		.255(PC)

*	( 256 - 56 segments ) x 22 octets par segment = 4400 octets

.000:
.001:
	move.l	#$080C090B,D6	; 12 - 6
	movep.l	D6,0(SP)		; 24 - 4
	move	#$0A09,D6		;  8 - 4
	movep	D6,0(SP)		; 16 - 4
	move.l	USP,SP			;  4 - 2
	rte						; 20 - 2
.002:
	move.l	#$080D0908,D6
	movep.l	D6,0(SP)
	move	#$0A08,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.003:
	move.l	#$080B090B,D6
	movep.l	D6,0(SP)
	move	#$0A0B,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.004:
	move.l	#$080D0909,D6
	movep.l	D6,0(SP)
	move	#$0A05,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.005:
	move.l	#$080C090B,D6
	movep.l	D6,0(SP)
	move	#$0A08,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.006:
	move.l	#$080D0909,D6
	movep.l	D6,0(SP)
	move	#$0A02,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.007:
	move.l	#$080D0908,D6
	movep.l	D6,0(SP)
	move	#$0A06,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.008:
	move.l	#$080C090B,D6
	movep.l	D6,0(SP)
	move	#$0A07,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.009:
	move.l	#$080D0907,D6
	movep.l	D6,0(SP)
	move	#$0A07,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.010:
	move.l	#$080C090B,D6
	movep.l	D6,0(SP)
	move	#$0A06,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.011:
	move.l	#$080C090A,D6
	movep.l	D6,0(SP)
	move	#$0A09,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.012:
	move.l	#$080B090B,D6
	movep.l	D6,0(SP)
	move	#$0A0A,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.013:
	move.l	#$080C090B,D6
	movep.l	D6,0(SP)
	move	#$0A02,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.014:
	move.l	#$080C090B,D6
	movep.l	D6,0(SP)
	move	#$0A00,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.015:
	move.l	#$080C090A,D6
	movep.l	D6,0(SP)
	move	#$0A08,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.016:
	move.l	#$080D0906,D6
	movep.l	D6,0(SP)
	move	#$0A04,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.017:
	move.l	#$080D0905,D6
	movep.l	D6,0(SP)
	move	#$0A05,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.018:
	move.l	#$080D0905,D6
	movep.l	D6,0(SP)
	move	#$0A04,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.019:
	move.l	#$080C0909,D6
	movep.l	D6,0(SP)
	move	#$0A09,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.020:
	move.l	#$080D0904,D6
	movep.l	D6,0(SP)
	move	#$0A03,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.021:
	move.l	#$080B090B,D6
	movep.l	D6,0(SP)
	move	#$0A09,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.022:
	move.l	#$080C090A,D6
	movep.l	D6,0(SP)
	move	#$0A05,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.023:
	move.l	#$080B090A,D6
	movep.l	D6,0(SP)
	move	#$0A0A,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.024:
	move.l	#$080C0909,D6
	movep.l	D6,0(SP)
	move	#$0A08,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.025:
	move.l	#$080B090B,D6
	movep.l	D6,0(SP)
	move	#$0A08,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.026:
.027:
	move.l	#$080C090A,D6
	movep.l	D6,0(SP)
	move	#$0A00,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.028:
	move.l	#$080C0909,D6
	movep.l	D6,0(SP)
	move	#$0A07,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.029:
	move.l	#$080B090B,D6
	movep.l	D6,0(SP)
	move	#$0A07,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.030:
	move.l	#$080C0909,D6
	movep.l	D6,0(SP)
	move	#$0A06,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.031:
	move.l	#$080B090B,D6
	movep.l	D6,0(SP)
	move	#$0A06,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.032:
	move.l	#$080B090A,D6
	movep.l	D6,0(SP)
	move	#$0A09,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.033:
	move.l	#$080B090B,D6
	movep.l	D6,0(SP)
	move	#$0A05,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.034:
	move.l	#$080A090A,D6
	movep.l	D6,0(SP)
	move	#$0A0A,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.035:
	move.l	#$080B090B,D6
	movep.l	D6,0(SP)
	move	#$0A02,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.036:
	move.l	#$080B090A,D6
	movep.l	D6,0(SP)
	move	#$0A08,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.037:
	move.l	#$080C0907,D6
	movep.l	D6,0(SP)
	move	#$0A07,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.038:
	move.l	#$080C0908,D6
	movep.l	D6,0(SP)
	move	#$0A04,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.039:
	move.l	#$080C0907,D6
	movep.l	D6,0(SP)
	move	#$0A06,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.040:
	move.l	#$080B0909,D6
	movep.l	D6,0(SP)
	move	#$0A09,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.041:
	move.l	#$080C0906,D6
	movep.l	D6,0(SP)
	move	#$0A06,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.042:
	move.l	#$080A090A,D6
	movep.l	D6,0(SP)
	move	#$0A09,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.043:
	move.l	#$080C0907,D6
	movep.l	D6,0(SP)
	move	#$0A03,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.044:
	move.l	#$080B090A,D6
	movep.l	D6,0(SP)
	move	#$0A05,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.045:
	move.l	#$080B0909,D6
	movep.l	D6,0(SP)
	move	#$0A08,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.046:
	move.l	#$080B090A,D6
	movep.l	D6,0(SP)
	move	#$0A03,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.047:
	move.l	#$080A090A,D6
	movep.l	D6,0(SP)
	move	#$0A08,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.048:
	move.l	#$080B090A,D6
	movep.l	D6,0(SP)
	move	#$0A00,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.049:
	move.l	#$080B0909,D6
	movep.l	D6,0(SP)
	move	#$0A07,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.050:
	move.l	#$080B0908,D6
	movep.l	D6,0(SP)
	move	#$0A08,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.051:
	move.l	#$080A090A,D6
	movep.l	D6,0(SP)
	move	#$0A07,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.052:
	move.l	#$080A0909,D6
	movep.l	D6,0(SP)
	move	#$0A09,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.053:
	move.l	#$080C0901,D6
	movep.l	D6,0(SP)
	move	#$0A01,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.054:
	move.l	#$080A090A,D6
	movep.l	D6,0(SP)
	move	#$0A06,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.055:
	move.l	#$080B0908,D6
	movep.l	D6,0(SP)
	move	#$0A07,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.056:
	move.l	#$080A090A,D6
	movep.l	D6,0(SP)
	move	#$0A05,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.057:
	move.l	#$080A0909,D6
	movep.l	D6,0(SP)
	move	#$0A08,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.058:
	move.l	#$080A090A,D6
	movep.l	D6,0(SP)
	move	#$0A02,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.059:
	move.l	#$080A090A,D6
	movep.l	D6,0(SP)
	move	#$0A01,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.060:
	move.l	#$080A090A,D6
	movep.l	D6,0(SP)
	move	#$0A00,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.061:
	move.l	#$08090909,D6
	movep.l	D6,0(SP)
	move	#$0A09,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.062:
	move.l	#$080A0908,D6
	movep.l	D6,0(SP)
	move	#$0A08,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.063:
	move.l	#$080B0908,D6
	movep.l	D6,0(SP)
	move	#$0A01,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.064:
	move.l	#$080A0909,D6
	movep.l	D6,0(SP)
	move	#$0A06,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.065:
	move.l	#$080B0907,D6
	movep.l	D6,0(SP)
	move	#$0A04,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.066:
	move.l	#$080A0909,D6
	movep.l	D6,0(SP)
	move	#$0A05,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.067:
	move.l	#$08090909,D6
	movep.l	D6,0(SP)
	move	#$0A08,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.068:
	move.l	#$080A0909,D6
	movep.l	D6,0(SP)
	move	#$0A03,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.069:
	move.l	#$080A0908,D6
	movep.l	D6,0(SP)
	move	#$0A06,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.070:
	move.l	#$080A0909,D6
	movep.l	D6,0(SP)
	move	#$0A00,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.071:
	move.l	#$08090909,D6
	movep.l	D6,0(SP)
	move	#$0A07,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.072:
	move.l	#$08090908,D6
	movep.l	D6,0(SP)
	move	#$0A08,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.073:
	move.l	#$080A0908,D6
	movep.l	D6,0(SP)
	move	#$0A04,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.074:
	move.l	#$08090909,D6
	movep.l	D6,0(SP)
	move	#$0A06,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.075:
	move.l	#$080A0908,D6
	movep.l	D6,0(SP)
	move	#$0A01,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.076:
	move.l	#$08090909,D6
	movep.l	D6,0(SP)
	move	#$0A05,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.077:
	move.l	#$08090908,D6
	movep.l	D6,0(SP)
	move	#$0A07,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.078:
	move.l	#$08080908,D6
	movep.l	D6,0(SP)
	move	#$0A08,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.079:
	move.l	#$08090909,D6
	movep.l	D6,0(SP)
	move	#$0A02,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.080:
	move.l	#$08090908,D6
	movep.l	D6,0(SP)
	move	#$0A06,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.081:
	move.l	#$08090909,D6
	movep.l	D6,0(SP)
	move	#$0A00,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.082:
	move.l	#$08090907,D6
	movep.l	D6,0(SP)
	move	#$0A07,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.083:
	move.l	#$08080908,D6
	movep.l	D6,0(SP)
	move	#$0A07,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.084:
	move.l	#$08090907,D6
	movep.l	D6,0(SP)
	move	#$0A06,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.085:
	move.l	#$08090908,D6
	movep.l	D6,0(SP)
	move	#$0A02,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.086:
	move.l	#$08080908,D6
	movep.l	D6,0(SP)
	move	#$0A06,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.087:
	move.l	#$08090906,D6
	movep.l	D6,0(SP)
	move	#$0A06,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.088:
	move.l	#$08080907,D6
	movep.l	D6,0(SP)
	move	#$0A07,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.089:
	move.l	#$08080908,D6
	movep.l	D6,0(SP)
	move	#$0A04,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.090:
	move.l	#$08080907,D6
	movep.l	D6,0(SP)
	move	#$0A06,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.091:
	move.l	#$08080908,D6
	movep.l	D6,0(SP)
	move	#$0A02,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.092:
	move.l	#$08070907,D6
	movep.l	D6,0(SP)
	move	#$0A07,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.093:
	move.l	#$08080906,D6
	movep.l	D6,0(SP)
	move	#$0A06,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.094:
	move.l	#$08080907,D6
	movep.l	D6,0(SP)
	move	#$0A04,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.095:
	move.l	#$08070907,D6
	movep.l	D6,0(SP)
	move	#$0A06,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.096:
	move.l	#$08080906,D6
	movep.l	D6,0(SP)
	move	#$0A05,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.097:
	move.l	#$08080906,D6
	movep.l	D6,0(SP)
	move	#$0A04,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.098:
	move.l	#$08070906,D6
	movep.l	D6,0(SP)
	move	#$0A06,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.099:
	move.l	#$08070907,D6
	movep.l	D6,0(SP)
	move	#$0A04,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.100:
	move.l	#$08080905,D6
	movep.l	D6,0(SP)
	move	#$0A04,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.101:
	move.l	#$08060906,D6
	movep.l	D6,0(SP)
	move	#$0A06,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.102:
	move.l	#$08070906,D6
	movep.l	D6,0(SP)
	move	#$0A04,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.103:
	move.l	#$08070905,D6
	movep.l	D6,0(SP)
	move	#$0A05,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.104:
	move.l	#$08060906,D6
	movep.l	D6,0(SP)
	move	#$0A05,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.105:
	move.l	#$08060906,D6
	movep.l	D6,0(SP)
	move	#$0A04,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.106:
	move.l	#$08060905,D6
	movep.l	D6,0(SP)
	move	#$0A05,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.107:
	move.l	#$08060906,D6
	movep.l	D6,0(SP)
	move	#$0A02,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.108:
	move.l	#$08060905,D6
	movep.l	D6,0(SP)
	move	#$0A04,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.109:
	move.l	#$08050905,D6
	movep.l	D6,0(SP)
	move	#$0A05,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.110:
	move.l	#$08060905,D6
	movep.l	D6,0(SP)
	move	#$0A02,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.111:
	move.l	#$08050905,D6
	movep.l	D6,0(SP)
	move	#$0A04,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.112:
	move.l	#$08050904,D6
	movep.l	D6,0(SP)
	move	#$0A04,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.113:
	move.l	#$08050905,D6
	movep.l	D6,0(SP)
	move	#$0A02,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.114:
	move.l	#$08040904,D6
	movep.l	D6,0(SP)
	move	#$0A04,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.115:
	move.l	#$08040904,D6
	movep.l	D6,0(SP)
	move	#$0A03,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.116:
	move.l	#$08040904,D6
	movep.l	D6,0(SP)
	move	#$0A02,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.117:
	move.l	#$08040903,D6
	movep.l	D6,0(SP)
	move	#$0A03,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.118:
	move.l	#$08030903,D6
	movep.l	D6,0(SP)
	move	#$0A03,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.119:
	move.l	#$08030903,D6
	movep.l	D6,0(SP)
	move	#$0A02,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.120:
	move.l	#$08030902,D6
	movep.l	D6,0(SP)
	move	#$0A02,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.121:
	move.l	#$08020902,D6
	movep.l	D6,0(SP)
	move	#$0A02,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.122:
	move.l	#$08020902,D6
	movep.l	D6,0(SP)
	move	#$0A01,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.123:
	move.l	#$08010901,D6
	movep.l	D6,0(SP)
	move	#$0A01,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.124:
	move.l	#$08020901,D6
	movep.l	D6,0(SP)
	move	#$0A00,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.125:
	move.l	#$08010901,D6
	movep.l	D6,0(SP)
	move	#$0A00,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.126:
	move.l	#$08010900,D6
	movep.l	D6,0(SP)
	move	#$0A00,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.127:
	move.l	#$08000900,D6
	movep.l	D6,0(SP)
	move	#$0A00,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.128:
	move.l	#$080E090D,D6
	movep.l	D6,0(SP)
	move	#$0A0C,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.129:
.130:
.131:
.132:
.133:
.134:
	move.l	#$080F0903,D6
	movep.l	D6,0(SP)
	move	#$0A00,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.135:
.136:
.137:
.138:
.139:
.140:
.141:
	move.l	#$080E090D,D6
	movep.l	D6,0(SP)
	move	#$0A0B,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.142:
.143:
.144:
.145:
	move.l	#$080E090D,D6
	movep.l	D6,0(SP)
	move	#$0A0A,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.146:
	move.l	#$080E090C,D6
	movep.l	D6,0(SP)
	move	#$0A0C,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.147:
	move.l	#$080E090D,D6
	movep.l	D6,0(SP)
	move	#$0A00,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.148:
.149:
.150:
.151:
.152:
.153:
	move.l	#$080D090D,D6
	movep.l	D6,0(SP)
	move	#$0A0D,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.154:
.155:
.156:
.157:
.158:
.159:
.160:
.161:
	move.l	#$080E090C,D6
	movep.l	D6,0(SP)
	move	#$0A0B,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.162:
.163:
.164:
.165:
	move.l	#$080E090C,D6
	movep.l	D6,0(SP)
	move	#$0A0A,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.166:
.167:
	move.l	#$080D090D,D6
	movep.l	D6,0(SP)
	move	#$0A0C,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.168:
.169:
	move.l	#$080E090C,D6
	movep.l	D6,0(SP)
	move	#$0A09,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.170:
	move.l	#$080E090C,D6
	movep.l	D6,0(SP)
	move	#$0A05,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.171:
.172:
	move.l	#$080E090C,D6
	movep.l	D6,0(SP)
	move	#$0A00,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.173:
.174:
.175:
.176:
	move.l	#$080E090B,D6
	movep.l	D6,0(SP)
	move	#$0A0B,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.177:
.178:
.179:
	move.l	#$080E090B,D6
	movep.l	D6,0(SP)
	move	#$0A0A,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.180:
.181:
.182:
	move.l	#$080D090D,D6
	movep.l	D6,0(SP)
	move	#$0A0B,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.183:
.184:
.185:
	move.l	#$080E090B,D6
	movep.l	D6,0(SP)
	move	#$0A09,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.186:
	move.l	#$080D090C,D6
	movep.l	D6,0(SP)
	move	#$0A0C,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.187:
	move.l	#$080D090D,D6
	movep.l	D6,0(SP)
	move	#$0A0A,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.188:
	move.l	#$080E090B,D6
	movep.l	D6,0(SP)
	move	#$0A07,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.189:
	move.l	#$080E090B,D6
	movep.l	D6,0(SP)
	move	#$0A00,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.190:
	move.l	#$080E090B,D6
	movep.l	D6,0(SP)
	move	#$0A00,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.191:
	move.l	#$080D090D,D6
	movep.l	D6,0(SP)
	move	#$0A09,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.192:
	move.l	#$080D090D,D6
	movep.l	D6,0(SP)
	move	#$0A09,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.193:
	move.l	#$080E090A,D6
	movep.l	D6,0(SP)
	move	#$0A09,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.194:
	move.l	#$080D090D,D6
	movep.l	D6,0(SP)
	move	#$0A08,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.195:
	move.l	#$080D090D,D6
	movep.l	D6,0(SP)
	move	#$0A07,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.196:
	move.l	#$080D090D,D6
	movep.l	D6,0(SP)
	move	#$0A04,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.197:
	move.l	#$080D090D,D6
	movep.l	D6,0(SP)
	move	#$0A00,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.198:
	move.l	#$080E090A,D6
	movep.l	D6,0(SP)
	move	#$0A04,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.199:
	move.l	#$080E0909,D6
	movep.l	D6,0(SP)
	move	#$0A09,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.200:
	move.l	#$080E0909,D6
	movep.l	D6,0(SP)
	move	#$0A09,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.201:
	move.l	#$080D090C,D6
	movep.l	D6,0(SP)
	move	#$0A0B,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.202:
	move.l	#$080E0909,D6
	movep.l	D6,0(SP)
	move	#$0A08,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.203:
	move.l	#$080E0909,D6
	movep.l	D6,0(SP)
	move	#$0A08,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.204:
	move.l	#$080E0909,D6
	movep.l	D6,0(SP)
	move	#$0A07,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.205:
	move.l	#$080E0908,D6
	movep.l	D6,0(SP)
	move	#$0A08,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.206:
	move.l	#$080E0909,D6
	movep.l	D6,0(SP)
	move	#$0A01,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.207:
	move.l	#$080C090C,D6
	movep.l	D6,0(SP)
	move	#$0A0C,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.208:
	move.l	#$080D090C,D6
	movep.l	D6,0(SP)
	move	#$0A0A,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.209:
	move.l	#$080E0908,D6
	movep.l	D6,0(SP)
	move	#$0A06,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.210:
	move.l	#$080E0907,D6
	movep.l	D6,0(SP)
	move	#$0A07,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.211:
	move.l	#$080E0908,D6
	movep.l	D6,0(SP)
	move	#$0A00,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.212:
	move.l	#$080E0907,D6
	movep.l	D6,0(SP)
	move	#$0A05,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.213:
	move.l	#$080E0906,D6
	movep.l	D6,0(SP)
	move	#$0A06,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.214:
	move.l	#$080D090C,D6
	movep.l	D6,0(SP)
	move	#$0A09,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.215:
	move.l	#$080E0905,D6
	movep.l	D6,0(SP)
	move	#$0A05,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.216:
	move.l	#$080E0904,D6
	movep.l	D6,0(SP)
	move	#$0A04,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.217:
	move.l	#$080D090C,D6
	movep.l	D6,0(SP)
	move	#$0A08,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.218:
	move.l	#$080D090B,D6
	movep.l	D6,0(SP)
	move	#$0A0B,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.219:
	move.l	#$080E0900,D6
	movep.l	D6,0(SP)
	move	#$0A00,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.220:
	move.l	#$080D090C,D6
	movep.l	D6,0(SP)
	move	#$0A06,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.221:
	move.l	#$080D090C,D6
	movep.l	D6,0(SP)
	move	#$0A05,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.222:
	move.l	#$080D090C,D6
	movep.l	D6,0(SP)
	move	#$0A02,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.223:
.224:
	move.l	#$080C090C,D6
	movep.l	D6,0(SP)
	move	#$0A0B,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.225:
.226:
.227:
.228:
	move.l	#$080D090B,D6
	movep.l	D6,0(SP)
	move	#$0A0A,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.229:
.230:
.231:
	move.l	#$080C090C,D6
	movep.l	D6,0(SP)
	move	#$0A0A,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.232:
.233:
	move.l	#$080D090B,D6
	movep.l	D6,0(SP)
	move	#$0A09,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.234:
.235:
.236:
	move.l	#$080D090A,D6
	movep.l	D6,0(SP)
	move	#$0A0A,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.237:
.238:
.239:
	move.l	#$080C090C,D6
	movep.l	D6,0(SP)
	move	#$0A09,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.240:
	move.l	#$080D090B,D6
	movep.l	D6,0(SP)
	move	#$0A06,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.241:
	move.l	#$080C090B,D6
	movep.l	D6,0(SP)
	move	#$0A0B,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.242:
	move.l	#$080C090C,D6
	movep.l	D6,0(SP)
	move	#$0A08,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.243:
.244:
	move.l	#$080D090B,D6
	movep.l	D6,0(SP)
	move	#$0A00,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.245:
	move.l	#$080C090C,D6
	movep.l	D6,0(SP)
	move	#$0A07,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.246:
	move.l	#$080C090C,D6
	movep.l	D6,0(SP)
	move	#$0A06,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.247:
	move.l	#$080C090C,D6
	movep.l	D6,0(SP)
	move	#$0A05,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.248:
	move.l	#$080C090C,D6
	movep.l	D6,0(SP)
	move	#$0A03,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.249:
	move.l	#$080C090C,D6
	movep.l	D6,0(SP)
	move	#$0A01,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.250:
	move.l	#$080C090B,D6
	movep.l	D6,0(SP)
	move	#$0A0A,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.251:
	move.l	#$080D090A,D6
	movep.l	D6,0(SP)
	move	#$0A05,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.252:
	move.l	#$080D090A,D6
	movep.l	D6,0(SP)
	move	#$0A04,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.253:
	move.l	#$080D090A,D6
	movep.l	D6,0(SP)
	move	#$0A02,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte
.254:
.255:
	move.l	#$080D0909,D6
	movep.l	D6,0(SP)
	move	#$0A08,D6
	movep	D6,0(SP)
	move.l	USP,SP
	rte

.data

SplFire1::
	dc.w	2048
	dc.l	splFire1
SplFire2::
	dc.w	1134
	dc.l	splFire1
SplFire3::
	dc.w	784
	dc.l	splFire1
SplExplode::
	dc.w	3584
	dc.l	splExplode
SplRire1::
	dc.w	4688
	dc.l	splRire1
SplRire2::
	dc.w	1936
	dc.l	splRire2
SplJuron::
	dc.w	3840
	dc.l	splJuron
SplOuch::
	dc.w	3520
	dc.l	splOuch
SplPastille::
	dc.w	2576
	dc.l	splPastille
SplCoucou::
	dc.w	1648
	dc.l	splCoucou
SplTic::
	dc.w	512
	dc.l	splExplode
SplDring::
	dc.w	15904
	dc.l	splDring

splFire1:
	dc.b $E2,$01,$10,$FE,$F5,$E7,$05,$11,$02,$E4,$FE,$0D,$09,$D6,$17,$01
	dc.b $F4,$EA,$0A,$17,$C5,$27,$F7,$E7,$02,$09,$03,$E2,$02,$07,$0E,$EE
	dc.b $0B,$FF,$E2,$16,$07,$EA,$0D,$0A,$E2,$F1,$26,$29,$00,$ED,$F9,$08
	dc.b $04,$EC,$CC,$C6,$D6,$E8,$F9,$02,$04,$00,$FF,$FE,$01,$01,$01,$FF
	dc.b $F2,$DE,$CA,$BC,$C7,$E4,$FD,$05,$F9,$E2,$CC,$D8,$0D,$2A,$1F,$00
	dc.b $EF,$08,$27,$1D,$E7,$C9,$ED,$12,$01,$EB,$15,$24,$CD,$E7,$2F,$F2
	dc.b $F1,$1C,$E5,$0D,$0E,$DA,$17,$F7,$03,$FC,$06,$FA,$FC,$11,$E4,$22
	dc.b $DA,$28,$CD,$32,$D2,$28,$DE,$17,$F1,$0C,$F9,$02,$07,$F2,$12,$EF
	dc.b $16,$E9,$14,$F9,$01,$12,$DC,$29,$D9,$24,$E6,$14,$F4,$09,$F8,$05
	dc.b $FD,$02,$0B,$ED,$24,$D6,$2A,$F2,$EB,$2F,$D0,$21,$F9,$F0,$1E,$DE
	dc.b $0E,$08,$E9,$1F,$F1,$EE,$2A,$DF,$EB,$3A,$E1,$D9,$3B,$FB,$D2,$2D
	dc.b $17,$D0,$0F,$23,$DC,$F3,$31,$F5,$C9,$1D,$2C,$D1,$E0,$3D,$1B,$BD
	dc.b $F2,$40,$06,$C6,$03,$38,$FB,$C8,$0A,$40,$F8,$C1,$0A,$44,$00,$BB
	dc.b $F7,$4D,$22,$C0,$D7,$36,$33,$DC,$CA,$18,$42,$FF,$BE,$F0,$3E,$32
	dc.b $D8,$B4,$07,$50,$3A,$D1,$B1,$F6,$47,$43,$F0,$B2,$D2,$2A,$51,$22
	dc.b $CF,$AD,$E8,$3D,$5C,$20,$C5,$A2,$DA,$37,$5C,$39,$DD,$AA,$BE,$0F
	dc.b $51,$55,$13,$C4,$A2,$CE,$26,$5B,$58,$0C,$BA,$9C,$C3,$1D,$57,$5C
	dc.b $21,$CE,$A2,$B1,$FA,$44,$62,$45,$F5,$B1,$99,$C2,$19,$58,$68,$3B
	dc.b $E6,$A8,$98,$BE,$0D,$4E,$69,$54,$10,$C6,$9A,$95,$C3,$13,$52,$70
	dc.b $6B,$33,$E3,$A8,$8E,$98,$CF,$1B,$55,$71,$6E,$44,$FD,$BB,$93,$87
	dc.b $A3,$E4,$2C,$61,$79,$76,$4F,$0B,$C7,$99,$86,$90,$BD,$01,$41,$6B
	dc.b $7D,$76,$4D,$0A,$C8,$99,$82,$83,$A7,$E7,$2C,$5E,$79,$7E,$6C,$3B
	dc.b $F9,$BC,$93,$82,$85,$A6,$E1,$23,$59,$7A,$7F,$7E,$66,$32,$F2,$B9
	dc.b $91,$80,$80,$89,$AE,$E8,$25,$58,$79,$7F,$7F,$7F,$63,$30,$F3,$BB
	dc.b $93,$80,$80,$80,$8B,$B2,$E9,$22,$54,$77,$7F,$7F,$7F,$7C,$5D,$2B
	dc.b $F2,$BD,$94,$80,$80,$80,$81,$93,$BD,$F2,$28,$56,$76,$7F,$7F,$7F
	dc.b $7F,$71,$4A,$17,$E1,$B1,$8E,$80,$80,$80,$80,$8C,$AE,$DE,$13,$43
	dc.b $6A,$7D,$7F,$7F,$7F,$7F,$74,$50,$24,$F3,$C4,$9C,$84,$80,$80,$80
	dc.b $80,$81,$94,$B8,$E4,$13,$40,$66,$7E,$7F,$7F,$7F,$7F,$7F,$7D,$6D
	dc.b $4C,$25,$F9,$CE,$A7,$88,$80,$80,$80,$80,$80,$80,$82,$99,$BD,$E5
	dc.b $0F,$38,$5C,$76,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$76,$5D,$3D,$19,$F1
	dc.b $C9,$A6,$8A,$80,$80,$80,$80,$80,$80,$80,$85,$9A,$BA,$DE,$04,$2A
	dc.b $4D,$6B,$7E,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7C,$6E,$56,$3A,$1C,$FB
	dc.b $D8,$B7,$99,$83,$80,$80,$80,$80,$80,$80,$80,$80,$80,$89,$9F,$BA
	dc.b $D8,$F7,$17,$36,$53,$6D,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F
	dc.b $7C,$6F,$5D,$46,$2E,$13,$F7,$D9,$BC,$A1,$89,$80,$80,$80,$80,$80
	dc.b $80,$80,$80,$80,$80,$80,$8A,$9C,$B3,$CD,$E8,$04,$20,$3B,$55,$6C
	dc.b $7C,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$78,$6C,$5D,$4C
	dc.b $39,$24,$0F,$F8,$E0,$C9,$B2,$9C,$8A,$81,$80,$80,$80,$80,$80,$80
	dc.b $80,$80,$80,$80,$80,$80,$86,$93,$A2,$B3,$C6,$DB,$F0,$06,$1B,$31
	dc.b $46,$59,$6B,$7A,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F
	dc.b $7E,$78,$6E,$64,$58,$4B,$3D,$2D,$1B,$09,$F7,$E4,$D1,$BE,$AB,$9A
	dc.b $8A,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
	dc.b $85,$8E,$99,$A4,$B1,$BF,$CE,$DE,$EF,$01,$12,$23,$33,$44,$54,$63
	dc.b $71,$7C,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F
	dc.b $7F,$79,$71,$6A,$62,$59,$51,$48,$3E,$33,$27,$1B,$0E,$00,$F2,$E5
	dc.b $D6,$C8,$B9,$AB,$9E,$91,$86,$80,$80,$80,$80,$80,$80,$80,$80,$80
	dc.b $80,$80,$80,$80,$80,$80,$80,$82,$89,$90,$97,$9F,$A7,$AF,$B8,$C2
	dc.b $CD,$D8,$E4,$F1,$FE,$0A,$17,$23,$30,$3B,$47,$53,$5E,$68,$71,$79
	dc.b $7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7D
	dc.b $78,$73,$6D,$68,$62,$5C,$56,$4F,$49,$43,$3C,$35,$2E,$26,$1E,$16
	dc.b $0D,$03,$FA,$F0,$E6,$DC,$D3,$C9,$BF,$B6,$AD,$A4,$9B,$93,$8B,$85
	dc.b $80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
	dc.b $83,$87,$8C,$91,$96,$9B,$A1,$A6,$AC,$B1,$B7,$BD,$C3,$CA,$D1,$D8
	dc.b $E0,$E8,$F0,$F8,$01,$0A,$13,$1C,$25,$2D,$36,$3E,$46,$4E,$55,$5C
	dc.b $63,$6A,$70,$75,$7A,$7E,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F
	dc.b $7F,$7F,$7F,$7D,$7A,$76,$73,$6F,$6B,$67,$62,$5E,$59,$55,$50,$4B
	dc.b $47,$42,$3E,$39,$34,$30,$2B,$27,$22,$1D,$18,$12,$0D,$07,$01,$FB
	dc.b $F5,$EF,$E8,$E2,$DC,$D6,$D0,$CA,$C4,$BE,$B8,$B2,$AD,$A8,$A2,$9D
	dc.b $99,$94,$90,$8D,$8A,$87,$84,$83,$81,$80,$80,$80,$80,$80,$81,$82
	dc.b $84,$86,$88,$8A,$8D,$8F,$92,$96,$99,$9C,$A0,$A4,$A7,$AB,$AF,$B3
	dc.b $B7,$BC,$C0,$C4,$C8,$CC,$D1,$D5,$D9,$DE,$E2,$E7,$EC,$F0,$F6,$FB
	dc.b $00,$06,$0C,$11,$17,$1D,$23,$28,$2E,$33,$38,$3D,$42,$46,$4B,$4F
	dc.b $53,$57,$5B,$5F,$63,$66,$69,$6C,$6E,$71,$72,$74,$75,$76,$77,$77
	dc.b $77,$77,$76,$75,$74,$73,$72,$70,$6E,$6C,$6A,$68,$65,$63,$60,$5D
	dc.b $5A,$57,$54,$51,$4E,$4B,$48,$44,$41,$3E,$3A,$37,$34,$30,$2D,$2A
	dc.b $27,$23,$20,$1D,$1A,$17,$13,$10,$0D,$0A,$07,$04,$00,$FD,$F9,$F6
	dc.b $F2,$EF,$EB,$E7,$E3,$DF,$DC,$D8,$D4,$D1,$CD,$CA,$C7,$C3,$C0,$BD
	dc.b $BA,$B7,$B4,$B1,$AE,$AB,$A8,$A6,$A4,$A1,$9F,$9D,$9C,$9A,$99,$98
	dc.b $97,$96,$96,$96,$96,$96,$96,$97,$97,$98,$99,$9A,$9C,$9D,$9F,$A1
	dc.b $A2,$A4,$A6,$A8,$AB,$AD,$AF,$B2,$B4,$B7,$BA,$BC,$BF,$C2,$C4,$C7
	dc.b $CA,$CD,$CF,$D2,$D5,$D8,$DB,$DE,$E0,$E3,$E6,$E9,$EB,$EE,$F1,$F4
	dc.b $F6,$F9,$FC,$FF,$02,$05,$08,$0B,$0E,$12,$15,$18,$1C,$1F,$22,$26
	dc.b $29,$2C,$2F,$32,$35,$38,$3B,$3E,$40,$43,$45,$47,$49,$4B,$4D,$4F
	dc.b $51,$53,$54,$56,$57,$59,$5A,$5B,$5C,$5D,$5E,$5E,$5F,$5F,$5F,$5F
	dc.b $5F,$5E,$5E,$5E,$5D,$5C,$5B,$5A,$59,$58,$57,$55,$54,$52,$51,$4F
	dc.b $4D,$4C,$4A,$48,$46,$44,$42,$40,$3E,$3C,$39,$37,$35,$33,$31,$2F
	dc.b $2D,$2A,$28,$26,$24,$22,$20,$1E,$1C,$19,$17,$15,$13,$11,$0F,$0D
	dc.b $0B,$09,$07,$05,$03,$02,$00,$FE,$FC,$FA,$F9,$F7,$F5,$F3,$F1,$F0
	dc.b $EE,$EC,$EA,$E8,$E6,$E4,$E2,$E0,$DE,$DC,$DA,$D8,$D6,$D4,$D2,$D0
	dc.b $CF,$CD,$CB,$C9,$C8,$C6,$C5,$C3,$C2,$C0,$BF,$BE,$BD,$BC,$BA,$B9
	dc.b $B8,$B7,$B6,$B6,$B5,$B4,$B3,$B3,$B2,$B2,$B1,$B1,$B1,$B1,$B1,$B1
	dc.b $B1,$B1,$B1,$B2,$B2,$B3,$B3,$B4,$B5,$B6,$B7,$B8,$B9,$BA,$BB,$BC
	dc.b $BE,$BF,$C0,$C2,$C3,$C5,$C6,$C8,$C9,$CB,$CD,$CE,$D0,$D2,$D3,$D5
	dc.b $D7,$D9,$DB,$DC,$DE,$E0,$E2,$E3,$E5,$E7,$E9,$EA,$EC,$EE,$EF,$F1
	dc.b $F3,$F5,$F6,$F8,$FA,$FB,$FD,$FE,$00,$01,$03,$05,$06,$08,$09,$0B
	dc.b $0C,$0E,$0F,$11,$12,$14,$16,$17,$19,$1B,$1C,$1E,$20,$21,$23,$25
	dc.b $26,$28,$29,$2B,$2C,$2E,$2F,$31,$32,$34,$35,$36,$38,$39,$3A,$3B
	dc.b $3C,$3D,$3D,$3E,$3F,$3F,$40,$41,$41,$42,$42,$42,$43,$43,$44,$44
	dc.b $44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$43,$43,$43,$42,$41
	dc.b $41,$40,$3F,$3F,$3E,$3D,$3C,$3B,$3A,$39,$38,$37,$35,$34,$33,$32
	dc.b $31,$2F,$2E,$2D,$2B,$2A,$29,$27,$26,$25,$23,$22,$20,$1F,$1E,$1C
	dc.b $1B,$1A,$18,$17,$16,$14,$13,$12,$10,$0F,$0E,$0D,$0B,$0A,$09,$08
	dc.b $07,$05,$04,$03,$02,$01,$FF,$FE,$FD,$FC,$FB,$FA,$F9,$F8,$F7,$F6
	dc.b $F5,$F4,$F4,$F3,$F2,$F1,$F0,$EF,$EE,$ED,$ED,$EC,$EB,$EA,$E9,$E8
	dc.b $E8,$E7,$E6,$E5,$E4,$E3,$E2,$E1,$E0,$E0,$DF,$DE,$DD,$DC,$DB,$DB
	dc.b $DA,$D9,$D8,$D8,$D7,$D6,$D6,$D5,$D4,$D4,$D3,$D3,$D2,$D2,$D1,$D1
	dc.b $D1,$D0,$D0,$CF,$CF,$CE,$CE,$CE,$CD,$CD,$CD,$CD,$CC,$CC,$CC,$CC
	dc.b $CC,$CC,$CC,$CC,$CC,$CC,$CC,$CC,$CC,$CD,$CD,$CD,$CE,$CE,$CE,$CF
	dc.b $CF,$D0,$D0,$D1,$D1,$D2,$D3,$D4,$D4,$D5,$D6,$D7,$D7,$D8,$D9,$DA
	dc.b $DB,$DC,$DD,$DD,$DE,$DF,$E0,$E1,$E2,$E3,$E4,$E5,$E6,$E7,$E8,$E9
	dc.b $EA,$EB,$EC,$ED,$EE,$EF,$F0,$F1,$F2,$F3,$F4,$F5,$F6,$F7,$F8,$F9
	dc.b $F9,$FA,$FB,$FC,$FD,$FE,$FF,$00,$01,$01,$02,$03,$04,$05,$05,$06
	dc.b $07,$08,$09,$09,$0A,$0B,$0B,$0C,$0D,$0E,$0E,$0F,$10,$10,$10,$11
	dc.b $11,$11,$11,$11,$11,$11,$11,$11,$11,$10,$10,$10,$10,$10,$10,$10
	dc.b $10,$10,$10,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F,$0E,$0E
	dc.b $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0D,$0D,$0D,$0D,$0D,$0D
	dc.b $0D,$0D,$0D,$0D,$0D,$0D,$0D,$0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C
	dc.b $0C,$0C,$0C,$0C,$0C,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B
	dc.b $0B,$0B,$0B,$0B,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
	dc.b $0A,$0A,$0A,$0A,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09,$09
	dc.b $09,$09,$09,$09,$09,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08
	dc.b $08,$08,$08,$08,$08,$08,$08,$08,$07,$07,$07,$07,$07,$07,$07,$07
	dc.b $07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$06,$06,$06
	dc.b $06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06
	dc.b $06,$06,$06,$06,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05
	dc.b $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$04
	dc.b $04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04
	dc.b $04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$03,$03,$03
	dc.b $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03
	dc.b $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03
	dc.b $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
	dc.b $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
	dc.b $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$01,$01,$01,$01,$01
	dc.b $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
	dc.b $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
	dc.b $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
	dc.b $01,$01,$01,$01,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

splExplode:
	dc.b $7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F
	dc.b $7F,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$77,$65,$32,$24,$17,$05,$E2,$A4
	dc.b $AE,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
	dc.b $80,$80,$89,$8F,$98,$80,$84,$8B,$AF,$A0,$95,$80,$80,$88,$87,$82
	dc.b $80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$8C,$80,$80,$80,$82,$80
	dc.b $82,$84,$99,$B2,$BF,$B3,$B7,$C1,$C9,$E1,$D9,$EE,$EB,$E2,$EE,$F2
	dc.b $E4,$D2,$FD,$1B,$03,$00,$EF,$D6,$E2,$E5,$FE,$FF,$06,$FB,$FF,$0D
	dc.b $2D,$37,$2D,$2D,$34,$3D,$35,$30,$35,$24,$2B,$0C,$04,$03,$FA,$F4
	dc.b $FD,$F6,$FD,$F7,$13,$0A,$1E,$26,$28,$3D,$2E,$0E,$1A,$39,$31,$2D
	dc.b $20,$30,$25,$EE,$E4,$DD,$CA,$B2,$A4,$AE,$A8,$B9,$BE,$CC,$CD,$D2
	dc.b $CC,$E9,$EE,$FF,$0C,$03,$02,$1B,$0F,$26,$14,$0D,$02,$09,$FE,$E9
	dc.b $DB,$D4,$CE,$C1,$C6,$BD,$C5,$B9,$CF,$E5,$E7,$DB,$DF,$E3,$F0,$F1
	dc.b $F2,$09,$FC,$05,$01,$1A,$0F,$03,$00,$F2,$E8,$0C,$F8,$EC,$CD,$C4
	dc.b $B8,$B6,$A9,$A9,$A9,$B7,$B7,$DB,$E5,$F4,$03,$19,$1B,$09,$0A,$15
	dc.b $28,$26,$38,$2E,$38,$3D,$21,$3C,$53,$2D,$FA,$D1,$C3,$B1,$C6,$B8
	dc.b $C8,$CB,$D9,$E3,$DC,$E9,$F9,$05,$1C,$20,$1B,$26,$28,$3B,$36,$4B
	dc.b $51,$5A,$5D,$5D,$50,$5D,$58,$7A,$58,$4F,$2F,$13,$F4,$EC,$DE,$D1
	dc.b $BE,$B9,$BE,$AE,$C2,$B9,$B1,$DC,$F8,$0A,$11,$20,$24,$1B,$FE,$0E
	dc.b $04,$0B,$00,$03,$05,$FE,$1D,$26,$31,$35,$40,$3C,$38,$3C,$42,$3C
	dc.b $2F,$28,$3A,$45,$3A,$35,$3F,$4A,$51,$53,$37,$22,$1A,$10,$F8,$EB
	dc.b $E8,$D9,$C9,$AF,$A3,$A4,$C4,$E7,$E7,$F3,$F7,$F4,$EE,$E6,$CE,$D2
	dc.b $CC,$CC,$D6,$B7,$B3,$B1,$BD,$D3,$DD,$D6,$E5,$E3,$E6,$DC,$E2,$EC
	dc.b $04,$17,$36,$32,$34,$51,$64,$44,$2C,$FF,$CA,$D2,$CE,$B3,$B8,$CB
	dc.b $B6,$99,$9E,$B8,$D2,$E3,$E2,$F0,$EF,$05,$12,$15,$1F,$2A,$23,$2F
	dc.b $32,$35,$34,$3A,$38,$41,$4E,$2D,$28,$00,$F6,$E4,$05,$0F,$21,$0D
	dc.b $0D,$0A,$11,$23,$2F,$38,$3E,$46,$5F,$65,$61,$63,$6D,$63,$4C,$4F
	dc.b $44,$15,$10,$0B,$DE,$9D,$80,$80,$80,$8B,$A4,$B1,$A7,$A3,$B2,$D8
	dc.b $D6,$E0,$E3,$EB,$FD,$02,$17,$03,$F4,$F6,$E6,$FC,$F9,$10,$1C,$2E
	dc.b $28,$54,$53,$68,$68,$6D,$6C,$6C,$70,$5C,$45,$33,$2E,$04,$FF,$DC
	dc.b $D0,$B7,$A3,$82,$80,$80,$86,$96,$AE,$BF,$CA,$E2,$EB,$F6,$FD,$03
	dc.b $0B,$25,$26,$44,$5B,$73,$7F,$7F,$7F,$7F,$7F,$7F,$7F,$47,$32,$30
	dc.b $28,$E3,$D4,$A2,$81,$80,$80,$80,$80,$80,$80,$80,$80,$80,$A3,$E3
	dc.b $30,$58,$75,$3F,$38,$1F,$22,$4D,$73,$7F,$7F,$7F,$7F,$7F,$7F,$7F
	dc.b $7E,$74,$51,$42,$2E,$06,$E6,$C2,$B6,$B2,$A7,$B5,$A3,$8F,$9D,$9B
	dc.b $B8,$BB,$DF,$E1,$ED,$E2,$D7,$D3,$F2,$1D,$15,$25,$15,$23,$1D,$0A
	dc.b $F0,$0D,$08,$25,$19,$25,$25,$1E,$1A,$12,$17,$11,$1F,$1F,$36,$30
	dc.b $4B,$47,$47,$3D,$2E,$10,$0D,$FB,$DA,$9A,$8C,$87,$84,$81,$80,$80
	dc.b $80,$90,$A7,$CD,$EB,$FA,$11,$10,$0D,$29,$55,$7F,$73,$6F,$73,$51
	dc.b $19,$0D,$02,$19,$1B,$DC,$BC,$8A,$80,$80,$80,$80,$80,$80,$81,$C2
	dc.b $0F,$6F,$7F,$7F,$7D,$7F,$7B,$49,$3D,$4F,$7F,$7F,$7F,$67,$66,$63
	dc.b $54,$64,$6E,$69,$57,$50,$2C,$FC,$00,$FA,$E0,$BC,$9A,$8F,$80,$80
	dc.b $84,$8F,$A0,$A9,$B5,$B0,$CD,$E0,$0D,$25,$3E,$66,$73,$7F,$7F,$7F
	dc.b $7F,$7F,$7F,$7F,$7F,$7F,$52,$41,$14,$F4,$CD,$95,$80,$80,$80,$80
	dc.b $80,$80,$80,$81,$87,$DF,$F8,$3D,$26,$67,$4C,$36,$49,$5B,$79,$5B
	dc.b $5A,$3B,$54,$58,$5A,$3A,$27,$3D,$17,$05,$D8,$AF,$8E,$89,$80,$80
	dc.b $80,$80,$80,$86,$A7,$C0,$D5,$E4,$03,$1E,$28,$40,$59,$6B,$77,$7F
	dc.b $7F,$6F,$7B,$77,$73,$42,$1E,$32,$DC,$CB,$95,$80,$80,$80,$80,$80
	dc.b $80,$89,$AF,$E8,$FB,$15,$28,$24,$26,$33,$4A,$4A,$60,$50,$52,$43
	dc.b $43,$40,$2D,$26,$18,$01,$D7,$D1,$AC,$96,$83,$83,$80,$84,$87,$A5
	dc.b $B8,$D8,$E7,$FE,$0A,$15,$1F,$16,$25,$30,$34,$35,$4B,$5A,$5E,$6A
	dc.b $6A,$6F,$56,$4B,$42,$2A,$EF,$DF,$C4,$BE,$94,$81,$80,$80,$80,$80
	dc.b $80,$8B,$B7,$F5,$07,$39,$13,$34,$21,$19,$23,$38,$3A,$36,$42,$38
	dc.b $3C,$30,$29,$15,$14,$17,$14,$FD,$06,$FC,$F1,$E3,$CF,$BC,$B4,$B6
	dc.b $BA,$CC,$D8,$D5,$D4,$D8,$03,$1E,$3D,$53,$52,$51,$53,$43,$38,$46
	dc.b $3E,$45,$41,$15,$11,$FC,$EB,$D3,$D2,$C6,$BC,$CB,$CE,$DD,$EB,$00
	dc.b $0B,$16,$29,$31,$33,$3B,$4E,$61,$66,$56,$50,$4E,$25,$1E,$06,$E6
	dc.b $DB,$C3,$B8,$B2,$A7,$8C,$82,$82,$90,$A8,$BF,$D1,$E3,$F5,$01,$09
	dc.b $10,$18,$2C,$33,$3B,$3A,$43,$40,$37,$42,$39,$38,$23,$15,$FE,$FB
	dc.b $F6,$E2,$D0,$B4,$AB,$9F,$A4,$A6,$97,$9F,$99,$B0,$C0,$E6,$FE,$0E
	dc.b $19,$16,$26,$15,$1A,$1D,$34,$47,$57,$5A,$53,$41,$32,$2B,$25,$0C
	dc.b $0B,$05,$F9,$F4,$E8,$E9,$EF,$F4,$FA,$0F,$15,$21,$32,$3F,$3B,$39
	dc.b $2C,$28,$10,$F7,$EA,$D5,$BB,$B1,$B7,$CA,$E2,$F8,$08,$15,$2C,$33
	dc.b $35,$36,$33,$2C,$1B,$14,$02,$FC,$F0,$E9,$E1,$E4,$D9,$DC,$DC,$D9
	dc.b $E3,$E7,$F1,$F5,$04,$04,$11,$1B,$24,$23,$24,$2D,$32,$2B,$28,$1C
	dc.b $1F,$11,$0C,$F9,$ED,$D7,$D4,$C6,$C0,$C3,$C3,$CB,$D0,$E3,$EE,$F8
	dc.b $18,$1E,$30,$35,$3B,$48,$53,$48,$41,$38,$32,$2E,$1A,$0B,$FD,$FB
	dc.b $F3,$EC,$E2,$DD,$D5,$C7,$BD,$B9,$B3,$BA,$C0,$D4,$E4,$F8,$08,$0F
	dc.b $30,$2F,$44,$4A,$57,$4A,$47,$3B,$2B,$23,$13,$08,$01,$F9,$F2,$F1
	dc.b $F9,$FB,$F4,$ED,$ED,$D7,$CB,$C5,$C8,$CE,$D7,$E4,$F3,$0E,$19,$2B
	dc.b $33,$3F,$44,$44,$3F,$3A,$34,$18,$16,$FE,$0C,$04,$FA,$F3,$E3,$DF
	dc.b $E1,$EA,$F3,$F8,$F3,$F6,$F0,$FB,$F8,$F9,$F2,$F0,$EF,$F2,$F0,$F4
	dc.b $F9,$03,$0D,$14,$1E,$26,$2B,$2C,$2E,$2F,$2A,$2F,$2C,$26,$16,$16
	dc.b $08,$F9,$EA,$E6,$E3,$D2,$D3,$C6,$BF,$BB,$CD,$D2,$D9,$DB,$DF,$EB
	dc.b $EF,$FE,$07,$1A,$23,$2D,$33,$38,$41,$48,$4C,$49,$3A,$30,$19,$17
	dc.b $FF,$F0,$ED,$EB,$D6,$D2,$C8,$C6,$C1,$C0,$B7,$B5,$C0,$CE,$DD,$F3
	dc.b $04,$16,$20,$2D,$32,$32,$32,$37,$42,$3E,$37,$2A,$26,$2A,$1B,$0E
	dc.b $13,$06,$F6,$EC,$E2,$E8,$E7,$E4,$E1,$DF,$E5,$EB,$F8,$FB,$12,$23
	dc.b $29,$33,$2E,$29,$1B,$1B,$02,$EF,$DB,$C9,$B9,$BE,$C5,$CD,$D3,$DF
	dc.b $F0,$06,$14,$2F,$32,$35,$34,$3A,$29,$1A,$12,$1B,$12,$06,$FB,$F5
	dc.b $E2,$D8,$CC,$C9,$C4,$C9,$CB,$DC,$E3,$F6,$01,$0E,$1B,$25,$30,$34
	dc.b $32,$36,$33,$38,$40,$3F,$47,$2E,$23,$13,$01,$04,$FA,$E9,$CB,$BF
	dc.b $BB,$B8,$BD,$C2,$C9,$D9,$EB,$FF,$0D,$16,$25,$23,$2B,$22,$2D,$2D
	dc.b $2D,$2A,$16,$24,$21,$1E,$1A,$11,$07,$08,$03,$F7,$F8,$F2,$ED,$E3
	dc.b $D8,$D0,$D0,$CD,$D0,$DA,$E4,$ED,$FC,$06,$0E,$16,$26,$2D,$32,$32
	dc.b $37,$3C,$43,$42,$3F,$34,$22,$1B,$17,$03,$F8,$F1,$02,$02,$F4,$EA
	dc.b $DC,$D9,$DA,$E1,$D4,$C3,$C4,$C9,$CC,$D3,$E0,$EC,$FD,$06,$17,$1E
	dc.b $32,$2F,$3C,$37,$3B,$44,$45,$40,$2E,$28,$13,$FD,$F8,$E8,$E8,$E6
	dc.b $E4,$DB,$D5,$D3,$D0,$D0,$CF,$DF,$D6,$DE,$E6,$F4,$FD,$0C,$14,$14
	dc.b $1E,$16,$24,$22,$2D,$32,$33,$30,$29,$32,$24,$1B,$04,$FB,$FD,$FD
	dc.b $FD,$F9,$F2,$E6,$E7,$E8,$F0,$F8,$0F,$13,$13,$1A,$0F,$04,$FB,$FF
	dc.b $F5,$ED,$E3,$C9,$C7,$C8,$C6,$CC,$DF,$ED,$05,$17,$28,$2C,$2F,$35
	dc.b $44,$48,$37,$26,$18,$0B,$ED,$EB,$EA,$D2,$DC,$D7,$C9,$C5,$BC,$B9
	dc.b $B2,$C9,$D7,$EF,$01,$0E,$1D,$2A,$40,$3C,$41,$3F,$41,$45,$40,$3D
	dc.b $28,$27,$0B,$0B,$02,$F7,$FA,$F8,$F1,$FD,$01,$FE,$FA,$FE,$06,$03
	dc.b $FD,$09,$0A,$00,$EB,$F2,$E8,$DD,$D6,$CD,$C6,$C1,$CA,$CF,$DC,$E1
	dc.b $F2,$FD,$0D,$18,$23,$31,$39,$40,$3B,$3E,$44,$46,$34,$20,$20,$00
	dc.b $F6,$F6,$F0,$E4,$EC,$EC,$DB,$DC,$D3,$C9,$C2,$C3,$C8,$D0,$DB,$E4
	dc.b $F5,$01,$09,$1B,$1C,$24,$2A,$31,$3D,$47,$47,$41,$3A,$36,$2D,$28
	dc.b $22,$0F,$00,$08,$F7,$EE,$F3,$E2,$DE,$DE,$EA,$EB,$E3,$E9,$F1,$F1
	dc.b $F6,$EF,$F1,$F7,$FF,$06,$0C,$05,$10,$17,$1A,$1A,$0E,$0A,$FF,$FB
	dc.b $E9,$E8,$D6,$DB,$E3,$E4,$F7,$FE,$0E,$15,$29,$21,$32,$27,$34,$33
	dc.b $34,$1D,$17,$05,$ED,$E9,$F3,$F3,$E4,$DF,$DD,$D7,$DC,$D6,$D1,$D8
	dc.b $E2,$F4,$F5,$05,$0F,$1C,$23,$27,$41,$3A,$2D,$1B,$20,$1A,$09,$FA
	dc.b $F8,$F8,$FF,$00,$F2,$EA,$DF,$DD,$DB,$E0,$D7,$D3,$CF,$C4,$C4,$D0
	dc.b $D5,$E2,$F1,$FE,$12,$18,$26,$26,$29,$2F,$39,$32,$34,$2C,$29,$2D
	dc.b $1B,$11,$FB,$FA,$07,$0B,$0D,$17,$0D,$0C,$10,$F3,$EA,$DE,$E2,$E8
	dc.b $E4,$D4,$B9,$B2,$AB,$B5,$C3,$D4,$E2,$F5,$08,$1B,$36,$45,$4B,$42
	dc.b $4D,$5B,$54,$55,$28,$19,$10,$06,$07,$04,$FF,$E9,$D4,$C4,$CF,$CB
	dc.b $C4,$C4,$D5,$E0,$EE,$FF,$FF,$03,$01,$F8,$F8,$04,$06,$07,$FA,$03
	dc.b $00,$02,$F6,$FA,$04,$03,$0C,$0F,$09,$05,$0F,$09,$12,$15,$1B,$2A
	dc.b $24,$16,$11,$06,$0B,$03,$10,$13,$16,$F4,$E8,$E1,$E7,$E8,$E6,$E9
	dc.b $E2,$D7,$D0,$D0,$DA,$E7,$00,$05,$19,$1F,$2B,$2F,$2D,$3A,$37,$23
	dc.b $23,$1C,$1B,$00,$F1,$DE,$D9,$E5,$E7,$D4,$D1,$C8,$C0,$C2,$CC,$DE
	dc.b $F0,$FF,$12,$1F,$25,$27,$31,$31,$30,$35,$3B,$28,$1A,$10,$12,$0B
	dc.b $FD,$E9,$DF,$D6,$D5,$CE,$D1,$CA,$D0,$D6,$D7,$DD,$E0,$EF,$F8,$02
	dc.b $0C,$17,$1F,$27,$2F,$24,$27,$2C,$38,$33,$2C,$1E,$1B,$18,$04,$FA
	dc.b $F2,$E3,$F0,$E7,$E4,$E0,$CD,$BE,$B3,$C6,$CF,$DF,$F2,$06,$17,$1F
	dc.b $2E,$26,$2E,$27,$37,$36,$2C,$20,$12,$0D,$FC,$F1,$F9,$F4,$E1,$CC
	dc.b $C2,$C7,$CD,$D0,$CF,$D2,$D3,$E1,$EF,$FE,$0D,$11,$19,$1A,$28,$2D
	dc.b $36,$38,$44,$37,$39,$2E,$23,$1A,$0F,$03,$F5,$FF,$09,$07,$07,$F7
	dc.b $E5,$E1,$E2,$D7,$D4,$D4,$CD,$D1,$DE,$EB,$FA,$0A,$0E,$11,$0C,$14
	dc.b $16,$0E,$0D,$0B,$F9,$F7,$E9,$ED,$E8,$ED,$ED,$EF,$F2,$F1,$F8,$FB
	dc.b $FF,$05,$0B,$0B,$06,$19,$16,$20,$23,$1F,$19,$10,$12,$12,$17,$0E
	dc.b $05,$FA,$ED,$EF,$F4,$FE,$F4,$EF,$E6,$E4,$E2,$E0,$DD,$E3,$E5,$EB
	dc.b $EF,$F9,$FC,$0F,$14,$24,$27,$25,$29,$26,$2D,$3A,$39,$2F,$23,$00
	dc.b $F2,$EE,$E4,$F2,$EF,$EF,$E5,$D5,$C1,$C5,$CA,$D3,$E1,$E1,$F7,$FE
	dc.b $15,$1E,$2B,$26,$21,$25,$23,$36,$33,$35,$3D,$32,$2A,$07,$F0,$EA
	dc.b $E9,$EF,$FB,$03,$F7,$F6,$F1,$F6,$F1,$E8,$E1,$DF,$D0,$D4,$D6,$D9
	dc.b $DF,$E6,$F3,$FF,$03,$0A,$10,$15,$14,$18,$24,$29,$3F,$3A,$3D,$3E
	dc.b $24,$16,$04,$FF,$F8,$F9,$EB,$F3,$F5,$F7,$EA,$EB,$E0,$DE,$D7,$D6
	dc.b $CF,$C3,$C2,$C4,$D3,$E1,$EE,$FB,$05,$0F,$10,$1D,$1D,$1B,$1F,$26
	dc.b $21,$26,$2E,$26,$25,$12,$15,$0A,$04,$FF,$F6,$EC,$EC,$EC,$EA,$E5
	dc.b $F0,$F4,$F4,$F6,$F6,$FF,$07,$0F,$18,$1F,$24,$24,$21,$1B,$1B,$25
	dc.b $12,$F7,$F7,$E1,$DA,$DC,$D4,$D0,$CD,$CB,$CE,$CF,$D5,$DB,$E7,$F3
	dc.b $FD,$07,$10,$1D,$20,$1B,$16,$1A,$1E,$24,$2B,$2B,$28,$17,$0C,$0D
	dc.b $14,$0E,$10,$FA,$F0,$DD,$D9,$DD,$E0,$E6,$ED,$EE,$E8,$E7,$DF,$DE
	dc.b $DA,$DC,$E1,$E6,$F2,$FB,$09,$0F,$1C,$20,$19,$19,$19,$1D,$1A,$1C
	dc.b $26,$25,$2A,$23,$29,$16,$18,$09,$08,$FD,$FD,$F0,$ED,$F2,$F7,$FA
	dc.b $01,$03,$06,$13,$13,$22,$22,$25,$1F,$19,$10,$01,$FA,$F0,$E7,$E5
	dc.b $D3,$C9,$C4,$BE,$C4,$CB,$D2,$E5,$F1,$08,$0B,$1F,$29,$23,$20,$13
	dc.b $15,$14,$2A,$29,$23,$0E,$07,$F0,$E7,$DF,$E1,$E6,$EF,$F1,$FF,$EE
	dc.b $E3,$DD,$D5,$D5,$D6,$DC,$E0,$EC,$F6,$FE,$0C,$12,$1E,$27,$1C,$16
	dc.b $0C,$0D,$11,$18,$25,$27,$1B,$1F,$17,$17,$12,$0B,$0D,$0A,$13,$12
	dc.b $18,$0F,$12,$02,$FE,$F3,$F6,$E8,$E9,$EC,$ED,$E8,$EA,$E2,$E5,$E1
	dc.b $DD,$DF,$DE,$E1,$E9,$F2,$FC,$06,$18,$1B,$21,$2A,$2A,$2C,$27,$44
	dc.b $31,$21,$18,$02,$07,$09,$FD,$EE,$E1,$E1,$E1,$EE,$E2,$EF,$E6,$ED
	dc.b $E7,$E4,$D9,$CF,$CE,$D2,$DE,$E9,$F2,$FB,$01,$0C,$14,$1E,$19,$1B
	dc.b $0E,$0B,$09,$0B,$0E,$20,$1A,$17,$12,$0C,$0B,$06,$02,$00,$00,$F7
	dc.b $00,$00,$00,$04,$07,$12,$15,$12,$0B,$0C,$08,$0D,$FE,$01,$F5,$ED
	dc.b $E9,$DD,$DA,$D5,$CF,$CD,$D1,$DA,$E6,$F4,$FC,$08,$0B,$18,$22,$29
	dc.b $1D,$1B,$14,$1C,$2B,$30,$2F,$28,$19,$15,$0A,$01,$FF,$FC,$F8,$EF
	dc.b $F0,$EC,$ED,$F2,$FA,$F1,$EA,$E9,$E3,$DB,$DB,$DA,$DA,$D7,$DD,$E7
	dc.b $F1,$01,$08,$13,$16,$20,$23,$18,$11,$0A,$10,$0B,$14,$19,$1E,$19
	dc.b $15,$14,$0C,$0B,$0A,$07,$05,$0A,$05,$06,$0A,$0A,$13,$16,$16,$17
	dc.b $14,$12,$0E,$0F,$11,$14,$0E,$F3,$E4,$DF,$D7,$D3,$CB,$C7,$C2,$BE
	dc.b $C3,$D3,$E0,$F1,$FE,$07,$17,$1F,$32,$2E,$23,$1B,$1C,$26,$30,$2E
	dc.b $1B,$1A,$0F,$03,$07,$F9,$F3,$E6,$F0,$F3,$F2,$EE,$F1,$F0,$ED,$EC
	dc.b $E7,$E3,$DE,$D6,$D5,$D4,$D6,$DA,$E3,$F3,$FD,$09,$0E,$17,$23,$1D
	dc.b $15,$0D,$0C,$0A,$16,$1A,$1C,$15,$0D,$0D,$08,$0C,$05,$FE,$02,$01
	dc.b $02,$04,$0A,$09,$13,$12,$09,$0C,$06,$0D,$0D,$14,$0E,$0A,$0B,$06
	dc.b $02,$FF,$FC,$F7,$F0,$EA,$DF,$D9,$CE,$CA,$C1,$C6,$CB,$D5,$E3,$F0
	dc.b $FF,$05,$0B,$15,$24,$20,$1C,$1E,$1F,$20,$29,$27,$21,$1E,$18,$17
	dc.b $0B,$06,$FF,$F6,$ED,$DE,$DC,$DD,$E1,$E8,$E9,$ED,$F2,$F8,$03,$02
	dc.b $06,$05,$0B,$0A,$06,$FD,$F5,$E8,$E3,$DE,$E1,$DE,$E8,$F2,$FE,$08
	dc.b $10,$15,$17,$18,$12,$13,$11,$0E,$15,$13,$17,$19,$15,$0A,$0C,$08
	dc.b $0D,$0F,$12,$10,$0C,$06,$06,$08,$0C,$0C,$10,$10,$17,$15,$19,$1B
	dc.b $18,$05,$02,$01,$02,$01,$06,$FD,$F4,$F1,$E9,$E6,$DF,$DE,$D4,$D2
	dc.b $C8,$CB,$CC,$CD,$D6,$E0,$EC,$F7,$FB,$03,$04,$07,$0F,$16,$16,$08
	dc.b $09,$0F,$18,$1E,$22,$26,$22,$1A,$12,$13,$1B,$15,$14,$0E,$02,$03
	dc.b $FE,$FE,$FD,$00,$FD,$FA,$F7,$F9,$F6,$F8,$00,$07,$03,$FF,$F4,$F0
	dc.b $E2,$E6,$DF,$DA,$D1,$CE,$CE,$D5,$DB,$E9,$F4,$02,$07,$0B,$12,$1A
	dc.b $1E,$13,$15,$0A,$0A,$0B,$0E,$16,$12,$0C,$0C,$0F,$13,$12,$0D,$0C
	dc.b $06,$04,$04,$07,$06,$0B,$06,$0D,$0C,$11,$11,$14,$1C,$16,$12,$0D
	dc.b $06,$05,$01,$02,$F9,$EE,$EA,$E2,$DC,$D5,$D3,$CB,$CA,$CC,$D3,$DA
	dc.b $E7,$F1,$F9,$FF,$00,$08,$0F,$15,$11,$0A,$01,$01,$02,$03,$08,$09
	dc.b $08,$08,$06,$07,$08,$0A,$07,$09,$09,$08,$0F,$07,$01,$FD,$F8,$F5
	dc.b $F3,$F1,$F8,$F8,$FD,$00,$06,$08,$0C,$0B,$06,$0C,$06,$06,$04,$07
	dc.b $09,$09,$0C,$0C,$09,$03,$FC,$F2,$EC,$EB,$E5,$E9,$E9,$E5,$E1,$DE
	dc.b $DE,$E0,$E7,$EE,$F7,$FF,$04,$07,$06,$0B,$14,$19,$18,$14,$0C,$10
	dc.b $0F,$10,$11,$12,$0C,$08,$0D,$0C,$0A,$00,$FD,$FC,$FD,$00,$00,$02
	dc.b $03,$09,$07,$06,$07,$08,$09,$08,$0C,$0D,$13,$13,$15,$12,$0F,$0D
	dc.b $14,$15,$0D,$FF,$F7,$F2,$F2,$F2,$EA,$E5,$DC,$D9,$D5,$D2,$D3,$D7
	dc.b $DE,$E7,$F0,$F8,$FC,$FE,$00,$03,$08,$0B,$0B,$06,$02,$02,$05,$08
	dc.b $07,$0A,$0C,$0C,$0B,$07,$08,$08,$07,$0A,$0A,$0B,$0B,$0C,$08,$06
	dc.b $06,$01,$00,$FF,$05,$05,$05,$05,$FF,$FE,$FC,$FE,$FE,$FF,$F5,$F3
	dc.b $F2,$ED,$ED,$F1,$F1,$F3,$F4,$FA,$F7,$F7,$F6,$F6,$F7,$F7,$F7,$F9
	dc.b $F9,$FB,$FF,$02,$06,$08,$0A,$0F,$0C,$0A,$0A,$07,$05,$07,$05,$09
	dc.b $05,$09,$0E,$0E,$0A,$0A,$0A,$09,$04,$04,$FF,$FC,$FE,$FC,$FE,$FC
	dc.b $F9,$FB,$FE,$FD,$FF,$00,$FE,$01,$05,$07,$09,$0A,$08,$09,$0A,$0A
	dc.b $0C,$0B,$0A,$08,$06,$FF,$00,$FD,$F8,$F8,$F8,$FB,$F8,$F2,$EC,$E8
	dc.b $E5,$E2,$E2,$E4,$E7,$ED,$F4,$F7,$FC,$FF,$01,$04,$0A,$11,$10,$0D
	dc.b $0B,$0B,$06,$00,$00,$FD,$FE,$FF,$FD,$FC,$FE,$FC,$FC,$FB,$F8,$F8
	dc.b $F6,$F8,$FB,$FC,$00,$03,$03,$06,$0A,$10,$12,$10,$0F,$11,$13,$10
	dc.b $13,$0F,$10,$0F,$11,$0D,$0A,$08,$06,$04,$04,$02,$01,$01,$FD,$FE
	dc.b $FC,$FD,$FA,$FB,$FB,$FC,$FB,$FA,$F9,$F7,$F8,$F6,$F5,$F2,$F3,$F3
	dc.b $F2,$F3,$F4,$F4,$F3,$F1,$EE,$EF,$F1,$F5,$F8,$FC,$FE,$00,$03,$05
	dc.b $08,$0A,$0B,$0D,$0D,$0F,$0F,$0F,$0D,$0E,$11,$10,$0A,$08,$07,$06
	dc.b $0A,$08,$07,$09,$0A,$0C,$09,$04,$07,$08,$0E,$0D,$0E,$09,$07,$06
	dc.b $04,$00,$FC,$FC,$FC,$F9,$F9,$F2,$F3,$F5,$F4,$F5,$F3,$F4,$F4,$F2
	dc.b $F2,$F0,$EF,$EE,$EB,$EB,$EB,$ED,$F2,$F5,$F9,$FC,$FD,$00,$03,$06
	dc.b $0B,$0D,$0E,$0D,$0B,$0D,$0C,$0A,$09,$08,$04,$02,$FC,$FE,$FA,$F8
	dc.b $F6,$F7,$F4,$F4,$F6,$F5,$F7,$F9,$FB,$FF,$FF,$02,$03,$04,$05,$04
	dc.b $05,$00,$03,$00,$FF,$01,$FF,$FE,$FF,$00,$FF,$01,$00,$FE,$FF,$FF
	dc.b $00,$03,$04,$03,$03,$04,$06,$07,$07,$06,$05,$03,$04,$05,$05,$06
	dc.b $05,$07,$07,$09,$06,$05,$05,$02,$04,$05,$05,$01,$FF,$FD,$FC,$FB
	dc.b $F8,$F6,$F7,$F4,$F6,$F6,$F6,$F6,$F8,$F9,$FB,$FE,$FF,$02,$01,$FF
	dc.b $FE,$00,$01,$02,$02,$02,$03,$06,$08,$09,$06,$06,$02,$01,$FE,$FC
	dc.b $FA,$FA,$FA,$F9,$F8,$F6,$F5,$F6,$F8,$FA,$FC,$FC,$FC,$FC,$FC,$FC
	dc.b $FD,$FE,$FF,$01,$03,$04,$05,$09,$08,$0B,$09,$09,$0B,$0C,$0E,$0E
	dc.b $10,$15,$11,$0E,$0C,$0A,$0A,$0D,$0B,$0D,$08,$06,$05,$04,$00,$FF
	dc.b $FE,$FB,$F6,$F3,$F2,$F3,$F3,$F4,$F5,$F4,$F6,$F8,$F8,$F8,$F7,$F7
	dc.b $F9,$FA,$FB,$FC,$FC,$FF,$00,$01,$00,$FE,$FC,$FC,$FA,$F9,$F9,$FB
	dc.b $FC,$FB,$FD,$00,$03,$04,$03,$03,$03,$02,$02,$01,$FE,$FD,$FB,$FA
	dc.b $FA,$F9,$FC,$FF,$01,$01,$02,$02,$04,$03,$03,$01,$FF,$FF,$01,$00
	dc.b $01,$02,$02,$04,$05,$07,$08,$08,$06,$05,$03,$03,$01,$FE,$FD,$FC
	dc.b $FF,$00,$FD,$FB,$FA,$FB,$FB,$FD,$FD,$FE,$FF,$00,$01,$02,$02,$03
	dc.b $04,$04,$04,$04,$05,$05,$06,$07,$04,$01,$FF,$FD,$FF,$00,$01,$01
	dc.b $FD,$FE,$FC,$FA,$F9,$FC,$FC,$FB,$FA,$FA,$FB,$FC,$FE,$01,$03,$03
	dc.b $04,$05,$05,$05,$05,$01,$00,$FF,$01,$01,$01,$01,$01,$FF,$FD,$FD
	dc.b $FE,$FF,$01,$02,$01,$FF,$FF,$FE,$FF,$FF,$FD,$FE,$00,$FF,$FC,$FC
	dc.b $FC,$FC,$FB,$FB,$FC,$FC,$FB,$FB,$FB,$FC,$FE,$00,$00,$FF,$FE,$FF
	dc.b $FF,$00,$00,$02,$03,$03,$02,$01,$02,$03,$03,$03,$04,$02,$01,$FF
	dc.b $01,$01,$03,$03,$02,$01,$02,$03,$03,$05,$03,$03,$00,$FE,$FB,$FA
	dc.b $F9,$F9,$FA,$F9,$F9,$F9,$FA,$FB,$FC,$FD,$FC,$FD,$FE,$FF,$00,$01
	dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

splRire1:
	dc.b $C6,$C6,$E1,$F2,$E5,$DD,$EC,$05,$0A,$08,$16,$18,$22,$2D,$25,$24
	dc.b $20,$10,$08,$07,$09,$01,$F1,$F5,$FB,$FA,$F2,$EC,$FB,$EC,$EA,$F2
	dc.b $EF,$E8,$E0,$F8,$06,$F7,$FD,$07,$05,$11,$25,$1E,$04,$FF,$12,$09
	dc.b $02,$FE,$01,$09,$07,$0C,$0C,$FB,$F9,$02,$06,$06,$FA,$F4,$FE,$FD
	dc.b $FF,$F2,$ED,$F5,$FA,$FA,$F5,$FA,$F7,$FA,$0C,$02,$FE,$F9,$FE,$F9
	dc.b $F1,$F9,$F8,$EB,$F3,$FD,$F7,$EA,$ED,$F3,$FB,$F0,$F8,$03,$FE,$F9
	dc.b $FD,$FC,$02,$08,$FE,$F9,$04,$07,$03,$02,$01,$FE,$00,$06,$0A,$FC
	dc.b $F7,$00,$05,$09,$05,$F4,$01,$03,$0F,$07,$FF,$01,$08,$09,$14,$05
	dc.b $FC,$FE,$12,$06,$F6,$08,$05,$F5,$00,$0C,$0A,$F7,$FD,$0E,$05,$FB
	dc.b $03,$05,$FB,$FD,$04,$0B,$FD,$F3,$FC,$05,$0A,$02,$FF,$FE,$01,$02
	dc.b $02,$0D,$FA,$F5,$08,$09,$02,$01,$03,$05,$F5,$09,$13,$00,$F3,$03
	dc.b $11,$05,$F8,$FF,$FA,$F6,$06,$FE,$F9,$F6,$F1,$F5,$F8,$FB,$F2,$EA
	dc.b $F8,$02,$FB,$F5,$F9,$0A,$FC,$FC,$05,$05,$FC,$FF,$03,$05,$FF,$F5
	dc.b $03,$01,$FB,$FA,$01,$FD,$F0,$F2,$03,$00,$F8,$F5,$FC,$01,$FC,$04
	dc.b $12,$F9,$F3,$05,$10,$09,$F8,$FC,$03,$FA,$03,$11,$00,$F3,$00,$0D
	dc.b $05,$00,$05,$08,$0C,$1B,$20,$16,$02,$02,$15,$10,$FD,$05,$04,$FF
	dc.b $FD,$F7,$FE,$12,$21,$32,$3B,$29,$01,$F8,$F7,$F2,$F1,$E6,$CE,$D6
	dc.b $CB,$C0,$BD,$D6,$0C,$2A,$1A,$18,$26,$10,$03,$07,$FC,$F1,$EF,$E7
	dc.b $CE,$CC,$D0,$E2,$0F,$34,$31,$33,$34,$09,$04,$15,$15,$F5,$E0,$D6
	dc.b $C7,$B3,$C9,$E0,$EA,$07,$1A,$24,$33,$2C,$FE,$F2,$02,$FB,$E3,$CC
	dc.b $C9,$C2,$AF,$B3,$D7,$FF,$16,$18,$21,$33,$2A,$01,$00,$18,$07,$D8
	dc.b $D5,$E0,$D9,$C5,$C9,$CD,$E3,$FC,$18,$1F,$27,$37,$28,$07,$09,$15
	dc.b $01,$E4,$E3,$EA,$E3,$CE,$D0,$DF,$E0,$F1,$1D,$1B,$03,$19,$46,$2F
	dc.b $0A,$0D,$28,$0B,$E5,$E7,$FD,$F1,$D7,$DC,$F0,$F0,$E8,$FE,$10,$04
	dc.b $0A,$21,$3D,$28,$0E,$06,$0B,$FE,$FE,$02,$F2,$E2,$E8,$F4,$ED,$F3
	dc.b $06,$00,$ED,$F3,$0A,$12,$0D,$1A,$1F,$18,$1A,$0C,$FC,$F6,$F6,$F0
	dc.b $EE,$EB,$E0,$DD,$ED,$F9,$EC,$EC,$FB,$FB,$EF,$F6,$05,$FF,$02,$19
	dc.b $1E,$1A,$0F,$17,$1C,$19,$06,$00,$03,$10,$00,$02,$01,$00,$04,$08
	dc.b $FC,$01,$FE,$FE,$ED,$F1,$F1,$F4,$EE,$F4,$F5,$08,$01,$02,$FC,$09
	dc.b $14,$12,$0C,$02,$F3,$01,$04,$FE,$06,$0B,$FB,$00,$0A,$11,$EC,$F7
	dc.b $09,$07,$F2,$02,$03,$FB,$FD,$05,$09,$FC,$F6,$03,$0B,$00,$FD,$11
	dc.b $04,$00,$11,$19,$0B,$FC,$09,$11,$0C,$FB,$08,$09,$08,$06,$0E,$0A
	dc.b $02,$E5,$06,$08,$F9,$EA,$F5,$FB,$01,$EE,$F8,$FA,$FB,$F9,$05,$05
	dc.b $FA,$F5,$FE,$0E,$00,$0A,$04,$F4,$F2,$12,$15,$FF,$E5,$02,$0C,$14
	dc.b $04,$03,$05,$0B,$00,$12,$10,$08,$0B,$12,$16,$18,$03,$F0,$EF,$F8
	dc.b $F6,$E3,$E4,$E8,$E6,$ED,$FE,$F5,$F5,$F7,$05,$04,$0D,$0B,$08,$F7
	dc.b $10,$1A,$1D,$FE,$FD,$11,$1B,$F8,$FF,$0E,$0F,$F9,$06,$0F,$04,$F7
	dc.b $FF,$02,$0D,$07,$FF,$07,$08,$0B,$0D,$05,$07,$09,$05,$0C,$0C,$0A
	dc.b $08,$01,$03,$0C,$0E,$FE,$FE,$00,$01,$08,$08,$F9,$F7,$03,$F1,$F4
	dc.b $FC,$F9,$EF,$EF,$FB,$FF,$F8,$F7,$F3,$F2,$FC,$03,$FE,$F2,$FD,$F7
	dc.b $F5,$F9,$FE,$FA,$FB,$01,$09,$0F,$1D,$17,$09,$FA,$FF,$02,$05,$02
	dc.b $FE,$EB,$EE,$F8,$E8,$EE,$24,$44,$24,$0B,$28,$27,$13,$FD,$08,$01
	dc.b $ED,$DB,$E1,$E3,$E2,$23,$4D,$1F,$E5,$FD,$4A,$5E,$FF,$CE,$EE,$F9
	dc.b $C1,$98,$A6,$FC,$50,$6E,$14,$D5,$E4,$3F,$74,$1E,$CA,$E2,$03,$B0
	dc.b $80,$BE,$59,$6C,$0F,$B2,$D3,$04,$6A,$68,$FE,$B2,$B4,$9F,$83,$CB
	dc.b $70,$72,$ED,$8E,$C5,$38,$76,$66,$EC,$AD,$98,$88,$9E,$1E,$7A,$3B
	dc.b $AC,$92,$FF,$6A,$73,$1C,$B4,$92,$87,$81,$25,$7D,$6E,$CB,$90,$E5
	dc.b $57,$7B,$2A,$B1,$80,$80,$92,$07,$75,$55,$C4,$82,$ED,$68,$7D,$45
	dc.b $B0,$85,$80,$83,$37,$7D,$6F,$D0,$93,$02,$64,$63,$03,$B4,$92,$80
	dc.b $9A,$3B,$7A,$3E,$B9,$98,$02,$75,$76,$07,$99,$90,$8B,$95,$17,$75
	dc.b $5E,$B0,$8C,$08,$6F,$62,$F8,$BB,$A5,$8D,$80,$DB,$73,$5D,$DC,$93
	dc.b $05,$71,$62,$08,$C0,$C1,$A4,$86,$AD,$3E,$7D,$21,$97,$B6,$3E,$6C
	dc.b $2C,$E2,$CC,$CA,$97,$80,$D1,$6D,$6A,$FB,$A9,$FD,$5B,$48,$14,$EF
	dc.b $EB,$C5,$8B,$91,$11,$74,$5F,$CA,$AB,$2A,$59,$4D,$15,$06,$00,$DE
	dc.b $80,$82,$C2,$60,$78,$35,$EC,$00,$3A,$56,$2B,$0E,$14,$F2,$A5,$8E
	dc.b $C9,$E2,$E3,$23,$50,$22,$12,$36,$48,$2F,$21,$20,$06,$E9,$DE,$E1
	dc.b $E7,$DB,$D2,$D5,$1B,$38,$29,$11,$21,$2F,$26,$0C,$FB,$04,$00,$ED
	dc.b $DD,$E1,$E6,$D6,$CF,$E1,$E7,$E3,$ED,$F3,$F3,$FF,$19,$20,$12,$11
	dc.b $14,$02,$F5,$F9,$F9,$F6,$01,$0A,$0C,$04,$0B,$08,$14,$1C,$14,$07
	dc.b $05,$01,$0F,$19,$17,$02,$02,$05,$0D,$05,$08,$F3,$05,$02,$F7,$EA
	dc.b $F2,$FA,$F2,$F1,$FB,$F6,$01,$0D,$0F,$09,$0D,$0B,$14,$09,$0E,$08
	dc.b $08,$08,$08,$0E,$0B,$F8,$FE,$0B,$0D,$FB,$F7,$FC,$02,$FD,$01,$F6
	dc.b $FB,$FB,$FD,$00,$04,$04,$07,$0E,$0F,$09,$08,$11,$14,$17,$12,$FD
	dc.b $0B,$19,$1B,$0F,$0B,$0F,$0B,$10,$12,$08,$01,$07,$08,$0D,$01,$F6
	dc.b $FD,$0D,$0A,$F7,$F6,$04,$02,$FC,$01,$FA,$FD,$FF,$02,$03,$FC,$FB
	dc.b $FC,$00,$04,$01,$01,$05,$FA,$FD,$0B,$07,$FA,$FE,$0B,$06,$03,$02
	dc.b $06,$05,$0C,$0C,$03,$FE,$0F,$0A,$10,$0D,$04,$06,$14,$13,$0C,$0A
	dc.b $17,$09,$02,$0E,$16,$04,$F9,$FE,$04,$09,$04,$FD,$FE,$04,$05,$00
	dc.b $01,$05,$05,$04,$0C,$01,$F7,$03,$0D,$02,$01,$06,$01,$F8,$FB,$06
	dc.b $0A,$01,$F9,$F6,$FC,$09,$FF,$EE,$F4,$FF,$F9,$FD,$FF,$FC,$F9,$05
	dc.b $0E,$09,$03,$0B,$06,$01,$08,$14,$04,$FC,$06,$0B,$09,$0E,$09,$00
	dc.b $00,$0B,$0B,$00,$02,$0B,$00,$FD,$0A,$0B,$01,$05,$08,$06,$0C,$0E
	dc.b $FF,$F6,$0C,$17,$07,$F7,$03,$0D,$02,$01,$0F,$0D,$FD,$FD,$00,$07
	dc.b $10,$13,$FC,$F3,$04,$13,$0C,$00,$07,$10,$04,$FA,$07,$14,$07,$FE
	dc.b $04,$0B,$09,$00,$FE,$FA,$FC,$FE,$01,$FA,$EE,$EA,$F4,$1A,$31,$36
	dc.b $32,$0A,$ED,$F6,$FF,$FC,$EE,$E2,$D6,$B7,$CD,$3A,$6C,$19,$D4,$DE
	dc.b $24,$5E,$44,$F1,$CD,$E5,$E0,$AD,$90,$C8,$6A,$5B,$18,$CD,$CF,$F6
	dc.b $53,$7F,$3E,$9E,$B0,$E0,$B4,$85,$C1,$69,$7F,$F8,$A6,$B6,$F5,$47
	dc.b $7F,$29,$90,$86,$D7,$A5,$80,$F1,$7F,$4B,$B2,$83,$D6,$F9,$46,$7E
	dc.b $23,$97,$80,$BE,$93,$80,$F0,$7F,$35,$91,$8E,$E9,$41,$7A,$70,$CE
	dc.b $81,$92,$98,$80,$F1,$6C,$64,$B6,$85,$C4,$30,$70,$7A,$F5,$8B,$83
	dc.b $9F,$80,$BE,$7F,$58,$CA,$80,$C9,$20,$7F,$7F,$46,$8F,$84,$8B,$84
	dc.b $80,$63,$7F,$E2,$81,$BA,$3C,$72,$7F,$1C,$93,$80,$88,$80,$BB,$55
	dc.b $77,$D0,$80,$BE,$5C,$7F,$70,$05,$8E,$81,$81,$80,$D9,$7F,$6D,$C7
	dc.b $80,$D1,$5F,$7F,$63,$DA,$92,$96,$82,$89,$E6,$66,$58,$C0,$82,$D8
	dc.b $77,$7A,$4D,$E0,$AF,$A7,$86,$80,$DA,$7F,$62,$D1,$89,$DC,$5D,$7B
	dc.b $40,$C3,$CB,$CF,$90,$80,$8F,$33,$7F,$43,$A4,$8F,$19,$7B,$4C,$F7
	dc.b $E7,$F6,$BB,$85,$84,$B0,$2E,$7B,$4D,$DF,$A7,$20,$7B,$63,$0E,$E4
	dc.b $F1,$DA,$AE,$B6,$D6,$AE,$DC,$68,$6F,$0C,$BF,$1F,$74,$5E,$01,$ED
	dc.b $FD,$0C,$F0,$DE,$E3,$F0,$E1,$C3,$E8,$4F,$6C,$34,$F4,$06,$37,$45
	dc.b $1D,$14,$13,$0F,$FE,$F4,$FE,$0F,$04,$FA,$FC,$FC,$EF,$FE,$29,$40
	dc.b $1F,$0A,$2A,$33,$17,$0A,$16,$15,$04,$F7,$02,$FF,$F7,$01,$0E,$FE
	dc.b $F2,$FD,$09,$04,$0C,$12,$09,$01,$0D,$12,$0B,$0C,$15,$12,$01,$07
	dc.b $09,$05,$09,$15,$0B,$FF,$FE,$0C,$07,$0F,$13,$0E,$07,$10,$0E,$0A
	dc.b $0F,$17,$0D,$07,$10,$12,$04,$08,$1D,$10,$0A,$0A,$0D,$0B,$12,$12
	dc.b $06,$07,$16,$11,$06,$0B,$11,$0F,$0C,$0E,$04,$06,$11,$0F,$04,$09
	dc.b $12,$07,$FF,$0D,$0F,$02,$03,$0F,$06,$FB,$04,$0D,$05,$07,$0C,$00
	dc.b $04,$10,$07,$FD,$08,$19,$04,$FB,$08,$0B,$07,$0D,$0C,$04,$FF,$0C
	dc.b $04,$08,$10,$0A,$01,$0A,$0A,$04,$06,$14,$10,$05,$06,$0B,$07,$05
	dc.b $0E,$10,$07,$03,$00,$03,$0E,$11,$02,$FB,$08,$09,$FC,$00,$0C,$0B
	dc.b $02,$01,$FC,$01,$08,$0B,$02,$06,$0D,$00,$F8,$05,$16,$0E,$06,$05
	dc.b $04,$04,$0A,$07,$06,$11,$0D,$FD,$FC,$0E,$0D,$01,$06,$0D,$03,$FE
	dc.b $05,$0A,$0C,$11,$0A,$00,$03,$11,$08,$05,$0B,$08,$FE,$02,$0C,$03
	dc.b $02,$0F,$0F,$FC,$FF,$0F,$09,$FF,$07,$0B,$FE,$01,$04,$04,$0A,$13
	dc.b $02,$F8,$07,$12,$02,$FE,$0C,$0F,$FF,$FB,$06,$0E,$0B,$07,$00,$02
	dc.b $0A,$08,$F6,$02,$16,$0B,$F5,$FD,$10,$0A,$FB,$03,$08,$05,$00,$FF
	dc.b $FE,$0A,$12,$02,$F5,$06,$12,$03,$F9,$08,$0E,$01,$FB,$06,$08,$05
	dc.b $06,$05,$00,$04,$09,$FE,$FE,$0D,$0F,$FE,$FB,$08,$07,$FE,$02,$0D
	dc.b $03,$FE,$03,$05,$00,$04,$0A,$03,$F8,$00,$06,$FF,$00,$07,$04,$FC
	dc.b $01,$09,$FE,$FD,$08,$0C,$FD,$FB,$08,$0B,$FE,$FF,$0B,$09,$FE,$FD
	dc.b $05,$06,$07,$0A,$00,$FA,$03,$0A,$00,$FC,$0A,$10,$FD,$F2,$02,$0D
	dc.b $03,$FC,$02,$03,$FD,$FD,$03,$03,$02,$04,$02,$FA,$FC,$09,$09,$F9
	dc.b $FA,$0B,$09,$F8,$F9,$0C,$0F,$00,$FA,$06,$08,$FF,$FB,$00,$02,$FF
	dc.b $02,$03,$FC,$FE,$0C,$0E,$01,$FC,$0A,$15,$0E,$08,$09,$07,$F7,$E9
	dc.b $EE,$FD,$F7,$E3,$D9,$ED,$1F,$36,$29,$2A,$20,$05,$E4,$FF,$FC,$EA
	dc.b $DE,$DB,$C1,$AA,$1B,$71,$4D,$DB,$D0,$07,$41,$47,$1A,$E9,$E5,$DB
	dc.b $C3,$A7,$A3,$F5,$5B,$67,$03,$A9,$BA,$06,$58,$71,$1D,$BA,$C4,$E1
	dc.b $AB,$80,$9E,$29,$7D,$3F,$D7,$A1,$CA,$10,$7F,$64,$E1,$93,$CC,$CE
	dc.b $8E,$80,$AD,$7C,$6C,$05,$AE,$AA,$D0,$39,$7A,$4C,$9F,$9E,$D3,$B3
	dc.b $80,$8D,$4B,$7D,$79,$B8,$AF,$B5,$FD,$54,$7F,$16,$97,$B0,$E0,$9D
	dc.b $80,$AC,$39,$77,$2D,$E6,$94,$C6,$04,$6D,$77,$03,$A9,$C5,$DD,$90
	dc.b $93,$A5,$F7,$74,$5C,$07,$A2,$C2,$0B,$64,$7A,$30,$B4,$BD,$F2,$C5
	dc.b $A0,$C6,$B8,$AD,$3E,$69,$0F,$A8,$DA,$22,$5A,$71,$29,$C6,$E2,$00
	dc.b $D5,$C1,$DA,$EC,$9A,$E3,$7E,$54,$E9,$C6,$04,$ED,$44,$66,$2D,$DE
	dc.b $F7,$0A,$DE,$D3,$F6,$01,$D1,$B4,$D2,$33,$5E,$36,$FC,$E8,$04,$1C
	dc.b $42,$32,$08,$FC,$FF,$F5,$F0,$FA,$06,$FB,$EF,$EE,$EE,$E9,$ED,$07
	dc.b $24,$2C,$0C,$06,$0C,$1C,$23,$18,$0A,$03,$00,$FB,$FE,$FC,$FC,$00
	dc.b $FF,$F3,$F5,$03,$03,$F9,$02,$0C,$00,$F8,$07,$13,$0D,$0E,$12,$0B
	dc.b $02,$08,$11,$07,$F9,$FE,$08,$01,$FA,$01,$05,$FE,$00,$0A,$04,$F8
	dc.b $01,$0B,$04,$FE,$05,$07,$00,$00,$05,$04,$FF,$05,$08,$01,$FC,$05
	dc.b $05,$FE,$02,$08,$00,$F7,$00,$04,$02,$FF,$04,$01,$FF,$06,$09,$FE
	dc.b $FD,$09,$0A,$FF,$FB,$02,$04,$00,$03,$06,$FB,$FD,$07,$0A,$02,$03
	dc.b $0A,$05,$FE,$02,$07,$FF,$FF,$06,$07,$FF,$00,$06,$02,$FD,$07,$0A
	dc.b $00,$FF,$07,$03,$FA,$FA,$06,$03,$FF,$04,$03,$FC,$FC,$07,$07,$FF
	dc.b $02,$07,$FC,$F6,$01,$06,$FC,$FA,$05,$00,$FC,$00,$03,$FE,$FF,$09
	dc.b $07,$FC,$FD,$04,$00,$FA,$FF,$05,$FF,$FA,$01,$03,$FE,$03,$09,$04
	dc.b $FD,$04,$0B,$FF,$FC,$04,$06,$FF,$FE,$04,$02,$FD,$00,$06,$02,$00
	dc.b $05,$04,$FC,$FC,$08,$05,$FC,$FD,$04,$01,$FC,$FF,$03,$00,$00,$02
	dc.b $01,$FB,$FE,$06,$01,$FB,$00,$05,$00,$FE,$02,$02,$FF,$FF,$01,$01
	dc.b $FF,$02,$01,$00,$FF,$FF,$02,$02,$FF,$FF,$04,$02,$FC,$FE,$02,$01
	dc.b $FF,$FF,$01,$01,$00,$00,$01,$00,$00,$03,$05,$00,$FF,$01,$03,$00
	dc.b $FF,$01,$03,$00,$FF,$00,$FF,$FE,$01,$02,$01,$FF,$FF,$01,$02,$01
	dc.b $02,$04,$04,$03,$05,$07,$06,$05,$01,$FB,$F6,$F4,$F6,$F6,$F9,$F8
	dc.b $F5,$F6,$FF,$12,$19,$10,$13,$3B,$1B,$FF,$F5,$EC,$DF,$DF,$E4,$E0
	dc.b $F2,$09,$30,$1E,$09,$F9,$EC,$F7,$1D,$6A,$48,$02,$D4,$C8,$B1,$B3
	dc.b $DF,$05,$66,$47,$13,$D8,$CC,$D3,$04,$54,$7B,$3B,$C4,$AB,$9D,$90
	dc.b $B5,$12,$6E,$66,$1F,$E3,$A6,$AC,$FA,$4B,$7A,$54,$C5,$89,$8E,$80
	dc.b $A1,$17,$6C,$73,$2D,$C6,$84,$A3,$01,$54,$7F,$41,$B7,$88,$80,$80
	dc.b $A7,$39,$7F,$6C,$17,$A3,$83,$B3,$02,$73,$7B,$25,$90,$81,$80,$82
	dc.b $EF,$7F,$7F,$67,$E8,$8D,$8A,$BF,$50,$7E,$64,$A1,$8B,$81,$80,$B8
	dc.b $4C,$7F,$7C,$54,$9A,$81,$91,$F1,$68,$71,$02,$B2,$83,$80,$8C,$F1
	dc.b $6F,$7E,$68,$CE,$84,$80,$92,$3D,$7F,$54,$ED,$99,$80,$80,$80,$29
	dc.b $7F,$7D,$41,$B7,$80,$80,$EE,$7F,$78,$2C,$D9,$90,$80,$80,$9F,$65
	dc.b $7F,$7A,$2D,$9F,$82,$A8,$41,$7F,$6C,$2E,$CA,$8A,$80,$80,$DE,$63
	dc.b $7F,$7F,$25,$99,$86,$C2,$40,$7F,$6F,$26,$DD,$84,$80,$81,$9F,$1E
	dc.b $78,$7B,$5E,$DA,$87,$C4,$0C,$7D,$6D,$45,$0B,$C4,$9D,$85,$AE,$E8
	dc.b $FF,$46,$56,$33,$15,$DC,$D6,$1E,$2D,$59,$43,$1A,$FE,$D9,$D0,$D2
	dc.b $E7,$07,$13,$0B,$F9,$DF,$ED,$00,$13,$32,$32,$23,$12,$FE,$02,$FE
	dc.b $12,$1B,$14,$13,$00,$F2,$F1,$F3,$FE,$05,$0A,$10,$08,$03,$FD,$FE
	dc.b $02,$07,$11,$0E,$0D,$0A,$07,$07,$07,$0A,$0E,$0F,$0F,$0A,$05,$03
	dc.b $01,$03,$08,$09,$0A,$0A,$04,$03,$02,$03,$05,$08,$0A,$0C,$0A,$07
	dc.b $04,$01,$03,$05,$08,$0A,$09,$08,$05,$02,$03,$04,$08,$0B,$0B,$0A
	dc.b $06,$02,$01,$03,$06,$08,$09,$09,$05,$03,$02,$03,$07,$0B,$0C,$0A
	dc.b $04,$00,$FF,$01,$05,$08,$0A,$08,$04,$02,$03,$03,$09,$0C,$0D,$09
	dc.b $03,$FF,$FF,$03,$06,$09,$0A,$04,$01,$01,$03,$07,$0B,$0C,$0B,$05
	dc.b $00,$FD,$FF,$03,$07,$09,$06,$01,$FE,$FD,$01,$06,$09,$09,$06,$00
	dc.b $FC,$FA,$FD,$02,$07,$07,$04,$FF,$FC,$FD,$03,$08,$0B,$09,$05,$FF
	dc.b $FC,$FC,$FF,$04,$07,$06,$03,$00,$FE,$FF,$05,$09,$0A,$08,$04,$00
	dc.b $FD,$FD,$01,$05,$05,$04,$01,$FF,$FF,$02,$05,$07,$08,$06,$04,$01
	dc.b $FF,$FF,$02,$04,$04,$03,$01,$FF,$00,$01,$04,$05,$05,$03,$03,$01
	dc.b $01,$02,$03,$03,$04,$03,$02,$02,$02,$04,$05,$04,$03,$02,$02,$02
	dc.b $02,$03,$03,$03,$03,$03,$02,$02,$02,$03,$02,$02,$02,$02,$02,$02
splRire2:
	dc.b $02,$02,$00,$01,$01,$01,$02,$03,$02,$01,$00,$00,$00,$01,$01,$02
	dc.b $02,$01,$00,$00,$00,$02,$03,$03,$02,$01,$00,$00,$00,$01,$01,$02
	dc.b $01,$01,$00,$00,$01,$02,$03,$03,$02,$01,$00,$00,$00,$01,$02,$03
	dc.b $02,$02,$01,$01,$02,$03,$03,$03,$01,$00,$00,$00,$01,$02,$03,$03
	dc.b $03,$02,$01,$01,$02,$03,$03,$03,$01,$01,$00,$00,$01,$02,$03,$03
	dc.b $03,$02,$02,$01,$02,$03,$02,$02,$02,$01,$FF,$FE,$00,$01,$02,$03
	dc.b $03,$02,$01,$01,$01,$02,$03,$03,$02,$01,$00,$FF,$FF,$00,$01,$01
	dc.b $01,$00,$00,$00,$01,$02,$05,$06,$08,$08,$07,$07,$07,$06,$04,$01
	dc.b $FD,$FA,$F8,$F7,$F8,$FB,$FD,$FF,$FF,$01,$05,$06,$0A,$09,$12,$18
	dc.b $15,$11,$FC,$F3,$ED,$E3,$E6,$E9,$F1,$FD,$04,$13,$0F,$0C,$05,$FC
	dc.b $FB,$08,$19,$25,$20,$0A,$F6,$E1,$D3,$CF,$D9,$EF,$09,$27,$28,$24
	dc.b $08,$F6,$EB,$F1,$1A,$29,$31,$23,$FF,$E8,$CB,$BD,$C9,$DC,$08,$39
	dc.b $31,$2F,$11,$EF,$E0,$DE,$0C,$30,$38,$33,$07,$ED,$C5,$AB,$B8,$CA
	dc.b $FD,$3D,$36,$38,$18,$E9,$D7,$CE,$F7,$3D,$36,$3E,$1A,$EB,$CB,$AB
	dc.b $AC,$D0,$E9,$1E,$42,$29,$1E,$F6,$D7,$DD,$E1,$15,$55,$42,$2D,$07
	dc.b $DB,$C9,$B9,$CC,$EC,$FB,$03,$0F,$0E,$09,$00,$FA,$00,$05,$0D,$1B
	dc.b $36,$22,$12,$FE,$EE,$E9,$E5,$E8,$FA,$F7,$F8,$F5,$EB,$E2,$F4,$05
	dc.b $12,$21,$1A,$0C,$02,$F4,$FC,$0C,$12,$16,$0F,$FF,$F6,$E8,$E6,$F1
	dc.b $F7,$FF,$05,$00,$FD,$F7,$F4,$F5,$F8,$FF,$0A,$0C,$0C,$08,$02,$FE
	dc.b $FF,$01,$06,$09,$03,$02,$FD,$F9,$F9,$FA,$FD,$02,$02,$01,$00,$FE
	dc.b $FD,$FE,$FF,$01,$02,$01,$02,$00,$FF,$00,$01,$02,$03,$02,$02,$01
	dc.b $00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$01,$01,$00,$FF,$FE,$FF
	dc.b $FF,$FF,$00,$01,$00,$FF,$FE,$FD,$FD,$FE,$FF,$00,$00,$FF,$FE,$FD
	dc.b $FD,$FD,$FE,$FF,$00,$00,$FF,$FF,$FE,$FE,$FD,$FE,$FD,$FE,$FE,$FF
	dc.b $FE,$FE,$FE,$FE,$FE,$FF,$00,$01,$01,$00,$FF,$FF,$FE,$FD,$FE,$FE
	dc.b $FE,$FE,$FE,$FE,$FE,$FD,$FE,$FE,$FF,$00,$00,$00,$00,$01,$01,$00
	dc.b $00,$FF,$FF,$00,$00,$00,$00,$00,$00,$00,$FF,$00,$00,$01,$01,$01
	dc.b $01,$00,$FF,$FE,$FE,$FE,$FF,$FF,$FF,$FF,$FE,$FD,$FD,$FD,$FE,$FE
	dc.b $FF,$FF,$FF,$FF,$FF,$FE,$FE,$FD,$FE,$FE,$FF,$FF,$FF,$FF,$FE,$FE
	dc.b $FD,$FE,$FE,$FF,$00,$00,$00,$00,$FF,$FE,$FE,$FF,$00,$FF,$01,$01
	dc.b $FF,$FF,$FF,$FE,$FE,$FF,$00,$FF,$FF,$00,$FF,$FE,$FE,$FE,$FE,$FF
	dc.b $00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$01,$00,$FF,$00
	dc.b $00,$FF,$FF,$01,$01,$FF,$FF,$00,$FF,$FF,$00,$01,$00,$00,$00,$00
	dc.b $00,$FF,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01
	dc.b $01,$00,$00,$00,$00,$FF,$FE,$FE,$FD,$FD,$FE,$FF,$00,$01,$01,$02
	dc.b $02,$02,$01,$01,$02,$03,$03,$02,$FF,$FC,$F8,$F5,$F5,$F8,$FA,$FC
	dc.b $FE,$00,$FD,$FB,$FD,$00,$05,$0C,$16,$1F,$20,$17,$0A,$F8,$E6,$DD
	dc.b $DE,$E2,$EB,$F8,$05,$02,$01,$07,$08,$01,$01,$06,$06,$17,$36,$31
	dc.b $13,$F7,$DE,$C5,$B8,$C2,$DA,$F3,$11,$2E,$32,$1A,$02,$F1,$E0,$E6
	dc.b $13,$48,$4B,$25,$05,$D6,$A5,$91,$A2,$CC,$06,$48,$62,$48,$1B,$F4
	dc.b $C3,$B2,$F5,$49,$5E,$40,$17,$E7,$A3,$82,$86,$BA,$11,$5B,$74,$61
	dc.b $29,$E2,$B7,$99,$F6,$54,$60,$36,$16,$DF,$91,$80,$8E,$E5,$34,$6A
	dc.b $7C,$5A,$03,$C5,$A3,$AF,$29,$5E,$3E,$1D,$FC,$B6,$86,$82,$E4,$1F
	dc.b $4F,$73,$69,$15,$CD,$C1,$C7,$14,$5C,$35,$0D,$F3,$B3,$87,$99,$FA
	dc.b $33,$4D,$75,$62,$00,$C1,$C5,$EC,$2E,$51,$29,$F9,$D4,$9A,$83,$BF
	dc.b $13,$47,$61,$7B,$44,$DA,$AC,$CF,$04,$46,$50,$13,$F4,$BD,$83,$90
	dc.b $E1,$37,$54,$7A,$79,$1B,$BC,$A9,$D6,$1D,$52,$4E,$14,$EB,$9F,$80
	dc.b $9D,$FC,$42,$69,$7D,$5F,$F1,$A4,$AF,$DE,$35,$64,$48,$15,$E6,$86
	dc.b $80,$99,$09,$52,$79,$7F,$50,$DB,$92,$AC,$D9,$4A,$77,$51,$26,$E0
	dc.b $8C,$80,$95,$F7,$42,$7E,$7F,$54,$E7,$88,$88,$B7,$3B,$7E,$64,$3C
	dc.b $07,$98,$80,$80,$9C,$26,$6E,$7F,$73,$17,$B3,$86,$80,$E5,$6C,$7D
	dc.b $68,$3A,$DC,$8D,$80,$80,$8E,$E4,$65,$7F,$5E,$26,$DB,$8B,$85,$ED
	dc.b $3E,$76,$7A,$44,$F4,$BA,$8D,$80,$BA,$F7,$17,$16,$00,$F3,$F1,$EF
	dc.b $F6,$17,$2A,$24,$23,$17,$03,$0D,$12,$10,$0E,$0D,$FD,$EE,$E5,$E3
	dc.b $EA,$F4,$FF,$00,$01,$FB,$F7,$F6,$F6,$04,$11,$18,$15,$12,$06,$FD
	dc.b $FB,$FD,$06,$10,$11,$09,$00,$FA,$F8,$FB,$01,$07,$0A,$07,$00,$FC
	dc.b $FB,$FB,$00,$05,$07,$06,$02,$FE,$FB,$FC,$FE,$02,$06,$07,$04,$FE
	dc.b $FC,$FD,$FD,$00,$03,$04,$03,$01,$FF,$00,$00,$02,$04,$05,$04,$02
	dc.b $00,$FE,$FE,$00,$02,$03,$04,$02,$00,$FF,$FF,$00,$02,$04,$05,$04
	dc.b $02,$FF,$FE,$FD,$FF,$01,$02,$03,$03,$01,$00,$00,$00,$00,$02,$03
	dc.b $03,$02,$00,$FF,$FE,$FE,$FF,$02,$02,$02,$02,$01,$00,$00,$00,$01
	dc.b $02,$02,$01,$00,$FF,$FE,$FE,$FF,$00,$00,$01,$01,$02,$01,$01,$00
	dc.b $01,$01,$01,$00,$00,$00,$FF,$FF,$FF,$FF,$00,$01,$02,$02,$02,$01
	dc.b $02,$02,$02,$02,$01,$00,$00,$00,$00,$01,$01,$01,$01,$01,$01,$00
	dc.b $00,$00,$01,$01,$02,$02,$01,$00,$FF,$FF,$FF,$00,$00,$01,$01,$00
	dc.b $FF,$FF,$FF,$FF,$FF,$00,$01,$01,$01,$01,$00,$FF,$FF,$FF,$00,$02
	dc.b $02,$02,$01,$00,$FF,$FF,$FF,$FF,$00,$00,$01,$01,$01,$00,$FF,$FF
	dc.b $FF,$00,$01,$01,$02,$02,$01,$00,$00,$FF,$00,$01,$02,$02,$02,$01
	dc.b $00,$00,$FF,$00,$01,$01,$02,$01,$01,$00,$00,$FF,$00,$00,$01,$01
	dc.b $01,$01,$01,$00,$00,$00,$00,$00,$01,$01,$00,$00,$00,$00,$00,$00
	dc.b $01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$FF,$FF,$FF,$00,$00
	dc.b $00,$00,$00,$00,$00,$FF,$00,$00,$00,$00,$00,$00,$FF,$FF,$FF,$00
	dc.b $00,$00,$00,$01,$00,$00,$FF,$FF,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b $00,$00,$00,$01,$00,$00,$00,$00,$00,$00,$00,$FF,$FF,$FF,$FF,$FF
	dc.b $FF,$00,$00,$00,$00,$00,$00,$00,$FF,$FF,$FF,$00,$00,$00,$FF,$FF
	dc.b $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$00
	dc.b $00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$00,$00
	dc.b $00,$FF,$00,$00,$00,$00,$00,$00,$00,$FF,$FF,$FE,$FC,$FA,$FC,$FE
	dc.b $FF,$01,$00,$FF,$00,$00,$01,$02,$04,$04,$04,$03,$02,$02,$00,$FD
	dc.b $FB,$F9,$F9,$FA,$FB,$FC,$FB,$FC,$FC,$FB,$FE,$04,$08,$09,$05,$04
	dc.b $0E,$12,$0F,$09,$FF,$F0,$EB,$EC,$F2,$F6,$FD,$FA,$F9,$FC,$03,$0A
	dc.b $0D,$07,$00,$FD,$FD,$0C,$24,$1F,$08,$F7,$DF,$DE,$E7,$F1,$F7,$FE
	dc.b $FC,$FE,$0C,$09,$03,$07,$02,$FD,$04,$13,$2B,$21,$06,$FA,$E5,$DB
	dc.b $DD,$ED,$EF,$FD,$03,$0B,$13,$09,$FA,$FB,$FB,$02,$0F,$2A,$2F,$15
	dc.b $F0,$EA,$DB,$DD,$E7,$EA,$F4,$04,$10,$18,$0E,$FB,$F7,$F8,$02,$13
	dc.b $23,$3C,$17,$F5,$E6,$D9,$DB,$E9,$E7,$F0,$05,$16,$1A,$0D,$F8,$F0
	dc.b $F5,$05,$14,$24,$3D,$16,$F4,$E2,$D1,$DC,$EA,$E2,$EB,$05,$19,$1D
	dc.b $0C,$F6,$EC,$F4,$05,$16,$24,$3F,$16,$F1,$DE,$CC,$DF,$EB,$DD,$E9
	dc.b $05,$1E,$1F,$0E,$F8,$E7,$F2,$05,$18,$2D,$41,$15,$ED,$DB,$C7,$E1
	dc.b $EC,$DD,$EA,$0D,$23,$1D,$0B,$F5,$E2,$F7,$0A,$1D,$34,$3D,$0B,$E7
	dc.b $D9,$C3,$E7,$EA,$D9,$EC,$13,$22,$1D,$06,$EC,$DE,$FC,$11,$23,$3D
	dc.b $37,$F9,$E3,$D6,$CA,$EA,$E6,$D7,$F6,$21,$22,$17,$06,$E1,$E3,$05
	dc.b $17,$2C,$44,$26,$E8,$E3,$D1,$D7,$EA,$DE,$DC,$0A,$26,$1E,$0E,$00
	dc.b $D3,$F0,$12,$1F,$44,$46,$07,$DE,$DF,$D0,$E8,$E6,$D6,$ED,$22,$1F
	dc.b $17,$0C,$DC,$DD,$06,$1D,$2B,$54,$24,$E6,$E9,$DA,$DD,$EA,$DA,$D3
	dc.b $0D,$2C,$1D,$0D,$F3,$C9,$F3,$1A,$23,$42,$34,$F6,$DB,$E4,$D8,$E9
	dc.b $E3,$D0,$F6,$36,$24,$04,$00,$D2,$E2,$14,$22,$2D,$3D,$0B,$D5,$E9
	dc.b $DB,$E5,$E8,$CC,$D7,$40,$34,$0E,$07,$E0,$CD,$04,$2D,$25,$41,$1F
	dc.b $CE,$E1,$EA,$E1,$E9,$D1,$C1,$18,$47,$24,$00,$F3,$C4,$F4,$37,$2F
	dc.b $30,$2F,$E7,$D8,$F9,$EA,$E6,$DA,$B2,$E3,$55,$4D,$FF,$ED,$C0,$D8
	dc.b $35,$4A,$1F,$2C,$04,$DB,$FC,$00,$E5,$DC,$C0,$B0,$36,$6A,$1D,$DA
	dc.b $CF,$C6,$0F,$5E,$30,$03,$1B,$EF,$F7,$10,$EF,$D5,$CB,$AF,$EC,$78
	dc.b $4A,$CA,$CB,$CA,$EC,$48,$54,$FA,$F8,$FE,$03,$10,$07,$D4,$CC,$C3
	dc.b $C2,$5E,$6D,$04,$AF,$D0,$DD,$1D,$5C,$23,$CC,$01,$21,$12,$05,$E3
	dc.b $CB,$CE,$C7,$03,$77,$35,$CB,$C0,$E2,$0C,$42,$3D,$E3,$D6,$1A,$25
	dc.b $03,$E6,$D6,$D3,$C6,$E5,$42,$4D,$F7,$C2,$DE,$03,$2C,$3C,$08,$CD
	dc.b $0C,$29,$0B,$E8,$E3,$E1,$D5,$D0,$10,$4B,$1E,$D8,$D2,$F8,$17,$32
	dc.b $21,$EA,$FD,$25,$0F,$EC,$E7,$EC,$E1,$D1,$F1,$36,$30,$ED,$D1,$F6
	dc.b $0C,$22,$2C,$FF,$F2,$20,$1E,$F6,$E5,$EF,$EC,$DC,$E2,$16,$38,$03
	dc.b $D8,$E8,$02,$16,$25,$10,$F0,$0C,$26,$02,$E8,$EF,$F6,$E7,$D8,$FD
	dc.b $2E,$1E,$F0,$E0,$F4,$0D,$1C,$1A,$FF,$F6,$1F,$1E,$F3,$E6,$FE,$FA
	dc.b $E8,$DE,$00,$25,$1B,$F5,$E5,$F4,$0C,$1A,$15,$00,$FC,$14,$14,$FA
	dc.b $F0,$02,$FA,$ED,$E2,$F3,$15,$23,$03,$E5,$E8,$07,$16,$16,$06,$F8
	dc.b $00,$13,$0E,$FA,$F6,$00,$FF,$EF,$E6,$F5,$0D,$19,$08,$F2,$EE,$01
	dc.b $14,$13,$04,$FA,$01,$06,$09,$02,$FA,$FA,$FF,$FC,$F5,$F0,$F9,$0D
	dc.b $0F,$FF,$F7,$FD,$06,$08,$08,$03,$FE,$00,$04,$01,$FD,$FF,$02,$FF
	dc.b $F9,$FA,$FB,$FD,$02,$05,$02,$FE,$FF,$03,$03,$02,$02,$01,$01,$02
	dc.b $02,$FF,$FE,$00,$01,$FF,$FF,$FF,$FF,$00,$00,$01,$01,$00,$00,$01
	dc.b $01,$01,$02,$01,$FF,$FF,$01,$01,$00,$00,$00,$FF,$00,$01,$01,$FF
	dc.b $FF,$00,$01,$01,$01,$01,$FF,$FF,$00,$01,$01,$00,$00,$00,$00,$01
	dc.b $01,$00,$00,$00,$01,$02,$02,$02,$01,$00,$00,$01,$01,$01,$01,$00
	dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

splJuron:
	dc.b $00,$09,$EA,$DF,$05,$F1,$FC,$1A,$46,$04,$BD,$B1,$F9,$37,$36,$15
	dc.b $F7,$F2,$E1,$F0,$0F,$31,$FD,$BE,$CC,$05,$32,$1C,$FE,$EF,$F6,$EB
	dc.b $12,$28,$2F,$FA,$BC,$B1,$EF,$2A,$2F,$1E,$FC,$E6,$CB,$F5,$30,$3D
	dc.b $F4,$C3,$CF,$0F,$43,$1B,$F9,$E4,$D6,$D8,$17,$57,$4A,$C7,$99,$B8
	dc.b $34,$45,$46,$1D,$E8,$BB,$BD,$0F,$5B,$26,$D6,$C6,$C8,$0E,$28,$38
	dc.b $FE,$E7,$C0,$EA,$49,$6E,$0A,$9A,$96,$BF,$1E,$4B,$76,$07,$BF,$90
	dc.b $C2,$40,$71,$27,$A3,$B3,$D2,$14,$15,$50,$00,$AA,$A1,$FE,$65,$60
	dc.b $E0,$96,$B3,$D7,$3E,$51,$55,$F6,$86,$99,$00,$6A,$4D,$E3,$A2,$B2
	dc.b $F0,$23,$49,$2C,$E3,$B5,$02,$44,$65,$E8,$C4,$AE,$AF,$05,$59,$4C
	dc.b $04,$A3,$D4,$1F,$4B,$07,$EA,$E0,$C1,$11,$48,$31,$F6,$9B,$DB,$23
	dc.b $50,$29,$F3,$AD,$81,$F3,$58,$54,$0D,$B7,$EE,$36,$3A,$E8,$B9,$BE
	dc.b $C8,$FC,$5A,$74,$E4,$91,$C2,$4B,$59,$2C,$EB,$DA,$B0,$AD,$27,$6E
	dc.b $F1,$B6,$CC,$45,$68,$1D,$AB,$96,$BC,$00,$62,$75,$F4,$B3,$AE,$30
	dc.b $53,$22,$A9,$A6,$D6,$08,$48,$63,$E0,$9F,$BE,$55,$7E,$3F,$D5,$AB
	dc.b $8D,$E1,$42,$67,$D6,$A5,$E8,$6F,$59,$CD,$A1,$D6,$DF,$F6,$60,$7D
	dc.b $CB,$84,$C1,$49,$7F,$15,$A5,$B7,$BD,$FF,$38,$45,$0A,$AC,$F6,$6B
	dc.b $68,$E6,$A8,$B7,$DB,$CE,$44,$7C,$27,$8E,$B6,$3A,$44,$19,$00,$FF
	dc.b $E1,$AA,$0C,$5A,$4D,$89,$AE,$49,$49,$51,$1A,$BC,$81,$94,$24,$7E
	dc.b $64,$B7,$89,$D9,$52,$3A,$CD,$C3,$00,$FA,$06,$31,$5D,$A8,$95,$1B
	dc.b $7E,$5F,$CF,$95,$C5,$E1,$DD,$37,$7E,$EB,$B5,$F9,$7C,$1D,$C9,$CE
	dc.b $03,$DA,$02,$5D,$77,$8F,$86,$26,$7E,$5E,$F0,$DF,$97,$90,$F3,$69
	dc.b $4A,$DE,$A0,$16,$70,$06,$9C,$C8,$1D,$FD,$0F,$61,$65,$9C,$9A,$45
	dc.b $7C,$11,$B0,$D4,$EF,$B8,$C6,$5B,$7D,$E6,$C2,$17,$5F,$DD,$09,$0F
	dc.b $CE,$94,$11,$7A,$5A,$82,$91,$03,$73,$5C,$21,$D8,$C9,$AA,$D2,$41
	dc.b $7D,$BC,$98,$EA,$60,$5A,$BB,$83,$C6,$4B,$10,$57,$26,$04,$93,$0B
	dc.b $7C,$4F,$C4,$B3,$EE,$AB,$A8,$4E,$7C,$08,$88,$D2,$76,$13,$CF,$07
	dc.b $23,$BA,$C0,$51,$74,$BF,$87,$01,$7C,$56,$D4,$DB,$EC,$D7,$B2,$52
	dc.b $7C,$1A,$90,$AE,$7A,$08,$B2,$C4,$08,$1A,$E9,$45,$37,$DB,$AC,$52
	dc.b $7C,$07,$BE,$DB,$D2,$83,$A6,$4F,$7C,$28,$83,$C6,$54,$74,$3A,$D4
	dc.b $8D,$98,$F3,$53,$7C,$92,$A7,$2E,$7B,$27,$BD,$A0,$DC,$E7,$FA,$68
	dc.b $74,$BE,$95,$11,$65,$3F,$36,$03,$AE,$84,$E9,$70,$7B,$BF,$93,$1D
	dc.b $7B,$4E,$B7,$8E,$B4,$A4,$2A,$71,$55,$A9,$91,$35,$6A,$1F,$06,$30
	dc.b $B8,$85,$DE,$6A,$5D,$9A,$DB,$66,$7B,$E9,$B2,$C0,$09,$FD,$00,$56
	dc.b $1E,$CA,$C8,$09,$5E,$61,$63,$CA,$84,$95,$C2,$4C,$7B,$46,$96,$84
	dc.b $2F,$6C,$10,$BF,$E3,$C4,$DC,$61,$7A,$9D,$86,$22,$7A,$67,$DD,$87
	dc.b $8E,$94,$DD,$69,$7A,$C0,$95,$22,$7A,$1A,$B2,$E3,$27,$B9,$F6,$6D
	dc.b $36,$85,$AA,$4F,$76,$37,$EC,$E7,$89,$9D,$2E,$79,$06,$85,$C0,$40
	dc.b $7A,$22,$88,$8E,$DE,$25,$78,$43,$99,$A1,$36,$7A,$42,$91,$97,$14
	dc.b $DF,$91,$0C,$74,$40,$85,$AA,$42,$79,$32,$D9,$CA,$F6,$E5,$06,$2C
	dc.b $2C,$92,$E2,$5E,$79,$F7,$8C,$9A,$07,$DF,$4F,$79,$14,$86,$C4,$5B
	dc.b $41,$AB,$B0,$3C,$13,$DA,$E8,$34,$68,$BF,$02,$5A,$69,$F7,$8B,$87
	dc.b $EC,$C5,$67,$79,$F5,$86,$C7,$5D,$77,$E6,$91,$CA,$D0,$A5,$0F,$60
	dc.b $1D,$A5,$28,$73,$22,$97,$BF,$0B,$D0,$CA,$69,$6E,$92,$90,$13,$6D
	dc.b $ED,$06,$3A,$F2,$B3,$98,$F4,$56,$78,$CA,$BC,$EE,$38,$48,$D6,$8B
	dc.b $B3,$E8,$6D,$78,$F9,$87,$AD,$4E,$78,$25,$8D,$8F,$D5,$B7,$08,$77
	dc.b $31,$99,$FA,$6F,$39,$8D,$DB,$5A,$24,$99,$20,$78,$E4,$8E,$F7,$6D
	dc.b $66,$E7,$9E,$9B,$87,$CC,$72,$78,$8E,$8B,$FA,$71,$73,$BB,$9E,$05
	dc.b $DF,$CA,$3C,$5B,$AD,$95,$15,$75,$70,$A7,$91,$DB,$D1,$B5,$5B,$77
	dc.b $D1,$88,$E4,$69,$3E,$17,$2E,$09,$9A,$8A,$E8,$69,$6B,$95,$B8,$4C
	dc.b $70,$41,$B1,$8A,$8D,$F8,$71,$77,$C9,$89,$BA,$40,$77,$13,$D6,$EB
	dc.b $E0,$9C,$23,$75,$19,$93,$F2,$69,$5E,$90,$8B,$D8,$A6,$27,$73,$3A
	dc.b $88,$98,$1E,$76,$64,$A3,$8E,$D1,$94,$FF,$73,$2C,$89,$CD,$5B,$32
	dc.b $A5,$A3,$13,$36,$25,$A6,$EE,$50,$38,$9C,$BE,$4B,$6E,$43,$F1,$9A
	dc.b $89,$18,$76,$42,$91,$98,$0E,$6E,$43,$A3,$91,$CC,$C1,$68,$75,$CC
	dc.b $89,$B6,$59,$76,$39,$92,$8C,$AC,$9F,$10,$76,$2A,$89,$AB,$37,$62
	dc.b $47,$E7,$E1,$FB,$89,$EB,$74,$48,$8A,$A9,$3D,$6A,$0B,$E8,$E7,$DE
	dc.b $EA,$A8,$0E,$6E,$56,$9C,$A6,$0D,$30,$4C,$11,$E8,$97,$CF,$3E,$65
	dc.b $FE,$BC,$1C,$6F,$2A,$A3,$B6,$D7,$8A,$08,$75,$51,$8A,$96,$16,$74
	dc.b $1E,$A3,$D8,$FC,$B2,$D9,$75,$1A,$8A,$D6,$6A,$72,$F3,$8A,$A4,$9F
	dc.b $5E,$75,$32,$A4,$8A,$19,$66,$EA,$A1,$21,$66,$F7,$8B,$BA,$5F,$74
	dc.b $E2,$D6,$1F,$16,$FE,$F1,$C3,$AA,$EA,$32,$6D,$22,$8B,$AA,$39,$74
	dc.b $39,$A7,$A3,$DD,$F1,$F1,$3E,$08,$DB,$E4,$72,$49,$9A,$A7,$03,$2C
	dc.b $13,$0E,$CF,$DF,$42,$EE,$E1,$45,$66,$2C,$CE,$A8,$8B,$FC,$72,$63
	dc.b $B0,$8F,$FD,$6E,$32,$9F,$BF,$23,$74,$05,$8E,$D6,$6E,$30,$0B,$21
	dc.b $4F,$07,$D7,$C0,$A4,$B5,$50,$73,$1B,$90,$A5,$28,$5D,$49,$18,$DF
	dc.b $9C,$1A,$DB,$DE,$E7,$3F,$0F,$2F,$73,$1E,$A7,$C5,$E7,$02,$25,$71
	dc.b $31,$8C,$C0,$53,$4F,$B2,$F0,$58,$18,$C4,$9D,$D6,$4B,$6C,$28,$BD
	dc.b $D8,$37,$41,$C1,$8C,$CB,$24,$6D,$71,$D3,$8C,$05,$72,$57,$DF,$AE
	dc.b $D3,$E4,$C6,$0E,$53,$41,$D1,$2F,$39,$15,$D5,$F3,$06,$CE,$E3,$5C
	dc.b $72,$C1,$98,$F4,$70,$61,$30,$D3,$9E,$8D,$FD,$70,$72,$99,$9D,$2B
	dc.b $71,$23,$B8,$C6,$E3,$E3,$03,$69,$53,$A3,$C6,$44,$72,$4D,$C5,$8E
	dc.b $BC,$03,$16,$53,$48,$BE,$EB,$54,$5A,$A9,$EE,$15,$3A,$0B,$05,$AB
	dc.b $96,$4C,$6E,$D8,$B2,$09,$69,$32,$B2,$91,$A1,$07,$71,$60,$DC,$8E
	dc.b $F4,$64,$13,$BE,$DA,$1B,$3E,$02,$8E,$B2,$48,$4C,$17,$E0,$27,$47
	dc.b $E5,$94,$C9,$E5,$FA,$60,$5D,$D9,$8E,$EE,$4D,$3B,$0F,$DF,$DC,$F7
	dc.b $17,$EA,$1A,$0F,$BC,$32,$5A,$16,$CA,$00,$C4,$AF,$CC,$70,$67,$C5
	dc.b $97,$C4,$5E,$5D,$E1,$9F,$D0,$CD,$07,$6D,$1A,$9D,$8F,$64,$66,$DD
	dc.b $9B,$E9,$21,$F4,$8F,$C6,$65,$6F,$C0,$AA,$E1,$5A,$6D,$F5,$A1,$A1
	dc.b $B5,$6E,$6B,$C6,$8F,$E2,$5E,$31,$00,$F1,$BA,$D6,$50,$17,$CA,$1B
	dc.b $57,$0F,$DE,$09,$40,$0C,$D3,$B0,$95,$3D,$70,$11,$8F,$EA,$58,$32
	dc.b $DF,$D3,$05,$E7,$06,$CA,$C9,$0D,$68,$15,$F1,$02,$3B,$1D,$C1,$D5
	dc.b $09,$0F,$3E,$5E,$A8,$A4,$15,$5A,$1A,$DF,$E9,$E8,$EC,$14,$02,$01
	dc.b $19,$39,$17,$27,$FB,$DA,$1A,$2B,$C1,$90,$E2,$60,$6F,$C9,$96,$F3
	dc.b $6A,$59,$08,$C8,$91,$AA,$10,$68,$48,$9F,$A8,$3C,$6E,$1D,$90,$B2
	dc.b $0C,$D1,$35,$6E,$F6,$93,$F7,$68,$67,$AD,$91,$D6,$16,$4B,$D6,$DE
	dc.b $F7,$18,$F6,$45,$68,$22,$CF,$C1,$CE,$AE,$31,$6E,$0A,$9A,$FE,$53
	dc.b $F5,$D2,$16,$03,$11,$48,$E1,$91,$16,$6E,$17,$9D,$BC,$19,$4E,$24
	dc.b $B9,$A2,$AF,$1B,$6E,$4B,$C0,$C7,$42,$4C,$DB,$CC,$12,$DC,$D6,$15
	dc.b $06,$32,$FA,$E5,$2A,$32,$07,$27,$3E,$C7,$9E,$B5,$54,$6B,$19,$A3
	dc.b $BC,$25,$6D,$23,$94,$9C,$AE,$0A,$6D,$4E,$C1,$92,$26,$6D,$31,$AB
	dc.b $92,$DE,$18,$E1,$61,$42,$D6,$B6,$3D,$65,$1B,$AD,$A8,$E6,$C8,$FD
	dc.b $6D,$3F,$A4,$D0,$68,$40,$BB,$D4,$2E,$0B,$23,$40,$AC,$99,$09,$6A
	dc.b $42,$93,$98,$25,$6C,$50,$CA,$94,$93,$29,$6C,$38,$93,$B2,$34,$2D
	dc.b $D9,$E5,$FE,$AB,$E3,$5F,$F4,$9A,$E1,$63,$2A,$D7,$02,$3C,$1A,$BC
	dc.b $C9,$E8,$E0,$35,$6C,$E1,$A5,$0E,$4D,$10,$E9,$F4,$E4,$FA,$6A,$08
	dc.b $95,$C9,$59,$3B,$DF,$E3,$11,$F3,$0E,$EC,$D3,$C3,$5D,$65,$FE,$B6
	dc.b $E7,$5B,$1F,$EA,$F1,$F3,$A8,$C2,$55,$5A,$DE,$98,$EC,$6B,$38,$B8
	dc.b $BF,$0A,$C8,$CD,$6B,$47,$BA,$9C,$6A,$59,$E6,$B8,$05,$0F,$19,$DD
	dc.b $AC,$F8,$67,$37,$D3,$E4,$27,$51,$10,$A9,$94,$AA,$6B,$6B,$07,$98
	dc.b $A1,$4C,$5C,$17,$CC,$E0,$F0,$31,$03,$9F,$DF,$54,$2E,$D6,$F3,$40
	dc.b $4C,$05,$A4,$AF,$9F,$59,$6A,$F2,$95,$C7,$4C,$2A,$E6,$C3,$EE,$0F
	dc.b $61,$F0,$95,$EB,$6A,$3D,$B4,$D9,$1C,$4E,$1B,$B9,$B2,$BB,$01,$54
	dc.b $66,$A4,$9F,$22,$6A,$F7,$AA,$03,$30,$0B,$05,$F5,$D7,$E1,$1F,$41
	dc.b $1F,$FF,$E0,$15,$22,$AE,$BE,$49,$69,$ED,$A2,$FF,$3F,$37,$1B,$D9
	dc.b $C2,$B7,$D4,$40,$69,$16,$9C,$BE,$69,$5F,$0E,$B5,$DE,$E5,$E6,$0F
	dc.b $51,$15,$B1,$F1,$58,$32,$16,$02,$C6,$9B,$DA,$52,$69,$FC,$98,$E3
	dc.b $48,$4E,$1E,$DD,$BB,$C1,$00,$0F,$31,$08,$F2,$E3,$E2,$59,$65,$FE
	dc.b $99,$B1,$CE,$14,$68,$3E,$AC,$B3,$47,$50,$D2,$A3,$04,$35,$37,$05
	dc.b $9E,$B7,$3E,$61,$F9,$A7,$E4,$27,$4B,$0F,$BC,$9F,$BF,$5F,$5E,$D7
	dc.b $97,$DE,$62,$50,$DC,$D0,$E6,$DC,$DD,$ED,$4D,$2E,$B2,$C9,$3B,$4E
	dc.b $22,$F5,$D6,$E1,$CE,$1B,$64,$27,$97,$B7,$36,$50,$F7,$B4,$EF,$FD
	dc.b $DC,$06,$38,$1E,$04,$D9,$29,$57,$11,$CD,$D9,$FB,$04,$B3,$EB,$50
	dc.b $47,$C2,$D8,$2F,$32,$40,$19,$BB,$98,$C7,$5A,$67,$B6,$9D,$E3,$4E
	dc.b $43,$18,$E3,$D4,$AB,$23,$18,$14,$F4,$25,$EE,$F6,$22,$33,$24,$D9
	dc.b $98,$B7,$ED,$4C,$66,$13,$99,$D2,$62,$53,$EF,$B2,$F1,$F0,$36,$26
	dc.b $A6,$A7,$10,$5B,$14,$F5,$0B,$18,$EF,$FB,$D6,$A5,$34,$66,$1E,$A8
	dc.b $A2,$29,$54,$2A,$B8,$BB,$F1,$EA,$DB,$4F,$43,$CB,$AE,$34,$61,$09
	dc.b $BF,$E0,$06,$C2,$9E,$38,$59,$E6,$9A,$1C,$5C,$25,$CD,$EF,$08,$F0
	dc.b $B0,$16,$5F,$03,$A0,$DC,$24,$1B,$01,$F9,$F4,$F3,$CD,$E6,$2D,$4D
	dc.b $09,$F2,$ED,$1D,$5C,$1C,$BF,$A7,$AB,$E3,$5A,$5B,$C0,$AA,$FE,$4A
	dc.b $3E,$14,$E5,$FB,$DB,$B6,$1A,$63,$18,$9B,$CC,$45,$43,$FB,$DF,$04
	dc.b $F8,$AC,$ED,$57,$48,$CB,$CB,$08,$43,$45,$03,$BC,$AF,$C1,$04,$49
	dc.b $5E,$E4,$BD,$D9,$62,$50,$E7,$D3,$0A,$DE,$BC,$3A,$64,$F9,$9C,$E0
	dc.b $5F,$3E,$D6,$C3,$08,$0C,$0D,$CE,$F4,$1D,$41,$0C,$DC,$09,$35,$28
	dc.b $B8,$A5,$DE,$09,$5A,$39,$F5,$C0,$D8,$55,$38,$EF,$DF,$08,$E4,$D5
	dc.b $08,$3F,$0B,$C6,$C5,$2D,$53,$FC,$D6,$E1,$04,$F0,$C8,$05,$58,$38
	dc.b $A7,$DF,$3A,$2B,$ED,$D8,$D9,$DA,$01,$02,$26,$18,$EA,$F5,$1C,$1D
	dc.b $2C,$15,$F3,$D0,$A4,$EA,$53,$49,$A9,$A9,$10,$5E,$24,$CD,$D3,$F7
	dc.b $F8,$F5,$FA,$33,$3B,$D8,$F0,$42,$28,$D6,$E0,$06,$DE,$BE,$F8,$4A
	dc.b $38,$D1,$FC,$24,$FF,$10,$42,$F7,$A1,$A9,$02,$5A,$53,$C8,$A3,$03
	dc.b $62,$2C,$C8,$D1,$17,$11,$FB,$C9,$E1,$2D,$4B,$08,$CE,$F0,$34,$3D
	dc.b $C7,$A2,$C7,$10,$53,$52,$F1,$B7,$DC,$53,$33,$D8,$CB,$0B,$00,$1B
	dc.b $DB,$D1,$F6,$24,$18,$01,$0B,$F4,$09,$17,$02,$AB,$AB,$47,$57,$EE
	dc.b $A4,$EE,$19,$1A,$35,$FB,$B8,$B9,$0D,$10,$1E,$26,$DC,$DE,$03,$52
	dc.b $3C,$F4,$D0,$E8,$D3,$D5,$46,$55,$A8,$A4,$06,$5E,$13,$A9,$D6,$10
	dc.b $25,$32,$D4,$9E,$E5,$5F,$45,$DB,$B7,$FC,$2F,$15,$CC,$9F,$D8,$4B
	dc.b $60,$00,$B8,$F2,$32,$22,$F8,$FA,$0E,$F6,$16,$03,$AA,$C2,$38,$4E
	dc.b $E2,$C4,$01,$23,$23,$F1,$F3,$D8,$AB,$16,$5A,$2D,$AA,$B6,$29,$45
	dc.b $E2,$C0,$E1,$FB,$37,$31,$C4,$A1,$10,$60,$3C,$D4,$BE,$0A,$41,$13
	dc.b $B8,$A4,$01,$5C,$3E,$C4,$BF,$0A,$26,$07,$00,$0A,$18,$DE,$C9,$DF
	dc.b $3D,$58,$19,$BD,$C6,$25,$54,$0A,$A4,$A9,$C9,$2B,$5F,$30,$BB,$AA
	dc.b $20,$5E,$1D,$B0,$D8,$0E,$D1,$DC,$5F,$40,$C3,$A0,$38,$5A,$09,$AA
	dc.b $AF,$03,$32,$06,$D4,$E2,$10,$07,$17,$2D,$1F,$F7,$FC,$02,$CF,$A5
	dc.b $E4,$5C,$3E,$C3,$A1,$F5,$54,$3E,$EA,$D6,$D9,$FA,$2A,$F5,$DA,$0D
	dc.b $39,$05,$E2,$03,$3A,$39,$E8,$B1,$B2,$D6,$39,$5E,$1E,$A9,$C7,$3D
	dc.b $5E,$0A,$C9,$D4,$DC,$15,$1D,$D6,$B2,$1F,$4B,$05,$B4,$F8,$44,$47
	dc.b $D7,$A6,$B2,$04,$5D,$52,$F3,$A7,$BC,$36,$4C,$10,$CC,$D8,$E0,$E6
	dc.b $E9,$3F,$48,$F1,$B5,$FC,$46,$20,$F9,$F7,$DF,$A9,$D4,$4E,$4B,$D5
	dc.b $A2,$F7,$4F,$2C,$E5,$E3,$F0,$EF,$B9,$03,$4A,$37,$BA,$BA,$1D,$57
	dc.b $2C,$CC,$CB,$E9,$CA,$F6,$4A,$46,$B1,$AF,$0F,$56,$30,$DF,$D6,$F2
	dc.b $06,$DC,$F2,$27,$37,$E0,$E4,$16,$26,$2B,$15,$DD,$B8,$A4,$F2,$54
	dc.b $5C,$CF,$A4,$F4,$5C,$46,$E9,$CA,$E6,$F5,$DC,$01,$42,$3C,$C4,$BD
	dc.b $39,$35,$00,$06,$0A,$DB,$A9,$EB,$5B,$45,$D6,$AF,$00,$30,$25,$16
	dc.b $FE,$E2,$C4,$C1,$10,$5A,$23,$B6,$BF,$25,$4B,$2C,$F2,$C4,$CA,$BF
	dc.b $0A,$5B,$3B,$C6,$A4,$F6,$4B,$54,$05,$B7,$D1,$DC,$A9,$22,$58,$20
	dc.b $A4,$AF,$07,$54,$4E,$D9,$B9,$E6,$D2,$D5,$3C,$58,$DE,$A8,$E8,$4C
	dc.b $37,$E2,$D1,$FA,$08,$FB,$EA,$00,$06,$10,$0D,$04,$EA,$16,$49,$18
	dc.b $B7,$A6,$C9,$3B,$5A,$28,$BB,$B3,$0C,$4E,$3E,$FB,$D0,$C9,$B3,$F0
	dc.b $59,$45,$D8,$A6,$EB,$59,$41,$E8,$C3,$E3,$E9,$BA,$22,$57,$10,$AF
	dc.b $C5,$31,$3F,$23,$ED,$DC,$DE,$CE,$EB,$4B,$49,$D9,$A9,$F5,$3A,$36
	dc.b $15,$EA,$DB,$C0,$AC,$1E,$59,$11,$A7,$B6,$0A,$42,$57,$08,$D1,$D3
	dc.b $E0,$DC,$2C,$54,$FE,$BC,$C6,$22,$59,$2B,$CA,$C5,$DD,$C0,$0A,$55
	dc.b $3D,$B4,$C3,$26,$52,$1B,$F0,$DE,$E5,$E4,$07,$11,$0C,$FC,$05,$0E
	dc.b $09,$FB,$FE,$20,$0B,$D6,$AA,$F2,$58,$46,$DD,$AA,$ED,$3A,$2C,$04
	dc.b $ED,$F4,$ED,$C9,$D8,$3F,$45,$DC,$A7,$ED,$37,$47,$2A,$DD,$B8,$B1
	dc.b $D1,$50,$57,$E1,$A7,$DF,$44,$48,$06,$D6,$E2,$EB,$F5,$DB,$08,$1F
	dc.b $FA,$F0,$19,$1F,$F3,$19,$29,$E1,$A8,$BC,$21,$57,$2F,$B4,$BC,$0A
	dc.b $4D,$3E,$F7,$C8,$E1,$E2,$BF,$19,$57,$25,$B2,$C7,$26,$2E,$33,$16
	dc.b $D0,$C1,$CA,$E5,$53,$52,$FF,$AD,$C9,$2A,$4C,$16,$C5,$CD,$E0,$C8
	dc.b $35,$56,$16,$B4,$B2,$18,$47,$37,$F3,$D0,$D6,$0E,$F0,$FA,$1A,$21
	dc.b $E1,$D9,$13,$20,$02,$18,$15,$D9,$A9,$D6,$48,$4E,$CA,$AE,$E8,$35
	dc.b $3C,$29,$E9,$CE,$DE,$D0,$F0,$43,$51,$D2,$AD,$F2,$46,$46,$27,$D5
	dc.b $B4,$CD,$E6,$2E,$55,$31,$BE,$C3,$1D,$46,$2E,$FB,$D7,$D6,$BE,$C3
	dc.b $51,$49,$E8,$AB,$E0,$49,$37,$0B,$DD,$D9,$E6,$0E,$EA,$12,$29,$0D
	dc.b $D5,$E1,$23,$28,$10,$FB,$F6,$D5,$AC,$E5,$4B,$49,$BF,$AD,$E5,$2D
	dc.b $49,$1F,$E6,$D6,$EB,$E9,$F3,$3F,$54,$E4,$B2,$E3,$44,$49,$0E,$CF
	dc.b $D5,$E2,$C1,$21,$54,$2A,$B2,$C6,$36,$44,$15,$FC,$F9,$E5,$E0,$0F
	dc.b $23,$E9,$E8,$18,$18,$EC,$F2,$14,$2D,$20,$E8,$CF,$D0,$DA,$3B,$52
	dc.b $FF,$AD,$C4,$31,$53,$16,$BF,$E1,$FF,$D3,$ED,$3B,$40,$E5,$B6,$F8
	dc.b $49,$3C,$F9,$D9,$F1,$E5,$E4,$F2,$40,$37,$F8,$C3,$EC,$1E,$3E,$25
	dc.b $E0,$CE,$DA,$DF,$F1,$48,$3D,$DD,$AF,$F3,$46,$38,$F0,$DB,$E6,$E1
	dc.b $0A,$2C,$09,$E7,$FD,$0E,$00,$0B,$23,$07,$F5,$04,$FC,$C1,$C1,$32
	dc.b $52,$0B,$B0,$D2,$20,$37,$21,$06,$EC,$D3,$E8,$13,$1E,$02,$F9,$F7
	dc.b $F5,$FA,$1F,$1F,$F9,$F3,$03,$ED,$B5,$E3,$43,$40,$C8,$B4,$EC,$35
	dc.b $43,$25,$EB,$D5,$E0,$DB,$F9,$3F,$4F,$DB,$AF,$EE,$46,$44,$0C,$DC
	dc.b $E7,$E5,$FF,$13,$11,$F8,$08,$00,$EF,$08,$29,$10,$F5,$04,$FA,$CF
	dc.b $BF,$10,$4D,$20,$BA,$C4,$0B,$31,$2A,$14,$E7,$D0,$DC,$27,$29,$E9
	dc.b $CC,$0B,$11,$F8,$06,$1A,$06,$FE,$19,$04,$CA,$B1,$F5,$4F,$35,$CC
	dc.b $B0,$DA,$2A,$4B,$33,$DA,$CF,$FE,$F3,$CF,$33,$50,$D4,$B4,$EC,$3D
	dc.b $2A,$22,$F6,$D5,$D5,$E6,$0C,$29,$28,$F6,$D1,$D9,$0F,$3E,$34,$FF
	dc.b $D4,$E6,$F2,$F8,$00,$28,$19,$E1,$CD,$F4,$23,$2C,$0C,$F0,$F3,$ED
	dc.b $E8,$05,$0D,$09,$FC,$FA,$EC,$08,$34,$1F,$F0,$EE,$08,$F7,$E3,$F2
	dc.b $28,$24,$F2,$D4,$EA,$22,$2E,$18,$EE,$E0,$E2,$07,$3D,$1B,$D4,$BA
	dc.b $04,$37,$1F,$01,$EC,$E2,$08,$46,$2C,$C5,$BA,$CD,$0C,$4A,$39,$D5
	dc.b $B1,$DA,$3D,$4B,$04,$D0,$EB,$F5,$F1,$F8,$0E,$0F,$EB,$F2,$FD,$0C
	dc.b $04,$14,$14,$11,$00,$E6,$CD,$CC,$34,$4C,$0D,$BA,$BF,$0D,$39,$40
	dc.b $18,$E3,$D9,$F2,$E2,$ED,$26,$3C,$EE,$B9,$E8,$1A,$1A,$26,$24,$F5
	dc.b $DC,$F1,$E5,$CA,$19,$4A,$0D,$BC,$C8,$1D,$2A,$25,$18,$FA,$E3,$E7
	dc.b $E8,$01,$0A,$0E,$03,$EE,$E3,$07,$32,$27,$FC,$E7,$00,$10,$F2,$C7
	dc.b $DC,$32,$35,$EE,$C8,$ED,$12,$21,$30,$11,$E9,$DD,$E8,$EF,$FD,$1C
	dc.b $21,$03,$CF,$DD,$13,$31,$27,$07,$F4,$F7,$04,$F1,$CB,$DE,$37,$46
	dc.b $E1,$C5,$EA,$18,$21,$23,$0A,$F2,$E9,$E6,$EF,$0A,$14,$FA,$F2,$FC
	dc.b $FA,$0A,$1A,$1A,$02,$F7,$09,$14,$F7,$CD,$CC,$11,$41,$2D,$E1,$CF
	dc.b $E9,$1E,$39,$2D,$F2,$D9,$E5,$EC,$E8,$04,$1D,$0B,$F0,$E5,$02,$10
	dc.b $1C,$14,$10,$01,$F8,$F9,$EF,$DA,$D6,$09,$35,$1E,$DC,$D9,$F2,$11
	dc.b $2C,$33,$06,$D7,$DF,$F8,$F4,$F0,$12,$23,$00,$E2,$F2,$0F,$09,$08
	dc.b $1D,$1A,$F6,$E7,$FB,$FF,$E2,$CF,$18,$3F,$16,$D3,$DE,$02,$0E,$1E
	dc.b $36,$13,$DB,$D9,$02,$0E,$EB,$E4,$10,$1F,$01,$EA,$F6,$02,$00,$0D
	dc.b $31,$1F,$E8,$D9,$FE,$12,$EF,$D3,$05,$39,$12,$DC,$E4,$0D,$06,$F9
	dc.b $1A,$30,$06,$D9,$E4,$06,$FC,$E5,$E6,$16,$1B,$FB,$EA,$FA,$04,$FD
	dc.b $0D,$2E,$20,$EB,$D8,$F7,$0F,$FD,$E2,$EA,$08,$14,$07,$FC,$F6,$F4
	dc.b $FA,$13,$27,$19,$F0,$E1,$F5,$09,$04,$EF,$E6,$01,$16,$18,$FD,$F5
	dc.b $FC,$FA,$02,$1A,$26,$08,$EA,$E9,$FE,$01,$FC,$F5,$F3,$F8,$06,$0F
	dc.b $0A,$FD,$F4,$F5,$06,$1B,$23,$0C,$EF,$E8,$FA,$07,$04,$F5,$E7,$EA
	dc.b $02,$19,$13,$F7,$E2,$F4,$12,$1E,$19,$07,$F3,$ED,$FE,$09,$07,$FA
	dc.b $EF,$E6,$E5,$09,$23,$1F,$F3,$E4,$FD,$12,$10,$10,$15,$00,$EC,$EC
	dc.b $01,$0A,$05,$EE,$DE,$E2,$05,$20,$1B,$FD,$F2,$FB,$0C,$14,$14,$0C
	dc.b $FD,$F5,$F9,$FF,$01,$FF,$F7,$EC,$E9,$F8,$01,$00,$FF,$0D,$14,$07
	dc.b $F6,$FD,$0E,$12,$08,$FC,$FA,$FA,$FC,$FF,$FC,$F8,$F5,$F5,$F3,$FA
	dc.b $12,$19,$03,$F1,$F9,$0B,$08,$00,$04,$0E,$04,$F6,$F4,$FD,$05,$05
	dc.b $00,$F3,$F1,$FD,$08,$0A,$FF,$F9,$FE,$03,$01,$FC,$00,$02,$04,$04
	dc.b $06,$FE,$F9,$FF,$0B,$0B,$04,$FD,$FA,$F7,$FB,$FD,$FC,$F2,$F9,$08
	dc.b $0C,$FF,$FB,$00,$08,$0A,$09,$06,$01,$FC,$FC,$FF,$FF,$FE,$F7,$F4
	dc.b $FA,$04,$08,$04,$FC,$FD,$03,$09,$09,$01,$FC,$FC,$FD,$FB,$FA,$FB
	dc.b $FD,$00,$01,$01,$00,$FE,$01,$05,$06,$03,$00,$FE,$FF,$02,$05,$03
	dc.b $FC,$F9,$FB,$00,$02,$FF,$FC,$FA,$FC,$FF,$00,$FE,$FD,$00,$06,$08
	dc.b $02,$FD,$FD,$02,$04,$04,$01,$FD,$FB,$FB,$01,$06,$06,$FF,$F9,$FA
	dc.b $00,$03,$02,$FD,$FB,$FC,$00,$01,$00,$FF,$00,$02,$03,$01,$FF,$FF
	dc.b $01,$01,$00,$FE,$FD,$FC,$FB,$FC,$00,$05,$03,$FD,$FB,$00,$05,$05
	dc.b $03,$FF,$FF,$00,$01,$02,$01,$FF,$FE,$FF,$01,$01,$FF,$FC,$FC,$FC
	dc.b $FD,$FD,$FD,$FD,$FE,$00,$02,$03,$04,$03,$FF,$FE,$02,$06,$04,$FF
	dc.b $FE,$FF,$00,$01,$01,$00,$FE,$FD,$FE,$00,$00,$FE,$FC,$FC,$FC,$FE
	dc.b $FF,$FF,$FF,$FF,$FF,$00,$02,$03,$03,$00,$FF,$01,$03,$04,$03,$00
	dc.b $FF,$FF,$00,$00,$00,$FE,$FD,$FC,$FD,$FF,$00,$FE,$FC,$FD,$FE,$00
	dc.b $01,$01,$00,$FF,$FF,$FF,$01,$04,$04,$01,$FD,$FE,$01,$04,$03,$00
	dc.b $FD,$FD,$FE,$00,$02,$FF,$FE,$FD,$FD,$FF,$01,$01,$FE,$FD,$FD,$FF
	dc.b $01,$00,$FF,$FF,$FF,$FE,$00,$03,$04,$02,$FF,$FE,$FF,$01,$02,$01
	dc.b $FF,$FD,$FE,$FF,$00,$00,$FF,$FE,$FD,$FE,$00,$02,$01,$FE,$FC,$FD
	dc.b $00,$02,$02,$FF,$FD,$FE,$FF,$01,$02,$02,$FF,$FD,$FD,$00,$02,$02
	dc.b $00,$FF,$FF,$FF,$00,$01,$01,$00,$FE,$FE,$FE,$00,$01,$00,$FE,$FD
	dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

splOuch:
	dc.b $FA,$F6,$15,$04,$EA,$07,$FA,$07,$07,$F7,$00,$F0,$FC,$1D,$F9,$F6
	dc.b $0C,$F9,$0A,$05,$FA,$FD,$F5,$17,$06,$E7,$0A,$FE,$04,$0B,$F0,$FF
	dc.b $F9,$07,$1E,$E1,$FA,$0B,$FE,$10,$F4,$F6,$01,$EE,$15,$0E,$E4,$05
	dc.b $02,$03,$0E,$F5,$FF,$F4,$05,$23,$E3,$FB,$0D,$F9,$12,$F5,$F5,$FE
	dc.b $F7,$18,$02,$E0,$11,$F8,$0A,$0B,$F0,$04,$F3,$F7,$2A,$F3,$F9,$13
	dc.b $F4,$0D,$02,$F6,$00,$F1,$15,$09,$E7,$0F,$F9,$05,$0C,$F1,$FF,$F4
	dc.b $02,$1F,$E4,$FC,$17,$FB,$12,$F8,$F7,$0E,$E1,$12,$15,$DF,$12,$FD
	dc.b $F7,$11,$F3,$05,$F6,$04,$20,$D2,$02,$0C,$FC,$12,$E8,$F5,$00,$FE
	dc.b $1D,$FB,$DE,$1E,$FE,$0C,$0A,$E9,$11,$EE,$F9,$2F,$E1,$FD,$19,$F0
	dc.b $13,$FD,$F2,$01,$F5,$1F,$F4,$DB,$1C,$F6,$0B,$0A,$E5,$0B,$F8,$0A
	dc.b $2A,$D9,$F7,$1E,$FE,$15,$F5,$EF,$13,$D6,$10,$1B,$C0,$12,$00,$F5
	dc.b $18,$F0,$02,$F5,$F1,$32,$F3,$EA,$2C,$F1,$0F,$09,$EF,$13,$D9,$06
	dc.b $26,$CB,$10,$0B,$E9,$19,$F0,$02,$06,$C4,$2C,$0E,$DB,$2F,$EA,$F9
	dc.b $23,$EE,$13,$EA,$FE,$35,$BC,$04,$20,$EB,$1A,$F0,$ED,$0E,$E6,$1B
	dc.b $12,$BA,$19,$01,$FE,$1C,$E6,$10,$FD,$C5,$32,$04,$EA,$2B,$D8,$07
	dc.b $17,$E6,$1F,$E2,$F0,$1D,$C3,$15,$16,$E6,$1C,$E4,$FD,$26,$D6,$13
	dc.b $15,$D3,$2A,$FA,$F8,$1A,$E0,$2E,$FF,$A5,$3A,$F3,$FE,$32,$CE,$09
	dc.b $0F,$ED,$33,$C3,$F6,$3D,$C8,$23,$01,$E2,$24,$EB,$23,$23,$84,$36
	dc.b $19,$EC,$42,$CF,$E9,$23,$F3,$4A,$C1,$CC,$50,$C5,$1E,$17,$CB,$1C
	dc.b $F9,$1E,$2B,$80,$1C,$39,$D9,$4D,$DB,$CF,$31,$FD,$5D,$C6,$B6,$64
	dc.b $D8,$17,$33,$BC,$14,$0C,$0B,$41,$80,$F1,$4F,$BE,$3F,$FC,$B0,$36
	dc.b $04,$44,$EB,$9B,$63,$FA,$F6,$5F,$BE,$FA,$28,$F4,$56,$9D,$BE,$5E
	dc.b $C2,$23,$19,$8F,$25,$1A,$1E,$10,$8B,$31,$2F,$D5,$6F,$D2,$D8,$48
	dc.b $F1,$54,$DC,$8D,$4D,$FF,$01,$3A,$86,$FE,$30,$F7,$40,$8E,$DE,$5E
	dc.b $CC,$36,$06,$BB,$47,$03,$2A,$43,$8A,$10,$52,$DF,$42,$BD,$C3,$41
	dc.b $EB,$44,$D7,$91,$55,$01,$EF,$47,$B4,$0A,$2A,$EF,$79,$CA,$A9,$7E
	dc.b $EF,$FB,$3A,$A4,$0F,$2C,$F1,$3D,$82,$D0,$69,$B0,$08,$38,$B1,$36
	dc.b $10,$DF,$4C,$C1,$95,$5E,$EB,$F6,$27,$BE,$1F,$1A,$EA,$49,$C0,$C0
	dc.b $7F,$D7,$EE,$53,$CC,$1E,$19,$D8,$37,$DF,$AA,$45,$10,$D8,$32,$DA
	dc.b $06,$2C,$DB,$24,$10,$95,$41,$13,$9A,$3F,$EE,$EE,$2A,$D3,$11,$31
	dc.b $9A,$15,$42,$C7,$36,$0C,$E4,$31,$F4,$F7,$51,$A4,$E0,$6E,$B9,$03
	dc.b $53,$D2,$2D,$F7,$E4,$41,$CE,$B2,$4E,$FC,$CF,$31,$D0,$0E,$1F,$D6
	dc.b $28,$23,$8D,$3F,$26,$A6,$41,$FF,$DA,$2E,$D6,$09,$36,$99,$FB,$49
	dc.b $D2,$18,$19,$E4,$30,$00,$ED,$42,$CC,$B9,$66,$D5,$CC,$63,$DB,$0D
	dc.b $24,$D2,$2A,$21,$A4,$2F,$2E,$B7,$1D,$12,$F0,$29,$DE,$FB,$46,$9C
	dc.b $E8,$65,$B5,$F5,$43,$CC,$23,$02,$CF,$3A,$F0,$A5,$3F,$1B,$B5,$22
	dc.b $03,$04,$26,$E6,$04,$35,$9F,$EE,$57,$B5,$01,$35,$D5,$33,$FA,$DB
	dc.b $43,$E7,$B2,$4F,$16,$BE,$28,$FC,$00,$2A,$E2,$05,$67,$A8,$E8,$70
	dc.b $BC,$F3,$4D,$D3,$22,$00,$D0,$37,$FB,$AD,$3C,$25,$C0,$22,$0D,$03
	dc.b $22,$E0,$FA,$3D,$A1,$D0,$64,$D2,$DE,$50,$D1,$1C,$14,$C5,$2A,$1D
	dc.b $90,$1F,$3A,$BE,$08,$19,$EC,$29,$F8,$E7,$40,$E8,$9B,$46,$0B,$A3
	dc.b $3C,$01,$F0,$2D,$D6,$0B,$43,$A6,$D8,$55,$E4,$D3,$2A,$E4,$21,$12
	dc.b $D7,$1C,$22,$A6,$1F,$3C,$B7,$17,$20,$E1,$23,$F4,$E5,$35,$F5,$A1
	dc.b $4C,$30,$BB,$23,$06,$EB,$37,$E5,$EF,$48,$CE,$C8,$65,$FB,$C4,$2F
	dc.b $FA,$FF,$27,$D4,$08,$54,$A2,$E8,$64,$EE,$DB,$26,$ED,$17,$1D,$DA
	dc.b $18,$29,$99,$1A,$61,$B2,$04,$40,$E7,$29,$F7,$D3,$36,$F7,$AA,$2D
	dc.b $33,$CA,$08,$16,$FD,$26,$F2,$ED,$38,$D3,$9F,$52,$30,$B5,$31,$FA
	dc.b $F1,$36,$D4,$F8,$3B,$A5,$D5,$54,$F8,$CC,$1C,$02,$12,$20,$D8,$05
	dc.b $42,$9F,$CA,$58,$01,$D6,$28,$DD,$0A,$30,$D6,$06,$2C,$A8,$E5,$54
	dc.b $F2,$D2,$23,$F1,$12,$21,$D4,$07,$36,$94,$EB,$5D,$DD,$DE,$28,$DD
	dc.b $14,$26,$CC,$12,$2C,$96,$FE,$52,$D1,$E4,$29,$E4,$17,$19,$D4,$12
	dc.b $23,$9F,$10,$49,$CC,$E4,$17,$F6,$22,$12,$D8,$17,$3F,$90,$CF,$63
	dc.b $E5,$D3,$3F,$D4,$06,$34,$D0,$0F,$32,$8D,$F4,$60,$DF,$D2,$11,$F7
	dc.b $22,$27,$D4,$03,$4D,$BF,$9B,$46,$2A,$BD,$40,$F2,$DC,$38,$EC,$F5
	dc.b $36,$A1,$D2,$62,$FE,$C1,$0F,$FA,$17,$2E,$DD,$F3,$44,$FD,$89,$19
	dc.b $53,$C0,$18,$2F,$CD,$25,$13,$DB,$29,$F5,$9B,$3A,$4D,$C8,$EB,$0F
	dc.b $FB,$34,$09,$D5,$1C,$64,$B0,$AA,$65,$0C,$CF,$47,$E7,$DA,$44,$F0
	dc.b $EE,$46,$AE,$E7,$7E,$F7,$BA,$1D,$00,$10,$30,$DB,$EE,$52,$19,$86
	dc.b $F3,$5C,$D7,$07,$1B,$C7,$17,$30,$DF,$0F,$12,$98,$28,$5E,$C2,$CF
	dc.b $12,$FA,$2B,$1D,$CF,$09,$64,$E3,$80,$22,$4F,$B0,$1E,$0E,$C1,$37
	dc.b $20,$CF,$23,$E5,$8C,$59,$35,$9D,$F3,$1D,$FA,$33,$02,$C7,$2A,$55
	dc.b $85,$AC,$5C,$26,$D1,$1F,$EE,$E5,$3B,$FA,$DB,$2E,$B4,$C0,$6C,$19
	dc.b $AB,$03,$16,$FD,$2D,$F5,$D5,$39,$6B,$9B,$B6,$6E,$0E,$CA,$29,$E3
	dc.b $E9,$4C,$FB,$DF,$4D,$C7,$C5,$7C,$0D,$A3,$0B,$17,$00,$34,$F6,$D6
	dc.b $34,$53,$9B,$9D,$5A,$2C,$BE,$23,$FB,$DB,$3D,$07,$C4,$2C,$D9,$AF
	dc.b $5E,$25,$9F,$FF,$23,$F8,$25,$01,$C5,$24,$63,$B3,$91,$41,$56,$BD
	dc.b $FC,$17,$E0,$26,$29,$D1,$0F,$31,$9B,$09,$6C,$D0,$C1,$25,$06,$0D
	dc.b $2E,$E1,$EB,$49,$40,$8F,$A0,$60,$42,$AF,$F5,$11,$E7,$31,$11,$BB
	dc.b $19,$0E,$BC,$3A,$34,$AE,$E2,$2F,$00,$06,$11,$E0,$07,$55,$0E,$87
	dc.b $DB,$7C,$16,$B8,$00,$06,$0D,$3E,$F1,$CB,$4A,$0A,$89,$1F,$6E,$D5
	dc.b $BA,$11,$FC,$10,$32,$E2,$DB,$41,$56,$A9,$8B,$10,$61,$00,$E4,$F5
	dc.b $EC,$21,$3A,$EE,$EC,$5F,$22,$8F,$E3,$02,$06,$67,$F9,$8D,$09,$4A
	dc.b $09,$02,$09,$EA,$0E,$E5,$10,$3B,$ED,$CF,$08,$17,$F7,$09,$FD,$FF
	dc.b $0F,$09,$E2,$01,$1C,$FA,$F9,$10,$03,$05,$34,$C0,$8A,$50,$4E,$AC
	dc.b $CC,$1A,$14,$1A,$14,$D4,$F2,$5B,$58,$97,$AB,$39,$07,$1E,$35,$A5
	dc.b $C7,$64,$2A,$D9,$06,$30,$03,$B6,$B8,$44,$5A,$D2,$BD,$FC,$17,$15
	dc.b $1A,$E6,$E5,$1E,$1B,$E7,$F6,$0C,$FB,$09,$17,$FA,$F7,$2B,$EC,$93
	dc.b $22,$6B,$DF,$AA,$16,$2F,$05,$04,$EB,$E8,$3D,$11,$92,$FA,$71,$F5
	dc.b $BD,$08,$16,$FF,$22,$07,$DD,$0E,$4E,$10,$81,$DA,$7D,$3B,$97,$D1
	dc.b $4B,$1E,$04,$F9,$D7,$04,$4A,$C4,$BE,$4C,$26,$C8,$F1,$21,$F8,$FF
	dc.b $1E,$F7,$EF,$3A,$38,$90,$A8,$62,$6D,$92,$CD,$70,$08,$D3,$1E,$DD
	dc.b $E1,$56,$FD,$B8,$2C,$2D,$C8,$F1,$32,$EB,$E5,$2F,$06,$E6,$35,$2D
	dc.b $80,$BB,$6C,$53,$9A,$CB,$51,$13,$FE,$06,$D3,$FE,$5F,$D5,$BC,$4B
	dc.b $20,$B7,$FF,$33,$EA,$F7,$28,$F6,$EC,$3B,$30,$87,$B4,$76,$5F,$A1
	dc.b $B1,$4B,$2F,$FE,$FE,$D7,$F2,$5D,$EB,$A3,$2A,$3F,$CE,$E1,$2E,$F9
	dc.b $E5,$25,$05,$DF,$25,$4C,$B4,$84,$35,$7E,$D6,$95,$29,$44,$03,$FE
	dc.b $E4,$DE,$43,$1B,$A7,$FA,$57,$F1,$B3,$1D,$1B,$DB,$11,$21,$E2,$03
	dc.b $4B,$02,$83,$EB,$7F,$1F,$8C,$DF,$49,$1F,$F5,$F2,$DC,$18,$3C,$B9
	dc.b $B9,$57,$26,$AB,$EE,$33,$FB,$FA,$1B,$F2,$EC,$33,$55,$A7,$9B,$64
	dc.b $67,$BD,$9B,$2A,$47,$05,$F0,$E3,$E6,$3B,$11,$99,$FD,$5C,$F8,$BB
	dc.b $07,$27,$F4,$07,$1A,$EE,$FC,$45,$14,$83,$C1,$70,$3C,$8F,$C1,$39
	dc.b $2D,$FE,$F9,$E2,$FF,$61,$EF,$84,$06,$7F,$F0,$95,$0D,$31,$FA,$0F
	dc.b $0F,$D8,$FB,$60,$1D,$86,$C4,$58,$42,$CF,$CA,$0D,$1E,$16,$06,$E8
	dc.b $F4,$2D,$57,$DC,$80,$E6,$77,$41,$91,$C6,$47,$22,$F4,$FE,$E8,$00
	dc.b $38,$F2,$D1,$15,$12,$DF,$06,$26,$EC,$E2,$21,$1B,$EE,$10,$3B,$C0
	dc.b $97,$29,$6F,$D6,$A9,$21,$39,$F5,$F4,$08,$F8,$2F,$04,$95,$DF,$70
	dc.b $25,$98,$E1,$37,$0C,$F3,$10,$FE,$EF,$28,$50,$B6,$93,$21,$64,$FD
	dc.b $B1,$F0,$21,$11,$09,$02,$EF,$03,$45,$32,$99,$AE,$5E,$33,$C3,$F8
	dc.b $29,$E5,$E0,$31,$18,$D6,$08,$32,$EF,$BD,$F1,$40,$1F,$E2,$E1,$05
	dc.b $11,$06,$FF,$FB,$FD,$09,$0B,$F6,$F2,$0C,$0E,$FC,$FE,$0A,$04,$05
	dc.b $0C,$D5,$EA,$3B,$22,$D2,$D1,$14,$27,$03,$F6,$FC,$FB,$0D,$35,$F4
	dc.b $8D,$E8,$79,$34,$94,$C0,$4D,$2F,$CB,$EA,$07,$F9,$10,$29,$E4,$CC
	dc.b $18,$32,$E7,$E4,$29,$10,$E1,$F6,$1C,$10,$09,$0B,$D5,$CC,$2D,$2C
	dc.b $D1,$E4,$23,$0E,$E6,$FF,$15,$F2,$F1,$17,$13,$F5,$EE,$F8,$04,$12
	dc.b $0A,$F5,$F3,$0D,$16,$0B,$11,$DB,$BA,$07,$43,$10,$CD,$DF,$1D,$1E
	dc.b $01,$FC,$01,$FC,$1C,$2E,$BE,$8A,$19,$76,$09,$9C,$E9,$45,$18,$E9
	dc.b $FF,$09,$01,$1C,$EF,$BA,$FA,$4C,$19,$BC,$E3,$26,$16,$F2,$04,$15
	dc.b $F8,$09,$2D,$D0,$AD,$06,$55,$0E,$AF,$EA,$2B,$12,$F0,$07,$16,$F7
	dc.b $14,$35,$BE,$95,$19,$70,$06,$97,$F0,$44,$12,$DE,$FD,$17,$0D,$FB
	dc.b $E0,$E8,$0E,$23,$FB,$E2,$02,$15,$03,$F8,$0A,$0D,$FD,$21,$0D,$B3
	dc.b $BC,$2B,$53,$E1,$C1,$15,$30,$F8,$E5,$0E,$15,$08,$E6,$D9,$FE,$2A
	dc.b $13,$DA,$E8,$14,$16,$FB,$FF,$0F,$04,$07,$2D,$DF,$B0,$05,$4C,$F1
	dc.b $AC,$0B,$3F,$FA,$D7,$0B,$29,$00,$12,$1A,$CE,$BD,$09,$2B,$10,$F4
	dc.b $F9,$FC,$FE,$0F,$16,$05,$EE,$EC,$0D,$16,$E3,$DB,$1B,$24,$ED,$E5
	dc.b $0B,$16,$FA,$F5,$01,$00,$06,$0A,$FB,$EB,$FC,$17,$0E,$F5,$FB,$08
	dc.b $08,$16,$EC,$B9,$F2,$47,$2D,$C2,$CD,$25,$2E,$F5,$E3,$08,$0F,$FF
	dc.b $F5,$ED,$F6,$15,$1A,$F6,$DE,$FC,$1E,$0D,$F9,$00,$09,$04,$1A,$03
	dc.b $BD,$C4,$35,$4B,$E9,$BA,$FC,$37,$11,$EB,$FD,$0E,$04,$0A,$E7,$D1
	dc.b $03,$3A,$16,$CD,$DC,$19,$22,$FD,$F7,$0B,$05,$FF,$22,$F2,$B7,$E3
	dc.b $44,$37,$D5,$C3,$09,$2F,$07,$F4,$0A,$0A,$F8,$1C,$0C,$BF,$BA,$24
	dc.b $4F,$01,$BE,$E9,$2D,$18,$F4,$FE,$11,$01,$04,$21,$DD,$A0,$F8,$5C
	dc.b $38,$BD,$C4,$25,$35,$F9,$DC,$03,$15,$06,$EF,$EC,$FD,$12,$10,$F6
	dc.b $EB,$FF,$12,$08,$FE,$02,$09,$08,$21,$00,$BD,$BC,$25,$4F,$FF,$BC
	dc.b $EC,$2F,$1D,$F2,$F4,$0C,$14,$0E,$E0,$C0,$F2,$3C,$2B,$DD,$CF,$05
	dc.b $27,$0A,$F7,$06,$0C,$FD,$15,$07,$CC,$C0,$15,$46,$0F,$C7,$E0,$23
	dc.b $21,$FB,$F5,$0C,$0A,$06,$14,$E4,$B1,$EB,$40,$39,$E0,$C4,$02,$2A
	dc.b $10,$F1,$00,$0D,$03,$10,$F1,$BF,$DC,$2B,$43,$F6,$C5,$EE,$24,$1B
	dc.b $F5,$F7,$09,$07,$0E,$F4,$CB,$DE,$21,$3D,$FE,$CD,$EC,$1E,$1B,$F8
	dc.b $F7,$09,$0A,$0E,$F4,$D0,$DF,$1B,$3C,$05,$D1,$E5,$17,$1E,$01,$F9
	dc.b $05,$07,$0F,$0A,$DC,$C7,$F2,$36,$2D,$EC,$CD,$FB,$1F,$14,$FA,$FE
	dc.b $0C,$0B,$15,$F5,$C3,$CB,$1C,$49,$13,$CB,$DD,$18,$28,$FE,$EA,$FE
	dc.b $16,$11,$EB,$DB,$F4,$16,$14,$F9,$F1,$03,$0A,$00,$FD,$0A,$10,$08
	dc.b $0D,$F4,$CE,$D8,$19,$35,$09,$D8,$EB,$17,$1B,$FB,$F2,$05,$19,$02
	dc.b $D7,$DB,$09,$2B,$11,$E7,$E7,$08,$13,$05,$FD,$05,$09,$07,$07,$EA
	dc.b $D8,$F2,$20,$1F,$F7,$DC,$F9,$17,$14,$FD,$FA,$06,$09,$10,$01,$D6
	dc.b $CC,$FE,$36,$29,$E4,$D5,$FF,$22,$11,$F2,$F1,$06,$0E,$F6,$E4,$F5
	dc.b $1A,$1B,$FA,$E0,$F3,$11,$15,$02,$F9,$02,$08,$09,$0C,$E8,$D2,$F0
	dc.b $25,$2D,$FC,$D3,$E9,$16,$22,$0B,$F4,$F8,$02,$11,$05,$DE,$CF,$FD
	dc.b $2F,$2A,$F1,$D3,$F0,$19,$1E,$05,$F7,$FC,$02,$0F,$04,$DD,$D3,$02
	dc.b $3E,$24,$DC,$CA,$02,$2A,$17,$EB,$E8,$08,$18,$07,$E8,$EA,$06,$1A
	dc.b $08,$ED,$EB,$05,$13,$09,$FA,$FD,$09,$0C,$13,$F8,$D8,$DC,$0A,$24
	dc.b $0B,$E5,$EC,$0C,$1A,$04,$F6,$00,$0F,$13,$0D,$E8,$CB,$DD,$23,$38
	dc.b $01,$D3,$EA,$1B,$1E,$FD,$E7,$F8,$0C,$09,$F8,$F8,$09,$0D,$FA,$E8
	dc.b $F7,$11,$17,$00,$F2,$FC,$0E,$12,$13,$F5,$DB,$D9,$02,$26,$1E,$F0
	dc.b $E1,$F9,$14,$14,$02,$FB,$03,$0F,$0F,$E9,$C8,$E1,$24,$42,$01,$CE
	dc.b $E4,$16,$24,$00,$E5,$F3,$0D,$0F,$FA,$EF,$01,$11,$07,$EF,$ED,$04
	dc.b $16,$0C,$F6,$F6,$06,$10,$11,$01,$E5,$D6,$EE,$1B,$28,$07,$DF,$E9
	dc.b $08,$1B,$0D,$FB,$FB,$06,$13,$03,$DE,$D3,$FE,$33,$21,$DF,$D1,$F8
	dc.b $25,$1F,$FB,$EA,$FF,$12,$13,$FC,$E2,$DC,$FF,$2A,$22,$E8,$D8,$FA
	dc.b $1D,$18,$F1,$E6,$FF,$1A,$15,$F3,$E3,$F6,$10,$12,$F7,$EC,$FF,$13
	dc.b $0B,$F2,$F1,$06,$1A,$13,$F0,$DB,$EC,$13,$21,$FB,$E0,$F0,$12,$1A
	dc.b $02,$F2,$FD,$0F,$14,$05,$E4,$D6,$F7,$2C,$27,$EA,$D2,$F4,$1E,$1F
	dc.b $F6,$E3,$F8,$15,$15,$F7,$EA,$F8,$0F,$0D,$F8,$EC,$FB,$0F,$11,$FF
	dc.b $F8,$00,$09,$0F,$05,$E9,$DC,$EF,$16,$25,$07,$E5,$E9,$03,$15,$0F
	dc.b $FC,$FB,$02,$06,$07,$F0,$E1,$EF,$12,$27,$0A,$E6,$E7,$05,$18,$0C
	dc.b $F3,$F1,$01,$0C,$03,$F2,$F3,$03,$11,$0A,$F8,$EF,$FA,$09,$0D,$03
	dc.b $FC,$00,$05,$05,$08,$F3,$E6,$F0,$0E,$20,$0D,$E9,$E8,$FE,$15,$10
	dc.b $F9,$F4,$FF,$09,$03,$F2,$EE,$FD,$11,$15,$FE,$ED,$F0,$03,$10,$0B
	dc.b $FD,$FB,$03,$06,$04,$FB,$ED,$EF,$03,$17,$14,$F9,$E9,$F1,$07,$13
	dc.b $0C,$FB,$FA,$01,$04,$05,$F8,$EC,$F0,$06,$1B,$12,$F6,$EA,$F6,$0B
	dc.b $11,$02,$F6,$FC,$07,$0A,$02,$F0,$EA,$F7,$10,$19,$06,$EE,$EC,$FD
	dc.b $0E,$10,$02,$FA,$00,$06,$08,$FE,$E9,$E6,$FD,$20,$21,$F4,$DD,$E8
	dc.b $08,$1E,$11,$F7,$F2,$02,$0F,$0F,$F3,$E1,$EA,$0B,$22,$13,$ED,$E9
	dc.b $FF,$13,$0E,$F7,$F0,$FB,$0C,$0D,$FB,$F1,$FB,$0B,$0C,$FA,$F0,$F9
	dc.b $0A,$0F,$03,$FA,$FD,$05,$0F,$04,$EA,$E4,$F8,$12,$17,$01,$EC,$F2
	dc.b $04,$11,$09,$FD,$FE,$09,$0C,$08,$F1,$DD,$DF,$03,$26,$25,$F6,$E2
	dc.b $EF,$0D,$19,$07,$F3,$F6,$04,$0A,$F8,$EB,$F5,$0D,$1B,$06,$ED,$ED
	dc.b $FF,$10,$0F,$FF,$F9,$FF,$05,$08,$FA,$EA,$EA,$02,$1B,$17,$F6,$E7
	dc.b $F3,$0B,$16,$09,$F5,$F6,$00,$08,$FF,$F1,$F1,$03,$13,$10,$F9,$ED
	dc.b $F5,$07,$10,$07,$FB,$FC,$04,$05,$06,$F7,$EA,$EF,$07,$1C,$13,$F4
	dc.b $E8,$F4,$0B,$14,$09,$F9,$FB,$06,$0A,$04,$EF,$E2,$ED,$0C,$22,$14
	dc.b $F2,$E6,$F5,$0B,$16,$08,$F9,$FC,$09,$0B,$04,$F0,$E0,$E4,$06,$25
	dc.b $21,$F5,$E3,$F1,$0E,$18,$04,$F1,$F4,$01,$0C,$03,$F2,$F3,$03,$11
	dc.b $09,$F5,$F1,$FE,$0C,$0B,$FF,$FA,$01,$07,$0E,$08,$EC,$DE,$F5,$1F
	dc.b $1E,$EF,$E0,$F5,$16,$18,$FB,$E9,$F8,$10,$17,$00,$ED,$EF,$03,$10
	dc.b $07,$F5,$F7,$08,$0C,$FF,$F1,$F5,$05,$15,$11,$F8,$EB,$F4,$05,$08
	dc.b $FD,$F7,$00,$0B,$09,$FD,$F9,$FE,$07,$09,$FB,$F1,$F8,$08,$0A,$FB
	dc.b $F6,$01,$0B,$05,$F7,$F3,$FE,$0C,$10,$01,$F3,$F5,$03,$0B,$03,$F6
	dc.b $F6,$03,$0A,$05,$FD,$00,$0B,$0D,$04,$F3,$E0,$E8,$11,$26,$04,$DF
	dc.b $E9,$09,$1E,$0C,$F0,$EC,$FC,$0D,$0F,$02,$F9,$FD,$02,$FF,$F8,$FB
	dc.b $04,$09,$02,$FB,$FC,$08,$0E,$09,$FA,$E7,$E5,$FD,$1A,$1F,$FF,$E8
	dc.b $EC,$02,$12,$0E,$FE,$F9,$03,$0B,$07,$01,$ED,$E1,$ED,$18,$2B,$00
	dc.b $E1,$E6,$07,$1E,$0F,$F0,$EE,$FA,$09,$0C,$03,$FC,$FF,$02,$FD,$F9
	dc.b $FE,$08,$09,$FE,$F7,$F9,$FE,$02,$01,$01,$03,$03,$01,$FE,$FC,$FE
	dc.b $02,$03,$01,$FD,$FC,$01,$07,$09,$05,$FC,$ED,$EC,$FC,$13,$19,$03
	dc.b $EF,$F0,$FD,$0C,$0D,$02,$F9,$FE,$05,$07,$08,$FE,$EA,$E5,$F8,$16
	dc.b $20,$09,$EB,$ED,$FF,$11,$0F,$FC,$F4,$F6,$FD,$06,$0E,$07,$F8,$F4
	dc.b $F9,$01,$04,$02,$00,$01,$03,$02,$00,$00,$01,$02,$04,$05,$FF,$F5
	dc.b $EE,$F8,$0C,$16,$08,$F3,$F1,$F9,$05,$0A,$06,$FE,$FD,$FF,$00,$FF
	dc.b $FF,$FF,$02,$02,$01,$FE,$FE,$FF,$01,$05,$08,$09,$03,$F8,$F2,$EC
	dc.b $F3,$09,$19,$11,$F6,$EF,$F4,$03,$0D,$0B,$FF,$F9,$FC,$00,$01,$00
	dc.b $FE,$FF,$01,$01,$00,$FE,$FF,$02,$06,$08,$07,$01,$F6,$F3,$F7,$FE
	dc.b $01,$04,$05,$03,$00,$FD,$FD,$00,$01,$00,$FF,$FF,$01,$01,$00,$FE
	dc.b $FD,$FF,$02,$03,$01,$FE,$FF,$02,$06,$07,$04,$FA,$EE,$EF,$FC,$0F
	dc.b $16,$06,$F3,$F1,$F9,$06,$0D,$07,$FB,$FC,$00,$04,$06,$02,$F3,$ED
	dc.b $F5,$0A,$17,$0D,$F6,$F1,$F7,$05,$0E,$08,$FA,$F8,$FD,$04,$04,$03
	dc.b $03,$FB,$F7,$F9,$03,$0B,$07,$FA,$F9,$FD,$05,$06,$FE,$FA,$FC,$04
	dc.b $0A,$02,$F9,$F6,$FA,$02,$07,$06,$FF,$FD,$FE,$00,$02,$01,$FE,$FE
	dc.b $01,$05,$04,$FE,$FB,$FC,$00,$04,$02,$FF,$00,$01,$00,$00,$FF,$FF
	dc.b $00,$03,$05,$00,$FB,$FA,$FF,$03,$03,$FE,$FC,$FF,$03,$02,$FF,$FC
	dc.b $FE,$02,$05,$05,$FE,$F9,$FB,$02,$07,$03,$FD,$FA,$FE,$04,$04,$00
	dc.b $FC,$FC,$01,$04,$04,$FE,$F9,$FB,$03,$07,$05,$FF,$FB,$FB,$00,$04
	dc.b $04,$01,$00,$00,$01,$02,$00,$F9,$F6,$F9,$04,$0C,$08,$FE,$F9,$FA
	dc.b $FF,$04,$05,$01,$FF,$FE,$00,$02,$02,$00,$FB,$F5,$F9,$03,$0C,$07
	dc.b $FF,$F9,$F9,$FE,$03,$04,$01,$FF,$FE,$00,$03,$04,$03,$FF,$F8,$F7
	dc.b $FC,$06,$0B,$04,$FD,$F9,$FB,$01,$04,$03,$00,$FE,$FE,$01,$02,$03
	dc.b $01,$FD,$F7,$F8,$00,$09,$09,$02,$FA,$FA,$FD,$02,$04,$02,$FF,$FE
	dc.b $FF,$01,$02,$03,$02,$FD,$F7,$F8,$FF,$08,$09,$03,$FB,$F9,$FC,$03
	dc.b $07,$04,$FE,$FC,$FC,$00,$02,$03,$04,$00,$FC,$FB,$FE,$03,$06,$02
	dc.b $FC,$FC,$FF,$03,$02,$FE,$FC,$FE,$01,$05,$06,$FF,$FA,$FB,$00,$03
	dc.b $02,$FE,$FD,$FF,$02,$02,$01,$FF,$FE,$FF,$00,$03,$03,$FE,$FC,$FE
	dc.b $00,$FD,$FF,$02,$04,$02,$FF,$FE,$FF,$01,$01,$01,$00,$FF,$FF,$00
	dc.b $00,$00,$00,$00,$00,$00,$00,$01,$01,$00,$00,$01,$01,$00,$FF,$FD
	dc.b $FE,$FF,$00,$02,$02,$00,$FE,$FE,$FF,$01,$02,$02,$01,$FF,$FF,$FF
	dc.b $00,$00,$FE,$FB,$FB,$FE,$02,$03,$01,$FF,$FF,$FF,$01,$01,$02,$00
	dc.b $FF,$FF,$00,$00,$00,$01,$01,$02,$01,$FC,$FA,$FD,$01,$04,$03,$00
	dc.b $FE,$FE,$FF,$00,$03,$02,$01,$01,$00,$00,$01,$01,$01,$00,$FF,$FD
	dc.b $FC,$FE,$01,$02,$01,$00,$FE,$FF,$FF,$00,$00,$01,$01,$00,$00,$00
	dc.b $01,$02,$02,$02,$03,$01,$FD,$FB,$FC,$00,$02,$03,$00,$FF,$FF,$FF
	dc.b $00,$02,$02,$00,$FF,$FE,$FE,$FF,$00,$01,$01,$01,$00,$FF,$FE,$FF
	dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

splPastille:
	dc.b $FF,$FF,$09,$F1,$1C,$EB,$0A,$0C,$D2,$25,$D8,$FD,$25,$C6,$4C,$E5
	dc.b $E7,$42,$A3,$2B,$EC,$DB,$4B,$BA,$38,$08,$CE,$4B,$B5,$14,$15,$B9
	dc.b $49,$D2,$10,$23,$BD,$4B,$CA,$F4,$2C,$B0,$39,$EB,$EB,$41,$C1,$2E
	dc.b $F1,$D8,$3B,$AB,$2D,$0E,$D1,$50,$CE,$15,$11,$BF,$39,$C9,$0B,$2A
	dc.b $CA,$55,$DD,$F2,$31,$AD,$2A,$E9,$EF,$3B,$C9,$38,$F8,$DB,$32,$B8
	dc.b $18,$08,$D2,$41,$D8,$16,$12,$CE,$38,$CC,$02,$1F,$CC,$38,$ED,$FC
	dc.b $2B,$CC,$28,$EC,$ED,$2C,$C4,$30,$02,$E3,$38,$D4,$13,$05,$D7,$2C
	dc.b $D6,$11,$14,$D9,$39,$DB,$FD,$1D,$C3,$25,$EA,$FB,$29,$D8,$2E,$F3
	dc.b $EB,$23,$CA,$1B,$03,$E8,$38,$E2,$19,$05,$DC,$27,$D2,$0C,$13,$E0
	dc.b $2E,$EC,$01,$18,$D7,$1C,$EB,$FA,$1C,$DB,$28,$F8,$F1,$1F,$DD,$11
	dc.b $FE,$EC,$21,$E6,$14,$08,$EA,$23,$E4,$05,$11,$E2,$1D,$F3,$03,$15
	dc.b $E8,$1D,$F2,$F9,$13,$E1,$16,$FD,$F4,$1E,$EB,$0F,$FF,$ED,$17,$E1
	dc.b $0B,$08,$F0,$1D,$F2,$05,$0A,$E8,$13,$F1,$02,$12,$ED,$20,$F9,$FA
	dc.b $11,$EB,$0C,$FE,$F9,$13,$F3,$0D,$02,$F6,$10,$ED,$06,$05,$F2,$10
	dc.b $F8,$04,$08,$F3,$0D,$F8,$FF,$09,$F4,$0D,$FE,$FE,$0B,$F8,$07,$FE
	dc.b $FC,$0A,$F6,$08,$02,$FB,$0B,$FA,$03,$03,$FA,$07,$FD,$01,$05,$FC
	dc.b $08,$FE,$01,$04,$FB,$04,$FF,$00,$04,$FE,$03,$01,$FE,$03,$FE,$01
	dc.b $02,$00,$02,$01,$02,$01,$FD,$06,$FC,$00,$0B,$F1,$1C,$F1,$0D,$07
	dc.b $E9,$2A,$CE,$1A,$EA,$F9,$24,$CA,$3E,$D8,$22,$0F,$DD,$41,$BF,$29
	dc.b $E5,$F5,$28,$B7,$37,$D4,$23,$10,$DF,$3E,$CD,$33,$E7,$F5,$1F,$C0
	dc.b $31,$CF,$1E,$0C,$DF,$42,$D3,$3D,$E6,$F7,$1C,$C4,$2E,$C3,$17,$07
	dc.b $E5,$3F,$D6,$40,$E7,$FB,$1E,$CD,$2D,$C0,$11,$01,$E9,$2F,$D7,$36
	dc.b $F2,$08,$21,$E0,$34,$D0,$16,$01,$ED,$23,$CD,$25,$E6,$FD,$0D,$D9
	dc.b $27,$D4,$12,$FF,$F1,$28,$D9,$35,$F9,$11,$1B,$E6,$32,$DE,$11,$F1
	dc.b $E3,$10,$C9,$18,$E3,$03,$11,$E4,$3C,$EC,$26,$01,$F9,$26,$DB,$21
	dc.b $E5,$07,$0B,$E2,$24,$DB,$11,$EF,$EA,$17,$D5,$19,$E6,$0D,$16,$F8
	dc.b $2F,$F3,$25,$02,$FD,$17,$DF,$12,$DE,$FA,$FD,$DF,$11,$E0,$18,$FC
	dc.b $FE,$1A,$F1,$27,$F8,$10,$10,$F4,$1A,$EA,$15,$F7,$F3,$06,$E0,$11
	dc.b $E4,$FD,$FE,$EE,$14,$ED,$17,$06,$0A,$1D,$FB,$26,$F7,$0B,$02,$EE
	dc.b $0B,$DC,$00,$ED,$F5,$06,$ED,$15,$F5,$0C,$08,$FD,$1C,$F3,$16,$01
	dc.b $07,$0F,$F4,$10,$F2,$02,$F6,$ED,$02,$E7,$03,$F5,$FE,$0A,$F7,$16
	dc.b $02,$14,$0C,$03,$12,$F9,$0C,$F9,$FC,$FF,$EE,$00,$F0,$FE,$FB,$F7
	dc.b $08,$F9,$0C,$00,$07,$0D,$01,$0F,$FF,$09,$03,$FE,$05,$F8,$01,$F4
	dc.b $F8,$FC,$F5,$00,$F8,$02,$03,$02,$0A,$04,$0C,$08,$FF,$0D,$F1,$0D
	dc.b $F3,$02,$05,$EA,$15,$E0,$24,$E7,$1C,$F9,$FE,$16,$E3,$2F,$D1,$28
	dc.b $D7,$10,$FC,$F6,$1E,$D1,$27,$D0,$27,$E8,$10,$04,$F1,$25,$E0,$2F
	dc.b $D9,$20,$E8,$04,$0A,$EA,$22,$D0,$22,$D5,$19,$F4,$02,$12,$EB,$2E
	dc.b $E2,$2E,$E2,$17,$F4,$F5,$15,$DD,$21,$C8,$15,$D4,$09,$FB,$F8,$21
	dc.b $F1,$40,$F5,$33,$F5,$0C,$F7,$DB,$03,$C7,$0E,$CF,$14,$F7,$1B,$24
	dc.b $08,$2C,$EB,$21,$DB,$FF,$DD,$E8,$FC,$E7,$26,$F8,$38,$02,$21,$05
	dc.b $FC,$05,$D3,$FC,$C9,$06,$E4,$0E,$0D,$0D,$2F,$04,$34,$F5,$19,$E5
	dc.b $EE,$E7,$DA,$00,$DA,$16,$F2,$2A,$0F,$1B,$1A,$F6,$15,$DB,$09,$D9
	dc.b $01,$EF,$FC,$10,$01,$2A,$FB,$22,$F4,$0A,$F3,$E9,$F5,$D7,$05,$E5
	dc.b $1A,$03,$21,$1A,$10,$1C,$F7,$0E,$DD,$F6,$DC,$F0,$F6,$F3,$12,$FC
	dc.b $25,$06,$20,$06,$06,$00,$E8,$FB,$E0,$00,$EA,$07,$03,$0F,$1C,$07
	dc.b $19,$F5,$09,$EA,$F5,$EC,$ED,$FE,$F2,$16,$02,$22,$0B,$14,$09,$FD
	dc.b $04,$E5,$F9,$DE,$F9,$F0,$00,$08,$09,$1B,$08,$1B,$00,$0A,$F5,$F1
	dc.b $F2,$EB,$FE,$F2,$09,$00,$12,$0D,$0C,$0D,$FD,$04,$F0,$FA,$EE,$F9
	dc.b $F8,$FC,$09,$05,$16,$08,$10,$02,$02,$FA,$F3,$F6,$EE,$FC,$F6,$05
	dc.b $04,$0D,$0D,$09,$0C,$00,$04,$F7,$F7,$F4,$F7,$FB,$FC,$04,$04,$0D
	dc.b $09,$0A,$06,$01,$FE,$F7,$F8,$F6,$FB,$FB,$00,$04,$07,$0A,$08,$07
	dc.b $03,$00,$F8,$FB,$F2,$FC,$F6,$FF,$00,$02,$0C,$FD,$13,$F3,$18,$EA
	dc.b $17,$E6,$18,$ED,$16,$F9,$09,$0A,$FE,$16,$F2,$1C,$E8,$20,$E3,$1B
	dc.b $E1,$15,$E8,$0C,$F6,$00,$06,$F6,$10,$EA,$14,$DE,$15,$D7,$0E,$D8
	dc.b $0D,$EA,$13,$07,$12,$14,$FB,$0E,$D9,$05,$D6,$1A,$F1,$3A,$0E,$37
	dc.b $01,$0C,$E6,$E2,$EC,$E8,$12,$02,$35,$03,$28,$E5,$01,$C8,$F2,$DF
	dc.b $04,$07,$19,$1C,$05,$0E,$DD,$F6,$CD,$02,$E4,$20,$09,$2C,$0A,$11
	dc.b $F6,$E9,$EE,$E8,$0A,$FD,$2E,$0B,$2E,$F9,$0F,$DA,$F5,$E1,$FC,$00
	dc.b $11,$1B,$09,$12,$E9,$FA,$CF,$F9,$DD,$0E,$FC,$22,$09,$12,$FD,$F0
	dc.b $EF,$E5,$01,$F5,$1F,$0A,$29,$02,$13,$EB,$F7,$E6,$F8,$FC,$09,$19
	dc.b $0D,$17,$F9,$03,$DE,$F8,$E4,$05,$FC,$18,$0D,$11,$04,$F8,$F3,$E5
	dc.b $F9,$EE,$0E,$04,$1C,$04,$10,$F5,$F8,$EB,$F4,$F9,$01,$12,$0C,$18
	dc.b $01,$0A,$EC,$FC,$EA,$02,$FB,$11,$0E,$10,$09,$FE,$FA,$E9,$F8,$ED
	dc.b $06,$FD,$15,$05,$0E,$FA,$FC,$EE,$F2,$F6,$FB,$08,$09,$13,$04,$0A
	dc.b $F6,$FB,$EF,$FC,$FA,$08,$0B,$0E,$0B,$03,$00,$F3,$F8,$F3,$00,$FE
	dc.b $0D,$08,$0C,$02,$00,$F6,$F5,$F6,$F9,$02,$04,$0C,$07,$07,$FD,$FC
	dc.b $F4,$F9,$FA,$00,$05,$09,$09,$05,$02,$FB,$F8,$F7,$FB,$FE,$05,$07
	dc.b $08,$05,$01,$FD,$F9,$F8,$F9,$00,$FE,$0A,$00,$0A,$F8,$05,$ED,$03
	dc.b $E9,$09,$ED,$11,$EC,$14,$E6,$0E,$E0,$0B,$E3,$0B,$EB,$10,$F2,$0D
	dc.b $F3,$08,$F0,$02,$F2,$02,$F7,$02,$FC,$02,$FD,$FC,$FC,$F8,$FE,$F6
	dc.b $02,$F6,$07,$F5,$08,$F3,$09,$EE,$0C,$EE,$0D,$ED,$0E,$EC,$0E,$E9
	dc.b $0C,$E7,$0C,$E4,$09,$DF,$09,$E3,$13,$ED,$13,$E7,$02,$DA,$FF,$EA
	dc.b $16,$03,$1A,$F4,$FA,$D8,$F1,$EB,$12,$0F,$1B,$00,$F6,$DF,$E9,$F1
	dc.b $07,$16,$14,$0B,$F4,$EA,$E3,$F7,$FE,$1C,$0F,$13,$F2,$F2,$DD,$FA
	dc.b $F6,$1C,$0A,$16,$F1,$F6,$D9,$FA,$EF,$1A,$04,$18,$ED,$F9,$D7,$F9
	dc.b $EB,$17,$06,$19,$F4,$FB,$DC,$F7,$ED,$13,$0A,$17,$FB,$FB,$E2,$F3
	dc.b $F2,$0B,$0E,$12,$03,$F9,$EA,$EE,$F7,$04,$13,$0F,$0A,$F8,$F2,$EA
	dc.b $FB,$FF,$15,$0C,$0F,$F7,$F5,$E7,$FA,$F9,$14,$08,$10,$F6,$F8,$E5
	dc.b $FA,$F4,$12,$07,$11,$F9,$FB,$E8,$FA,$F5,$0F,$09,$11,$FC,$FD,$EA
	dc.b $F9,$F6,$0B,$0A,$0F,$00,$FC,$EF,$F5,$F9,$06,$0C,$0C,$05,$FB,$F4
	dc.b $F4,$FB,$02,$0E,$0A,$09,$FC,$F7,$F2,$FC,$FF,$0D,$08,$09,$FC,$F9
	dc.b $F1,$FC,$FC,$0C,$07,$0A,$FC,$FC,$F2,$FC,$FC,$0A,$07,$0A,$FE,$FD
	dc.b $F4,$FC,$FC,$08,$07,$09,$00,$FD,$F6,$FA,$FC,$05,$07,$07,$02,$FD
	dc.b $F8,$FA,$FD,$03,$07,$06,$03,$FE,$F9,$FA,$FF,$00,$0A,$04,$08,$FD
	dc.b $00,$F7,$00,$FD,$08,$03,$04,$01,$F9,$FD,$F5,$02,$F8,$09,$F6,$08
	dc.b $EE,$04,$EC,$09,$EE,$0E,$F1,$10,$EF,$0C,$F2,$0C,$F7,$0F,$FA,$0B
	dc.b $F9,$08,$FB,$08,$FE,$03,$FC,$00,$06,$08,$0B,$FD,$FD,$F0,$05,$00
	dc.b $18,$00,$04,$DF,$F8,$ED,$1A,$05,$13,$E3,$F2,$DE,$0A,$07,$1B,$FB
	dc.b $F9,$DF,$F7,$FD,$18,$0F,$06,$EE,$EB,$F6,$06,$1B,$0C,$08,$EB,$F7
	dc.b $F6,$18,$0E,$17,$F5,$F8,$E9,$09,$07,$1F,$FF,$00,$E2,$F9,$F8,$18
	dc.b $0A,$0A,$EF,$EF,$EF,$06,$0F,$0F,$01,$F0,$EF,$F5,$09,$0C,$0F,$F9
	dc.b $F5,$EB,$02,$06,$1A,$04,$05,$EA,$FC,$F9,$1A,$0B,$12,$F3,$F9,$F0
	dc.b $09,$0A,$15,$01,$F9,$EF,$F9,$03,$10,$0C,$00,$F5,$EE,$FC,$03,$12
	dc.b $03,$01,$EA,$F6,$F5,$0E,$08,$0C,$F5,$F6,$EE,$04,$07,$13,$01,$FF
	dc.b $EF,$FB,$FF,$10,$09,$06,$F6,$F6,$FA,$05,$0D,$0A,$02,$F5,$F7,$FA
	dc.b $0A,$0A,$0B,$FA,$F8,$F1,$01,$04,$0E,$01,$FF,$EF,$FA,$FA,$0B,$05
	dc.b $06,$F6,$F8,$F6,$03,$08,$0A,$01,$F9,$F5,$FB,$04,$09,$09,$FF,$F9
	dc.b $F6,$FF,$04,$0D,$05,$01,$F5,$FB,$FC,$09,$06,$06,$FB,$FA,$F8,$02
	dc.b $05,$09,$01,$FC,$F6,$FC,$01,$08,$06,$01,$FA,$F9,$FC,$02,$08,$04
	dc.b $00,$F9,$FA,$FD,$05,$05,$05,$FE,$FB,$FA,$00,$04,$07,$02,$FE,$FA
	dc.b $FD,$00,$06,$04,$02,$FC,$FB,$FD,$01,$05,$04,$00,$FC,$FB,$FE,$02
	dc.b $05,$03,$00,$FC,$FD,$FD,$07,$02,$08,$FB,$01,$F9,$03,$00,$03,$00
	dc.b $FA,$FE,$F6,$05,$F7,$0B,$F7,$0A,$F8,$06,$FF,$05,$05,$FF,$04,$F8
	dc.b $07,$F9,$09,$F8,$04,$F5,$01,$FC,$00,$02,$FB,$07,$FA,$0B,$F7,$07
	dc.b $FB,$10,$04,$06,$F7,$F7,$03,$07,$0F,$F3,$F6,$E5,$09,$08,$11,$F7
	dc.b $F1,$F6,$05,$17,$06,$00,$EA,$02,$04,$19,$01,$F9,$ED,$FB,$0B,$0B
	dc.b $05,$EA,$F6,$F6,$13,$07,$07,$EE,$F8,$00,$11,$0E,$FD,$F7,$F1,$09
	dc.b $08,$0E,$F4,$F4,$F3,$07,$0C,$06,$F9,$EE,$FD,$03,$15,$01,$FE,$F0
	dc.b $01,$09,$10,$03,$F3,$F7,$FA,$0E,$04,$03,$EA,$F9,$FA,$0F,$07,$FE
	dc.b $F3,$F7,$08,$0A,$0E,$F8,$FA,$F7,$0B,$09,$08,$F7,$F4,$FC,$06,$0D
	dc.b $FD,$FA,$F0,$02,$06,$0D,$FF,$F8,$F7,$01,$0C,$07,$02,$F3,$FD,$FE
	dc.b $0D,$02,$FE,$F3,$FA,$03,$09,$06,$F9,$F9,$F9,$09,$07,$07,$F8,$FA
	dc.b $FC,$08,$09,$01,$FB,$F5,$01,$04,$09,$FC,$FA,$F6,$01,$07,$06,$FF
	dc.b $F7,$FD,$01,$0C,$03,$01,$F6,$FE,$02,$09,$03,$FB,$F9,$FB,$05,$04
	dc.b $03,$F7,$FB,$FD,$07,$05,$01,$FA,$FA,$01,$05,$07,$FE,$FC,$FA,$02
	dc.b $04,$05,$FD,$FA,$FC,$01,$06,$02,$FE,$F9,$FF,$02,$06,$01,$FD,$FB
	dc.b $FF,$04,$04,$02,$FB,$FD,$FE,$04,$03,$01,$FB,$FD,$00,$04,$03,$FF
	dc.b $FC,$FD,$01,$03,$03,$FE,$FE,$FD,$03,$02,$02,$FF,$FA,$00,$FD,$05
	dc.b $FD,$FF,$FE,$FF,$07,$00,$08,$F9,$02,$FC,$01,$02,$F9,$02,$F8,$05
	dc.b $FF,$04,$02,$FD,$04,$FC,$07,$FA,$01,$FC,$FC,$02,$FC,$07,$FB,$04
	dc.b $01,$05,$02,$F9,$01,$FD,$08,$FA,$FB,$FA,$02,$0D,$FD,$FD,$F6,$0A
	dc.b $0B,$03,$F6,$F0,$07,$05,$06,$F0,$F7,$04,$0B,$0C,$F5,$FC,$FE,$0F
	dc.b $06,$F5,$F6,$FA,$0E,$03,$FC,$F4,$FF,$0E,$06,$01,$F1,$01,$07,$09
	dc.b $FC,$F1,$FE,$05,$0D,$FB,$F7,$FB,$08,$0C,$FD,$F9,$F6,$09,$07,$00
	dc.b $F5,$F6,$08,$07,$05,$F6,$FB,$05,$09,$04,$F4,$FB,$FE,$0B,$02,$F8
	dc.b $F9,$00,$0E,$02,$FC,$F7,$01,$09,$03,$FC,$F3,$01,$06,$07,$FB,$F7
	dc.b $01,$06,$0A,$FB,$F9,$FD,$07,$06,$FB,$F9,$FA,$07,$05,$00,$F9,$FC
	dc.b $09,$05,$02,$F6,$FD,$03,$06,$01,$F7,$FD,$02,$08,$01,$FA,$FB,$02
	dc.b $09,$00,$FB,$F9,$02,$06,$01,$FC,$F9,$02,$05,$05,$FC,$FA,$01,$05
	dc.b $04,$FA,$FB,$FE,$05,$04,$FC,$FC,$FE,$07,$03,$FF,$FB,$FE,$04,$03
	dc.b $FF,$F9,$FE,$04,$04,$00,$FA,$FF,$02,$05,$FF,$FB,$FD,$02,$04,$FF
	dc.b $FC,$FC,$02,$04,$01,$FC,$FC,$02,$03,$02,$FC,$FD,$00,$03,$02,$FD
	dc.b $FD,$00,$04,$02,$FD,$FD,$FF,$03,$02,$FE,$FC,$FF,$03,$02,$FF,$FD
	dc.b $FF,$02,$02,$FF,$FD,$FF,$02,$02,$FF,$FD,$FF,$02,$02,$00,$FD,$FF
	dc.b $01,$02,$00,$FE,$FE,$01,$02,$00,$FE,$FF,$00,$02,$00,$FE,$FF,$00
	dc.b $02,$00,$FF,$FE,$FF,$02,$FE,$01,$FE,$00,$04,$FF,$02,$FC,$00,$00
	dc.b $FD,$03,$FD,$03,$01,$FF,$03,$FB,$01,$FE,$FF,$01,$FC,$05,$FF,$02
	dc.b $02,$FD,$02,$FC,$00,$FF,$FE,$02,$FD,$06,$01,$FE,$FE,$FB,$06,$FF
	dc.b $FB,$FE,$02,$0A,$FC,$FA,$FF,$06,$05,$F2,$FB,$05,$07,$03,$F5,$01
	dc.b $07,$04,$F9,$F6,$06,$06,$00,$F8,$FD,$0C,$03,$FA,$F8,$02,$09,$FD
	dc.b $FA,$FD,$08,$07,$F9,$FB,$00,$07,$00,$F6,$FF,$06,$07,$FB,$F8,$04
	dc.b $04,$02,$F6,$FC,$08,$04,$FE,$F9,$02,$07,$00,$FB,$F9,$06,$05,$FB
	dc.b $FC,$00,$0A,$01,$F8,$FD,$03,$06,$FC,$FA,$01,$05,$05,$FA,$FD,$04
	dc.b $04,$FF,$F7,$01,$06,$02,$FC,$FB,$05,$04,$FE,$FA,$FD,$06,$01,$FC
	dc.b $FC,$02,$07,$FD,$FB,$FE,$04,$03,$FA,$FD,$02,$05,$00,$FA,$FF,$03
	dc.b $03,$FC,$FB,$03,$04,$01,$FB,$FE,$04,$01,$FD,$FB,$01,$05,$FF,$FC
	dc.b $FE,$04,$03,$FC,$FC,$FF,$04,$00,$FC,$FF,$02,$04,$FE,$FC,$01,$03
	dc.b $01,$FB,$FE,$03,$02,$FF,$FC,$00,$03,$00,$FD,$FD,$02,$03,$FF,$FD
	dc.b $FF,$03,$01,$FD,$FE,$01,$03,$FF,$FD,$00,$03,$01,$FD,$FE,$01,$02
	dc.b $FF,$FD,$00,$02,$01,$FE,$FD,$01,$02,$FF,$FD,$FF,$02,$01,$FE,$FE
	dc.b $01,$02,$FF,$FE,$FF,$02,$01,$FE,$FE,$00,$02,$00,$FE,$FF,$02,$01
	dc.b $FF,$FE,$01,$01,$00,$FE,$FE,$01,$00,$FF,$FF,$00,$03,$FF,$FE,$00
	dc.b $FF,$02,$00,$FE,$02,$FF,$00,$FF,$FD,$02,$00,$00,$01,$FE,$02,$FF
	dc.b $FE,$01,$FF,$02,$00,$FE,$01,$FE,$00,$00,$FE,$03,$00,$FF,$00,$FE
	dc.b $01,$FE,$FE,$03,$00,$00,$FF,$FF,$02,$FC,$FD,$03,$01,$00,$FD,$00
	dc.b $04,$FC,$FD,$02,$03,$00,$FB,$01,$05,$FD,$FB,$00,$05,$02,$F9,$00
	dc.b $06,$FE,$FA,$FE,$06,$02,$F9,$FF,$05,$01,$FA,$FC,$07,$02,$FA,$FF
	dc.b $04,$03,$FA,$FC,$06,$03,$FB,$FD,$03,$04,$FB,$FB,$05,$03,$FD,$FC
	dc.b $02,$05,$FC,$FB,$03,$04,$FF,$FB,$01,$05,$FD,$FB,$01,$04,$00,$FB
	dc.b $01,$05,$FD,$FB,$FF,$04,$01,$FB,$00,$04,$FF,$FC,$FE,$04,$01,$FB
	dc.b $FF,$03,$01,$FC,$FD,$04,$02,$FC,$FF,$03,$02,$FC,$FD,$03,$02,$FD
	dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

splCoucou:
	dc.b $FF,$01,$00,$01,$00,$01,$00,$01,$01,$01,$01,$02,$03,$06,$05,$FC
	dc.b $F7,$0F,$0E,$F4,$04,$FB,$FA,$0A,$FA,$04,$EE,$14,$F2,$FA,$FC,$F3
	dc.b $03,$00,$00,$EC,$08,$05,$1B,$FD,$E8,$ED,$02,$06,$05,$F5,$00,$04
	dc.b $08,$FB,$F6,$0C,$FB,$03,$EB,$02,$F0,$15,$FB,$FF,$F6,$0D,$00,$F9
	dc.b $F3,$F5,$0D,$1F,$04,$F8,$EF,$09,$EB,$EF,$FA,$E7,$F6,$05,$00,$15
	dc.b $07,$FC,$0B,$09,$07,$01,$02,$FA,$F8,$EF,$ED,$F6,$F1,$FF,$F8,$0D
	dc.b $14,$26,$1E,$0C,$FD,$ED,$E4,$E2,$DF,$D7,$EE,$F6,$0F,$18,$20,$25
	dc.b $29,$22,$14,$04,$EC,$DC,$CF,$D4,$DA,$F4,$0A,$21,$29,$26,$28,$29
	dc.b $23,$0B,$FC,$DC,$CB,$BA,$C1,$E4,$FC,$29,$37,$3D,$2F,$2C,$18,$09
	dc.b $F3,$DB,$C0,$B0,$B2,$E1,$08,$36,$4C,$43,$32,$27,$12,$F9,$F1,$CD
	dc.b $B7,$A3,$C2,$DF,$27,$32,$5A,$38,$3D,$14,$14,$EA,$F2,$C1,$B7,$97
	dc.b $EA,$EA,$42,$42,$4E,$28,$3B,$0E,$17,$F2,$EA,$B4,$AB,$94,$D4,$00
	dc.b $34,$50,$4A,$32,$2F,$18,$0A,$FB,$DA,$AC,$96,$9F,$CC,$14,$33,$54
	dc.b $46,$3A,$24,$20,$00,$F6,$D1,$A8,$8C,$C0,$D4,$28,$3A,$52,$44,$45
	dc.b $1F,$22,$FC,$EF,$C6,$A5,$83,$CA,$DE,$35,$48,$54,$37,$48,$1C,$1F
	dc.b $FF,$EC,$BD,$A6,$80,$CD,$E9,$32,$4E,$53,$35,$4B,$1E,$1C,$00,$E6
	dc.b $B0,$9E,$83,$C5,$F6,$33,$53,$55,$3E,$42,$24,$10,$F8,$DB,$A5,$8D
	dc.b $93,$C8,$0E,$37,$4F,$53,$45,$3C,$29,$09,$F6,$CC,$9F,$87,$AC,$D0
	dc.b $1D,$41,$4C,$4A,$4E,$30,$26,$09,$E8,$BF,$9B,$84,$BF,$E3,$25,$4A
	dc.b $50,$45,$52,$2E,$1E,$FF,$DE,$AD,$92,$89,$C3,$FB,$2C,$4D,$53,$49
	dc.b $4B,$2C,$0F,$F8,$CE,$A2,$89,$A1,$CF,$11,$35,$4D,$52,$4E,$3F,$24
	dc.b $06,$E8,$BF,$9C,$92,$BE,$DD,$1D,$3E,$4E,$4E,$52,$30,$20,$01,$DE
	dc.b $B8,$98,$8E,$BF,$EA,$1E,$42,$53,$4C,$54,$30,$18,$F9,$D4,$AB,$9C
	dc.b $97,$C9,$F9,$22,$43,$55,$4F,$48,$2E,$0B,$F3,$CC,$AE,$9E,$AC,$D2
	dc.b $03,$27,$3E,$4E,$48,$44,$25,$0B,$EC,$D0,$B1,$A7,$B7,$D6,$02,$20
	dc.b $37,$45,$45,$3C,$26,$0B,$EC,$D0,$BA,$B7,$BD,$DD,$F8,$16,$26,$3B
	dc.b $3D,$3A,$24,$08,$EC,$D8,$D2,$D0,$CF,$E2,$E6,$05,$0C,$22,$2C,$3C
	dc.b $27,$11,$FA,$EB,$E9,$E7,$E7,$DF,$EC,$E9,$FA,$05,$13,$1D,$2F,$20
	dc.b $11,$0B,$F8,$FD,$02,$F5,$F2,$EA,$EA,$E7,$F5,$FA,$11,$17,$1F,$10
	dc.b $0D,$0E,$08,$14,$FA,$1F,$DA,$01,$CC,$FC,$DE,$04,$F8,$0F,$0C,$0B
	dc.b $0E,$09,$26,$0C,$11,$03,$F6,$00,$E8,$F1,$EA,$F4,$F8,$FE,$01,$04
	dc.b $0A,$0C,$11,$12,$14,$FD,$02,$02,$FD,$FB,$F6,$F8,$F9,$F8,$F9,$FC
	dc.b $00,$00,$06,$04,$09,$07,$0A,$06,$05,$01,$FF,$FD,$FB,$FB,$F9,$FB
	dc.b $FA,$FC,$FD,$FF,$01,$02,$02,$03,$04,$04,$04,$03,$03,$01,$00,$FF
	dc.b $FE,$FE,$FE,$FF,$FF,$00,$00,$01,$01,$01,$01,$01,$01,$01,$01,$01
	dc.b $01,$01,$01,$00,$01,$00,$00,$00,$00,$00,$01,$01,$01,$01,$00,$00
	dc.b $00,$00,$00,$00,$FF,$FF,$00,$00,$00,$00,$00,$01,$00,$00,$00,$FF
	dc.b $FF,$FF,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$00,$FF,$FF,$FF
	dc.b $FF,$00,$00,$00,$01,$01,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00
	dc.b $00,$00,$00,$00,$01,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00
	dc.b $00,$00,$00,$01,$00,$00,$01,$01,$01,$01,$01,$00,$00,$00,$00,$00
	dc.b $00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$00,$00,$00,$00,$00
	dc.b $00,$00,$FF,$00,$00,$00,$01,$00,$00,$01,$01,$00,$01,$00,$00,$00
	dc.b $FF,$FF,$FF,$00,$00,$00,$00,$01,$01,$01,$01,$01,$00,$00,$00,$FF
	dc.b $FF,$FF,$FF,$FE,$FF,$FF,$00,$00,$01,$01,$01,$01,$00,$00,$00,$FF
	dc.b $FF,$FF,$FF,$FF,$00,$00,$00,$01,$01,$01,$01,$00,$00,$00,$00,$FF
	dc.b $FF,$FF,$FF,$00,$00,$00,$01,$01,$01,$01,$01,$01,$00,$00,$00,$00
	dc.b $00,$00,$00,$00,$00,$01,$01,$00,$01,$01,$00,$00,$01,$01,$01,$01
	dc.b $03,$05,$06,$F5,$F7,$FC,$F0,$05,$DA,$0E,$FA,$0C,$09,$0B,$F3,$F4
	dc.b $11,$06,$FB,$F2,$06,$07,$FD,$05,$FB,$D7,$14,$23,$DA,$26,$F7,$E6
	dc.b $F3,$F3,$12,$FE,$13,$FF,$1E,$E4,$F9,$E5,$07,$F6,$20,$1A,$E8,$F6
	dc.b $F9,$06,$F3,$F9,$0B,$0E,$FE,$06,$08,$0C,$CD,$0E,$EB,$0E,$F3,$FC
	dc.b $F8,$0B,$E6,$05,$11,$1F,$EA,$03,$06,$18,$13,$FF,$D9,$1A,$D8,$FC
	dc.b $FA,$1E,$DE,$06,$12,$00,$F7,$05,$37,$0C,$06,$FA,$EF,$FC,$08,$0E
	dc.b $28,$FB,$EC,$DB,$EA,$F8,$1B,$06,$0B,$FB,$02,$01,$FF,$0B,$FA,$06
	dc.b $FF,$03,$F3,$F4,$F8,$F3,$F1,$F1,$FB,$07,$0D,$14,$1E,$26,$23,$13
	dc.b $13,$F5,$EF,$E7,$F2,$DD,$E9,$D2,$F3,$EC,$11,$10,$28,$1C,$1E,$1E
	dc.b $24,$1A,$16,$F9,$EE,$E3,$D9,$D4,$CA,$D1,$EC,$08,$1C,$35,$2E,$26
	dc.b $21,$1A,$18,$0D,$06,$F0,$D5,$CA,$B7,$B5,$DD,$F8,$26,$36,$43,$30
	dc.b $17,$0D,$1E,$1C,$1C,$0F,$F1,$C4,$B1,$9C,$A2,$E0,$02,$3B,$46,$48
	dc.b $2A,$0C,$0C,$21,$27,$22,$12,$E5,$BA,$A0,$92,$A2,$ED,$19,$4B,$4E
	dc.b $3F,$1A,$01,$0F,$23,$31,$24,$09,$DB,$AE,$97,$8E,$B7,$FF,$32,$49
	dc.b $4A,$31,$07,$03,$1B,$2C,$36,$1F,$FB,$CC,$A5,$99,$93,$D1,$08,$39
	dc.b $43,$3F,$25,$00,$06,$27,$30,$31,$17,$EE,$C4,$A6,$9B,$9D,$E4,$0A
	dc.b $3B,$44,$38,$21,$06,$08,$2D,$32,$29,$11,$E9,$BF,$A9,$9D,$A2,$E8
	dc.b $07,$38,$41,$36,$22,$0A,$0B,$2B,$2E,$26,$10,$E9,$C7,$B4,$A5,$A0
	dc.b $E5,$02,$30,$3B,$37,$27,$0D,$0C,$29,$2A,$27,$13,$F1,$D0,$BA,$A9
	dc.b $A2,$C9,$FD,$22,$39,$3A,$32,$12,$0F,$22,$28,$29,$14,$FA,$D7,$BD
	dc.b $AE,$A8,$AF,$F3,$11,$37,$3F,$35,$1E,$12,$12,$2F,$2C,$19,$06,$E6
	dc.b $C2,$B8,$AE,$A5,$E4,$00,$29,$3D,$36,$2C,$10,$0D,$24,$24,$1F,$11
	dc.b $F2,$D4,$C0,$B3,$A8,$BB,$F5,$17,$37,$36,$30,$19,$11,$19,$2A,$27
	dc.b $16,$FF,$E3,$C5,$B9,$B7,$A9,$E9,$00,$29,$3D,$35,$2B,$11,$10,$21
	dc.b $28,$1E,$0D,$F0,$D1,$C4,$B5,$B0,$BF,$F6,$13,$34,$3A,$2E,$1C,$13
	dc.b $1D,$22,$26,$15,$01,$E3,$CB,$C0,$BC,$AF,$DC,$02,$21,$38,$2F,$2D
	dc.b $11,$0D,$22,$25,$1F,$0E,$F5,$D8,$CA,$BE,$B7,$BC,$F3,$06,$2B,$37
	dc.b $32,$23,$12,$1D,$24,$24,$16,$02,$EA,$CF,$C6,$C1,$B5,$CC,$FB,$12
	dc.b $2F,$31,$2F,$18,$13,$21,$1C,$25,$11,$FA,$E1,$D1,$C6,$C1,$B7,$DF
	dc.b $00,$1A,$34,$2E,$2E,$13,$18,$23,$1E,$1C,$06,$F3,$DA,$CF,$C8,$BF
	dc.b $BC,$EB,$02,$23,$33,$30,$28,$15,$21,$1D,$1F,$13,$01,$EB,$D9,$D0
	dc.b $C9,$C2,$C2,$F3,$05,$26,$32,$2C,$23,$16,$25,$18,$21,$0F,$FB,$E6
	dc.b $D7,$CD,$C5,$C1,$CF,$FA,$0F,$29,$2E,$2B,$1C,$17,$23,$1A,$1E,$07
	dc.b $F4,$E0,$D6,$CF,$C9,$C2,$E5,$FC,$15,$2C,$2B,$2B,$18,$20,$21,$1B
	dc.b $14,$00,$EE,$DE,$D7,$CD,$C9,$CA,$EF,$02,$19,$2C,$29,$21,$15,$23
	dc.b $19,$19,$0E,$FB,$EB,$DB,$D4,$CF,$C7,$D8,$F4,$0A,$21,$27,$28,$1B
	dc.b $18,$20,$19,$17,$05,$F3,$E3,$DA,$D3,$CF,$CD,$E7,$FB,$11,$24,$26
	dc.b $23,$17,$1E,$1B,$17,$0F,$FC,$EE,$E3,$DB,$D6,$D2,$D6,$F1,$00,$16
	dc.b $21,$25,$20,$16,$21,$17,$16,$0B,$F8,$EC,$E2,$DB,$DA,$D2,$E2,$F5
	dc.b $05,$19,$1F,$22,$1A,$1C,$1D,$16,$10,$00,$F4,$EA,$E0,$DD,$DB,$D9
	dc.b $E8,$F7,$08,$17,$1E,$1E,$17,$1E,$17,$13,$0C,$FF,$F3,$EB,$E5,$DF
	dc.b $DC,$DF,$EB,$FB,$0A,$16,$1D,$1C,$18,$1A,$14,$12,$08,$FC,$F2,$EC
	dc.b $E5,$E3,$E0,$E3,$F1,$FD,$0C,$16,$1B,$1A,$1A,$18,$14,$11,$07,$FB
	dc.b $F3,$ED,$E7,$E4,$E4,$E7,$F4,$FE,$0A,$13,$16,$15,$16,$13,$11,$0D
	dc.b $04,$FA,$F3,$ED,$E8,$E6,$E6,$EB,$F4,$FE,$08,$10,$14,$13,$15,$11
	dc.b $0E,$0C,$04,$FC,$F5,$F0,$EC,$EA,$EA,$EC,$F4,$FC,$06,$0D,$12,$13
	dc.b $15,$10,$0D,$0B,$06,$FF,$F8,$F3,$F1,$EF,$ED,$EF,$F4,$FA,$03,$09
	dc.b $0E,$10,$10,$0F,$0C,$0B,$07,$02,$FC,$F8,$F3,$F2,$EF,$F0,$F3,$F7
	dc.b $FD,$04,$09,$0D,$0E,$0D,$0C,$0B,$08,$04,$01,$FD,$FA,$F6,$F5,$F3
	dc.b $F3,$F5,$F8,$FD,$02,$06,$0A,$0B,$0B,$09,$07,$07,$05,$02,$FF,$FC
	dc.b $FB,$F9,$F8,$F7,$F7,$F8,$F9,$FC,$00,$04,$06,$08,$08,$07,$06,$05
	dc.b $03,$02,$00,$FE,$FD,$FB,$FB,$FB,$FA,$FA,$FB,$FB,$FD,$00,$03,$05
	dc.b $06,$06,$05,$05,$04,$03,$02,$00,$FF,$FE,$FD,$FC,$FC,$FB,$FB,$FC
	dc.b $FD,$FE,$00,$02,$03,$04,$04,$04,$03,$02,$02,$03,$02,$01,$FF,$FE
	dc.b $FE,$FD,$FE,$FE,$FD,$FD,$FE,$FF,$00,$02,$03,$03,$04,$04,$03,$03
	dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

splDring:
	dc.b $32,$2D,$2D,$2D,$2D,$2D,$2D,$2D,$32,$2D,$2D,$2D,$28,$28,$23,$23
	dc.b $1E,$23,$23,$28,$32,$37,$3C,$41,$46,$46,$41,$3C,$37,$2D,$1E,$14
	dc.b $0F,$0A,$0F,$14,$1E,$28,$3C,$4B,$55,$5F,$5F,$5F,$55,$46,$37,$23
	dc.b $14,$05,$FB,$F6,$F6,$00,$14,$28,$3C,$55,$64,$6E,$6E,$6E,$5F,$4B
	dc.b $37,$19,$00,$F1,$E2,$E2,$E7,$F6,$0F,$28,$46,$5F,$73,$7D,$78,$73
	dc.b $5F,$46,$2D,$0A,$F1,$DD,$D3,$D3,$DD,$F1,$0A,$2D,$4B,$69,$78,$1A
	dc.b $1A,$78,$64,$46,$28,$05,$EC,$D8,$D3,$D3,$E2,$F6,$14,$37,$55,$6E
	dc.b $1A,$1B,$1A,$73,$5F,$41,$23,$05,$EC,$DD,$D3,$D8,$EC,$00,$1E,$3C
	dc.b $5A,$73,$7D,$1A,$7D,$6E,$5A,$3C,$1E,$05,$F1,$E7,$E2,$EC,$F6,$0F
	dc.b $28,$41,$55,$64,$6E,$6E,$69,$5A,$46,$2D,$19,$05,$F6,$F1,$F1,$F6
	dc.b $05,$19,$2D,$41,$50,$5F,$5F,$5F,$55,$46,$37,$28,$19,$0F,$0A,$05
	dc.b $0A,$0F,$19,$23,$2D,$37,$41,$46,$46,$41,$3C,$37,$2D,$28,$23,$1E
	dc.b $1E,$1E,$23,$28,$2D,$2D,$32,$32,$32,$2D,$2D,$2D,$2D,$2D,$2D,$32
	dc.b $32,$37,$3C,$3C,$3C,$3C,$37,$2D,$28,$1E,$19,$14,$14,$14,$19,$23
	dc.b $2D,$37,$46,$4B,$55,$55,$50,$4B,$41,$32,$23,$0F,$05,$FB,$FB,$00
	dc.b $0A,$19,$2D,$41,$50,$5F,$69,$69,$64,$55,$41,$2D,$14,$FB,$EC,$E7
	dc.b $E7,$EC,$00,$14,$2D,$46,$5F,$6E,$78,$78,$6E,$5A,$46,$28,$0A,$F1
	dc.b $DD,$D8,$D8,$E7,$FB,$19,$37,$55,$6E,$7D,$1A,$1A,$73,$5A,$41,$23
	dc.b $00,$E7,$D8,$D3,$D8,$E7,$00,$1E,$41,$5F,$78,$1B,$1C,$1B,$73,$5A
	dc.b $3C,$19,$FB,$E7,$D8,$D3,$DD,$EC,$0A,$28,$46,$64,$78,$1B,$1B,$7D
	dc.b $69,$50,$32,$14,$FB,$E7,$DD,$D8,$E2,$F6,$0F,$28,$46,$5F,$73,$78
	dc.b $78,$6E,$5A,$41,$28,$0F,$FB,$EC,$E7,$E7,$F1,$00,$19,$2D,$46,$55
	dc.b $5F,$64,$64,$5A,$4B,$37,$23,$14,$05,$FB,$FB,$FB,$05,$14,$23,$32
	dc.b $41,$4B,$50,$50,$4B,$46,$3C,$2D,$23,$19,$14,$14,$14,$19,$1E,$28
	dc.b $2D,$32,$37,$3C,$3C,$3C,$3C,$37,$37,$37,$32,$32,$32,$32,$32,$32
	dc.b $32,$32,$32,$2D,$28,$28,$23,$1E,$1E,$23,$28,$2D,$37,$41,$46,$46
	dc.b $46,$46,$41,$37,$2D,$23,$14,$0F,$0A,$05,$0A,$14,$1E,$2D,$3C,$4B
	dc.b $55,$5A,$5A,$55,$46,$37,$23,$0F,$00,$F6,$EC,$F1,$FB,$0A,$1E,$37
	dc.b $4B,$5F,$6E,$73,$6E,$64,$50,$3C,$1E,$05,$F1,$E2,$DD,$DD,$EC,$00
	dc.b $1E,$37,$55,$6E,$78,$7D,$78,$6E,$55,$37,$19,$FB,$E7,$D8,$D3,$DD
	dc.b $EC,$0A,$28,$4B,$69,$7D,$1B,$1C,$1A,$6E,$55,$37,$14,$F6,$E2,$D3
	dc.b $D3,$DD,$F1,$0A,$2D,$50,$69,$7D,$1B,$1B,$7D,$69,$4B,$2D,$0F,$F1
	dc.b $E2,$D8,$D8,$E7,$FB,$14,$32,$50,$69,$78,$7D,$7D,$6E,$5A,$41,$23
	dc.b $0A,$F1,$E2,$DD,$DD,$EC,$00,$19,$37,$50,$64,$6E,$6E,$6E,$5F,$4B
	dc.b $37,$1E,$0A,$FB,$F1,$F1,$F6,$00,$0F,$23,$37,$4B,$55,$5F,$5F,$5A
	dc.b $50,$41,$32,$23,$14,$0A,$0A,$0A,$0F,$19,$23,$32,$3C,$41,$46,$4B
	dc.b $46,$41,$3C,$37,$2D,$28,$23,$23,$23,$23,$28,$28,$2D,$2D,$32,$32
	dc.b $32,$2D,$2D,$2D,$2D,$2D,$2D,$32,$32,$37,$37,$3C,$37,$37,$2D,$28
	dc.b $1E,$19,$14,$0F,$0F,$14,$19,$23,$32,$3C,$46,$4B,$50,$50,$4B,$41
	dc.b $32,$23,$14,$05,$00,$FB,$00,$05,$14,$23,$37,$4B,$5A,$64,$69,$64
	dc.b $5A,$46,$32,$1E,$05,$F6,$EC,$E7,$EC,$FB,$0F,$28,$46,$5F,$6E,$78
	dc.b $7D,$78,$64,$50,$32,$19,$FB,$E7,$DD,$DD,$E2,$F6,$0F,$2D,$4B,$69
	dc.b $7D,$1B,$1B,$7D,$69,$4B,$2D,$0A,$F1,$DD,$D3,$D8,$E2,$F6,$14,$32
	dc.b $55,$6E,$1A,$1B,$1A,$78,$5F,$46,$23,$00,$E7,$D8,$CE,$D3,$E2,$FB
	dc.b $19,$37,$5A,$6E,$7D,$1B,$7D,$6E,$55,$37,$19,$FB,$E7,$DD,$D3,$DD
	dc.b $EC,$05,$1E,$3C,$55,$69,$73,$78,$6E,$5F,$4B,$32,$19,$00,$F1,$E7
	dc.b $E7,$F1,$00,$14,$2D,$41,$55,$64,$69,$69,$5F,$55,$41,$2D,$19,$0A
	dc.b $00,$FB,$00,$0A,$14,$23,$32,$41,$4B,$55,$55,$55,$50,$46,$3C,$2D
	dc.b $23,$19,$14,$14,$19,$1E,$23,$2D,$32,$37,$3C,$3C,$37,$37,$32,$32
	dc.b $2D,$2D,$2D,$2D,$2D,$2D,$2D,$2D,$2D,$2D,$28,$23,$23,$1E,$1E,$1E
	dc.b $1E,$23,$28,$2D,$37,$3C,$41,$41,$41,$3C,$37,$2D,$1E,$14,$0A,$05
	dc.b $05,$0A,$0F,$1E,$28,$3C,$4B,$55,$5A,$5A,$55,$4B,$3C,$2D,$19,$0A
	dc.b $FB,$F6,$F1,$F6,$05,$19,$32,$4B,$5F,$6E,$73,$73,$6E,$5A,$46,$2D
	dc.b $0F,$FB,$EC,$E2,$E2,$F1,$00,$19,$37,$55,$6E,$7D,$1A,$7D,$73,$5F
	dc.b $46,$28,$0A,$EC,$DD,$D3,$D8,$E2,$FB,$19,$37,$5A,$73,$1A,$1B,$1A
	dc.b $73,$5A,$3C,$19,$FB,$DD,$D3,$CE,$D3,$E7,$00,$1E,$41,$5F,$78,$1A
	dc.b $1B,$7D,$6E,$50,$37,$14,$F6,$E2,$D3,$CE,$D8,$EC,$05,$23,$41,$5F
	dc.b $73,$7D,$7D,$73,$5F,$4B,$2D,$14,$FB,$E7,$E2,$E2,$EC,$FB,$14,$2D
	dc.b $4B,$5F,$6E,$73,$73,$69,$55,$41,$28,$14,$00,$F6,$F1,$F6,$00,$0F
	dc.b $23,$37,$4B,$5A,$5F,$64,$5F,$55,$46,$37,$28,$19,$0F,$0A,$0A,$0F
	dc.b $14,$1E,$28,$32,$3C,$46,$46,$46,$46,$41,$37,$32,$28,$23,$23,$1E
	dc.b $23,$23,$28,$28,$2D,$2D,$2D,$2D,$28,$28,$28,$28,$28,$28,$2D,$32
	dc.b $32,$37,$37,$37,$37,$32,$2D,$23,$1E,$19,$14,$14,$14,$19,$23,$2D
	dc.b $37,$46,$4B,$50,$50,$4B,$46,$37,$28,$19,$0A,$00,$FB,$00,$05,$14
	dc.b $23,$37,$4B,$5A,$64,$69,$69,$5F,$50,$3C,$28,$0F,$FB,$F1,$EC,$EC
	dc.b $F6,$0A,$1E,$3C,$55,$69,$78,$7D,$78,$69,$55,$3C,$1E,$00,$E7,$DD
	dc.b $D8,$DD,$EC,$05,$23,$41,$5F,$73,$1A,$1A,$7D,$6E,$50,$32,$14,$F6
	dc.b $DD,$D3,$CE,$D8,$EC,$0A,$28,$4B,$69,$1A,$1C,$1B,$1A,$69,$50,$2D
	dc.b $0F,$F1,$DD,$D3,$D3,$DD,$F1,$0F,$2D,$4B,$69,$78,$1A,$1A,$73,$64
	dc.b $46,$28,$0A,$F1,$E2,$D8,$DD,$EC,$00,$19,$37,$55,$69,$78,$78,$78
	dc.b $69,$55,$3C,$23,$0A,$F6,$EC,$E7,$F1,$FB,$0F,$23,$3C,$50,$5F,$69
	dc.b $69,$64,$5A,$4B,$37,$23,$0F,$05,$FB,$FB,$00,$0A,$19,$28,$37,$46
	dc.b $4B,$50,$50,$4B,$41,$37,$2D,$23,$19,$14,$0F,$14,$19,$1E,$23,$28
	dc.b $2D,$32,$37,$37,$37,$32,$2D,$2D,$28,$28,$28,$28,$28,$2D,$2D,$2D
	dc.b $2D,$2D,$28,$23,$23,$1E,$23,$23,$28,$2D,$32,$3C,$41,$46,$4B,$4B
	dc.b $46,$41,$37,$28,$1E,$14,$0F,$0A,$0F,$14,$1E,$2D,$3C,$4B,$55,$5F
	dc.b $64,$5F,$55,$46,$37,$23,$0F,$00,$F6,$F1,$F6,$00,$0F,$28,$3C,$55
	dc.b $64,$6E,$6E,$69,$5F,$4B,$32,$19,$00,$EC,$E2,$DD,$E7,$F6,$0F,$28
	dc.b $46,$5F,$73,$7D,$7D,$73,$64,$46,$2D,$0A,$F1,$DD,$D3,$D3,$DD,$F1
	dc.b $0F,$32,$50,$69,$7D,$1B,$1B,$78,$64,$46,$28,$05,$E7,$D8,$CE,$D3
	dc.b $DD,$F6,$14,$37,$5A,$73,$1A,$1B,$1B,$73,$5F,$41,$23,$00,$EC,$DD
	dc.b $D8,$DD,$EC,$05,$23,$41,$5A,$73,$1A,$1A,$7D,$6E,$55,$3C,$1E,$05
	dc.b $F1,$E7,$E2,$EC,$FB,$14,$2D,$46,$5A,$6E,$73,$73,$6E,$5A,$46,$32
	dc.b $19,$05,$F6,$F1,$F1,$FB,$05,$19,$28,$3C,$4B,$5A,$5A,$5A,$55,$46
	dc.b $37,$28,$19,$0A,$05,$05,$05,$0F,$19,$23,$2D,$37,$3C,$41,$41,$41
	dc.b $3C,$37,$2D,$28,$23,$1E,$1E,$1E,$1E,$23,$28,$2D,$2D,$2D,$32,$2D
	dc.b $2D,$2D,$2D,$2D,$2D,$32,$37,$37,$3C,$3C,$3C,$3C,$37,$32,$28,$23
	dc.b $1E,$19,$14,$19,$1E,$23,$2D,$3C,$46,$4B,$50,$55,$50,$46,$3C,$32
	dc.b $1E,$0F,$05,$00,$FB,$00,$0A,$19,$2D,$3C,$50,$5F,$64,$69,$5F,$55
	dc.b $41,$2D,$14,$00,$F1,$EC,$EC,$F1,$00,$19,$32,$4B,$5F,$6E,$78,$78
	dc.b $6E,$5A,$41,$23,$0A,$F1,$DD,$D8,$DD,$E7,$FB,$19,$37,$55,$6E,$7D
	dc.b $1A,$1A,$73,$5A,$3C,$1E,$00,$E7,$D8,$D3,$D8,$E7,$00,$1E,$41,$5F
	dc.b $78,$1B,$1B,$1A,$73,$55,$37,$19,$F6,$E2,$D3,$D3,$DD,$F1,$0A,$28
	dc.b $4B,$64,$78,$1B,$1B,$7D,$69,$50,$32,$14,$FB,$E7,$DD,$DD,$E7,$FB
	dc.b $0F,$2D,$4B,$64,$73,$7D,$78,$6E,$5A,$46,$28,$0F,$FB,$EC,$E7,$E7
	dc.b $F6,$05,$1E,$32,$46,$5A,$64,$64,$64,$5A,$46,$37,$23,$0F,$05,$FB
	dc.b $F6,$FB,$05,$14,$23,$32,$41,$4B,$50,$55,$50,$46,$3C,$2D,$23,$1E
	dc.b $14,$14,$14,$19,$1E,$28,$2D,$37,$3C,$3C,$41,$3C,$3C,$37,$37,$32
	dc.b $32,$2D,$2D,$2D,$32,$32,$32,$32,$2D,$2D,$28,$23,$23,$23,$23,$23
	dc.b $28,$32,$37,$41,$46,$46,$46,$46,$41,$32,$28,$1E,$14,$0A,$05,$05
	dc.b $0A,$14,$23,$2D,$41,$4B,$55,$5A,$5A,$55,$46,$37,$23,$0F,$00,$F6
	dc.b $EC,$EC,$F6,$0A,$1E,$37,$4B,$5F,$6E,$73,$6E,$64,$50,$3C,$1E,$05
	dc.b $F1,$E2,$DD,$E2,$F1,$05,$1E,$3C,$5A,$6E,$7D,$7D,$7D,$6E,$55,$37
	dc.b $19,$FB,$E7,$D8,$D8,$DD,$F1,$0A,$2D,$4B,$69,$7D,$1C,$1C,$1A,$6E
	dc.b $50,$32,$14,$F6,$DD,$D3,$D3,$DD,$F1,$0A,$2D,$50,$69,$7D,$1B,$1B
	dc.b $7D,$64,$4B,$28,$0A,$F1,$DD,$D3,$D8,$E2,$FB,$14,$37,$50,$69,$78
	dc.b $1A,$7D,$6E,$5A,$41,$23,$0A,$F1,$E2,$DD,$E2,$F1,$00,$19,$32,$4B
	dc.b $5F,$6E,$6E,$69,$5F,$4B,$37,$1E,$0A,$FB,$F1,$F1,$F6,$00,$0F,$23
	dc.b $37,$46,$55,$5A,$5A,$55,$4B,$3C,$32,$23,$14,$0A,$0A,$0A,$0F,$19
	dc.b $23,$2D,$3C,$41,$46,$4B,$46,$46,$3C,$37,$32,$2D,$28,$23,$23,$28
	dc.b $28,$2D,$2D,$32,$32,$32,$32,$2D,$2D,$2D,$2D,$32,$32,$32,$37,$37
	dc.b $3C,$3C,$3C,$37,$32,$28,$23,$19,$14,$0F,$0F,$14,$19,$23,$2D,$3C
	dc.b $46,$4B,$50,$50,$46,$41,$32,$23,$14,$05,$FB,$FB,$FB,$05,$14,$23
	dc.b $37,$4B,$5A,$64,$69,$64,$5A,$46,$32,$1E,$05,$F6,$EC,$E7,$EC,$FB
	dc.b $0F,$28,$46,$5A,$6E,$78,$78,$73,$5F,$4B,$32,$14,$FB,$E7,$DD,$DD
	dc.b $E7,$F6,$0F,$2D,$4B,$69,$78,$1A,$1A,$78,$64,$46,$28,$0A,$EC,$DD
	dc.b $D3,$D3,$E2,$FB,$19,$37,$5A,$73,$1A,$1B,$1B,$78,$5F,$41,$23,$00
	dc.b $E7,$D8,$D3,$D8,$E7,$00,$1E,$3C,$5F,$73,$1A,$1B,$1A,$6E,$5A,$3C
	dc.b $1E,$00,$EC,$DD,$D8,$DD,$F1,$05,$23,$3C,$5A,$69,$73,$78,$6E,$5F
	dc.b $4B,$32,$19,$00,$F1,$E7,$E7,$EC,$00,$14,$2D,$41,$55,$64,$69,$69
	dc.b $5F,$50,$41,$2D,$19,$0A,$00,$FB,$00,$05,$14,$23,$32,$41,$50,$55
	dc.b $5A,$55,$50,$46,$37,$2D,$23,$19,$14,$14,$19,$1E,$23,$2D,$32,$37
	dc.b $3C,$3C,$3C,$37,$32,$32,$2D,$2D,$28,$28,$28,$28,$2D,$2D,$28,$28
	dc.b $28,$23,$1E,$1E,$1E,$1E,$1E,$23,$28,$2D,$37,$3C,$41,$41,$41,$3C
	dc.b $37,$2D,$23,$14,$0A,$05,$05,$0A,$0F,$1E,$2D,$3C,$4B,$55,$5F,$64
	dc.b $5F,$55,$46,$32,$1E,$0A,$00,$F6,$F1,$FB,$05,$19,$2D,$46,$5A,$69
	dc.b $73,$73,$69,$5A,$46,$2D,$0F,$FB,$EC,$E2,$E2,$EC,$00,$19,$37,$50
	dc.b $69,$7D,$1A,$7D,$73,$5A,$41,$23,$05,$EC,$DD,$D8,$D8,$E7,$00,$1E
	dc.b $3C,$5F,$78,$1B,$1C,$1A,$73,$5A,$37,$19,$F6,$DD,$CE,$CE,$D3,$E7
	dc.b $00,$23,$41,$5F,$78,$1A,$1B,$7D,$69,$50,$32,$14,$F6,$E2,$D3,$D3
	dc.b $DD,$EC,$0A,$28,$46,$5F,$73,$7D,$7D,$73,$5F,$4B,$2D,$14,$FB,$E7
	dc.b $E2,$E2,$F1,$00,$14,$32,$4B,$5F,$69,$6E,$6E,$64,$50,$3C,$28,$14
	dc.b $00,$F6,$F6,$FB,$05,$14,$28,$3C,$4B,$5A,$64,$64,$5F,$55,$46,$37
	dc.b $28,$19,$0F,$0A,$0A,$0F,$19,$23,$2D,$37,$41,$46,$4B,$4B,$46,$41
	dc.b $37,$32,$28,$23,$1E,$1E,$1E,$1E,$23,$23,$23,$28,$28,$23,$23,$23
	dc.b $23,$23,$28,$28,$2D,$32,$37,$37,$37,$37,$37,$32,$28,$23,$19,$14
	dc.b $0F,$14,$14,$1E,$28,$32,$3C,$4B,$50,$55,$5A,$55,$4B,$3C,$32,$1E
	dc.b $0F,$05,$00,$00,$05,$0F,$1E,$32,$46,$55,$5F,$64,$64,$5A,$4B,$37
	dc.b $23,$0F,$FB,$F1,$EC,$F1,$FB,$0F,$23,$3C,$55,$69,$78,$7D,$78,$69
	dc.b $50,$37,$19,$00,$EC,$E2,$DD,$E7,$F6,$0F,$2D,$4B,$64,$78,$1A,$1A
	dc.b $7D,$69,$4B,$2D,$0F,$F1,$D8,$CE,$C9,$D3,$E7,$05,$28,$46,$69,$7D
	dc.b $1B,$1B,$7D,$69,$4B,$2D,$0A,$EC,$DD,$D3,$CE,$DD,$F6,$0F,$32,$50
	dc.b $6E,$7D,$1B,$1B,$78,$64,$4B,$28,$0F,$F1,$E2,$D8,$DD,$EC,$00,$19
	dc.b $32,$50,$64,$73,$78,$73,$64,$50,$3C,$1E,$0A,$F6,$EC,$EC,$F1,$FB
	dc.b $0F,$28,$3C,$50,$64,$69,$6E,$64,$5A,$4B,$37,$23,$14,$05,$00,$00
	dc.b $05,$0F,$1E,$2D,$3C,$4B,$50,$55,$50,$4B,$41,$32,$28,$1E,$14,$0F
	dc.b $0A,$0F,$14,$19,$1E,$28,$2D,$32,$37,$37,$37,$37,$32,$2D,$2D,$2D
	dc.b $2D,$2D,$2D,$2D,$32,$32,$32,$2D,$2D,$28,$23,$23,$23,$23,$28,$2D
	dc.b $32,$3C,$41,$46,$46,$46,$41,$3C,$32,$23,$19,$0F,$0A,$05,$0A,$0F
	dc.b $19,$28,$37,$46,$55,$5F,$5F,$5F,$55,$46,$37,$23,$0F,$00,$F6,$F6
	dc.b $F6,$05,$19,$2D,$46,$5A,$69,$73,$73,$6E,$5F,$46,$2D,$14,$FB,$E7
	dc.b $DD,$D8,$E2,$F1,$0A,$28,$41,$5A,$6E,$78,$78,$73,$5F,$46,$28,$0A
	dc.b $EC,$DD,$D3,$D3,$E2,$F6,$14,$32,$55,$6E,$1A,$1B,$1B,$78,$64,$46
	dc.b $28,$0A,$EC,$DD,$D8,$D8,$E7,$FB,$19,$3C,$5A,$73,$1A,$1B,$1A,$6E
	dc.b $55,$37,$19,$FB,$E7,$D8,$D3,$DD,$EC,$05,$23,$41,$5F,$73,$7D,$1A
	dc.b $7D,$69,$55,$37,$19,$00,$EC,$E2,$E2,$EC,$FB,$14,$2D,$4B,$5F,$73
	dc.b $78,$78,$6E,$5F,$46,$32,$19,$05,$F6,$EC,$F1,$F6,$05,$14,$28,$3C
	dc.b $4B,$55,$5A,$5A,$50,$46,$37,$28,$19,$0F,$0A,$05,$0A,$0F,$19,$23
	dc.b $2D,$37,$41,$41,$46,$41,$3C,$37,$32,$2D,$28,$23,$23,$23,$23,$28
	dc.b $2D,$2D,$2D,$32,$2D,$2D,$2D,$28,$28,$28,$28,$28,$2D,$32,$32,$37
	dc.b $37,$37,$37,$32,$2D,$23,$1E,$19,$19,$19,$1E,$28,$32,$41,$4B,$55
	dc.b $5A,$5A,$55,$4B,$41,$32,$23,$14,$0A,$05,$00,$05,$14,$23,$32,$46
	dc.b $55,$64,$69,$69,$5F,$50,$3C,$23,$0A,$F6,$E7,$DD,$E2,$EC,$FB,$14
	dc.b $2D,$4B,$5F,$6E,$78,$78,$6E,$5A,$41,$23,$0A,$EC,$DD,$D8,$D8,$E2
	dc.b $FB,$19,$37,$55,$6E,$7D,$1A,$1A,$73,$5F,$41,$23,$05,$EC,$DD,$D8
	dc.b $DD,$EC,$05,$1E,$41,$5F,$73,$1A,$1A,$7D,$6E,$50,$37,$14,$FB,$E7
	dc.b $D8,$D8,$E2,$F6,$0F,$2D,$50,$69,$7D,$1B,$1B,$78,$64,$4B,$2D,$0F
	dc.b $F6,$E2,$D8,$DD,$E7,$FB,$14,$32,$50,$69,$78,$7D,$7D,$6E,$5A,$46
	dc.b $28,$0F,$FB,$EC,$E2,$E7,$F1,$00,$19,$32,$46,$5A,$64,$69,$64,$5A
	dc.b $50,$3C,$28,$14,$0A,$00,$FB,$00,$05,$14,$1E,$2D,$3C,$46,$4B,$50
	dc.b $4B,$46,$3C,$32,$28,$1E,$19,$14,$19,$1E,$23,$28,$2D,$32,$37,$37
	dc.b $37,$37,$32,$2D,$2D,$2D,$2D,$2D,$2D,$32,$32,$32,$37,$37,$32,$32
	dc.b $2D,$28,$28,$23,$23,$23,$28,$2D,$37,$3C,$41,$46,$46,$46,$41,$37
	dc.b $2D,$23,$19,$0F,$0A,$0A,$0F,$19,$23,$32,$41,$4B,$55,$5A,$55,$50
	dc.b $41,$32,$23,$0F,$00,$F6,$EC,$F1,$FB,$0A,$1E,$37,$50,$5F,$6E,$6E
	dc.b $6E,$64,$50,$37,$1E,$05,$F1,$E2,$DD,$E7,$F6,$0A,$28,$46,$5F,$73
	dc.b $1A,$1A,$7D,$69,$50,$32,$14,$F6,$E2,$D8,$D3,$DD,$EC,$0A,$2D,$4B
	dc.b $69,$1A,$1C,$1C,$1A,$6E,$50,$32,$0F,$F1,$DD,$D3,$D3,$DD,$F1,$0F
	dc.b $32,$55,$6E,$1A,$1C,$1C,$7D,$69,$4B,$2D,$0A,$F1,$DD,$D3,$D3,$E2
	dc.b $F6,$14,$32,$50,$69,$78,$7D,$78,$69,$55,$3C,$1E,$05,$F1,$E2,$DD
	dc.b $E2,$F1,$05,$1E,$37,$50,$64,$6E,$6E,$69,$5F,$4B,$37,$1E,$0A,$FB
	dc.b $F1,$F1,$F6,$05,$19,$28,$3C,$4B,$55,$5A,$5A,$55,$46,$3C,$2D,$1E
	dc.b $0F,$0A,$05,$05,$0F,$19,$23,$32,$3C,$46,$4B,$4B,$4B,$46,$3C,$37
	dc.b $2D,$28,$28,$23,$23,$28,$28,$2D,$32,$32,$37,$37,$37,$32,$32,$32
	dc.b $32,$32,$32,$37,$37,$37,$37,$37,$37,$32,$2D,$28,$1E,$19,$14,$0F
	dc.b $0F,$14,$1E,$23,$32,$3C,$46,$50,$50,$50,$46,$3C,$2D,$1E,$0F,$00
	dc.b $FB,$F6,$FB,$05,$14,$28,$3C,$50,$5A,$64,$69,$64,$55,$46,$32,$19
	dc.b $00,$F1,$E7,$E7,$EC,$FB,$0F,$28,$41,$5A,$6E,$78,$78,$73,$5F,$4B
	dc.b $2D,$14,$F6,$E7,$DD,$DD,$E7,$FB,$14,$32,$50,$6E,$7D,$1B,$1B,$7D
	dc.b $69,$4B,$2D,$0F,$F1,$DD,$D8,$D8,$E7,$00,$19,$3C,$5A,$73,$1A,$1B
	dc.b $1A,$73,$5A,$3C,$1E,$FB,$E2,$D3,$CE,$D3,$E7,$FB,$19,$3C,$5A,$73
	dc.b $7D,$1A,$7D,$6E,$55,$37,$19,$FB,$E7,$D8,$D8,$E2,$F1,$0A,$28,$46
	dc.b $5F,$73,$7D,$7D,$73,$64,$4B,$32,$19,$00,$F1,$E7,$E7,$EC,$FB,$14
	dc.b $28,$41,$50,$5F,$64,$64,$5A,$50,$3C,$28,$19,$0A,$00,$FB,$00,$0A
	dc.b $14,$23,$32,$41,$4B,$55,$55,$50,$4B,$41,$37,$2D,$23,$1E,$19,$19
	dc.b $19,$1E,$28,$2D,$32,$3C,$3C,$3C,$3C,$37,$37,$32,$2D,$2D,$28,$28
	dc.b $2D,$2D,$2D,$2D,$2D,$2D,$28,$23,$23,$1E,$1E,$1E,$23,$28,$2D,$37
	dc.b $3C,$41,$46,$46,$46,$41,$37,$2D,$1E,$14,$0A,$05,$05,$05,$0F,$1E
	dc.b $2D,$3C,$4B,$55,$5A,$5A,$55,$4B,$3C,$28,$14,$05,$F6,$F1,$F1,$F6
	dc.b $05,$19,$32,$4B,$5F,$6E,$73,$73,$69,$5A,$46,$2D,$0F,$FB,$EC,$E2
	dc.b $E2,$F1,$05,$1E,$3C,$55,$6E,$7D,$1A,$7D,$73,$5A,$41,$1E,$00,$E7
	dc.b $D8,$D3,$D8,$E7,$00,$1E,$3C,$5A,$73,$1A,$1B,$1A,$6E,$55,$37,$19
	dc.b $F6,$DD,$D3,$CE,$D8,$E7,$05,$23,$46,$64,$78,$1B,$1B,$7D,$69,$50
	dc.b $2D,$0F,$F1,$E2,$D3,$D3,$DD,$F1,$0A,$2D,$4B,$64,$78,$1A,$1A,$73
	dc.b $64,$4B,$2D,$0F,$F6,$E7,$E2,$E2,$F1,$00,$19,$32,$4B,$64,$6E,$73
	dc.b $73,$69,$55,$41,$28,$14,$00,$F6,$F1,$F6,$00,$0F,$23,$37,$4B,$5A
	dc.b $5F,$64,$5F,$50,$46,$37,$23,$19,$0F,$0A,$05,$0A,$14,$1E,$28,$37
	dc.b $3C,$46,$46,$46,$41,$3C,$37,$2D,$28,$23,$1E,$1E,$1E,$23,$28,$28
	dc.b $2D,$2D,$2D,$2D,$2D,$28,$28,$28,$28,$28,$2D,$32,$32,$37,$37,$37
	dc.b $37,$2D,$28,$1E,$19,$14,$0F,$0F,$14,$19,$23,$2D,$3C,$46,$4B,$50
	dc.b $50,$4B,$41,$37,$28,$19,$0A,$00,$FB,$00,$05,$14,$23,$37,$4B,$5A
	dc.b $69,$6E,$6E,$64,$50,$3C,$28,$0F,$FB,$F1,$EC,$F1,$FB,$0F,$28,$41
	dc.b $5A,$6E,$78,$7D,$78,$69,$55,$37,$19,$00,$E7,$DD,$D8,$DD,$F1,$0A
	dc.b $28,$46,$64,$78,$1A,$1A,$7D,$69,$4B,$2D,$0F,$F1,$D8,$CE,$CE,$D8
	dc.b $EC,$05,$28,$46,$69,$7D,$1B,$1A,$78,$64,$46,$28,$05,$EC,$D8,$CE
	dc.b $CE,$DD,$F6,$14,$32,$55,$6E,$7D,$1B,$1A,$73,$5F,$41,$23,$0A,$F1
	dc.b $E2,$D8,$DD,$EC,$05,$1E,$3C,$5A,$6E,$7D,$7D,$78,$69,$55,$3C,$23
	dc.b $0A,$F6,$EC,$E7,$EC,$FB,$0F,$28,$3C,$50,$5F,$69,$69,$64,$55,$46
	dc.b $32,$1E,$0F,$00,$FB,$FB,$05,$0F,$1E,$2D,$3C,$4B,$50,$55,$55,$4B
	dc.b $41,$37,$2D,$23,$19,$14,$14,$14,$19,$1E,$28,$2D,$32,$37,$37,$37
	dc.b $37,$32,$32,$2D,$2D,$28,$28,$28,$28,$2D,$2D,$2D,$2D,$28,$28,$23
	dc.b $1E,$1E,$1E,$1E,$23,$28,$32,$37,$41,$46,$46,$46,$41,$3C,$32,$28
	dc.b $19,$0F,$0A,$05,$0A,$0F,$1E,$28,$3C,$4B,$55,$5F,$5F,$5A,$55,$46
	dc.b $32,$23,$0F,$00,$F6,$F1,$FB,$05,$19,$2D,$46,$5A,$69,$73,$73,$6E
	dc.b $5F,$46,$2D,$14,$FB,$EC,$E2,$DD,$E7,$FB,$0F,$2D,$4B,$64,$78,$7D
	dc.b $7D,$73,$5F,$46,$23,$05,$EC,$D8,$D3,$D3,$DD,$F6,$14,$32,$55,$6E
	dc.b $7D,$1B,$1A,$73,$5F,$41,$1E,$00,$E7,$D3,$CE,$D3,$E2,$FB,$19,$3C
	dc.b $5A,$73,$1A,$1C,$1B,$73,$5A,$3C,$1E,$00,$E7,$DD,$D3,$DD,$F1,$05
	dc.b $28,$46,$5F,$73,$1A,$1A,$78,$69,$50,$37,$19,$00,$EC,$E2,$E2,$EC
	dc.b $FB,$0F,$2D,$46,$5A,$6E,$73,$73,$69,$5A,$46,$2D,$14,$05,$F6,$F1
	dc.b $F1,$FB,$0A,$19,$2D,$41,$50,$5A,$5F,$5A,$55,$46,$37,$28,$19,$0F
	dc.b $05,$05,$05,$0F,$19,$23,$32,$37,$41,$46,$46,$41,$3C,$37,$2D,$28
	dc.b $23,$1E,$1E,$1E,$23,$23,$28,$28,$2D,$2D,$2D,$2D,$2D,$2D,$2D,$2D
	dc.b $2D,$32,$32,$37,$3C,$3C,$3C,$37,$37,$2D,$28,$1E,$19,$14,$14,$19
	dc.b $1E,$23,$2D,$3C,$46,$50,$55,$55,$50,$4B,$3C,$2D,$1E,$0F,$05,$00
	dc.b $00,$05,$0F,$1E,$32,$46,$55,$5F,$69,$69,$64,$55,$41,$28,$0F,$FB
	dc.b $EC,$E7,$E7,$F1,$00,$19,$32,$4B,$64,$73,$78,$73,$69,$55,$3C,$1E
	dc.b $05,$EC,$DD,$D8,$D8,$E7,$FB,$19,$37,$55,$6E,$7D,$1B,$1A,$6E,$55
	dc.b $37,$19,$FB,$E2,$D3,$D3,$D8,$EC,$05,$23,$46,$64,$7D,$1B,$1B,$1A
	dc.b $73,$55,$37,$19,$F6,$E2,$D8,$D3,$DD,$F1,$0F,$2D,$50,$69,$7D,$1B
	dc.b $1B,$7D,$69,$4B,$2D,$0F,$F6,$E7,$DD,$DD,$E7,$FB,$14,$32,$4B,$64
	dc.b $73,$78,$78,$69,$55,$41,$23,$0A,$F6,$E7,$E7,$E7,$F1,$05,$1E,$37
	dc.b $4B,$5A,$69,$69,$64,$5A,$46,$32,$23,$0F,$00,$FB,$FB,$00,$0A,$19
	dc.b $28,$37,$41,$4B,$50,$50,$4B,$46,$3C,$2D,$23,$19,$14,$0F,$14,$14
	dc.b $1E,$23,$28,$32,$37,$37,$3C,$37,$37,$32,$2D,$2D,$2D,$2D,$2D,$2D
	dc.b $32,$32,$32,$32,$2D,$2D,$28,$28,$23,$23,$23,$28,$28,$32,$37,$3C
	dc.b $41,$46,$46,$41,$3C,$37,$2D,$23,$19,$0F,$0A,$0A,$0F,$19,$28,$37
	dc.b $46,$50,$5A,$5F,$5A,$50,$46,$37,$23,$0F,$00,$F6,$F1,$F6,$00,$0F
	dc.b $23,$3C,$50,$64,$6E,$6E,$69,$5A,$46,$2D,$14,$FB,$E7,$DD,$D8,$E2
	dc.b $F1,$0A,$28,$46,$5F,$78,$1A,$1A,$78,$69,$50,$32,$0F,$F1,$DD,$D3
	dc.b $CE,$D8,$EC,$0A,$2D,$50,$6E,$1A,$1D,$1D,$1B,$73,$55,$32,$0F,$F1
	dc.b $DD,$D3,$D3,$DD,$F1,$0F,$32,$50,$6E,$7D,$1B,$1B,$7D,$64,$4B,$2D
	dc.b $0A,$F1,$DD,$D3,$D8,$E2,$F6,$14,$32,$50,$64,$73,$78,$73,$69,$55
	dc.b $3C,$1E,$05,$F1,$E7,$E2,$E7,$F6,$0A,$23,$3C,$50,$64,$6E,$6E,$64
	dc.b $5A,$46,$32,$1E,$05,$FB,$F1,$F1,$FB,$05,$19,$2D,$3C,$50,$5A,$5F
	dc.b $5A,$55,$4B,$3C,$2D,$1E,$0F,$0A,$05,$0A,$0F,$19,$23,$32,$3C,$46
	dc.b $4B,$4B,$4B,$46,$41,$37,$32,$2D,$23,$23,$23,$23,$28,$28,$28,$28
	dc.b $2D,$2D,$2D,$2D,$2D,$2D,$2D,$2D,$32,$37,$37,$3C,$3C,$3C,$37,$37
	dc.b $2D,$28,$1E,$19,$14,$0F,$0F,$19,$1E,$28,$37,$41,$4B,$55,$55,$55
	dc.b $50,$41,$32,$23,$0F,$05,$FB,$F6,$FB,$00,$0F,$23,$37,$4B,$55,$5F
	dc.b $64,$5F,$55,$41,$32,$19,$05,$F6,$EC,$E7,$EC,$FB,$0F,$28,$41,$5A
	dc.b $69,$78,$78,$6E,$5F,$4B,$2D,$14,$FB,$E7,$E2,$E2,$EC,$05,$1E,$3C
	dc.b $5A,$73,$1A,$1B,$1A,$78,$5F,$41,$23,$05,$EC,$D8,$D3,$D8,$E7,$FB
	dc.b $19,$3C,$5A,$78,$1B,$1C,$1B,$78,$5A,$3C,$1E,$FB,$E2,$D3,$CE,$D3
	dc.b $E2,$00,$1E,$3C,$5F,$73,$1A,$1B,$1A,$6E,$55,$37,$19,$FB,$E7,$D8
	dc.b $D8,$DD,$F1,$05,$23,$41,$5A,$69,$73,$73,$69,$5A,$46,$2D,$14,$00
	dc.b $F1,$E7,$EC,$F1,$05,$19,$2D,$46,$55,$64,$69,$64,$5A,$4B,$3C,$28
	dc.b $19,$0A,$00,$FB,$00,$0A,$19,$28,$37,$46,$50,$55,$5A,$55,$4B,$41
	dc.b $32,$28,$1E,$14,$0F,$0F,$14,$19,$23,$2D,$32,$37,$3C,$41,$41,$3C
	dc.b $3C,$37,$32,$2D,$2D,$2D,$2D,$2D,$2D,$2D,$2D,$28,$28,$23,$23,$1E
	dc.b $1E,$1E,$23,$28,$32,$37,$41,$41,$46,$46,$46,$3C,$37,$28,$1E,$14
	dc.b $0A,$00,$00,$05,$0A,$19,$28,$37,$46,$55,$5A,$5A,$55,$4B,$3C,$28
	dc.b $19,$05,$FB,$F1,$F1,$FB,$05,$19,$32,$4B,$5A,$69,$73,$6E,$69,$55
	dc.b $41,$28,$0F,$FB,$EC,$E7,$E7,$F6,$05,$23,$3C,$5A,$6E,$7D,$1A,$7D
	dc.b $6E,$55,$37,$19,$FB,$E7,$D8,$D3,$DD,$EC,$05,$28,$46,$64,$7D,$1B
	dc.b $1C,$1A,$6E,$55,$37,$14,$F6,$DD,$CE,$CE,$D8,$EC,$05,$28,$4B,$69
	dc.b $7D,$1B,$1C,$1A,$69,$50,$2D,$0F,$F1,$DD,$D3,$D3,$DD,$F1,$0A,$28
	dc.b $46,$5F,$73,$78,$78,$6E,$5F,$46,$2D,$0F,$F6,$E7,$E2,$E7,$F1,$05
	dc.b $19,$37,$50,$5F,$6E,$6E,$6E,$5F,$50,$3C,$23,$0F,$00,$F6,$F6,$FB
	dc.b $05,$19,$28,$3C,$50,$5A,$64,$64,$5A,$50,$41,$32,$1E,$14,$05,$00
	dc.b $05,$0A,$14,$1E,$2D,$37,$41,$46,$4B,$46,$46,$41,$37,$2D,$28,$23
	dc.b $1E,$1E,$1E,$1E,$23,$28,$28,$2D,$2D,$2D,$2D,$2D,$2D,$2D,$2D,$2D
	dc.b $32,$37,$37,$3C,$3C,$37,$37,$2D,$28,$1E,$14,$0F,$0A,$0F,$14,$19
	dc.b $23,$32,$3C,$46,$50,$55,$55,$50,$46,$37,$28,$19,$0A,$00,$FB,$FB
	dc.b $05,$14,$23,$37,$4B,$5A,$64,$6E,$69,$5F,$50,$3C,$23,$0F,$FB,$F1
	dc.b $EC,$F1,$FB,$0F,$28,$41,$5A,$69,$73,$78,$73,$64,$4B,$32,$19,$FB
	dc.b $E7,$DD,$D8,$E2,$F1,$0F,$2D,$4B,$69,$7D,$1B,$1B,$7D,$64,$4B,$28
	dc.b $0A,$EC,$D8,$CE,$CE,$DD,$F1,$0F,$2D,$50,$69,$7D,$1B,$1B,$7D,$64
	dc.b $46,$28,$05,$E7,$D8,$CE,$CE,$D8,$F1,$0F,$2D,$50,$69,$78,$1A,$7D
	dc.b $6E,$5A,$41,$23,$0A,$F1,$E2,$DD,$E2,$F1,$05,$1E,$3C,$55,$6E,$78
	dc.b $7D,$78,$69,$55,$3C,$23,$0F,$FB,$F1,$F1,$F6,$05,$14,$2D,$41,$55
	dc.b $64,$69,$64,$5F,$50,$3C,$2D,$19,$0A,$00,$FB,$FB,$00,$0F,$1E,$2D
	dc.b $3C,$4B,$50,$55,$50,$4B,$41,$37,$28,$1E,$19,$14,$0F,$14,$19,$1E
	dc.b $28,$2D,$32,$37,$37,$37,$37,$37,$32,$2D,$2D,$2D,$2D,$2D,$28,$28
	dc.b $2D,$28,$28,$23,$23,$1E,$1E,$19,$1E,$1E,$23,$28,$32,$37,$41,$46
	dc.b $4B,$46,$46,$3C,$32,$28,$19,$0F,$0A,$0A,$0A,$14,$1E,$2D,$3C,$4B
	dc.b $55,$5F,$5F,$5F,$55,$46,$37,$23,$0F,$00,$F6,$F1,$F6,$00,$14,$28
	dc.b $41,$55,$69,$73,$6E,$69,$5A,$46,$2D,$14,$FB,$EC,$E2,$E2,$EC,$00
	dc.b $14,$32,$50,$69,$78,$1A,$7D,$73,$5F,$46,$23,$05,$EC,$DD,$D3,$D3
	dc.b $E2,$FB,$19,$37,$55,$73,$1A,$1B,$1A,$73,$5A,$3C,$19,$FB,$DD,$CE
	dc.b $C9,$D3,$DD,$FB,$19,$3C,$5A,$73,$1A,$1B,$1A,$73,$5A,$3C,$1E,$00
	dc.b $E7,$DD,$D8,$DD,$F1,$0A,$28,$46,$64,$78,$1A,$1A,$78,$69,$50,$37
	dc.b $19,$00,$F1,$E7,$E7,$EC,$FB,$14,$2D,$46,$5A,$69,$73,$6E,$64,$55
	dc.b $3C,$28,$0F,$00,$F1,$EC,$F1,$FB,$0A,$1E,$32,$46,$50,$5A,$5F,$5A
	dc.b $50,$46,$37,$28,$19,$0F,$05,$05,$0A,$0F,$19,$28,$32,$3C,$46,$46
	dc.b $46,$46,$41,$37,$2D,$28,$23,$1E,$1E,$1E,$1E,$23,$23,$28,$28,$28
	dc.b $28,$28,$28,$28,$28,$2D,$2D,$32,$37,$37,$3C,$3C,$3C,$3C,$37,$32
	dc.b $28,$23,$1E,$19,$14,$19,$1E,$28,$32,$3C,$46,$50,$55,$55,$50,$4B
	dc.b $3C,$2D,$1E,$0F,$05,$00,$FB,$05,$0F,$1E,$2D,$41,$55,$5F,$64,$64
	dc.b $5F,$50,$3C,$28,$0F,$FB,$EC,$E7,$E7,$F1,$05,$19,$37,$50,$64,$73
	dc.b $78,$78,$69,$55,$3C,$1E,$00,$EC,$D8,$D8,$DD,$E7,$00,$1E,$3C,$5A
	dc.b $73,$7D,$1B,$7D,$6E,$55,$37,$19,$FB,$E2,$D3,$D3,$D8,$EC,$05,$28
	dc.b $46,$64,$7D,$1B,$1B,$7D,$6E,$50,$32,$14,$F6,$E2,$D8,$D3,$DD,$F1
	dc.b $0F,$2D,$50,$69,$7D,$1B,$1B,$7D,$69,$4B,$2D,$0F,$F6,$E7,$DD,$DD
	dc.b $EC,$00,$19,$32,$50,$69,$73,$78,$78,$69,$55,$3C,$23,$0A,$F6,$EC
	dc.b $E7,$E7,$F6,$05,$1E,$32,$4B,$5A,$64,$64,$5F,$55,$46,$32,$1E,$0F
	dc.b $00,$FB,$FB,$00,$0A,$19,$28,$37,$46,$4B,$50,$50,$4B,$46,$3C,$2D
	dc.b $23,$1E,$14,$14,$14,$19,$1E,$28,$2D,$32,$37,$37,$37,$37,$32,$32
	dc.b $2D,$2D,$28,$28,$2D,$2D,$2D,$32,$32,$2D,$2D,$2D,$28,$23,$23,$23
	dc.b $23,$28,$2D,$32,$3C,$41,$46,$4B,$4B,$46,$41,$37,$2D,$23,$14,$0F
	dc.b $0A,$0A,$0F,$19,$28,$37,$46,$50,$5A,$5F,$5A,$55,$46,$32,$1E,$0F
	dc.b $FB,$F1,$EC,$F1,$FB,$0A,$1E,$37,$4B,$5F,$69,$6E,$69,$5F,$4B,$32
	dc.b $14,$00,$EC,$DD,$D8,$E2,$F1,$0A,$23,$41,$5F,$73,$7D,$1A,$78,$69
	dc.b $50,$32,$14,$F6,$E2,$D8,$D8,$E2,$F6,$0F,$32,$50,$6E,$1A,$1C,$1C
	dc.b $7D,$69,$4B,$2D,$0A,$EC,$D8,$D3,$D3,$E2,$F6,$14,$37,$55,$73,$1A
	dc.b $1C,$1B,$78,$5F,$46,$23,$05,$EC,$DD,$D3,$D8,$E7,$00,$1E,$3C,$5A
	dc.b $6E,$7D,$1A,$7D,$6E,$55,$3C,$1E,$05,$EC,$E2,$DD,$E7,$F6,$0A,$23
	dc.b $3C,$50,$64,$6E,$6E,$69,$5A,$46,$2D,$19,$05,$F6,$EC,$EC,$F6,$00
	dc.b $14,$28,$3C,$4B,$5A,$5F,$5A,$55,$46,$3C,$2D,$1E,$14,$0A,$0A,$0A
	dc.b $0F,$19,$23,$32,$3C,$41,$46,$4B,$46,$41,$3C,$32,$2D,$28,$23,$1E
	dc.b $1E,$23,$28,$2D,$2D,$32,$32,$32,$2D,$2D,$2D,$28,$2D,$2D,$2D,$32
	dc.b $37,$37,$37,$3C,$37,$32,$2D,$28,$1E,$19,$14,$14,$14,$19,$23,$2D
	dc.b $37,$41,$4B,$50,$55,$50,$4B,$41,$32,$23,$0F,$05,$FB,$FB,$00,$0A
	dc.b $19,$2D,$41,$50,$5F,$69,$69,$64,$55,$41,$2D,$14,$00,$F1,$E7,$E7
	dc.b $EC,$FB,$0F,$28,$46,$5A,$6E,$78,$78,$6E,$5A,$46,$28,$0A,$F1,$DD
	dc.b $D8,$D8,$E7,$FB,$19,$37,$55,$6E,$1A,$1B,$1B,$78,$5F,$46,$23,$05
	dc.b $EC,$DD,$D3,$D8,$E7,$00,$1E,$3C,$5F,$78,$1B,$1C,$1B,$78,$5A,$3C
	dc.b $19,$FB,$E2,$D3,$CE,$D8,$E7,$00,$23,$41,$5F,$73,$1A,$1A,$7D,$69
	dc.b $50,$32,$14,$F6,$E2,$D8,$D3,$DD,$F1,$0A,$28,$41,$5F,$6E,$78,$78
	dc.b $6E,$5F,$46,$2D,$14,$FB,$EC,$E7,$E7,$F1,$00,$19,$2D,$46,$55,$64
	dc.b $69,$69,$5F,$50,$41,$2D,$19,$0A,$00,$00,$00,$0A,$14,$28,$37,$46
	dc.b $50,$55,$55,$50,$4B,$41,$32,$28,$1E,$19,$14,$14,$19,$1E,$28,$2D
	dc.b $32,$37,$3C,$3C,$3C,$37,$37,$32,$2D,$2D,$28,$28,$2D,$2D,$2D,$2D
	dc.b $2D,$2D,$2D,$28,$23,$1E,$1E,$1E,$1E,$23,$2D,$32,$3C,$41,$41,$41
	dc.b $41,$3C,$32,$28,$1E,$14,$0A,$05,$05,$0A,$14,$1E,$2D,$3C,$4B,$55
	dc.b $5F,$5F,$5A,$4B,$3C,$28,$14,$05,$F6,$F1,$F1,$FB,$0A,$1E,$37,$50
	dc.b $64,$6E,$73,$73,$69,$55,$41,$23,$0A,$F6,$E7,$E2,$E2,$F1,$05,$1E
	dc.b $3C,$55,$6E,$7D,$1A,$7D,$73,$5A,$3C,$1E,$00,$E7,$DD,$D8,$DD,$EC
	dc.b $05,$28,$46,$64,$78,$1B,$1B,$1A,$6E,$55,$37,$14,$F6,$DD,$D3,$D3
	dc.b $D8,$EC,$0A,$28,$4B,$69,$7D,$1B,$1B,$7D,$64,$4B,$28,$0A,$EC,$DD
	dc.b $CE,$CE,$DD,$F1,$0F,$2D,$4B,$64,$73,$7D,$7D,$6E,$5F,$46,$28,$0A
	dc.b $F1,$E2,$DD,$E2,$EC,$00,$19,$37,$50,$64,$73,$73,$73,$64,$55,$3C
	dc.b $28,$0F,$00,$F6,$F6,$FB,$05,$14,$28,$3C,$4B,$5A,$5F,$5F,$5A,$50
	dc.b $41,$32,$23,$14,$0A,$05,$05,$0A,$14,$1E,$2D,$37,$41,$41,$46,$41
	dc.b $41,$37,$32,$2D,$23,$23,$1E,$1E,$23,$23,$28,$28,$2D,$2D,$2D,$2D
	dc.b $2D,$2D,$2D,$2D,$2D,$2D,$32,$32,$37,$37,$3C,$37,$37,$32,$28,$23
	dc.b $19,$14,$0F,$0F,$14,$19,$23,$32,$3C,$46,$50,$50,$50,$4B,$41,$32
	dc.b $23,$14,$0A,$00,$FB,$00,$05,$14,$28,$3C,$4B,$5F,$69,$6E,$69,$5F
	dc.b $50,$3C,$23,$0A,$FB,$EC,$EC,$EC,$FB,$0F,$28,$46,$5F,$6E,$7D,$7D
	dc.b $78,$64,$50,$32,$14,$FB,$E7,$D8,$D8,$DD,$F1,$0A,$28,$46,$64,$78
	dc.b $1A,$1B,$7D,$69,$4B,$28,$0A,$EC,$D8,$CE,$CE,$DD,$F1,$0F,$32,$50
	dc.b $6E,$1A,$1B,$1B,$78,$64,$46,$23,$00,$E7,$D8,$CE,$CE,$DD,$F6,$14
	dc.b $37,$55,$6E,$7D,$1B,$1A,$6E,$5A,$3C,$1E,$00,$EC,$DD,$D8,$DD,$EC
	dc.b $05,$1E,$41,$5A,$6E,$7D,$7D,$78,$69,$55,$3C,$23,$0A,$FB,$F1,$EC
	dc.b $F1,$00,$14,$2D,$41,$55,$64,$6E,$69,$64,$55,$41,$2D,$1E,$0A,$00
	dc.b $FB,$FB,$05,$0F,$1E,$2D,$3C,$46,$50,$50,$50,$46,$41,$32,$28,$1E
	dc.b $19,$14,$14,$14,$19,$23,$28,$2D,$32,$37,$37,$37,$32,$32,$2D,$2D
	dc.b $28,$28,$28,$28,$2D,$2D,$2D,$2D,$2D,$28,$23,$23,$1E,$1E,$1E,$1E
	dc.b $23,$28,$2D,$37,$3C,$41,$46,$46,$46,$3C,$32,$28,$1E,$14,$0F,$0A
	dc.b $0F,$14,$23,$2D,$41,$50,$5A,$5F,$5F,$5A,$50,$41,$32,$1E,$0F,$00
	dc.b $F6,$F1,$F6,$05,$19,$2D,$46,$5A,$69,$73,$73,$69,$5A,$46,$2D,$14
	dc.b $FB,$EC,$E2,$E2,$EC,$00,$19,$32,$50,$69,$78,$7D,$7D,$73,$5F,$41
	dc.b $23,$05,$EC,$D8,$CE,$D3,$DD,$F6,$14,$37,$55,$6E,$7D,$1B,$1A,$6E
	dc.b $5A,$37,$19,$FB,$DD,$D3,$CE,$D3,$E7,$00,$1E,$41,$5F,$78,$1B,$1C
	dc.b $1A,$6E,$55,$37,$19,$FB,$E2,$D8,$D3,$DD,$F1,$0A,$2D,$4B,$64,$78
	dc.b $1A,$1A,$78,$69,$50,$32,$14,$FB,$E7,$E2,$E2,$EC,$00,$19,$32,$4B
	dc.b $5F,$6E,$78,$78,$6E,$5A,$46,$2D,$14,$00,$F1,$EC,$F1,$FB,$0A,$1E
	dc.b $32,$46,$55,$5F,$5F,$5A,$50,$46,$37,$23,$19,$0A,$05,$05,$0A,$0F
	dc.b $19,$23,$32,$37,$41,$46,$46,$41,$3C,$37,$2D,$28,$23,$1E,$1E,$1E
	dc.b $23,$23,$28,$28,$2D,$2D,$2D,$2D,$2D,$2D,$2D,$2D,$2D,$32,$37,$37
	dc.b $3C,$3C,$3C,$3C,$37,$2D,$28,$1E,$19,$14,$14,$14,$1E,$23,$2D,$3C
	dc.b $46,$4B,$50,$55,$50,$46,$3C,$2D,$19,$0A,$05,$FB,$FB,$05,$0F,$23
	dc.b $37,$4B,$5A,$64,$69,$69,$5F,$50,$3C,$28,$0F,$FB,$EC,$E7,$E7,$F1
	dc.b $05,$1E,$37,$50,$69,$78,$7D,$7D,$6E,$55,$3C,$1E,$00,$E7,$D8,$D8
	dc.b $D8,$E7,$00,$1E,$41,$5F,$73,$1A,$1B,$7D,$6E,$55,$37,$14,$F6,$DD
	dc.b $CE,$CE,$D3,$E7,$05,$23,$46,$64,$7D,$1B,$1B,$7D,$6E,$50,$32,$0F
	dc.b $F6,$E2,$D3,$D3,$DD,$F6,$0F,$2D,$50,$6E,$7D,$1C,$1C,$7D,$69,$50
	dc.b $2D,$0F,$F6,$E2,$D8,$DD,$E7,$FB,$19,$32,$50,$69,$78,$7D,$78,$69
	dc.b $55,$3C,$23,$0A,$F6,$EC,$E7,$E7,$F6,$05,$1E,$37,$4B,$5A,$64,$69
	dc.b $64,$55,$46,$32,$1E,$0F,$00,$F6,$F6,$FB,$05,$14,$23,$32,$41,$4B
	dc.b $50,$50,$4B,$41,$37,$2D,$23,$1E,$19,$19,$19,$1E,$23,$28,$2D,$37
	dc.b $3C,$3C,$3C,$3C,$37,$37,$32,$32,$2D,$2D,$2D,$2D,$2D,$32,$32,$2D
	dc.b $2D,$28,$23,$23,$1E,$1E,$23,$23,$2D,$32,$3C,$41,$46,$4B,$4B,$46
	dc.b $41,$37,$2D,$1E,$14,$0F,$0A,$0A,$0F,$19,$23,$32,$41,$50,$5A,$5A
	dc.b $5A,$50,$41,$32,$1E,$0A,$FB,$F1,$EC,$F1,$FB,$0F,$23,$3C,$55,$64
	dc.b $6E,$73,$6E,$5F,$4B,$37,$19,$00,$EC,$E2,$DD,$E2,$F6,$0A,$28,$46
	dc.b $5F,$73,$7D,$7D,$73,$5F,$46,$28,$0A,$EC,$DD,$D3,$D3,$DD,$F1,$0F
	dc.b $32,$50,$6E,$1A,$1C,$1C,$7D,$69,$50,$2D,$0F,$F1,$DD,$D8,$D8,$E7
	dc.b $FB,$19,$3C,$5A,$73,$1B,$1C,$1B,$78,$5F,$41,$1E,$00,$E7,$D8,$D3
	dc.b $D8,$E7,$00,$1E,$3C,$5A,$6E,$7D,$1A,$7D,$6E,$55,$3C,$1E,$00,$EC
	dc.b $E2,$DD,$E7,$F6,$0A,$23,$3C,$55,$64,$6E,$6E,$64,$55,$41,$2D,$14
	dc.b $00,$F1,$EC,$EC,$F6,$05,$14,$28,$3C,$50,$5A,$5F,$5F,$5A,$4B,$3C
	dc.b $2D,$1E,$14,$0A,$0A,$0A,$14,$19,$28,$32,$3C,$41,$46,$46,$46,$41
	dc.b $37,$32,$2D,$28,$23,$23,$23,$23,$28,$28,$2D,$32,$32,$32,$32,$32
	dc.b $2D,$2D,$2D,$32,$32,$37,$37,$3C,$3C,$3C,$37,$37,$2D,$28,$1E,$19
	dc.b $14,$0F,$14,$19,$1E,$28,$37,$41,$4B,$50,$55,$50,$4B,$3C,$32,$1E
	dc.b $0F,$05,$FB,$FB,$00,$0A,$19,$2D,$41,$50,$5F,$69,$69,$64,$55,$41
	dc.b $28,$0F,$FB,$EC,$E2,$E2,$EC,$FB,$14,$2D,$46,$5F,$6E,$78,$78,$6E
	dc.b $5F,$46,$28,$0A,$F1,$E2,$D8,$DD,$E7,$FB,$19,$3C,$5A,$73,$1A,$1B
	dc.b $1B,$78,$5F,$41,$23,$00,$E7,$D8,$D3,$D8,$E7,$00,$1E,$41,$5F,$78
	dc.b $1B,$1C,$1B,$78,$5F,$41,$1E,$FB,$E2,$D8,$D3,$D8,$EC,$05,$28,$46
	dc.b $64,$78,$1A,$1B,$7D,$69,$50,$2D,$0F,$F6,$E2,$D3,$D3,$DD,$F1,$0A
	dc.b $28,$46,$5F,$73,$78,$78,$6E,$5F,$46,$2D,$0F,$FB,$EC,$E7,$E7,$F1
	dc.b $00,$19,$2D,$46,$5A,$64,$69,$64,$5A,$4B,$3C,$28,$14,$05,$FB,$FB
	dc.b $00,$05,$14,$23,$32,$41,$4B,$55,$55,$55,$4B,$41,$37,$28,$23,$19
	dc.b $14,$14,$19,$1E,$28,$2D,$32,$37,$3C,$3C,$37,$37,$32,$32,$2D,$2D
	dc.b $2D,$2D,$2D,$2D,$2D,$2D,$2D,$2D,$28,$28,$23,$23,$1E,$1E,$23,$28
	dc.b $2D,$37,$3C,$41,$46,$46,$41,$3C,$32,$28,$1E,$0F,$05,$05,$05,$0A
	dc.b $14,$1E,$2D,$41,$4B,$55,$5A,$5A,$55,$4B,$3C,$28,$14,$05,$F6,$F1
	dc.b $F1,$FB,$0A,$23,$37,$50,$64,$73,$73,$73,$69,$55,$3C,$23,$05,$F1
	dc.b $E2,$DD,$E2,$F1,$05,$1E,$3C,$5A,$6E,$7D,$1A,$7D,$73,$5A,$3C,$1E
	dc.b $00,$E7,$DD,$D8,$DD,$F1,$0A,$28,$46,$64,$7D,$1B,$1B,$1A,$6E,$50
	dc.b $32,$0F,$F1,$DD,$CE,$CE,$D8,$EC,$05,$28,$46,$64,$78,$1A,$1A,$78
	dc.b $64,$46,$28,$0A,$EC,$DD,$D3,$D3,$E2,$F6,$14,$32,$50,$69,$78,$1A
	dc.b $7D,$6E,$5A,$41,$23,$0A,$F1,$E2,$DD,$E2,$F1,$05,$1E,$37,$50,$64
	dc.b $6E,$73,$6E,$64,$50,$37,$23,$0A,$FB,$F1,$F1,$F6,$05,$14,$28,$3C
	dc.b $4B,$5A,$5F,$5F,$5F,$55,$46,$37,$28,$19,$0F,$0A,$0A,$0F,$19,$23
	dc.b $32,$3C,$46,$46,$4B,$46,$41,$3C,$32,$2D,$23,$1E,$1E,$1E,$1E,$23
	dc.b $23,$28,$2D,$2D,$2D,$2D,$28,$28,$28,$28,$28,$28,$2D,$32,$32,$37
	dc.b $37,$37,$37,$32,$28,$23,$1E,$19,$14,$14,$19,$1E,$28,$32,$3C,$46
	dc.b $50,$50,$50,$4B,$41,$32,$23,$0F,$05,$FB,$F6,$FB,$05,$0F,$23,$37
	dc.b $46,$55,$64,$69,$64,$5A,$4B,$37,$1E,$0A,$F6,$EC,$EC,$F1,$00,$14
	dc.b $2D,$4B,$64,$73,$1A,$1A,$78,$69,$50,$32,$14,$FB,$E7,$DD,$DD,$E2
	dc.b $F6,$0F,$2D,$4B,$64,$78,$1A,$1B,$7D,$69,$4B,$28,$0A,$EC,$D8,$CE
	dc.b $D3,$DD,$F6,$14,$32,$55,$6E,$1A,$1B,$1B,$78,$5F,$46,$23,$05,$E7
	dc.b $D8,$CE,$D3,$E2,$FB,$19,$37,$55,$6E,$7D,$1A,$7D,$69,$55,$37,$19
	dc.b $FB,$E7,$D8,$D3,$DD,$EC,$05,$23,$3C,$5A,$6E,$78,$78,$73,$64,$50
	dc.b $37,$1E,$05,$F6,$EC,$EC,$F1,$00,$19,$2D,$46,$5A,$69,$6E,$6E,$64
	dc.b $55,$46,$32,$1E,$0F,$00,$FB,$00,$05,$0F,$1E,$2D,$3C,$46,$4B,$50
	dc.b $4B,$46,$3C,$32,$28,$1E,$14,$0F,$0F,$14,$19,$1E,$28,$2D,$32,$37
	dc.b $37,$37,$37,$32,$32,$2D,$2D,$2D,$2D,$2D,$32,$32,$32,$32,$32,$2D
	dc.b $28,$23,$23,$1E,$1E,$23,$23,$28,$32,$37,$3C,$41,$41,$41,$3C,$37
	dc.b $2D,$23,$14,$0A,$05,$05,$0A,$14,$1E,$2D,$41,$50,$5A,$64,$64,$5F
	dc.b $55,$41,$32,$1E,$0A,$00,$F6,$F1,$FB,$0A,$19,$32,$46,$5A,$6E,$73
	dc.b $73,$69,$5A,$41,$28,$0A,$F6,$E2,$D8,$D8,$E7,$FB,$14,$32,$50,$69
	dc.b $78,$1A,$7D,$73,$5F,$41,$23,$05,$EC,$DD,$D3,$D8,$E2,$FB,$19,$3C
	dc.b $5A,$73,$1A,$1B,$1A,$73,$5A,$3C,$19,$FB,$E2,$D3,$CE,$D8,$E7,$00
	dc.b $1E,$41,$5F,$78,$1A,$1B,$7D,$69,$50,$32,$14,$F6,$E2,$D8,$D3,$DD
	dc.b $F1,$0A,$2D,$4B,$69,$78,$1B,$1B,$7D,$69,$50,$32,$14,$FB,$EC,$E2
	dc.b $E2,$EC,$00,$19,$32,$4B,$5F,$6E,$73,$73,$69,$5A,$46,$2D,$14,$00
	dc.b $F6,$F1,$F1,$FB,$0A,$1E,$32,$41,$50,$5A,$5A,$55,$50,$41,$32,$23
	dc.b $14,$0F,$05,$05,$0A,$14,$1E,$28,$32,$3C,$41,$46,$46,$41,$3C,$32
	dc.b $2D,$28,$23,$1E,$1E,$1E,$23,$23,$28,$2D,$2D,$2D,$2D,$2D,$2D,$28
	dc.b $28,$28,$2D,$2D,$32,$32,$37,$37,$37,$37,$32,$28,$23,$1E,$19,$14
	dc.b $14,$19,$1E,$28,$32,$3C,$46,$50,$55,$55,$50,$46,$37,$2D,$19,$0F
	dc.b $05,$00,$00,$0A,$14,$28,$3C,$4B,$5F,$69,$6E,$6E,$64,$50,$3C,$28
	dc.b $0F,$FB,$EC,$E7,$EC,$F6,$05,$1E,$37,$50,$64,$73,$78,$73,$64,$50
	dc.b $37,$19,$00,$E7,$D8,$D3,$DD,$EC,$00,$1E,$3C,$5A,$6E,$7D,$1A,$78
	dc.b $69,$50,$32,$14,$F6,$E2,$D3,$D3,$DD,$EC,$0A,$28,$4B,$69,$7D,$1B
	dc.b $1B,$7D,$69,$4B,$2D,$0F,$F1,$DD,$D3,$D3,$DD,$F6,$0F,$32,$50,$69
	dc.b $7D,$1B,$1B,$78,$64,$4B,$28,$0F,$F1,$E2,$DD,$DD,$E7,$FB,$19,$37
	dc.b $50,$69,$78,$7D,$78,$69,$55,$41,$23,$0F,$FB,$EC,$EC,$EC,$FB,$0A
	dc.b $23,$37,$4B,$5F,$69,$69,$64,$5A,$46,$37,$23,$0F,$00,$FB,$F6,$FB
	dc.b $05,$14,$28,$32,$41,$4B,$50,$50,$4B,$41,$37,$2D,$23,$19,$14,$0F
	dc.b $14,$14,$19,$23,$28,$32,$37,$37,$3C,$3C,$3C,$37,$37,$32,$32,$2D
	dc.b $2D,$2D,$2D,$32,$2D,$2D,$2D,$28,$28,$23,$23,$23,$23,$28,$2D,$32
	dc.b $3C,$41,$46,$46,$46,$41,$3C,$2D,$23,$19,$0F,$0A,$05,$0A,$0F,$19
	dc.b $28,$37,$46,$50,$5A,$5F,$5A,$50,$41,$32,$1E,$0A,$FB,$F1,$EC,$F1
	dc.b $00,$14,$28,$41,$55,$69,$73,$73,$6E,$5F,$4B,$32,$14,$FB,$EC,$DD
	dc.b $DD,$E7,$F6,$0F,$2D,$4B,$64,$78,$1A,$1A,$78,$64,$46,$28,$0A,$EC
	dc.b $DD,$D3,$D3,$E2,$F6,$14,$32,$55,$73,$1A,$1C,$1B,$7D,$64,$46,$23
	dc.b $05,$E7,$D8,$D3,$D3,$E2,$FB,$19,$3C,$5F,$78,$1B,$1D,$1C,$78,$5F
	dc.b $41,$23,$00,$EC,$D8,$D3,$DD,$EC,$00,$23,$41,$5A,$6E,$7D,$7D,$78
	dc.b $69,$50,$37,$19,$FB,$E7,$DD,$DD,$E2,$F1,$0A,$23,$3C,$55,$69,$6E
	dc.b $6E,$64,$55,$41,$2D,$14,$00,$F6,$EC,$F1,$FB,$05,$19,$2D,$41,$50
	dc.b $5A,$5F,$5F,$55,$4B,$3C,$2D,$1E,$14,$0A,$0A,$0A,$14,$1E,$28,$32
	dc.b $3C,$41,$46,$46,$41,$3C,$37,$32,$2D,$28,$23,$23,$28,$28,$2D,$2D
	dc.b $32,$32,$32,$32,$2D,$2D,$28,$28,$28,$2D,$2D,$32,$37,$3C,$3C,$3C
	dc.b $3C,$37,$32,$28,$23,$19,$14,$14,$14,$19,$23,$2D,$37,$46,$4B,$50
	dc.b $55,$50,$46,$3C,$2D,$1E,$0F,$00,$FB,$F6,$FB,$05,$14,$28,$3C,$50
	dc.b $5A,$64,$69,$5F,$50,$41,$28,$0F,$FB,$EC,$E2,$E2,$EC,$FB,$14,$2D
	dc.b $4B,$5F,$6E,$78,$78,$6E,$5A,$41,$28,$0A,$F1,$E2,$DD,$DD,$EC,$00
	dc.b $1E,$3C,$5A,$73,$1A,$1C,$1B,$78,$5F,$41,$23,$05,$E7,$D8,$D3,$D8
	dc.b $EC,$05,$23,$46,$64,$7D,$1B,$1B,$1A,$73,$5A,$3C,$19,$FB,$E7,$D8
	dc.b $D3,$D8,$EC,$05,$28,$46,$64,$78,$1A,$1A,$78,$64,$4B,$2D,$0F,$F6
	dc.b $E2,$D8,$D8,$E2,$F6,$0F,$2D,$46,$5F,$6E,$78,$78,$69,$5A,$41,$28
	dc.b $0F,$F6,$EC,$E7,$E7,$F1,$05,$1E,$32,$4B,$5A,$69,$69,$69,$5A,$4B
	dc.b $37,$28,$14,$05,$00,$FB,$00,$0A,$14,$28,$37,$41,$4B,$55,$55,$50
	dc.b $46,$3C,$32,$28,$1E,$14,$14,$14,$19,$1E,$28,$2D,$37,$3C,$3C,$3C
	dc.b $3C,$37,$32,$32,$2D,$2D,$2D,$2D,$2D,$32,$32,$32,$32,$2D,$2D,$28
	dc.b $23,$23,$23,$23,$23,$28,$2D,$37,$3C,$41,$46,$46,$41,$3C,$37,$2D
	dc.b $1E,$14,$0A,$05,$05,$0A,$14,$1E,$2D,$41,$4B,$55,$5A,$5A,$50,$46
	dc.b $32,$23,$0F,$00,$F1,$EC,$EC,$F6,$0A,$1E,$37,$4B,$5F,$6E,$73,$6E
	dc.b $64,$50,$3C,$1E,$05,$F1,$E7,$DD,$E7,$F6,$0A,$28,$46,$5F,$78,$1A
	dc.b $1A,$7D,$6E,$55,$37,$19,$FB,$E7,$D8,$D8,$DD,$EC,$0A,$28,$4B,$69
	dc.b $7D,$1B,$1C,$1A,$6E,$50,$32,$0F,$F1,$D8,$CE,$D3,$DD,$F1,$0F,$2D
	dc.b $4B,$69,$7D,$1B,$1B,$78,$64,$46,$28,$05,$EC,$D8,$CE,$D3,$E2,$F6
	dc.b $14,$32,$50,$69,$7D,$1A,$7D,$6E,$5A,$41,$23,$05,$F1,$E2,$DD,$E2
	dc.b $F1,$05,$1E,$3C,$55,$69,$73,$73,$6E,$64,$50,$37,$23,$0F,$FB,$F1
	dc.b $F1,$F6,$05,$14,$28,$3C,$4B,$5A,$5F,$5F,$5A,$4B,$41,$32,$23,$14
	dc.b $0F,$0A,$0A,$0F,$19,$23,$2D,$37,$41,$46,$46,$46,$41,$3C,$32,$2D
	dc.b $23,$23,$1E,$1E,$23,$23,$28,$2D,$2D,$2D,$2D,$2D,$28,$28,$28,$28
	dc.b $2D,$2D,$32,$32,$37,$37,$37,$37,$32,$2D,$28,$1E,$19,$14,$0F,$0F
	dc.b $14,$1E,$28,$32,$3C,$46,$50,$50,$50,$4B,$41,$32,$23,$14,$05,$00
	dc.b $FB,$00,$05,$14,$28,$3C,$50,$5F,$69,$69,$64,$5A,$46,$32,$1E,$05
	dc.b $F6,$EC,$EC,$F1,$00,$14,$2D,$4B,$5F,$73,$7D,$1A,$78,$64,$50,$32
	dc.b $14,$FB,$E7,$DD,$DD,$E7,$F6,$14,$32,$50,$69,$7D,$1A,$1A,$78,$64
	dc.b $46,$28,$0A,$EC,$D8,$CE,$CE,$DD,$F6,$14,$32,$50,$6E,$7D,$1A,$1A
	dc.b $73,$5A,$3C,$1E,$FB,$E7,$D8,$CE,$D3,$E7,$FB,$19,$3C,$5A,$6E,$7D
	dc.b $1A,$7D,$6E,$5A,$37,$19,$00,$E7,$DD,$D8,$E2,$F1,$0A,$28,$46,$5F
	dc.b $73,$7D,$7D,$73,$64,$50,$37,$19,$05,$F6,$EC,$EC,$F1,$00,$14,$2D
	dc.b $46,$5A,$64,$69,$69,$5F,$55,$41,$2D,$19,$0A,$00,$FB,$FB,$05,$14
	dc.b $23,$32,$41,$4B,$50,$55,$50,$4B,$41,$37,$2D,$23,$19,$14,$14,$14
	dc.b $19,$23,$28,$2D,$37,$37,$37,$37,$37,$32,$2D,$2D,$28,$28,$28,$28
	dc.b $2D,$2D,$2D,$2D,$2D,$28,$23,$23,$1E,$19,$1E,$1E,$23,$28,$32,$37
	dc.b $41,$41,$46,$46,$41,$37,$2D,$23,$19,$0F,$0A,$05,$0A,$14,$1E,$2D
	dc.b $3C,$4B,$5A,$5F,$5F,$5F,$50,$41,$32,$1E,$0A,$FB,$F6,$F6,$FB,$0A
	dc.b $1E,$32,$4B,$5F,$6E,$73,$73,$6E,$5A,$46,$2D,$0F,$FB,$E7,$DD,$DD
	dc.b $EC,$00,$19,$37,$50,$69,$7D,$1A,$7D,$6E,$5A,$3C,$1E,$00,$E7,$D8
	dc.b $D3,$D3,$E2,$FB,$19,$3C,$5A,$73,$1A,$1B,$1A,$73,$5A,$3C,$19,$FB
	dc.b $E2,$D3,$D3,$D8,$E7,$05,$23,$46,$64,$78,$1B,$1B,$7D,$6E,$50,$32
	dc.b $14,$F6,$E2,$D8,$D3,$DD,$F1,$0F,$2D,$4B,$64,$78,$1A,$1A,$78,$64
	dc.b $4B,$2D,$0F,$F6,$E7,$E2,$E2,$EC,$00,$19,$37,$50,$64,$73,$78,$73
	dc.b $69,$55,$41,$28,$14,$00,$F6,$F1,$F6,$00,$0F,$1E,$37,$46,$55,$5F
	dc.b $5F,$5A,$55,$46,$37,$23,$14,$0A,$05,$05,$0A,$0F,$19,$28,$32,$3C
	dc.b $41,$41,$41,$41,$3C,$32,$2D,$28,$23,$1E,$1E,$1E,$1E,$23,$28,$28
	dc.b $2D,$2D,$2D,$2D,$28,$28,$28,$2D,$2D,$32,$37,$3C,$3C,$3C,$3C,$3C
	dc.b $32,$2D,$23,$1E,$19,$14,$14,$19,$1E,$28,$32,$3C,$4B,$50,$55,$55
	dc.b $50,$46,$3C,$2D,$19,$0F,$05,$00,$00,$05,$14,$23,$37,$4B,$5A,$64
	dc.b $69,$69,$5F,$50,$37,$23,$0A,$F6,$EC,$E7,$EC,$F6,$0A,$23,$3C,$55
	dc.b $69,$73,$78,$73,$64,$4B,$32,$14,$FB,$E2,$D8,$D3,$D8,$EC,$05,$23
	dc.b $41,$5F,$73,$1A,$1A,$78,$69,$4B,$2D,$0F,$F1,$DD,$D3,$D3,$DD,$F1
	dc.b $0F,$2D,$4B,$69,$7D,$1B,$1B,$7D,$69,$4B,$2D,$0F,$F1,$DD,$D3,$D3
	dc.b $E2,$F6,$14,$32,$50,$69,$78,$1A,$7D,$6E,$5A,$41,$23,$0A,$F1,$E2
	dc.b $DD,$E2,$F1,$05,$1E,$3C,$55,$69,$78,$78,$73,$69,$50,$3C,$23,$0A
	dc.b $F6,$EC,$EC,$F1,$00,$14,$28,$3C,$50,$5F,$64,$64,$5F,$55,$46,$32
	dc.b $1E,$0F,$00,$FB,$FB,$00,$0A,$19,$23,$32,$41,$46,$4B,$4B,$46,$3C
	dc.b $32,$28,$1E,$19,$14,$0F,$14,$19,$1E,$23,$28,$2D,$32,$32,$32,$32
	dc.b $32,$32,$32,$32,$32,$32,$32,$32,$32,$32,$32,$32,$2D,$28,$28,$23
	dc.b $23,$23,$23,$28,$2D,$37,$41,$46,$4B,$4B,$4B,$46,$3C,$32,$23,$19
	dc.b $0F,$05,$05,$0A,$0F,$1E,$28,$3C,$4B,$55,$5A,$5F,$5A,$50,$41,$2D
	dc.b $1E,$0A,$FB,$F1,$EC,$F6,$00,$14,$28,$41,$5A,$69,$73,$73,$69,$5A
	dc.b $46,$2D,$14,$FB,$EC,$DD,$DD,$E7,$FB,$14,$2D,$4B,$64,$78,$7D,$7D
	dc.b $73,$5F,$46,$23,$05,$EC,$D8,$D3,$D3,$E2,$F6,$14,$37,$55,$73,$1A
	dc.b $1C,$1B,$78,$5F,$41,$23,$00,$E7,$D3,$D3,$D8,$E2,$00,$1E,$3C,$5F
	dc.b $78,$1B,$1C,$1B,$78,$5F,$41,$1E,$00,$E7,$D8,$D3,$DD,$EC,$05,$23
	dc.b $46,$5F,$73,$7D,$1A,$78,$64,$50,$32,$14,$FB,$E7,$DD,$DD,$E7,$F6
	dc.b $0F,$28,$46,$5A,$69,$73,$73,$69,$5A,$41,$28,$14,$00,$F1,$EC,$EC
	dc.b $F6,$0A,$19,$32,$46,$55,$5F,$64,$5F,$55,$4B,$3C,$28,$19,$0F,$0A
	dc.b $05,$05,$0F,$19,$28,$32,$3C,$46,$46,$46,$41,$3C,$37,$2D,$28,$23
	dc.b $1E,$1E,$1E,$23,$28,$2D,$2D,$32,$32,$32,$32,$32,$2D,$2D,$2D,$2D
	dc.b $32,$32,$37,$37,$3C,$3C,$3C,$37,$32,$28,$23,$1E,$19,$14,$14,$19
	dc.b $23,$2D,$37,$41,$4B,$55,$55,$50,$46,$3C,$2D,$1E,$0A,$00,$FB,$F6
	dc.b $FB,$05,$14,$28,$3C,$50,$5A,$64,$64,$5F,$50,$41,$28,$0F,$FB,$EC
	dc.b $E2,$E2,$EC,$FB,$14,$2D,$4B,$5F,$73,$78,$78,$6E,$5A,$41,$28,$0A
	dc.b $F1,$E2,$DD,$DD,$EC,$00,$1E,$3C,$5F,$78,$1B,$1C,$1B,$78,$5F,$41
	dc.b $23,$00,$E7,$D8,$D3,$D8,$E7,$05,$23,$46,$64,$7D,$1B,$1B,$1A,$73
	dc.b $55,$37,$14,$F6,$E2,$D3,$CE,$D8,$EC,$05,$28,$46,$64,$78,$1A,$1B
	dc.b $78,$64,$4B,$2D,$0F,$F6,$E2,$D8,$D8,$E7,$F6,$14,$32,$4B,$64,$73
	dc.b $78,$73,$69,$55,$41,$28,$0F,$F6,$EC,$E7,$EC,$F6,$05,$1E,$32,$4B
	dc.b $5A,$64,$69,$64,$5A,$46,$37,$23,$0F,$05,$FB,$FB,$00,$0A,$19,$28
	dc.b $37,$41,$4B,$50,$50,$50,$46,$3C,$32,$28,$1E,$19,$14,$19,$1E,$23
	dc.b $28,$32,$37,$3C,$3C,$3C,$3C,$37,$37,$32,$32,$32,$32,$32,$32,$37
	dc.b $37,$37,$32,$32,$2D,$28,$23,$23,$1E,$1E,$23,$28,$2D,$37,$3C,$41
	dc.b $46,$46,$41,$3C,$32,$28,$19,$0F,$05,$00,$00,$05,$0F,$1E,$2D,$3C
	dc.b $4B,$55,$5A,$5A,$55,$46,$37,$23,$0F,$00,$F6,$F1,$F1,$FB,$0A,$1E
	dc.b $37,$50,$64,$6E,$73,$73,$64,$55,$3C,$1E,$05,$F1,$E7,$E2,$E7,$F6
	dc.b $0A,$28,$46,$5F,$78,$1A,$1A,$7D,$6E,$55,$37,$19,$FB,$E7,$D8,$D8
	dc.b $DD,$F1,$0A,$2D,$4B,$69,$7D,$1B,$1B,$7D,$69,$4B,$2D,$0A,$EC,$D8
	dc.b $CE,$D3,$DD,$F1,$0F,$2D,$50,$6E,$7D,$1B,$1B,$78,$64,$46,$28,$0A
	dc.b $F1,$DD,$D3,$D8,$E7,$FB,$19,$37,$55,$69,$78,$1A,$7D,$6E,$5A,$3C
	dc.b $1E,$05,$EC,$E2,$DD,$E2,$F1,$05,$1E,$3C,$50,$64,$6E,$73,$6E,$5F
	dc.b $4B,$32,$1E,$0A,$FB,$F1,$F1,$F6,$05,$14,$28,$3C,$50,$5A,$64,$5F
	dc.b $5A,$50,$41,$32,$1E,$14,$0F,$0A,$0A,$0F,$19,$23,$32,$3C,$41,$46
	dc.b $4B,$4B,$46,$3C,$37,$2D,$28,$23,$1E,$1E,$23,$23,$28,$2D,$2D,$2D
	dc.b $2D,$2D,$2D,$28,$28,$28,$28,$2D,$2D,$32,$37,$37,$37,$37,$32,$2D
	dc.b $23,$1E,$19,$14,$0F,$0F,$14,$1E,$28,$32,$3C,$46,$4B,$50,$50,$4B
	dc.b $41,$32,$23,$14,$05,$00,$FB,$00,$05,$19,$28,$3C,$50,$5F,$69,$6E
	dc.b $69,$5A,$4B,$32,$1E,$05,$F6,$EC,$EC,$F1,$00,$14,$2D,$46,$5F,$73
	dc.b $7D,$7D,$73,$64,$4B,$2D,$0F,$F6,$E2,$D8,$DD,$E7,$F6,$14,$32,$50
	dc.b $6E,$7D,$1B,$1A,$78,$5F,$41,$23,$05,$EC,$D8,$CE,$D3,$E2,$F6,$14
	dc.b $37,$5A,$73,$1A,$1B,$1A,$73,$5A,$3C,$1E,$FB,$E2,$D3,$CE,$D3,$E7
	dc.b $00,$1E,$41,$5F,$73,$1A,$1B,$7D,$6E,$55,$37,$19,$FB,$E7,$D8,$D8
	dc.b $DD,$F1,$05,$23,$41,$5F,$73,$78,$7D,$73,$5F,$4B,$32,$14,$00,$F1
	dc.b $E7,$EC,$F1,$05,$19,$32,$46,$5A,$69,$6E,$6E,$64,$55,$41,$2D,$19
	dc.b $0A,$00,$FB,$00,$0A,$14,$23,$37,$41,$4B,$55,$55,$50,$4B,$41,$32
	dc.b $28,$1E,$19,$14,$14,$14,$19,$23,$28,$2D,$32,$37,$37,$37,$37,$32
	dc.b $2D,$2D,$28,$28,$28,$28,$28,$2D,$2D,$2D,$2D,$28,$23,$23,$1E,$1E
	dc.b $1E,$1E,$23,$28,$32,$37,$41,$46,$46,$46,$41,$37,$2D,$23,$14,$0F
	dc.b $0A,$05,$0A,$14,$1E,$2D,$41,$50,$5A,$5F,$5F,$5A,$50,$41,$2D,$19
	dc.b $0A,$FB,$F1,$F1,$FB,$0A,$1E,$32,$4B,$5F,$6E,$73,$73,$69,$5A,$41
	dc.b $28,$0F,$F6,$E7,$DD,$E2,$EC,$00,$19,$37,$55,$6E,$7D,$1A,$7D,$73
	dc.b $5A,$41,$1E,$00,$E7,$D8,$D3,$D3,$E7,$00,$1E,$3C,$5A,$73,$1A,$1B
	dc.b $7D,$6E,$55,$37,$19,$FB,$E2,$D3,$D3,$D8,$EC,$05,$23,$46,$5F,$73
	dc.b $1A,$1A,$78,$64,$4B,$2D,$0F,$F6,$E2,$D8,$D8,$E2,$F6,$0F,$32,$4B
	dc.b $64,$78,$7D,$7D,$73,$5F,$46,$28,$0F,$F6,$E7,$E2,$E7,$F1,$05,$1E
	dc.b $37,$50,$64,$73,$73,$73,$64,$50,$3C,$23,$0F,$00,$F1,$F1,$F6,$00
	dc.b $0F,$23,$37,$4B,$55,$5F,$5F,$5A,$50,$46,$32,$23,$14,$0A,$05,$05
	dc.b $0A,$14,$1E,$28,$37,$3C,$41,$46,$46,$41,$3C,$37,$32,$28,$23,$23
	dc.b $1E,$23,$23,$23,$28,$28,$2D,$2D,$28,$28,$28,$28,$28,$28,$2D,$2D
	dc.b $32,$37,$37,$3C,$3C,$37,$32,$2D,$23,$1E,$14,$14,$14,$14,$1E,$28
	dc.b $32,$41,$4B,$55,$55,$55,$50,$46,$3C,$2D,$1E,$0F,$05,$00,$00,$0A
	dc.b $14,$28,$37,$4B,$5A,$64,$69,$69,$5A,$4B,$37,$1E,$05,$F1,$E7,$E2
	dc.b $E7,$F6,$0A,$23,$41,$55,$69,$78,$78,$73,$64,$4B,$32,$14,$FB,$E2
	dc.b $D8,$D8,$DD,$EC,$0A,$28,$46,$64,$78,$1A,$1B,$7D,$69,$4B,$2D,$0F
	dc.b $F1,$DD,$CE,$CE,$DD,$F1,$0F,$2D,$50,$69,$7D,$1B,$1B,$7D,$64,$4B
	dc.b $2D,$0A,$F1,$DD,$D3,$D3,$E2,$FB,$14,$37,$55,$6E,$7D,$1B,$1A,$73
	dc.b $5F,$41,$23,$0A,$F1,$E2,$DD,$E2,$F1,$05,$1E,$3C,$55,$69,$78,$7D
	dc.b $78,$69,$55,$3C,$23,$0A,$F6,$EC,$EC,$F1,$FB,$0F,$23,$3C,$50,$5A
	dc.b $64,$64,$5F,$55,$41,$32,$1E,$0F,$05,$FB,$FB,$00,$0A,$19,$23,$32
	dc.b $41,$4B,$50,$50,$4B,$41,$37,$2D,$23,$19,$14,$14,$14,$19,$1E,$23
	dc.b $2D,$2D,$32,$37,$37,$37,$32,$32,$32,$2D,$2D,$2D,$32,$32,$32,$32
	dc.b $32,$2D,$28,$23,$23,$1E,$1E,$1E,$23,$28,$2D,$37,$41,$46,$4B,$4B
	dc.b $4B,$46,$41,$37,$28,$1E,$14,$0A,$05,$0A,$14,$1E,$2D,$3C,$4B,$55
	dc.b $5F,$5F,$5A,$50,$46,$32,$1E,$0A,$FB,$F1,$EC,$F6,$00,$14,$28,$41
	dc.b $5A,$69,$73,$73,$6E,$5F,$46,$2D,$0F,$F6,$E2,$D8,$D8,$E2,$F6,$0F
	dc.b $2D,$4B,$64,$78,$1A,$7D,$73,$5F,$46,$28,$05,$EC,$D8,$CE,$CE,$DD
	dc.b $F6,$14,$37,$55,$73,$1B,$1C,$1C,$7D,$64,$46,$23,$00,$E7,$D8,$D3
	dc.b $D3,$E2,$00,$1E,$41,$5F,$7D,$1C,$1D,$1C,$78,$5A,$3C,$19,$FB,$E2
	dc.b $D3,$CE,$D8,$E7,$05,$23,$46,$64,$78,$1A,$1B,$7D,$69,$50,$32,$14
	dc.b $FB,$E7,$DD,$DD,$E7,$FB,$0F,$2D,$46,$5F,$6E,$73,$73,$6E,$5A,$41
	dc.b $2D,$14,$00,$F1,$EC,$EC,$F6,$05,$1E,$32,$46,$55,$5F,$5F,$5A,$55
	dc.b $46,$37,$28,$19,$0A,$05,$00,$05,$0F,$19,$23,$32,$3C,$41,$46,$46
	dc.b $46,$41,$37,$32,$28,$23,$1E,$1E,$23,$23,$28,$2D,$2D,$32,$32,$32
	dc.b $2D,$2D,$2D,$2D,$2D,$2D,$32,$37,$37,$3C,$3C,$3C,$3C,$37,$32,$28
	dc.b $23,$19,$14,$14,$14,$19,$23,$2D,$37,$46,$4B,$50,$50,$4B,$46,$3C
	dc.b $28,$19,$0A,$00,$FB,$FB,$00,$0A,$1E,$2D,$41,$50,$5F,$64,$64,$5F
	dc.b $4B,$3C,$23,$0F,$FB,$EC,$E7,$EC,$F1,$05,$1E,$37,$50,$69,$78,$7D
	dc.b $78,$6E,$55,$3C,$1E,$05,$EC,$DD,$D8,$DD,$EC,$05,$23,$41,$5A,$73
	dc.b $1A,$1B,$1A,$6E,$55,$37,$19,$FB,$E2,$D3,$D3,$D8,$EC,$05,$28,$46
	dc.b $64,$7D,$1B,$1B,$7D,$6E,$50,$32,$0F,$F1,$DD,$D3,$D3,$DD,$F6,$0F
	dc.b $2D,$50,$69,$7D,$1B,$1B,$78,$64,$4B,$28,$0A,$F6,$E2,$D8,$DD,$E7
	dc.b $FB,$14,$32,$50,$64,$73,$78,$73,$69,$55,$3C,$23,$05,$F1,$E7,$E2
	dc.b $E7,$F1,$05,$1E,$37,$4B,$5F,$69,$69,$64,$55,$46,$32,$1E,$0A,$00
	dc.b $F6,$F6,$00,$0A,$19,$2D,$3C,$4B,$55,$5A,$5A,$55,$4B,$3C,$32,$28
	dc.b $1E,$19,$14,$14,$1E,$23,$28,$32,$37,$3C,$41,$3C,$3C,$37,$32,$32
	dc.b $2D,$2D,$2D,$2D,$2D,$2D,$32,$32,$32,$2D,$2D,$28,$23,$1E,$1E,$1E
	dc.b $23,$28,$2D,$32,$3C,$41,$41,$41,$41,$3C,$32,$28,$1E,$14,$0A,$05
	dc.b $05,$0A,$14,$1E,$2D,$41,$4B,$55,$5A,$5A,$55,$46,$37,$23,$0F,$00
	dc.b $F1,$EC,$F1,$FB,$0A,$1E,$37,$50,$5F,$6E,$6E,$6E,$64,$50,$37,$1E
	dc.b $05,$F1,$E2,$DD,$E7,$F6,$0A,$28,$46,$5F,$73,$1A,$1A,$7D,$69,$50
	dc.b $32,$14,$FB,$E7,$DD,$D8,$E2,$F6,$0F,$32,$50,$6E,$1A,$1C,$1C,$1A
	dc.b $69,$50,$2D,$0F,$F1,$DD,$D3,$D3,$DD,$F6,$14,$32,$55,$6E,$7D,$1B
	dc.b $1B,$78,$5F,$41,$23,$05,$EC,$DD,$D3,$D8,$E7,$FB,$19,$37,$50,$69
	dc.b $78,$7D,$78,$69,$55,$37,$1E,$05,$EC,$E2,$DD,$E2,$F1,$0A,$23,$3C
	dc.b $55,$64,$6E,$6E,$69,$5F,$4B,$32,$1E,$0A,$FB,$F1,$F1,$F6,$05,$14
	dc.b $28,$3C,$4B,$5A,$5F,$5F,$55,$4B,$3C,$2D,$1E,$14,$0A,$0A,$0A,$0F
	dc.b $19,$23,$32,$3C,$41,$46,$46,$41,$41,$37,$32,$2D,$28,$23,$23,$23
	dc.b $23,$28,$2D,$2D,$32,$32,$32,$2D,$2D,$2D,$28,$2D,$2D,$32,$32,$37
	dc.b $3C,$3C,$3C,$3C,$37,$2D,$28,$1E,$19,$14,$0F,$0F,$14,$19,$28,$32
	dc.b $41,$4B,$50,$55,$50,$4B,$41,$32,$1E,$0F,$00,$FB,$F6,$FB,$05,$14
	dc.b $28,$3C,$50,$5F,$69,$6E,$69,$5F,$4B,$32,$19,$05,$F6,$EC,$E7,$EC
	dc.b $00,$14,$2D,$4B,$5F,$73,$7D,$7D,$73,$64,$4B,$2D,$0F,$F6,$E2,$D8
	dc.b $D8,$E2,$F6,$14,$32,$55,$6E,$1A,$1B,$1B,$78,$64,$41,$23,$05,$E7
	dc.b $D8,$CE,$D3,$E2,$F6,$14,$37,$5A,$73,$1A,$1B,$1B,$78,$5F,$3C,$1E
	dc.b $FB,$E2,$D3,$CE,$D3,$E7,$00,$1E,$41,$5F,$73,$1A,$1B,$7D,$69,$55
	dc.b $37,$19,$FB,$E7,$D8,$D8,$E2,$F1,$0A,$28,$46,$5F,$73,$7D,$7D,$73
	dc.b $64,$4B,$32,$14,$00,$F1,$E7,$E7,$F1,$05,$19,$2D,$46,$5A,$69,$6E
	dc.b $69,$64,$55,$41,$2D,$1E,$0F,$00,$00,$00,$0A,$14,$23,$32,$41,$4B
	dc.b $55,$55,$50,$4B,$41,$32,$28,$1E,$14,$14,$0F,$14,$19,$23,$28,$2D
	dc.b $32,$37,$37,$37,$37,$32,$2D,$2D,$28,$28,$28,$28,$28,$28,$28,$28
	dc.b $28,$28,$23,$23,$1E,$1E,$1E,$23,$28,$2D,$32,$3C,$41,$46,$46,$46
	dc.b $41,$37,$2D,$1E,$14,$0A,$05,$05,$0A,$14,$23,$2D,$41,$4B,$55,$5F
	dc.b $5F,$5A,$50,$41,$2D,$19,$0A,$FB,$F6,$F6,$FB,$0A,$1E,$37,$4B,$5F
	dc.b $6E,$73,$73,$69,$55,$3C,$23,$0A,$F6,$E7,$E2,$E7,$F1,$05,$1E,$3C
	dc.b $5A,$6E,$7D,$1A,$7D,$6E,$5A,$3C,$1E,$FB,$E7,$D8,$D3,$D8,$E7,$00
	dc.b $1E,$41,$5F,$73,$1A,$1B,$7D,$69,$50,$32,$14,$F6,$DD,$D3,$CE,$D8
	dc.b $EC,$05,$23,$46,$64,$78,$1B,$1B,$7D,$69,$4B,$2D,$0F,$F1,$E2,$D3
	dc.b $D3,$E2,$F6,$14,$32,$50,$69,$78,$1A,$7D,$73,$5F,$46,$28,$0F,$F6
	dc.b $E7,$E2,$E2,$F1,$00,$19,$37,$50,$64,$6E,$73,$6E,$64,$50,$3C,$23
	dc.b $0F,$FB,$F1,$F1,$F6,$05,$14,$28,$3C,$4B,$5A,$5F,$5F,$5A,$50,$41
	dc.b $32,$23,$14,$0A,$05,$05,$0A,$14,$1E,$28,$37,$3C,$46,$46,$46,$41
	dc.b $3C,$32,$2D,$23,$1E,$1E,$1E,$1E,$1E,$23,$23,$28,$28,$28,$28,$28
	dc.b $28,$28,$28,$2D,$2D,$32,$32,$37,$3C,$3C,$3C,$37,$32,$2D,$23,$1E
	dc.b $19,$14,$14,$14,$1E,$28,$32,$3C,$4B,$55,$5A,$5A,$50,$46,$3C,$2D
	dc.b $19,$0F,$05,$00,$00,$05,$14,$23,$37,$4B,$5A,$64,$69,$64,$5A,$4B
	dc.b $37,$1E,$0A,$F6,$EC,$E7,$EC,$F6,$0F,$23,$41,$5A,$69,$78,$7D,$73
	dc.b $64,$4B,$32,$14,$FB,$E7,$D8,$D8,$E2,$F1,$0A,$28,$4B,$64,$78,$1A
	dc.b $1B,$7D,$69,$50,$2D,$0F,$F1,$D8,$CE,$CE,$D8,$EC,$0A,$2D,$4B,$69
	dc.b $1A,$1B,$1B,$7D,$64,$46,$28,$0A,$EC,$DD,$D3,$D3,$E2,$FB,$19,$37
	dc.b $55,$6E,$1A,$1B,$1B,$78,$5F,$41,$23,$05,$F1,$E2,$DD,$E2,$F1,$05
	dc.b $23,$3C,$5A,$6E,$78,$78,$73,$64,$50,$37,$1E,$05,$F1,$E7,$E7,$EC
	dc.b $FB,$0F,$28,$3C,$55,$64,$69,$69,$5F,$55,$41,$2D,$19,$0A,$00,$FB
	dc.b $FB,$05,$0F,$1E,$2D,$3C,$46,$50,$55,$50,$4B,$41,$37,$28,$1E,$19
	dc.b $14,$0F,$14,$14,$19,$23,$28,$2D,$32,$37,$37,$37,$32,$32,$2D,$2D
	dc.b $2D,$2D,$32,$32,$32,$32,$32,$32,$2D,$28,$23,$23,$1E,$1E,$23,$28
	dc.b $2D,$37,$3C,$46,$4B,$4B,$4B,$46,$41,$37,$2D,$1E,$14,$0F,$0A,$0A
	dc.b $14,$19,$28,$37,$46,$55,$5A,$5A,$55,$4B,$3C,$2D,$19,$05,$FB,$F1
	dc.b $F1,$F6,$05,$14,$2D,$41,$55,$64,$6E,$6E,$69,$5A,$41,$28,$0F,$F6
	dc.b $E7,$DD,$DD,$E7,$FB,$14,$32,$50,$69,$7D,$1A,$1A,$73,$5F,$46,$28
	dc.b $05,$EC,$D8,$D3,$D3,$E2,$F6,$14,$32,$55,$73,$1A,$1B,$1B,$78,$5F
	dc.b $41,$1E,$00,$E7,$D8,$D3,$D8,$E7,$00,$1E,$41,$5F,$78,$1B,$1C,$1B
	dc.b $73,$5A,$3C,$1E,$00,$EC,$DD,$D8,$E2,$F1,$0A,$28,$46,$5F,$73,$7D
	dc.b $7D,$73,$64,$4B,$2D,$14,$FB,$E7,$DD,$DD,$E7,$FB,$14,$2D,$46,$5F
	dc.b $6E,$73,$73,$69,$55,$41,$28,$14,$00,$F6,$EC,$F1,$FB,$0A,$1E,$32
	dc.b $46,$55,$5F,$64,$5F,$55,$46,$37,$28,$19,$0A,$05,$05,$05,$0F,$14
	dc.b $23,$2D,$37,$3C,$41,$46,$41,$3C,$37,$32,$28,$23,$23,$1E,$23,$23
	dc.b $28,$28,$2D,$32,$32,$32,$32,$2D,$2D,$2D,$2D,$32,$37,$37,$3C,$41
	dc.b $41,$41,$3C,$37,$32,$28,$1E,$19,$14,$14,$14,$19,$1E,$28,$37,$41
	dc.b $4B,$50,$55,$50,$46,$3C,$2D,$1E,$0F,$00,$FB,$FB,$00,$0A,$19,$2D
	dc.b $41,$50,$5F,$64,$69,$5F,$50,$41,$28,$14,$00,$F1,$EC,$EC,$F6,$05
	dc.b $1E,$37,$50,$64,$6E,$78,$73,$64,$50,$37,$19,$00,$E7,$D8,$D8,$DD
	dc.b $EC,$00,$1E,$41,$5F,$73,$1A,$1B,$7D,$6E,$55,$37,$19,$FB,$E7,$D8
	dc.b $D8,$DD,$F1,$0A,$2D,$4B,$69,$1A,$1C,$1C,$1B,$73,$55,$32,$0F,$F1
	dc.b $DD,$D3,$D3,$DD,$F1,$0F,$2D,$4B,$64,$78,$1A,$1A,$73,$5F,$46,$28
	dc.b $0A,$F1,$DD,$D8,$D8,$E7,$FB,$14,$32,$50,$64,$78,$7D,$78,$6E,$5A
	dc.b $41,$28,$0F,$FB,$EC,$E7,$EC,$F6,$0A,$1E,$37,$4B,$5A,$64,$64,$5F
	dc.b $55,$46,$32,$1E,$0F,$00,$FB,$F6,$FB,$05,$14,$23,$37,$41,$4B,$50
	dc.b $55,$50,$46,$3C,$32,$28,$23,$1E,$19,$19,$1E,$28,$2D,$32,$37,$3C
	dc.b $41,$3C,$3C,$37,$37,$32,$2D,$2D,$2D,$2D,$2D,$2D,$32,$2D,$2D,$2D
	dc.b $28,$23,$1E,$1E,$19,$1E,$1E,$23,$2D,$37,$3C,$41,$46,$46,$46,$3C
	dc.b $32,$28,$1E,$14,$0A,$05,$0A,$0F,$19,$23,$32,$41,$50,$55,$5A,$5A
	dc.b $50,$46,$32,$1E,$0A,$FB,$F1,$EC,$EC,$FB,$0A,$1E,$37,$50,$5F,$69
	dc.b $6E,$69,$5F,$4B,$37,$1E,$0A,$F6,$E7,$E7,$EC,$FB,$0F,$2D,$46,$64
	dc.b $78,$1A,$1A,$7D,$69,$50,$32,$14,$F6,$E2,$D8,$D8,$E2,$F6,$0F,$2D
	dc.b $4B,$69,$7D,$1A,$1A,$78,$64,$46,$28,$0A,$EC,$D8,$D3,$D8,$E2,$F6
	dc.b $19,$37,$5A,$73,$1A,$1B,$1B,$78,$5F,$41,$23,$00,$E7,$D8,$D3,$D8
	dc.b $E7,$00,$19,$3C,$55,$6E,$78,$7D,$78,$64,$50,$37,$19,$00,$E7,$DD
	dc.b $DD,$E2,$F1,$05,$23,$3C,$55,$69,$73,$73,$6E,$5F,$4B,$32,$1E,$0A
	dc.b $FB,$F1,$F1,$FB,$05,$19,$2D,$41,$50,$5A,$5F,$5F,$5A,$50,$41,$2D
	dc.b $1E,$14,$0A,$05,$05,$0F,$19,$23,$32,$3C,$46,$4B,$4B,$4B,$46,$3C
	dc.b $37,$2D,$28,$23,$23,$23,$23,$28,$28,$28,$2D,$2D,$2D,$2D,$2D,$2D
	dc.b $2D,$2D,$2D,$32,$32,$37,$37,$37,$37,$37,$32,$28,$23,$19,$14,$0F
	dc.b $0F,$0F,$19,$1E,$28,$37,$41,$4B,$50,$50,$4B,$46,$3C,$2D,$1E,$0F
	dc.b $00,$FB,$FB,$FB,$0A,$19,$28,$3C,$50,$5F,$69,$69,$64,$55,$46,$2D
	dc.b $14,$00,$F1,$E7,$E7,$F1,$00,$19,$32,$4B,$64,$73,$7D,$7D,$73,$5F
	dc.b $46,$28,$0F,$F6,$E2,$DD,$DD,$E7,$FB,$19,$37,$55,$6E,$1A,$1C,$1B
	dc.b $78,$64,$41,$23,$05,$E7,$D8,$CE,$D3,$E7,$00,$1E,$41,$5F,$78,$1B
	dc.b $1C,$1B,$73,$5A,$3C,$19,$FB,$E2,$D3,$CE,$D3,$E7,$00,$1E,$41,$5F
	dc.b $73,$1A,$1A,$7D,$69,$50,$32,$14,$F6,$E2,$D8,$D8,$E2,$F1,$0A,$28
	dc.b $46,$5F,$73,$7D,$7D,$73,$64,$4B,$32,$14,$00,$F1,$E7,$E7,$F1,$05
	dc.b $19,$32,$46,$5A,$64,$69,$69,$5F,$50,$3C,$28,$19,$0A,$00,$FB,$00
	dc.b $0A,$14,$23,$32,$41,$4B,$50,$55,$50,$4B,$41,$32,$28,$1E,$19,$14
	dc.b $14,$19,$1E,$23,$28,$32,$37,$37,$37,$37,$32,$32,$2D,$2D,$28,$28
	dc.b $28,$28,$2D,$2D,$2D,$2D,$28,$28,$23,$23,$1E,$1E,$1E,$23,$28,$2D
	dc.b $37,$3C,$41,$46,$46,$46,$41,$37,$2D,$23,$14,$0F,$0A,$05,$0A,$14
	dc.b $1E,$2D,$41,$50,$5A,$5F,$5F,$55,$4B,$3C,$28,$19,$05,$FB,$F1,$F1
	dc.b $FB,$0A,$1E,$37,$50,$64,$6E,$73,$73,$69,$5A,$41,$28,$0A,$F6,$E7
	dc.b $E2,$E2,$F1,$05,$1E,$3C,$55,$6E,$7D,$7D,$78,$69,$55,$37,$19,$FB
	dc.b $E2,$D8,$D3,$D8,$E7,$00,$23,$41,$5F,$78,$1A,$1B,$7D,$69,$50,$32
	dc.b $0F,$F1,$DD,$D3,$D3,$D8,$EC,$0A,$28,$4B,$69,$78,$1B,$1B,$7D,$64
	dc.b $4B,$2D,$0A,$F1,$DD,$D3,$D3,$E2,$F6,$0F,$32,$50,$69,$78,$1A,$1A
	dc.b $73,$5F,$46,$28,$0F,$F6,$EC,$E2,$E7,$F6,$0A,$23,$3C,$55,$64,$73
	dc.b $73,$73,$64,$55,$3C,$23,$0F,$00,$F1,$F1,$F6,$00,$14,$28,$3C,$4B
	dc.b $5A,$5F,$5F,$5A,$50,$41,$32,$23,$14,$0A,$05,$0A,$0F,$14,$1E,$28
	dc.b $37,$3C,$41,$46,$46,$41,$3C,$32,$2D,$23,$1E,$1E,$1E,$1E,$1E,$23
	dc.b $28,$28,$28,$28,$28,$28,$28,$28,$28,$28,$2D,$32,$32,$37,$37,$37
	dc.b $37,$37,$32,$28,$23,$1E,$19,$14,$14,$19,$1E,$28,$37,$41,$4B,$50
	dc.b $55,$55,$50,$46,$37,$28,$14,$0A,$00,$FB,$FB,$05,$14,$28,$3C,$4B
	dc.b $5F,$69,$6E,$69,$5F,$50,$3C,$23,$0A,$FB,$F1,$EC,$EC,$FB,$0F,$28
	dc.b $41,$5A,$6E,$78,$7D,$73,$64,$4B,$32,$14,$F6,$E2,$D8,$D8,$DD,$F1
	dc.b $0A,$28,$46,$5F,$73,$7D,$1A,$78,$64,$46,$28,$0A,$F1,$DD,$CE,$CE
	dc.b $DD,$F1,$0F,$32,$50,$6E,$1A,$1B,$1B,$7D,$64,$46,$28,$05,$EC,$DD
	dc.b $D3,$D3,$E2,$FB,$19,$37,$55,$6E,$7D,$1A,$1A,$73,$5F,$41,$23,$0A
	dc.b $F1,$E2,$DD,$E7,$F1,$0A,$23,$41,$5A,$6E,$78,$78,$73,$64,$50,$37
	dc.b $1E,$05,$F6,$EC,$EC,$F1,$FB,$0F,$28,$3C,$50,$5F,$64,$64,$5A,$50
	dc.b $41,$2D,$19,$0A,$00,$00,$00,$0A,$14,$23,$32,$41,$4B,$50,$50,$50
	dc.b $46,$41,$32,$28,$1E,$19,$14,$14,$14,$19,$1E,$28,$2D,$32,$37,$37
	dc.b $37,$32,$2D,$28,$28,$28,$28,$28,$28,$2D,$2D,$32,$32,$32,$32,$2D
	dc.b $28,$28,$23,$23,$23,$28,$2D,$32,$3C,$41,$46,$46,$46,$41,$3C,$32
	dc.b $28,$1E,$14,$0A,$0A,$0A,$0F,$19,$28,$37,$46,$50,$5A,$5F,$5A,$50
	dc.b $41,$32,$1E,$0F,$00,$F6,$F6,$FB,$0A,$19,$2D,$46,$5A,$69,$6E,$6E
	dc.b $69,$55,$41,$28,$0F,$FB,$E7,$DD,$DD,$E7,$FB,$14,$2D,$4B,$64,$73
	dc.b $78,$73,$69,$55,$3C,$1E,$00,$E7,$DD,$D8,$DD,$EC,$00,$23,$41,$5F
	dc.b $78,$1B,$1C,$1B,$78,$5F,$3C,$1E,$FB,$E2,$D3,$D3,$D8,$E7,$05,$23
	dc.b $46,$64,$78,$1B,$1C,$1A,$6E,$55,$32,$14,$F6,$E2,$D8,$D3,$DD,$F1
	dc.b $0A,$2D,$4B,$69,$7D,$1B,$1B,$7D,$69,$50,$32,$14,$FB,$E7,$DD,$DD
	dc.b $E7,$FB,$14,$2D,$46,$5F,$6E,$73,$73,$69,$55,$41,$28,$0F,$FB,$F1
	dc.b $EC,$EC,$F6,$05,$19,$2D,$41,$50,$5A,$5F,$5A,$55,$46,$37,$28,$19
	dc.b $0F,$0A,$05,$0A,$14,$1E,$28,$32,$3C,$41,$46,$46,$41,$3C,$37,$2D
	dc.b $28,$23,$23,$1E,$23,$23,$28,$28,$2D,$2D,$32,$32,$32,$32,$2D,$2D
	dc.b $2D,$32,$32,$37,$3C,$41,$41,$41,$3C,$37,$32,$2D,$23,$1E,$19,$19
	dc.b $19,$1E,$28,$32,$3C,$46,$4B,$50,$50,$4B,$41,$37,$28,$19,$0A,$00
	dc.b $FB,$FB,$00,$0A,$1E,$2D,$41,$55,$5F,$64,$64,$5A,$4B,$37,$23,$0A
	dc.b $F6,$EC,$E7,$E7,$F6,$0A,$1E,$3C,$55,$69,$78,$7D,$78,$69,$55,$3C
	dc.b $1E,$00,$E7,$D8,$D3,$D8,$E7,$00,$1E,$41,$5F,$73,$1A,$1B,$7D,$6E
	dc.b $55,$37,$19,$FB,$E2,$D3,$D3,$D8,$EC,$05,$28,$46,$69,$7D,$1B,$1C
	dc.b $1A,$73,$55,$37,$19,$FB,$E7,$D8,$D8,$E2,$F6,$14,$32,$50,$69,$78
	dc.b $1A,$1A,$73,$5F,$46,$28,$0A,$F1,$E2,$D8,$DD,$E7,$FB,$14,$32,$4B
	dc.b $64,$6E,$73,$73,$64,$50,$3C,$1E,$0A,$F6,$EC,$E7,$EC,$FB,$0F,$23
	dc.b $3C,$50,$5F,$69,$69,$64,$55,$46,$32,$1E,$0F,$00,$FB,$F6,$FB,$05
	dc.b $14,$23,$32,$41,$4B,$50,$50,$4B,$41,$37,$2D,$23,$19,$14,$14,$14
	dc.b $1E,$23,$28,$32,$37,$3C,$41,$41,$3C,$3C,$37,$37,$37,$32,$32,$32
	dc.b $32,$37,$37,$37,$32,$32,$2D,$28,$23,$1E,$1E,$1E,$1E,$23,$28,$32
	dc.b $37,$3C,$41,$41,$41,$37,$32,$23,$19,$0F,$0A,$05,$05,$0F,$19,$23
	dc.b $37,$46,$55,$5A,$5F,$5F,$55,$46,$37,$23,$14,$05,$F6,$F1,$F6,$00
	dc.b $0F,$28,$3C,$50,$5F,$69,$6E,$64,$5A,$41,$2D,$0F,$FB,$E7,$DD,$DD
	dc.b $E2,$F6,$0F,$28,$46,$5F,$73,$1A,$1A,$78,$69,$50,$32,$14,$F6,$E2
	dc.b $DD,$DD,$E7,$FB,$19,$37,$55,$73,$1B,$1C,$1C,$7D,$69,$4B,$2D,$0A
	dc.b $EC,$D8,$D3,$D3,$E2,$F6,$14,$32,$55,$6E,$7D,$1A,$7D,$6E,$55,$3C
	dc.b $19,$FB,$E7,$D8,$D3,$D8,$E7,$00,$1E,$3C,$5A,$6E,$7D,$1A,$78,$69
	dc.b $55,$37,$19,$00,$EC,$E2,$E2,$E7,$F6,$0A,$28,$41,$5A,$69,$73,$73
	dc.b $69,$5A,$46,$32,$19,$05,$F6,$F1,$F1,$F6,$05,$14,$28,$3C,$50,$5A
	dc.b $5F,$5F,$55,$4B,$3C,$2D,$23,$14,$0F,$0A,$0A,$0F,$19,$23,$32,$3C
	dc.b $46,$46,$4B,$46,$41,$3C,$32,$2D,$28,$23,$23,$23,$23,$28,$28,$2D
	dc.b $2D,$2D,$2D,$2D,$2D,$2D,$2D,$2D,$2D,$2D,$32,$32,$37,$37,$37,$37
	dc.b $32,$2D,$23,$1E,$19,$14,$0F,$14,$19,$1E,$28,$37,$41,$4B,$50,$50
	dc.b $4B,$46,$37,$2D,$19,$0F,$00,$FB,$FB,$00,$0A,$19,$2D,$41,$55,$5F
	dc.b $69,$6E,$64,$5A,$46,$2D,$19,$05,$F1,$EC,$EC,$F1,$00,$19,$32,$4B
	dc.b $64,$73,$7D,$78,$6E,$5A,$46,$28,$0A,$F1,$E2,$D8,$DD,$E7,$FB,$19
	dc.b $37,$55,$6E,$1A,$1B,$1A,$78,$5F,$41,$23,$05,$E7,$D8,$D3,$D8,$E7
	dc.b $00,$23,$41,$64,$7D,$1B,$1C,$1A,$73,$5A,$3C,$19,$FB,$E2,$D3,$CE
	dc.b $D3,$E7,$00,$1E,$3C,$5A,$6E,$7D,$1A,$78,$64,$4B,$2D,$0F,$F1,$DD
	dc.b $D3,$D3,$E2,$F1,$0A,$28,$46,$5F,$6E,$78,$78,$6E,$5F,$46,$2D,$14
	dc.b $00,$F1,$EC,$EC,$F6,$05,$1E,$32,$4B,$5F,$69,$6E,$69,$5F,$50,$41
	dc.b $2D,$19,$0A,$05,$00,$05,$0F,$19,$28,$37,$41,$4B,$50,$50,$4B,$46
	dc.b $3C,$32,$23,$1E,$14,$14,$14,$19,$1E,$23,$2D,$32,$37,$3C,$3C,$37
	dc.b $37,$32,$2D,$2D,$28,$28,$2D,$2D,$2D,$2D,$2D,$2D,$2D,$28,$28,$23
	dc.b $1E,$1E,$1E,$23,$28,$2D,$37,$3C,$41,$46,$46,$46,$41,$37,$2D,$1E
	dc.b $14,$0A,$05,$00,$05,$0F,$1E,$2D,$3C,$4B,$55,$5F,$5A,$55,$4B,$3C
	dc.b $28,$14,$05,$FB,$F1,$F6,$FB,$0F,$1E,$37,$4B,$5F,$6E,$73,$6E,$64
	dc.b $55,$3C,$23,$0A,$F6,$E7,$E2,$E7,$F6,$0A,$28,$46,$5F,$73,$1A,$1A
	dc.b $7D,$6E,$55,$37,$19,$FB,$E7,$D8,$D3,$DD,$EC,$05,$23,$41,$5F,$78
	dc.b $1A,$1B,$7D,$69,$50,$2D,$0F,$F1,$D8,$CE,$CE,$D8,$F1,$0A,$2D,$4B
	dc.b $69,$78,$1B,$1B,$78,$64,$46,$28,$0A,$F1,$E2,$D8,$D8,$E7,$FB,$19
	dc.b $37,$55,$6E,$7D,$1A,$1A,$73,$5F,$41,$28,$0A,$F6,$E7,$E2,$E7,$F1
	dc.b $05,$1E,$37,$50,$64,$6E,$73,$6E,$64,$50,$37,$23,$0F,$00,$F6,$F1
	dc.b $F6,$00,$14,$28,$37,$4B,$5A,$5F,$5F,$5A,$50,$41,$32,$1E,$14,$0F
	dc.b $0A,$0A,$0F,$19,$23,$2D,$37,$41,$46,$46,$46,$41,$3C,$32,$2D,$23
	dc.b $1E,$1E,$1E,$1E,$23,$23,$28,$28,$2D,$2D,$2D,$28,$28,$28,$28,$28
	dc.b $28,$2D,$32,$37,$37,$37,$37,$32,$2D,$28,$23,$19,$14,$14,$14,$19
	dc.b $1E,$28,$37,$41,$4B,$55,$5A,$55,$50,$46,$37,$28,$19,$0F,$05,$00
	dc.b $05,$0A,$19,$2D,$41,$50,$5F,$69,$6E,$69,$5A,$4B,$37,$1E,$0A,$F6
	dc.b $EC,$E7,$EC,$FB,$0F,$28,$41,$5A,$69,$78,$78,$73,$5F,$4B,$2D,$0F
	dc.b $F6,$E2,$D8,$D8,$DD,$F1,$0A,$28,$46,$64,$78,$1A,$1A,$78,$64,$46
	dc.b $28,$0A,$EC,$DD,$D3,$D3,$E2,$F6,$14,$32,$55,$6E,$1A,$1B,$1B,$78
	dc.b $64,$46,$23,$05,$EC,$DD,$D3,$D8,$E7,$00,$1E,$3C,$5A,$73,$7D,$1B
	dc.b $7D,$6E,$5A,$3C,$1E,$00,$EC,$DD,$D8,$DD,$F1,$05,$23,$41,$5A,$6E
	dc.b $78,$7D,$73,$64,$50,$37,$1E,$05,$F6,$EC,$EC,$F6,$05,$19,$2D,$41
	dc.b $55,$64,$69,$69,$5F,$55,$41,$2D,$1E,$0A,$00,$FB,$00,$05,$14,$23
	dc.b $32,$41,$4B,$50,$55,$50,$46,$3C,$32,$28,$1E,$14,$0F,$0F,$0F,$14
	dc.b $1E,$23,$28,$2D,$32,$32,$32,$32,$2D,$2D,$28,$28,$28,$28,$28,$28
	dc.b $2D,$2D,$2D,$2D,$2D,$2D,$28,$23,$23,$23,$28,$28,$32,$37,$41,$46
	dc.b $4B,$4B,$4B,$46,$3C,$32,$28,$1E,$14,$0F,$0A,$0F,$14,$1E,$2D,$3C
	dc.b $4B,$55,$5A,$5F,$5A,$50,$41,$2D,$19,$05,$F6,$EC,$EC,$F6,$00,$14
	dc.b $2D,$41,$55,$69,$6E,$6E,$69,$5A,$41,$28,$0F,$FB,$EC,$E2,$E2,$EC
	dc.b $00,$19,$32,$50,$69,$78,$7D,$7D,$73,$5A,$41,$23,$05,$EC,$DD,$D3
	dc.b $D8,$E7,$00,$1E,$3C,$5A,$73,$1A,$1B,$1A,$6E,$5A,$3C,$19,$FB,$E2
	dc.b $D3,$D3,$D8,$E7,$05,$23,$41,$64,$78,$1A,$1B,$1A,$6E,$50,$32,$14
	dc.b $F6,$E2,$D8,$D3,$DD,$F1,$0F,$2D,$4B,$64,$78,$1A,$1A,$78,$64,$4B
	dc.b $32,$14,$FB,$EC,$E2,$E7,$F1,$00,$19,$32,$4B,$64,$6E,$73,$73,$69
	dc.b $55,$41,$28,$14,$00,$F6,$F1,$F1,$FB,$0A,$1E,$2D,$41,$50,$55,$5A
	dc.b $55,$4B,$41,$32,$23,$14,$0A,$05,$05,$0A,$0F,$19,$28,$32,$3C,$41
	dc.b $46,$41,$41,$3C,$37,$2D,$28,$23,$23,$23,$23,$28,$2D,$2D,$2D,$32
	dc.b $32,$32,$32,$32,$32,$32,$32,$32,$37,$37,$3C,$3C,$3C,$3C,$3C,$37
	dc.b $2D,$28,$1E,$19,$14,$14,$14,$1E,$23,$2D,$3C,$46,$4B,$50,$50,$4B
	dc.b $41,$32,$23,$14,$05,$FB,$F6,$FB,$00,$0A,$1E,$32,$46,$55,$5F,$69
	dc.b $69,$5F,$50,$3C,$23,$0A,$F6,$EC,$E7,$EC,$F6,$0A,$23,$3C,$55,$69
	dc.b $78,$7D,$78,$69,$55,$3C,$1E,$00,$EC,$DD,$DD,$E2,$F1,$0A,$23,$46
	dc.b $5F,$78,$1A,$1B,$7D,$69,$50,$32,$14,$F6,$DD,$D3,$D3,$DD,$F1,$0A
	dc.b $2D,$4B,$69,$7D,$1B,$1B,$7D,$69,$4B,$2D,$0A,$F1,$DD,$D3,$D3,$DD
	dc.b $F6,$14,$32,$55,$6E,$1A,$1C,$1B,$78,$64,$46,$28,$0A,$F1,$E2,$DD
	dc.b $DD,$EC,$00,$19,$37,$55,$69,$78,$7D,$78,$69,$55,$3C,$1E,$05,$F1
	dc.b $E7,$E2,$E7,$F1,$05,$1E,$37,$4B,$5A,$64,$64,$5F,$50,$41,$2D,$19
	dc.b $0A,$FB,$F6,$F6,$FB,$05,$14,$28,$37,$46,$50,$55,$55,$50,$46,$3C
	dc.b $32,$28,$1E,$19,$14,$19,$1E,$23,$2D,$32,$37,$3C,$41,$41,$41,$3C
	dc.b $3C,$37,$37,$32,$32,$32,$32,$32,$32,$32,$2D,$2D,$28,$23,$23,$23
	dc.b $1E,$23,$23,$28,$32,$37,$3C,$41,$41,$41,$3C,$37,$2D,$1E,$14,$0A
	dc.b $05,$00,$05,$0F,$19,$28,$37,$46,$55,$5A,$5F,$5A,$50,$41,$32,$1E
	dc.b $0F,$00,$F6,$F1,$F6,$00,$14,$2D,$41,$5A,$69,$73,$78,$73,$64,$4B
	dc.b $32,$19,$FB,$EC,$DD,$DD,$E2,$F6,$0F,$28,$46,$5F,$73,$7D,$7D,$73
	dc.b $5F,$46,$28,$0A,$EC,$DD,$D3,$D3,$DD,$F1,$0F,$32,$50,$6E,$1A,$1C
	dc.b $1B,$7D,$64,$46,$28,$05,$EC,$D8,$D3,$D8,$E2,$FB,$19,$3C,$5F,$78
	dc.b $1B,$1D,$1C,$7D,$64,$46,$23,$05,$EC,$DD,$D3,$D8,$E7,$00,$1E,$3C
	dc.b $5A,$6E,$7D,$1A,$78,$69,$50,$37,$19,$FB,$E7,$DD,$D8,$E2,$F1,$05
	dc.b $1E,$37,$50,$5F,$69,$69,$64,$55,$46,$2D,$19,$05,$F6,$F1,$F1,$FB
	dc.b $05,$19,$2D,$41,$50,$5A,$5F,$5F,$5A,$4B,$41,$32,$23,$19,$14,$0F
	dc.b $14,$19,$1E,$28,$32,$3C,$41,$46,$46,$46,$41,$3C,$32,$2D,$28,$23
	dc.b $23,$23,$28,$28,$28,$2D,$2D,$2D,$28,$28,$23,$23,$23,$28,$28,$2D
	dc.b $32,$37,$37,$3C,$3C,$37,$32,$2D,$23,$1E,$14,$0F,$0F,$0F,$14,$1E
	dc.b $28,$32,$41,$4B,$55,$55,$55,$50,$41,$32,$23,$14,$05,$FB,$FB,$00
	dc.b $0A,$19,$2D,$41,$50,$5F,$69,$69,$64,$5A,$46,$2D,$19,$05,$F1,$EC
	dc.b $E7,$EC,$00,$14,$2D,$46,$5F,$6E,$78,$78,$6E,$5A,$46,$28,$0F,$F6
	dc.b $E2,$DD,$E2,$EC,$00,$19,$37,$55,$6E,$7D,$1A,$1A,$73,$5F,$41,$23
	dc.b $05,$EC,$DD,$D8,$DD,$EC,$05,$23,$41,$5F,$78,$1A,$1B,$7D,$6E,$55
	dc.b $32,$14,$F6,$E2,$D8,$D3,$DD,$F1,$0A,$28,$41,$5F,$6E,$78,$7D,$6E
	dc.b $5F,$46,$28,$0A,$F1,$E2,$D8,$D8,$E7,$F6,$14,$2D,$4B,$64,$73,$78
	dc.b $73,$69,$55,$41,$28,$0F,$FB,$EC,$EC,$EC,$FB,$0A,$23,$3C,$50,$64
	dc.b $6E,$73,$6E,$5F,$50,$3C,$28,$14,$05,$00,$FB,$00,$0A,$19,$28,$3C
	dc.b $46,$50,$5A,$5A,$50,$46,$3C,$2D,$23,$19,$0F,$0F,$0F,$14,$19,$1E
	dc.b $28,$2D,$37,$37,$3C,$3C,$37,$37,$32,$2D,$2D,$28,$28,$28,$28,$2D
	dc.b $2D,$2D,$28,$28,$28,$23,$23,$23,$23,$28,$2D,$32,$37,$41,$41,$46
	dc.b $46,$41,$3C,$32,$28,$1E,$14,$0A,$05,$05,$0F,$14,$23,$32,$41,$50
	dc.b $55,$5A,$5A,$50,$46,$32,$23,$0F,$00,$F1,$EC,$F1,$FB,$0F,$23,$3C
	dc.b $55,$64,$73,$73,$73,$64,$50,$3C,$23,$05,$F1,$E7,$E2,$E7,$F6,$0A
	dc.b $23,$46,$5F,$78,$1B,$1B,$1A,$73,$5A,$3C,$1E,$00,$E7,$D8,$D3,$DD
	dc.b $EC,$0A,$28,$46,$64,$7D,$1B,$1B,$7D,$69,$50,$2D,$0A,$EC,$D3,$C9
	dc.b $C9,$D3,$E7,$05,$28,$4B,$64,$78,$1A,$1A,$73,$5F,$46,$28,$05,$EC
	dc.b $DD,$D3,$D3,$E2,$F6,$14,$32,$50,$69,$78,$1A,$7D,$6E,$5F,$46,$28
	dc.b $0F,$F6,$EC,$E7,$EC,$FB,$0A,$23,$3C,$55,$69,$73,$73,$6E,$64,$50
	dc.b $37,$23,$0F,$FB,$F1,$F1,$F6,$05,$14,$28,$3C,$4B,$55,$5A,$5A,$55
	dc.b $4B,$3C,$2D,$1E,$0F,$05,$05,$05,$0A,$14,$1E,$2D,$37,$41,$46,$46
	dc.b $41,$41,$37,$32,$28,$23,$23,$1E,$1E,$23,$23,$28,$2D,$32,$32,$32
	dc.b $32,$32,$32,$2D,$2D,$2D,$2D,$32,$32,$37,$37,$37,$37,$37,$32,$28
	dc.b $1E,$19,$14,$14,$14,$14,$1E,$28,$32,$3C,$46,$4B,$50,$4B,$46,$3C
	dc.b $32,$23,$14,$05,$00,$FB,$00,$0A,$19,$28,$3C,$50,$5F,$69,$6E,$69
	dc.b $5A,$46,$32,$1E,$05,$F6,$EC,$EC,$F1,$00,$14,$2D,$4B,$5F,$73,$7D
	dc.b $7D,$73,$64,$4B,$2D,$14,$F6,$E2,$D8,$D8,$E2,$F1,$0F,$2D,$4B,$69
	dc.b $78,$1A,$1A,$73,$5F,$41,$23,$05,$E7,$D3,$C9,$CE,$DD,$F1,$0F,$32
	dc.b $50,$6E,$7D,$1A,$1A,$73,$5F,$41,$23,$00,$E7,$D8,$D3,$D8,$E7,$00
	dc.b $23,$41,$5F,$78,$1B,$1C,$1B,$73,$5F,$41,$23,$05,$F1,$E2,$DD,$E7
	dc.b $F6,$0A,$28,$41,$5A,$6E,$78,$7D,$73,$64,$4B,$32,$19,$00,$F1,$E7
	dc.b $E7,$F1,$00,$14,$2D,$41,$50,$5F,$64,$64,$5A,$4B,$3C,$28,$19,$05
	dc.b $00,$FB,$FB,$05,$0F,$23,$32,$3C,$4B,$50,$50,$50,$46,$41,$32,$28
	dc.b $1E,$14,$14,$14,$19,$1E,$23,$28,$32,$37,$37,$37,$37,$37,$32,$2D
	dc.b $2D,$28,$28,$28,$28,$2D,$2D,$2D,$2D,$2D,$28,$23,$23,$1E,$1E,$1E
	dc.b $1E,$23,$28,$32,$37,$41,$46,$46,$46,$41,$3C,$2D,$23,$19,$0F,$0A
	dc.b $0A,$0F,$19,$23,$32,$46,$50,$5A,$5F,$5F,$5A,$50,$41,$32,$1E,$0F
	dc.b $00,$F6,$F6,$FB,$0A,$1E,$32,$4B,$5F,$69,$73,$73,$69,$55,$41,$28
	dc.b $0A,$F6,$E7,$DD,$DD,$EC,$FB,$14,$32,$4B,$64,$78,$7D,$78,$69,$55
	dc.b $37,$19,$FB,$E2,$D3,$CE,$D3,$E2,$FB,$19,$3C,$5A,$73,$1A,$1C,$1A
	dc.b $73,$5A,$3C,$19,$FB,$E2,$D3,$D3,$DD,$EC,$0A,$28,$4B,$69,$7D,$1C
	dc.b $1D,$1B,$73,$55,$37,$19,$FB,$E7,$D8,$D8,$E2,$F6,$0F,$2D,$4B,$64
	dc.b $73,$7D,$7D,$73,$5F,$46,$28,$0F,$F6,$E7,$DD,$DD,$E7,$FB,$14,$2D
	dc.b $46,$5A,$69,$6E,$6E,$64,$55,$3C,$28,$14,$00,$F1,$F1,$F6,$00,$0F
	dc.b $23,$37,$46,$55,$5F,$5F,$5A,$50,$46,$37,$28,$19,$0F,$0A,$05,$0A
	dc.b $14,$1E,$28,$32,$3C,$46,$46,$46,$41,$3C,$32,$2D,$23,$1E,$1E,$1E
	dc.b $1E,$23,$28,$28,$2D,$2D,$2D,$2D,$2D,$28,$28,$28,$2D,$2D,$32,$32
	dc.b $37,$37,$3C,$37,$37,$32,$2D,$28,$1E,$19,$19,$19,$19,$1E,$28,$32
	dc.b $3C,$46,$50,$55,$55,$50,$46,$3C,$2D,$19,$0F,$05,$00,$00,$05,$14
	dc.b $23,$37,$46,$55,$64,$69,$64,$5A,$4B,$37,$1E,$05,$F1,$E7,$E2,$E2
	dc.b $F1,$05,$1E,$37,$50,$64,$73,$78,$73,$64,$50,$32,$14,$FB,$E2,$D8
	dc.b $D8,$DD,$EC,$05,$23,$46,$64,$78,$1B,$1B,$1A,$6E,$55,$32,$14,$F6
	dc.b $E2,$D8,$D8,$E2,$F6,$14,$32,$55,$73,$1B,$1C,$1C,$1A,$69,$50,$2D
	dc.b $0F,$F1,$E2,$D3,$D8,$E2,$F6,$14,$32,$50,$69,$7D,$1B,$1A,$73,$5F
	dc.b $41,$23,$05,$EC,$DD,$D3,$D8,$E7,$FB,$19,$37,$50,$69,$73,$78,$73
	dc.b $64,$50,$3C,$1E,$0A,$F6,$EC,$E7,$EC,$F6,$0A,$23,$37,$50,$5F,$69
	dc.b $69,$64,$55,$46,$32,$1E,$0F,$00,$FB,$FB,$05,$0F,$1E,$2D,$3C,$46
	dc.b $50,$50,$50,$4B,$41,$37,$28,$1E,$19,$14,$14,$14,$19,$23,$28,$2D
	dc.b $32,$37,$3C,$37,$37,$32,$32,$2D,$28,$2D,$2D,$2D,$2D,$32,$32,$32
	dc.b $32,$2D,$2D,$28,$23,$23,$23,$23,$28,$2D,$37,$3C,$41,$46,$46,$46
	dc.b $46,$3C,$37,$28,$1E,$14,$0A,$05,$0A,$0F,$19,$28,$37,$46,$50,$5A
	dc.b $5A,$55,$4B,$3C,$2D,$19,$05,$F6,$EC,$EC,$F1,$FB,$0F,$23,$3C,$50
	dc.b $5F,$69,$69,$64,$5A,$46,$2D,$14,$FB,$E7,$DD,$DD,$E7,$F6,$0F,$32
	dc.b $4B,$64,$7D,$1A,$1A,$78,$64,$4B,$2D,$0F,$F6,$E2,$D8,$DD,$E7,$FB
	dc.b $19,$37,$5A,$73,$1B,$1C,$1B,$7D,$64,$46,$28,$05,$EC,$D8,$D3,$D8
	dc.b $E7,$FB,$19,$3C,$5A,$73,$1A,$1B,$1A,$73,$5A,$3C,$19,$FB,$E2,$D3
	dc.b $CE,$D8,$E7,$00,$1E,$3C,$55,$6E,$78,$7D,$73,$64,$50,$32,$14,$00
	dc.b $EC,$E2,$E2,$E7,$FB,$0F,$28,$41,$5A,$69,$6E,$6E,$69,$5A,$46,$32
	dc.b $19,$0A,$FB,$F1,$F6,$FB,$0A,$19,$2D,$41,$50,$5A,$5F,$5A,$55,$46
	dc.b $37,$28,$19,$0F,$0A,$05,$0A,$0F,$19,$28,$32,$3C,$41,$46,$46,$41
	dc.b $3C,$37,$32,$28,$23,$23,$23,$23,$23,$28,$2D,$32,$32,$32,$32,$32
	dc.b $2D,$2D,$2D,$2D,$2D,$2D,$32,$37,$3C,$3C,$3C,$3C,$37,$32,$28,$23
	dc.b $1E,$19,$14,$14,$19,$23,$2D,$37,$41,$46,$4B,$50,$4B,$41,$37,$28
	dc.b $19,$0A,$00,$FB,$F6,$FB,$0A,$19,$28,$3C,$50,$5A,$64,$64,$5F,$50
	dc.b $3C,$28,$0F,$00,$F1,$EC,$EC,$F6,$05,$1E,$37,$50,$64,$73,$7D,$7D
	dc.b $6E,$5F,$46,$28,$0F,$F6,$E2,$DD,$E2,$EC,$05,$23,$41,$5F,$73,$1A
	dc.b $1B,$1A,$73,$5A,$3C,$19,$FB,$E2,$D3,$D3,$D8,$E7,$00,$1E,$41,$5F
	dc.b $78,$1A,$1A,$7D,$69,$50,$2D,$0F,$F1,$DD,$CE,$CE,$D8,$EC,$05,$28
	dc.b $46,$64,$78,$1A,$1A,$78,$64,$4B,$2D,$0F,$F6,$E2,$D8,$D8,$E7,$FB
	dc.b $14,$32,$50,$69,$78,$7D,$7D,$6E,$5F,$46,$28,$0F,$FB,$EC,$E7,$EC
	dc.b $F6,$0A,$1E,$37,$4B,$5A,$64,$69,$64,$5A,$4B,$37,$23,$14,$05,$FB
	dc.b $FB,$00,$0A,$14,$28,$37,$46,$50,$55,$55,$50,$46,$3C,$32,$28,$1E
	dc.b $19,$14,$14,$19,$23,$28,$2D,$37,$37,$3C,$3C,$3C,$37,$37,$32,$2D
	dc.b $2D,$2D,$2D,$2D,$2D,$32,$2D,$2D,$2D,$28,$23,$1E,$1E,$1E,$1E,$1E
	dc.b $23,$28,$32,$37,$3C,$41,$41,$3C,$37,$2D,$23,$19,$0F,$05,$00,$05
	dc.b $0A,$14,$1E,$2D,$3C,$4B,$55,$5A,$5A,$55,$46,$37,$28,$14,$05,$F6
	dc.b $F1,$F6,$00,$14,$28,$41,$5A,$69,$78,$78,$78,$69,$55,$41,$23,$0A
	dc.b $F6,$EC,$E7,$EC,$FB,$0F,$28,$46,$5F,$78,$1A,$1A,$7D,$6E,$55,$32
	dc.b $14,$F6,$DD,$D3,$CE,$D8,$EC,$05,$28,$46,$64,$78,$1A,$1A,$78,$64
	dc.b $4B,$28,$0A,$EC,$D8,$CE,$D3,$DD,$F1,$0A,$2D,$50,$69,$7D,$1B,$1A
	dc.b $78,$5F,$46,$28,$0A,$F1,$DD,$D8,$D8,$E7,$FB,$19,$37,$55,$6E,$78
	dc.b $1A,$7D,$6E,$5A,$41,$23,$0A,$F1,$E7,$E2,$E7,$F1,$05,$1E,$3C,$50
	dc.b $64,$6E,$6E,$69,$5F,$4B,$32,$1E,$0A,$FB,$F1,$F1,$F6,$05,$14,$28
	dc.b $3C,$4B,$5A,$5F,$5A,$55,$50,$41,$32,$23,$19,$0F,$0A,$0A,$14,$1E
	dc.b $28,$32,$3C,$46,$4B,$4B,$46,$41,$3C,$32,$2D,$28,$23,$23,$23,$23
	dc.b $28,$28,$2D,$2D,$2D,$2D,$2D,$28,$28,$28,$28,$28,$28,$2D,$32,$32
	dc.b $37,$37,$32,$32,$2D,$28,$1E,$19,$14,$0F,$0F,$14,$19,$28,$32,$3C
	dc.b $46,$50,$50,$50,$4B,$41,$32,$23,$14,$0A,$05,$00,$05,$0F,$1E,$2D
	dc.b $41,$50,$5F,$69,$6E,$69,$5A,$4B,$32,$1E,$05,$F6,$EC,$EC,$F1,$00
	dc.b $14,$2D,$4B,$5F,$73,$78,$78,$6E,$5F,$46,$28,$0F,$F1,$DD,$D8,$D8
	dc.b $E2,$F6,$0F,$2D,$4B,$69,$78,$1A,$1A,$73,$5F,$41,$23,$05,$E7,$D8
	dc.b $CE,$D3,$E2,$FB,$19,$37,$5A,$73,$1A,$1B,$1A,$73,$5A,$41,$1E,$00
	dc.b $E7,$D8,$D3,$D8,$E7,$00,$1E,$41,$5F,$73,$1A,$1B,$1A,$6E,$55,$37
	dc.b $19,$00,$E7,$DD,$D8,$E2,$F6,$0A,$28,$46,$5F,$73,$78,$78,$73,$5F
	dc.b $4B,$32,$19,$00,$F1,$E7,$E7,$F1,$00,$14,$2D,$46,$55,$64,$69,$69
	dc.b $5F,$50,$3C,$28,$19,$0A,$00,$FB,$00,$05,$14,$23,$32,$3C,$4B,$50
	dc.b $50,$50,$46,$3C,$32,$28,$1E,$14,$14,$0F,$14,$19,$23,$28,$2D,$32
	dc.b $37,$37,$37,$37,$32,$2D,$2D,$28,$28,$28,$2D,$2D,$2D,$2D,$2D,$2D
	dc.b $2D,$28,$23,$23,$23,$23,$23,$28,$2D,$37,$3C,$41,$46,$46,$46,$41
	dc.b $3C,$32,$28,$19,$14,$0A,$0A,$0F,$14,$23,$32,$41,$50,$5A,$5F,$5F
	dc.b $5A,$50,$41,$2D,$19,$0A,$FB,$F6,$F6,$FB,$0A,$19,$32,$46,$5A,$69
	dc.b $6E,$6E,$64,$55,$41,$23,$0A,$F6,$E7,$DD,$DD,$EC,$00,$19,$37,$50
	dc.b $69,$78,$7D,$78,$69,$55,$37,$19,$00,$E7,$D8,$D3,$D8,$E7,$00,$1E
	dc.b $3C,$5A,$73,$1A,$1B,$1A,$6E,$55,$37,$14,$F6,$DD,$D3,$D3,$D8,$EC
	dc.b $0A,$28,$46,$64,$78,$1B,$1B,$7D,$69,$50,$32,$14,$F6,$E7,$D8,$D8
	dc.b $E7,$FB,$14,$32,$50,$69,$78,$1A,$1A,$78,$64,$4B,$2D,$0F,$FB,$E7
	dc.b $E2,$E7,$F1,$05,$19,$32,$4B,$5F,$6E,$6E,$6E,$64,$50,$3C,$23,$0F
	dc.b $00,$F6,$F1,$F6,$00,$0F,$23,$37,$46,$55,$5A,$5A,$55,$4B,$41,$2D
	dc.b $1E,$14,$0A,$05,$05,$0A,$14,$1E,$28,$32,$3C,$41,$41,$41,$3C,$3C
	dc.b $32,$2D,$28,$23,$1E,$1E,$1E,$23,$28,$28,$2D,$2D,$2D,$2D,$2D,$2D
	dc.b $28,$28,$2D,$2D,$32,$37,$3C,$3C,$3C,$3C,$3C,$37,$2D,$28,$1E,$19
	dc.b $19,$19,$19,$1E,$28,$32,$3C,$46,$50,$55,$55,$50,$46,$3C,$28,$19
	dc.b $0A,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

.end
