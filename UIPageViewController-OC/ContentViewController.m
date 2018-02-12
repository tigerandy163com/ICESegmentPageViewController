//
//  ContentViewController.m
//  UIPageViewController-OC
//
 

#import "ContentViewController.h"

@implementation ContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blueColor];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 40)];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    [self.view addSubview:label];
    label.text = self.title;
}
 
@end
