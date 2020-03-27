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
#import "Primer.h"
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
        pTool->verifyMachine();
        pTool->runDataTest();
        
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
            string output = pTool->analyzePrimes(_primeList,binaryWidth);
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




int main2(int argc, const char * argv[]) {
    @autoreleasepool{
        
	    //Print Current Time
        time_t     now = time(0);
        time_t     startTime;
        struct tm  tstruct;
        char       buf[80];
        tstruct = *localtime(&now);
        // Visit http://en.cppreference.com/w/cpp/chrono/c/strftime
        // for more information about date/time format
        strftime(buf, sizeof(buf), "%Y-%m-%d.%X", &tstruct);
        std::cout << "Start Time: " << buf << std::endl;

        //Setup
        Primer* primer = [[Primer alloc] init];
        [primer verifyMachine];
        [primer runDataTest];
        
        //[primer runPerformaceTest];
        //exit(0);
        
        primesieve::iterator it;
        uint64_t _prime = it.next_prime(); //Read the initial prime
        
        
        //Test input file
        ifstream inputFile;
        inputFile.open(INPUT_FILE);
        
        if(inputFile.is_open()){
        
        //Output file
        NSString* outputFilePathName = [NSString stringWithFormat:@"%s/%s",OUTPUT_DIR,OUTPUT_FILE];
        ofstream outfile;
        outfile.open([outputFilePathName cStringUsingEncoding:NSUTF8StringEncoding]);
        
        if(LOG_DATA_FILE){
            outfile<<"Digits,Number of Primes,";
            outfile<<"Grand Master Primes,";
            outfile<<"Master Primes,Special Master Primes,";
            outfile<<"Grand Primes,Special Grand Primes,";
            outfile<<"Flip Primes,Special Flip Primes,";
            outfile<<"Invert Primes,";
            outfile<<"Null Primes"<<endl;
        }
        //NSMutableSet* testPrimeSet = [[NSMutableSet alloc] init];
        NSMutableArray* primeNumbers = [[NSMutableArray alloc] initWithCapacity:20];
        
        long long max;
        long long data=0;
        BOOL endOfFile = false;
        inputFile>>data; //Read the initial line
        
        //Filter out the minimums
        unsigned long long min;
        min = pow(2,MIN_BINARY_WIDTH-1)-1;
        while(_prime<=min){
            _prime = it.next_prime();
            //inputFile>>data;
        }
        NSLog(@"Starting with Prime: %lld",_prime);
        
        
        for(int binaryWidth=MIN_BINARY_WIDTH;binaryWidth<MAX_BINARY_WIDTH;binaryWidth++){ //Cyclce through all the different buckets
            max = pow(2,binaryWidth)-1; //Calculate the max bucket
            NSLog(@"****************************");
            NSLog(@"Binary width: %d",binaryWidth);
            NSLog(@"Analyzing for max: %lld",max);
            BOOL analyze = false;
            while(!analyze){
               
                if (_prime <= max) {
                    [primeNumbers addObject:@(_prime)];
                    //[testPrimeSet addObject:@(_prime)];
                    _prime = it.next_prime();
                }
                else{
                    analyze = true;
                }
                
                if(analyze && [primeNumbers count] > 0){ //Bucket is full, go analyze
                    NSLog(@"Count: %lu primes (between %.f and %lld)",(unsigned long)[primeNumbers count],pow(2,binaryWidth-1),max);
                   // NSLog(@"Array count: %lu - Set count: %lu",(unsigned long)[primeNumbers count],(unsigned long)[testPrimeSet count]);
                    //NSLog(@"Primes: %@",[primeNumbers description]);
                    
                    //What effect does randomizing the data have on our algorithm?
                    //Answer: Algorithm uses binary search, so assumes list is in order
                    //primeNumbers = [Primer randomSortArray:primeNumbers];
                    
                    //Analyze the Data
                    startTime = time(0);
                    //NSString* output = [primer analyzePrimeNumberList:primeNumbers width:binaryWidth];
                    //NSString* output = [primer analyzePrimeNumberList_Threaded:primeNumbers width:binaryWidth];
                    NSString* output = [primer analyzePrimeNumberList_NoThread:primeNumbers width:binaryWidth];
                    
                    //Flip* investigation
                    //NSString* output = [primer analyzePrimeNumberListForFlip_NoThread:primeNumbers width:binaryWidth];
                    
                    //Output the Data
                    outfile<<[output cStringUsingEncoding:NSUTF8StringEncoding]<<endl;
                    double totalTime = difftime(time(0),startTime);
                    NSLog(@"Total Time: %.f seconds",totalTime);
                    
                    //Reset the buckets
                    [primeNumbers removeAllObjects];
                }
            }
        }
        //If we reached the end of file without filling up a bucket, make sure this is known!
        if(endOfFile){
            NSLog(@"Reached EOF with %lu incomplete primes.",[primeNumbers count]);
        }
        //Print the End Time
        now = time(0);
        tstruct = *localtime(&now);
        // Visit http://en.cppreference.com/w/cpp/chrono/c/strftime
        // for more information about date/time format
        strftime(buf, sizeof(buf), "%Y-%m-%d.%X", &tstruct);
        std::cout << "End Time: " << buf << std::endl;
        }
        else{
            std::cout << "Could not open input file: "<<INPUT_FILE<<endl;
        }

    }//AutoRelease pool.
    return 0;
}

int main_Random(int argc, const char * argv[]) {

    int loopCnt = 10;
    while(loopCnt<128){
    
    @autoreleasepool{
        
        //Print Current Time
        time_t     now = time(0);
        time_t     startTime;
        struct tm  tstruct;
        char       buf[80];
        tstruct = *localtime(&now);
        // Visit http://en.cppreference.com/w/cpp/chrono/c/strftime
        // for more information about date/time format
        strftime(buf, sizeof(buf), "%Y-%m-%d.%X", &tstruct);
        std::cout << "Start Time: " << buf << std::endl;
        
        //Setup
        Primer* primer = [[Primer alloc] init];
        [primer verifyMachine];
        [primer runDataTest];
        
        //Output file
        NSString* outputFilePathName = [NSString stringWithFormat:@"%s/Random OutputLoop/%d%s",OUTPUT_DIR,loopCnt,OUTPUT_FILE];
        ofstream outfile;
        outfile.open([outputFilePathName cStringUsingEncoding:NSUTF8StringEncoding]);
        
        outfile<<"Digits,Number of Primes,";
        outfile<<"Grand Master Primes,";
        outfile<<"Master Primes,Special Master Primes,";
        outfile<<"Grand Primes,Special Grand Primes,";
        outfile<<"Flip Primes,Special Flip Primes,";
        outfile<<"Invert Primes,";
        outfile<<"Null Primes"<<endl;
        
        NSArray* primeNumbers = [[NSArray alloc] init];
        
        long long max;
        long long data=0;

        //Filter out the minimums
        unsigned long long min;
        min = pow(2,MIN_BINARY_WIDTH-1)-1;
        NSLog(@"Starting with Prime: %lld",data);
        
        for(int binaryWidth=MIN_BINARY_WIDTH;binaryWidth<MAX_BINARY_WIDTH;binaryWidth++){ //Cyclce through all the different buckets
            max = pow(2,binaryWidth)-1; //Calculate the max bucket
            NSLog(@"****************************");
            NSLog(@"Binary width: %d",binaryWidth);
            NSLog(@"Analyzing for max: %lld",max);
            
            unsigned long long primeCount = [primer primeNumbersPerGroup:binaryWidth];
            primeNumbers = [primer createRandomInput:binaryWidth numPrimes:primeCount];
            
            NSLog(@"Count: %lu primes (between %.f and %lld)",(unsigned long)[primeNumbers count],pow(2,binaryWidth-1),max);
            
            //Analyze the Data
            startTime = time(0);
            //NSString* output = [primer analyzePrimeNumberList:primeNumbers width:binaryWidth];
            //NSString* output = [primer analyzePrimeNumberList_Threaded:primeNumbers width:binaryWidth];
            NSString* output = [primer analyzePrimeNumberList_NoThread:primeNumbers width:binaryWidth];
            
            //Output the Data
            outfile<<[output cStringUsingEncoding:NSUTF8StringEncoding]<<endl;
            double totalTime = difftime(time(0),startTime);
            NSLog(@"Total Time: %.f seconds",totalTime);
            
        }
        outfile.close();
        //[primer dealloc];
        //[primeNumbers dealloc];
        
        //Print the End Time
        now = time(0);
        tstruct = *localtime(&now);
        // Visit http://en.cppreference.com/w/cpp/chrono/c/strftime
        // for more information about date/time format
        strftime(buf, sizeof(buf), "%Y-%m-%d.%X", &tstruct);
        std::cout << "End Time: " << buf << std::endl;

    }//AutoRelease Pool.
      loopCnt++;
    }
    return 0;
}

void testPrimeLibs()
{
    // store the primes below 1000
    //std::vector<int> primes;
    //primesieve::generate_primes(1000, &primes);

    primesieve::iterator it;
    uint64_t prime = it.next_prime();
    
    // iterate over the primes below 10^6
    for (; prime < 1000000; prime = it.next_prime())
        std::cout << prime << std::endl;
    
}

