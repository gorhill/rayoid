/*************************************************************************

	Deux joueurs - Modem - Mode complexe

*/

#include <stdlib.h>
#include <tos.h>
#include <linea.h>
#include <string.h>
#include "projet.h"

extern int C2Winner;

static GRECT C2Box = { 16,4,256,172 };

void C2CalcPos( int xvit, int yvit, POSITION * );
int  C2SprScreen( int x, int y, SPRITE * );
void JrRadrDraw( void );
void BsRadrDraw( void );
void JrMapDraw( void );
void BsMapDraw( void );
void InvisDraw( void );
void C2BlackHole( int xpos, int ypos, int *_xyvit );

void C2EnerDraw( void );
void C2CryoDraw( void );

void C2BaseDraw( void );
void C2BaseClear( void );
void BaseCreate( void );
void BaseDo( void );

void C2StarCreate( STAR *, int xvit, int yvit );
void C2StarDraw( void );
void C2StarMove( void );
void C2StarClear( void );

int  C2GetMv1( void );

void C2JrReset( void );
void C2JrMove( JOUEUR *_joueur );
void C2JrDraw( JOUEUR *_joueur );
void C2JrClear( void );
void C2JrColl( JOUEUR *_predateur, JOUEUR *_proie );

void C2MisMove( JOUEUR *_joueur );
void C2MisDraw( JOUEUR *_joueur );
void C2MisClear( void );

void C2Fiche( int row, char color, C2STATS * );

/*************************************************************************

	Initialiser boucle de jeu

*/

void C2Init(mode)
	int mode;
{
	int ii;

	static char *_msg[] = {
	/* 0 */		"~cThe Opponants","~cLes forces en pr‚sence",
	/* 2 */		"~dHit RETURN to start","~dTapez RETURN pour commencer" };

	ScreenBox = C2Box;

	/* Initialiser ecrans */
	UnTiny(TnyPanel);
	MemCopy(_SavLogScreen,_Screens[0],32000L);
	MemCopy(_SavLogScreen,_Screens[1],32000L);
	UnTiny(TnyRayoid);
	SwapReset();

	if ( mode != 0 ) {
		ShowStr(2,-1,_msg[0 + Langue],0);
		C2Fiche(5,'4',&C2Stats);
		C2Fiche(12,'6',&DataExg.c2stats);
		ShowStr(20,-1,_msg[2 + Langue],0);
		ClrKeybd();
		while ( GetKeyAscii() != '\r' );
		}

	MdmPostX = 16;
	MdmPostY = 186;
	MdmPostLen = 32;

	C2JrReset();
	C2Winner = 0;

	/* creer une floppee d'etoiles, mobile en mode complexe */
	for ( ii = 0; ii < NStars; ii++ ) {
		Stars[ii].magnitude = ii & (NMAGNITUDE - 1);
		C2StarCreate( &Stars[ii], 0, 0 );
		Stars[ii]._scradr[0] = Stars[ii]._scradr[1] = 0;
		}

	/* creer une floppee d'asteroide */
	BaseCreate();
	Bases[1 - Maitre].mode = 4;
	Bases[Maitre].mode = 5;
	Bases[0].energie = Bases[1].energie = 12288;
	Joueur[0].xpos = Joueur[0].radrxpos = Bases[1 - Maitre].xpos + 16;
	Joueur[0].ypos = Joueur[0].radrypos = Bases[1 - Maitre].ypos + 16;
	Joueur[1].xpos = Joueur[1].radrxpos = Bases[Maitre].xpos + 16;
	Joueur[1].ypos = Joueur[1].radrypos = Bases[Maitre].ypos + 16;

	ClrScreen();
}

/*************************************************************************

	Terminer boucle de jeu

	mode 0 = demo
	mode 1 = vraie partie

*/

void C2Term(mode)
	int mode;
{
	char numstr[16];
	char str[40];

	int ii;
	int winner;

	long rsc[2];

	JOUEUR *_joueur = Joueur;

	static char *_msg[] = {
	/* 0 */		"~4You","~4Vous",
	/* 2 */		"~6The Other","~6L'Ennemi",
	/* 4 */		"~4Bases in built : ","~4Bases en d‚veloppement : ",
	/* 6 */		"~4Develloped Bases : ","~4Bases Developp‚es : ",
	/* 8 */		"~4Total ressources : ","~4Ressources totales : ",
	/* 10 */	"~4Pod : ","~4Navette : ",
	/* 12 */	"~cYou Win The War !","~cVous Gagnez la Guerre !",
	/* 14 */	"~cYou Lose The War !","~cVous Perdez la Guerre !",
	/* 16 */	"~dHit RETURN for another game","~dTapez RETURN pour recommencer" };


	(*SplOff._proc)();

	SwapReset();

	if ( JouteStatus != 0 )
		return;

	/* calculer ressources */
	rsc[0] = _joueur[0].energie + (_joueur[0].cryogen * 1024);
	rsc[1] = _joueur[1].energie + (_joueur[1].cryogen * 1024);
	for ( ii = 0; ii < NBASE; ii++ ) {
		if ( Bases[ii].mode < 2 )
			continue;
		if ( Bases[ii].mode & 1 )
			rsc[1] += Bases[ii].energie;
		else
			rsc[0] += Bases[ii].energie;
		}
	if ( rsc[0] < 0 )
		rsc[0] = 0;
	if ( rsc[1] < 0 )
		rsc[1] = 0;

	winner = C2Winner & 1;

	if ( mode != 0 ) {
		if ( winner == 0 ) {
			C2Stats.win++;
			DataExg.c2stats.lose++;
			}
		else {
			C2Stats.lose++;
			DataExg.c2stats.win++;
			}
		}

	ShowStr(3,-1,_msg[12 + (winner * 2) + Langue],1);

	ShowStr(5,-1,_msg[0 + Langue],1);
	ShowStr(12,-1,_msg[2 + Langue],1);

	for ( ii = 0; ii < 2; ii++, _joueur++ ) {

		strcpy(str,_msg[4 + Langue]);
		str[1] = (ii == 0) ? '4' : '6';
		MyLToA(numstr,(long)(_joueur->nbase - _joueur->nfullbase));
		strcat(str,numstr);
		ShowStr(7 * ii + 7,-1,str,1);

		strcpy(str,_msg[6 + Langue]);
		str[1] = (ii == 0) ? '4' : '6';
		MyLToA(numstr,(long)_joueur->nfullbase);
		strcat(str,numstr);
		ShowStr(7 * ii + 8,-1,str,1);

		strcpy(str,_msg[8 + Langue]);
		str[1] = (ii == 0) ? '4' : '6';
		MyLToA(numstr,rsc[ii]);
		strcat(str,numstr);
		ShowStr(7 * ii + 9,-1,str,1);

		strcpy(str,_msg[10 + Langue]);
		str[1] = (ii == 0) ? '4' : '6';
		MyLToA(numstr,_joueur->podcnt * 100 / _joueur->counter);
		strcat(str,numstr);
		strcat(str," %");
		ShowStr(7 * ii + 10,-1,str,1);
		}

	Delai(2000L);
	ShowStr(20,-1,_msg[16 + Langue],1);
	ClrKeybd();
	while ( GetKeyAscii() != '\r' );
}

/*************************************************************************

	Afficher la fiche d'un joueur

*/

void C2Fiche(row,color,_fiche)
	int row;
	char color;
	C2STATS *_fiche;
{
	char str1[32];
	char str2[32];

	int nimg;
	int x,y;
	int xsrc;
	int xlimit;
	int decaleur;
	int maskidx;
	int rank;

	static int mask[] = { 0x7FFF,511,63,7 };
	static char *_msg[] = {
	/* 0 */		"~4Record of ","~4Fiche de ",
	/* 2 */		" Victory, "," Victoire, ",
	/* 4 */		" Defeat"," D‚faite",
	/* 6 */		" Victories, "," Victoires, ",
	/* 8 */		" Defeats"," D‚faites" };


	UnTiny(TnyRayoid);

	strcpy(str1,_msg[0 + Langue]);
	str1[1] = color;
	strcat(str1,_fiche->name);
	ShowStr(row,4,str1,0);

	MyLToA(&str1[2],(long)_fiche->win);
	if ( _fiche->win > 1 )
		strcat(str1,_msg[6 + Langue]);
	else
		strcat(str1,_msg[2 + Langue]);
	MyLToA(str2,(long)_fiche->lose);
	if ( _fiche->lose > 1 )
		strcat(str2,_msg[8 + Langue]);
	else
		strcat(str2,_msg[4 + Langue]);
	strcat(str1,str2);
	ShowStr(row + 1,(ScreenBox.g_x >> 3) + 2,str1,0);

	rank = _fiche->win * 3 + _fiche->lose;
	x = ScreenBox.g_x + 16;
	y = (row + 2) * 8;
	xlimit = (ScreenBox.g_x + ScreenBox.g_w - 1) - 16;
	xsrc = 48;
	decaleur = 9;
	maskidx = 0;

	do {
		nimg = (rank & mask[maskidx]) >> decaleur;
		while ( nimg-- ) {
			CpyImage(xsrc,91,x,y,16,16);
			x += 16;
			if ( x > xlimit ) {
				x = ScreenBox.g_x + 16;
				y += 12;
				}
			}
		xsrc -= 16;
		decaleur -= 3;
		maskidx++;
	} while ( decaleur >= 0 );
}
