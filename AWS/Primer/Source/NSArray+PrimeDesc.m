//
//  NSArray+PrimeDesc.m
//  Primer
//
//  Created by Jeremy Cope on 4/25/16.
//  Copyright © 2016 Emma Technologies, L.L.C. All rights reserved.
//

#import "NSArray+PrimeDesc.h"

@interface NSArray (PrimeDescPrivate)
- (NSInteger)binarySearch:(id)searchItem minIndex:(NSInteger)minIndex maxIndex:(NSInteger)maxIndex;
@end

@implementation NSArray (PrimeDesc)
-(NSString*)decimalDescription{
    NSString* retStr = @"";
    NSMutableString* dataOutput = [NSMutableString stringWithCapacity:20];
    for(NSDictionary* data in self){
        NSString* decimal = [data objectForKey:@"d"];
        [dataOutput appendFormat:@"%@,",decimal];
    }
    if([dataOutput length]>0){ //If dataOutput was generated
        retStr = [dataOutput substringToIndex:[dataOutput length]-1]; //Trim away last ','
    }
    return retStr;
}
-(NSString*)ullDescription{
    NSString* retStr = @"";
    NSMutableString* dataOutput = [NSMutableString stringWithCapacity:20];
    for(NSNumber* prime in self){
        unsigned long long value = [prime unsignedLongLongValue];
        [dataOutput appendFormat:@"%llu,",value];
    }
    if([dataOutput length]>0){ //If dataOutput was generated
        retStr = [dataOutput substringToIndex:[dataOutput length]-1]; //Trim away last ','
    }
    return retStr;
}

- (NSInteger)binarySearch:(id)searchItem
{
    if (searchItem == nil)
        return NSNotFound;
    return [self binarySearch:searchItem minIndex:0 maxIndex:[self count] - 1];
}


- (NSInteger)binarySearch:(id)searchItem minIndex:(NSInteger)minIndex maxIndex:(NSInteger)maxIndex
{
    // If the subarray is empty, return not found
    if (maxIndex < minIndex)
        return NSNotFound;
    
    NSInteger midIndex = (minIndex + maxIndex) / 2;
    id itemAtMidIndex = [self objectAtIndex:midIndex];
    
    NSComparisonResult comparison = [searchItem compare:itemAtMidIndex];
    if (comparison == NSOrderedSame)
        return midIndex;
    else if (comparison == NSOrderedAscending)
        return [self binarySearch:searchItem minIndex:minIndex maxIndex:midIndex - 1];
    else
        return [self binarySearch:searchItem minIndex:midIndex + 1 maxIndex:maxIndex];
}

@end
