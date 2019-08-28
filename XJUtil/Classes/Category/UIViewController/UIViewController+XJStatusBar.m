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

- (void)setStatusBarHidden:(BOOL)hidden
                 animation:(UIStatusBarAnimation)animation
                completion:(void (^ __nullable)(void))completion
{
    self.statusBarHidden = hidden;
    self.statusBarAnimation = animation;
    CGFloat statusBarH = [UIApplication sharedApplication].statusBarFrame.size.height;
    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{

        [self setNeedsStatusBarAppearanceUpdate];

    } completion:^(BOOL finished) {

        NSTimeInterval time = (statusBarH == 40.0f) ? 0.3f : 0.15f;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (completion) completion();
        });

    }];
}

#pragma mark - prefers

- (BOOL)prefersStatusBarHidden {
    return self.statusBarHidden;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return self.statusBarAnimation;
}

#pragma mark - Setter & Getter Property

- (void)setStatusBarHidden:(BOOL)statusBarHidden
{
    NSNumber *number = [NSNumber numberWithBool:statusBarHidden];
    objc_setAssociatedObject(self, kXJStatusBarHidden, number, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)statusBarHidden
{
    NSNumber *number = objc_getAssociatedObject(self, kXJStatusBarHidden);
    return [number boolValue];
}

- (void)setStatusBarAnimation:(UIStatusBarAnimation)statusBarAnimation
{
    NSNumber *number = [NSNumber numberWithInteger:statusBarAnimation];
    objc_setAssociatedObject(self, kXJStatusBarAnimation, number, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIStatusBarAnimation)statusBarAnimation
{
    NSNumber *number = objc_getAssociatedObject(self, kXJStatusBarAnimation);
    return [number integerValue];
}

@end
