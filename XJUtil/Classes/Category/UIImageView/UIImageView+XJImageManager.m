//
//  UIImageView+ImageManager.m
//  iMuker
//
//  Created by XJIMI on 2018/8/24.
//  Copyright © 2018年 XJIMI. All rights reserved.
//

#import "UIImageView+XJImageManager.h"
#import "NSArray+XJEnumExtensions.h"

@implementation UIImageView (XJImageManager)

- (void)xj_imageWithURL:(NSURL *)url
{
    [self xj_imageWithURL:url
          placeholderType:XJImagePlaceholderTypeNone];
}

- (void)xj_imageWithURL:(NSURL *)url
        placeholderType:(XJImagePlaceholderType)placeholderType
{
    [self xj_imageWithURL:url
          placeholderType:placeholderType
               completion:nil];
}

- (void)xj_imageWithURL:(NSURL *)url
        placeholderType:(XJImagePlaceholderType)placeholderType
           cornerRadius:(CGFloat)radius
{
    [self xj_imageWithURL:url
          placeholderType:placeholderType
         downloadAnimated:YES
             cornerRadius:radius
               completion:nil];
}

- (void)xj_imageWithURL:(NSURL *)url
        placeholderType:(XJImagePlaceholderType)placeholderType
             completion:(nullable XJImageManagerCompletion)completion
{
    [self xj_imageWithURL:url
          placeholderType:placeholderType
         downloadAnimated:YES
             cornerRadius:0
               completion:completion];
}

- (void)xj_imageWithURL:(NSURL *)url
        placeholderType:(XJImagePlaceholderType)placeholderType
       downloadAnimated:(BOOL)downloadAnimated
           cornerRadius:(CGFloat)radius
             completion:(nullable XJImageManagerCompletion)completion
{
    /*
    self.image = nil;
    __weak typeof(self)weakSelf = self;
    NSString *placeholder = [XJImagePlaceholderTypes stringFromEnum:placeholderType];
    UIImage *placeholderImage = [UIImage imageNamed:placeholder];

    [self pin_setImageFromURL:url
             placeholderImage:placeholderImage
                   completion:^(PINRemoteImageManagerResult *result)
     {
         
         if (downloadAnimated)
         {
             if (result.resultType == PINRemoteImageResultTypeDownload)
             {
                 weakSelf.alpha = 0.0f;
                 [UIView animateWithDuration:.6 animations:^{
                     weakSelf.alpha = 1.0f;
                 }];
             }
             else
             {
                 weakSelf.alpha = 1.0f;
             }
         }

         if (completion) completion(result.image);

     }];*/
}


@end
