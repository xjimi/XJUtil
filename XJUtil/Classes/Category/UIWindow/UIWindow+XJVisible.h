//
//  UIWindow+Visible.h
//  XJIMI
//
//  Created by XJIMI on 2018/6/18.
//  Copyright © 2018年 XJIMI. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIWindow (XJVisible)

+ (UIViewController *)xj_rootViewController;
+ (UIViewController *)xj_rootKeyWindowViewController;

+ (UIViewController *)xj_visibleViewController;
+ (UIViewController *)xj_visibleKeyWindowViewController;

@end

NS_ASSUME_NONNULL_END
