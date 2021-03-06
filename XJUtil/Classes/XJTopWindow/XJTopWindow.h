//
//  XJTopWindow.h
//  search
//
//  Created by XJIMI on 2015/3/11.
//  Copyright (c) 2015年 jimi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface XJTopWindow : NSObject

+ (void)initWithWindowLevel:(UIWindowLevel)windowLevel;

+ (void)showWithViewController:(UIViewController *)viewController;

+ (void)dismiss;

@end

NS_ASSUME_NONNULL_END
