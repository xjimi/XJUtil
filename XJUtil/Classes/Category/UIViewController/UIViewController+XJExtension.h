//
//  UIViewController+Extension.h
//  news
//
//  Created by XJIMI on 2019/6/14.
//  Copyright © 2019 XJIMI. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (XJExtension)

- (void)xj_presentViewController:(UIViewController *)viewController
                        animated:(BOOL)flag
                      completion:(void (^)(void))completion;

@end

NS_ASSUME_NONNULL_END
