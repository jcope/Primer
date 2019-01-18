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
#include <vector>
#include <set>

typedef unsigned long long pType;

using namespace std;

class PrimerTool   {
    
public:
    PrimerTool();
    ~PrimerTool();
    void testPrimer();
    
    bool searchBinaryFile(int width,pType number);
    void createBinaryFile(int width);
    
    //Main utility function
    string analyzePrimes(vector<pType>primes, int width);
    
    //Twin Primes
    string analyzePrimes_Twins(vector<pType>primes, int width);
    
    //Verify FlipSpecial Conjecture
    string analyzePrimes_FlipSpecial(vector<pType>primes, int width);
    //Random Analysis
    vector<pType> createRandomInput(int digits, pType bucketSize);
    pType primeNumbersPerGroup(int width);
    //Verify MasterSpecial Conjecture
    string analyzePrimes_MasterSpecial(vector<pType>primes, int width);
    
private:                      // begin private section
    int m_primeWidth;
    vector<pType> m_primeList;
    
    set <pType, less <pType> > m_grandMasterPrimes; //Flip, Inverse, and FlipInverse unique primes
    set <pType, less <pType> > m_masterPrimes; //Flip and Inverse are unique
    set <pType, less <pType> > m_specialMasterPrimes; //Flip and inverse are prime, but equal
    
    set <pType, less <pType> > m_grandPrimes; //Flip/Invert
    set <pType, less <pType> > m_specialGrandPrimes; //Flip/Invert; Flip == Invert
    
    set <pType, less <pType> > m_flipPrimes; //Flip
    set <pType, less <pType> > m_specialFlipPrimes; //Flip == self
    
    set <pType, less <pType> > m_invertPrimes; //Invert
    
    set <pType, less <pType> > m_nullPrimes; //None of the above
    
    pType invert(pType number, int width);
    pType flip(pType number, int width);
    pType invertFlip(pType number, int width);
    int common_bits(pType a, pType b);
    int countBits(pType a);
    
    void initBuckets();
    bool containsPrime(pType prime);
   
    void analyzePrimeNumberList();
    string analyzeFlipSpecial();
    string analyzeMasterSpecial();
    string analyzeTwins();
    
    primeType calculatePrimeType(pType prime, pType* sPrime);
    bool isTwinPrime(pType prime1, pType prime2, int width);
    
    void verifyCount();
    
    string outputResults();
    string setDescription(set <pType, less <pType> > primeSet);
    
    void log(string s);
    void assertLog(bool test,string s);
    //Verification
    void verifyMachine();
    //Tests
    void runDataTest();
    void runPerformaceTest();
};





#endif /* Primer_hpp */
