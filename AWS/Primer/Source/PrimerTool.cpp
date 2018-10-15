//
//  Primer.cpp
//  Primer
//
//  Created by Jeremy Cope on 10/11/18.
//  Copyright © 2018 Emma Technologies, L.L.C. All rights reserved.
//

#include "PrimerTool.hpp"
#include <stdio.h>
#include <iostream>
#include <fstream>
#include <sstream>
#include <algorithm>
#include <math.h>

PrimerTool::PrimerTool(){
    
}    
PrimerTool::~PrimerTool(){
    
}

void PrimerTool::testPrimer(){
    verifyMachine();
    runDataTest();
}
void PrimerTool::initBuckets(){
    m_grandMasterPrimes.clear();
    m_masterPrimes.clear();
    m_specialMasterPrimes.clear();
    m_grandPrimes.clear();
    m_specialGrandPrimes.clear();
    m_flipPrimes.clear();
    m_specialFlipPrimes.clear();
    m_invertPrimes.clear();
    m_nullPrimes.clear();
}

string PrimerTool::analyzePrimes(vector<unsigned long long>primes, int width){
    //Store the primes in data controlled storage
     m_primeList = primes;
    m_primeWidth = width;
    initBuckets();
    
    analyzePrimeNumberList();

    verifyCount(); //Will Assert if false
    string result = outputResults();
    
    return result;
}
string PrimerTool::outputResults(){
    if(LOG_DATA_CONSOLE){
        string str;
        str.reserve(100);
        //Print out the sumsx
        str+="----------------------------------------\n";
        str+="Digits: " + to_string(m_primeWidth) + "\n";
        
        str+="Total Primes: "+ to_string(m_primeList.size());
        str+="\n--------------------\n";
        str+="Grand Master Primes: " + to_string(m_grandMasterPrimes.size());
        str+="\nMaster Primes: " + to_string(m_masterPrimes.size());
        str+="\nSpecial Master Primes: " + to_string(m_specialMasterPrimes.size());
        str+="\nGrand Primes: " + to_string(m_grandPrimes.size());
        str+="\nSpeical Grand Primes: " + to_string(m_specialGrandPrimes.size());
        str+="\nFlip Primes: " + to_string(m_flipPrimes.size());
        str+="\nSpecial Flip Primes: " + to_string(m_specialFlipPrimes.size());
        str+="\nInvert Primes: " + to_string(m_invertPrimes.size());
        str+="\nNull Primes: " + to_string(m_nullPrimes.size());
        str+="\n----------------------------------------";
        log(str);
    }
    
    if(LOG_DATA_FILE_VERBOSE){
        string str;
        str.reserve(300);
        
        string fileName = string(OUTPUT_DIR)+"/"+to_string(m_primeWidth)+"_"+string(OUTPUT_FILE);
        string dataBreak = "\n----------------------";
        
        //Generate and write all outputs
        str += "Digit Width: "+to_string(m_primeWidth);
        str += "\nMax Prime: "+to_string(powl(2, m_primeWidth)-1);
        str += "\nTotal Primes: "+to_string(m_primeList.size());
        str += dataBreak;
        //Grand/Master/Special
        str += "\nGrand Master Primes: "+setDescription(m_grandMasterPrimes);
        str += dataBreak;
        str += "\nMaster Primes: "+setDescription(m_masterPrimes);
        str += "\nSpecial Master Primes: %@"+setDescription(m_specialMasterPrimes);
        str += dataBreak;
        str += "\nGrand Primes: %@"+setDescription(m_grandPrimes);
        str += "\nSpecial Grand Primes: %@"+setDescription(m_specialGrandPrimes);
        str += dataBreak;
        //Flip
        str += "\nFlip Primes: %@"+setDescription(m_flipPrimes);
        str += "\nSpecial Flip Primes: %@"+setDescription(m_specialFlipPrimes);
        str += dataBreak;
        //Invert
        str += "\nInvert Primes: %@"+setDescription(m_invertPrimes);
        str += dataBreak;
        //Null Primes
        str += "\nNull Primes: %@"+setDescription(m_nullPrimes);
        
        //Write to file
        ofstream outfile;
        outfile.open(fileName);
        outfile<<str;
        outfile.close();
    }
    
    
    //Create the output string
    string str;
    str.reserve(300);
    
    //Digits,Number of Primes,
    //Grand Master Primes,
    //Master Primes, Special Master Primes,
    //Grand Primes, Special Grand Primes,
    //Flip Primes, Special Flip Primes,
    //Invert Primes,
    //Null Primes
    str+=to_string(m_primeWidth);
    
    str+=","+to_string(m_primeList.size());
    
    str+=","+to_string(m_grandMasterPrimes.size());
    
    str+=","+to_string(m_masterPrimes.size());
    str+=","+to_string(m_specialMasterPrimes.size());
    
    str+=","+to_string(m_grandPrimes.size());
    str+=","+to_string(m_specialGrandPrimes.size());
    
    str+=","+to_string(m_flipPrimes.size());
    str+=","+to_string(m_specialFlipPrimes.size());
    
    str+=","+to_string(m_invertPrimes.size());
    
    str+=","+to_string(m_nullPrimes.size());

    return str;
}
string PrimerTool::setDescription(set <unsigned long long, less <unsigned long long> > primeSet){
    string retStr = "";
    set<unsigned long long>::iterator it;
    for (it=primeSet.begin(); it!=primeSet.end(); ++it)
        retStr+=to_string(*it)+",";
    //Remove trailing comma
    retStr.erase(retStr.end());
    return retStr;
}
void PrimerTool::analyzePrimeNumberList(){
    std::for_each(m_primeList.begin(), m_primeList.end(), [this](unsigned long long& prime){
        unsigned long long storagePrime = 0;
        primeType pType = calculatePrimeType(prime,&storagePrime);

        if(pType == grandMasterPRIME) m_grandMasterPrimes.insert(storagePrime);
        else if(pType == masterPRIME) m_masterPrimes.insert(storagePrime);
        else if(pType == specialMasterPRIME) m_specialMasterPrimes.insert(storagePrime);
        else if(pType == grandPRIME) m_grandPrimes.insert(storagePrime);
        else if(pType == specialGrandPRIME) m_specialGrandPrimes.insert(storagePrime);
        else if(pType == flipPRIME) m_flipPrimes.insert(storagePrime);
        else if(pType == specialFlipPRIME) m_specialFlipPrimes.insert(storagePrime);
        else if(pType == invertPRIME) m_invertPrimes.insert(storagePrime);
        else if(pType == nullPRIME) m_nullPrimes.insert(storagePrime);
        else assertLog(false,"Unknown Type");
    });
}
primeType PrimerTool::calculatePrimeType(unsigned long long prime, unsigned long long* sPrime){
    primeType retPrimeType = unknownPRIME;
    unsigned long long retStoragePrime;
    
    unsigned long long primeInvert = invert(prime, m_primeWidth);
    unsigned long long primeFlip = flip(prime, m_primeWidth);
    unsigned long long primeInvertFlip = invertFlip(prime, m_primeWidth);
    
    
    bool hasInvert = containsPrime(primeInvert);
    bool hasFlip = containsPrime(primeFlip);
    bool hasInvertFlip = containsPrime(primeInvertFlip);
    
    //Count the number of primes in the set
    int primeSetCnt = 1; //Start with atleast 1 prime (initial entry)
    if(hasInvert)primeSetCnt++;
    if(hasFlip)primeSetCnt++;
    if(hasInvertFlip)primeSetCnt++;
    
    //TODO: Add only the lowest value
    /*
     unsigned long long basePrime = 0;
     basePrime = [self calculateBasePrime:prime
     invertPrime:(hasInvert?primeInvert:0)
     flipPrime:(hasFlip?primeInvertFlip:0)
     invertFlipPrime:(hasInvertFlip?primeInvertFlip:0)];
     basePrime = prime;
     */
    
    //Categorize the prime
    if(primeSetCnt == 1){
        retPrimeType = nullPRIME;
        retStoragePrime = prime;
    }
    else if (primeSetCnt == 2){
        //Flip, Invert, Special Flip, Grand, Special Grand
        if(hasFlip){
            if(prime == primeFlip){
                retPrimeType = specialFlipPRIME;
                retStoragePrime = prime;
            }
            else{
                retPrimeType = flipPRIME;
                //Store the smaller prime
                retStoragePrime = (prime<primeFlip?prime:primeFlip);
            }
        }
        else if(hasInvert){
            retPrimeType = invertPRIME;
            //Store the smaller prime
            retStoragePrime = (prime<primeInvert?prime:primeInvert);
        }
        else if(hasInvertFlip){
            if(prime == primeInvertFlip){
                retPrimeType = specialGrandPRIME;
                retStoragePrime = prime;
            }
            else{
                retPrimeType = grandPRIME;
                //Store the smaller prime
                retStoragePrime = (prime<primeInvertFlip?prime:primeInvertFlip);
            }
        }
        else{
            log("Reached poor logic choice 23.");
            retStoragePrime = 0;
        }
        
    }
    else if(primeSetCnt == 3){
        //Master, Special Master
        if(hasInvert && hasFlip){
            //Store Prime
            retPrimeType = masterPRIME;
            retStoragePrime = prime;
        }
        else if(hasInvert && hasInvertFlip){
            //Store Invert
            retPrimeType = masterPRIME;
            retStoragePrime = primeInvert;
        }
        else if(hasFlip && hasInvertFlip){
            //Store Flip
            retPrimeType = masterPRIME;
            retStoragePrime = primeFlip;
        }
        else{
            log("Reached poor logic choice 93.");
            retStoragePrime = 0;
        }
    }
    else if(primeSetCnt == 4){
        //Grand Master, Special Master
        if(primeFlip == primeInvert ||
           prime == primeFlip ||
           prime == primeInvert){
            //Store the smallest of prime v primeFlip v primeInvert
            unsigned long long smallest = prime;
            smallest = smallest<primeInvert?smallest:primeInvert;
            smallest = smallest<primeFlip?smallest:primeFlip;
            //Note: May include two types..
            retPrimeType = specialMasterPRIME;
            retStoragePrime = smallest;
        }
        else{
            unsigned long long smallest = prime;
            smallest = smallest<primeInvert?smallest:primeInvert;
            smallest = smallest<primeFlip?smallest:primeFlip;
            smallest = smallest<primeInvertFlip?smallest:primeInvertFlip;
            //Store the smallest out of all 4
            retPrimeType = grandMasterPRIME;
            retStoragePrime = smallest;
        }
    }
    else{
        log("Reached poor logic choice 126.");
        retStoragePrime = 0;
    }
    *sPrime = retStoragePrime;
    return retPrimeType;
}
void PrimerTool::log(string s){
    cout<<s<<endl;
}
void PrimerTool::assertLog(bool test,string s){
    if(!test){
        cout<<s<<endl;
        cout<<"Terminating program due to above error."<<endl;
        exit(0);
    }
}
bool PrimerTool::containsPrime(unsigned long long prime){
    bool foundPrime = false;
    
    if(BINARY_SEARCH){
        foundPrime = std::binary_search(m_primeList.begin(),m_primeList.end(),prime);
    }
    else{
        std::vector<unsigned long long>::iterator it;
        it = std::find(m_primeList.begin(),m_primeList.end(),prime);
        if(it != m_primeList.end()){
            foundPrime = true;
        }
    }
    return foundPrime;
}
void PrimerTool::verifyCount(){
    unsigned long analyzedCnt =
    
    m_grandMasterPrimes.size()*4+\
    //Master
    m_masterPrimes.size()*3+m_specialMasterPrimes.size()*2+\
    //Grand
    m_grandPrimes.size()*2+m_specialGrandPrimes.size()*1+\
    //
    m_flipPrimes.size()*2+m_specialFlipPrimes.size()*1+\
    m_invertPrimes.size()*2+\
    m_nullPrimes.size();
    
    assertLog(analyzedCnt == m_primeList.size(),"Mismatch in number of primes analyzed versus counted!!");
}
#pragma mark - Machine Diagnosis
void PrimerTool::verifyMachine(){
    unsigned long long maxNumber = ULLONG_MAX;
    cout<<"Upper Limit: "<<maxNumber<<endl;
}
#pragma mark - Tests
#pragma mark Data Verification
void PrimerTool::runDataTest(){
    
    unsigned long long primeInvert = invert(4306063679,33);
    unsigned long long primeFlip = flip(4306063679,33);
    unsigned long long primeInvertFlip = invertFlip(4306063679,33);
    assertLog(primeInvert == 8578838209,"Invalid invert conversion!");
    assertLog(primeFlip == 8473881089,"Invalid flip conversion!");
    assertLog(primeInvertFlip == 4411020799,"Invalid invertFlip conversion!");
    
    
    primeInvert = invert(18446744073709551613U,64);
    primeFlip = flip(18446744073709551613U,64);
    primeInvertFlip = invertFlip(18446744073709551613U,64);
    assertLog(primeInvert == 9223372036854775811U,"Invalid invert conversion!");
    assertLog(primeFlip == 13835058055282163711U,"Invalid flip conversion!");
    assertLog(primeInvertFlip == 13835058055282163713U,"Invalid invertFlip conversion!");
    
    
    //Test unsigned long long conversion
    unsigned long long longResult;
    
    //11001001
    //201i == 10110111 == 183
    longResult = invert(201,8);
    assertLog(183 == longResult,"Invert Failed");
    //201f == 10010011 == 147
    longResult = flip(201,8);
    assertLog(147 == longResult,"Flip Failed");
    //201if == 11101101 == 237
    longResult = invertFlip(201,8);
    assertLog(237 == longResult,"Invert/Flip Failed");
    
    
    //Special Case
    //27 == 11011
    //27i == 10101 == 21
    longResult =  invert(27,5);
    assertLog(21 == longResult,"Invert Failed");
    //27f == 11011 == 27
    longResult = flip(27,5);
    assertLog(27 == longResult,"Flip Failed");
    //27if == 10101 == 21
    longResult = invertFlip(27,5);
    assertLog(21 == longResult,"Invert/Flip Failed");
    
    log("Data Test Passed.");
}

#pragma mark Unsigned Long Long
 unsigned long long PrimerTool::invert(unsigned long long number, int width){
    unsigned long long mask = powl(2,width) - 1;
    unsigned long long primeMask = powl(2,width-1) + 1;
    unsigned long long invertedNumber = (~number) & mask;
    invertedNumber = invertedNumber | primeMask;
    return invertedNumber;
}
unsigned long long PrimerTool::flip(unsigned long long number, int width){
    unsigned long long flippedNumber = 0;
    while(number > 0){
        unsigned int digit = number & 1;
        flippedNumber = flippedNumber << 1; //Ok to flip on first entry becuase initialized to '0'
        flippedNumber += digit;
        number = number >> 1;
    }
    return flippedNumber;
}
 unsigned long long PrimerTool::invertFlip(unsigned long long number,int width){
    unsigned long long invertValue = invert(number,width);
    return flip(invertValue,width);
}
