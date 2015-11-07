/*
 *==================================================================================================
 *  Filename      : bin2hex.v
 *  Revision      : 1.0
 *  Author        : Angel Terrones
 *  Company       : Universidad Simón Bolívar
 *  Email         : aterrones@usb.ve
 *
 *  Description   : Converts binary data into hex data.
 *                  This is for FPGA block RAM initialization data.
 *==================================================================================================
*/

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

// Typedefs
// -----------------------------------------------------------------------------
typedef enum { false, true } bool;

// Function declaration
// -----------------------------------------------------------------------------
void         help           (void);
unsigned int convertEndian  (unsigned int value, bool bigEndian);

// Main
// -----------------------------------------------------------------------------
int main(int argc, char **argv){
    // variables
    FILE         *file      = NULL;
    char         *inName    = NULL;
    char         *outName   = NULL;
    int           fileSize  = 0;
    unsigned int *inputData = NULL;
    int           dataPad   = 0;
    int           padLength = 0;
    bool          endian    = false;
    int           option    = 0;
    int           index     = 0;
    int           startPad  = 0;

    // p needs an argument: use ":".
    while( (option = getopt(argc, argv, "hbp:")) != -1 ){
        switch (option){
            case 'h':
                help();
                break;
            case 'b':
                endian = true;
                break;
            case 'p':
                padLength = (int)strtol(optarg, NULL, 10);
                break;
            default:
                help();
        }
    }

    // remove options. Leave only input/output targets
    argc -= optind;
    argv += optind;

    if(argc != 2){
        help();     // this have the exit
    }

    // get the input/output targets
    inName = argv[0];
    outName = argv[1];

    // read the input file
    file = fopen(inName, "rb");
    if(file == NULL){
        fprintf(stderr, "Error: Can not open \"%s\" file.\n", inName);
        exit(1);
    }

    // Get file size: Move cursor to EOF
    fseek(file, 0L, SEEK_END);
    fileSize = (int)ftell(file);
    if( (fileSize < 0) || ftell(file) > (long)fileSize){    // file is too big: more that 2 GB
        fprintf(stderr, "Error: Input file is too large.\n");
        fclose(file);
        exit(1);
    }

    // Move cursor to BOF and copy to array
    fseek(file, 0L, SEEK_SET);
    inputData = (unsigned int *)malloc(fileSize);
    if(inputData == NULL){
        fprintf(stderr, "Error: Can not allocate %d bytes of memory.\n", fileSize);
        fclose(file);
        exit(1);
    }
    if(fread(inputData, 1, fileSize, file) != (unsigned long)fileSize){
        fprintf(stderr, "Error reading input file.\n");
        free(inputData);
        fclose(file);
        exit(1);
    }
    fclose(file);

    // Write output file
    file = fopen(outName, "wb+");
    if(file == NULL){
        fprintf(stderr, "Error: Can not open \"%s\" file for writing.\n", outName);
        exit(1);
    }
    // words
    for (index = 0; index < (fileSize/4); index++) {
        if (index != 0) {
            fprintf(file, "\n");
        }
        fprintf(file, "%08x", convertEndian(inputData[index], endian));
    }
    fprintf(file, "\n");
    // pad last data
    // CHECK
    for(index = ( (fileSize/4)*4 ); index < fileSize; index++){
        printf("%s\n", "PADPADPADPADPADPADPADP");
        if (!endian){
            dataPad >>= 8;
            dataPad |= (0x000000FF & (((char *)inputData)[index] ) << 24);
        }else{
            dataPad <<= 8;
            dataPad |= (0x000000FF & ((char *)inputData)[index]);
        }
    }
    if ((fileSize%4) != 0){
        fprintf(file, "%08x\n", dataPad);
    }

    // Pad file size
    if(padLength > 0){
        startPad = (fileSize/4) + ( ((fileSize%4) != 0) ? 1 : 0 );
        for(index = startPad; index < padLength; index++){
            fprintf(file, "00000000\n");
        }
    }

    fclose(file);

    return 0;
}

// Function implementation
// -----------------------------------------------------------------------------

// Print help: How to use the program.
void help(void){
    const char *helpText = "Usage: bin2hex [-p <pad lenght>] [-b (Big Endian)] <input> <output>\n";
    printf("%s\n", helpText);
    exit(1);
}

// Convert a integer to hex, in big endian or little endian format.
unsigned int convertEndian(unsigned int value, bool bigEndian){
    if(bigEndian){
        return (((value >> 24) & 0x000000ff) |
                ((value >> 8)  & 0x0000ff00) |
                ((value << 8)  & 0x00ff0000) |
                ((value << 24) & 0xff000000));
    }
    else{
        return value;
    }
}
