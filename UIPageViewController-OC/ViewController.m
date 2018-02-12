//
//  ViewController.m
//  UIPageViewController-OC
//
 

#import "ViewController.h"
#import "ContentViewController.h"
#import "ICESegmentPageViewController.h"
#import "ICESegmentView.h"

@interface ViewController ()<ICESegmentViewDataSource, ICESegmentViewDelegate>

@property (nonatomic, strong) NSMutableDictionary *dataSource;
@property (nonatomic, strong) ICESegmentPageViewController *segVC;

@end

@implementation ViewController
- (NSMutableDictionary *)dataSource {
    if (_dataSource == nil) {
        _dataSource = [NSMutableDictionary dictionary];
    }
    
    return _dataSource;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0,0,40, 40);
    [button setTitle:@"reload" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(reload) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItems = @[right];
    CGRect frame = self.view.frame;
    frame.origin.y += 64;
    frame.size.height -= 64;

    ICESegmentPageViewController *segVC = [[ICESegmentPageViewController alloc]init];
    segVC.dataSource = self;
    segVC.delegate = self;
    ICESegmentConfig *config = [[ICESegmentConfig alloc] init];
    config.lineWidth = 50;
    config.lineHeight = 1.5;
    config.divideParent = YES;
//    config = YES;
    config.segmentColor = [UIColor redColor];
    config.selectedColor = [UIColor blackColor];
    config.selectFont = [UIFont boldSystemFontOfSize:15];
    segVC.config = config;
    segVC.view.frame = frame;

    [self addChildViewController:segVC];
    [self.view addSubview:segVC.view];
    segVC.selectedIndex = 2;
    self.segVC = segVC;
}

- (NSInteger)segmentCount {
    return 5;
}

- (UIViewController *)segmentViewController:(NSInteger)index {
    UIViewController * vc= [self.dataSource objectForKey:@(index)];
    if (!vc) {
        ContentViewController *con = [[ContentViewController alloc]init];
        
        [self.dataSource setObject:con forKey:@(index)];
        
        NSString *str = [NSString stringWithFormat:@"第 %zd 页", index+1];
        con.title = str;
        vc = con;
    }
    return vc;
}

- (CGFloat)segmentWidth:(NSInteger)index {
    switch (index) {
        case 0:
           return 100;
            break;
        case 1:
            return 100;
            break;
        case 2:
            return 100;
            break;
        case 3:
            return 50;
            break;
        default:
            break;
    }
    return 50;
}

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

- (void)reload {
    [self.segVC reloadData];
    self.segVC.selectedIndex = 3;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSInteger max = [self segmentCount];
    for (int i = 0; i < max; ++i) {
        if (i < self.segVC.selectedIndex - 1 || i > self.segVC.selectedIndex + 1) {
            UIViewController *vc = (UIViewController *)self.dataSource[@(i)];
            if (vc) {
                [vc removeFromParentViewController];
                [self.dataSource removeObjectForKey:@(i)];
            }
        }
    }
}
@end
