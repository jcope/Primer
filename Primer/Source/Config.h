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

#define MIN_BINARY_WIDTH 3
#define MAX_BINARY_WIDTH 8

#define OUTPUT_DIR "/Users/Jeremy/Projects/Primer/Output/"
#define OUTPUT_FILE "PrimerOutput.txt"

typedef enum{
    _BASIC,         //'basic'           std::find, used when the set is unordered
    _STANDARD,      //'standard',       default, uses binary search
    _BINARY_SEARCH, //'binarysearch'    requires a known ordered set, not to be used with random algorithm
    _FILE_SEARCH,   //'filesearch'
    _RANDOM,        //'randomsearch'
    _TWIN,          //'twinsearch'
    _MASTER_SPECIAL,//'mastersearch'
    _FLIP_SPECIAL,  //'flipsearch'
}runtime_exe;

//Must be a multiple of 2^n
//#define FILE_BUFFER_SEARCH_SIZE 4
//#define FILE_BUFFER_SEARCH_SIZE 32768
//#define FILE_BUFFER_SEARCH_SIZE 131072
#define FILE_BUFFER_SEARCH_SIZE 542288

#endif /* Config_h */
