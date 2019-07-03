//
//  UINavigationController+StatusBarStyle.m
//  Vidol
//
//  Created by XJIMI on 2017/3/30.
//  Copyright © 2017年 XJIMI. All rights reserved.
//

#import "UINavigationController+StatusBarStyle.h"

@implementation UINavigationController (StatusBarStyle)

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.topViewController;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.topViewController;
}

@end
