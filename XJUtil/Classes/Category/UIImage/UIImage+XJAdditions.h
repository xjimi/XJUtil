//
//  UIImage+LSAdditions.h
//  ResourceLoader
//
//  Created by Artem Meleshko on 1/31/15.
//  Copyright (c) 2015 LeshkoApps ( http://leshkoapps.com ). All rights reserved.
//


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (XJAdditions)

+ (UIImage *)imageWithColor:(UIColor *)bgColor size:(CGSize)imageSize;

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

+ (UIImage *)templateImageNamed:(NSString *)name;

- (UIImage*)stretchableImage;

- (UIImage *)imageByApplyingAlpha:(CGFloat)alpha;

@end

NS_ASSUME_NONNULL_END
