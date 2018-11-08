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

using namespace std;

class PrimerTool   {
    
public:
    PrimerTool();
    ~PrimerTool();
    void testPrimer();
    
    //Main utility function
    string analyzePrimes(vector<unsigned long long>primes, int width);
    
    //Twin Primes
    string analyzePrimes_Twins(vector<unsigned long long>primes, int width);
    
    //Verify FlipSpecial Conjecture
    string analyzePrimes_FlipSpecial(vector<unsigned long long>primes, int width);
    //Random Analysis
    vector<unsigned long long> createRandomInput(int digits, unsigned long long bucketSize);
    unsigned long long primeNumbersPerGroup(int width);
    
    
private:                      // begin private section
    int m_primeWidth;
    vector<unsigned long long> m_primeList;
    
    set <unsigned long long, less <unsigned long long> > m_grandMasterPrimes; //Flip, Inverse, and FlipInverse unique primes
    set <unsigned long long, less <unsigned long long> > m_masterPrimes; //Flip and Inverse are unique
    set <unsigned long long, less <unsigned long long> > m_specialMasterPrimes; //Flip and inverse are prime, but equal
    
    set <unsigned long long, less <unsigned long long> > m_grandPrimes; //Flip/Invert
    set <unsigned long long, less <unsigned long long> > m_specialGrandPrimes; //Flip/Invert; Flip == Invert
    
    set <unsigned long long, less <unsigned long long> > m_flipPrimes; //Flip
    set <unsigned long long, less <unsigned long long> > m_specialFlipPrimes; //Flip == self
    
    set <unsigned long long, less <unsigned long long> > m_invertPrimes; //Invert
    
    set <unsigned long long, less <unsigned long long> > m_nullPrimes; //None of the above
    
    unsigned long long invert(unsigned long long number, int width);
    unsigned long long flip(unsigned long long number, int width);
    unsigned long long invertFlip(unsigned long long number, int width);
    int common_bits(unsigned long long a, unsigned long long b);
    int countBits(unsigned long long a);
    
    void initBuckets();
    bool containsPrime(unsigned long long prime);
   
    void analyzePrimeNumberList();
    string analyzeFlipSpecial();
    string analyzeTwins();
    
    primeType calculatePrimeType(unsigned long long prime, unsigned long long* sPrime);
    bool isTwinPrime(unsigned long long prime1, unsigned long long prime2, int width);
    
    void verifyCount();
    
    string outputResults();
    string setDescription(set <unsigned long long, less <unsigned long long> > primeSet);
    
    void log(string s);
    void assertLog(bool test,string s);
    //Verification
    void verifyMachine();
    //Tests
    void runDataTest();
    void runPerformaceTest();
};





#endif /* Primer_hpp */
