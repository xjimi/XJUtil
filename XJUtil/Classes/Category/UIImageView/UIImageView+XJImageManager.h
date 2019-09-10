//
//  UIImageView+ImageManager.h
//  iMuker
//
//  Created by XJIMI on 2018/8/24.
//  Copyright © 2018年 XJIMI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PINRemoteImage/PINImageView+PINRemoteImage.h>

typedef NS_ENUM(NSUInteger, XJImagePlaceholderType) {
    XJImagePlaceholderTypeNone,
    XJImagePlaceholderTypeDefault,
    XJImagePlaceholderTypeMedium,
    XJImagePlaceholderTypeHigh
};

#define XJImagePlaceholderTypes @[@"none", @"placeholder_default", @"placeholder_medium", @"placeholder_high"]

NS_ASSUME_NONNULL_BEGIN

typedef void (^XJImageManagerResultCompletion)(PINRemoteImageManagerResult *result);

@interface UIImageView (XJImageManager)

- (void)xj_imageWithURL:(NSURL *)url;

- (void)xj_imageWithURL:(NSURL *)url
        placeholderType:(XJImagePlaceholderType)placeholderType;

- (void)xj_imageWithURL:(NSURL *)url
        placeholderType:(XJImagePlaceholderType)placeholderType
           cornerRadius:(CGFloat)radius;

- (void)xj_imageWithURL:(NSURL *)url
        placeholderType:(XJImagePlaceholderType)placeholderType
             completion:(nullable XJImageManagerResultCompletion)completion;

- (void)xj_imageWithURL:(NSURL *)url
        placeholderType:(XJImagePlaceholderType)placeholderType
       downloadAnimated:(BOOL)downloadAnimated
           cornerRadius:(CGFloat)radius
             completion:(nullable XJImageManagerResultCompletion)completion;

@end

NS_ASSUME_NONNULL_END
