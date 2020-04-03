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
//Third Party
#include <primesieve.hpp>
//Primer
#import "Config.h"
#import "PrimerTool.hpp"

using namespace std;
void printTime(string s);

void programStart();
void checkProgram();
void printHeader();

int main_primer();
int main_random();


int main(int argc, const char * argv[]) {
    programStart();
    return main_primer();
    //return main_random();
}
int main_primer(){
    PrimerTool* pTool = new PrimerTool();
          
    primesieve::iterator it;
    uint64_t _prime = it.next_prime(); //Read the initial prime
    vector<pType> _primeList;
          
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
    
    printTime("Start Time: ");
    time_t startTime;
          
    for(int binaryWidth=MIN_BINARY_WIDTH;binaryWidth<MAX_BINARY_WIDTH;binaryWidth++){ //Cyclce through all the different buckets
        max = powl(2,binaryWidth)-1; //Calculate the max bucket
        cout<<"****************************"<<endl;
        cout<<"Binary width: "<<binaryWidth<<endl;
        if(FILE_SEARCH){
            startTime = time(0);
            pTool->setBinaryWidth(binaryWidth);
        }

        bool analyze = false;
        
        //Collect the data
        while(!analyze){
            if (_prime <= max) {
                //Sequential or group search.
                if(! FILE_SEARCH){
                    _primeList.push_back(_prime);
                    _prime = it.next_prime();
                }
                else{
                    pTool->analyzeNextPrime(_prime);
                    _prime = it.next_prime();
                }
            }
            else{
                analyze = true;
            }
        }

        //Analyze the bucket data
        string output = "";
        if(FILE_SEARCH){
            output = pTool->generateOutput();
        }
        else{
            cout<<"Count: "<<_primeList.size()<< " primes (between "<< uint64_t(powl(2,binaryWidth-1)) <<" and "<< max <<")"<<endl;
            startTime = time(0);
            output = pTool->analyzePrimes(_primeList,binaryWidth);
            //string output = pTool->analyzePrimes_Twins(_primeList,binaryWidth);
            //string output = pTool->analyzePrimes_MasterSpecial(_primeList,binaryWidth);
        }
              
        outfile<<output<<endl;
        double totalTime = difftime(time(0),startTime);
        cout<<"Total Time: "<<totalTime<<" seconds."<<endl;

        //Clean up for next run
        _primeList.clear();
              
    }
    outfile.close();
    printTime("End Time: ");
    return 0;
}

int main_ramdom(){
    int loopCnt = 0;
    while(loopCnt < 128){
        PrimerTool* pTool = new PrimerTool();
        
         primesieve::iterator it;
         uint64_t _prime = it.next_prime(); //Read the initial prime
         vector<pType> _primeList;
         
         //Write to file
         string outputFileName = string(OUTPUT_DIR)+"/RandomLoop/"+to_string(loopCnt)+string(OUTPUT_FILE);
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
        
         printTime("Start Time: ");
         time_t startTime;
         
         for(int binaryWidth=MIN_BINARY_WIDTH;binaryWidth<MAX_BINARY_WIDTH;binaryWidth++){ //Cyclce through all the different buckets
             max = powl(2,binaryWidth)-1; //Calculate the max bucket
             cout<<"****************************"<<endl;
             cout<<"Binary width: "<<binaryWidth<<endl;
             if(FILE_SEARCH){
                 startTime = time(0);
                 pTool->setBinaryWidth(binaryWidth);
             }
             pType primeCount = pTool->primeNumbersPerGroup(binaryWidth);
             _primeList = pTool->createRandomInput(binaryWidth, primeCount);
             
             //Analyze
             string output = "";
             if(FILE_SEARCH){
                 output = pTool->generateOutput();
             }
             else{
                 cout<<"Count: "<<_primeList.size()<< " primes (between "<< uint64_t(powl(2,binaryWidth-1)) <<" and "<< max <<")"<<endl;
                 startTime = time(0);
                 output = pTool->analyzePrimes(_primeList,binaryWidth);
             }
             
             outfile<<output<<endl;
             double totalTime = difftime(time(0),startTime);
             cout<<"Total Time: "<<totalTime<<" seconds."<<endl;
             
             //Clean up for next run
             _primeList.clear();
             
         }
         outfile.close();
         printTime("End Time: ");
         loopCnt++;
    }
    return 0;
}
//
void programStart(){
    printHeader();
    checkProgram();
    cout<<"****************************"<<endl;
}
void checkProgram(){
    PrimerTool* pTool = new PrimerTool();
    pTool->testPrimer();
}
void printHeader(){
    cout << "**** Welcome to Primer ****" << endl;
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
