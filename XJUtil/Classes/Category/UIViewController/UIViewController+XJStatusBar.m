//
//  UIViewController+XJStatusBar.m
//  XJUtil
//
//  Created by XJIMI on 2019/8/8.
//

#import "UIViewController+XJStatusBar.h"
#import <objc/runtime.h>

static char const * const kXJStatusBarHidden = "StatusBarHidden";
static char const * const kXJStatusBarAnimation = "StatusBarAnimation";

@implementation UIViewController (XJStatusBar)

- (void)setStatusBarHidden:(BOOL)hidden animation:(UIStatusBarAnimation)animation
{
    self.statusBarHidden = hidden;
    self.statusBarAnimation = animation;
    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self setNeedsStatusBarAppearanceUpdate];
    } completion:^(BOOL finished) {
    }];
}

#pragma mark - prefers

- (BOOL)prefersStatusBarHidden {
    return self.statusBarHidden;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return self.statusBarAnimation;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Setter & Getter Property

- (void)setStatusBarHidden:(BOOL)statusBarHidden
{
    NSNumber *number = [NSNumber numberWithBool:statusBarHidden];
    objc_setAssociatedObject(self, &kXJStatusBarHidden, number, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)statusBarHidden
{
    NSNumber *number = objc_getAssociatedObject(self, kXJStatusBarHidden);
    return [number boolValue];
}

- (void)setStatusBarAnimation:(UIStatusBarAnimation)statusBarAnimation
{
    NSNumber *number = [NSNumber numberWithBool:statusBarAnimation];
    objc_setAssociatedObject(self, &kXJStatusBarAnimation, number, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIStatusBarAnimation)statusBarAnimation
{
    NSNumber *number = objc_getAssociatedObject(self, kXJStatusBarAnimation);
    return [number boolValue];
}

@end
