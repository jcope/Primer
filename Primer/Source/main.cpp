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

void programStart();
void checkConfig();
void checkProgram();
void printHeader();
void printTime(string s);

int main_primer();
int main_random();

void createPrimeCountFile();
void createPrimeReducedCountFile();

runtime_exe _runMode = _FILE_SEARCH;
int _minWidth = MIN_BINARY_WIDTH;
int _maxWidth = MAX_BINARY_WIDTH;

int main(int argc, const char * argv[]) {
    programStart();
    //createPrimeCountFile();
    createPrimeReducedCountFile();
    return 0;
        
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
    uint64_t min = powl(2,_minWidth-1); //Minus 1 to include the min width group
    while(_prime<min){
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
    while(loopCnt < NUM_RANDOM_TRIALS){
        PrimerTool* pTool = new PrimerTool(_runMode);
        
        //Write to file
        string outputFileName = string(OUTPUT_DIR)+"/RandomLoop/"+to_string(loopCnt)+string(OUTPUT_FILE);
        pTool->setupDataHeaders(outputFileName);
                
        //Create the Prime number generator
        primesieve::iterator it;
        uint64_t _prime = it.next_prime(); //Read the initial prime
        
        //Filter out the minimums
        uint64_t min = powl(2,_minWidth-1); //Minus 1 to include the min width group
        while(_prime<min){
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
            
            //Calculate and display run time
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
    //Append and log the current time to the input string
    time_t now = time(0);
    struct tm tstruct;
    char buf[80];
    tstruct = *localtime(&now);
    strftime(buf, sizeof(buf), "%Y-%m-%d.%X", &tstruct);
    cout << s << buf << endl;
}
void createPrimeCountFile(){
    //Create the Prime Number generator
    primesieve::iterator it;
    
    string outputFileName = string(OUTPUT_DIR)+"PrimeCountFile.txt";
    pType number = it.next_prime();
    pType total = 0;
    pType count = 2;
    ofstream outfile;
    outfile.open(outputFileName, ofstream::out | ofstream::app);

    while(count<1048576){
    //while(count<100){
        outfile<<count<<","<<total<<endl;
        count++;
        if(count>=number){
            number = it.next_prime();
            total++;
        }
    }
    outfile.close();
}
void createPrimeReducedCountFile(){
    //Create the Prime Number generator
    //Data starts at bit length = 2
    pType dataSet[] = {1,2,3,5,8,15,27,48,90,167,317,606,1161,2195,4202,8122,15580,30017,57804,111554,216036,417763,808510};
    pType fullDataSet[] = {2,4,6,11,18,31,54,97,172,309,564,1028,1900,3512,6542,12251,23000,43390,82025,155611,295947,564163};
    pType number = 0;
    pType bitLength = 2;
    
    string outputFileName = string(OUTPUT_DIR)+"PrimeSetCountFile.txt";
    ofstream outfile;
    outfile.open(outputFileName, ofstream::out | ofstream::app);
    
    pType data = 0;
    while(bitLength < 21){
        data = fullDataSet[bitLength-2]; //dataset starts at index = 2
        outfile<<number<<","<<data<<endl;
        number++;
        pType limit = powl(2,bitLength)-1;
        if(number>=limit){
            bitLength++;
        }
    }
    outfile.close();
}
