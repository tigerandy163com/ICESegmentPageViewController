# ICESegmentPageViewController
segment with UIPageViewController

# Use guide
## Init
> Use an object of ICESegmentConfig to control the display style
```
ICESegmentPageViewController *segVC = [[ICESegmentPageViewController alloc]init];
segVC.dataSource = self;
segVC.delegate = self;

ICESegmentConfig *config = [[ICESegmentConfig alloc] init];
config.lineWidth = 50;
config.lineHeight = 1.5;
config.divideParent = YES;
config.segmentColor = [UIColor redColor];
config.selectedColor = [UIColor blackColor];
config.selectFont = [UIFont boldSystemFontOfSize:15];
segVC.config = config;

segVC.view.frame = frame;
[self addChildViewController:segVC];
[self.view addSubview:segVC.view];

```

## DataSource
>  Warning：Because internal this implementation only holds sub-viewControllers' weak references, so you must hold all of sub-viewControllers' strong references 

```
- (NSInteger)segmentCount {
   return 5;
 }

- (UIViewController *)segmentViewController:(NSInteger)index {
   return vc;
}
```

## Delegate
>Warning：Need not again in these delegate callbacks call its UIViewController's appear&disappear life-cycle functions

```
- (void)pageWillAppear:(NSInteger)index {
    NSLog(@"pageWillAppear %zd",index);
}

- (void)pageDidAppear:(NSInteger)index {
    NSLog(@"pageDidAppear %zd",index);
}

- (void)pageWillDisappear:(NSInteger)index {
    NSLog(@"pageWillDisappear %zd",index);
}

- (void)pageDidDisappear:(NSInteger)index {
    NSLog(@"pageDidDisappear %zd",index);
}
```

## Reload 

```
- (void)reload {
   [self.segVC reloadData];
}
 ```

##  SetSelect

```
segVC.selectedIndex = 3;
```
