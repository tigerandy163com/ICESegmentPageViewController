//
//  ICESegmentViewController.m

#import "ICESegmentPageViewController.h"

@interface ICESegmentPageViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, ICESegmentViewDelagate, UIScrollViewDelegate> {

    NSInteger _shouldSegmentIndex;
    NSInteger _selectSegmentIndex;

    BOOL _paging;

    NSDictionary *_dicTextColor;

    NSDictionary *_dicSelectTextColor;
}

@property(nonatomic) UIPageViewController *pageViewController;

@property(nonatomic) ICESegmentView *segmentView;

@property(nonatomic) NSMapTable *viewControllers;

@property(nonatomic) NSArray<NSString *> *segmentTitles;

@end

@implementation ICESegmentPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _viewControllers = [NSMapTable weakToWeakObjectsMapTable];
    [self segmentView];
    if (!_config) {
        ICESegmentConfig *config = [[ICESegmentConfig alloc] init];
        _config = config;
    }
    [self reloadData];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self adjustFrame];
}

- (ICESegmentView *)segmentView {
    if (!_segmentView) {
        _segmentView = [[ICESegmentView alloc] init];
        _segmentView.backgroundColor = [UIColor whiteColor];
        _segmentView.delegate = self;
        [self.view addSubview:_segmentView];
    }
    return _segmentView;
}

- (UIPageViewController *)pageViewController {
    if (!_pageViewController) {
        NSDictionary * option = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:0] forKey:UIPageViewControllerOptionInterPageSpacingKey];
        _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:option];
        _pageViewController.delegate = self;
        _pageViewController.dataSource = self;
        [self addChildViewController:_pageViewController];
        [self.view addSubview:_pageViewController.view];
        [self pageScrollView].delegate = self;
    }
    return _pageViewController;
}

#pragma mark - dataSource data

- (NSInteger)segmentCount {
    if ([self.dataSource respondsToSelector:@selector(segmentCount)]) {
        return [self.dataSource segmentCount];
    }
    return 0;
}

- (UIViewController *)segmentViewController:(NSInteger)index {
    if ([self.dataSource respondsToSelector:@selector(segmentViewController:)]) {
        UIViewController * vc = [self.dataSource segmentViewController:index];
        return vc;
    }
    return nil;
}

- (NSString *)segmentTitle:(NSInteger)index {
    NSString * title;
    if ([self.dataSource respondsToSelector:@selector(segmentTitle:)]) {
        title = [self.dataSource segmentTitle:index];
    } else {
        title = [self segmentViewController:index].title;
    }
    if (!title) {
        title = @"标题?";
    }
    return title;
}

- (CGFloat)segmentWidth:(NSInteger)index {
    if ([self.dataSource respondsToSelector:@selector(segmentWidth:)]) {
        return [self.dataSource segmentWidth:index];
    }
    return 0;
}

#pragma mark - delegate sender

- (void)pageWillAppear:(NSInteger)index {
    if ([self.delegate respondsToSelector:@selector(pageWillAppear:)]) {
        [self.delegate pageWillAppear:index];
    }
}

- (void)pageDidAppear:(NSInteger)index {
    if ([self.delegate respondsToSelector:@selector(pageDidAppear:)]) {
        [self.delegate pageDidAppear:index];
    }
}

- (void)pageWillDisappear:(NSInteger)index {
    if ([self.delegate respondsToSelector:@selector(pageWillDisappear:)]) {
        [self.delegate pageWillDisappear:index];
    }
}

- (void)pageDidDisappear:(NSInteger)index {
    if ([self.delegate respondsToSelector:@selector(pageDidDisappear:)]) {
        [self.delegate pageDidDisappear:index];
    }
}

#pragma mark - interface

- (void)reloadData {
    self.config = self.config;
    [_pageViewController.view removeFromSuperview];
    [_pageViewController removeFromParentViewController];
    _pageViewController = nil;
    [self pageViewController];
    [self configViewControllers];
    [self configSegmentTitles];
    [self adjustFrame];
    [self pageScrollView].scrollEnabled = self.viewControllers.count > 1;
    _selectedIndex = -1;
    self.selectedIndex = 0;
}

- (NSArray *)segmentTitles {
    return self.segmentView.datas;
}

- (void)setSegmentTitles:(NSArray *)segmentTitles {
    self.segmentView.datas = segmentTitles;
}

- (void)setConfig:(ICESegmentConfig *)config {
    _config = config;
    self.segmentView.config = config;
    _dicTextColor = [self getRGBDictionaryByColor:config.normalColor];
    _dicSelectTextColor = [self getRGBDictionaryByColor:config.selectedColor];
    [self.segmentView setNeedsLayout];
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    if (_selectedIndex == selectedIndex) {
        return;
    }
    self.segmentView.selectedIndex = selectedIndex;
    [self didSelectedIndex:selectedIndex animated:NO];
}

#pragma mark - delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!_paging) {
        return;
    }
    if (ABS(_selectSegmentIndex - _shouldSegmentIndex) > 1) {
        return;
    }
    CGFloat curSegmentW = [self.segmentView segmentWidthOfIndex:_shouldSegmentIndex];
    CGFloat per = scrollView.contentOffset.x / scrollView.frame.size.width;

    if (per == 1) {
        return;
    }
    if (per > 1) {
        CGPoint pos = [self.segmentView lineEndPosOfIndex:_selectSegmentIndex];
        per -= 1.0;
        if (per < 1) {
            pos.x += per * curSegmentW;
            [self.segmentView moveLineToEndPoint:pos];
        }
    } else {
        CGPoint pos = [self.segmentView lineStartPosOfIndex:_selectSegmentIndex];
        per = 1.0 - per;
        if (per < 1) {
            pos.x -= per * curSegmentW;
            [self.segmentView moveLineToStartPoint:pos];
        }
    }
    if (_dicSelectTextColor) {
        ICESegmentCell *cell = [self.segmentView segmentAtIndex:_shouldSegmentIndex];
        cell.titleColor = [self changeToSelectColorPer:per];
        cell = [self.segmentView segmentAtIndex:_selectSegmentIndex];
        cell.titleColor = [self changeToNormalColorPer:per];
        for (NSInteger index = 0; index < [self segmentCount]; index ++) {
            if (index != _shouldSegmentIndex && index != _selectSegmentIndex) {
                ICESegmentCell *cell = [self.segmentView segmentAtIndex:index];
                cell.titleColor = self.config.normalColor;
                cell.titleFont = self.config.normalFont;
            }
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _paging = NO;
    [self adjustSelectedIndex];
}

- (void)segmentView:(ICESegmentView *)view didSelectedIndex:(NSInteger)index {
    [self didSelectedIndex:index animated:YES];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSInteger index = [[self.viewControllers objectForKey:viewController] integerValue];
    if (index == 0) {
        return nil;
    }
    index--;
    return [self segmentViewController:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSInteger index = [[self.viewControllers objectForKey:viewController] integerValue];
    if (index == [self segmentCount] - 1) {
        return nil;
    }
    index++;
    return [self segmentViewController:index];
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers {
    UIViewController * viewController = [pendingViewControllers firstObject];
    NSInteger index = [[self.viewControllers objectForKey:viewController] integerValue];
    _paging = YES;
    _shouldSegmentIndex = index;
    viewController = [self.pageViewController.viewControllers firstObject];
    index = [[self.viewControllers objectForKey:viewController] integerValue];
    _selectSegmentIndex = index;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {

}
#pragma mark - method
- (void)didSelectedIndex:(NSInteger)index animated:(BOOL)animated {
    UIViewController * vc = [self segmentViewController:index];
    if (_selectedIndex >= 0) {
        [self pageWillDisappear:self.selectedIndex];
    }
    [self pageWillAppear:index];
    UIPageViewControllerNavigationDirection direction = UIPageViewControllerNavigationDirectionReverse;
    if (index > _selectedIndex && index < self.viewControllers.count - 1) {
        direction = UIPageViewControllerNavigationDirectionForward;
    }
    __weak typeof(self) weakSelf = self;
    [self.pageViewController setViewControllers:@[vc] direction:direction animated:animated completion:^(BOOL finished) {
        typeof(self) self = weakSelf;
        if (self.selectedIndex >= 0) {
            [self pageDidDisappear:self.selectedIndex];
        }
        [self pageDidAppear:index];
        self->_selectedIndex = index;
    }];
}

- (void)adjustSelectedIndex {
    UIViewController * viewController = [self.pageViewController.viewControllers firstObject];
    NSInteger index = [[self.viewControllers objectForKey:viewController] integerValue];
    if (_selectedIndex != index) {
        [self didSelectedIndex:index animated:NO];
    }
    self.segmentView.selectedIndex = _selectedIndex;
}

- (void)adjustFrame {
    CGRect segmentFrame = _segmentView.hidden ? CGRectZero : CGRectMake(0, 0, self.view.frame.size.width, self.config.segmentHeight);
    self.segmentView.frame = segmentFrame;
    _pageViewController.view.frame = CGRectMake(0, CGRectGetMaxY(segmentFrame), self.view.frame.size.width, self.view.frame.size.height - CGRectGetMaxY(segmentFrame));
}

- (void)configSegmentTitles {
    NSMutableArray *segmentTitles = [NSMutableArray arrayWithCapacity:[self segmentCount]];
    for (int index = 0; index < [self segmentCount]; index++) {
        [segmentTitles addObject:[self segmentTitle:index]];
    }
    self.segmentTitles = segmentTitles;

    NSAssert(self.segmentTitles.count == self.viewControllers.count, @"The childViewController's count doesn't equal to the count of segmentTitles");
}

- (void)configViewControllers {
    [self.viewControllers removeAllObjects];
    for (int index = 0; index < [self segmentCount]; index++) {
        UIViewController * vc = [self segmentViewController:index];
        [self.viewControllers setObject:@(index) forKey:vc];
        if (self.config.preloadView) {
            [vc view];
        }
    }
    NSAssert(self.viewControllers.count > 0, @"Must have one childViewCpntroller at least");
}

- (UIColor *)changeToSelectColorPer:(CGFloat)per {
    if (per - 0.9 >= 0) {
        per = 0.9;
    }
    float redColorValue =
            ([_dicSelectTextColor[@"R"] floatValue] - [_dicTextColor[@"R"] floatValue]) *
                    per + [_dicTextColor[@"R"] floatValue];
    float greenColorValue =
            ([_dicSelectTextColor[@"G"] floatValue] - [_dicTextColor[@"G"] floatValue]) *
                    per + [_dicTextColor[@"G"] floatValue];
    float blueColorValue =
            ([_dicSelectTextColor[@"B"] floatValue] - [_dicTextColor[@"B"] floatValue]) *
                    per + [_dicTextColor[@"B"] floatValue];
    return [UIColor colorWithRed:redColorValue
                           green:greenColorValue
                            blue:blueColorValue
                           alpha:1];
}

- (UIColor *)changeToNormalColorPer:(CGFloat)per {
    if (per - 0.9 >= 0) {
        per = 0.9;
    }
    float redColorValue =
            [_dicSelectTextColor[@"R"] floatValue] - ([_dicSelectTextColor[@"R"] floatValue] - [_dicTextColor[@"R"] floatValue]) *
                    per;
    float greenColorValue =
            [_dicSelectTextColor[@"G"] floatValue] - ([_dicSelectTextColor[@"G"] floatValue] - [_dicTextColor[@"G"] floatValue]) *
                    per;
    float blueColorValue =
            [_dicSelectTextColor[@"B"] floatValue] - ([_dicSelectTextColor[@"B"] floatValue] - [_dicTextColor[@"B"] floatValue]) *
                    per;
    return [UIColor colorWithRed:redColorValue
                           green:greenColorValue
                            blue:blueColorValue
                           alpha:1];
}

- (UIScrollView *)pageScrollView {
    UIScrollView *scrollView;
    for (id subview in _pageViewController.view.subviews) {
        if ([subview isKindOfClass:UIScrollView.class]) {
            scrollView = subview;
            break;
        }
    }
    return scrollView;
}

- (NSDictionary *)getRGBDictionaryByColor:(UIColor *)originColor {
    CGFloat r = 0, g = 0, b = 0, a = 0;
    if ([originColor respondsToSelector:@selector(getRed:green:blue:alpha:)]) {
        [originColor getRed:&r green:&g blue:&b alpha:&a];
    } else {
        const CGFloat * components = CGColorGetComponents(originColor.CGColor);
        r = components[0];
        g = components[1];
        b = components[2];
        a = components[3];
    }

    return @{@"R": @(r), @"G": @(g), @"B": @(b), @"A": @(a)};
}

@end
