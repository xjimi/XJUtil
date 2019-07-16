//
//  GradientView.m
//  Waker
//
//  Created by XJIMI on 2014/3/23.
//  Copyright (c) 2014年 xjimi. All rights reserved.
//

#import "GradientView.h"

@interface GradientView ()

@end

@implementation GradientView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setGradientColors:(NSArray *)gradientColors
{
    _gradientColors = gradientColors;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    NSMutableArray *colors = nil;
    if (self.gradientColors)
    {
        colors = [NSMutableArray arrayWithCapacity:self.gradientColors.count];
        for (UIColor *gcolor in self.gradientColors) {
            [colors addObject:(id)gcolor.CGColor];
        }
    }
    else
    {
        UIColor *topColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        UIColor *cenColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.25];
        UIColor *endColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        colors = @[(id)topColor.CGColor, (id)cenColor.CGColor, (id)endColor.CGColor].mutableCopy;
    }
    
    CGGradientRef gradient = CGGradientCreateWithColors(CGColorSpaceCreateDeviceRGB(), (CFArrayRef)colors, NULL);
    CGContextDrawLinearGradient(context, gradient, CGPointZero, CGPointMake(0.0f, rect.size.height), kCGGradientDrawsAfterEndLocation);
    CGGradientRelease(gradient);
}

- (void)drawInContext:(CGContextRef)ctx
{
    //圓形 中間空旁邊黑
    size_t gradLocationsNum = 2;
    CGFloat gradLocations[2] = {0.0f, 1.0f};
    CGFloat gradColors[8] = {0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.5f};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, gradColors, gradLocations, gradLocationsNum);
    CGColorSpaceRelease(colorSpace);
    
    CGPoint gradCenter= CGPointMake(self.bounds.size.width, self.bounds.size.height/6);
    float gradRadius = MIN(self.bounds.size.width , self.bounds.size.height) ;
    
    CGContextDrawRadialGradient (ctx, gradient, gradCenter, 0, gradCenter, gradRadius, kCGGradientDrawsAfterEndLocation);
    
    
    CGGradientRelease(gradient);
}

@end
