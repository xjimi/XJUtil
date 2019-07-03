//
//  WMScrollView.m
//  XJUtil
//
//  Created by XJIMI on 2019/7/3.
//

#import "WMScrollView.h"

@implementation WMScrollView

#pragma mark - <UIGestureRecognizerDelegate>

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    //MARK: UITableViewCell 删除手势
    if ([NSStringFromClass(otherGestureRecognizer.view.class) isEqualToString:@"UITableViewWrapperView"] && [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        return YES;
    }
    return NO;
}

@end
