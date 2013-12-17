/*************************************************************************

	Convertir un fichier quelconque en fichier source assembleur

*/

#include <stdlib.h>
#include <stdio.h>
#include <tos.h>
#include <string.h>

unsigned char Buffer[64000L];

static char asm_line[] = "\tdc.b $%02X,$%02X,$%02X,$%02X,$%02X,$%02X,$%02X,$%02X,$%02X,$%02X,$%02X,$%02X,$%02X,$%02X,$%02X,$%02X\r";


main(argc,argv)
	int argc;
	char *argv[];
{
	int fh;

	long count;

	char s_file[128];
	char c_file[128];
	char gp_str[256];

	char *_c;
	unsigned char *_val;

	DTA *_dta;


	if ( argc < 2 ) {
		printf("Fichier a convertir inconnu\r");
		return (1);
		}

	_dta = Fgetdta();

	strcpy(s_file,argv[1]);
	strcpy(c_file,argv[1]);

	if ( Fsfirst(s_file,0) != 0 ) {
		printf("Fichier a convertir introuvable\r");
		return (2);
		}

	fh = Fopen(s_file,0);
	if ( fh < 0 ) {
		printf("Ouverture du fichier a convertir problematique\r");
		return (2);
		}
	Fread(fh,64000L,Buffer);
	Fclose(fh);

	_c = c_file;
	while ( *_c ) {
		if ( *_c == '.' )
			break;
		_c++;
		}
	strcpy(_c,".S");

	fh = Fcreate(c_file,0);
	if ( fh < 0 ) {
		printf("Je ne peux creer le fichier destination\r");
		return (4);
		}

	printf("Conversion en cours...");
	sprintf(gp_str,"\tdc.w %ld\r",_dta->d_length);
	Fwrite(fh,(long)strlen(gp_str),gp_str);
	_val = Buffer;
	count = _dta->d_length;
	while ( count > 0 ) {
		sprintf(gp_str,asm_line,(int)_val[0],(int)_val[1],(int)_val[2],(int)_val[3],(int)_val[4],(int)_val[5],(int)_val[6],(int)_val[7],(int)_val[8],(int)_val[9],(int)_val[10],(int)_val[11],(int)_val[12],(int)_val[13],(int)_val[14],(int)_val[15]);
		Fwrite(fh,(long)strlen(gp_str),gp_str);
		_val += 16;
		count -= 16;
		}

	Fclose(fh);

	return (0);
}
