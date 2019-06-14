//
//  NSArray+EnumExtensions.h
//  Vidol
//
//  Created by XJIMI on 2018/2/6.
//  Copyright © 2018年 XJIMI. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (XJEnumExtensions)

/**
 * enum to string
 * @param value enum value
 * @return NSString string value
 */
- (NSString *)stringFromEnum:(NSInteger)value;

/**
 * string to enum
 * @param value string value
 * @return NSInteger enum value
 */
- (NSInteger)enumFromString:(NSString *)value;

/**
 * string to enum
 * @param value string value
 * @param def default enum value
 * @return NSInteger enum value
 */
- (NSInteger)enumFromString:(NSString *)value def:(NSInteger)def;

@end


NS_ASSUME_NONNULL_END
