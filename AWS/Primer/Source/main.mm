//
//  main.m
//  Primer
//
//  Created by Jeremy Cope on 3/23/16.
//  Copyright © 2016 Emma Technologies, L.L.C. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <iostream> // Definition of cin, cout etc.

#include <primesieve.hpp>
#include <iostream>
#include <vector>
#include <set>
#include <iterator>

#include <unistd.h>
#include <string>
#include <fstream>
#include <sstream>
#include <time.h>

#import "Config.h"
#import "PrimerTool.hpp"

//2^28 == 268,435,456
//2^29
//2^30 == 1,073,741,824
//2^31
//2^32 == 4,294,967,296
//2^34 == 17,179,869,184
//2^35 == 34,359,738,368
//2^37 == 137,438,953,472
//30,057,700,549

using namespace std;
void testPrimeLibs(void);
void printTime(string s);

int main(int argc, const char * argv[]) {
    @autoreleasepool{
        printTime("Start Time: ");

        PrimerTool* pTool = new PrimerTool();
        pTool->testPrimer();
        
        primesieve::iterator it;
        uint64_t _prime = it.next_prime(); //Read the initial prime
        vector<unsigned long long> _primeList;
        
        //Write to file
        string outputFileName = string(OUTPUT_DIR)+string(OUTPUT_FILE);
        ofstream outfile;
        outfile.open(outputFileName);
        if(LOG_DATA_FILE){
            outfile<<"Digits,Number of Primes,";
            outfile<<"Grand Master Primes,";
            outfile<<"Master Primes,Special Master Primes,";
            outfile<<"Grand Primes,Special Grand Primes,";
            outfile<<"Flip Primes,Special Flip Primes,";
            outfile<<"Invert Primes,";
            outfile<<"Null Primes"<<endl;
        }
        
        uint64_t max;
        
        //Filter out the minimums
        uint64_t min;
        min = powl(2,MIN_BINARY_WIDTH-1)-1;
        while(_prime<=min){
            _prime = it.next_prime();
        }
        cout<<"Starting with Prime: "<<_prime<<endl;
        
        time_t startTime;
        
        for(int binaryWidth=MIN_BINARY_WIDTH;binaryWidth<MAX_BINARY_WIDTH;binaryWidth++){ //Cyclce through all the different buckets
            max = powl(2,binaryWidth)-1; //Calculate the max bucket
            cout<<"****************************"<<endl;
            cout<<"Binary width: "<<binaryWidth<<endl;
            cout<<"Analyzing for max: "<<binaryWidth<<endl;
            BOOL analyze = false;
            //Collect the data
            while(!analyze){
                if (_prime <= max) {
                    _primeList.push_back(_prime);
                    _prime = it.next_prime();
                }
                else{
                    analyze = true;
                }
            }
            //Analyze
            cout<<"Count: "<<_primeList.size()<< " primes (between "<< uint64_t(powl(2,binaryWidth-1)) <<" and "<< max <<")"<<endl;
            startTime = time(0);
            //string output = pTool->analyzePrimes(_primeList,binaryWidth);
            string output = pTool->analyzePrimes_Twins(_primeList,binaryWidth);
            outfile<<output<<endl;
            double totalTime = difftime(time(0),startTime);
            cout<<"Total Time: "<<totalTime<<" seconds."<<endl;
            
            //Clean up for next run
            _primeList.clear();
        }
        printTime("End Time: ");
        
    }//Autorelease poool
    return 0;
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
    std::cout << s << buf << std::endl;
}
