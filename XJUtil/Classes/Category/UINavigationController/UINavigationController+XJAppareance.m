//
//  UINavigationController+XJAppareance.m
//  XJUtil_Example
//
//  Created by XJIMI on 2019/8/16.
//  Copyright © 2019 xjimi. All rights reserved.
//

#import "UINavigationController+XJAppareance.h"

@implementation UINavigationController (XJAppareance)

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [self.topViewController supportedInterfaceOrientations];
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.topViewController;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.topViewController;
}

@end
