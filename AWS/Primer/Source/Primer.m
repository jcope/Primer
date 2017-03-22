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
-(NSString*)analyzePrimeNumberSet:(NSDictionary *)primeNumbers{
    int width = [[primeNumbers objectForKey:@"width"] intValue];
    NSArray* numbers = [primeNumbers objectForKey:@"numbers"];
    
    NSMutableArray* results = [NSMutableArray arrayWithCapacity:[numbers count]];
    
    NSMutableArray* grandPrimes = [NSMutableArray arrayWithCapacity:[numbers count]]; //Flip,Inverse,Flip/Inverse
    NSMutableArray* masterPrimes = [NSMutableArray arrayWithCapacity:[numbers count]]; //Flip and Inverse are unique
    NSMutableArray* specialPrimes = [NSMutableArray arrayWithCapacity:[numbers count]]; //Flip == Inverse
    
    NSMutableArray* flipPrimes = [NSMutableArray arrayWithCapacity:[numbers count]];
    NSMutableArray* flipUniquePrimes = [NSMutableArray arrayWithCapacity:[numbers count]]; //Flip == self
    NSMutableArray* invertPrimes = [NSMutableArray arrayWithCapacity:[numbers count]];
    NSMutableArray* invertUniquePrimes = [NSMutableArray arrayWithCapacity:[numbers count]]; //Invsers == self
    
    
    for(NSNumber* n in numbers){
        int d = [n intValue];
        NSString* decimal = [n stringValue];
        NSString* binary = [self binaryStringFromInteger:d numDigits:width];
        NSString* invertBinary = [self invertedBinaryStringFromInteger:d numDigits:width];
        NSString* flipBinary = [self flippedBinaryStringFromInteger:d numDigits:width];
        NSString* invertFlipBinary = [self invertedFlippedBinaryStringFromInteger:d numDigits:width];
        
        
        [results addObject:@{@"d":decimal,
                             @"b":binary,
                             @"i":invertBinary,
                             @"f":flipBinary,
                             @"if":invertFlipBinary}];
        
        //Print for now
        //NSLog(@"Decimal: %@\tBinary: %@\tInvert: %@\tFlip:%@",decimal,binary,invertBinary,flipBinary);
    }
    
    NSMutableArray* searchPrimes = [NSMutableArray arrayWithArray:results];
    NSMutableArray* tempPrimes = [NSMutableArray arrayWithCapacity:[numbers count]]; //Store Master and Grand
    //Search for Master Primes
    for(int index=0;index<[results count];index++){
        NSDictionary* d = [results objectAtIndex:index];
        
        //Searh for an inverse
        bool inverseFound = NO;
        NSString* inverse = @"   ";
        NSDictionary* invertDict = @{};
        for(NSDictionary* di in results){
            if([[d objectForKey:@"i"] isEqualToString:[di objectForKey:@"b"]]){
                inverseFound = YES;
                inverse = [di objectForKey:@"d"];
                invertDict = di;
            }
        }
        
        //Search for a flip
        bool flipFound = NO;
        NSString* flip = @"   ";
        NSDictionary* flipDict = @{};
        for(NSDictionary* df in results){
            if([[d objectForKey:@"f"] isEqualToString:[df objectForKey:@"b"]]){
                flipFound = YES;
                flip = [df objectForKey:@"d"];
                flipDict = df;
            }
        }
        
        //Determine Results
        if(inverseFound && flipFound){
            if(![flip isEqualToString:inverse]){
                [tempPrimes addObject:d];
            }else{
                //Only add if 'cousin' is not already tracked
                if(![specialPrimes containsObject:flipDict] || ![specialPrimes containsObject:invertDict]){
                    [specialPrimes addObject:d];
                }
            }
            [searchPrimes removeObject:d];
            [searchPrimes removeObject:flipDict];
            [searchPrimes removeObject:invertDict];
        }
    }
    
    //Filter Temp Primes into Grand Primes and Master Primes
    for(NSDictionary* d in tempPrimes){
        //Determine if this is a grand or master prime
        bool invertFlipFound = NO;
        NSDictionary* invertFlipDict = @{};
        for(NSDictionary* dif in tempPrimes){
            if([[d objectForKey:@"if"] isEqualToString:[dif objectForKey:@"b"]]){
                invertFlipFound = YES;
                invertFlipDict = dif;
            }
        }
        if (invertFlipFound){
            //Only add if it's inverse flip has not already been added
            BOOL alreadyAdded = NO;
            for(NSDictionary* g in grandPrimes){
                if ([[g objectForKey:@"b"] isEqualToString:[invertFlipDict objectForKey:@"b"]] ||
                    [[g objectForKey:@"i"] isEqualToString:[invertFlipDict objectForKey:@"b"]] ||
                    [[g objectForKey:@"f"] isEqualToString:[invertFlipDict objectForKey:@"b"]] ||
                    [[g objectForKey:@"if"] isEqualToString:[invertFlipDict objectForKey:@"b"]]) {
                    alreadyAdded = YES;
                }
            }
            if(!alreadyAdded){
                [grandPrimes addObject:d];
            }
        }else{ //InverseFlip was not found, must only be a master prime
            [masterPrimes addObject:d];
        }
    }
    
    results = [NSMutableArray arrayWithArray:searchPrimes];
    
    //Search for Inverts and Flips
    for(int index=0;index<[results count];index++){
        NSDictionary* d = [results objectAtIndex:index];
        //Searh for an inverse
        bool inverseFound = NO;
        NSString* inverse = @"   ";
        NSDictionary* invertDict = @{};
        for(NSDictionary* di in results){
            if([[d objectForKey:@"i"] isEqualToString:[di objectForKey:@"b"]]){
                inverseFound = YES;
                inverse = [di objectForKey:@"d"];
                invertDict = di;
            }
        }
        
        //Search for a flip
        bool flipFound = NO;
        NSString* flip = @"   ";
        NSDictionary* flipDict = @{};
        for(NSDictionary* df in results){
            if([[d objectForKey:@"f"] isEqualToString:[df objectForKey:@"b"]]){
                flipFound = YES;
                flip = [df objectForKey:@"d"];
                flipDict = df;
            }
        }
        
        if(inverseFound){
            if([[d objectForKey:@"d"] isEqualToString:inverse]){
                [invertUniquePrimes addObject:d];
            }
            else if(![invertPrimes containsObject:invertDict]){
                [invertPrimes addObject:d];
            }
            [searchPrimes removeObject:d];
            [searchPrimes removeObject:invertDict];
        }
        else if(flipFound){
            if([[d objectForKey:@"d"] isEqualToString:flip]){
                [flipUniquePrimes addObject:d];
            }
            else if(![flipPrimes containsObject:flipDict]){
                [flipPrimes addObject:d];
            }
            [searchPrimes removeObject:d];
            [searchPrimes removeObject:flipDict];
        }
    }
    results = [NSMutableArray arrayWithArray:searchPrimes];
    
    
    
    
    NSUInteger analyzedCnt =    [grandPrimes count]*4+\
    [masterPrimes count]*3+[specialPrimes count]*2+\
    [flipPrimes count]*2+[flipUniquePrimes count]+\
    [invertPrimes count]*2+[invertUniquePrimes count]+\
    [results count];
    
    if(LOG_DATA_CONSOLE){
        //Print out the sums
        NSLog(@"----------------------------------------");
        NSLog(@"Digits: %d",width);
        NSLog(@"Total Primes: %lu",[numbers count]);
        NSLog(@"--------------------");
        NSLog(@"Grand Primes: %lu",(unsigned long)[grandPrimes count]);
        NSLog(@"Master Primes: %lu",(unsigned long)[masterPrimes count]);
        NSLog(@"Special Primes: %lu",(unsigned long)[specialPrimes count]);
        NSLog(@"--------------------");
        NSLog(@"Flip Primes: %lu",(unsigned long)[flipPrimes count]);
        NSLog(@"Flip Unique Primes: %lu",(unsigned long)[flipUniquePrimes count]);
        NSLog(@"Invert Primes: %lu",(unsigned long)[invertPrimes count]);
        NSLog(@"Invert Unique Primes: %lu",(unsigned long)[invertUniquePrimes count]);
        NSLog(@"--------------------");
        NSLog(@"Null Primes: %lu",(unsigned long)[results count]);
        NSLog(@"--------------------");
        
        NSLog(@"Analyzed Primes: %lu",analyzedCnt);
        NSLog(@"----------------------------------------");
    }
    if(LOG_DATA_FILE_VERBOSE){
        NSMutableString* cacheOutput = [NSMutableString stringWithCapacity:100];
        NSString* fileName = [NSString stringWithFormat:@"%d_PrimerOutput.txt",width];
        
        NSStringEncoding enc = NSUTF8StringEncoding;
        NSString* dataBreak = @"\n----------------------";
        //Generate and write all outputs
        [cacheOutput appendFormat:@"Digit Width: %d",width];
        [cacheOutput appendFormat:@"\nMax Prime: %Lf",powl(2, width-1)];
        [cacheOutput appendFormat:@"\nTotal Primes: %lu",[numbers count]];
        [cacheOutput appendString:dataBreak];
        //Grand/Master/Special
        [cacheOutput appendFormat:@"\nGrand Primes: %@",[grandPrimes decimalDescription]];
        [cacheOutput appendFormat:@"\nMaster Primes: %@",[masterPrimes decimalDescription]];
        [cacheOutput appendFormat:@"\nSpecial Primes: %@",[specialPrimes decimalDescription]];
        [cacheOutput appendString:dataBreak];
        //Flip/Invert
        [cacheOutput appendFormat:@"\nFlip Primes: %@",[flipPrimes decimalDescription]];
        [cacheOutput appendFormat:@"\nFlipUnique Primes: %@",[flipUniquePrimes decimalDescription]];
        [cacheOutput appendFormat:@"\nInvert Primes: %@",[invertPrimes decimalDescription]];
        [cacheOutput appendFormat:@"\nInvertUnique Primes: %@",[invertUniquePrimes decimalDescription]];
        [cacheOutput appendString:dataBreak];
        //Null Primes
        [cacheOutput appendFormat:@"\nNull Primes: %@",[results decimalDescription]];
        
        //Write to file
        [cacheOutput appendToFile:fileName encoding:enc];
    }
    
    //Create the output string
    NSMutableString* output = [[NSMutableString alloc] init];

    //Digits,Number of Primes,Grand Primes,Master Primes,Special Primes,Flip Primes,Unique Flip Primes,Invert Primes,Unique Invert Primes,Null Primes
    [output appendFormat:@"%d,",width];
    [output appendFormat:@"%lu,",(unsigned long)[numbers count]];
    
    [output appendFormat:@"%lu,",(unsigned long)[grandPrimes count]];
    [output appendFormat:@"%lu,",(unsigned long)[masterPrimes count]];
    [output appendFormat:@"%lu,",(unsigned long)[specialPrimes count]];
    
    [output appendFormat:@"%lu,",(unsigned long)[flipPrimes count]];
    [output appendFormat:@"%lu,",(unsigned long)[flipUniquePrimes count]];
    [output appendFormat:@"%lu,",(unsigned long)[invertPrimes count]];
    [output appendFormat:@"%lu,",(unsigned long)[invertUniquePrimes count]];
    
    [output appendFormat:@"%lu",(unsigned long)[results count]];
    
    return output;
}
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
    
        _threadCount++;
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
    
    NSMutableArray* masterPrimes = [NSMutableArray arrayWithCapacity:[primes count]]; //Flip and Inverse are unique
    NSMutableArray* grandMasterPrimes = [NSMutableArray arrayWithCapacity:[primes count]]; //Flip,Inverse,Flip/Invert
    NSMutableArray* specialPrimes = [NSMutableArray arrayWithCapacity:[primes count]]; //Flip == Invert
    
    NSMutableArray* flipPrimes = [NSMutableArray arrayWithCapacity:[primes count]]; //Flip
    NSMutableArray* grandFlipPrimes = [NSMutableArray arrayWithCapacity:[primes count]]; //Flip, Flip/Invert
    NSMutableArray* specialFlipPrimes = [NSMutableArray arrayWithCapacity:[primes count]]; //Flip == self
    
    NSMutableArray* invertPrimes = [NSMutableArray arrayWithCapacity:[primes count]]; //Invert
    NSMutableArray* grandInvertPrimes = [NSMutableArray arrayWithCapacity:[primes count]]; //Invert, Flip/Invert
    NSMutableArray* specialInvertPrimes = [NSMutableArray arrayWithCapacity:[primes count]]; //Invert == self
    
    NSMutableArray* grandPrimes = [NSMutableArray arrayWithCapacity:[primes count]]; //Flip/Invert
    NSMutableArray* nullPrimes = [NSMutableArray arrayWithCapacity:[primes count]]; //None of the above
    
    while([primeList count] > 0){
        NSNumber* p = [primeList objectAtIndex:0];
        unsigned long long prime = [p unsignedLongLongValue];
        unsigned long long primeInvert = [self invert:prime width:width];
        unsigned long long primeFlip = [self flip:prime width:width];
        unsigned long long primeInvertFlip = [self invertFlip:prime width:width];
        /*
        bool hasInvert = [primeList containsObject:@(primeInvert)];
        bool hasFlip = [primeList containsObject:@(primeFlip)];
        bool hasInvertFlip = [primeList containsObject:@(primeInvertFlip)];
        */
        
        bool hasInvert = [self containsPrime:primeList prime:@(primeInvert)];
        bool hasFlip = [self containsPrime:primeList prime:@(primeFlip)];
        bool hasInvertFlip = [self containsPrime:primeList prime:@(primeInvertFlip)];
        //Categorize the prime
        //Master Primes (ie flip and invert)
        if(hasInvert && hasFlip){
            if(primeInvert == primeFlip){ //Special
                [specialPrimes addObject:@(prime)];
            }
            else if (hasInvertFlip){ //Grand Master
                [grandMasterPrimes addObject:@(prime)];
            }
            else{ //Master
                [masterPrimes addObject:@(prime)];
            }
        }
        //Invert
        else if(hasInvert){
            if(prime == primeInvert){ //Special Invert
                [specialInvertPrimes addObject:@(prime)];
            }
            else if(hasInvertFlip){ //Grand Flip
                [grandFlipPrimes addObject:@(prime)];
            }
            else{ //Flip
                [flipPrimes addObject:@(prime)];
            }
        }
        //Flip
        else if(hasFlip){
            if(prime == primeFlip){ //Special Flip
                [specialFlipPrimes addObject:@(prime)];
            }
            else if(hasInvertFlip){ //Grand Invert
                [grandInvertPrimes addObject:@(prime)];
            }
            else{ //Invert
                [invertPrimes addObject:@(prime)];
            }
        }
        //InvertFlip
        else if(hasInvertFlip){ //Grand
            [grandPrimes addObject:@(prime)];
        }
        //No category
        else{
            [nullPrimes addObject:@(prime)];
        }
        
        
        //Reset the prime list
        [primeList removeObject:@(prime)];
        if(hasInvert) [primeList removeObject:@(primeInvert)];
        if(hasFlip) [primeList removeObject:@(primeFlip)];
        if(hasInvertFlip) [primeList removeObject:@(primeInvertFlip)];
    }
    
    //Format the Output
    
    
    NSUInteger analyzedCnt =    [grandMasterPrimes count]*4+\
                                [masterPrimes count]*3+[specialPrimes count]*2+\
                                [flipPrimes count]*2+[grandFlipPrimes count]*3+[specialInvertPrimes count]+\
                                [invertPrimes count]*2+[grandInvertPrimes count]*3+[specialFlipPrimes count]+\
                                [grandPrimes count]*2+\
                                [nullPrimes count];
    
    if(LOG_DATA_CONSOLE){
        //Print out the sums
        NSLog(@"----------------------------------------");
        NSLog(@"Digits: %d",width);
        NSLog(@"Total Primes: %lu",[primes count]);
        NSLog(@"--------------------");
        NSLog(@"Grand Master Primes: %lu",(unsigned long)[grandPrimes count]);
        NSLog(@"Master Primes: %lu",(unsigned long)[masterPrimes count]);
        NSLog(@"Grand Primes: %lu",(unsigned long)[grandPrimes count]);
        NSLog(@"Special Primes: %lu",(unsigned long)[specialPrimes count]);
        NSLog(@"--------------------");
        NSLog(@"Flip Primes: %lu",(unsigned long)[flipPrimes count]);
        NSLog(@"Grand Flip Primes: %lu",(unsigned long)[grandFlipPrimes count]);
        NSLog(@"Special Flip Primes: %lu",(unsigned long)[specialFlipPrimes count]);
        NSLog(@"--------------------");
        NSLog(@"Invert Primes: %lu",(unsigned long)[invertPrimes count]);
        NSLog(@"Grand Invert Primes: %lu",(unsigned long)[grandInvertPrimes count]);
        NSLog(@"Special Invert Primes: %lu",(unsigned long)[specialInvertPrimes count]);
        NSLog(@"--------------------");
        NSLog(@"Null Primes: %lu",(unsigned long)[nullPrimes count]);
        NSLog(@"--------------------");
        NSLog(@"Analyzed Primes: %lu",analyzedCnt);
        NSLog(@"----------------------------------------");
    }
    if(LOG_DATA_FILE_VERBOSE){
        NSMutableString* cacheOutput = [NSMutableString stringWithCapacity:100];
        NSString* fileName = [NSString stringWithFormat:@"Output/%d_PrimerOutput.txt",width];
        
        NSStringEncoding enc = NSUTF8StringEncoding;
        NSString* dataBreak = @"\n----------------------";
        //Generate and write all outputs
        [cacheOutput appendFormat:@"Digit Width: %d",width];
        [cacheOutput appendFormat:@"\nMax Prime: %Lf",powl(2, width-1)];
        [cacheOutput appendFormat:@"\nTotal Primes: %lu",[primes count]];
        [cacheOutput appendString:dataBreak];
        //Grand/Master/Special
        [cacheOutput appendFormat:@"\nGrand Master Primes: %@",[masterPrimes ullDescription]];
        [cacheOutput appendFormat:@"\nMaster Primes: %@",[masterPrimes ullDescription]];
        [cacheOutput appendFormat:@"\nGrand Primes: %@",[grandPrimes ullDescription]];
        [cacheOutput appendFormat:@"\nSpecial Primes: %@",[specialPrimes ullDescription]];
        [cacheOutput appendString:dataBreak];
        //Flip
        [cacheOutput appendFormat:@"\nFlip Primes: %@",[flipPrimes ullDescription]];
        [cacheOutput appendFormat:@"\nGrand Flip Primes: %@",[grandFlipPrimes ullDescription]];
        [cacheOutput appendFormat:@"\nSpecial Flip Primes: %@",[specialFlipPrimes ullDescription]];
        [cacheOutput appendString:dataBreak];
        //Invert
        [cacheOutput appendFormat:@"\nInvert Primes: %@",[invertPrimes ullDescription]];
        [cacheOutput appendFormat:@"\nGrand Invert Primes: %@",[grandInvertPrimes ullDescription]];
        [cacheOutput appendFormat:@"\nSpecial Invert Primes: %@",[specialInvertPrimes ullDescription]];
        [cacheOutput appendString:dataBreak];
        //Null Primes
        [cacheOutput appendFormat:@"\nNull Primes: %@",[nullPrimes ullDescription]];
        
        //Write to file
        [cacheOutput appendToFile:fileName encoding:enc];
    }
    
    //Create the output string
    NSMutableString* output = [[NSMutableString alloc] init];
    
    //Digits,Number of Primes,
    //Grand Master Primes, Master Primes, Grand Primes, Special Primes,
    //Grand Flip Primes, Flip Primes, Special Flip Primes,
    //Grand Invert Primes, Invert Primes, Special Invert Primes,
    //Null Primes
    [output appendFormat:@"%d,",width];
    [output appendFormat:@"%lu,",(unsigned long)[primes count]];
    
    [output appendFormat:@"%lu,",(unsigned long)[grandMasterPrimes count]];
    [output appendFormat:@"%lu,",(unsigned long)[masterPrimes count]];
    [output appendFormat:@"%lu,",(unsigned long)[grandPrimes count]];
    [output appendFormat:@"%lu,",(unsigned long)[specialPrimes count]];

    [output appendFormat:@"%lu,",(unsigned long)[grandFlipPrimes count]];
    [output appendFormat:@"%lu,",(unsigned long)[flipPrimes count]];
    [output appendFormat:@"%lu,",(unsigned long)[specialFlipPrimes count]];
    
    [output appendFormat:@"%lu,",(unsigned long)[grandInvertPrimes count]];
    [output appendFormat:@"%lu,",(unsigned long)[invertPrimes count]];
    [output appendFormat:@"%lu,",(unsigned long)[specialInvertPrimes count]];
    
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
