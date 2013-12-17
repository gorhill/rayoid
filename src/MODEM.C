/*************************************************************************

	Routine de gestion du modem

*/

#include <stdlib.h>
#include <string.h>
#include <tos.h>
#include "projet.h"

int StartSignal;
int Acknowledge;

DATAEXG DataExg;

/*************************************************************************

	Traiter un octet en provenance du modem

		122 : code de liaison MIDI
		123 : message recu (\r termine le message)
		124 : acknowledge
		125 : jeu en mode simple
		126 : jeu en mode complexe
		127 : signal de depart
		128 - 254 : donnees de joystick
		255 : l'adversaire abandonne le jeu

*/

int RecvModem()
{
	char *_c;

	char inchksum;
	char mychksum;

	int ii;
	int status;


	if ( (status = GetCMdm()) != 0 ) {

		switch ( status ) {

			case ERROR:
				Acknowledge = -1;
				break;

			case MIDILINK:
				(*MdmWrByte._proc)(ACK);
				Acknowledge = 1;
				break;

			case POSTMSG:
				MdmPost(0);
				break;

			case ACK:
				Acknowledge = 1;
				break;

			case SETSIMPLE:
			case SETCOMPLEX:
				mychksum = 0;
				_c = (char *)&DataExg;
				for ( ii = 0; ii < sizeof(DATAEXG); ii++, _c++ ) {
					*_c = WaitCMdm();
					mychksum += *_c;
					}

				inchksum = WaitCMdm();

				if ( mychksum == inchksum ) {

					if ( Maitre == 0 )
						InitRand(DataExg.seed);

					if ( DataExg.s1stats.score > S1Stats.score ) {
						S1Stats.score = DataExg.s1stats.score;
						strcpy(S1Stats.name,DataExg.s1stats.name);
						strcpy(S1Stats.msg,DataExg.s1stats.msg);
						}

					(*MdmWrByte._proc)(ACK);
					}
				else
					(*MdmWrByte._proc)(ERROR);
				break;

			case STARTSIGNAL:
				StartSignal = 1;
				break;

			case QUITGAME:
				JouteStatus = 2;
				break;

			default:
				if ( status >= 128 )
					Joueur[1].move = status;
				break;
			}
		}

	return ( JouteStatus );
}
