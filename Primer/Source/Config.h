//
//  Config.h
//  Primer
//
//  Created by Jeremy Cope on 4/21/16.
//  Copyright © 2016 Emma Technologies, L.L.C. All rights reserved.
//

#ifndef Config_h
#define Config_h

#define LOG_DATA_CONSOLE 1
#define LOG_DATA_FILE 1
#define LOG_DATA_FILE_VERBOSE 1
#define LOG_DATA_FILE_VERBOSE_FULL 1

#define MIN_BINARY_WIDTH 3
#define MAX_BINARY_WIDTH 16

#define OUTPUT_DIR "/Users/Jeremy/Projects/Primer/Output/"
#define OUTPUT_FILE "PrimerOutput.txt"

//Search Algorithm. Default is std::find
#define BINARY_SEARCH 1 //Only use if we know the input will be ordered
#define FILE_SEARCH 0

#endif /* Config_h */
