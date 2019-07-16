//
//  XJGradientImageView.m
//  SetTV
//
//  Created by XJIMI on 2015/7/23.
//  Copyright (c) 2015年 XJIMI. All rights reserved.
//

#import "XJGradientImageView.h"
#import "GradientView.h"

@interface XJGradientImageView ()

@property (nonatomic, strong) GradientView *topGradientView;
@property (nonatomic, strong) GradientView *bottomGradientView;
@property (nonatomic, strong) GradientView *rightGradientView;
@property (nonatomic, assign) CGFloat bottomPadding;
@property (nonatomic, strong) UIView *bottomView;


@end

@implementation XJGradientImageView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
    }
    return self;
}

- (GradientView *)topGradientView
{
    if (!_topGradientView)
    {
        GradientView *gradientView = [[GradientView alloc] initWithFrame:self.bounds];
        _topGradientView = gradientView;
    }
    return _topGradientView;
}

- (GradientView *)bottomGradientView
{
    if (!_bottomGradientView)
    {
        GradientView *gradientView = [[GradientView alloc] initWithFrame:self.bounds];
        _bottomGradientView = gradientView;
    }
    return _bottomGradientView;
}

- (GradientView *)rightGradientView
{
    if (!_rightGradientView)
    {
        GradientView *gradientView = [[GradientView alloc] initWithFrame:self.bounds];
        _rightGradientView = gradientView;
    }
    return _rightGradientView;
}

- (UIView *)bottomView
{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
    }

    return _bottomView;
}

- (void)topTransparentWithColor:(UIColor *)color
{
    [self topTransparentWithColor:color endColor:nil];
}

- (void)topTransparentWithColor:(UIColor *)color endColor:(UIColor *)endColor
{
    if (color)
    {
        endColor = endColor ? : [color colorWithAlphaComponent:0];
        self.topGradientView.gradientColors = @[color, endColor];
        if(![self isDescendantOfView:self.topGradientView]) {
            [self addSubview:self.topGradientView];
        }
    }
    else
    {
        [self.topGradientView removeFromSuperview];
        self.topGradientView.gradientColors = nil;
        self.topGradientView = nil;
    }
    [self setNeedsDisplay];
}


- (void)bottomTransparentWithColor:(UIColor *)color {
    [self bottomTransparentWithColor:color bottomPadding:0];
}

- (void)bottomTransparentWithColor:(UIColor *)color
                     bottomPadding:(CGFloat)padding
{
    if (color)
    {
        if (padding)
        {
            self.bottomPadding = padding;
            self.bottomView.backgroundColor = color;
            [self.bottomGradientView addSubview:self.bottomView];
        }
        UIColor *endColor = [color colorWithAlphaComponent:0];
        self.bottomGradientView.gradientColors = @[endColor ,color];
        if(![self isDescendantOfView:self.bottomGradientView]) {
            [self addSubview:self.bottomGradientView];
        }
    } else {
        [self.bottomGradientView removeFromSuperview];
        self.bottomGradientView.gradientColors = nil;
        self.bottomGradientView = nil;
    }
    [self setNeedsDisplay];
}


- (void)rightTransparentWithColor:(UIColor *)color
{
    if (color)
    {
        CGFloat alpha = CGColorGetAlpha(color.CGColor);
        /*
        self.rightGradientView.gradientColors = @[[color colorWithAlphaComponent:0.0f],
                                                  [color colorWithAlphaComponent:alpha]];
        if(![self isDescendantOfView:self.rightGradientView]) {
            [self addSubview:self.rightGradientView];
         */
        if(![self isDescendantOfView:self.rightGradientView]) {
            [self addSubview:self.rightGradientView];
        }
        CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
        CGRect layerFrame = gradientLayer.frame;
        layerFrame.size = self.rightGradientView.frame.size;
        gradientLayer.frame = layerFrame;
        gradientLayer.colors = @[[color colorWithAlphaComponent:0.0f],
                                 [color colorWithAlphaComponent:alpha]];
        gradientLayer.startPoint = CGPointMake(0, 1);
        gradientLayer.endPoint = CGPointMake(1.0, 1.0);
        [self.rightGradientView.layer addSublayer:gradientLayer];
    }
    else
    {
        [self.rightGradientView removeFromSuperview];
        self.rightGradientView.gradientColors = nil;
        self.rightGradientView = nil;
    }
    [self setNeedsDisplay];
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_topGradientView)
    {
        CGFloat width = self.bounds.size.width;
        CGFloat height = self.bounds.size.height * .5;
        self.topGradientView.frame = CGRectMake(0, 0, width, height);
    }
    
    if (_bottomGradientView)
    {
        CGRect frame = self.bounds;
        if (self.bottomPadding)
        {
            CGRect bottomViewFrame = self.bounds;
            bottomViewFrame.size.height = frame.size.height - self.bottomPadding;
            bottomViewFrame.origin.y = bottomViewFrame.size.height;
            self.bottomView.frame = bottomViewFrame;
            frame.size.height = bottomViewFrame.size.height;
        }
        self.bottomGradientView.frame = frame;
    }
    
    if (_rightGradientView) {
        self.rightGradientView.frame = self.bounds;
    }
}

@end
