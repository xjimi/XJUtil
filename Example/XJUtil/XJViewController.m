//
//  XJViewController.m
//  XJUtil
//
//  Created by xjimi on 06/14/2019.
//  Copyright (c) 2019 xjimi. All rights reserved.
//

#import "XJViewController.h"
#import "UIViewController+XJExtension.h"
#import "UIWindow+XJVisible.h"
#import "UIViewController+XJStatusBar.h"

@interface XJViewController ()

@end

@implementation XJViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setStatusBarHidden:YES animation:UIStatusBarAnimationSlide completion:^{
            NSLog(@"completion!!");
        }];

    });
}

- (BOOL)prefersStatusBarHidden {
    return [super prefersStatusBarHidden];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

@end
