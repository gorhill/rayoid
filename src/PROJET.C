/*************************************************************************

	Routines generales

*/

#include <stdlib.h>
#include <tos.h>
#include <linea.h>
#include <string.h>
#include "projet.h"

int JouteStatus;
long *_Hz200 = (long *)0x4BA;

char *_SavLogScreen;
char *_SavPhyScreen;

GRECT ScreenBox = { 0,0,320,200 };

main()
{
	int probleme;

	DataDecrypt();

	if ( DataCheck() != 0 )
		DataClear();

	linea_init();
	hide_mouse();

	probleme = InitTank();

	if ( !probleme ) {
		InitSys();
		_InitSys();
		InitRand((int)*_Hz200 & 0x7FFF);
		ShowLogo();
		MnRoot();
		_TermSys();
		TermSys();
		}

	TermTank(probleme);

	show_mouse(0);

	return (0);
}

/************************************************************************/

static int SavPalette[16];
static int SavRez;

int InitTank()
{
	int ii;

	/* initialiser cookie */
	InitCookie();

	/* sauvegarder palette des couleurs */
	for ( ii = 0; ii < 16; ii++ )
		SavPalette[ii] = Setcolor(ii,-1);

	/* aller en basse resolution */
	SavRez = Getrez();
	if ( SavRez > 1 )
		return (1);

	/* mise en place des ecrans de travail */
	_SavLogScreen = (char *)Logbase();
	_SavPhyScreen = (char *)Physbase();

	_Screens[0] = (char *)malloc(32256L);
	_Screens[1] = (char *)malloc(32256L);
	if ( _Screens[0] == 0 || _Screens[1] == 0L )
		return (2);
	_Screens[0] = _ShowScreen = (char *)((long)(_Screens[0] + 255) & 0xFFFFFF00L);
	_Screens[1] = _HideScreen = (char *)((long)(_Screens[1] + 255) & 0xFFFFFF00L);
	MemClear(_Screens[0],32000L);
	MemClear(_Screens[1],32000L);

	Setpalette(BlackPalette);

	if ( ShipSetUp(0) == 0 )
		return (2);
	if ( MiscSetUp() == 0 )
		return (2);
	if ( StarSetUp() == 0 )
		return (2);
	if ( AstSetUp() == 0 )
		return (2);
	if ( ExplSetUp() == 0 )
		return (2);

	Setscreen(_Screens[0],_Screens[0],0);

	TTSpl = ((Cookies.snd & 2) != 0);
	SplOn._proc = _SplOnProc[ TTSpl ];
	SplOff._proc = _SplOffProc[ TTSpl ];

	NStars = (Cookies.cpu > 10) ? 32 : 16;

	return (0);
}

void TermTank(status)
	int status;
{

#ifdef REGISTERED
	int fh;

	PRGHDR header;
#endif


	Setpalette(SavPalette);

	switch ( status ) {

		case 0:
			Setscreen(_SavLogScreen,_SavPhyScreen,SavRez);

#ifdef REGISTERED
			/* changement dans les donnees de configuration ? */
			show_mouse(0);
			if ( DataCheck() != 0 ) {
				DataEncrypt();
				fh = Fopen(".\\RAYOID.PRG",2);
				if ( fh > 0 ) {
					Fread(fh,(long)sizeof(PRGHDR),&header);
					Fseek(header.text,fh,1);
					Fwrite(fh,(long)(sizeof(DATAVAR) + DataVar.size),&DataVar);
					Fclose(fh);
					}
				}
#endif

			return;

		/* memoire insuffisante */
		case 2:
			Cconws("\33EM‚moire insuffisante...\n\rNot enough memory...\n\r");
			break;

		/* resolution invalide */
		case 1:
			Cconws("\33ER‚solution basse ou moyenne seulement...\n\rLow or medium rez only...\n\r");
			break;
		}

	Bconin(2);
}

/*************************************************************************

	Attendre x millisecondes

*/

void Delai(ms)
	long ms;
{
	long delai;

	delai = *_Hz200;
	while ( ((*_Hz200 - delai) * 5) < ms ); 
}

/*************************************************************************

	COOKIE JAR

*/

COOKIES Cookies;

void InitCookie()
{
	long save_ssp;
	long *_5a0;


	save_ssp = Super(0L);

	_5a0 = *(long **)0x5a0;
	
	while( *_5a0 ) {
		if ( *_5a0 == '_MCH' )
			Cookies.type = *(int *)&_5a0[1];
		else if ( *_5a0 == '_CPU' )
			Cookies.cpu = _5a0[1];
		else if ( *_5a0 == '_SND' )
			Cookies.snd = _5a0[1];
		_5a0 += 2;
		}

	Super((void *)save_ssp);
}

/*************************************************************************

	Gestion systeme

*/

KEYTAB *_KeyTable;

static void (*_SavMouseVec)();

void InitSys()
{
	MOUSE mouse;
	KBDVBASE *_kbdvbase;

	_kbdvbase = Kbdvbase();
 	_SavMouseVec = _kbdvbase->kb_mousevec;

	Initmouse(0,&mouse,NullProc);
	_KeyTable = Keytbl((char *)-1L,(char *)-1L,(char *)-1L);
}

void TermSys()
{
	MOUSE mouse;

    mouse.topmode = 0;
    mouse.buttons = 0;
    mouse.x_scale = 1;
    mouse.y_scale = 1;
	Initmouse(1,&mouse,_SavMouseVec);
}

void NullPlay()
{
	JouteStatus = 3;
}

void NullProc()
{
}
