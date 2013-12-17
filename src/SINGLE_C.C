/*************************************************************************

	SIMPLE_C.C

*/

#include <stdlib.h>
#include <tos.h>
#include <linea.h>
#include <string.h>
#include "projet.h"

extern int S1NCible;
extern int S1NShip;
extern int S1Level;
extern long S1Bonus;

void S1CalcPos( int xvit, int yvit, POSITION * );
int  S1SprScreen( int x, int y, SPRITE * );
void S1PtsDraw( long points );
int  S1GetDir( int xref, int yref, int xobj, int yobj );
void S1Collision( void );
void S1AstCreate( void );
void S1AstMove( void );
void S1AstDraw( void );
void S1AstClear( void );
void S1ShowSpare( int newnum );
void S1MisDraw( void );
void S1MisClear( void );
void S1MisMove( void );
void S1JrDraw( void );
void S1JrMove( void );
int  S1GetMove( void );
int  S1LookKeybd( void );
void S1JrReset( void );
int  S1WaitSafe( void );

void S1AlnCreate( void );
void S1AlnDraw( void );
void S1AlnClear( void );
void S1AlnMove( void );

/************************************************************************

	Initialiser boucle de jeu

*/

void S1Init()
{
	char str[16];
	char name[16];

	ScreenBox.g_x = ScreenBox.g_y = 0;
	ScreenBox.g_w = 320;
	ScreenBox.g_h = 192;

	/* initialiser ecrans */
	UnTiny(TnyRayoid);
	MemClear(_Screens[0],32000L);
	MemClear(_Screens[1],32000L);
	SwapReset();

	Alien.on = 0;
	Alien.mis.on = 0;
	Joueur[0].points = 0;
	S1Bonus = 2000;
	S1Level = 0;

	S1AstCreate();

	strcpy(str,"~8");
	strcpy(name,S1Stats.name);
	StrRight(name,8);
	strcat(str,name);
	_ShowStr(200,192,str,0);
	CopyZone(192,192,80,8);

	DrawNumber(272,192,S1Stats.score);

	S1ShowSpare(4);
}

/*************************************************************************

	Terminer, sauvegarder Hi-Score si il y a lieu

*/

void S1Term()
{
	char str[64];

	int choice;

	static char *_msg[] = {
	/*  0 */	"~8You beat the hi score !!!","~8Vous battez le record !!!",
	/*  2 */	"Your name : ........","Votre nom : ........",
	/*  4 */	"~7Your personnal message","~7Votre message personnel",
	/*  6 */	"................................","",
	/*  8 */	"~cGame Over","~cGame Over",
	/* 10 */	"~3Play again - ~4Y~3es ~4N~3o ?","~3Jouer … nouveau - ~4O~3ui ~4N~3on ?",
	/* 12 */	"yYnN","oOnN" };


	(*SplOff._proc)();

	SwapReset();

	if ( Joueur[0].points > S1Stats.score ) {

		S1Stats.score = Joueur[0].points;

		ShowStr(7,-1,_msg[0 + Langue],1);
		strcpy(str,_msg[2 + Langue]);
		GetStr(8,-1,str);
		if ( str[0] != 0 )
			strcpy(S1Stats.name,str);

		ShowStr(10,-1,_msg[4 + Langue],1);
		strcpy(str,_msg[6]);
		GetStr(11,-1,str);
		if ( str[0] != 0 )
			strcpy(S1Stats.msg,str);
		}

	if ( JouteStatus == 0 ) {
		ClrScreen();
		ShowStr(9,-1,_msg[8 + Langue],1);
		ShowStr(12,-1,_msg[10 + Langue],1);
		choice = GetChoice(_msg[12 + Langue]);
		if ( choice > 1 )
			JouteStatus = 1;
		}
}
