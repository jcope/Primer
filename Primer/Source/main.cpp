//
//  main.cpp
//  Primer
//
//  Created by Jeremy Cope on 3/23/16.
//  Copyright © 2016 Emma Technologies, L.L.C. All rights reserved.
//

#include <iostream>
#include <vector>
#include <set>
#include <iterator>
#include <unistd.h>
#include <string>
#include <fstream>
#include <sstream>
#include <time.h>
#include <chrono>
#include <thread>

//Third Party
#include <primesieve.hpp>
//Primer
#import "Config.h"
#import "PrimerTool.hpp"

using namespace std;
void printTime(string s);

void programStart();
void checkConfig();
void checkProgram();
void printHeader();

int main_primer();
int main_random();

runtime_exe _runMode = _STANDARD;
int _minWidth = MIN_BINARY_WIDTH;
int _maxWidth = MAX_BINARY_WIDTH;

int main(int argc, const char * argv[]) {
    programStart();
    if(_runMode == _RANDOM){
        return main_random();
    }
    else{
        return main_primer();
    }
}

int main_primer(){
    PrimerTool* pTool = new PrimerTool(_runMode);
    pTool->setupDataHeaders(string(OUTPUT_DIR)+string(OUTPUT_FILE));
        
    //Create the Prime Number generator
    primesieve::iterator it;
    uint64_t _prime = it.next_prime(); //Read the initial prime
    
    //Filter out the minimums
    uint64_t min = powl(2,_minWidth-1)-1;
    while(_prime<=min){
        _prime = it.next_prime();
    }
    cout<<"Starting with Prime: "<<_prime<<endl;
    printTime("Start Time: ");
    
    uint64_t max;
    time_t startTime = 0;
    vector<pType> _primeList;
          
    for(int binaryWidth=_minWidth;binaryWidth<_maxWidth;binaryWidth++){ //Cyclce through all the different buckets
        pTool->logDataHeaders(binaryWidth);
        
        if(_runMode == _FILE_SEARCH){
            startTime = time(0);
            pTool->createBinaryFile(binaryWidth);
            pTool->initializeBinaryFileSearch(binaryWidth);
            pTool->setBinaryWidth(binaryWidth);
        }
        
        max = powl(2,binaryWidth)-1; //Calculate the max bucket
        
        //Collect the data
        while(_prime <= max) {
            //Sequential or group search.
            if(_runMode == _FILE_SEARCH){
                pTool->analyzeNextPrime(_prime);
                _prime = it.next_prime();
            }
            else{
                _primeList.push_back(_prime);
                _prime = it.next_prime();
            }
        }

        //Analyze the bucket data
        if(_runMode == _FILE_SEARCH){
            //Analysis is already completed- performed as primes are parsed, entire group has been pre-generated into file.
            pTool->generateOutput();
        }
        else{
            startTime = time(0);
            pTool->analyzePrimes(_primeList,binaryWidth);
        }
        
        //Calculate and display run time
        double totalTime = difftime(time(0),startTime);
        cout<<"Total Time: "<<totalTime<<" seconds."<<endl;
        
        //Clean up for next run
        _primeList.clear();
    }
    printTime("End Time: ");
    return 0;
}

//Runs the primer search algorithm on randomized sets of known size (same size as equivalent prime grouping)
int main_random(){
    int loopCnt = 0;
    while(loopCnt < 128){
        PrimerTool* pTool = new PrimerTool(_runMode);
        
        //Write to file
        string outputFileName = string(OUTPUT_DIR)+"/RandomLoop/"+to_string(loopCnt)+string(OUTPUT_FILE);
        pTool->setupDataHeaders(outputFileName);
                
        //Create the Prime number generator
        primesieve::iterator it;
        uint64_t _prime = it.next_prime(); //Read the initial prime
        
        //Filter out the minimums
        uint64_t min = powl(2,_minWidth-1)-1;
        while(_prime<=min){
            _prime = it.next_prime();
        }
        cout<<"Starting with Prime: "<<_prime<<endl;
        printTime("Start Time: ");
        
        time_t startTime;
        vector<pType> _primeList;
        
        for(int binaryWidth=_minWidth;binaryWidth<_maxWidth;binaryWidth++){ //Cyclce through all the different buckets
            pTool->logDataHeaders(binaryWidth);
            
            pType primeCount = pTool->primeNumbersPerGroup(binaryWidth);
            _primeList = pTool->createRandomInput(binaryWidth, primeCount);
             
            //Analyze
            startTime = time(0);
            pTool->analyzePrimes(_primeList,binaryWidth);
            
            double totalTime = difftime(time(0),startTime);
            cout<<"Total Time: "<<totalTime<<" seconds."<<endl;
             
            //Clean up for next run
            _primeList.clear();
         }
         printTime("End Time: ");
         loopCnt++;
    }
    return 0;
}
//
void programStart(){
    printHeader();
    checkConfig();
    checkProgram();
    cout<<"****************************************"<<endl;
}
void printHeader(){
    cout << "********   Welcome to Primer   *********" << endl;
}
void checkConfig(){
    //Min and max search
    cout << "Running program from 2 ^ ("<< _minWidth << " to " << _maxWidth <<")"<<endl;
    //Search Algorithm
    string runString = "";
    switch (_runMode) {
        case _BASIC: runString = "Using std::find search algorithm"; break;
        case _STANDARD:
        case _BINARY_SEARCH: runString = "Using binary search algorithm"; break;
        case _FILE_SEARCH: runString = "Using file storage search algorithm"; break;
        case _RANDOM: runString = "Using random analysis algorithm"; break;
        case _TWIN: runString = "Using twin prime slgorithm"; break;
        case _MASTER_SPECIAL: runString = "Using master special investigation algorithm"; break;
        case _FLIP_SPECIAL: runString = "Using file special investigation algorithm"; break;
        default:
            break;
    }
    cout << runString << endl;
}
void checkProgram(){
    PrimerTool* pTool = new PrimerTool(_runMode);
    pTool->testPrimer(_maxWidth);
    delete pTool;
}
void printTime(string s){
    //Print Current Time
    time_t     now = time(0);
    struct tm  tstruct;
    char       buf[80];
    tstruct = *localtime(&now);
    // Visit http://en.cppreference.com/w/cpp/chrono/c/strftime
    // for more information about date/time format
    strftime(buf, sizeof(buf), "%Y-%m-%d.%X", &tstruct);
    cout << s << buf << endl;
}
