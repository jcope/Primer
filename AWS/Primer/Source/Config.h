//
//  Config.h
//  Primer
//
//  Created by Jeremy Cope on 4/21/16.
//  Copyright © 2016 Emma Technologies, L.L.C. All rights reserved.
//

#ifndef Config_h
#define Config_h


#define LOG_RAW_DATA 1
#define LOG_DATA_CONSOLE 1
#define LOG_DATA_FILE 1
#define LOG_DATA_FILE_VERBOSE 1
#define LOG_DATA_FILE_VERBOSE_FULL 1


#define MIN_BINARY_WIDTH 3
#define MAX_BINARY_WIDTH 34


#define OUTPUT_FILE "PrimerOutput.txt"


//2^ ()
//35 = 34359738368
//34 = 17179869184
//30057700549

//32 = 4294967296

//29 = 536870912
//28 = 268435456
//27 = 134217728


//AWS
//#define INPUT_FILE "/data/PrimeInputData.txt" //Very Large, Up to [30057700549, 2^(34)+]
//#define INPUT_FILE "./PrimeInput.txt" //Sample Size, Up to [179424673, 2^(27)+]
//#define OUTPUT_DIR "./Output/"

//MAC
//#define INPUT_FILE "/Volumes/Untitled/Primer/PrimeInput.txt" //Very Large
//#define INPUT_FILE "/Users/Jeremy/Projects/Primer/PrimeInput.txt" //Sample Size
//#define OUTPUT_DIR "/Users/Jeremy/Projects/Primer/Output"

//USB
#define INPUT_FILE "/Volumes/Untitled/Primer/PrimeInput.txt" //Very Large
#define OUTPUT_DIR "/Volumes/Untitled/Primer/Output"


#endif /* Config_h */
