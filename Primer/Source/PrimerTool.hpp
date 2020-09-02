//
//  Primer.hpp
//  Primer
//
//  Created by Jeremy Cope on 10/11/18.
//  Copyright © 2018 Emma Technologies, L.L.C. All rights reserved.
//

#ifndef PrimerTool_hpp
#define PrimerTool_hpp

#include "Config.h"
#include <string>
#include <vector>
#include <set>


typedef unsigned long long pType;

typedef enum{
    grandMasterPRIME,
    masterPRIME,
    specialMasterPRIME,
    grandPRIME,
    specialGrandPRIME,
    flipPRIME,
    specialFlipPRIME,
    invertPRIME,
    nullPRIME,
    unknownPRIME,
}primeType;


using namespace std;

class PrimerTool   {
    
public:
    PrimerTool();
    PrimerTool(runtime_exe mode);
    ~PrimerTool();
    void testPrimer(int maxBinaryWidth);
    
    void setupDataHeaders(string filename);
    void logDataHeaders(int binaryWidth);
    void setBinaryWidth(int width);
    string generateOutput();
    void printProgress(time_t startTime);
    void testPerformance(vector<pType>primes, int width);
    
    //Main utility function
    string analyzePrimes(vector<pType>primes, int width);
    
    void createBinaryFile(int width);
    void initializeBinaryFileSearch(int width);
    void testFile(int width);
    void analyzeNextPrime(pType prime);
    
    //Twin Primes
    string analyzePrimes_Twins(vector<pType>primes, int width);
    
    //Verify FlipSpecial Conjecture
    string analyzePrimes_FlipSpecial(vector<pType>primes, int width);
    //Random Analysis
    vector<pType> createRandomInput(int digits, pType bucketSize);
    pType primeNumbersPerGroup(int width);
    //Verify MasterSpecial Conjecture
    string analyzePrimes_MasterSpecial(vector<pType>primes, int width);
    
private:
    runtime_exe m_runMode;
    int m_primeWidth;
    vector<pType> m_primeList;
    string m_outputFilename;
    int m_primeGroupEstimate; //Used for progress indicator on file search
    
    set <pType, less <pType> > m_grandMasterPrimes; //Flip, Inverse, and FlipInverse unique primes
    set <pType, less <pType> > m_masterPrimes; //Flip and Inverse are unique
    set <pType, less <pType> > m_specialMasterPrimes; //Flip and inverse are prime, but equal
    set <pType, less <pType> > m_grandPrimes; //Flip/Invert
    set <pType, less <pType> > m_specialGrandPrimes; //Flip/Invert; Flip == Invert
    set <pType, less <pType> > m_flipPrimes; //Flip
    set <pType, less <pType> > m_specialFlipPrimes; //Flip == self
    set <pType, less <pType> > m_invertPrimes; //Invert
    set <pType, less <pType> > m_nullPrimes; //None of the above
    
    //Core utility functions
    pType invert(pType number, int width);
    pType flip(pType number, int width);
    pType invertFlip(pType number, int width);
    primeType calculatePrimeType(pType prime, pType* sPrime);
    
    void initBuckets();
    void estimateGroupSize();
    bool containsPrime(pType prime);
    
    void analyzePrimeNumberList();
    unsigned long getTotalAnalyzedCount();
    
    //File search utilties
    unsigned long m_totalAnalyzedCnt;
    FILE* m_fp;
    pType m_BSF_values[FILE_BUFFER_SEARCH_SIZE];
    long m_BSF_indexes[FILE_BUFFER_SEARCH_SIZE];
    bool searchBinaryFile(pType number);
    void useSearchCache(pType searchNumber,
                       pType* start, pType* middle, pType* end,
                       long* startIndex, long* middleIndex, long* endIndex);
        
    //Twin investigation
    string analyzeTwins();
    string outputTwinInvestigation(int count);
    int common_bits(pType a, pType b);
    int countBits(pType a);
    bool isTwinPrime(pType prime1, pType prime2, int width);
    
    //Other investigations
    //Conjecture 1
    string analyzeFlipSpecial();
    string outputFlipSpecial(int count);
    //Conjecture 2
    string analyzeMasterSpecial();
    string outputMasterSpecial(unsigned long count, unsigned long masterSpecialFlip, unsigned long masterSpecialInvertFlip, unsigned long masterSpecialEven);
    
    void verifyCount();
    string outputResults();
    string setDescription(set <pType, less <pType> > primeSet);
    
    void consoleLog(string s);
    void assertLog(bool test,string s);
    
    //Verification
    void verifyMachine(int maxBinaryWidth);
    //Tests
    void runDataTest();
    void runPerformaceTest();
};

#endif /* Primer_hpp */
