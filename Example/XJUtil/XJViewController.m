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
#import <XJUtil/UIImageView+XJImageManager.h>
#import <PINRemoteImage/PINRemoteImage.h>

@interface XJViewController ()

@end

@implementation XJViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[PINRemoteImageManager sharedImageManager].defaultImageCache removeAllObjects];

    UIImageView *imageView = [[UIImageView alloc] init];
    //imageView.backgroundColor = [UIColor lightGrayColor];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.frame = CGRectMake(10, 50, 250, 150);
    imageView.clipsToBounds = YES;
    [self.view addSubview:imageView];
    NSURL *URL = [NSURL URLWithString:@"https://setn.s3-ap-northeast-1.amazonaws.com/public/appServices/images/123_0x_0s_2sss.jpg"];
    [imageView xj_imageWithURL:URL placeholderType:XJImagePlaceholderTypeDefault];

    UIImageView *imageView2 = [[UIImageView alloc] init];
    imageView2.contentMode = UIViewContentModeScaleAspectFill;
    imageView2.clipsToBounds = YES;
    CGRect imgRect = imageView.frame;
    imgRect.origin.y = imgRect.origin.y + 10 + imgRect.size.height;
    imageView2.frame = imgRect;
    [self.view addSubview:imageView2];

    NSString *url = @"https://attach.setn.com/adsimages/185358_國美晴空-首頁大圖.jpg";
    [imageView2 xj_imageWithURL:[NSURL URLWithString:url] placeholderType:XJImagePlaceholderTypeNone];

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
