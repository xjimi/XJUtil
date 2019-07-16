//
//  XJGradientImageView.h
//  SetTV
//
//  Created by XJIMI on 2015/7/23.
//  Copyright (c) 2015年 XJIMI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XJGradientImageView : UIImageView

- (void)topTransparentWithColor:(UIColor *)color;

- (void)bottomTransparentWithColor:(UIColor *)color;
- (void)bottomTransparentWithColor:(UIColor *)color
                     bottomPadding:(CGFloat)padding;

- (void)topTransparentWithColor:(UIColor *)color endColor:(UIColor *)endColor;

@end
