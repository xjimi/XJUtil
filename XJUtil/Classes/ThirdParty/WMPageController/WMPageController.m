//
//  WMPageController.m
//  WMPageController
//
//  Created by Mark on 15/6/11.
//  Copyright (c) 2015年 yq. All rights reserved.
//

#import "WMPageController.h"

NSString *const WMControllerDidAddToSuperViewNotification = @"WMControllerDidAddToSuperViewNotification";
NSString *const WMControllerDidFullyDisplayedNotification = @"WMControllerDidFullyDisplayedNotification";

static NSInteger const kWMUndefinedIndex = -1;
static NSInteger const kWMControllerCountUndefined = -1;
@interface WMPageController () {
    CGFloat _targetX;
    CGRect  _contentViewFrame;
    BOOL    _hasInited, _shouldNotScroll;
    NSInteger _initializedIndex, _controllerCount, _markedSelectIndex;
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
@property (nonatomic, strong) NSMutableDictionary *backgroundCache;
// 收到内存警告的次数
@property (nonatomic, assign) int memoryWarningCount;
@property (nonatomic, readonly) NSInteger childControllersCount;
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

- (NSMutableDictionary *)backgroundCache {
    if (_backgroundCache == nil) {
        _backgroundCache = [[NSMutableDictionary alloc] init];
    }
    return _backgroundCache;
}

#pragma mark - Public Methods
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self wm_setup];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self wm_setup];
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        [self wm_setup];
    }
    return self;
}

- (instancetype)initWithViewControllerClasses:(NSArray<Class> *)classes {
    if (self = [self initWithNibName:nil bundle:nil]) {
        _viewControllerClasses = [NSArray arrayWithArray:classes];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(wm_growCachePolicyAfterMemoryWarning) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(wm_growCachePolicyToHigh) object:nil];
}

- (void)forceLayoutSubviews {
    if (!self.childControllersCount) return;
    // 计算宽高及子控制器的视图frame
    [self wm_calculateSize];
    [self wm_adjustScrollViewFrame];
    [self wm_adjustDisplayingViewControllersFrame];
}

- (void)setScrollEnable:(BOOL)scrollEnable {
    _scrollEnable = scrollEnable;

    if (!self.scrollView) return;
    self.scrollView.scrollEnabled = scrollEnable;
}

- (void)setCachePolicy:(WMPageControllerCachePolicy)cachePolicy {
    _cachePolicy = cachePolicy;
    if (cachePolicy != WMPageControllerCachePolicyDisabled) {
        self.memCache.countLimit = _cachePolicy;
    }
}

- (void)setSelectIndex:(int)selectIndex {
    _selectIndex = selectIndex;
    _markedSelectIndex = kWMUndefinedIndex;
    if (!_hasInited) {
        _markedSelectIndex = selectIndex;
        UIViewController *vc = [self.memCache objectForKey:@(selectIndex)];
        if (!vc) {
            vc = [self initializeViewControllerAtIndex:selectIndex];
            [self.memCache setObject:vc forKey:@(selectIndex)];
        }
        self.currentViewController = vc;
    }
}

- (void)reloadData {
    [self wm_clearDatas];

    if (!self.childControllersCount) return;

    [self wm_resetScrollView];
    [self.memCache removeAllObjects];
    [self viewDidLayoutSubviews];
    [self didEnterController:self.currentViewController atIndex:self.selectIndex];
}

#pragma mark - Notification
- (void)willResignActive:(NSNotification *)notification {
    for (int i = 0; i < self.childControllersCount; i++) {
        id obj = [self.memCache objectForKey:@(i)];
        if (obj) {
            [self.backgroundCache setObject:obj forKey:@(i)];
        }
    }
}

- (void)willEnterForeground:(NSNotification *)notification {
    for (NSNumber *key in self.backgroundCache.allKeys) {
        if (![self.memCache objectForKey:key]) {
            [self.memCache setObject:self.backgroundCache[key] forKey:key];
        }
    }
    [self.backgroundCache removeAllObjects];
}

#pragma mark - Delegate

- (NSDictionary *)infoWithIndex:(NSInteger)index {
    return @{@"index": @(index)};
}

- (void)willCachedController:(UIViewController *)vc atIndex:(NSInteger)index {
    if (self.childControllersCount && [self.delegate respondsToSelector:@selector(pageController:willCachedViewController:atIndex:)]) {
        [self.delegate pageController:self willCachedViewController:vc atIndex:index];
    }
}

- (void)willEnterController:(UIViewController *)vc atIndex:(NSInteger)index {
    _selectIndex = (int)index;
    if (self.childControllersCount && [self.delegate respondsToSelector:@selector(pageController:willEnterViewController:atIndex:)]) {
        [self.delegate pageController:self willEnterViewController:vc atIndex:index];
    }
}

// 完全进入控制器 (即停止滑动后调用)
- (void)didEnterController:(UIViewController *)vc atIndex:(NSInteger)index {
    if (!self.childControllersCount) return;

    // Post FullyDisplayedNotification
    [self wm_postFullyDisplayedNotificationWithCurrentIndex:self.selectIndex];

    if ([self.delegate respondsToSelector:@selector(pageController:didEnterViewController:atIndex:)]) {
        [self.delegate pageController:self didEnterViewController:vc atIndex:index];
    }

    // 当控制器创建时，调用延迟加载的代理方法
    if (_initializedIndex == index && [self.delegate respondsToSelector:@selector(pageController:lazyLoadViewController:atIndex:)]) {
        [self.delegate pageController:self lazyLoadViewController:vc atIndex:index];
        _initializedIndex = kWMUndefinedIndex;
    }

    // 根据 preloadPolicy 预加载控制器
    if (self.preloadPolicy == WMPageControllerPreloadPolicyNever) return;
    int length = (int)self.preloadPolicy;
    int start = 0;
    int end = (int)self.childControllersCount - 1;
    if (index > length) {
        start = (int)index - length;
    }
    if (self.childControllersCount - 1 > length + index) {
        end = (int)index + length;
    }
    for (int i = start; i <= end; i++) {
        // 如果已存在，不需要预加载
        if (![self.memCache objectForKey:@(i)] && !self.displayVC[@(i)]) {
            [self wm_addViewControllerAtIndex:i];
            [self wm_postAddToSuperViewNotificationWithIndex:i];
        }
    }
    _selectIndex = (int)index;
}

#pragma mark - Data source
- (NSInteger)childControllersCount {
    if (_controllerCount == kWMControllerCountUndefined) {
        if ([self.dataSource respondsToSelector:@selector(numbersOfChildControllersInPageController:)]) {
            _controllerCount = [self.dataSource numbersOfChildControllersInPageController:self];
        } else {
            _controllerCount = self.viewControllerClasses.count;
        }
    }
    return _controllerCount;
}

- (UIViewController * _Nonnull)initializeViewControllerAtIndex:(NSInteger)index {
    if ([self.dataSource respondsToSelector:@selector(pageController:viewControllerAtIndex:)]) {
        return [self.dataSource pageController:self viewControllerAtIndex:index];
    }
    return [[self.viewControllerClasses[index] alloc] init];
}

#pragma mark - Private Methods

- (void)wm_resetScrollView {
    if (self.scrollView) {
        [self.scrollView removeFromSuperview];
    }
    [self wm_addScrollView];
    [self wm_addViewControllerAtIndex:self.selectIndex];
    self.currentViewController = self.displayVC[@(self.selectIndex)];
}

- (void)wm_clearDatas {
    _controllerCount = kWMControllerCountUndefined;
    _hasInited = NO;
    NSUInteger maxIndex = (self.childControllersCount - 1 > 0) ? (self.childControllersCount - 1) : 0;
    _selectIndex = self.selectIndex < self.childControllersCount ? self.selectIndex : (int)maxIndex;

    NSArray *displayingViewControllers = self.displayVC.allValues;
    for (UIViewController *vc in displayingViewControllers) {
        [vc.view removeFromSuperview];
        [vc willMoveToParentViewController:nil];
        [vc removeFromParentViewController];
    }
    self.memoryWarningCount = 0;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(wm_growCachePolicyAfterMemoryWarning) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(wm_growCachePolicyToHigh) object:nil];
    self.currentViewController = nil;
    [self.posRecords removeAllObjects];
    [self.displayVC removeAllObjects];
}

// 当子控制器init完成时发送通知
- (void)wm_postAddToSuperViewNotificationWithIndex:(int)index {
    if (!self.postNotification) return;
    NSDictionary *info = [self infoWithIndex:index];
    [[NSNotificationCenter defaultCenter] postNotificationName:WMControllerDidAddToSuperViewNotification
                                                        object:self
                                                      userInfo:info];
}

// 当子控制器完全展示在user面前时发送通知
- (void)wm_postFullyDisplayedNotificationWithCurrentIndex:(int)index {
    if (!self.postNotification) return;
    NSDictionary *info = [self infoWithIndex:index];
    [[NSNotificationCenter defaultCenter] postNotificationName:WMControllerDidFullyDisplayedNotification
                                                        object:self
                                                      userInfo:info];
}


// 初始化一些参数，在init中调用
- (void)wm_setup
{
    _memCache = [[NSCache alloc] init];
    _initializedIndex = kWMUndefinedIndex;
    _markedSelectIndex = kWMUndefinedIndex;
    _controllerCount  = kWMControllerCountUndefined;
    _scrollEnable = YES;
    _pageAnimatable = YES;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.preloadPolicy = WMPageControllerPreloadPolicyNever;
    self.cachePolicy = WMPageControllerCachePolicyNoLimit;
    
    self.delegate = self;
    self.dataSource = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

// 包括宽高，子控制器视图 frame
- (void)wm_calculateSize {
    _contentViewFrame = [self.dataSource pageController:self preferredFrameForContentView:self.scrollView];
    _childViewFrames = [NSMutableArray array];
    for (int i = 0; i < self.childControllersCount; i++) {
        CGRect frame = CGRectMake(i * _contentViewFrame.size.width, 0, _contentViewFrame.size.width, _contentViewFrame.size.height);
        [_childViewFrames addObject:[NSValue valueWithCGRect:frame]];
    }
}

- (void)wm_addScrollView {
    WMScrollView *scrollView = [[WMScrollView alloc] init];
    scrollView.scrollsToTop = NO;
    scrollView.pagingEnabled = YES;
    scrollView.backgroundColor = [UIColor whiteColor];
    scrollView.delegate = self;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.bounces = self.bounces;
    scrollView.scrollEnabled = self.scrollEnable;
    if (@available(iOS 11.0, *)) {
        scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;

    if (!self.navigationController) return;
    for (UIGestureRecognizer *gestureRecognizer in scrollView.gestureRecognizers) {
        [gestureRecognizer requireGestureRecognizerToFail:self.navigationController.interactivePopGestureRecognizer];
    }
}

- (void)wm_layoutChildViewControllers {
    int currentPage = (int)(self.scrollView.contentOffset.x / _contentViewFrame.size.width);
    int length = (int)self.preloadPolicy;
    int left = currentPage - length - 1;
    int right = currentPage + length + 1;
    for (int i = 0; i < self.childControllersCount; i++) {
        UIViewController *vc = [self.displayVC objectForKey:@(i)];
        CGRect frame = [self.childViewFrames[i] CGRectValue];
        if (!vc) {
            if ([self wm_isInScreen:frame]) {
                [self wm_initializedControllerWithIndexIfNeeded:i];
            }
        } else if (i <= left || i >= right) {
            if (![self wm_isInScreen:frame]) {
                [self wm_removeViewController:vc atIndex:i];
            }
        }
    }
}

// 创建或从缓存中获取控制器并添加到视图上
- (void)wm_initializedControllerWithIndexIfNeeded:(NSInteger)index {
    // 先从 cache 中取
    UIViewController *vc = [self.memCache objectForKey:@(index)];
    if (vc) {
        // cache 中存在，添加到 scrollView 上，并放入display
        [self wm_addCachedViewController:vc atIndex:index];
    } else {
        // cache 中也不存在，创建并添加到display
        [self wm_addViewControllerAtIndex:(int)index];
    }
    [self wm_postAddToSuperViewNotificationWithIndex:(int)index];
}

- (void)wm_addCachedViewController:(UIViewController *)viewController atIndex:(NSInteger)index {
    [self addChildViewController:viewController];
    viewController.view.frame = [self.childViewFrames[index] CGRectValue];
    [viewController didMoveToParentViewController:self];
    [self.scrollView addSubview:viewController.view];
    [self willEnterController:viewController atIndex:index];
    [self.displayVC setObject:viewController forKey:@(index)];
}

// 创建并添加子控制器
- (void)wm_addViewControllerAtIndex:(int)index {
    _initializedIndex = index;
    UIViewController *viewController = [self initializeViewControllerAtIndex:index];
    if (self.values.count == self.childControllersCount && self.keys.count == self.childControllersCount) {
        [viewController setValue:self.values[index] forKey:self.keys[index]];
    }
    [self addChildViewController:viewController];
    CGRect frame = self.childViewFrames.count ? [self.childViewFrames[index] CGRectValue] : self.view.frame;
    viewController.view.frame = frame;
    [viewController didMoveToParentViewController:self];
    [self.scrollView addSubview:viewController.view];
    [self willEnterController:viewController atIndex:index];
    [self.displayVC setObject:viewController forKey:@(index)];

    [self wm_backToPositionIfNeeded:viewController atIndex:index];
}

// 移除控制器，且从display中移除
- (void)wm_removeViewController:(UIViewController *)viewController atIndex:(NSInteger)index {
    [self wm_rememberPositionIfNeeded:viewController atIndex:index];
    [viewController.view removeFromSuperview];
    [viewController willMoveToParentViewController:nil];
    [viewController removeFromParentViewController];
    [self.displayVC removeObjectForKey:@(index)];

    // 放入缓存
    if (self.cachePolicy == WMPageControllerCachePolicyDisabled) {
        return;
    }

    if (![self.memCache objectForKey:@(index)]) {
        [self willCachedController:viewController atIndex:index];
        [self.memCache setObject:viewController forKey:@(index)];
    }
}

- (void)wm_backToPositionIfNeeded:(UIViewController *)controller atIndex:(NSInteger)index {
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
    if (!self.rememberLocation) return;
#pragma clang diagnostic pop
    if ([self.memCache objectForKey:@(index)]) return;
    UIScrollView *scrollView = [self wm_isKindOfScrollViewController:controller];
    if (scrollView) {
        NSValue *pointValue = self.posRecords[@(index)];
        if (pointValue) {
            CGPoint pos = [pointValue CGPointValue];
            [scrollView setContentOffset:pos];
        }
    }
}

- (void)wm_rememberPositionIfNeeded:(UIViewController *)controller atIndex:(NSInteger)index {
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
    if (!self.rememberLocation) return;
#pragma clang diagnostic pop
    UIScrollView *scrollView = [self wm_isKindOfScrollViewController:controller];
    if (scrollView) {
        CGPoint pos = scrollView.contentOffset;
        self.posRecords[@(index)] = [NSValue valueWithCGPoint:pos];
    }
}

- (UIScrollView *)wm_isKindOfScrollViewController:(UIViewController *)controller {
    UIScrollView *scrollView = nil;
    if ([controller.view isKindOfClass:[UIScrollView class]]) {
        // Controller的view是scrollView的子类(UITableViewController/UIViewController替换view为scrollView)
        scrollView = (UIScrollView *)controller.view;
    } else if (controller.view.subviews.count >= 1) {
        // Controller的view的subViews[0]存在且是scrollView的子类，并且frame等与view得frame(UICollectionViewController/UIViewController添加UIScrollView)
        UIView *view = controller.view.subviews[0];
        if ([view isKindOfClass:[UIScrollView class]]) {
            scrollView = (UIScrollView *)view;
        }
    }
    return scrollView;
}

- (BOOL)wm_isInScreen:(CGRect)frame {
    CGFloat x = frame.origin.x;
    CGFloat ScreenWidth = self.scrollView.frame.size.width;

    CGFloat contentOffsetX = self.scrollView.contentOffset.x;
    if (CGRectGetMaxX(frame) > contentOffsetX && x - contentOffsetX < ScreenWidth) {
        return YES;
    } else {
        return NO;
    }
}

- (void)wm_growCachePolicyAfterMemoryWarning {
    self.cachePolicy = WMPageControllerCachePolicyBalanced;
    [self performSelector:@selector(wm_growCachePolicyToHigh) withObject:nil afterDelay:2.0 inModes:@[NSRunLoopCommonModes]];
}

- (void)wm_growCachePolicyToHigh {
    self.cachePolicy = WMPageControllerCachePolicyHigh;
}

#pragma mark - Adjust Frame
- (void)wm_adjustScrollViewFrame {
    // While rotate at last page, set scroll frame will call `-scrollViewDidScroll:` delegate
    // It's not my expectation, so I use `_shouldNotScroll` to lock it.
    // Wait for a better solution.
    _shouldNotScroll = YES;
    CGFloat oldContentOffsetX = self.scrollView.contentOffset.x;
    CGFloat contentWidth = self.scrollView.contentSize.width;
    self.scrollView.frame = _contentViewFrame;
    self.scrollView.contentSize = CGSizeMake(self.childControllersCount * _contentViewFrame.size.width, 0);
    CGFloat xContentOffset = contentWidth == 0 ? self.selectIndex * _contentViewFrame.size.width : oldContentOffsetX / contentWidth * self.childControllersCount * _contentViewFrame.size.width;
    [self.scrollView setContentOffset:CGPointMake(xContentOffset, 0)];
    _shouldNotScroll = NO;
}

- (void)wm_adjustDisplayingViewControllersFrame {
    [self.displayVC enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, UIViewController * _Nonnull vc, BOOL * _Nonnull stop) {
        NSInteger index = key.integerValue;
        CGRect frame = [self.childViewFrames[index] CGRectValue];
        vc.view.frame = frame;
    }];
}

- (void)wm_delaySelectIndexIfNeeded {
    if (_markedSelectIndex != kWMUndefinedIndex) {
        self.selectIndex = (int)_markedSelectIndex;
    }
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    if (!self.childControllersCount) return;
    [self wm_calculateSize];
    [self wm_addScrollView];
    [self wm_initializedControllerWithIndexIfNeeded:self.selectIndex];
    self.currentViewController = self.displayVC[@(self.selectIndex)];
    [self didEnterController:self.currentViewController atIndex:self.selectIndex];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    if (!self.childControllersCount) return;
    [self forceLayoutSubviews];
    _hasInited = YES;
    [self wm_delaySelectIndexIfNeeded];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self reloadCurrentController];
    [self postFullyDisplayedNotificationWithCurrentIndex:self.selectIndex];
}*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    self.memoryWarningCount++;
    self.cachePolicy = WMPageControllerCachePolicyLowMemory;
    // 取消正在增长的 cache 操作
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(wm_growCachePolicyAfterMemoryWarning) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(wm_growCachePolicyToHigh) object:nil];

    [self.memCache removeAllObjects];
    [self.posRecords removeAllObjects];
    self.posRecords = nil;

    // 如果收到内存警告次数小于 3，一段时间后切换到模式 Balanced
    if (self.memoryWarningCount < 3) {
        [self performSelector:@selector(wm_growCachePolicyAfterMemoryWarning) withObject:nil afterDelay:3.0 inModes:@[NSRunLoopCommonModes]];
    }
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (![scrollView isKindOfClass:WMScrollView.class]) return;

    if (_shouldNotScroll || !_hasInited) return;

    [self wm_layoutChildViewControllers];
    if (_startDragging) {
        CGFloat contentOffsetX = scrollView.contentOffset.x;
        if (contentOffsetX < 0) {
            contentOffsetX = 0;
        }
        if (contentOffsetX > scrollView.contentSize.width - _contentViewFrame.size.width) {
            contentOffsetX = scrollView.contentSize.width - _contentViewFrame.size.width;
        }
    }

    // Fix scrollView.contentOffset.y -> (-20) unexpectedly.
    if (scrollView.contentOffset.y == 0) return;
    CGPoint contentOffset = scrollView.contentOffset;
    contentOffset.y = 0.0;
    scrollView.contentOffset = contentOffset;

    if ([self.delegate respondsToSelector:@selector(pageController:didScrollToOffset:)]) {
        [self.delegate pageController:self didScrollToOffset:scrollView.contentOffset];
    }
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (![scrollView isKindOfClass:WMScrollView.class]) return;

    _startDragging = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (![scrollView isKindOfClass:WMScrollView.class]) return;

    _selectIndex = (int)(scrollView.contentOffset.x / _contentViewFrame.size.width);
    self.currentViewController = self.displayVC[@(self.selectIndex)];
    [self didEnterController:self.currentViewController atIndex:self.selectIndex];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (![scrollView isKindOfClass:WMScrollView.class]) return;

    self.currentViewController = self.displayVC[@(self.selectIndex)];
    [self didEnterController:self.currentViewController atIndex:self.selectIndex];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (![scrollView isKindOfClass:WMScrollView.class]) return;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (![scrollView isKindOfClass:WMScrollView.class]) return;

    _targetX = targetContentOffset->x;
}

#pragma mark - WMPageControllerDataSource

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForContentView:(WMScrollView *)contentView {
    NSAssert(0, @"[%@] MUST IMPLEMENT DATASOURCE METHOD `-pageController:preferredFrameForContentView:`", [self.dataSource class]);
    return CGRectZero;
}

- (void)selectedIndex:(NSInteger)index currentIndex:(NSInteger)currentIndex {
    if (!_hasInited) return;
    _selectIndex = (int)index;
    _startDragging = NO;
    CGPoint targetP = CGPointMake(_contentViewFrame.size.width * index, 0);
    [self.scrollView setContentOffset:targetP animated:self.pageAnimatable];
    if (self.pageAnimatable) return;
    // 由于不触发 -scrollViewDidScroll: 手动处理控制器
    UIViewController *currentViewController = self.displayVC[@(currentIndex)];
    if (currentViewController) {
        [self wm_removeViewController:currentViewController atIndex:currentIndex];
    }
    [self wm_layoutChildViewControllers];
    self.currentViewController = self.displayVC[@(self.selectIndex)];

    [self didEnterController:self.currentViewController atIndex:index];
}

#pragma mark - Customized

- (void)reloadCurrentController
{
    if ([self.delegate respondsToSelector:@selector(pageController:didEnterViewController:atIndex:)]) {
        [self.delegate pageController:self didEnterViewController:self.currentViewController atIndex:self.selectIndex];
    }
}

@end
