//
//  NSArray+MSSafe.h
//  
//
//  Created by J on 2014/2/26.
//  Copyright © 2014年 J. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (XJSafe)

///如果index越界 返回nil
- (id)objectAtIndexSafe:(NSUInteger)index;

///如果index越界&&類型不匹配 返回nil
- (id)objectAtIndex:(NSUInteger)index kindOfClass:(Class)aClass;
- (id)objectAtIndex:(NSUInteger)index memberOfClass:(Class)aClass;

///如果index越界 返回defaultValue 默認值
- (id)objectAtIndex:(NSUInteger)index defaultValue:(id)value;
- (BOOL)boolAtIndex:(NSUInteger)index defaultValue:(BOOL)value;
- (float)floatAtIndex:(NSUInteger)index defaultValue:(float)value;
- (double)doubleAtIndex:(NSUInteger)index defaultValue:(double)value;
- (NSDate *)dateAtIndex:(NSUInteger)index defaultValue:(NSDate *)value;
- (NSData *)dataAtIndex:(NSUInteger)index defaultValue:(NSData *)value;
- (NSArray *)arrayAtIndex:(NSUInteger)index defaultValue:(NSArray *)value;
- (NSInteger)integerAtIndex:(NSUInteger)index defaultValue:(NSInteger)value;
- (NSString *)stringAtIndex:(NSUInteger)index defaultValue:(NSString *)value;
- (NSNumber *)numberAtIndex:(NSUInteger)index defaultValue:(NSNumber *)value;
- (NSUInteger)unintegerAtIndex:(NSUInteger)index defaultValue:(NSUInteger)value;
- (NSDictionary *)dictionaryAtIndex:(NSUInteger)index defaultValue:(NSDictionary *)value;

@end


@interface NSMutableArray (XJSafe)

// 排除nil 和 NSNull
- (void)addObjectSafe:(id)anObject;

- (void)removeObjectAtIndexInBoundary:(NSUInteger)index;
- (void)insertObject:(id)anObject atIndexInBoundary:(NSUInteger)index;
- (void)replaceObjectAtInBoundaryIndex:(NSUInteger)index withObject:(id)anObject;

@end

NS_ASSUME_NONNULL_END
