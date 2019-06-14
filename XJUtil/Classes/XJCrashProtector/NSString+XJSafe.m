//
//  NSString+MSSafe.m
//  
//
//  Created by J on 2014/2/27.
//  Copyright © 2014年 J. All rights reserved.
//

#import "NSString+XJSafe.h"

@implementation NSString (XJSafe)

- (BOOL)isNotEmpty {
    return [self length] != 0;
}

- (BOOL)isNotBlank
{
    if ([self isNotEmpty]) {
        return [[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] > 0;
    }
    return NO;
}

@end
