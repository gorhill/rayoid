/*************************************************************************

	Fichier d'inclusion de PROJET

*/

#define	REGISTERED


#include <aes.h>


#define MODEM 1
#define CONSOLE 2
#define NSTR 80

#define ERROR 121
#define MIDILINK 122
#define POSTMSG 123
#define ACK 124
#define SETSIMPLE 125
#define SETCOMPLEX 126
#define STARTSIGNAL 127
#define QUITGAME 255

#define SPACE_W 4096
#define SPACE_H 4096

#define POS_FRAC 32
#define DIR_FRAC 64
#define NMISSILE 8

#define NSTAR 32
#define NMAGNITUDE 4

#define NASTEROID 32
#define NBASE 28

typedef struct {
	int magic;	/* magic number (0x601A) */
	long text;	/* size of text segment */
	long data;	/* size of initialized data */
	long bss;	/* size of uninitialized data */
	long syms;	/* size of symbol table */
	long entry;	/* entry point */
	long res;	/* reserved, always zero */
	int reloc;	/* size of data relocation */
} PRGHDR;

typedef struct {
	int jmp;
	int (*_proc)();
} JMPVEC;

typedef struct {
	int x1;
	int y1;
	int x2;
	int y2;
} FRAME;

typedef struct {
	int type;	/*	0 	= ST
					1 	= STE
					2 	= TT */
	long cpu;	/*  0 	= 68000
					10 	= 68010
					20 	= 68020
					30 	= 68030 */
	long snd;	/*  0 	= PAS DE PROCESSOR
					1 	= YAMAHA SEUL
					2 	= SON STEREO DMA SEUL
					3 	= YAMAHA ET SON STEREO */
} COOKIES;

extern COOKIES Cookies;

typedef struct {
	int xpos;
	int ypos;
	int xposfrac;
	int yposfrac;
} POSITION;

typedef struct {
	int magnitude;		/*  0 - magnitude de l'etoile */
	int xpos;			/*  2 - coords de l'etoile */
	int ypos;			/*  4 */
	int xposfrac;		/*  6 */
	int yposfrac;		/*  8 */
	int *_scradr[2];	/* 10 - adresse de l'etoile a l'ecran */
} STAR;

typedef struct {
	int w_word;
	int h_line;
	int *_scrn;
} SCRADR;

typedef struct {
	GRECT box;			/*  0 - boite ecran du sprite */
	int xhot;			/*  8 */
	int yhot;			/* 10 */
	int w_word;			/* 12 - largeur du lutin en mot */
	int *_images;		/* 14 - images predecalees */
	int *__images[16];	/* 18 - liste de pointeurs sur les images predecalees */
	int *_masks;		/* 82 - masques predecales */
	int *__masks[16];	/* 86 - liste de pointeurs sur les masques predecales */
} SPRITE;

typedef struct {
	int on;
	int image;
	int xpos;
	int ypos;
	int xposfrac;
	int yposfrac;
	int xvit;
	int yvit;
	GRECT scrbox;
	SCRADR scradr[2];
} NOVA;

extern NOVA Novas[];

typedef struct {
	int on;
	int image;
	int xpos;
	int ypos;
	int xposfrac;
	int yposfrac;
	int xvit;
	int yvit;
	GRECT scrbox;
	SCRADR scradr[2];
} ASTEROID;

typedef struct {
	int on;				/* indicateur de missile actif */
	int type;			/* type de missile utilise */
	int xpos;			/* coords du missile */
	int ypos;
	int xposfrac;
	int yposfrac;
	int xvit;			/* vitesse du missile */
	int yvit;
	GRECT scrbox;
	SCRADR scradr[2];	/* adresse du missile l'ecran */
} MISSILE;

typedef struct {
	int mode;			/* developpement */
	int energie;		/* energie de la base */
	int counter;		/* compteur tout usage 1/60 sec */
	int xpos;
	int ypos;
	int xposfrac;
	int yposfrac;
	int xvit;
	int yvit;
	GRECT scrbox;
	SCRADR scradr[2];
	MISSILE mis;
	int map;			/* indique si base apparait sur la map */
	int hit;
} BASE;

extern BASE Bases[];

typedef struct {
	int on;
	int type;
	int count;
	int image;
	int xpos;
	int ypos;
	int xposfrac;
	int yposfrac;
	int xvit;
	int yvit;
	GRECT scrbox;
	SCRADR scradr[2];
	MISSILE mis;
} ALIEN;

extern ALIEN Alien;

typedef struct {
	int dir;			/*  0 - direction du vaisseau */
	int xpos;			/*  2 - position horizontale */
	int ypos;			/*  4 - position verticale */
	int xposfrac;		/*  6 - position horizontale fractionnelle */
	int yposfrac;		/*  8 - position verticale fractionnelle */
	int xvit;			/* 10 - vitesse horizontale */
	int yvit;			/* 12 - vitesse verticale */
	int xvitfrac;
	int yvitfrac;
	int move;
	int oldmove;
	int moteur;
	int hit;
	int dommage;
	int energie;
	long counter;
	long points;
	char nom[12];
	int hyper;
	int mistype;
	int	cryogen;
	int autofire;
	int	radrxpos;
	int radrypos;
	int invisible;
	int id;
	int nbase;
	int nfullbase;
	int explx;
	int exply;
	SCRADR savexpl[2];
	long podcnt;
	int mine;
	int minex;
	int miney;
	int minexfrac;
	int mineyfrac;
	int minexvit;
	int mineyvit;
	SCRADR savmine[2];
	int futurs[19];
	GRECT scrbox;
	MISSILE missiles[8];
	SPRITE vaisseau[16];
	SCRADR savship[2];
	SCRADR savfire[2];
} JOUEUR;

extern JOUEUR Joueur[2];

extern int Maitre;
extern int NewMaitre;
extern int JeuMode;
extern int JouteStatus;

extern long *_Hz200;
extern JMPVEC AuxVBL;

extern int Langue;

extern int BlackPalette[];
extern int ImgPalette[];

extern char *_Screens[];
extern char *_NewScreen;
extern char *_HideScreen;
extern char *_ShowScreen;
extern int Hide1Screen;
extern int Hide4Screen;
extern int Hide8Screen;
extern int *_NewPalette;

void SwapScreen( void );
void SwapWait( void );
void SwapReset( void );
void ScreenSync( void );
extern int SyncMode;

extern char *_SavLogScreen;
extern char *_SavPhyScreen;
extern GRECT ScreenBox;

int InitTank( void );
void TermTank( int );
void InitCookie( void );
void NullProc( void );
void ShowLogo( void );

void NullPlay( void );

void Delai( long );

void MyLToA( char *_str, long val );
void InitRand( int seed );
long FastRand( void );
int GetSign( int val );
void TrapVit( int *_xyvit, int limit );

void MemClear( void *, long );
void MemFill( void *, long, char );
void MemCopy( void *, void *, long );
void SaveA6( void );
void RestA6( void );

void CollConf( GRECT *_in );
int CollOr( GRECT *_in );
int CollAnd( GRECT *_in );

/*************************************************************************

	Parametres de congiguration de Rayoid (hi score, clavier, etc)

*/

typedef struct {
	int zero;
	int sum;
	int xor;
	int size;
	int data[0];
} DATAVAR;

extern DATAVAR DataVar;

void DataDecrypt( void );
void DataEncrypt( void );
int  DataCheck( void );
void DataClear( void );

/************************************************************************/

void CpyImage( int xsrc, int ysrc, int xdes, int ydes, int w, int h );
void ClrImage( int x, int y, int w, int h );
void ClrScreen( void );
void CopyZone( int x, int y, int w, int h );
void UnTiny( char *_tiny );

extern char TnyMenu[];
extern char TnyPanel[];
extern char TnyRayoid[];

/*************************************************************************

	DIALOGUE.C

*/

typedef struct {
	char status;
	char count;
	char keyon;
	char keyoff;
	char keystat[120];
	char capslock;
	char futur[7];
	unsigned char joy0;
	unsigned char joy1;
} KEYSTAT;

extern KEYSTAT KeyStat;
extern KEYTAB *_KeyTable;

void InitSys( void );
void TermSys( void );
void _InitSys( void );
void _TermSys( void );
int GetKeyAscii( void );
int LookKeybd( void );
void ClrKeybd( void );
void GetKeyName( char *_str, int scancode );

#define KEY_LROT 0
#define KEY_RROT 1
#define KEY_FIRE 2
#define KEY_MOTOR 3
#define KEY_BRAKE 4
#define KEY_HYPER 5
#define KEY_PAUSE 6

#define KEY_INVIS 7
#define KEY_CRYOGEN 8
#define KEY_LEURRE 9

typedef struct {
	char action[16];
} KEYCONF;

extern KEYCONF S1KeyCfg;
extern KEYCONF S2TKey1Cfg;
extern KEYCONF S2TKey2Cfg;
extern KEYCONF S2MKey1Cfg;

extern KEYCONF C2KeyCfg;

extern int MoveScale;

/*************************************************************************

	MENUS.C

*/

void MnRoot( void );
void MenuMsg( char *_str );

/*************************************************************************

	joueur.c

*/

int FindXYIdx( int x, int y );

extern int *_StarImg;
extern int *__StarImg[][];
extern int NStars;
extern STAR Stars[];

void SpriteDraw( SPRITE *, SCRADR * );
void SpriteMask( SPRITE *, SCRADR * );
void SpriteClear( SCRADR * );

extern int SprIdx[];

extern GRECT ClipSprite;

extern SPRITE MotorImg[];
extern SPRITE MisImg[];
extern SPRITE BigMisImg[];
extern SPRITE GazMisImg[];
extern SPRITE MineImg[];
extern SPRITE BonusImg[];
extern SPRITE BaseImg[];
extern SPRITE PodImg[];
extern SPRITE AstImg[];
extern SPRITE ExplImg[];
extern SPRITE AlnImg[];
extern SPRITE NovaImg[];
extern SPRITE IIIMisImg[];
extern SPRITE PiegeImg[];

extern int ShipXVit[];
extern int ShipYVit[];
extern int MisXPos[];
extern int MisYPos[];
extern int MisXVit[];
extern int MisYVit[];

int  ShipSetUp( int joueur );
void ShipFree( int joueur );

int  MiscSetUp( void );
int  StarSetUp( void );

int  AstSetUp( void );
int  ExplSetUp( void );

int  AlnSetUp( void );
void AlnFree( void );

int  SingleSetUp( void );
void SingleFree( void );
int  SimpleSetUp( void );
void SimpleFree( void );
int  ComplexSetUp( void );
void ComplexFree( void );

extern ASTEROID Asteroids[];

/*************************************************************************

	modem.c

*/

typedef struct {
	long score;
	char name[16];
	char msg[40];
} S1STATS;

extern S1STATS S1Stats;

typedef struct {
	int win;
	int lose;
	int rank;
	char name[16];
} C2STATS;

extern C2STATS C2Stats;

typedef struct {
	int seed;
	S1STATS s1stats;
	C2STATS c2stats;
} DATAEXG;

extern DATAEXG DataExg;

extern int Acknowledge;

extern JMPVEC MdmConnect;
extern JMPVEC MdmWrByte;
extern JMPVEC MdmRdByte;
extern JMPVEC MdmWrStr;
extern JMPVEC MdmWrBloc;
extern JMPVEC MdmConf;
extern JMPVEC MdmRdClr;
extern JMPVEC MdmReset;

extern MdmMode;
extern MdmPostX;
extern MdmPostY;
extern MdmPostLen;

void MdmSetMode( int mode );

int GetCMdm( void );	/* lire un caractere au modem (ou midi) */
int WaitCMdm( void );	/* attendre un caractere au modem (ou midi) */
int RecvModem( void );
void SendModem( int );
void MdmPost( int mode );

int SyncStart( void );

/*************************************************************************

	dialogue.c

*/

int StrFindChar( char *_str, char c );
int GetChoice( char *_valid );
void InitChoice( int row, int col, char * );
void MarkChoice( int row, int col, char *, int choix );
void _MarkChoice( char *_str, int choix, char color );
void GetStr( int row, int col, char *_str );
void StrLeft( char *_str, int n );
void StrRight( char *_str, int n );

void DrawChar( int x, int y, int c, int color, int op );
void DrawNumber( int x, int y, long val );

void _ShowStr( int xdes, int ydes, char *_str, int op );
void ShowStr( int row, int col, char *_str, int op );

extern char Fontes[];

extern char CopyRight[];
extern char *_Owner[];

/*************************************************************************

	Echantillonage

*/

typedef struct {
	int len;
	char *_data;
} SAMPLE;

extern int TTSpl;

extern void (*_SplOnProc[])( SAMPLE *_sample, int priorite, int speed );
extern void (*_SplOffProc[])( void );

extern JMPVEC SplOn;
extern JMPVEC SplOff;

extern SAMPLE SplFire1;
extern SAMPLE SplFire2;
extern SAMPLE SplFire3;
extern SAMPLE SplExplode;
extern SAMPLE SplRire1;
extern SAMPLE SplRire2;
extern SAMPLE SplJuron;
extern SAMPLE SplPastille;
extern SAMPLE SplTic;
