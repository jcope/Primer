//
//  Primer.h
//  Primer
//
//  Created by Jeremy Cope on 3/23/16.
//  Copyright © 2016 Emma Technologies, L.L.C. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Primer : NSObject{
    int m_threadCount;
    int m_primeWidth;
    
    NSArray* m_primeList;
    NSMutableArray* m_grandMasterPrimes; //Flip, Inverse, and FlipInverse unique primes
    NSMutableArray* m_masterPrimes; //Flip and Inverse are unique
    NSMutableArray* m_specialMasterPrimes; //Flip and inverse are prime, but equal
    
    NSMutableArray* m_grandPrimes; //Flip/Invert
    NSMutableArray* m_specialGrandPrimes; //Flip/Invert; Flip == Invert
    
    NSMutableArray* m_flipPrimes; //Flip
    NSMutableArray* m_specialFlipPrimes; //Flip == self
    
    NSMutableArray* m_invertPrimes; //Invert
    
    NSMutableArray* m_nullPrimes; //None of the above
}


//Tranformation on Prime Numbers
-(NSString*)binaryStringFromInteger:(unsigned long long)number numDigits:(int)width;

-(NSString*)invertedBinaryStringFromInteger:(unsigned long long)number numDigits:(int)width;
-(NSString*)flippedBinaryStringFromInteger:(unsigned long long)number numDigits:(int)width;
-(NSString*)invertedFlippedBinaryStringFromInteger:(unsigned long long)number numDigits:(int)width;

//Analyze Prime Number Set
//Sequential
-(NSString*)analyzePrimeNumberList:(NSArray*)primes width:(int)width;

//Threads
-(NSString*)analyzePrimeNumberList_Threaded:(NSArray*)primes width:(int)width;
-(NSString*)analyzePrimeNumberList_NoThread:(NSArray*)primes width:(int)width;
//Verification
-(void)verifyMachine;
//Tests
-(void)runDataTest;
-(void)runPerformaceTest;
//Data generation
-(NSArray*)createRandomInput:(int)digits numPrimes:(unsigned long long)bucketSize;
-(unsigned long long)primeNumbersPerGroup:(int)width;

+(NSMutableArray *)randomSortArray:(NSMutableArray *)array;

//Flip Tests
-(NSString*)analyzePrimeNumberListForFlip_NoThread:(NSArray*)primes width:(int)width;

//@property NSLock *dataLock;
@property int m_threadCount;
@property int m_primeWidth;

@property (nonatomic, retain) NSArray* m_primeList;

@property (nonatomic, retain) NSMutableArray* m_grandMasterPrimes; //Flip, Inverse, and FlipInverse unique primes

@property (nonatomic, retain) NSMutableArray* m_masterPrimes; //Flip and Inverse are unique
@property (nonatomic, retain) NSMutableArray* m_specialMasterPrimes; //Flip and inverse are prime, but equal

@property (nonatomic, retain) NSMutableArray* m_grandPrimes; //Flip/Invert
@property (nonatomic, retain) NSMutableArray* m_specialGrandPrimes; //Flip/Invert; Flip == Invert

@property (nonatomic, retain) NSMutableArray* m_flipPrimes; //Flip
@property (nonatomic, retain) NSMutableArray* m_specialFlipPrimes; //Flip == self

@property (nonatomic, retain) NSMutableArray* m_invertPrimes; //Invert

@property (nonatomic, retain) NSMutableArray* m_nullPrimes; //None of the above

@end
