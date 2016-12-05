/* Grundlage dieses Programmes ist ein Programm, dass ich auf
http://moxi.jp gefunden habe */

#include <stdio.h>
#include <stdlib.h>


#define LINEMAX 0x100

/* pseudo memory space */
unsigned char memory[0x10000] ; /* 64Kbyte Space */

/* hex to decimal converter */
static int hextoint(char a)
{
	if ((a >= '0') && (a <='9')) return a - '0' ;
	if ((a >= 'A') && (a <='F')) return a - 'A' + 0x0A ;
	if ((a >= 'a') && (a <='f')) return a - 'a' + 0x0A ;
	return 0 ;
}

static int hex2toint(char *a)
{
	return (hextoint(a[0]) * 0x10 +  hextoint(a[1])) ;
}

static int hex4toint(char *a)
{
	return (hextoint(a[0]) * 0x1000 +   hextoint(a[1]) * 0x100 + hextoint(a[2])*0x10 +  hextoint(a[3])) ;
}



int main(int argc,char *argv[])
{
	char line[LINEMAX] ;
	unsigned int memend,i ;
	FILE *fpi,*fpo ;

	memend = 0x0000 ; /* end address of output coe file */

	printf("Intel HEX to VHDL memory file converter (16bit)\n") ;


	/* help message */
	if (argc < 2) {
		fprintf(stderr,"%s [infile.hex]\n",argv[0]) ;
		exit(-1) ;
	}

	/* open input file */
	if ((fpi = fopen(argv[1],"r")) == NULL) {
		fprintf(stderr,"Can't open input file [%s]\n",argv[1]) ;
		exit(-1) ;
	}

	/* read hex file and distribute bits */
	while(fgets(line,LINEMAX,fpi) != NULL) {
		unsigned int reclen,recofs,rectyp ;

		/* +0123456789A            */
		/*  :LLOOOOTTDD...DDCC[CR] */
		/*  LL   - Data Count */
		/*  OOOO - Offset Address */
		/*  TT   - Record Type, 00 : DATA , 01 : END , ignore other types */

		/* [0] is always ':' */
		if (line[0] != ':') continue ;

		/* [1,2] is record length */
		reclen = hex2toint(&line[1]) ;
		if (reclen == 0) continue ;

		/* [3,4,5,6] is record offset */
		recofs = hex4toint(&line[3]) ;

		/* [7,8] is recore type */
		rectyp = hex2toint(&line[7]) ;
		if (rectyp != 0) continue ; /* 01 is END but ignore here */

		/* write one record to pseudo memory (no error check :-) */
		for (i = 0;i < reclen;i++) {
			int data ;
			data = hex2toint(&line[9+i*2]) ;
			memory[recofs] = (unsigned char)data & 0xFF;
			if (recofs > memend) memend = recofs ;
			recofs ++ ;
		}
	}
	fclose(fpi) ;

#define DEBUG
#ifdef DEBUG
	/* dump memory map (for DEBUG) */
	printf("Memory Content is ....\n") ;
	for (i = 0;i <= memend;i += 16) {
		unsigned int j ;
		printf("%04X :",i) ;
		for (j = i;(j < i + 16) && (j <= memend);j++) {
			printf(" %02X",memory[j]) ;
		}
		printf("\n") ;
	}
#endif

	/* open output file */
	if ((fpo = fopen("pkg_instrmem.vhd","w"))== NULL) {
		fprintf(stderr,"Can't open output file\n") ;
		exit(-1) ;
	}

	/* Output .vhd format */
	fprintf(fpo,"library ieee;\n") ;
	fprintf(fpo,"use ieee.std_logic_1164.all;\n") ;
//	fprintf(fpo,"use work.pkg_prozessor.all;\n") ;
	fprintf(fpo,"-- ---------------------------------------------------------------------------------\n") ;
	fprintf(fpo,"-- Memory initialisation package from input file : %s\n", argv[1]) ;
	fprintf(fpo,"-- ---------------------------------------------------------------------------------\n") ;
	fprintf(fpo,"package pkg_instrmem is\n\n") ;
	fprintf(fpo,"\ttype t_instrMem   is array(0 to 4096-1) of std_logic_vector(15 downto 0);\n") ;
	fprintf(fpo,"\tconstant PROGMEM : t_instrMem := (\n\t\t");
	for (i = 1;i <= memend;i+=3) {  //change byte order to 1,0,3,2,5,4,...
		unsigned char byte;
		signed int j ;
		fprintf(fpo,"\"") ;
		for (j=7;j>=0;j--)
        {
            byte = memory[i] & (1<<j);
            byte >>= j;
            fprintf(fpo, "%u", byte);
        }
        i--;                       // to change byte order....
        for (j=7;j>=0;j--)
        {
            byte = memory[i] & (1<<j);
            byte >>= j;
            fprintf(fpo, "%u", byte);
        }
        fprintf(fpo,"\",\n\t\t") ;
    }

    fprintf(fpo,"\n") ;
    fprintf(fpo,"\t\tothers => (others => '0')\n") ;
    fprintf(fpo,"\t);\n") ;
    fprintf(fpo,"\n") ;
    fprintf(fpo,"end package pkg_instrmem;\n") ;


	fclose(fpo) ;
	return 0;
}

