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
    //Verification
    void verifyMachine();
    //Tests
    void runDataTest();
    void runPerformaceTest();
    primeType calculatePrimeType(unsigned long long prime, unsigned long long* sPrime);
    bool containsPrime(unsigned long long prime);
    void verifyCount();
    void analyzePrimeNumberList();
    void initBuckets();
    string analyzePrimes(vector<unsigned long long>primes, int width);
    string outputResults();
    string setDescription(set <unsigned long long, less <unsigned long long> > primeSet);
    
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
    
    void log(string s);
    void assertLog(bool test,string s);
};





#endif /* Primer_hpp */
