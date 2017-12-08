//
//  Primer.m
//  Primer
//
//  Created by Jeremy Cope on 3/23/16.
//  Copyright © 2016 Emma Technologies, L.L.C. All rights reserved.
//

#import "Primer.h"
#import "Config.h"
#import "NSString+FileIO.h"
#import "NSArray+PrimeDesc.h"

@interface Primer ()
@property NSLock *dataLock;
@property NSUInteger threadCount;
@end


@implementation Primer

-(instancetype)init{
    if (self = [super init]) {
        _dataLock = [[NSLock alloc] init];
        _threadCount = 0;
    }
    return self;
}
#pragma mark - Transform
#pragma mark String
-(NSString*)binaryStringFromInteger:(unsigned long long)number numDigits:(int)width{
    char buffer[width+1];
    memset(buffer, 0, width+1);
    
    int binaryDigit = width - 1;
    unsigned long long integer = number;
    
    while( binaryDigit >= 0 ){
        buffer[binaryDigit--] = (integer & 1) ? '1' : '0';
        integer = integer >> 1;
    }
    return [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
}

-(NSString*)invertedBinaryStringFromInteger:(unsigned long long)number numDigits:(int)width{
    //Invert
    unsigned long long mask = powl(2,width-1) + 1;
    unsigned long long invertedNumber = (~number) | mask;
    
    //return string format
    return [self binaryStringFromInteger:invertedNumber numDigits:width];
}
-(NSString*)flippedBinaryStringFromInteger:(unsigned long long)number numDigits:(int)width{
    char buffer[width+1];
    memset(buffer, 0, width+1);
    
    int binaryDigit = 0;
    unsigned long long integer = number;
    
    while( binaryDigit < width ){
        buffer[binaryDigit++] = (integer & 1) ? '1' : '0';
        integer = integer >> 1;
    }
    buffer[binaryDigit]= '\0';
    
    return [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
}
-(NSString*)invertedFlippedBinaryStringFromInteger:(unsigned long long)number numDigits:(int)width{
    //Invert First
    unsigned long long mask = powl(2,width-1) + 1;
    unsigned long long invertedNumber = (~number) | mask;
    //Return flipped
    return [self flippedBinaryStringFromInteger:invertedNumber numDigits:width];
}
#pragma mark Unsigned Long Long
-(unsigned long long)invert:(unsigned long long)number width:(int)width{
    unsigned long long mask = powl(2,width) - 1;
    unsigned long long primeMask = powl(2,width-1) + 1;
    unsigned long long invertedNumber = (~number) & mask;
    invertedNumber = invertedNumber | primeMask;
    return invertedNumber;
}
-(unsigned long long)flip:(unsigned long long)number width:(int)width{
    unsigned long long flippedNumber = 0;
    while(number > 0){
        unsigned int digit = number & 1;
        flippedNumber = flippedNumber << 1; //Ok to flip on first entry becuase initialized to '0'
        flippedNumber += digit;
        number = number >> 1;
    }
    return flippedNumber;
}
-(unsigned long long)invertFlip:(unsigned long long)number width:(int)width{
    unsigned long long invert = [self invert:number width:width];
    return [self flip:invert width:width];
}
#pragma mark - Analyze
#define NUM_THREADS 4
-(NSString*)analyzePrimeNumberList_Threaded:(NSArray*)primes width:(int)width{
    //Store the primes in data controlled storage
    
    NSUInteger range = [primes count] / NUM_THREADS;
    NSUInteger lowerRange = 0;
    
    while(lowerRange < [primes count]){
        
        NSUInteger rangeCalculated = range;
        if(lowerRange+range > [primes count]){
            rangeCalculated = [primes count] - lowerRange; //Use the difference as the range for the last bucket
        }
        NSRange r = NSMakeRange(lowerRange, rangeCalculated);
        
        NSArray* subset = [primes subarrayWithRange:r];
    
    
        //Spawn a thread with a subset of primes as its search list
        [self performSelectorInBackground:@selector(analyzePrimeNumberList_Search:)
                               withObject:subset];
    
        [_dataLock lock];
        _threadCount++;
        [_dataLock unlock];
        lowerRange+=range;
    }
    //Wait until all threads are done
    while(_threadCount>0){
        
    }
    return @"";
}
-(void)analyzePrimeNumberList_Search:(NSArray*)primesSubset{
    //For now just print out the prime subset
    for(NSNumber* p in primesSubset){
        unsigned long long prime = [p unsignedLongLongValue];
        //NSLog(@"%llu",prime);
    }
    
    
    [_dataLock lock];
    _threadCount--;
    [_dataLock unlock];
    
}


//Returns formatted summary
-(NSString*)analyzePrimeNumberList:(NSArray*)primes width:(int)width{
    
    NSMutableArray* primeList = [NSMutableArray arrayWithArray:primes];
    
    //Special is a modifier, signifying there is identity (reflects to self)
    //Special indicates an (identity) prime, ie a non-unique prime is created in the set
    NSMutableArray* grandMasterPrimes = [NSMutableArray arrayWithCapacity:[primes count]]; //Flip, Inverse, and FlipInverse unique primes
    
    NSMutableArray* masterPrimes = [NSMutableArray arrayWithCapacity:[primes count]]; //Flip and Inverse are unique
    NSMutableArray* specialMasterPrimes = [NSMutableArray arrayWithCapacity:[primes count]]; //Flip and inverse are prime, but equal

    NSMutableArray* grandPrimes = [NSMutableArray arrayWithCapacity:[primes count]]; //Flip/Invert
    NSMutableArray* specialGrandPrimes = [NSMutableArray arrayWithCapacity:[primes count]]; //Flip/Invert; Flip == Invert

    NSMutableArray* flipPrimes = [NSMutableArray arrayWithCapacity:[primes count]]; //Flip
    NSMutableArray* specialFlipPrimes = [NSMutableArray arrayWithCapacity:[primes count]]; //Flip == self
    
    NSMutableArray* invertPrimes = [NSMutableArray arrayWithCapacity:[primes count]]; //Invert

    NSMutableArray* nullPrimes = [NSMutableArray arrayWithCapacity:[primes count]]; //None of the above
    
    while([primeList count] > 0){
        NSNumber* p = [primeList objectAtIndex:0];
        unsigned long long prime = [p unsignedLongLongValue];
        unsigned long long primeInvert = [self invert:prime width:width];
        unsigned long long primeFlip = [self flip:prime width:width];
        unsigned long long primeInvertFlip = [self invertFlip:prime width:width];
        
        
        bool hasInvert = [self containsPrime:primeList prime:@(primeInvert)];
        bool hasFlip = [self containsPrime:primeList prime:@(primeFlip)];
        bool hasInvertFlip = [self containsPrime:primeList prime:@(primeInvertFlip)];
        
        //Count the number of primes in the set
        int primeSetCnt = 1; //Start with atleast 1 prime (initial entry)
        if(hasInvert)primeSetCnt++;
        if(hasFlip)primeSetCnt++;
        if(hasInvertFlip)primeSetCnt++;
        
        //TODO: Add only the lowest value
        unsigned long long basePrime = 0;
        basePrime = [self calculateBasePrime:prime
                                 invertPrime:(hasInvert?primeInvert:0)
                                   flipPrime:(hasFlip?primeInvertFlip:0)
                             invertFlipPrime:(hasInvertFlip?primeInvertFlip:0)];
        basePrime = prime;
        
        //Categorize the prime
        if(primeSetCnt == 1){
            [nullPrimes addObject:@(prime)];
        }
        else if (primeSetCnt == 2){
            //Flip, Invert, Special Flip, Grand, Special Grand
            if(hasFlip){
                if(prime == primeFlip){
                    [specialFlipPrimes addObject:@(prime)];
                }
                else{
                    [flipPrimes addObject:@(prime)];
                }
            }
            else if(hasInvert){
                [invertPrimes addObject:@(prime)];
            }
            else if(hasInvertFlip){
                if(prime == primeInvertFlip){
                    [specialGrandPrimes addObject:@(prime)];
                }
                else{
                    [grandPrimes addObject:@(prime)];
                }
            }
            else{
                NSAssert(false,@"Reached poor logic choice 23.");
            }
            
        }
        else if(primeSetCnt == 3){
            //Master, Special Master
            if(hasInvert && hasFlip){
                //Store Prime
                [masterPrimes addObject:@(prime)];
            }
            else if(hasInvert && hasInvertFlip){
                //Store Invert
                [masterPrimes addObject:@(primeInvert)];
            }
            else if(hasFlip && hasInvertFlip){
                //Store Flip
                [masterPrimes addObject:@(primeFlip)];
            }
            else{
                NSAssert(false,@"Reached poor logic choice 93.");
            }
        }
        else if(primeSetCnt == 4){
            //Grand Master, Special Master
            if(primeFlip == primeInvert ||
               prime == primeFlip ||
               prime == primeInvert){
                [specialMasterPrimes addObject:@(prime<primeFlip?prime:primeFlip)];
            }
            else{
                unsigned long long largest = prime;
                largest = largest<primeInvert?primeInvert:largest;
                largest = largest<primeFlip?primeFlip:largest;
                largest = largest<primeInvertFlip?primeInvertFlip:largest;
                [grandMasterPrimes addObject:@(largest)];
            }
        }
        //TODO: May not want to remove during the threaded operation
        //Removing might spead up the search, ie create a smaller search pool
        //However locking the set to remove data would decrease performance
        
        //Reset the prime list
        [primeList removeObject:@(prime)];
        if(hasInvert) [primeList removeObject:@(primeInvert)];
        if(hasFlip) [primeList removeObject:@(primeFlip)];
        if(hasInvertFlip) [primeList removeObject:@(primeInvertFlip)];
    }
        
    //Format the Output
    
    
    NSUInteger analyzedCnt =    [grandMasterPrimes count]*4+\
        
                                [masterPrimes count]*3+[specialMasterPrimes count]*2+\
    
                                [grandPrimes count]*2+[specialGrandPrimes count]*1+\
    
                                [flipPrimes count]*2+[specialFlipPrimes count]*1+\
                                [invertPrimes count]*2+\
                                [nullPrimes count];
    
    NSAssert(analyzedCnt==[primes count],@"Mismatch in number of primes analyzed versus counted!!");
    
    if(LOG_DATA_CONSOLE){
        //Print out the sumsx
        NSLog(@"----------------------------------------");
        NSLog(@"Digits: %d",width);
        NSLog(@"Total Primes: %lu",[primes count]);
        NSLog(@"Analyzed Primes: %lu",analyzedCnt);
        NSLog(@"--------------------");
        NSLog(@"Grand Master Primes: %lu",(unsigned long)[grandMasterPrimes count]);
        NSLog(@"Master Primes: %lu",(unsigned long)[masterPrimes count]);
        NSLog(@"Special Master Primes: %lu",(unsigned long)[specialMasterPrimes count]);
        NSLog(@"Grand Primes: %lu",(unsigned long)[grandPrimes count]);
        NSLog(@"Speical Grand Primes: %lu",(unsigned long)[specialGrandPrimes count]);
        NSLog(@"Flip Primes: %lu",(unsigned long)[flipPrimes count]);
        NSLog(@"Special Flip Primes: %lu",(unsigned long)[specialFlipPrimes count]);
        NSLog(@"Invert Primes: %lu",(unsigned long)[invertPrimes count]);
        NSLog(@"Null Primes: %lu",(unsigned long)[nullPrimes count]);
        NSLog(@"----------------------------------------");
    }
    if(LOG_DATA_FILE_VERBOSE){
        NSMutableString* cacheOutput = [NSMutableString stringWithCapacity:100];
        NSString* fileName = [NSString stringWithFormat:@"%s/%d_PrimerOutput.txt",OUTPUT_DIR,width];
        
        NSStringEncoding enc = NSUTF8StringEncoding;
        NSString* dataBreak = @"\n----------------------";
        //Generate and write all outputs
        [cacheOutput appendFormat:@"Digit Width: %d",width];
        [cacheOutput appendFormat:@"\nMax Prime: %.Lf",powl(2, width)-1];
        [cacheOutput appendFormat:@"\nTotal Primes: %lu",[primes count]];
        [cacheOutput appendString:dataBreak];
        //Grand/Master/Special
        [cacheOutput appendFormat:@"\nGrand Master Primes: %@",[grandMasterPrimes ullDescription]];
        [cacheOutput appendString:dataBreak];
        [cacheOutput appendFormat:@"\nMaster Primes: %@",[masterPrimes ullDescription]];
        [cacheOutput appendFormat:@"\nSpecial Master Primes: %@",[specialMasterPrimes ullDescription]];
        [cacheOutput appendString:dataBreak];
        [cacheOutput appendFormat:@"\nGrand Primes: %@",[grandPrimes ullDescription]];
        [cacheOutput appendFormat:@"\nSpecial Grand Primes: %@",[specialGrandPrimes ullDescription]];
        [cacheOutput appendString:dataBreak];
        //Flip
        [cacheOutput appendFormat:@"\nFlip Primes: %@",[flipPrimes ullDescription]];
        [cacheOutput appendFormat:@"\nSpecial Flip Primes: %@",[specialFlipPrimes ullDescription]];
        [cacheOutput appendString:dataBreak];
        //Invert
        [cacheOutput appendFormat:@"\nInvert Primes: %@",[invertPrimes ullDescription]];
        [cacheOutput appendString:dataBreak];
        //Null Primes
        [cacheOutput appendFormat:@"\nNull Primes: %@",[nullPrimes ullDescription]];
        
        //Write to file
        [cacheOutput appendToFile:fileName encoding:enc];
    }


    //Create the output string
    NSMutableString* output = [[NSMutableString alloc] init];
    
    //Digits,Number of Primes,
    //Grand Master Primes,
    //Master Primes, Special Master Primes,
    //Grand Primes, Special Grand Primes,
    //Flip Primes, Special Flip Primes,
    //Invert Primes,
    //Null Primes
    [output appendFormat:@"%d,",width];
    [output appendFormat:@"%lu,",(unsigned long)[primes count]];
    
    [output appendFormat:@"%lu,",(unsigned long)[grandMasterPrimes count]];
    
    [output appendFormat:@"%lu,",(unsigned long)[masterPrimes count]];
    [output appendFormat:@"%lu,",(unsigned long)[specialMasterPrimes count]];
    
    [output appendFormat:@"%lu,",(unsigned long)[grandPrimes count]];
    [output appendFormat:@"%lu,",(unsigned long)[specialGrandPrimes count]];
    
    [output appendFormat:@"%lu,",(unsigned long)[flipPrimes count]];
    [output appendFormat:@"%lu,",(unsigned long)[specialFlipPrimes count]];
    
    [output appendFormat:@"%lu,",(unsigned long)[invertPrimes count]];
    
    [output appendFormat:@"%lu",(unsigned long)[nullPrimes count]];
    
    return output;
}
-(BOOL)containsPrime:(NSArray*)sortedArray prime:(NSNumber*)prime{
    BOOL foundPrime = false;
    /*
    NSRange searchRange = NSMakeRange(0, [sortedArray count]);
    NSUInteger findIndex = [sortedArray indexOfObject:prime
                                        inSortedRange:searchRange
                                              options:NSBinarySearchingFirstEqual
                                      usingComparator:^(id obj1, id obj2){
                                          return [obj1 compare:obj2];
                                      }];
    */
    NSInteger findIndex = [sortedArray binarySearch:prime];
    if(findIndex != NSNotFound){
        foundPrime = true;
    }
    return foundPrime;
}
-(unsigned long long)calculateBasePrime:(unsigned long long)prime
                            invertPrime:(unsigned long long)invert
                              flipPrime:(unsigned long long)flip
                        invertFlipPrime:(unsigned long long)invertFlip{
    unsigned long long retVal = prime;
    if(invert != 0 && invert < retVal) retVal = invert;
    if(flip != 0 && flip < retVal) retVal = flip;
    if(invertFlip != 0 && invertFlip < retVal) retVal = invertFlip;
    return retVal;
}
#pragma mark - Machine Diagnosis
-(void)verifyMachine{
    unsigned long long maxNumber = ULLONG_MAX;
    //179424673
    //573259391
    NSLog(@"Upper Limit: %llu",maxNumber);
}
#pragma mark - Tests
#pragma mark Data Verification
-(void)runDataTest{
    NSString* result;
    //Test String Conversion
    //515d = 1000000011b
    result = [self binaryStringFromInteger:515 numDigits:10];
    NSAssert([result isEqualToString:@"1000000011"],@"Binary String Conversion Failed");
    result = [self invertedBinaryStringFromInteger:515 numDigits:10];
    NSAssert([result isEqualToString:@"1111111101"],@"Inverted Binary String Conversion Failed");
    result = [self flippedBinaryStringFromInteger:515 numDigits:10];
    NSAssert([result isEqualToString:@"1100000001"],@"Flipped Binary String Conversion Failed");
    result = [self invertedFlippedBinaryStringFromInteger:515 numDigits:10];
    NSAssert([result isEqualToString:@"1011111111"],@"Inverted Flipped Binary String Conversion Failed");
    
    //Test longest string conversion
    //18446744073709551613d = 1111111111111111111111111111111111111111111111111111111111111101b
    result = [self binaryStringFromInteger:18446744073709551613U numDigits:64];
    NSAssert([result isEqualToString:@"1111111111111111111111111111111111111111111111111111111111111101"],@"Binary String Conversion Failed");
    result = [self invertedBinaryStringFromInteger:18446744073709551613U numDigits:64];
    NSAssert([result isEqualToString:@"1000000000000000000000000000000000000000000000000000000000000011"],@"Binary String Conversion Failed");
    result = [self flippedBinaryStringFromInteger:18446744073709551613U numDigits:64];
    NSAssert([result isEqualToString:@"1011111111111111111111111111111111111111111111111111111111111111"],@"Binary String Conversion Failed");
    
    
    //Test unsigned long long conversion
    unsigned long long longResult;
    
    //11001001
    //201i == 10110111 == 183
    longResult = [self invert:201 width:8];
    NSAssert(183 == longResult,@"Invert Failed");
    //201f == 10010011 == 147
    longResult = [self flip:201 width:8];
    NSAssert(147 == longResult,@"Flip Failed");
    //201if == 11101101 == 237
    longResult = [self invertFlip:201 width:8];
    NSAssert(237 == longResult,@"Invert/Flip Failed");
    
    
    //Special Case
    //27 == 11011
    //27i == 10101 == 21
    longResult = [self invert:27 width:5];
    NSAssert(21 == longResult,@"Invert Failed");
    //27f == 11011 == 27
    longResult = [self flip:27 width:5];
    NSAssert(27 == longResult,@"Flip Failed");
    //27if == 10101 == 21
    longResult = [self invertFlip:27 width:5];
    NSAssert(21 == longResult,@"Invert/Flip Failed");
    
    
    
    NSLog(@"Data Test Passed.");
}
-(void)testInputData{
    
}

#pragma mark Performance
-(void)runPerformaceTest{
    for(int width=3;width<5;width++){
        unsigned long long initNumb = powl(2,width-1);
        unsigned long long maxNumb = powl(2, width);
        NSString* result;
        NSString* result2;
        NSLog(@"Number,Binary,Invert");
        for(unsigned long long index = initNumb; index<maxNumb;index++){
            result = [self binaryStringFromInteger:index numDigits:width];
            result2 = [self invertedBinaryStringFromInteger:index numDigits:width];
            //result = [self flippedBinaryStringFromInteger:index numDigits:width];
            //result = [self flippedBinaryStringFromInteger2:index numDigits:width];
            NSLog(@"%llu,%@,%@",index,result,result2);
        }
    }
}
@end
