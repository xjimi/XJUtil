//
//  WMPageController.h
//  WMPageController
//
//  Created by Mark on 15/6/11.
//  Copyright (c) 2015年 yq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class WMPageController;

@protocol WMPageControllerDelegate <NSObject>

@required
- (NSUInteger)numberOfPagesInPageViewController:(WMPageController *)pageController;
- (UIViewController *)pageController:(WMPageController *)pageController viewControllerForPageAtIndex:(NSUInteger)pageIndex;

@optional
- (void)pageController:(WMPageController *)pageController didScrollToOffset:(CGPoint)offset;
- (void)pageController:(WMPageController *)pageController didScrollToPageAtIndex:(NSInteger)pageIndex;
@end

/**************************************************************************************************************
 *  WMPageController 的缓存设置，默认缓存为无限制，当收到 memoryWarning 时，会自动切换到低缓存模式 (WMPageControllerCachePolicyLowMemory)，并在一段时间后切换回默认模式.
 收到多次警告后，会停留在到 WMPageControllerCachePolicyLowMemory 不再增长
 **************************************************************************************************************
 *  The Default cache policy is No Limit, when recieved memory warning, page controller will switch mode to 'LowMemory'
    and continue to grow back after a while.
    If recieved too much times, the cache policy will stay at 'LowMemory' and don't grow back any more.
 */
typedef NS_ENUM(NSUInteger, WMPageControllerCachePolicy){
    WMPageControllerCachePolicyNoLimit   = 0,  // No limit
    WMPageControllerCachePolicyLowMemory = 1,  // Low Memory but may block when scroll
    WMPageControllerCachePolicyBalanced  = 3,  // Balanced ↑ and ↓
    WMPageControllerCachePolicyHigh      = 5   // High
};

@interface WMPageController : UIViewController

/**
 *  各个控制器的 class, 例如:[UITableViewController class]
 *  Each controller's class, example:[UITableViewController class]
 */
@property (nonatomic, strong) NSArray *viewControllerClasses;

/**
 *  各个控制器标题, NSString
 *  Titles of view controllers in page controller. Use `NSString`.
 */
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong, readonly) UIViewController *currentViewController;

/**
 *  设置选中几号 item
 *  To select item at index
 */
@property (nonatomic, assign) int selectIndex;

/**
 *  点击相邻的 MenuItem 是否触发翻页动画(当当前选中与点击Item相差大于1是不触发)
 *  Whether to animate when press the MenuItem, if distant between the selected and the pressed is larger than 1,never animate.
 */
@property (nonatomic, assign) BOOL pageAnimatable;

/**
 *  选中时的标题尺寸
 *  The title size when selected (animatable)
 */
@property (nonatomic, assign) CGFloat titleSizeSelected;
/**
 *  非选中时的标题尺寸
 *  The normal title size (animatable)
 */
@property (nonatomic, assign) CGFloat titleSizeNormal;

/**
 *  标题选中时的颜色, 颜色是可动画的.
 *  The title color when selected, the color is animatable.
 */
@property (nonatomic, strong) UIColor *titleColorSelected;
/**
 *  标题非选择时的颜色, 颜色是可动画的.
 *  The title's normal color, the color is animatable.
 */
@property (nonatomic, strong) UIColor *titleColorNormal;

/**
 *  标题的字体名字
 *  The name of title's font
 */
@property (nonatomic, copy) NSString *titleFontName;

/**
 *  是否发送在创建控制器或者视图完全展现在用户眼前时通知观察者，默认为不开启，如需利用通知请开启
 *  Whether notify observer when finish init or fully displayed to user, the default is NO.
 */
@property (nonatomic, assign) BOOL postNotification;

/**
 *  是否记录 Controller 的位置，并在下次回来的时候回到相应位置，默认为 NO (若当前缓存中存在不会触发)
 *  Whether to remember controller's positon if it's a kind of scrollView controller,like UITableViewController,The default value is NO.
 *  比如 `UITabelViewController`, 当然你也可以在自己的控制器中自行设置, 如果将 Controller.view 替换为 scrollView 或者在Controller.view 上添加了一个和自身 bounds 一样的 scrollView 也是OK的
 */
@property (nonatomic, assign) BOOL rememberLocation __deprecated_msg("Because of the cache policy,this property can abondon now.");
/**
 *  缓存的机制，默认为无限制(如果收到内存警告)
 */
@property (nonatomic, assign) WMPageControllerCachePolicy cachePolicy;

@property (nonatomic, weak) id <WMPageControllerDelegate> delegate;

- (void)selectedIndex:(NSInteger)index currentIndex:(NSInteger)currentIndex;


- (void)reloadCurrentController;

@end
