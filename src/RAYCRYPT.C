/*************************************************************************

	Envrypter la zone de donnees de Rayoid

*/

#include "tos.h"
#include "string.h"

typedef struct {
    int        c_magic;    /* magic number (0x601A)       */
    long       c_text;     /* size of text segment        */
    long       c_data;     /* size of initialized data    */
    long       c_bss;      /* size of uninitialized data  */
    long       c_syms;     /* size of symbol table        */
    long       c_entry;    /* entry point                 */
    long       c_res;      /* reserved, always zero       */
    int        c_reloc;    /* size of data relocation     */
} HEADER;

typedef struct {
	int zero;
	int sum;
	int xor;
	int size;
	char data[0];
} DATAVAR;

char Buffer[256 * 1024L];
long Code = -'RHIL';

main( argc, argv )
	int argc;
	char *argv[];
{
	int ii;
	int fh;
	int codeidx;

	long database;
	long datacnt;

	char str[32];
	char name[32];

	char *_data;
	char *_code;
	int *_chksum;

	HEADER header;
	DATAVAR *_datavar;


	fh = Fopen( "RAYOID.PRG", 2 );
	if ( fh <= 0 )
		return ( 1 );

	Fread( fh, sizeof( HEADER ), &header );

	database = sizeof( HEADER ) + header.c_text;

	Fseek( database, fh, 0 );

	_datavar = (DATAVAR *)Buffer;
	Fread( fh, sizeof( DATAVAR ), _datavar );

	if ( _datavar->zero == 0 ) {

		Cconws("\033EEncryptage en cours...\n\r");

		_data = Buffer + sizeof( DATAVAR );
		Fread( fh, (long)_datavar->size, _data );

		for ( ii = 1, name[0] = 0; ii < argc; ii++ ) {
			strcat( name, " " );
			strcat( name, argv[ ii ] );
			}

		/* francais */
		strcpy( str, "~6Merci" );
		strcat( str, name );
		strcpy( _data + _datavar->size - 32, str );

		/* anglais */
		strcpy( str, "~6Thanks" );
		strcat( str, name );
		strcpy( _data + _datavar->size - 64, str );

		_chksum = (int *)_data;
		_code = (char *)&Code;
		datacnt = _datavar->size;
		codeidx = 0;
		_datavar->sum = 0;
		_datavar->xor = 0;
		do {
			if ( (codeidx & 1) == 0 ) {
				_datavar->sum += *_chksum;
				_datavar->xor ^= *_chksum;
				_chksum++;
				}
			*_data += _code[codeidx];
			codeidx++;
			codeidx &= 3;
			_data++;
		} while ( --datacnt );
	
		_datavar->zero = 1;
	
		Fseek( database, fh, 0 );
		Fwrite( fh, sizeof( DATAVAR ) + _datavar->size, Buffer );
		}

	else {
		Cconws("\033EDeja encrypte...\n\r");
		Bconin(2);
		}

	Fclose( fh );

	return (0);
}
