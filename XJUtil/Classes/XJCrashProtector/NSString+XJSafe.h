//
//  NSString+MSSafe.h
//
//
//  Created by J on 2014/2/27.
//  Copyright © 2014年 J. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (XJSafe)

- (BOOL)isNotEmpty;
- (BOOL)isNotBlank;

@end

NS_ASSUME_NONNULL_END
