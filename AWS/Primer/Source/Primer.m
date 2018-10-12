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

@interface Primer()
//@property NSArray* primeList;
@end

@implementation Primer

@synthesize m_primeWidth;
@synthesize m_threadCount;

@synthesize m_primeList;
/*
@synthesize threadCount = _threadCount;
@synthesize primeWidth = _primeWidth;
*/
@synthesize m_grandMasterPrimes;
@synthesize m_masterPrimes;
@synthesize m_specialMasterPrimes;
@synthesize m_grandPrimes;
@synthesize m_specialGrandPrimes;
@synthesize m_flipPrimes;
@synthesize m_specialFlipPrimes;
@synthesize m_invertPrimes;
@synthesize m_nullPrimes;

-(instancetype)init{
    if (self = [super init]) {
        self.m_primeList = [[NSArray alloc] init];
        //_dataLock = [[NSLock alloc] init];
        self.m_threadCount = 0;
        self.m_primeWidth = 0;
    }
    return self;
}
/*
-(NSArray*)primeList{
    return self.primeList;
}
-(void)setPrimeList:(NSArray *)primeList{
    self.primeList = primeList;
}
 */
-(void)initBuckets{
    /*
    self.m_grandMasterPrimes = [[NSMutableSet alloc] init];
    self.m_masterPrimes = [[NSMutableSet alloc] init];
    self.m_specialMasterPrimes = [[NSMutableSet alloc] init];
    self.m_grandPrimes = [[NSMutableSet alloc] init];
    self.m_specialGrandPrimes = [[NSMutableSet alloc] init];
    self.m_flipPrimes = [[NSMutableSet alloc] init];
    self.m_specialFlipPrimes = [[NSMutableSet alloc] init];
    self.m_invertPrimes = [[NSMutableSet alloc] init];
    self.m_nullPrimes = [[NSMutableSet alloc] init];
    */
    self.m_grandMasterPrimes = [[NSMutableArray alloc] init];
    self.m_masterPrimes = [[NSMutableArray alloc] init];
    self.m_specialMasterPrimes = [[NSMutableArray alloc] init];
    self.m_grandPrimes = [[NSMutableArray alloc] init];
    self.m_specialGrandPrimes = [[NSMutableArray alloc] init];
    self.m_flipPrimes = [[NSMutableArray alloc] init];
    self.m_specialFlipPrimes = [[NSMutableArray alloc] init];
    self.m_invertPrimes = [[NSMutableArray alloc] init];
    self.m_nullPrimes = [[NSMutableArray alloc] init];
}
-(void)removeDuplicates{
    NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:self.m_grandMasterPrimes];
    self.m_grandMasterPrimes = [NSMutableArray arrayWithArray:[orderedSet array]];
    orderedSet = [NSOrderedSet orderedSetWithArray:self.m_masterPrimes];
    self.m_masterPrimes = [NSMutableArray arrayWithArray:[orderedSet array]];
    orderedSet = [NSOrderedSet orderedSetWithArray:self.m_specialMasterPrimes];
    self.m_specialMasterPrimes = [NSMutableArray arrayWithArray:[orderedSet array]];
    orderedSet = [NSOrderedSet orderedSetWithArray:self.m_grandPrimes];
    self.m_grandPrimes = [NSMutableArray arrayWithArray:[orderedSet array]];
    orderedSet = [NSOrderedSet orderedSetWithArray:self.m_specialGrandPrimes];
    self.m_specialGrandPrimes = [NSMutableArray arrayWithArray:[orderedSet array]];
    orderedSet = [NSOrderedSet orderedSetWithArray:self.m_flipPrimes];
    self.m_flipPrimes = [NSMutableArray arrayWithArray:[orderedSet array]];
    orderedSet = [NSOrderedSet orderedSetWithArray:self.m_specialFlipPrimes];
    self.m_specialFlipPrimes = [NSMutableArray arrayWithArray:[orderedSet array]];
    orderedSet = [NSOrderedSet orderedSetWithArray:self.m_invertPrimes];
    self.m_invertPrimes = [NSMutableArray arrayWithArray:[orderedSet array]];
    orderedSet = [NSOrderedSet orderedSetWithArray:self.m_nullPrimes];
    self.m_nullPrimes = [NSMutableArray arrayWithArray:[orderedSet array]];
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
#pragma mark Threaded
#define NUM_THREADS 1
-(NSString*)analyzePrimeNumberList_NoThread:(NSArray*)primes width:(int)width{
    //Store the primes in data controlled storage
    self.m_primeList = primes;
    self.m_primeWidth = width;
    [self initBuckets];
    [self analyzePrimeNumberList_Search:primes];
    [self removeDuplicates];
    
    [self verifyCount]; //Will Assert if false
    NSString* result = [self outputResults];
    
    return result;
}

-(NSString*)analyzePrimeNumberList_Threaded:(NSArray*)primes width:(int)width{
    //Store the primes in data controlled storage
    self.m_primeList = primes;
    self.m_primeWidth = width;
    [self initBuckets];
    
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
    
        //[_dataLock lock];
        self.m_threadCount++;
        //[_dataLock unlock];
        lowerRange+=range;
    }
    //Wait until all threads are done
    while(self.m_threadCount>0){
        
    }
    [self verifyCount]; //Will Assert if false
    NSString* result = [self outputResults];
    
    return result;
}
-(void)verifyCount{
    NSUInteger analyzedCnt =
    
    [self.m_grandMasterPrimes count]*4+\
    //Master
    [self.m_masterPrimes count]*3+[self.m_specialMasterPrimes count]*2+\
    //Grand
    [self.m_grandPrimes count]*2+[self.m_specialGrandPrimes count]*1+\
    //
    [self.m_flipPrimes count]*2+[self.m_specialFlipPrimes count]*1+\
    [self.m_invertPrimes count]*2+\
    [self.m_nullPrimes count];
    
    NSAssert(analyzedCnt == [self.m_primeList count],@"Mismatch in number of primes analyzed versus counted!!");
}
-(void)analyzePrimeNumberList_Search:(NSArray*)primesSubset{
    NSLog(@"Analyzing %lu primes out of %lu",(unsigned long)[primesSubset count],(unsigned long)[self.m_primeList count]);
    //For now just print out the prime subset
    for(NSNumber* p in primesSubset){
        unsigned long long prime = [p unsignedLongLongValue];
        unsigned long long storagePrime = 0;
        primeType pType = [self calculatePrimeType:prime storagePrime:&storagePrime];
        
        NSNumber* sPrime = @(storagePrime);
        if(pType == grandMasterPRIME) [self.m_grandMasterPrimes addObject:sPrime];
        else if(pType == masterPRIME) [self.m_masterPrimes addObject:sPrime];
        else if(pType == specialMasterPRIME) [self.m_specialMasterPrimes addObject:sPrime];
        else if(pType == grandPRIME) [self.m_grandPrimes addObject:sPrime];
        else if(pType == specialGrandPRIME) [self.m_specialGrandPrimes addObject:sPrime];
        else if(pType == flipPRIME) [self.m_flipPrimes addObject:sPrime];
        else if(pType == specialFlipPRIME) [self.m_specialFlipPrimes addObject:sPrime];
        else if(pType == invertPRIME) [self.m_invertPrimes addObject:sPrime];
        else if(pType == nullPRIME) [self.m_nullPrimes addObject:sPrime];
        else NSAssert(false,@"Unknown Type");
    }
    
    //[_dataLock lock];
    self.m_threadCount--;
    //[_dataLock unlock];
}
-(primeType)calculatePrimeType:(unsigned long long)prime storagePrime:(unsigned long long*)sPrime{
    primeType retPrimeType = unknownPRIME;
    unsigned long long retStoragePrime;
    
    unsigned long long primeInvert = [self invert:prime width:self.m_primeWidth];
    unsigned long long primeFlip = [self flip:prime width:self.m_primeWidth];
    unsigned long long primeInvertFlip = [self invertFlip:prime width:self.m_primeWidth];
    
    
    bool hasInvert = [self containsPrime:self.m_primeList prime:@(primeInvert)];
    bool hasFlip = [self containsPrime:self.m_primeList prime:@(primeFlip)];
    bool hasInvertFlip = [self containsPrime:self.m_primeList prime:@(primeInvertFlip)];
    
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
            NSAssert(false,@"Reached poor logic choice 23.");
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
            NSAssert(false,@"Reached poor logic choice 93.");
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
        NSAssert(false,@"Reached poor logic choice 126.");
        retStoragePrime = 0;
    }
    *sPrime = retStoragePrime;
    return retPrimeType;
}
-(NSString*)outputResults{
    if(LOG_DATA_CONSOLE){
        //Print out the sumsx
        NSLog(@"----------------------------------------");
        NSLog(@"Digits: %d",m_primeWidth);
        NSLog(@"Total Primes: %lu",[m_primeList count]);
        NSLog(@"--------------------");
        NSLog(@"Grand Master Primes: %lu",(unsigned long)[m_grandMasterPrimes count]);
        NSLog(@"Master Primes: %lu",(unsigned long)[m_masterPrimes count]);
        NSLog(@"Special Master Primes: %lu",(unsigned long)[m_specialMasterPrimes count]);
        NSLog(@"Grand Primes: %lu",(unsigned long)[m_grandPrimes count]);
        NSLog(@"Speical Grand Primes: %lu",(unsigned long)[m_specialGrandPrimes count]);
        NSLog(@"Flip Primes: %lu",(unsigned long)[m_flipPrimes count]);
        NSLog(@"Special Flip Primes: %lu",(unsigned long)[m_specialFlipPrimes count]);
        NSLog(@"Invert Primes: %lu",(unsigned long)[m_invertPrimes count]);
        NSLog(@"Null Primes: %lu",(unsigned long)[m_nullPrimes count]);
        NSLog(@"----------------------------------------");
    }
    if(LOG_DATA_FILE_VERBOSE){
        NSMutableString* cacheOutput = [NSMutableString stringWithCapacity:100];
        NSString* fileName = [NSString stringWithFormat:@"%s/%d_%s",OUTPUT_DIR,m_primeWidth,OUTPUT_FILE];
        
        NSStringEncoding enc = NSUTF8StringEncoding;
        NSString* dataBreak = @"\n----------------------";
        //Generate and write all outputs
        [cacheOutput appendFormat:@"Digit Width: %d",m_primeWidth];
        [cacheOutput appendFormat:@"\nMax Prime: %.Lf",powl(2, m_primeWidth)-1];
        [cacheOutput appendFormat:@"\nTotal Primes: %lu",[m_primeList count]];
        [cacheOutput appendString:dataBreak];
        //Grand/Master/Special
        [cacheOutput appendFormat:@"\nGrand Master Primes: %@",[self ullDescription_array:m_grandMasterPrimes]];
        [cacheOutput appendString:dataBreak];
        [cacheOutput appendFormat:@"\nMaster Primes: %@",[self ullDescription_array:m_masterPrimes]];
        [cacheOutput appendFormat:@"\nSpecial Master Primes: %@",[self ullDescription_array:m_specialMasterPrimes]];
        [cacheOutput appendString:dataBreak];
        [cacheOutput appendFormat:@"\nGrand Primes: %@",[self ullDescription_array:m_grandPrimes]];
        [cacheOutput appendFormat:@"\nSpecial Grand Primes: %@",[self ullDescription_array:m_specialGrandPrimes]];
        [cacheOutput appendString:dataBreak];
        //Flip
        [cacheOutput appendFormat:@"\nFlip Primes: %@",[self ullDescription_array:m_flipPrimes]];
        [cacheOutput appendFormat:@"\nSpecial Flip Primes: %@",[self ullDescription_array:m_specialFlipPrimes]];
        [cacheOutput appendString:dataBreak];
        //Invert
        [cacheOutput appendFormat:@"\nInvert Primes: %@",[self ullDescription_array:m_invertPrimes]];
        [cacheOutput appendString:dataBreak];
        //Null Primes
        [cacheOutput appendFormat:@"\nNull Primes: %@",[self ullDescription_array:m_nullPrimes]];
        
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
    [output appendFormat:@"%d,",m_primeWidth];
    [output appendFormat:@"%lu,",(unsigned long)[m_primeList count]];
    
    [output appendFormat:@"%lu,",(unsigned long)[m_grandMasterPrimes count]];
    
    [output appendFormat:@"%lu,",(unsigned long)[m_masterPrimes count]];
    [output appendFormat:@"%lu,",(unsigned long)[m_specialMasterPrimes count]];
    
    [output appendFormat:@"%lu,",(unsigned long)[m_grandPrimes count]];
    [output appendFormat:@"%lu,",(unsigned long)[m_specialGrandPrimes count]];
    
    [output appendFormat:@"%lu,",(unsigned long)[m_flipPrimes count]];
    [output appendFormat:@"%lu,",(unsigned long)[m_specialFlipPrimes count]];
    
    [output appendFormat:@"%lu,",(unsigned long)[m_invertPrimes count]];
    
    [output appendFormat:@"%lu",(unsigned long)[m_nullPrimes count]];
    
    return output;
}
-(NSString*)ullDescription:(NSSet*)set{
    NSString* retStr = @"";
    NSMutableString* dataOutput = [NSMutableString stringWithCapacity:20];
    for(NSNumber* prime in set){
        unsigned long long value = [prime unsignedLongLongValue];
        [dataOutput appendFormat:@"%llu,",value];
    }
    if([dataOutput length]>0){ //If dataOutput was generated
        retStr = [dataOutput substringToIndex:[dataOutput length]-1]; //Trim away last ','
    }
    return retStr;
}
-(NSString*)ullDescription_array:(NSArray*)array{
    NSString* retStr = @"";
    NSMutableString* dataOutput = [NSMutableString stringWithCapacity:20];
    for(NSNumber* prime in array){
        unsigned long long value = [prime unsignedLongLongValue];
        [dataOutput appendFormat:@"%llu,",value];
    }
    if([dataOutput length]>0){ //If dataOutput was generated
        retStr = [dataOutput substringToIndex:[dataOutput length]-1]; //Trim away last ','
    }
    return retStr;
}
#pragma mark Sequential
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
    
    NSAssert(analyzedCnt == [primes count],@"Mismatch in number of primes analyzed versus counted!!");
    
    
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
        NSString* fileName = [NSString stringWithFormat:@"%s/%d_%s",OUTPUT_DIR,width,OUTPUT_FILE];
        
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
    if(BINARY_SEARCH){
        NSInteger findIndex = [sortedArray binarySearch:prime];
        if(findIndex != NSNotFound){
            foundPrime = true;
        }
    }
    else{
        foundPrime = [sortedArray containsObject:prime];
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
    
    
    //4306063679d = 100000000101010010101000100111111b
    result = [self binaryStringFromInteger:4306063679 numDigits:33];
    NSAssert([result isEqualToString:@"100000000101010010101000100111111"],@"Binary String Conversion Failed");
    result = [self invertedBinaryStringFromInteger:4306063679 numDigits:33];
    NSAssert([result isEqualToString:@"111111111010101101010111011000001"],@"Inverted Binary String Conversion Failed");
    result = [self flippedBinaryStringFromInteger:4306063679 numDigits:33];
    NSAssert([result isEqualToString:@"111111001000101010010101000000001"],@"Flipped Binary String Conversion Failed");
    result = [self invertedFlippedBinaryStringFromInteger:4306063679 numDigits:33];
    NSAssert([result isEqualToString:@"100000110111010101101010111111111"],@"Inverted Flipped Binary String Conversion Failed");

    unsigned long long primeInvert = [self invert:4306063679 width:33];
    unsigned long long primeFlip = [self flip:4306063679 width:33];
    unsigned long long primeInvertFlip = [self invertFlip:4306063679 width:33];
    NSAssert(primeInvert == 8578838209,@"Invalid invert conversion!");
    NSAssert(primeFlip == 8473881089,@"Invalid flip conversion!");
    NSAssert(primeInvertFlip == 4411020799,@"Invalid invertFlip conversion!");
    
    
    

    //Test longest string conversion
    //18446744073709551613d = 1111111111111111111111111111111111111111111111111111111111111101b
    result = [self binaryStringFromInteger:18446744073709551613U numDigits:64];
    NSAssert([result isEqualToString:@"1111111111111111111111111111111111111111111111111111111111111101"],@"Binary String Conversion Failed");
    result = [self invertedBinaryStringFromInteger:18446744073709551613U numDigits:64];
    NSAssert([result isEqualToString:@"1000000000000000000000000000000000000000000000000000000000000011"],@"Binary String Conversion Failed");
    result = [self flippedBinaryStringFromInteger:18446744073709551613U numDigits:64];
    NSAssert([result isEqualToString:@"1011111111111111111111111111111111111111111111111111111111111111"],@"Binary String Conversion Failed");
   
    primeInvert = [self invert:18446744073709551613U width:64];
    primeFlip = [self flip:18446744073709551613U width:64];
    primeInvertFlip = [self invertFlip:18446744073709551613U width:64];
    NSAssert(primeInvert == 9223372036854775811U,@"Invalid invert conversion!");
    NSAssert(primeFlip == 13835058055282163711U,@"Invalid flip conversion!");
    NSAssert(primeInvertFlip == 13835058055282163713U,@"Invalid invertFlip conversion!");
    
    
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
#pragma mark Data Generation- for random input testing
-(NSArray*)createRandomInput:(int)digits numPrimes:(unsigned long long)bucketSize{
    //Calculate a min, max, number of elements
    unsigned long long initNumb = powl(2,digits-1);
    unsigned long long maxNumb = powl(2, digits)-1;
    //Creat array with all available candidtate (between min/max, not even)
    NSMutableArray* pool = [NSMutableArray arrayWithCapacity:maxNumb-initNumb];
    for(unsigned long long number = initNumb+1; number<=maxNumb; number = number+2){
        [pool addObject:@(number)];
    }
    //Randomize the mutable array
    pool = [Primer randomSortArray:pool];
    NSRange randomRange;
    randomRange.location = 0;
    randomRange.length = bucketSize;
    NSArray* randomList = [pool subarrayWithRange:randomRange];
    NSArray* sortedList = [Primer sortArrayAscending:randomList];
    //NSLog([randomList description]);
    return sortedList;
}
-(unsigned long long)primeNumbersPerGroup:(int)width{
    NSArray* primeCount = @[@(2),@(2),@(5),@(7),@(13),@(23),@(43),@(75),@(137),
                            @(255),@(464),@(872),@(1612),@(3030),@(5709),@(10749),@(20390),
                            @(38635),@(73586),@(140336),@(268216),@(513708),@(985818),@(1894120),
                            @(3645744),@(7027290),@(13561907),@(26207278),@(50697537),@(98182656)];
    int index = width - 3; //We only analyze starting with width = 3 digits
    NSAssert(index<[primeCount count],@"Unsupported length");
    unsigned long long retVal = [primeCount[index] unsignedLongLongValue];
    return retVal;
}
#pragma mark - Array Utilities
+(NSMutableArray *)randomSortArray:(NSMutableArray *)array {
    srandom((unsigned int)time(NULL));
    for (NSInteger x = 0; x < [array count]; x++) {
        NSInteger randInt = (arc4random() % ([array count] - x)) + x;
        [array exchangeObjectAtIndex:x withObjectAtIndex:randInt];
    }
    return array;
}
+(NSArray *)sortArrayAscending:(NSArray *)array{
    NSArray* sortedArray = [array sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if ([obj1 unsignedLongLongValue] > [obj2 unsignedLongLongValue]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        if ([obj1 unsignedLongLongValue] < [obj2 unsignedLongLongValue]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    return sortedArray;
}
#pragma mark - Flip(*) investigation
-(NSString*)analyzePrimeNumberListForFlip_NoThread:(NSArray*)primes width:(int)width{
    //Store the primes in data controlled storage
    self.m_primeList = primes;
    self.m_primeWidth = width;
    [self initBuckets];
    NSString* result = [self analyzePrimeNumberListForSpecialFlips:primes];
    
    return result;
}
-(NSString*)analyzePrimeNumberListForSpecialFlips:(NSArray*)primesSubset{
    NSString* result;
    int count = 0;
    for(NSNumber* p in primesSubset){
        unsigned long long prime = [p unsignedLongLongValue];
        unsigned long long primeInvert = [self invert:prime width:self.m_primeWidth];
        unsigned long long primeFlip = [self flip:prime width:self.m_primeWidth];
        unsigned long long primeInvertFlip = [self invertFlip:prime width:self.m_primeWidth];
        
        bool hasInvert = [self containsPrime:self.m_primeList prime:@(primeInvert)];
        bool hasFlip = [self containsPrime:self.m_primeList prime:@(primeFlip)];
        bool hasInvertFlip = [self containsPrime:self.m_primeList prime:@(primeInvertFlip)];
        
        //If this meets the condiditon for a flip*
        if(prime == primeFlip && hasFlip == true && hasInvert == false && hasInvertFlip == false){
            count++;
        }
    }
    result = [NSString stringWithFormat:@"%d,%d",self.m_primeWidth,count];
    return result;
}
@end
