//
//  main.m
//  Primer
//
//  Created by Jeremy Cope on 3/23/16.
//  Copyright © 2016 Emma Technologies, L.L.C. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <iostream> // Definition of cin, cout etc.

#include <unistd.h>
#include <string>
#include <fstream>
#include <sstream>
#include <time.h>

#import "Config.h"
#import "Primer.h"

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

int main(int argc, const char * argv[]) {
    @autoreleasepool {
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
        
        //Test input file
        ifstream inputFile;
        inputFile.open(INPUT_FILE);
        
        //Output file
        NSString* outputFilePathName = [NSString stringWithFormat:@"%s/%s",OUTPUT_DIR,OUTPUT_FILE];
        ofstream outfile;
        outfile.open([outputFilePathName cStringUsingEncoding:NSUTF8StringEncoding]);
        
        if(LOG_DATA_FILE){
            outfile<<"Digits,Number of Primes,";
            outfile<<"Grand Master Primes,Master Primes,Grand Primes,Special Primes,";
            outfile<<"Flip Primes,Grand Flip Primes,Special Flip Primes,";
            outfile<<"Invert Primes,Grand Invert Primes,Special Invert Primes,";
            outfile<<"Null Primes"<<endl;
        }
        
        NSMutableArray* primeNumbers = [[NSMutableArray alloc] initWithCapacity:20];
        
        long long max;
        long long data=0;
        BOOL endOfFile = false;
        inputFile>>data; //Read the initial line
        
        //Filter out the minimums
        unsigned long long min;
        min = pow(2,MIN_BINARY_WIDTH-1)-1;
        while(data<=min){
            inputFile>>data;
        }
        NSLog(@"Starting with Prime: %lld",data);
        
        
        for(int binaryWidth=MIN_BINARY_WIDTH;binaryWidth<MAX_BINARY_WIDTH;binaryWidth++){ //Cyclce through all the different buckets
            max = pow(2,binaryWidth)-1; //Calculate the max bucket
            NSLog(@"****************************");
            NSLog(@"Binary width: %d",binaryWidth);
            NSLog(@"Analyzing for max: %lld",max);
            BOOL analyze = false;
            while(!analyze && !endOfFile){
               
                if (data <= max) {
                    [primeNumbers addObject:@(data)];
                    if(!(inputFile>>data)){ //Read the next line
                        endOfFile = true;
                    }
                }
                else{
                    analyze = true;
                }
                
                if(analyze && [primeNumbers count] > 0){ //Bucket is full, go analyze
                    NSLog(@"Count: %lu primes (between %.f and %lld)",(unsigned long)[primeNumbers count],pow(2,binaryWidth-1),max);
                    //NSLog(@"Primes: %@",[primeNumbers description]);
                    
                    //Analyze the Data
                    startTime = time(0);
                    //NSString* output = [primer analyzePrimeNumberList:primeNumbers width:binaryWidth];
                    NSString* output = [primer analyzePrimeNumberList_Threaded:primeNumbers width:binaryWidth];                 
                    
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
    return 0;
}
