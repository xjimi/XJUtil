//
//  UIViewController+Extension.m
//  news
//
//  Created by XJIMI on 2019/6/14.
//  Copyright © 2019 XJIMI. All rights reserved.
//

#import "UIViewController+XJExtension.h"

@implementation UIViewController (XJExtension)

- (void)xj_presentViewController:(UIViewController *)viewController
                        animated:(BOOL)flag
                      completion:(void (^)(void))completion
{
    viewController = viewController.presentedViewController ? : viewController;
    [self presentViewController:viewController animated:flag completion:completion];
}

@end
