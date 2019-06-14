//
//  UIWindow+Visible.m
//  XJIMI
//
//  Created by XJIMI on 2018/6/18.
//  Copyright © 2018年 XJIMI. All rights reserved.
//

#import "UIWindow+XJVisible.h"

@implementation UIWindow (XJVisible)

+ (UIViewController *)xj_rootViewController {
    return [UIApplication sharedApplication].delegate.window.rootViewController;
}

+ (UIViewController *)xj_rootKeyWindowViewController {
    return [UIApplication sharedApplication].keyWindow.rootViewController;
}

+ (UIViewController *)xj_visibleViewController
{
    UIViewController *rootViewController = [UIWindow xj_rootViewController];
    return [UIWindow xj_getVisibleViewControllerFrom:rootViewController];
}

+ (UIViewController *)xj_visibleKeyWindowViewController
{
    UIViewController *rootViewController = [UIWindow xj_rootKeyWindowViewController];
    return [UIWindow xj_getVisibleViewControllerFrom:rootViewController];
}

+ (UIViewController *)xj_getVisibleViewControllerFrom:(UIViewController *)vc
{
    if ([vc isKindOfClass:[UINavigationController class]])
    {
        return [UIWindow xj_getVisibleViewControllerFrom:[((UINavigationController *) vc) visibleViewController]];
    }
    else if ([vc isKindOfClass:[UITabBarController class]])
    {
        return [UIWindow xj_getVisibleViewControllerFrom:[((UITabBarController *) vc) selectedViewController]];
    }
    else
    {
        if (vc.presentedViewController) {
            return [UIWindow xj_getVisibleViewControllerFrom:vc.presentedViewController];
        } else {
            return vc;
        }
    }
}

@end
