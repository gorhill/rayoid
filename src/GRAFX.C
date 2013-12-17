/*************************************************************************

	Routines de gestion graphique

*/

#include <stdlib.h>
#include <tos.h>
#include <linea.h>
#include "projet.h"

int Maitre;
int NewMaitre;
int JeuMode;

STAR Stars[NSTAR];	/* etoiles simultanees */

int *_StarImg;
int *__StarImg[NMAGNITUDE][16];

JOUEUR Joueur[2];
ASTEROID Asteroids[NASTEROID];
BASE Bases[32];
ALIEN Alien;
NOVA Novas[2];

GRECT ClipSprite = { 0,0,0,0 };

SPRITE MotorImg[16];
SPRITE MisImg[4];
SPRITE BigMisImg[4];
SPRITE GazMisImg[4];
SPRITE ExplImg[8];
SPRITE MineImg[4];
SPRITE BonusImg[5];
SPRITE BaseImg[18];
SPRITE PodImg[2];
SPRITE AstImg[3];
SPRITE AlnImg[5];
SPRITE NovaImg[3];
SPRITE IIIMisImg[8];
SPRITE PiegeImg[2];

static int ShipX[] = { 0,9,18,29,40,50,61,72,81,90,99,110,121,131,142,153 };


static int  BoniSetUp( void );
static void BoniFree( void );
static int  NovaSetUp( void );
static void NovaFree( void );
static int  BaseSetUp( void );
static void BaseFree( void );
static int  IIIMisSetUp( void );
static void IIIMisFree( void );
static int  MineSetUp( void );
static void MineFree( void );
static int  PiegeSetUp( void );
static void PiegeFree( void );

static int  SpriteSetUp( int x, int y, int w, int h, int xhot, int yhot, SPRITE * );
static void SpriteFree( SPRITE * );

/*************************************************************************

	Initialisation des differents modes de jeu

*/

int SingleSetUp()
{
	if ( AlnSetUp() == 0 || BoniSetUp() == 0 )
		return ( 0 );
	return ( 1 );
}

void SingleFree()
{
	AlnFree();
	BoniFree();
}

int SimpleSetUp()
{
	if ( ShipSetUp(1) == 0 || NovaSetUp() == 0 )
		return ( 0 );
	return ( 1 );
}

void SimpleFree()
{
	ShipFree(1);
	NovaFree();
}

int ComplexSetUp()
{
	if ( BaseSetUp() == 0 || ShipSetUp(1) == 0 || MineSetUp() == 0 || IIIMisSetUp() == 0 || PiegeSetUp() == 0 )
		return ( 0 );
	return ( 1 );
}

void ComplexFree()
{
	BaseFree();
	ShipFree(1);
	MineFree();
	IIIMisFree();
	PiegeFree();
}

/*************************************************************************

	Calcul des images predecalees des joueurs

*/

int ShipSetUp(joueur)
	int joueur;
{
	int dir;

	JOUEUR *_joueur = &Joueur[joueur];

	static int ShipW[] = { 9,9,11,11,10,11,11,9,9,9,11,11,10,11,11,9 };
	static int ShipH[] = { 10,11,11,9,9,9,11,11,10,11,11,9,9,9,11,11 };
	static int ShipXHot[] = { 4,5,5,4,3,4,5,5,4,3,5,6,6,6,5,3 };
	static int ShipYHot[] = { 6,6,5,3,4,5,5,4,3,4,5,5,4,3,5,6 };

	for ( dir = 0; dir < 16; dir++ ) {
		if ( SpriteSetUp(ShipX[dir],joueur * 11,ShipW[dir],ShipH[dir],ShipXHot[dir],ShipYHot[dir],&_joueur->vaisseau[dir]) == 0 )
			return (0);
		}

	return (1);
}

void ShipFree(joueur)
	int joueur;
{
	int dir;

	JOUEUR *_joueur = &Joueur[joueur];

	for ( dir = 0; dir < 16; dir++ )
		SpriteFree(&_joueur->vaisseau[dir]);
}

/*************************************************************************

	Calcul des images predecalees d'un paquet d'affaire

*/

int MiscSetUp()
{
	int ii;

	static int FireXHot[] = { 2,3,5,6,7,6,5,3,2,0,-1,-3,-4,-3,-1,0 };
	static int FireYHot[] = { -4,-3,-1,0,2,3,5,6,7,6,5,3,2,0,-1,-3 };

	for ( ii = 0; ii < 16; ii++ ) {
		if ( SpriteSetUp(ShipX[ii],22,5,5,FireXHot[ii],FireYHot[ii],&MotorImg[ii]) == 0 )
			return (0);
		}

	/* missiles standards de base */
	for ( ii = 0; ii < 4; ii++ ) {
		if ( SpriteSetUp(ii * 3,28,3,3,1,1,&MisImg[ii]) == 0 )
			return (0);
		}

	/* gros missiles */
	for ( ii = 0; ii < 4; ii++ ) {
		if ( SpriteSetUp(162 + ii * 7,0,7,7,3,3,&BigMisImg[ii]) == 0 )
			return (0);
		}

	/* missiles plasmiques */
	for ( ii = 0; ii < 4; ii++ ) {
		if ( SpriteSetUp(162 + ii * 7,8,7,7,3,3,&GazMisImg[ii]) == 0 )
			return (0);
		}

	return (1);
}

/*************************************************************************

	Initialiser sprites boni utilises en mode 1 joueur

*/

static int BoniSetUp()
{
	int ii;

	for ( ii = 0; ii < 5; ii++ ) {
		if ( SpriteSetUp(192 + ii * 16,0,15,15,7,7,&BonusImg[ii]) == 0 )
			return (0);
		}

	return (1);
}

static void BoniFree()
{
	int ii;

	for ( ii = 0; ii < 5; ii++ )
		SpriteFree(&BonusImg[ii]);
}

/*************************************************************************

	Initialiser sprites bases utilises en mode 2 joueurs complexe

*/

static int BaseSetUp()
{
	int ii;

	for ( ii = 0; ii < 18; ii++ ) {
		if ( SpriteSetUp(ii * 16,76,15,15,7,7,&BaseImg[ii]) == 0 )
			return (0);
		}

	for ( ii = 0; ii < 2; ii++ ) {
		if ( SpriteSetUp(ii * 8,32,7,7,3,3,&PodImg[ii]) == 0 )
			return (0);
		}

	return (1);
}

static void BaseFree()
{
	int ii;

	for ( ii = 0; ii < 18; ii++ )
		SpriteFree(&BaseImg[ii]);

	SpriteFree(&PodImg[0]);
	SpriteFree(&PodImg[1]);
}

/*************************************************************************

	Sprite Mines

*/

static int MineSetUp()
{
	int ii;
	int hot;
	int size;

	static int MineX[] = { 16,25,32,41 };

	for ( ii = 0; ii < 4; ii++ ) {
		size = (ii & 1) ? 7 : 9;
		hot = (ii & 1) ? 3 : 4;
		if ( SpriteSetUp(MineX[ii],28,size,size,hot,hot,&MineImg[ii]) == 0 )
			return (0);
		}

	return (1);
}

static void MineFree()
{
	int ii;

	for ( ii = 0; ii < 4; ii++ )
		SpriteFree(&MineImg[ii]);
}

/*************************************************************************

	Afficher sequence explosive

*/

int ExplSetUp()
{
	int ii;

	for ( ii = 0; ii < 8; ii++ ) {
		if ( SpriteSetUp(ii * 16,60,15,15,7,7,&ExplImg[ii]) == 0 )
			return (0);
		}

	return (1);
}

/*************************************************************************

	Asteroides

*/

int AstSetUp()
{
	int ii;

	static int AstX[] = { 192,210,227 };
	static int AstY[] = { 16,18,19 };
	static int AstW[] = { 15,11,9 };
	static int AstH[] = { 15,11,9 };
	static int AstXHot[] = { 7,5,4 };
	static int AstYHot[] = { 7,5,4 };

	for ( ii = 0; ii < 3; ii++ ) {
		if ( SpriteSetUp(AstX[ii],AstY[ii],AstW[ii],AstH[ii],AstXHot[ii],AstYHot[ii],&AstImg[ii]) == 0 )
			return (0);
		}

	return (1);
}

/*************************************************************************

	Initialiser les sprites de l'alien

*/

int AlnSetUp()
{
	int ii;

	static int AlnX[] = { 87,96,111,120,135 };
	static int AlienW[] = { 9,15,9,15,3 };
	static int AlienH[] = { 5,9,8,14,3 };
	static int AlienXHot[] = { 4,7,4,7,1 };
	static int AlienYHot[] = { 2,4,5,9,1 };

	for ( ii = 0; ii < 5; ii ++ ) {
		if ( SpriteSetUp(AlnX[ii],28,AlienW[ii],AlienH[ii],AlienXHot[ii],AlienYHot[ii],&AlnImg[ii]) == 0 )
			return (0);
		}
	return (1);
}

void AlnFree()
{
	int ii;

	for ( ii = 0; ii < 5; ii ++ )
		SpriteFree(&AlnImg[ii]);
}

/*************************************************************************

	Novas

*/

static int NovaSetUp()
{
	int ii;

	static int NovaX[] = { 48,63,76 };
	static int NovaWH[] = { 15,13,11 };

	for ( ii = 0; ii < 3; ii ++ ) {
		if ( SpriteSetUp(NovaX[ii],28,NovaWH[ii],NovaWH[ii],NovaWH[ii] / 2,NovaWH[ii] / 2,&NovaImg[ii]) == 0 )
			return (0);
		}
	return (1);
}

static void NovaFree()
{
	int ii;

	for ( ii = 0; ii < 3; ii ++ )
		SpriteFree(&NovaImg[ii]);
}

/*************************************************************************

	Initialiser sprites missile du mode complexe

*/

static int IIIMisSetUp()
{
	int ii;

	for ( ii = 0; ii < 8; ii++ ) {
		if ( SpriteSetUp(ii * 5,39,5,5,2,2,&IIIMisImg[ii]) == 0 )
			return (0);
		}

	return (1);
}

static void IIIMisFree()
{
	int ii;

	for ( ii = 0; ii < 8; ii++ )
		SpriteFree(&IIIMisImg[ii]);
}

/*************************************************************************

	Initialiser sprite de mine furtive

*/

static int PiegeSetUp()
{
	int ii;

	for ( ii = 0; ii < 2; ii++ ) {
		if ( SpriteSetUp(304,39 + ii * 7,7,7,3,3,&PiegeImg[ii]) == 0 )
			return (0);
		}

	return (1);
}

static void PiegeFree()
{
	SpriteFree(&PiegeImg[0]);
	SpriteFree(&PiegeImg[1]);
}

/*************************************************************************

	Initialiser un sprite

*/

static int SpriteSetUp(x,y,w,h,xhot,yhot,_sprite)
	int x,y;
	int w,h;
	int xhot,yhot;
	SPRITE *_sprite;
{
	int xoffset;

	long mem_img;	/* en octet */
	long mem_msk;	/* en octet */
	long mem_tot;	/* en octet */

	BITBLT bitblt;


	UnTiny(TnyRayoid);

	_sprite->box.g_w = w;
	_sprite->box.g_h = h;
	_sprite->xhot = xhot;
	_sprite->yhot = yhot;
	_sprite->w_word = (w + 30) >> 4;

	/* nombre d'octet par image et total */
	mem_img = _sprite->w_word * _sprite->box.g_h * 8;
	mem_msk = mem_img / 4;
	mem_tot = (mem_img + mem_msk) * 16;

	/* allouer la memoire necessaire */
	if ( _sprite->_images != 0L )
		free(_sprite->_images);
	_sprite->_images = malloc(mem_tot);
	if ( _sprite->_images == 0L )
		return (0);
	_sprite->_masks = _sprite->_images + mem_img * (16/2);

	MemClear((char *)_sprite->_images,mem_img * 16);
	MemFill((char *)_sprite->_masks,mem_msk * 16,-1);

	bitblt.b_wd = w;
	bitblt.b_ht = h;

	bitblt.plane_ct = 4;
	bitblt.fg_col = bitblt.bg_col = 0;

	bitblt.s_xmin = x;
	bitblt.s_ymin = y;
	bitblt.s_form = _SavLogScreen;
	bitblt.s_nxwd = 8;
	bitblt.s_nxln = 160;
	bitblt.s_nxpl = 2;

	for ( xoffset = 0; xoffset < 16; xoffset++ ) {

		/* image */
		bitblt.d_xmin = xoffset;
		bitblt.d_ymin = 0;

		bitblt.op_tab[0] = bitblt.op_tab[1] = bitblt.op_tab[2] = bitblt.op_tab[3] = 3;
		bitblt.d_form = _sprite->__images[xoffset] = _sprite->_images + (xoffset * mem_img / 2);
		bitblt.d_nxwd = 8;
		bitblt.d_nxln = _sprite->w_word << 3;
		bitblt.d_nxpl = 2;
		bitblt.p_addr = 0L;
		bit_blt(&bitblt);

		/* masque */
		bitblt.op_tab[0] = bitblt.op_tab[1] = bitblt.op_tab[2] = bitblt.op_tab[3] = 4;
		bitblt.d_form = _sprite->__masks[xoffset] = _sprite->_masks + (xoffset * mem_msk / 2);
		bitblt.d_nxwd = 2;
		bitblt.d_nxln = _sprite->w_word << 1;
		bitblt.d_nxpl = 0;
		bitblt.p_addr = 0L;
		bit_blt(&bitblt);
		}

	return (1);
}

/*************************************************************************

	Liberer la memoire utilisee par un sprite

*/

static void SpriteFree(_sprite)
	SPRITE *_sprite;
{
	if ( _sprite->_images != 0L ) {
		free(_sprite->_images);
		_sprite->_images = 0L;
		_sprite->_masks = 0L;
		}
}

/*************************************************************************

	Initialiser gestion des etoiles

*/

int StarSetUp()
{
	int magnitude;
	int xoffset;

	BITBLT bitblt;


	UnTiny(TnyRayoid);

	_StarImg = malloc((long)(NMAGNITUDE * 128));
	if ( _StarImg == 0L )
		return (0);
	MemClear((char *)_StarImg,(long)(NMAGNITUDE * 128));

	bitblt.b_wd = bitblt.b_ht = 1;
	bitblt.plane_ct = 4;
	bitblt.fg_col = bitblt.bg_col = 0;
	bitblt.s_form = _SavLogScreen;
	bitblt.s_nxwd = 8;
	bitblt.s_nxln = 160;
	bitblt.s_nxpl = 2;
	bitblt.d_ymin = 0;
	bitblt.d_nxwd = 8;
	bitblt.d_nxln = 16;
	bitblt.d_nxpl = 2;

	for ( magnitude = 0; magnitude < NMAGNITUDE; magnitude++ ) {
		bitblt.s_xmin = magnitude + 12;
		bitblt.s_ymin = 28;
		for ( xoffset = 0; xoffset < 16; xoffset++ ) {
			bitblt.op_tab[0] = bitblt.op_tab[1] = bitblt.op_tab[2] = bitblt.op_tab[3] = 3;
			bitblt.d_xmin = xoffset;
			bitblt.d_form = __StarImg[magnitude][xoffset] = _StarImg + (magnitude * 64) + (xoffset * 4);
			bitblt.p_addr = 0L;
			bit_blt(&bitblt);
			}
		}

	return (1);
}
