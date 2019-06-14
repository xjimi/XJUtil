//
//  NSString+MD5.h
//  iMuker
//
//  Created by XJIMI on 2018/6/10.
//  Copyright © 2018年 XJIMI. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (XJExtension)

- (CGFloat)xj_height:(UIFont*)font
            maxWidth:(CGFloat)width;

- (CGFloat)xj_heightForLineSpace:(CGFloat)lSpace
                  characterSpace:(CGFloat)cSpace
                            font:(UIFont*)font
                        maxWidth:(CGFloat)width;

- (CGFloat)xj_heightForAttribute:(NSDictionary *)attributes
                        maxWidth:(CGFloat)width;

- (CGFloat)xj_heightForAttribute:(NSDictionary *)attributes
                          option:(NSStringDrawingOptions)options
                        maxWidth:(CGFloat)width;

- (NSString *)xj_md5;

@end

NS_ASSUME_NONNULL_END
