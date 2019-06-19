//
//  WMPageController.m
//  WMPageController
//
//  Created by Mark on 15/6/11.
//  Copyright (c) 2015年 yq. All rights reserved.
//

#import "WMPageController.h"

@interface WMPageController () < UIScrollViewDelegate > {
    CGFloat viewHeight;
    CGFloat viewWidth;
    CGFloat targetX;
    BOOL    animate;
}
@property (nonatomic, strong, readwrite) UIViewController *currentViewController;

// 用于记录子控制器view的frame，用于 scrollView 上的展示的位置
@property (nonatomic, strong) NSMutableArray *childViewFrames;
// 当前展示在屏幕上的控制器，方便在滚动的时候读取 (避免不必要计算)
@property (nonatomic, strong) NSMutableDictionary *displayVC;
// 用于记录销毁的viewController的位置 (如果它是某一种scrollView的Controller的话)
@property (nonatomic, strong) NSMutableDictionary *posRecords;
// 用于缓存加载过的控制器
@property (nonatomic, strong) NSCache *memCache;
// 收到内存警告的次数
@property (nonatomic, assign) int memoryWarningCount;

@end

@implementation WMPageController

#pragma mark - Lazy Loading
- (NSMutableDictionary *)posRecords {
    if (_posRecords == nil) {
        _posRecords = [[NSMutableDictionary alloc] init];
    }
    return _posRecords;
}
- (NSMutableDictionary *)displayVC {
    if (_displayVC == nil) {
        _displayVC = [[NSMutableDictionary alloc] init];
    }
    return _displayVC;
}

#pragma mark - Public Methods

- (instancetype)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (void)setCachePolicy:(WMPageControllerCachePolicy)cachePolicy {
    _cachePolicy = cachePolicy;
    self.memCache.countLimit = _cachePolicy;
}

- (void)setSelectIndex:(int)selectIndex {
    _selectIndex = selectIndex;
}

#pragma mark - Private Methods

// 当子控制器init完成时发送通知
- (void)postAddToSuperViewNotificationWithIndex:(NSInteger)index {
    /*
     if (!self.postNotification) return;
     NSDictionary *info = @{
     @"index":@(index),
     @"title":self.titles[index]
     };
     [[NSNotificationCenter defaultCenter] postNotificationName:WMControllerDidAddToSuperViewNotification
     object:info];*/
}

// 当子控制器完全展示在user面前时发送通知
- (void)postFullyDisplayedNotificationWithCurrentIndex:(int)index {
    /*
     if (!self.postNotification) return;
     NSDictionary *info = @{
     @"index":@(index),
     @"title":self.titles[index]
     };
     [[NSNotificationCenter defaultCenter] postNotificationName:WMControllerDidFullyDisplayedNotification
     object:info];*/
}

// 初始化一些参数，在init中调用
- (void)setup {
    // cache
    _pageAnimatable = YES;
    self.memCache = [[NSCache alloc] init];
}

// 包括宽高，子控制器视图frame
- (void)calculateSize
{
    CGSize size = self.view.frame.size;
    viewHeight = size.height;
    viewWidth = size.width;
    
    // 重新计算各个控制器视图的宽高
    _childViewFrames = [NSMutableArray array];
    
    NSInteger pages = [self.delegate numberOfPagesInPageViewController:self];
    for (int i = 0; i < pages; i++) {
        CGRect frame = CGRectMake(i*viewWidth, 0, viewWidth, viewHeight);
        [_childViewFrames addObject:[NSValue valueWithCGRect:frame]];
    }
}

- (void)addScrollView
{
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.pagingEnabled = YES;
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.delegate = self;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.alwaysBounceHorizontal = NO;
    scrollView.alwaysBounceVertical = NO;
    scrollView.scrollsToTop = NO;
    scrollView.directionalLockEnabled = YES;
    scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
}

- (void)layoutChildViewControllersCanAdd:(BOOL)canAdd
{
    NSInteger pages = [self.delegate numberOfPagesInPageViewController:self];
    NSInteger currentPage = (NSInteger)self.scrollView.contentOffset.x / viewWidth;
    NSInteger start = currentPage == 0 ? currentPage : (currentPage - 1);
    NSInteger end = (currentPage == pages - 1) ? currentPage : (currentPage + 1);
    for (NSInteger i = start; i <= end; i++)
    {
        CGRect frame = [self.childViewFrames[i] CGRectValue];
        UIViewController *vc = [self.displayVC objectForKey:@(i)];
        if ([self isInScreen:frame])
        {
            if (vc == nil) {
                // 先从 cache 中取
                vc = [self.memCache objectForKey:@(i)];
                if (vc)
                {
                    // cache 中存在，添加到 scrollView 上，并放入display
                    [self addCachedViewController:vc atIndex:i];
                }
                else
                {
                    // cache 中也不存在，创建并添加到display
                    if (canAdd) [self addViewControllerAtIndex:i];
                }
                [self postAddToSuperViewNotificationWithIndex:i];
            }
        }else{
            if (vc) {
                // vc不在视野中且存在，移除他
                [self removeViewController:vc atIndex:i];
            }
        }
    }
}

- (void)removeSuperfluousViewControllersIfNeeded {
    [self.displayVC enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, UIViewController * _Nonnull vc, BOOL * _Nonnull stop) {
        NSInteger index = key.integerValue;
        CGRect frame = [self.childViewFrames[index] CGRectValue];
        if (![self isInScreen:frame]) {
            [self removeViewController:vc atIndex:index];
        }
    }];
}

- (void)addCachedViewController:(UIViewController *)viewController atIndex:(NSInteger)index {
    [self addChildViewController:viewController];
    viewController.view.frame = [self.childViewFrames[index] CGRectValue];
    [viewController didMoveToParentViewController:self];
    [self.scrollView addSubview:viewController.view];
    [self.displayVC setObject:viewController forKey:@(index)];
}

// 添加子控制器
- (void)addViewControllerAtIndex:(NSInteger)index
{
    //Class vcClass = self.viewControllerClasses[index];
    UIViewController *viewController = [self.delegate pageController:self viewControllerForPageAtIndex:index];
    [self addChildViewController:viewController];
    viewController.view.frame = [self.childViewFrames[index] CGRectValue];
    [viewController didMoveToParentViewController:self];
    [self.scrollView addSubview:viewController.view];
    [self.displayVC setObject:viewController forKey:@(index)];
    [self backToPositionIfNeeded:viewController atIndex:index];
}

// 移除控制器，且从display中移除
- (void)removeViewController:(UIViewController *)viewController atIndex:(NSInteger)index {
    [self rememberPositionIfNeeded:viewController atIndex:index];
    [viewController.view removeFromSuperview];
    [viewController willMoveToParentViewController:nil];
    [viewController removeFromParentViewController];
    [self.displayVC removeObjectForKey:@(index)];
    
    // 放入缓存
    if (![self.memCache objectForKey:@(index)]) {
        [self.memCache setObject:viewController forKey:@(index)];
    }
}

- (void)backToPositionIfNeeded:(UIViewController *)controller atIndex:(NSInteger)index {
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
    if (!self.rememberLocation) return;
#pragma clang diagnostic pop
    if ([self.memCache objectForKey:@(index)]) return;
    UIScrollView *scrollView = [self isKindOfScrollViewController:controller];
    if (scrollView) {
        NSValue *pointValue = self.posRecords[@(index)];
        if (pointValue) {
            CGPoint pos = [pointValue CGPointValue];
            // 奇怪的现象，我发现collectionView的contentSize是 {0, 0};
            [scrollView setContentOffset:pos];
        }
    }
}

- (void)rememberPositionIfNeeded:(UIViewController *)controller atIndex:(NSInteger)index {
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
    if (!self.rememberLocation) return;
#pragma clang diagnostic pop
    UIScrollView *scrollView = [self isKindOfScrollViewController:controller];
    if (scrollView) {
        CGPoint pos = scrollView.contentOffset;
        self.posRecords[@(index)] = [NSValue valueWithCGPoint:pos];
    }
}

- (UIScrollView *)isKindOfScrollViewController:(UIViewController *)controller {
    UIScrollView *scrollView = nil;
    if ([controller.view isKindOfClass:[UIScrollView class]]) {
        // Controller的view是scrollView的子类(UITableViewController/UIViewController替换view为scrollView)
        scrollView = (UIScrollView *)controller.view;
    }else if (controller.view.subviews.count >= 1) {
        // Controller的view的subViews[0]存在且是scrollView的子类，并且frame等与view得frame(UICollectionViewController/UIViewController添加UIScrollView)
        UIView *view = controller.view.subviews[0];
        if ([view isKindOfClass:[UIScrollView class]]) {
            scrollView = (UIScrollView *)view;
        }
    }
    return scrollView;
}

- (BOOL)isInScreen:(CGRect)frame {
    CGFloat x = frame.origin.x;
    CGFloat ScreenWidth = self.scrollView.frame.size.width;
    
    CGFloat contentOffsetX = self.scrollView.contentOffset.x;
    if (CGRectGetMaxX(frame) > contentOffsetX && x-contentOffsetX < ScreenWidth) {
        return YES;
    }else{
        return NO;
    }
}

- (void)growCachePolicyAfterMemoryWarning {
    self.cachePolicy = WMPageControllerCachePolicyBalanced;
    [self performSelector:@selector(growCachePolicyToHigh) withObject:nil afterDelay:2.0 inModes:@[NSRunLoopCommonModes]];
}

- (void)growCachePolicyToHigh {
    self.cachePolicy = WMPageControllerCachePolicyHigh;
}

#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self addScrollView];
    [self addViewControllerAtIndex:self.selectIndex];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self calculateSize];
    CGRect scrollFrame = CGRectMake(0, 0, viewWidth, viewHeight);
    self.scrollView.frame = scrollFrame;
    
    NSInteger pages = [self.delegate numberOfPagesInPageViewController:self];
    self.scrollView.contentSize = CGSizeMake(pages*viewWidth, viewHeight);
    [self.scrollView setContentOffset:CGPointMake(self.selectIndex*viewWidth, 0)];
    
    self.currentViewController.view.frame = [self.childViewFrames[self.selectIndex] CGRectValue];
    [self.view layoutIfNeeded];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self reloadCurrentController];
    [self postFullyDisplayedNotificationWithCurrentIndex:self.selectIndex];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    self.memoryWarningCount++;
    self.cachePolicy = WMPageControllerCachePolicyLowMemory;
    // 取消正在增长的 cache 操作
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(growCachePolicyAfterMemoryWarning) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(growCachePolicyToHigh) object:nil];
    
    [self.memCache removeAllObjects];
    [self.posRecords removeAllObjects];
    self.posRecords = nil;
    
    // 如果收到内存警告次数小于 3，一段时间后切换到模式 Balanced
    if (self.memoryWarningCount < 3) {
        [self performSelector:@selector(growCachePolicyAfterMemoryWarning) withObject:nil afterDelay:3.0 inModes:@[NSRunLoopCommonModes]];
    }
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self layoutChildViewControllersCanAdd:NO];
    if ([self.delegate respondsToSelector:@selector(pageController:didScrollToOffset:)]) {
        [self.delegate pageController:self didScrollToOffset:scrollView.contentOffset];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _selectIndex = (int)scrollView.contentOffset.x / viewWidth;
    [self removeSuperfluousViewControllersIfNeeded];
    self.currentViewController = self.displayVC[@(self.selectIndex)];
    
    [self postFullyDisplayedNotificationWithCurrentIndex:self.selectIndex];
    [self layoutChildViewControllersCanAdd:YES];
    if ([self.delegate respondsToSelector:@selector(pageController:didScrollToPageAtIndex:)]) {
        [self.delegate pageController:self didScrollToPageAtIndex:self.selectIndex];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self postFullyDisplayedNotificationWithCurrentIndex:self.selectIndex];
    [self removeSuperfluousViewControllersIfNeeded];
    [self layoutChildViewControllersCanAdd:YES];
    if ([self.delegate respondsToSelector:@selector(pageController:didScrollToPageAtIndex:)]) {
        [self.delegate pageController:self didScrollToPageAtIndex:self.selectIndex];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        //CGFloat rate = targetX / viewWidth;
        [self removeSuperfluousViewControllersIfNeeded];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    targetX = targetContentOffset->x;
}

- (void)selectedIndex:(NSInteger)index currentIndex:(NSInteger)currentIndex
{
    NSInteger gap = (NSInteger)labs(index - currentIndex);
    CGPoint targetP = CGPointMake(viewWidth*index, 0);
    [self.scrollView setContentOffset:targetP animated:self.pageAnimatable];
    if (gap > 1 || !self.pageAnimatable) {
        //[self postFullyDisplayedNotificationWithCurrentIndex:(int)index];
        // 由于不触发-scrollViewDidScroll: 手动清除控制器..
        UIViewController *vc = [self.displayVC objectForKey:@(currentIndex)];
        if (vc) {
            [self removeViewController:vc atIndex:currentIndex];
        }
    }
    _selectIndex = (int)index;
    self.currentViewController = self.displayVC[@(self.selectIndex)];
}

- (void)reloadCurrentController
{
    if ([self.delegate respondsToSelector:@selector(pageController:didScrollToPageAtIndex:)]) {
        [self.delegate pageController:self didScrollToPageAtIndex:self.selectIndex];
    }
}

@end
