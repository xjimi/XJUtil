//
//  NSMutableSet+MSSafe.h
//  
//
//  Created by J on 2014/2/27.
//  Copyright © 2014年 J. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableSet(XJSafe)

// 排除nil
- (void)addObjectSafe:(id)object;

- (void)removeObjectSafe:(id)object;

@end

NS_ASSUME_NONNULL_END
