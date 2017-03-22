//
//  NSString+FileIO.h
//  Primer
//
//  Created by Jeremy Cope on 4/25/16.
//  Copyright © 2016 Emma Technologies, L.L.C. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (FileIO)
- (BOOL) appendToFile:(NSString *)path encoding:(NSStringEncoding)enc;
@end
