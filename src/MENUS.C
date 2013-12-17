/*************************************************************************

	MENUS.C
	Raymond Hill
	15 juin 1992
	Gestion des menus du jeu

*/

#include <stdlib.h>
#include <tos.h>
#include <string.h>
#include "projet.h"

extern int S2Mode;

int MoveScale;

static GRECT MenuBox = { 16,16,288,168 };

void S1Init( void );
void S1Play( void );
void S1Term( void );

void S2Init( void );
void S2TPlay( void );
void S2MPlay( void );
void S2Term( void );

void C2Init( int mode );
void C2Play( int mode );
void C2Term( int mode );
void C2Fiche( int row, char color, C2STATS * );

static void MenuInit( void );
static int  MenuDo( int *_curline, int maxline, int *_keycode );
static void MenuMsg( char *_msg );
static void OutOfMem( void );
static int  MenuModem( char *_title, int playmode );
static int  MenuMidi( char *_title, int playmode );

static void S1MnKeyCfg( void );
static void S1MnRoot( void );

static void S2TMnKeyCfg( void );
static void S2TMnRoot( void );
static void S2MMnKeyCfg( void );
static void S2MMnRoot( void );

static void C2MnKeyCfg( void );
static void C2MnRoot( void );

/*************************************************************************

	Preparer ecran menu

*/

static void MenuInit()
{
	ScreenBox = MenuBox;
	UnTiny(TnyMenu);
	MemCopy(_SavLogScreen,_Screens[0],32000L);
	SwapReset();
}

/*************************************************************************

	Gerer une page menu

*/

static int MenuDo(_curline,maxline,_keycode)
	int *_curline;
	int maxline;
	int *_keycode;
{
	for ( ;; ) {

		while ( (*_keycode = LookKeybd()) == 0 );

		switch ( *_keycode ) {

			/* menu precedent */
			case 0x61:
				return (-1);

			/* fleche basse */
			case 0x50:
				if ( maxline != 0 ) {
					(*_curline)++;
					if ( *_curline >= maxline )
						*_curline = 0;
					return (0);
					}
				break;

			/* fleche haute */
			case 0x48:
				if ( maxline != 0 ) {
					(*_curline)--;
					if ( *_curline < 0 )
						*_curline = maxline - 1;
					return (0);
					}
				break;

			/* activer choix */
			default:
				if ( maxline != 0 )
					return (1);
				break;
			}
		}
}

/*************************************************************************

	Memoire insuffisante

*/

static void OutOfMem()
{
	static char *_msg[] = {
		"~cSorry, not enough memory",
		"~cDÇsolÇ, mÇmoire insuffisante" };

	MenuMsg(_msg[Langue]);
	GetKeyAscii();
}

/*************************************************************************

	Message quelconque

*/

void MenuMsg(_str)
	char *_str;
{
	ClrScreen();
	ShowStr(-1,-1,_str,0);
}

/*************************************************************************

	Configurer clavier pour mode 1 joueur

*/

static void S1MnKeyCfg()
{
	char str[80];

	int ii;
	int action;
	int keycode;
	int redraw = -1;
	int oldline = -1;

	static int curline = 0;

	static char *_msg[] = {
	/* 0 */		"~cRAYOãD I","~cRAYOãD I",
	/* 2 */		"~cKeyboard configuration","~cPersonnaliser le clavier",
	/* 4 */		"~gRotate left : ","~gRotation gauche : ",
	/* 6 */		"~gRotate right : ","~gRotation droite : ",
	/* 8 */		"~gFire : ","~gTir : ",
	/* 10 */	"~gMotor : ","~gRÇacteur : ",
	/* 12 */	"~gBrake : ","~gFrein : ",
	/* 14 */	"~gHyperspace : ","~gHyperespace : ",
	/* 16 */	"~gPause : ","~gPause : " };


	for (;;) {

		/* afficher page ecran ? */
		if ( redraw != 0 ) {

			if ( redraw < 0 ) {
				ClrScreen();
				ShowStr(3,-1,_msg[0 + Langue],0);
				ShowStr(4,-1,_msg[2 + Langue],0);
				}

			for ( ii = 0; ii < 7; ii++ ) {
				if ( redraw > 0 && ii != curline && ii != oldline )
					continue;
				strcpy(str,_msg[ii * 2 + Langue + 4]);
				str[1] = (ii == curline) ? 'd' : 'g';
				StrRight(&str[2],20);
				GetKeyName(&str[strlen(str)],S1KeyCfg.action[ii]);
				strcat(str,"                ");
				str[2 + 34] = 0;
				ShowStr(ii + 6,3,str,0);
				}

			redraw = 0;
			}

		oldline = curline;

		action = MenuDo(&curline,7,&keycode);

		switch ( action ) {

			/* menu precedent */
			case -1:
				return;

			case 0:
				redraw = 1;
				break;

			case 1:
				S1KeyCfg.action[curline] = keycode;
				redraw = 1;
				break;
			}
		}
}

/*************************************************************************

	Menu racine du mode 1 joueur

*/

static void S1MnRoot()
{
	extern void S1VBL1( void );

	char *_str;

	char thebest[40];
	char score[12];

	int ii;
	int action;
	int keycode;
	int redraw = -1;
	int oldline = -1;
	int finished = 0;

	static int curline = 0;
	static int xsrcimg[] = { 192,208,224,192,208,224,240,256 };
	static int ysrcimg[] = { 16,16,16,0,0,0,0,0 };

	static char *_msg[] = {
	/* 0 */		"~cRAYOãD I","~cRAYOãD I",
	/* 2 */		"~cIf you are alone in the world","~cPour ceux qui n'ont pas d'ami",
	/* 4 */		"~gI want to play !","~gJe veux jouer !",
	/* 6 */		"~gCustomize keyboard","~gPersonnaliser le clavier",
	/* 8 */		"~45 points","~45 points",
	/* 10 */	"~410 points","~410 points",
	/* 12 */	"~420 points","~420 points",
	/* 14 */	"~4Fire Power 1","~4Fire Power 1",
	/* 16 */	"~4Fire Power 2","~4Fire Power 2",
	/* 18 */	"~4Zap","~4Zap",
	/* 20 */	"~41000 points","~41000 points",
	/* 22 */	"~4Auto Fire","~4Auto Fire",
	/* 24 */	"~cGet Ready","~cSoyez Pràt",
	/* 26 */	"~6The best is ~8","~6L'as est ~8",
	/* 28 */	"~6 with ~8","~6 avec ~8" };

	JeuMode = 0;

	AuxVBL._proc = S1VBL1;

	do {

		JouteStatus = 0;

		/* afficher page ecran ? */
		if ( redraw != 0 ) {

			if ( redraw < 0 ) {
				ClrScreen();
				ShowStr(3,-1,_msg[0 + Langue],0);
				ShowStr(4,-1,_msg[2 + Langue],0);
				UnTiny(TnyRayoid);
				for ( ii = 0; ii < 8; ii++ ) {
					CpyImage(xsrcimg[ii],ysrcimg[ii],32 + (ii / 4) * 128,76 + (ii & 3) * 16,16,16);
					ShowStr(10 + (ii & 3) * 2,7 + (ii / 4) * 16,_msg[ii * 2 + Langue + 8],0);
					}
				strcpy(thebest,_msg[26 + Langue]);
				strcat(thebest,S1Stats.name);
				strcat(thebest,_msg[28 + Langue]);
				MyLToA(score,S1Stats.score);
				strcat(thebest,score);
				ShowStr(20,-1,thebest,0);
				thebest[0] = '~';
				thebest[1] = '6';
				thebest[2] = 0;
				strcat(thebest,S1Stats.msg);
				ShowStr(21,-1,thebest,0);
				}

			for ( ii = 0; ii < 2; ii++ ) {
				if ( redraw > 0 && ii != curline && ii != oldline )
					continue;
				_str = _msg[ii * 2 + Langue + 4];
				_str[1] = (ii == curline) ? 'd' : 'g';
				ShowStr(ii + 6,-1,_str,0);
				}

			redraw = 0;
			}

		oldline = curline;

		action = MenuDo(&curline,2,&keycode);

		switch ( action ) {

			/* menu precedent */
			case -1:
				finished = 1;
				break;

			case 0:
				redraw = 1;
				break;

			/* activer choix */
			case 1:
				if ( keycode != 0x1C )
					break;
				switch ( curline ) {

					/* jouer */
					case 0:
						MenuMsg(_msg[24 + Langue]);
						if ( SingleSetUp() != 0 ) {
							SaveA6();
							do {
								S1Init();
								S1Play();
								S1Term();
							} while ( JouteStatus == 0 );
							RestA6();
							}
						else
							OutOfMem();
						SingleFree();
						MenuInit();
						break;

					/* personnaliser le clavier */
					case 1:
						S1MnKeyCfg();
						break;
					}
				redraw = -1;
				break;
			}

	} while ( !finished );

	AuxVBL._proc = NullProc;
	_NewPalette = ImgPalette;
}

/*************************************************************************

	Configurer clavier pour mode 2 joueur - simple - tete-a-tete

*/

static void S2TMnKeyCfg()
{
	char str[80];

	int ii;
	int action;
	int keycode;
	int redraw = -1;
	int oldline = -1;

	static int curline = 0;

	static char *_msg[] = {
	/* 0 */		"~cRAYOãD II head-to-head","~cRAYOãD II en tàte-Ö-tàte",
	/* 2 */		"~cKeyboard configuration","~cPersonnaliser le clavier",
	/* 4 */		"~4Player 1","~4Joueur 1",
	/* 6 */		"~gRotate left : ","~gRotation gauche : ",
	/* 8 */		"~gRotate right : ","~gRotation droite : ",
	/* 10 */	"~gFire : ","~gTir : ",
	/* 12 */	"~gMotor : ","~gRÇacteur : ",
	/* 14 */	"~gBrake : ","~gFrein : ",
	/* 16 */	"~gHyperspace : ","~gHyperespace : ",
	/* 18 */	"~6Player 2","~6Joueur 2",
	/* 20 */	"~gRotate left : ","~gRotation gauche : ",
	/* 22 */	"~gRotate right : ","~gRotation droite : ",
	/* 24 */	"~gFire : ","~gTir : ",
	/* 26 */	"~gMotor : ","~gRÇacteur : ",
	/* 28 */	"~gBrake : ","~gFrein : ",
	/* 30 */	"~gHyperspace : ","~gHyperespace : " };

	for (;;) {

		/* afficher page ecran ? */
		if ( redraw != 0 ) {

			if ( redraw < 0 ) {
				ClrScreen();
				ShowStr(3,-1,_msg[0 + Langue],0);
				ShowStr(4,-1,_msg[2 + Langue],0);
				ShowStr(6,-1,_msg[4 + Langue],0);
				ShowStr(14,-1,_msg[18 + Langue],0);
				}

			for ( ii = 0; ii < 6; ii++ ) {
				if ( redraw > 0 && ii != curline && ii != oldline )
					continue;
				strcpy(str,_msg[ii * 2 + Langue + 6]);
				str[1] = (ii == curline) ? 'd' : 'g';
				StrRight(&str[2],20);
				GetKeyName(&str[strlen(str)],S2TKey1Cfg.action[ii]);
				strcat(str,"                ");
				str[2 + 34] = 0;
				ShowStr(ii + 7,3,str,0);
				}

			for ( ii = 0; ii < 6; ii++ ) {
				if ( redraw > 0 && (ii+6) != curline && (ii+6) != oldline )
					continue;
				strcpy(str,_msg[ii * 2 + Langue + 20]);
				str[1] = ((ii+6) == curline) ? 'd' : 'g';
				StrRight(&str[2],20);
				GetKeyName(&str[strlen(str)],S2TKey2Cfg.action[ii]);
				strcat(str,"                ");
				str[2 + 34] = 0;
				ShowStr(ii + 15,3,str,0);
				}

			redraw = 0;
			}

		oldline = curline;

		action = MenuDo(&curline,12,&keycode);

		switch ( action ) {

			/* menu precedent */
			case -1:
				return;

			case 0:
				redraw = 1;
				break;

			case 1:
				if ( curline < 6 )
					S2TKey1Cfg.action[curline] = keycode;
				else
					S2TKey2Cfg.action[curline - 6] = keycode;
				redraw = 1;
				break;
			}
		}
}

/*************************************************************************

	Menu racine du mode 2 joueurs en tete-a-tete

*/

static void S2TMnRoot()
{
	char *_str;

	int ii;
	int action;
	int keycode;
	int redraw = -1;
	int oldline = -1;

	static int curline = 0;

	static char *_msg[] = {
	/* 0 */		"~cRAYOãD II","~cRAYOãD II",
	/* 2 */		"~cKill and blast someone","~cêcrabouillez autrui",
	/* 4 */		"~gStart the game","~gDÇbuter la partie",
	/* 6 */		"~gCustomize keyboard","~gPersonnaliser le clavier",
	/* 8 */		"~cGet Ready","~cSoyez Pràt" };

	JeuMode = 1;

	for (;;) {

		JouteStatus = 0;
		Joueur[0].points = Joueur[1].points = 0;

		/* afficher page ecran ? */
		if ( redraw != 0 ) {

			if ( redraw < 0 ) {
				ClrScreen();
				ShowStr(3,-1,_msg[0 + Langue],0);
				ShowStr(4,-1,_msg[2 + Langue],0);
				}

			for ( ii = 0; ii < 2; ii++ ) {
				if ( redraw > 0 && ii != curline && ii != oldline )
					continue;
				_str = _msg[ii * 2 + Langue + 4];
				_str[1] = (ii == curline) ? 'd' : 'g';
				ShowStr(ii + 6,-1,_str,0);
				}

			redraw = 0;
			}

		oldline = curline;

		action = MenuDo(&curline,2,&keycode);

		switch ( action ) {

			/* menu precedent */
			case -1:
				return;

			case 0:
				redraw = 1;
				break;

			/* activer choix */
			case 1:
				if ( keycode != 0x1C )
					break;

				switch ( curline ) {

					/* jouer */
					case 0:
						MenuMsg(_msg[8 + Langue]);
						if ( SimpleSetUp() != 0 ) {
							S2Mode = 0;
							do {
								S2Init();
								S2TPlay();
								S2Term();
							} while ( JouteStatus == 0 );
							MenuInit();
							}
						else
							OutOfMem();
						SimpleFree();
						break;

					/* configurer clavier */
					case 1:
						S2TMnKeyCfg();
						break;
					}

				redraw = -1;
				break;
			}
		}
}

/*************************************************************************

	Configurer clavier pour mode 2 joueurs - simple - modem

*/

static void S2MMnKeyCfg()
{
	char str[80];

	int ii;
	int action;
	int keycode;
	int redraw = -1;
	int oldline = -1;

	static int curline = 0;

	static char *_msg[] = {
	/* 0 */		"~cRAYOãD II by modem","~cRAYOãD II par modem",
	/* 2 */		"~cKeyboard configuration","~cPersonnaliser le clavier",
	/* 4 */		"~gRotate left : ","~gRotation gauche : ",
	/* 6 */		"~gRotate right : ","~gRotation droite : ",
	/* 8 */		"~gFire : ","~gTir : ",
	/* 10 */	"~gMotor : ","~gRÇacteur : ",
	/* 12 */	"~gBrake : ","~gFrein : ",
	/* 14 */	"~gHyperspace : ","~gHyperespace : " };


	for (;;) {

		/* afficher page ecran ? */
		if ( redraw != 0 ) {

			if ( redraw < 0 ) {
				ClrScreen();
				ShowStr(3,-1,_msg[0 + Langue],0);
				ShowStr(4,-1,_msg[2 + Langue],0);
				}

			for ( ii = 0; ii < 6; ii++ ) {
				if ( redraw > 0 && ii != curline && ii != oldline )
					continue;
				strcpy(str,_msg[ii * 2 + Langue + 4]);
				str[1] = (ii == curline) ? 'd' : 'g';
				StrRight(&str[2],20);
				GetKeyName(&str[strlen(str)],S2MKey1Cfg.action[ii]);
				strcat(str,"                ");
				str[2 + 34] = 0;
				ShowStr(ii + 6,3,str,0);
				}

			redraw = 0;
			}

		oldline = curline;

		action = MenuDo(&curline,6,&keycode);

		switch ( action ) {

			/* menu precedent */
			case -1:
				return;

			case 0:
				redraw = 1;
				break;

			case 1:
				S2MKey1Cfg.action[curline] = keycode;
				redraw = 1;
				break;
			}
		}
}

/*************************************************************************

	Menu racine du mode 2 joueurs via modem

*/

static void S2MMnRoot()
{
	char *_str;

	int ii;
	int action;
	int keycode;
	int redraw = -1;
	int oldline = -1;

	static int curline = 0;

	static int msgrow[] = { 6,7,9 };
	static char *_msg[] = {
	/* 0 */		"~cRAYOãD II","~cRAYOãD II",
	/* 2 */		"~cKill and blast someone","~cêcrabouillez autrui",
	/* 4 */		"~gPlay by modem","~gJouer via modem",
	/* 6 */		"~gPlay by MIDI","~gJouer via MIDI",
	/* 8 */		"~gCustomize keyboard","~gPersonnaliser le clavier",
	/* 10 */	"~cGet Ready","~cSoyez Pràt" };

	JeuMode = 2;

	for (;;) {

		JouteStatus = 0;
		Joueur[0].points = Joueur[1].points = 0;

		/* afficher page ecran ? */
		if ( redraw != 0 ) {

			if ( redraw < 0 ) {
				ClrScreen();
				ShowStr(3,-1,_msg[0 + Langue],0);
				ShowStr(4,-1,_msg[2 + Langue],0);
				}

			for ( ii = 0; ii < 3; ii++ ) {
				if ( redraw > 0 && ii != curline && ii != oldline )
					continue;
				_str = _msg[ii * 2 + Langue + 4];
				_str[1] = (ii == curline) ? 'd' : 'g';
				ShowStr(msgrow[ii],-1,_str,0);
				}

			redraw = 0;
			}

		oldline = curline;

		action = MenuDo(&curline,3,&keycode);

		switch ( action ) {

			/* menu precedent */
			case -1:
				return;

			case 0:
				redraw = 1;
				break;

			/* activer choix */
			case 1:
				if ( keycode != 0x1C )
					break;

				switch ( curline ) {

					/* jouer par modem */
					case 0:
						MenuMsg(_msg[10 + Langue]);
						if ( SimpleSetUp() != 0 ) {
							MdmSetMode(0);
							if ( MenuModem(_msg[Langue],SETSIMPLE) > 0 ) {
								S2Mode = 0;
								do {
									S2Init();
									S2MPlay();
									S2Term();
								} while ( JouteStatus == 0 );
								(*MdmReset._proc)();
								MenuInit();
								}
							}
						else
							OutOfMem();
						SimpleFree();
						break;

					/* jouer par midi */
					case 1:
						MenuMsg(_msg[10 + Langue]);
						if ( SimpleSetUp() != 0 ) {
							MdmSetMode(1);
							if ( MenuMidi(_msg[Langue],SETSIMPLE) > 0 ) {
								S2Mode = 0;
								do {
									S2Init();
									S2MPlay();
									S2Term();
								} while ( JouteStatus == 0 );
								(*MdmReset._proc)();
								MenuInit();
								}
							}
						else
							OutOfMem();
						SimpleFree();
						break;

					/* configurer le clavier */
					case 2:
						S2MMnKeyCfg();
						break;
					}
				redraw = -1;
				break;
			}
		}
}

/*************************************************************************

	Configurer clavier pour mode 1 joueur

*/

static void C2MnKeyCfg()
{
	char str[80];

	int ii;
	int action;
	int keycode;
	int redraw = -1;
	int oldline = -1;

	static int curline = 0;

	static char *_msg[] = {
	/* 0 */		"~cRAYOãD III","~cRAYOãD III",
	/* 2 */		"~cKeyboard configuration","~cPersonnaliser le clavier",
	/* 4 */		"~gRotate left : ","~gRotation gauche : ",
	/* 6 */		"~gRotate right : ","~gRotation droite : ",
	/* 8 */		"~gFire : ","~gTir : ",
	/* 10 */	"~gMotor : ","~gRÇacteur : ",
	/* 12 */	"~gBrake : ","~gFrein : ",
	/* 14 */	"~gHyperspace : ","~gHyperespace : ",
	/* 16 */	"~gInvisibility : ","~gInvisibilitÇ : ",
	/* 18 */	"~gGet cryogen : ","~gRecruter colons : ",
	/* 20 */	"~gDump cryogen : ","~gColoniser : ",
	/* 22 */	"~gMark position : ","~gMarquer position : ",
	/* 24 */	"~gSend message : ","~gTransmettre message : ",
	/* 26 */ 	"~gRefill : ","~gFaire le plein : ",
	/* 28 */	"~gSurrender : ","~gReddition : ",
	/* 30 */	"~gStealthy mine : ","~gMine furtive : " };

	for (;;) {

		/* afficher page ecran ? */
		if ( redraw != 0 ) {

			if ( redraw < 0 ) {
				ClrScreen();
				ShowStr(3,-1,_msg[0 + Langue],0);
				ShowStr(4,-1,_msg[2 + Langue],0);
				}

			for ( ii = 0; ii < 14; ii++ ) {
				if ( redraw > 0 && ii != curline && ii != oldline )
					continue;
				strcpy(str,_msg[ii * 2 + Langue + 4]);
				str[1] = (ii == curline) ? 'd' : 'g';
				StrRight(&str[2],22);
				GetKeyName(&str[strlen(str)],C2KeyCfg.action[ii]);
				strcat(str,"                ");
				str[2 + 34] = 0;
				ShowStr(ii + 6,3,str,0);
				}

			redraw = 0;
			}

		oldline = curline;

		action = MenuDo(&curline,14,&keycode);

		switch ( action ) {

			/* menu precedent */
			case -1:
				return;

			case 0:
				redraw = 1;
				break;

			case 1:
				C2KeyCfg.action[curline] = keycode;
				redraw = 1;
				break;
			}
		}
}

/*************************************************************************

	Menu de sequence de liaison par modem

*/

static int MenuModem(_title,playmode)
	char *_title;
	int playmode;
{
	char checksum;
	char str[64];
	char msg[64];

	int choix;

	long timeout;

	static char *_msg[] = {
	/* 0 */		"","",
	/* 2 */		"~cPlay by modem","~cJouer via modem",
	/* 4 */		"Turn on your modem and hit a key","Allumez votre modem et tapez une clÇ",
	/* 6 */		"~c1~g200| OR ~c2~g400| BAUDS ?","~c1~g200| OU ~c2~g400| bauds ?",
	/* 8 */		"~cM~gASTER| OR ~cS~gLAVE| ?","~cM~gAITRE| OU ~cE~gSCLAVE| ?",
	/* 10 */	"mMsS","mMeE",
	/* 12 */	"Phone number : ................","TÇlÇphone : ................",
	/* 14 */	"Trying to make the connection","J'essaie d'Çtablir la communication",
	/* 16 */	"Waiting the call of the opponent","J'attend l'appel de l'adversaire",
	/* 18 */	"Connection successful","Communication Çtablie" };


	ClrScreen();
	ShowStr(3,-1,_title,0);
	ShowStr(4,-1,_msg[2 + Langue],0);

	ShowStr(6,-1,_msg[4 + Langue],0);
	GetKeyAscii();

	/* vitesse du modem */
	InitChoice(8,-1,_msg[6 + Langue]);
	choix = GetChoice("12");
	MarkChoice(8,-1,_msg[6 + Langue],choix);
	MoveScale = (choix == 0) ? 3 : 1;
	(*MdmConf._proc)(choix);
	Delai(100L);
	(*MdmWrStr._proc)("ATE\r");

	/* maitre ou esclave */
	InitChoice(10,-1,_msg[8 + Langue]);
	choix = GetChoice(_msg[10 + Langue]);
	choix >>= 1;
	MarkChoice(10,-1,_msg[8 + Langue],choix);

	/* maitre... */
	if ( choix == 0 ) {
		Maitre = 1;
		strcpy(str,_msg[12 + Langue]);
		GetStr(12,-1,str);
		strcpy(msg,_msg[14 + Langue]);
		ShowStr(14,-1,msg,0);
		(*MdmWrStr._proc)("ATD ");
		(*MdmWrStr._proc)(str);
		(*MdmWrStr._proc)("\r");
		}
	/* ... ou esclave */
	else {
		Maitre = 0;
		strcpy(msg,_msg[16 + Langue]);
		ShowStr(14,-1,msg,0);
		(*MdmWrStr._proc)("ATS0=1\r");
		}

	/* attendre que la communication s'etablisse (DCD a 1) */
	timeout = *_Hz200;
	do {
		if ( Maitre && (*_Hz200 - timeout) > 12000L )
			break;
		if ( LookKeybd() == 0x61 )
			break;
	} while ( !(*MdmConnect._proc)() );

	if ( (*MdmConnect._proc)() == 0 )
		return (0);

	ShowStr(16,-1,_msg[18 + Langue],0);

	Delai(250L);
	(*MdmRdClr._proc)();
	Delai(250L);

	/* echanger les donnees */
	DataExg.seed = (int)*_Hz200 & 0x7FFF;
	DataExg.s1stats = S1Stats;
	DataExg.c2stats = C2Stats;

	if ( Maitre != 0 )
		InitRand(DataExg.seed);

	(*MdmWrByte._proc)(playmode);
	checksum = (*MdmWrBloc._proc)((char *)&DataExg,(int)sizeof(DATAEXG));
	(*MdmWrByte._proc)(checksum);

	Acknowledge = 0;
	do {
		if ( RecvModem() != 0 )
			break;
	} while ( Acknowledge == 0 );

	return ( Acknowledge );
}

/*************************************************************************

	Menu de sequence de liaison par midi

*/

static int MenuMidi(_title,playmode)
	char *_title;
	int playmode;
{
	char checksum;

	int choix;

	static char *_msg[] = {
	/* 0 */		"~cPlay by MIDI","~cJouer via MIDI",
	/* 2 */		"~4To play by MIDI...","~4Pour jouer via MIDI...",
	/* 4 */		"Connect your computer ~4MIDI IN|","Brancher le ~4MIDI IN| de votre",
	/* 6 */		"with the ~6MIDI OUT| of the","ordinateur au ~6MIDI OUT",
	/* 8 */		"opponant's computer.","de l'ordinateur adverse.",
	/* 10 */	"Connect ~6MIDI IN| of the opponant's","brancher le ~6MIDI IN| de",
	/* 12 */	"computer to the ~4MIDI OUT| of","l'ordinateur adverse au ~4MIDI OUT",
	/* 14 */	" your computer.","de votre ordinateur.",
	/* 16 */	"Hit a key when done...","Pressez une clÇ lorsque fait...",

	/* 18 */	"~cM~gASTER| or ~cS~gLAVE| ?","~cM~gAITRE| ou ~cE~gSCLAVE| ?",
	/* 20 */	"mMsS","mMeE",

	/* 22 */	"Trying to make the connection","J'essaie d'Çtablir la communication",
	/* 24 */	"Connection successfull","communication Çtablie" };


	MoveScale = 0;

	ClrScreen();
	ShowStr(3,-1,_title,0);
	ShowStr(4,-1,_msg[0 + Langue],0);

	ShowStr(6,-1,_msg[2 + Langue],0);

	ShowStr(8,-1,_msg[4 + Langue],0);
	ShowStr(9,-1,_msg[6 + Langue],0);
	ShowStr(10,-1,_msg[8 + Langue],0);
	ShowStr(12,-1,_msg[10 + Langue],0);
	ShowStr(13,-1,_msg[12 + Langue],0);
	ShowStr(14,-1,_msg[14 + Langue],0);

	ShowStr(16,-1,_msg[16 + Langue],0);
	GetKeyAscii();

	/* maitre ou esclave ? */
	InitChoice(18,-1,_msg[18 + Langue]);
	choix = GetChoice(_msg[20 + Langue]);
	Maitre = 1 - (choix >>= 1);
	MarkChoice(18,-1,_msg[18 + Langue],choix);

	ShowStr(20,-1,_msg[22 + Langue],0);

	Acknowledge = 0;
	do {
		if ( Maitre ) {
			(*MdmWrByte._proc)(MIDILINK);
			Delai(250L);
			}
		if ( RecvModem() != 0 )
			break;
	} while ( Acknowledge == 0 );

	Delai(250L);
	(*MdmRdClr._proc)();
	Delai(250L);


	/* echanger les donnees */
	DataExg.seed = (int)*_Hz200 & 0x7FFF;
	DataExg.s1stats = S1Stats;
	DataExg.c2stats = C2Stats;

	if ( Maitre != 0 )
		InitRand(DataExg.seed);

	(*MdmWrByte._proc)(playmode);
	checksum = (*MdmWrBloc._proc)((char *)&DataExg,(int)sizeof(DATAEXG));
	(*MdmWrByte._proc)(checksum);

	Acknowledge = 0;
	do {
		if ( RecvModem() != 0 )
			break;
	} while ( Acknowledge == 0 );

	return ( Acknowledge );
}

/*************************************************************************

	Menu racine du mode 2 joueurs par modem - complexe

*/

static void C2MnRoot()
{
	char *_str;
	char str[64];

	int ii;
	int action;
	int keycode;
	int redraw = -1;
	int oldline = -1;
	int choice;
	int result;

	static int curline = 2;
	static int msgrow[] = { 6,7,9,11,12 };
	static char *_msg[] = {
	/* 0 */		"~cRAYOãD III","~cRAYOãD III",
	/* 2 */		"~cAction and Strategy","~cAction et StratÇgie",
	/* 4 */		"~gPlay by modem","~gJouer via modem",
	/* 6 */		"~gPlay by MIDI","~gJouer via MIDI",
	/* 8 */		"~gHow it look ?","~gDe quoi \200a a l'air ?",
	/* 10 */	"~gCustomize keyboard","~gPersonnaliser le clavier",
	/* 12 */	"~gReset personnal record","~gInitialiser fiche personnelle",
	/* 14 */	"~cGet Ready","~cSoyez Pràt",
	/* 16 */	"~3Are you sure - ~4Y~3es ~4N~3o ?","~3Etes-vous certain - ~4O~3ui ~4N~3on ?",
	/* 18 */	"YyNn","OoNn",
	/* 20 */	"Your name : ............","Votre nom : ............" };


	JeuMode = 3;

	for (;;) {

		JouteStatus = 0;

		/* afficher page ecran ? */
		if ( redraw != 0 ) {

			if ( redraw < 0 ) {
				ClrScreen();
				ShowStr(3,-1,_msg[0 + Langue],0);
				ShowStr(4,-1,_msg[2 + Langue],0);
				C2Fiche(16,'4',&C2Stats);
				}

			for ( ii = 0; ii < 5; ii++ ) {
				if ( redraw > 0 && ii != curline && ii != oldline )
					continue;
				_str = _msg[ii * 2 + Langue + 4];
				_str[1] = (ii == curline) ? 'd' : 'g';
				ShowStr(msgrow[ii],-1,_str,0);
				}

			redraw = 0;
			}

		oldline = curline;

		action = MenuDo(&curline,5,&keycode);

		switch ( action ) {

			/* menu precedent */
			case -1:
				return;

			case 0:
				redraw = 1;
				break;

			/* activer choix */
			case 1:
				if ( keycode != 0x1C )
					break;
				switch ( curline ) {

					/* jouer par modem ou midi */
					case 0:
					case 1:
						if ( ComplexSetUp() != 0 ) {
							MdmSetMode(curline);
							result = (curline == 0) ? MenuModem(_msg[Langue],SETCOMPLEX) : MenuMidi(_msg[Langue],SETCOMPLEX);
							if ( result > 0 ) {
								do {
									C2Init(1);
									C2Play(1);
									C2Term(1);
								} while ( JouteStatus == 0 );
								(*MdmReset._proc)();
								MenuInit();
								}
							}
						else
							OutOfMem();
						ComplexFree();
						break;

					/* demonstration */
					case 2:
						MenuMsg(_msg[14 + Langue]);
						if ( ComplexSetUp() != 0 ) {
							MoveScale = 0;
							do {
								C2Init(0);
								C2Play(0);
								C2Term(0);
							} while ( JouteStatus == 0 );
							MenuInit();
							}
						else
							OutOfMem();
						ComplexFree();
						break;

					/* configurer clavier */
					case 3:
						C2MnKeyCfg();
						break;

					/* initialiser fiche personnelle */
					case 4:
						ClrScreen();
						strcpy(str,_msg[12 + Langue]);
						str[1] = 'c';
						ShowStr(3,-1,str,0);
						ShowStr(6,-1,_msg[16 + Langue],0);
						choice = GetChoice(_msg[18 + Langue]);
						if ( choice < 2 ) {
							C2Stats.win = C2Stats.lose = C2Stats.rank = 0;
							strcpy(str,_msg[20 + Langue]);
							GetStr(9,-1,str);
							if ( str[0] != 0 )
								strcpy(C2Stats.name,str);
							}
						break;
					}
				redraw = -1;
				break;
			}
		}
}

/*************************************************************************

	Gestion du menu racine

*/

void MnRoot()
{
	char *_str;

	int ii;
	int keycode;
	int action;
	int redraw = -1;
	int oldline = -1;
	int dummy;

	static int curline = 0;

	static int msgidx[] = { 8,10,11,12,13,15,16,18 };
	static char *_msg[] = {
	/* 0 */		"~cRAYOãD : 3 games in one","~cRAYOãD : 3 Jeux en un",
	/* 2 */		"~gAbout RAYOãD","~gÖ propos de RAYOãD",
	/* 4 */		"~gSingle player","~gUn joueur",
	/* 6 */		"~g2 players \5 Simple \5 Keyboard","~g2 joueurs \5 Simple \5 Clavier",
	/* 8 */		"~g2 players \5 Simple \5 Modem","~g2 joueurs \5 Simple \5 Modem",
	/* 10 */	"~g2 players \5 Complex \5 Modem","~g2 joueurs \5 Complexe \5 Modem",
	/* 12 */	"~gJe prÇfere le fran\200ais","~gI prefer english",
	/* 14 */	"~gScreen Frequency : ~g50 Hz~g  ~g60 Hz~g","~gBalayage Çcran : ~g50 Hz~g  ~g60 Hz~g",
	/* 16 */	"~gQuit","~gQuitter",
	/* 18 */	"~4Use \1, \2, Return and Undo","~4Utilisez \1, \2, Return et Undo",
	/* 20 */	"~4to walk through all menus","~4pour accÇder aux diffÇrents menus" };
	static int abtidx[] = { 3,4,6,7,9,10,13,14,15,16,17,18,19,20,21,22,23 };
	static char *_about[] = {
	/* 0 */		"~6Conception and Programmation","~6Conception et Programmation",
	/* 2 */		"~cRaymond Hill","~cRaymond Hill",
	/* 4 */		"~6Ideas and Suggestions","~6IdÇes et Suggestions",
	/* 6 */		"~cNicolas Michaud","~cNicolas Michaud",
	/* 8 */		"~6English translation of documentation","~6Traduction anglaise de la doc",
	/* 10 */	"~cHenri Tremblay","~cHenri Tremblay",

	/* 12 */	"~4It is absolutely forbidden to","~4Il est strictement interdit de",
	/* 14 */	"~4sell or modify in any way this","~4vendre ou de modifier de quelque",
	/* 16 */	"~4software without the express","~4fa\200on que ce soit ce logiciel sans",
	/* 18 */	"~4agreement of the author.","~4le consentement Çcrit de l'auteur.",
	/* 20 */	"~4The author give the permission","~4L'auteur donne la permission de",
	/* 22 */	"~4to copy and distribute freely","~4copier et distribuer gratuitement",
	/* 24 */	"~4and without any change RAYOID.LZH.","~4et intÇgralement RAYOID.LZH.",
	/* 26 */	"~4The author ~dforbids~4 the distribution","~4L'auteur ~dinterdit~4 la distribution de",
	/* 28 */	"~4of this software on disk.","~4ce logiciel sur disquette.",
	/* 30 */	"","" };

	MenuInit();

	for (;;) {

		/* afficher page ecran ? */
		if ( redraw != 0 ) {

			if ( redraw < 0 ) {
				ClrScreen();
				ShowStr(3,-1,_msg[0 + Langue],0);
				ShowStr(4,-1,CopyRight,0);
				ShowStr(6,-1,_Owner[Langue],0);
				ShowStr(21,-1,_msg[18 + Langue],0);
				ShowStr(22,-1,_msg[20 + Langue],0);
				}

			_MarkChoice(_msg[14] + 2,1 - SyncMode,'7');
			_MarkChoice(_msg[15] + 2,1 - SyncMode,'7');

			for ( ii = 0; ii < 8; ii++ ) {
				if ( redraw > 0 && ii != curline && ii != oldline )
					continue;
				_str = _msg[ii * 2 + Langue + 2];
				_str[1] = (ii == curline) ? 'd' : 'g';
				ShowStr(msgidx[ii],-1,_str,0);
				}

			redraw = 0;
			}

		oldline = curline;

		action = MenuDo(&curline,8,&keycode);

		switch ( action ) {

			case -1:
				curline = 7;

			case 0:
				redraw = 1;
				break;

			/* activer choix */
			case 1:
				if ( keycode != 0x1C )
					break;

				switch ( curline ) {

					/* a propos de rayoid */
					case 0:
						ClrScreen();
						for ( ii = 0; ; ii++ ) {
							_str = _about[ii * 2 + Langue];
							if ( _str[0] == 0 )
								break;
							ShowStr(abtidx[ii],-1,_str,0);
							}
						MenuDo(&dummy,0,&dummy);
						redraw = -1;
						break;

					/* un joueur */
					case 1:
						S1MnRoot();
						redraw = -1;
						break;

					/* deux joueurs - simple - tete-a-tete */
					case 2:
						S2TMnRoot();
						redraw = -1;
						break;

					/* deux joueurs - simple - modem-a-modem */
					case 3:
						S2MMnRoot();
						redraw = -1;
						break;

					/* deux joueurs - complexe - modem-a-modem */
					case 4:
						C2MnRoot();
						redraw = -1;
						break;

					/* changer de langue */
					case 5:
						Langue ^= 1;
						redraw = -1;
						break;

					/* basculer frequence ecran */
					case 6:
						ScreenSync();
						redraw = 1;
						break;

					/* quitter */
					case 7:
						return;
					}
				break;
			}
		}
}
