/*************************************************************************

	SIMPLE_C.C

*/

#include <stdlib.h>
#include <tos.h>
#include <linea.h>
#include <string.h>
#include "projet.h"

extern int S2Mode;
extern int S2NAst;

int S2TMv1( void );
int S2TMv2( void );
int S2MMv1( void );

void S2CalcPos( int xvit, int yvit, POSITION * );
void S2EnerDraw( int joueur, int energie );
void S2StarDraw( void );
int  S2SprScreen( int x, int y, SPRITE * );
int  S2GetDir( int xref, int yref, int xobj, int yobj );

void S2NovaCreate( void );
void S2NovaMove( void );
void S2NovaDraw( void );
void S2NovaClear( void );

void S2StarCreate( void );

void S2AstCreate( void );
void S2AstMove( void );
void S2AstDraw( void );
void S2AstClear( void );

void S2JrDraw( int joueur );
void S2JrMove( int joueur );

void S2MisMove( int joueur );
void S2MisDraw( int joueur );
void S2MisClear( void );

void S2Collision( void );

static void S2JrReset( int joueur );

/*************************************************************************

	Tete-a-tete - Initialiser les donnees d'un joueur

*/

static void S2JrReset(joueur)
	int joueur;
{
	int ii;

	JOUEUR *_joueur = &Joueur[joueur];

	_joueur->dir = 0;
	if ( JeuMode == 1 ) {
		_joueur->xpos = (joueur == 0) ? 20 : 299;
		_joueur->ypos = (joueur == 0) ? 20 : 179;
		}
	else {
		if ( joueur == 0 ) {
			_joueur->xpos = (Maitre == 1) ? 20 : 299;
			_joueur->ypos = (Maitre == 1) ? 20 : 179;
			}
		else {
			_joueur->xpos = (Maitre == 1) ? 299 : 20;
			_joueur->ypos = (Maitre == 1) ? 179 : 20;
			}
		}
	_joueur->xposfrac = _joueur->yposfrac = 0;
	_joueur->xvit = _joueur->yvit = 0;
	_joueur->xvitfrac = _joueur->yvitfrac = 0;
	_joueur->dommage = 31;
	_joueur->moteur = 0;
	_joueur->hit = 0;
	_joueur->energie = 8192;
	_joueur->hyper = 0;
	_joueur->counter = 0;
	_joueur->invisible = 0;
	_joueur->mistype = 0;
	_joueur->id = joueur;

	for ( ii = 0; ii < NMISSILE; ii++ )
		_joueur->missiles[ii].on = 0;
}

/*************************************************************************

	Mode Simple - Initialiser boucle de jeu

*/

void S2Init()
{
	char str[32];

	ScreenBox.g_x = ScreenBox.g_y = 0;
	ScreenBox.g_w = 320;
	ScreenBox.g_h = 192;

	MdmPostX = 64;
	MdmPostY = 192;
	MdmPostLen = 24;

	/* initialiser ecrans */
	UnTiny(TnyRayoid);
	MemClear(_Screens[0],32000L);
	MemClear(_Screens[1],32000L);
	SwapReset();

	S2NAst = S2Mode & 7;

	S2StarCreate();
	S2AstCreate();
	S2NovaCreate();

	S2JrReset(0);
	S2JrReset(1);

	str[0] = '~';

	CpyImage(128,60,0,192,32,7);
	str[1] = '4';
	MyLToA(&str[2],Joueur[0].points);
	_ShowStr(32,192,str,0);

	CpyImage(128,67,288,192,32,7);
	str[1] = '6';
	MyLToA(&str[2],Joueur[1].points);
	StrRight(&str[2],6);
	_ShowStr(240,192,str,0);

	MemCopy(_Screens[0],_Screens[1],32000L);
}

/*************************************************************************

	Mode Simple - Terminer boucle de jeu

*/

void S2Term()
{
	S2Mode++;

	(*SplOff._proc)();
}

/*************************************************************************

	Deux joueurs, mode simple, tete-a-tete

*/

void S2TPlay()
{
	int keycode;

	register JOUEUR *_joueur = Joueur;

	_joueur[0].move = _joueur[1].move = 0x80;

	do {
		_joueur[0].oldmove = _joueur[0].move;
		_joueur[1].oldmove = _joueur[1].move;

		_joueur[0].move = S2TMv1();
		_joueur[1].move = S2TMv2();

		keycode = LookKeybd();
		if ( keycode == 0x61 )
			JouteStatus = 1;
		else {
			if ( keycode == 0x52 )
				MdmPost(1);
			}

		S2NovaMove();

		S2AstMove();

		S2JrMove(1 - Maitre);
		S2JrMove(Maitre);

		S2MisMove(1 - Maitre);
		S2MisMove(Maitre);

		/* attendre que l'ecran soit bascule */
		SwapWait();

		if ( JouteStatus != 0 )
			break;

		S2AstClear();

		SpriteClear(_joueur[0].savship);
		SpriteClear(_joueur[0].savfire);
		SpriteClear(_joueur[1].savship);
		SpriteClear(_joueur[1].savfire);

		S2MisClear();
		S2NovaClear();

		S2StarDraw();

		S2EnerDraw(0,_joueur[0].energie);
		S2EnerDraw(1,_joueur[1].energie);

		S2JrDraw(1 - Maitre);
		S2JrDraw(Maitre);

		S2MisDraw(1 - Maitre);
		S2MisDraw(Maitre);

		S2AstDraw();

		S2NovaDraw();

		SwapScreen();

		S2Collision();

		_joueur[0].counter++;
		_joueur[1].counter++;

	} while ( _joueur[0].dommage != 0 && _joueur[1].dommage != 0 );

	if ( _joueur[0].dommage == 0 )
		_joueur[1].points++;
	if ( _joueur[1].dommage == 0 )
		_joueur[0].points++;
}

/*************************************************************************

	Deux joueurs, mode simple, modem

*/

void S2MPlay()
{
	int nxtmove;
	int keycode;

	long iteration = 0;

	register JOUEUR *_joueur = Joueur;


	if ( SyncStart() != 0 )
		return;

	_joueur[0].move = _joueur[1].move = nxtmove = 0x80;
	(*MdmWrByte._proc)((char)nxtmove);

	do {

		_joueur[0].oldmove = _joueur[0].move;
		_joueur[1].oldmove = _joueur[1].move;

		if ( (iteration & MoveScale) == 0 ) {
			_joueur[0].move = nxtmove;
			_joueur[1].move = 0;
			do {
				if ( RecvModem() != 0 )
					break;
			} while ( _joueur[1].move == 0 );
			nxtmove = S2MMv1();
			(*MdmWrByte._proc)((char)nxtmove);
			}

		keycode = LookKeybd();
		if ( keycode == 0x61 )
			JouteStatus = 1;
		else {
			if ( keycode == 0x52 )
				MdmPost(1);
			}

		S2NovaMove();

		S2AstMove();

		S2JrMove(1 - Maitre);
		S2JrMove(Maitre);

		S2MisMove(1 - Maitre);
		S2MisMove(Maitre);

		/* attendre que l'ecran soit bascule */
		SwapWait();

		if ( JouteStatus != 0 )
			break;

		S2AstClear();

		SpriteClear(_joueur[0].savship);
		SpriteClear(_joueur[0].savfire);
		SpriteClear(_joueur[1].savship);
		SpriteClear(_joueur[1].savfire);

		S2MisClear();
		S2NovaClear();

		S2StarDraw();

		S2EnerDraw(0,_joueur[0].energie);
		S2EnerDraw(1,_joueur[1].energie);

		S2JrDraw(1 - Maitre);
		S2JrDraw(Maitre);

		S2MisDraw(1 - Maitre);
		S2MisDraw(Maitre);

		S2AstDraw();

		S2NovaDraw();

		SwapScreen();

		S2Collision();

		_joueur[0].counter++;
		_joueur[1].counter++;

		iteration++;

	} while ( _joueur[0].dommage != 0 && _joueur[1].dommage != 0 );

	if ( _joueur[0].dommage == 0 )
		_joueur[1].points++;
	if ( _joueur[1].dommage == 0 )
		_joueur[0].points++;
}
