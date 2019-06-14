//
//  NSArray+EnumExtensions.m
//  Vidol
//
//  Created by XJIMI on 2018/2/6.
//  Copyright © 2018年 XJIMI. All rights reserved.
//

#import "NSArray+XJEnumExtensions.h"

@implementation NSArray (XJEnumExtensions)

- (NSString *)stringFromEnum:(NSInteger)value {
    return [self objectAtIndex:value];
}

- (NSInteger)enumFromString:(NSString *)value {
    return [self enumFromString:value def:0];
}

- (NSInteger)enumFromString:(NSString *)value def:(NSInteger)def {
    NSInteger n = [self indexOfObject:value];
    if(n == NSNotFound) n = def;
    return n;
}

@end
