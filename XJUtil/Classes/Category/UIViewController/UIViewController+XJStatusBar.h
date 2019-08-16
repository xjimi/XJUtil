//
//  UIViewController+XJStatusBar.h
//  XJUtil
//
//  Created by XJIMI on 2019/8/8.
//



NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (XJStatusBar)

@property (nonatomic, assign) BOOL statusBarHidden;

@property (nonatomic, assign) UIStatusBarAnimation statusBarAnimation;

- (void)setStatusBarHidden:(BOOL)hidden
                 animation:(UIStatusBarAnimation)animation
                completion:(void (^ __nullable)(void))completion;

@end

NS_ASSUME_NONNULL_END
