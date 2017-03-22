//
//  NSString+FileIO.m
//  Primer
//
//  Created by Jeremy Cope on 4/25/16.
//  Copyright © 2016 Emma Technologies, L.L.C. All rights reserved.
//

#import "NSString+FileIO.h"

@implementation NSString (FileIO)

- (BOOL) appendToFile:(NSString *)path encoding:(NSStringEncoding)enc{
    BOOL result = YES;
    NSFileHandle* fh = [NSFileHandle fileHandleForWritingAtPath:path];
    if ( !fh ) {
        [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
        fh = [NSFileHandle fileHandleForWritingAtPath:path];
    }
    if ( !fh ) return NO;
    @try {
        [fh seekToEndOfFile];
        [fh writeData:[self dataUsingEncoding:enc]];
    }
    @catch (NSException * e) {
        result = NO;
    }
    [fh closeFile];
    return result;
}

@end
