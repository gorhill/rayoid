/*************************************************************************

	Routines de dialogue avec usager

*/

#include <tos.h>
#include <string.h>
#include <linea.h>
#include "projet.h"

/*************************************************************************

	Effectuer un choix

*/

int GetChoice(_valid)
	char *_valid;
{
	int choix;
	int index;

	do {
		choix = GetKeyAscii();
		index = StrFindChar(_valid,choix);
	} while ( index < 0 );

	return ( index );
}

/*************************************************************************

	Trouver la position d'un caractere dans une chaine

*/

int StrFindChar(_str,c)
	char *_str;
	char c;
{
	int ii = 0;

	while ( _str[ii] ) {
		if ( _str[ii] == c )
			return (ii);
		ii++;
		}
	return ( -1 );
}

/*************************************************************************

	Obtenir un caractere ASCII au clavier

	typedef struct {
		char *unshift;
		char *shift;
		char *capslock;
	} KEYTAB;
*/

int GetKeyAscii()
{
	unsigned char key;
	unsigned char ascii = 0;


	do {
		while ( (key = LookKeybd()) == 0 );

		if ( KeyStat.capslock )
			ascii = _KeyTable->capslock[key];
		else {
			if ( KeyStat.keystat[0x36] || KeyStat.keystat[0x2A] )
				ascii = _KeyTable->shift[key];
			else
				ascii = _KeyTable->unshift[key];
			}
	} while ( ascii == 0 );

	return ( (int)ascii );
}

void ShowStr(row,col,_str,op)
	int row,col;
	char *_str;
	int op;
{
	char *_c;

	int xdes,ydes;
	int len;


	if ( row < 0 )
		ydes = ScreenBox.g_y + ((ScreenBox.g_h - 8) >> 1);
	else
		ydes = row << 3;

	if ( col < 0 ) {
		for ( _c = _str, len = 0; *_c != 0; _c++ ) {
			if ( *_c != '~' && *_c != '|' )
				len += 8;
			else {
				if ( *_c == '~' )
					_c++;
				}
			}
		xdes = ScreenBox.g_x + ((ScreenBox.g_w - len) >> 1);
		}
	else
		xdes = col << 3;

	_ShowStr(xdes,ydes,_str,op);
}

/*************************************************************************

	Justification gauche ou droite d'une chaine de caractere

*/

void StrLeft(_str,n)
	char *_str;
	int n;
{
	char str[128];

	MemFill(str,80L,' ');
	strcpy(str,_str);
	str[strlen(_str)] = ' ';
	str[n] = 0;
	strcpy(_str,str);
}

void StrRight(_str,n)
	char *_str;
	int n;
{
	char str[128];

	MemFill(str,80L,' ');
	strcpy(&str[n - strlen(_str)],_str);
	strcpy(_str,str);
}

/*************************************************************************

	Initialiser un choix

*/

void InitChoice(row,col,_str)
	int row,col;
	char *_str;
{
	int first = 1;

	char *_c = _str;

	while ( *_c != 0 ) {
		if ( *_c == '~' ) {
			_c++;
			*_c = (first == 0) ? 'g' : 'd';
			first = 1 - first;
			}
		_c++;
		}

	ShowStr(row,col,_str,0);
}

void MarkChoice(row,col,_str,choice)
	int row,col;
	char *_str;
	int choice;
{
	_MarkChoice(_str,choice,'d');
	ShowStr(row,col,_str,0);
}

void _MarkChoice(_str,choice,color)
	char *_str;
	int choice;
	char color;
{
	int mark = 0;
	int first = 1;

	char *_c = _str;

	while ( *_c != 0 ) {
		if ( *_c++ == '~' ) {
			*_c = (mark == choice) ? color : 'g';
			if ( first == 0 )
				mark++;
			first = 1 - first;
			}
		}
}

/*************************************************************************

	Saisir une chaine de caractere

*/

void GetStr(row,col,_str)
	int row,col;
	char *_str;
{
	int key;
	int maxlen;
	int len = 0;
	int redraw = 1;
	int offset;

	char str[64];


	strcpy(str,_str);
	offset = StrFindChar(_str,'.');
	maxlen = (int)strlen(_str) - offset;

	do {
		if ( redraw )
			ShowStr(row,col,str,0);

		redraw = 0;

		key = GetKeyAscii();

		switch ( key ) {

			case '\r':
				break;

			case '\b':
				if ( len ) {
					len--;
					str[offset + len] = _str[offset + len];
					redraw = 1;
					}
				break;

			case '\33':
				if ( len ) {
					len = 0;
					strcpy(str,_str);
					redraw = 1;
					}
				break;

			default:
				if ( key >= ' ' && key <= '}' ) {
					if ( len < maxlen ) {
						str[offset + len] = key;
						len++;
						}
					else {
						str[offset + len - 1] = key;
						}
					redraw = 1;
					}
				break;
			}

	} while ( key != '\r' );

	str[offset + len] = 0;
	strcpy(_str,&str[offset]);
}
