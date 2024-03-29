//
//  Primer.cpp
//  Primer
//
//  Created by Jeremy Cope on 10/11/18.
//  Copyright © 2021 Emma Technologies, L.L.C. All rights reserved.
//

#include "PrimerTool.hpp"
#include <stdio.h>
#include <iostream>
#include <iomanip> // std::setw
#include <fstream>
#include <sstream>
#include <algorithm>
#include <math.h>
#include <ctime>        // std::time
#include <cstdlib>      // std::rand, std::srand
#include <primesieve.hpp>

PrimerTool::PrimerTool(): PrimerTool(_STANDARD){}

PrimerTool::~PrimerTool(){

}
PrimerTool::PrimerTool(runtime_exe mode){
    srand ( unsigned ( time(0) ) );
    m_runMode = mode;
}
void PrimerTool::setBinaryWidth(int width){
    m_primeWidth = width;
    m_totalAnalyzedCnt = 0;
    initBuckets();
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
string PrimerTool::analyzePrimes(vector<pType>primes, int width){
    //Store the primes in data controlled storage
    m_primeList = primes;
    m_primeWidth = width;
    initBuckets();

    string result = "";
    if(m_runMode == _TWIN){
        result = analyzeTwins();
    }
    else if(m_runMode == _MASTER_SPECIAL){
        result = analyzeMasterSpecial();
    }
    else if(m_runMode == _FLIP_SPECIAL){
        result = analyzeFlipSpecial();
    }
    else{ //Default, standard analysis
        analyzePrimeNumberList();
        verifyCount(); //Will Assert if false
        result = outputResults();
    }
    return result;
}
unsigned long PrimerTool::getTotalAnalyzedCount(){
    unsigned long count = 0;
    if(m_runMode == _FILE_SEARCH){
        count = m_totalAnalyzedCnt;
    }
    else{
        count = m_primeList.size();
    }
    return count;
}
string PrimerTool::setDescription(set <pType, less <pType> > primeSet){
    string retStr = "";
    set<pType>::iterator it;
    for (it=primeSet.begin(); it!=primeSet.end(); ++it)
        retStr+=to_string(*it)+",";
    //Remove trailing comma
    retStr.erase(retStr.end());
    return retStr;
}
void PrimerTool::analyzeNextPrime(pType prime){
    pType storagePrime = 0;
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

    if(m_runMode == _FILE_SEARCH) m_totalAnalyzedCnt++;
}
void PrimerTool::analyzePrimeNumberList(){
    for_each(m_primeList.begin(), m_primeList.end(), [this](pType& prime){
        analyzeNextPrime(prime);
    });
}
primeType PrimerTool::calculatePrimeType(pType prime, pType* sPrime){
    primeType retPrimeType = unknownPRIME;
    pType retStoragePrime = 0;

    pType primeInvert = invert(prime, m_primeWidth);
    pType primeFlip = flip(prime, m_primeWidth);
    pType primeInvertFlip = invertFlip(prime, m_primeWidth);

    bool hasInvert = containsPrime(primeInvert);
    bool hasFlip = containsPrime(primeFlip);
    bool hasInvertFlip = containsPrime(primeInvertFlip);

    //Count the number of primes in the set
    int primeSetCnt = 1; //Start with atleast 1 prime (initial entry)
    if(hasInvert)primeSetCnt++;
    if(hasFlip)primeSetCnt++;
    if(hasInvertFlip)primeSetCnt++;

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
        //Master
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
            pType smallest = prime;
            smallest = smallest<primeInvert?smallest:primeInvert;
            smallest = smallest<primeFlip?smallest:primeFlip;
            //Note: May include two types..
            retPrimeType = specialMasterPRIME;
            retStoragePrime = smallest;
        }
        else{
            pType smallest = prime;
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

bool PrimerTool::containsPrime(pType prime){
    bool foundPrime = false;

    if(m_runMode == _BINARY_SEARCH || m_runMode == _STANDARD){
        foundPrime = std::binary_search(m_primeList.begin(),m_primeList.end(),prime);
    }
    else if(m_runMode == _FILE_SEARCH){
        foundPrime = searchBinaryFile(prime);
    }
    else{ //Can be explicitly used by using _BASIC runtime mode. Also used by _RANDOM during un-ordered analysis
        std::vector<pType>::iterator it;
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

    assertLog(analyzedCnt == getTotalAnalyzedCount(),"Mismatch in number of primes analyzed versus counted!!");
}
#pragma mark - Core
 pType PrimerTool::invert(pType number, int width){
    pType mask = powl(2,width) - 1;
    pType primeMask = powl(2,width-1) + 1;
    pType invertedNumber = (~number) & mask;
    invertedNumber = invertedNumber | primeMask;
    return invertedNumber;
}
pType PrimerTool::flip(pType number, int width){
    pType flippedNumber = 0;
    while(number > 0){
        unsigned int digit = number & 1;
        flippedNumber = flippedNumber << 1; //Ok to flip on first entry becuase initialized to '0'
        flippedNumber += digit;
        number = number >> 1;
    }
    return flippedNumber;
}
 pType PrimerTool::invertFlip(pType number,int width){
    pType invertValue = invert(number,width);
    return flip(invertValue,width);
}
#pragma mark - Output
string PrimerTool::generateOutput(){
    verifyCount();
    return outputResults();
}
void PrimerTool::setupDataHeaders(string filename){
    m_outputFilename = filename;
    if(LOG_DATA_FILE){
        //Write to file
        ofstream outfile;
        outfile.open(m_outputFilename);
        outfile<<"Digits,Primes,";
        if(m_runMode == _FLIP_SPECIAL){
            outfile<<"*Flip"<<endl;
        }
        else if(m_runMode == _TWIN){
            outfile<<"Twins"<<endl;
        }
        else if(m_runMode == _MASTER_SPECIAL){
            outfile<<"Count,*MasterFlip,*MasterInvertFlip,*MasterEven"<<endl;
        }
        else{ //Standard analysis output
            outfile<<"Grand Master,";
            outfile<<"Master,*Master,";
            outfile<<"Grand,*Grand,";
            outfile<<"Flip,*Flip,";
            outfile<<"Invert,";
            outfile<<"Null"<<endl;
        }
        outfile.close();
    }
}
void PrimerTool::logDataHeaders(int binaryWidth){
    uint64_t min = powl(2,binaryWidth-1);
    uint64_t max = powl(2,binaryWidth)-1; //Calculate the max bucket
    cout<<"****************************************"<<endl;
    cout<<"Binary width: "<<binaryWidth<<endl;
    if(m_runMode == _RANDOM){
        cout<<"Using numbers from: "<<min<<" to "<<max<<endl;
        cout<<"Group size: "<< to_string(primeNumbersPerGroup(binaryWidth));
    }
    else{
        cout<<"Analyzing from: "<<min<<" to "<<max<<endl;
        cout<<"Size: "<<max-min+1<<" numbers"<<endl;
    }
}
string PrimerTool::outputResults(){
    if(LOG_DATA_CONSOLE){
        string str;
        str.reserve(100);
        //Print out the sumsx
        if(m_runMode != _RANDOM) str+="Total Primes: "+ to_string(getTotalAnalyzedCount());
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
        str += "\nTotal Primes: "+to_string(getTotalAnalyzedCount());
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

    str+=","+to_string(getTotalAnalyzedCount());

    str+=","+to_string(m_grandMasterPrimes.size());

    str+=","+to_string(m_masterPrimes.size());
    str+=","+to_string(m_specialMasterPrimes.size());

    str+=","+to_string(m_grandPrimes.size());
    str+=","+to_string(m_specialGrandPrimes.size());

    str+=","+to_string(m_flipPrimes.size());
    str+=","+to_string(m_specialFlipPrimes.size());

    str+=","+to_string(m_invertPrimes.size());

    str+=","+to_string(m_nullPrimes.size());

    if(LOG_DATA_FILE){
        //Write to file
        ofstream outfile;
        outfile.open(m_outputFilename, ofstream::out | ofstream::app);
        outfile<<str<<endl;
        outfile.close();
    }

    return str;
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
#pragma mark - Machine Diagnosis
void PrimerTool::verifyMachine(int maxBinaryWidth){
    pType maxNumber = ULLONG_MAX;
    cout<<"Upper Program Limit: "<<maxNumber<<endl;
    pType maxSearch = powl(2,maxBinaryWidth);
    assertLog(maxSearch<maxNumber,"Machine cannot search for numbers this big");
}
#pragma mark - Tests
void PrimerTool::testPrimer(int maxBinaryWidth){
    verifyMachine(maxBinaryWidth);
    runDataTest();
}
#pragma mark Data Verification
void PrimerTool::runDataTest(){

    pType primeInvert = invert(4306063679,33);
    pType primeFlip = flip(4306063679,33);
    pType primeInvertFlip = invertFlip(4306063679,33);
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
    pType longResult;

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

    //Twins
    bool result;
    result = isTwinPrime(23, 31, 5);
    assertLog(result,"Twin Test Failed");
    result = isTwinPrime(23, 27, 5); //Should not be a twin prime
    assertLog(result==false,"Twin Test Failed2");

    result = isTwinPrime(53, 37, 6);
    assertLog(result,"Twin Test Failed3");
    result = isTwinPrime(53, 59, 6); //Should not be a twin prime
    assertLog(result==false,"Twin Test Failed4");

    result = isTwinPrime(89, 93, 7);
    assertLog(result,"Twin Test Failed5");
    result = isTwinPrime(89, 113, 7); //Should not be a twin prime
    assertLog(result==false,"Twin Test Failed6");

    log("Data Test Passed.");
}
#pragma mark - Random investigation
vector<pType>
PrimerTool::createRandomInput(int digits, pType bucketSize){
    //Calculate a min, max, number of elements
    pType initNumb = powl(2,digits-1);
    pType maxNumb = powl(2, digits)-1;
    //Creat array with all available candidtate (between min/max, not even)
    vector<pType> numberPool;
    for(pType number = initNumb+1; number<=maxNumb; number = number+2){
        numberPool.push_back(number);
    }

    random_shuffle ( numberPool.begin(), numberPool.end() );    //Randomize
    vector<pType> primePool(numberPool.begin(),numberPool.begin()+bucketSize); //Take Subset
    sort(primePool.begin(),primePool.end());    //Order
    return primePool;
}
pType PrimerTool::primeNumbersPerGroup(int width){
    pType values[] = {2,2,5,7,13,23,43,75,137,
                    255,464,872,1612,3030,5709,10749,20390,
                    38635,73586,140336,268216,513708,985818,1894120,
                    3645744,7027290,13561907,26207278,50697537,98182656};
    int length = (sizeof(values)/sizeof(*values));
    int index = width - 3; //We only analyze starting with width = 3 digits
    assertLog(index < length,"Unsupported length");
    pType retVal = values[index];
    return retVal;
}

#pragma mark - Flip(*) investigation
//Counts the number of Flip Specials per each group
string PrimerTool::analyzeFlipSpecial(){
    string result;
    int count = 0;
    for_each(m_primeList.begin(), m_primeList.end(), [this,&count](pType& prime){
        pType primeInvert = invert(prime, m_primeWidth);
        pType primeFlip = flip(prime, m_primeWidth);
        pType primeInvertFlip = invertFlip(prime, m_primeWidth);


        bool hasInvert = containsPrime(primeInvert);
        bool hasFlip = containsPrime(primeFlip);
        bool hasInvertFlip = containsPrime(primeInvertFlip);

        //If this meets the condiditon for a flip*
        if(prime == primeFlip && hasFlip == true && hasInvert == false && hasInvertFlip == false){
            count++;
        }
    });
    return outputFlipSpecial(count);
}
string PrimerTool::outputFlipSpecial(int count){
    //Verify Conjecture 1
    if(m_primeWidth%2==0 && count!=0){
        cout<<"There exists no flip special prime number with binary even width."<<endl;
        exit(10);
    }

    if(LOG_DATA_CONSOLE){
        string str;
        str.reserve(100);
        //Print out the sumsx
        str+="Total Primes: "+ to_string(getTotalAnalyzedCount());
        str+="\nSpecial Flip Primes: " + to_string(count);
        str+="\n----------------------------------------";
        log(str);
    }

    //Create the output string
    string str;
    str.reserve(300);

    //Digits,Number of Primes,
    //Special Flip Primes,
    str+=to_string(m_primeWidth);
    str+=","+to_string(getTotalAnalyzedCount());
    str+=","+to_string(count);

    if(LOG_DATA_FILE){
        //Write to file
        ofstream outfile;
        outfile.open(m_outputFilename, ofstream::out | ofstream::app);
        outfile<<str<<endl;
        outfile.close();
    }

    return str;
}
#pragma mark - Master(*) investigation
string PrimerTool::analyzeMasterSpecial(){
    string result;

    set <pType, less <pType> > masterSpecialPrimes_Flip; //Flip == self || Invert == self // Only happens for Odd, invert never happens
    set <pType, less <pType> > masterSpecialPrimes_InvertFlip; //InvertFlip == self //Only happens for Even

    set <pType, less <pType> > masterSpecialPrimes_even; //Flip == self, only for even binary width - Conjecture 2: Never observed to happen

    for_each(m_primeList.begin(), m_primeList.end(), [this,&masterSpecialPrimes_Flip,&masterSpecialPrimes_InvertFlip,&masterSpecialPrimes_even](pType& prime){
        pType primeInvert = invert(prime, m_primeWidth);
        pType primeFlip = flip(prime, m_primeWidth);
        pType primeInvertFlip = invertFlip(prime, m_primeWidth);

        //Use the smallest value as the storage prime
        pType storagePrime = prime;
        storagePrime = storagePrime<primeInvert?storagePrime:primeInvert;
        storagePrime = storagePrime<primeFlip?storagePrime:primeFlip;

        bool hasInvert = containsPrime(primeInvert);
        bool hasFlip = containsPrime(primeFlip);
        bool hasInvertFlip = containsPrime(primeInvertFlip);

        //If this meets the condiditon for a Master*
        if(hasInvert && hasFlip && hasInvertFlip){
            if(prime == primeInvertFlip){
                masterSpecialPrimes_InvertFlip.insert(storagePrime);
            }
            else if(prime == primeInvert || prime == primeFlip){
                masterSpecialPrimes_Flip.insert(storagePrime);
            }
        }
        //Lets do a different type of analysis
        //Are there any even digits and flip(x)=x, flip is noop?
        //Seems to only occur for odds
        if(m_primeWidth%2==0){
            if(prime == primeFlip){
                masterSpecialPrimes_even.insert(storagePrime);
            }
        }
    });
    unsigned long count = masterSpecialPrimes_Flip.size()+masterSpecialPrimes_InvertFlip.size();
    //result = to_string(m_primeWidth)+","+to_string(count)+","+to_string(masterSpecialPrimes.size())+","+to_string(masterSpecialPrimes_Flip.size())+","+to_string(masterSpecialPrimes_even.size());

    return outputMasterSpecial(count, masterSpecialPrimes_Flip.size(), masterSpecialPrimes_InvertFlip.size(), masterSpecialPrimes_even.size());
}
string PrimerTool::outputMasterSpecial(unsigned long count, unsigned long masterSpecialFlip, unsigned long masterSpecialInvertFlip, unsigned long masterSpecialEven){
    //Verify Conjecture 2
    if(m_primeWidth%2==0 && masterSpecialEven!=0){
        exit(12);
    }


    if(LOG_DATA_CONSOLE){
        string str;
        str.reserve(100);
        //Print out the sumsx
        str+="Total Primes: "+ to_string(getTotalAnalyzedCount());
        str+="\nCount: " + to_string(count);
        str+="\n*Master (Flip/Invert Identity): " + to_string(masterSpecialFlip);
        str+="\n*Master (InvertFlip Identity): " + to_string(masterSpecialInvertFlip);
        str+="\n*Master (Flip Identity w/ Even Width): " + to_string(masterSpecialEven);
        str+="\n----------------------------------------";
        log(str);
    }

    //Create the output string
    string str;
    str.reserve(300);

    //Digits,Number of Primes,
    //Count,

    str+=to_string(m_primeWidth);
    str+=","+to_string(getTotalAnalyzedCount());
    str+=","+to_string(count);
    str+=","+to_string(masterSpecialFlip);
    str+=","+to_string(masterSpecialInvertFlip);
    str+=","+to_string(masterSpecialEven);

    if(LOG_DATA_FILE){
        //Write to file
        ofstream outfile;
        outfile.open(m_outputFilename, ofstream::out | ofstream::app);
        outfile<<str<<endl;
        outfile.close();
    }

    return str;
}
#pragma mark - Twin Prime investigation
string PrimerTool::analyzeTwins(){
    string result;
    int count = 0;
    for_each(m_primeList.begin(), m_primeList.end(), [this,&count](pType& primeA){
        for_each(m_primeList.begin(), m_primeList.end(), [this,&count,&primeA](pType& primeB){
            if(primeA != primeB){
                if(isTwinPrime(primeA, primeB, m_primeWidth)) count++;
            }
        });
    });
    //We divide by 2 because each match was paired twice (not efficient search)
    return outputTwinInvestigation(count/2);
}
string PrimerTool::outputTwinInvestigation(int count){

    if(LOG_DATA_CONSOLE){
        string str;
        str.reserve(100);
        //Print out the sumsx
        str+="Total Primes: "+ to_string(getTotalAnalyzedCount());
        str+="\nTwin Primes: " + to_string(count);
        str+="\n----------------------------------------";
        log(str);
    }

    //Create the output string
    string str;
    str.reserve(300);

    //Digits,Number of Primes,
    //Special Flip Primes,
    str+=to_string(m_primeWidth);
    str+=","+to_string(getTotalAnalyzedCount());
    str+=","+to_string(count);

    if(LOG_DATA_FILE){
        //Write to file
        ofstream outfile;
        outfile.open(m_outputFilename, ofstream::out | ofstream::app);
        outfile<<str<<endl;
        outfile.close();
    }

    return str;
}
bool PrimerTool::isTwinPrime(pType prime1, pType prime2, int width){
    //Twin prime is defined as having only one binary digit different
    //In the case of primer research, we neglect MSB and LSB
    pType mask = powl(2,width-1) - 1;
    pType primeA = (prime1 & mask) >> 1;
    pType primeB = (prime2 & mask) >> 1;
    //int result = common_bits(primeA, primeB);
    pType temp = primeA^primeB;
    int result = countBits(temp);
    return (result == 1);
}
//Recursively count the number of bits that are 1
int PrimerTool::countBits(pType a){
    if (a == 0) return 0;
    return ((a&1) == 1) + countBits(a>>1);
}

#pragma mark - Binary File Storage/Search
void PrimerTool::createBinaryFile(int width){
    primesieve::iterator it;

    string outputFileName = string(OUTPUT_DIR)+"LargePrimeFile"+to_string(width)+".bin";
    pType number=0;

    FILE* fp = fopen(outputFileName.c_str(), "wb");
    while(number<powl(2,width-1)){
        number = it.next_prime();
    }
    while(number<powl(2,width)){
        fwrite(&number, 1, sizeof(pType), fp);
        number = it.next_prime();
    }
    fclose(fp);
}
//Search cache eleminates the first x steps of binary file lookup, having pre-populated the values in cache. Minimizing file i/o.
void PrimerTool::initializeBinaryFileSearch(int width){
    setBinaryWidth(width);

    string inputFileName = string(OUTPUT_DIR)+"LargePrimeFile"+to_string(m_primeWidth)+".bin";

    m_fp = fopen(inputFileName.c_str(), "rb");
    assert(m_fp);

    long endIndex = 0;
    long pos;
    pType buffer[1];
    int bufferSize = sizeof(pType);
    pType mask = powl(2,m_primeWidth) - 1;

    //Seek to middle
    fseek(m_fp, 0, SEEK_END);
    pos = ftell(m_fp);
    endIndex = pos - bufferSize;

    long stepSize = endIndex/(FILE_BUFFER_SEARCH_SIZE-1);
    //Ensure step size is a multipe of bufferSize
    stepSize = stepSize - stepSize%bufferSize;

    for(int count = 0;count < FILE_BUFFER_SEARCH_SIZE-1; count++){
        long fileIndex = stepSize*count;
        fseek(m_fp, fileIndex, SEEK_SET); // seek to begining
        fread(buffer, 1, sizeof(pType), m_fp);
        m_BSF_values[count] = buffer[0] & mask;
        m_BSF_indexes[count] = fileIndex;
    }
    //Ensure the last index is correctly populated
    fseek(m_fp, endIndex, SEEK_SET); // seek to begining
    fread(buffer, 1, sizeof(pType), m_fp);
    m_BSF_values[FILE_BUFFER_SEARCH_SIZE-1] = buffer[0] & mask;
    m_BSF_indexes[FILE_BUFFER_SEARCH_SIZE-1] = endIndex;

    //Keep the file reference open so we don't open/close too frequently when searching the file
}
void PrimerTool::testFile(int width){
    string outputFileName = string(OUTPUT_DIR)+"LargePrimeFile"+to_string(width)+".bin";

    FILE* fp = fopen(outputFileName.c_str(), "rb");
    long pos;
    long endIndex;
    pType buffer[1];
    int bufferSize = sizeof(pType);

    //End index
    fseek(fp, 0, SEEK_END);
    pos = ftell(fp);
    cout<<"Filesize: "<<pos<<" size."<<endl;
    endIndex = pos - bufferSize;
    int count=0;
    pos = 0;
    while(pos<=endIndex){
        fseek(fp, pos, SEEK_SET); // seek to begining
        fread(buffer, 1, sizeof(pType), fp);
        pos+=bufferSize;
        count++;
    }
    cout<<"There were "<<count<<" primes."<<endl;
    fclose(fp);
}
void PrimerTool::useSearchCache(pType searchNumber,
                                pType* start, pType* middle, pType* end,
                                long* startIndex, long* middleIndex, long* endIndex){
    long lowerIndex = 0;
    long upperIndex = FILE_BUFFER_SEARCH_SIZE-1;
    long midIndex = (upperIndex-lowerIndex)/2;
    bool set = false;

    //for(int i=0;i<FILE_BUFFER_SEARCH_SIZE-1 && !set;i++){
    while(!set){
        if(searchNumber > m_BSF_values[midIndex]){
            lowerIndex = midIndex;
            upperIndex = upperIndex;
        }
        else{
            lowerIndex = lowerIndex;
            upperIndex = midIndex;
        }
        midIndex = (upperIndex-lowerIndex)/2 + lowerIndex;
        if((upperIndex-lowerIndex)<=3){
            *start = m_BSF_values[lowerIndex];
            *middle = m_BSF_values[midIndex];
            *end = m_BSF_values[upperIndex];
            *startIndex = m_BSF_indexes[lowerIndex];
            *middleIndex = m_BSF_indexes[midIndex];
            *endIndex = m_BSF_indexes[upperIndex];
            set = true;
        }
    }
}
bool PrimerTool::searchBinaryFile(pType searchNumber){
    assert(m_fp);

    pType start = 0;
    pType middle = 0;
    pType end = 0;

    long startIndex = 0;
    long middleIndex = 0;
    long endIndex = 0;

    useSearchCache(searchNumber, &start, &middle, &end, &startIndex, &middleIndex, &endIndex);

    pType buffer[1];
    int bufferSize = sizeof(pType);
    pType mask = powl(2,m_primeWidth) - 1;

    bool found = false;
    bool stop = false;
    while (!found && !stop){

        if(searchNumber == start || searchNumber == middle || searchNumber == end){
            found = true;
        }
        else {
            if(searchNumber > middle){
                startIndex = middleIndex;
                endIndex = endIndex;
            }
            else{
                startIndex = startIndex;
                endIndex = middleIndex;
            }
            //Recalculate the middle index
            long tempindex = ((endIndex+bufferSize)-startIndex);
            tempindex = tempindex/(bufferSize);
            tempindex = tempindex/2;
            tempindex = tempindex*(bufferSize);
            middleIndex = startIndex+tempindex;

            //Read Values
            fseek(m_fp, startIndex, SEEK_SET); // seek to begining
            fread(buffer, 1, sizeof(pType), m_fp);
            start = buffer[0] & mask;

            fseek(m_fp, middleIndex, SEEK_SET); // seek to middle
            fread(buffer, 1, sizeof(pType), m_fp);
            middle = buffer[0] & mask;

            fseek(m_fp, endIndex, SEEK_SET); // seek to end
            fread(buffer, 1, sizeof(pType), m_fp);
            end = buffer[0] & mask;

            if(middle == start || middle == end || searchNumber < start || searchNumber > end){
                stop = true;
            }
        }
    }
    return found;
}
