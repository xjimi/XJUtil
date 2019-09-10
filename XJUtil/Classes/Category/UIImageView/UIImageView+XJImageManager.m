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
             completion:(nullable XJImageManagerResultCompletion)completion
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
           cornerRadius:(CGFloat)cornerRadius
             completion:(nullable XJImageManagerResultCompletion)completion
{
    self.image = nil;
    __weak typeof(self)weakSelf = self;
    NSString *placeholder = [XJImagePlaceholderTypes stringFromEnum:placeholderType];
    UIImage *placeholderImage = [UIImage imageNamed:placeholder];
    if (!cornerRadius)
    {
        [self pin_setImageFromURL:url
                 placeholderImage:placeholderImage
                       completion:^(PINRemoteImageManagerResult *result)
         {
             [weakSelf processDownloadAnimated:downloadAnimated
                             remoteImageResult:result
                              resultCompletion:completion];

         }];
    }
    else
    {
        NSString *processorKey = [NSString stringWithFormat:@"rounded_%.1f", cornerRadius];
        CGSize imageViewSize = self.bounds.size;
        __weak typeof(self)weakSelf = self;
        [self pin_setImageFromURL:url
                     processorKey:processorKey
                        processor:^UIImage *(PINRemoteImageManagerResult *result, NSUInteger *cost)
         {
             //已經有 Cache 就不會再進入此 Blcok
             UIImage *image = result.image;
             if (cornerRadius) {
                 image = [weakSelf processImage:image imageViewSize:imageViewSize cornerRadius:cornerRadius];
             }

             dispatch_async(dispatch_get_main_queue(), ^{
                 [weakSelf processDownloadAnimated:downloadAnimated
                                 remoteImageResult:result
                                  resultCompletion:completion];
             });

             return image;
         }];
    }
}

- (void)processDownloadAnimated:(BOOL)downloadAnimated
              remoteImageResult:(PINRemoteImageManagerResult *)result
               resultCompletion:(XJImageManagerResultCompletion)resultCompletion
{
    if (downloadAnimated)
    {
        if (result.resultType == PINRemoteImageResultTypeDownload)
        {
            self.alpha = 0.0f;
            [UIView animateWithDuration:.3 animations:^{
                self.alpha = 1.0f;
            }];
        }
        else
        {
            self.alpha = 1.0f;
        }
    }

    if (resultCompletion) resultCompletion(result);
}

- (UIImage *)processImage:(UIImage *)image imageViewSize:(CGSize)imageViewSize cornerRadius:(CGFloat)cornerRadius
{
    CGSize imageSize = image.size;
    CGRect imageRect = CGRectMake(0, 0, imageViewSize.width, imageViewSize.height);
    UIGraphicsBeginImageContextWithOptions(imageRect.size, NO, [[UIScreen mainScreen] scale]);
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:imageRect cornerRadius:cornerRadius];
    [bezierPath addClip];

    CGFloat sizeMultiplier = MAX(imageViewSize.width / imageSize.width, imageViewSize.height / imageSize.height);
    CGRect drawRect = CGRectMake(0, 0, imageSize.width * sizeMultiplier, imageSize.height * sizeMultiplier);
    if (CGRectGetMaxX(drawRect) > CGRectGetMaxX(imageRect)) {
        drawRect.origin.x -= (CGRectGetMaxX(drawRect) - CGRectGetMaxX(imageRect)) / 2.0;
    }
    if (CGRectGetMaxY(drawRect) > CGRectGetMaxY(imageRect)) {
        drawRect.origin.y -= (CGRectGetMaxY(drawRect) - CGRectGetMaxY(imageRect)) / 2.0;
    }

    [image drawInRect:drawRect];

    UIImage *processedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return processedImage;
}

@end
