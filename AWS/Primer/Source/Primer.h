//
//  Primer.h
//  Primer
//
//  Created by Jeremy Cope on 3/23/16.
//  Copyright © 2016 Emma Technologies, L.L.C. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Primer : NSObject

//Tranformation on Prime Numbers
-(NSString*)binaryStringFromInteger:(unsigned long long)number numDigits:(int)width;

-(NSString*)invertedBinaryStringFromInteger:(unsigned long long)number numDigits:(int)width;
-(NSString*)flippedBinaryStringFromInteger:(unsigned long long)number numDigits:(int)width;
-(NSString*)invertedFlippedBinaryStringFromInteger:(unsigned long long)number numDigits:(int)width;

//Analyze Prime Number Set
//
-(NSString*)analyzePrimeNumberList:(NSArray*)primes width:(int)width;

//Threads
-(NSString*)analyzePrimeNumberList_Threaded:(NSArray*)primes width:(int)width;

//Verification
-(void)verifyMachine;
//Tests
-(void)runDataTest;
-(void)runPerformaceTest;

@end
