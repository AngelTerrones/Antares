/*
 *==================================================================================================
 *  Filename      : bin2hex.v
 *  Revision      : 1.0
 *  Author        : Angel Terrones
 *  Company       : Universidad Simón Bolívar
 *  Email         : aterrones@usb.ve
 *
 *  Description   : Conbines the text (instruction) and data segments of an
 *                  executable file into one binary file.
 *==================================================================================================
*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>

// Function declaration
// -----------------------------------------------------------------------------
void help     (void);
void readFile (char *name, int *size, char **buffer);

// Main
// -----------------------------------------------------------------------------
int main(int argc, char **argv){
    // variables
    FILE    *file             = NULL;
    char    *textName         = NULL;
    char    *dataName         = NULL;
    char    *outName          = NULL;
    int      textSize         = 0;
    int      dataSize         = 0;
    char    *textBuffer       = NULL;
    char    *dataBuffer       = NULL;
    int      dataStartAddress = 0;
    int      option           = 0;
    int      dataPad          = 0;

    // p needs an argument: use ":".
    while( (option = getopt(argc, argv, "d:")) != -1 ){
        switch (option){
            case 'd':
                dataStartAddress = (int)strtol(optarg, NULL, 10);
                break;
            default:
                help();
        }
    }

    // remove options. Leave only input/output targets
    argc -= optind;
    argv += optind;

    if(argc != 3){
        help();     // this have the exit
    }

    // get the input/output targets
    textName = argv[0];
    dataName = argv[1];
    outName  = argv[2];

    // read input files
    readFile(textName, &textSize, &textBuffer);
    readFile(dataName, &dataSize, &dataBuffer);

    // Open output file
    file = fopen(outName, "wb+");
    if(file == NULL){
        fprintf(stderr, "Error: Can not open \"%s\" for writing.\n", outName);
        exit(1);
    }

    // copy text segment
    if(fwrite((void*)textBuffer, 1, textSize, file) != (unsigned long)textSize){
        fprintf(stderr, "Error writing text segment to output file.\n");
        exit(1);
    }

    // pad until data segment
    textBuffer[0] = 0;
    while(textSize < dataStartAddress){
        if(fwrite((void*)textBuffer, 1, 1, file) != 1){
            fprintf(stderr, "Error writing 0 (pad to data seg) to output file.\n");
            exit(1);
        }
        textSize++;
    }

    // copy data segment
    if(fwrite((void*)dataBuffer, 1, dataSize, file) != (unsigned long)dataSize){
        fprintf(stderr, "Error writing data segment to output file.\n");
        exit(1);
    }

    // pad data section (at the end)
    dataPad = ((dataSize % 4) != 0) ? 4 - (dataSize % 4) : 0;
    if(dataPad != 0){
        memset((void *)dataBuffer, 0, 4);
        if(fwrite((void*)dataBuffer, 1, dataPad, file) != (unsigned long)dataPad){
            fprintf(stderr, "Error writing 0 (pad to end) to output file.\n");
            exit(1);
        }
    }

    return 0;
}

// Function implementation
// -----------------------------------------------------------------------------

// Print help: How to use the program.
void help(void){
    const char *helpText = "Usage: bin2mem [-d <data start address>] <text segment> <data segment> <output file>\n";
    printf("%s\n", helpText);
    exit(1);
}

// Read a file
void readFile(char *name, int *size, char **buffer){
    FILE *file;

    file = fopen(name, "rb");
    if(file == NULL){
        fprintf(stderr, "Error: Can not open \"%s\" file.\n", name);
        exit(1);
    }
    fseek(file, 0L, SEEK_END);
    *size = (int)ftell(file);
    if((*size < 0) || (ftell(file) > (long)*size)){
        fprintf(stderr, "Error: File is too large.\n");
        fclose(file);
        exit(1);
    }
    fseek(file, 0L, SEEK_SET);
    *buffer = (char *)malloc(*size);
    if(*buffer == NULL){
        fprintf(stderr, "Error: Can not allocate %d bytes of memory.\n", *size);
        fclose(file);
        exit(1);
    }
    if(fread(*buffer, 1, *size, file) != (unsigned long)*size){
        fprintf(stderr, "Error: Can not read input file.\n");
        fclose(file);
        exit(1);
    }

    fclose(file);
}
