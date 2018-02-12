//
//  ICESegmentViewController.h

#import <UIKit/UIKit.h>
#import "ICESegmentView.h"

@protocol ICESegmentViewDelegate <NSObject>

@optional

- (void)pageWillAppear:(NSInteger)index;

- (void)pageDidAppear:(NSInteger)index;

- (void)pageWillDisappear:(NSInteger)index;

- (void)pageDidDisappear:(NSInteger)index;

@end

@protocol ICESegmentViewDataSource <NSObject>

- (NSInteger)segmentCount;

- (UIViewController *)segmentViewController:(NSInteger)index;

@optional
/**
  If not implement, get title of the return UIViewController (- (UIViewController *)segmentViewController:(NSInteger)index)
 */
- (NSString *)segmentTitle:(NSInteger)index;

/**
 Invalid when ICESegmentConfig.divideParent is YES
 */
- (CGFloat)segmentWidth:(NSInteger)index;

@end

@interface ICESegmentPageViewController : UIViewController

@property(nonatomic, weak) id <ICESegmentViewDataSource> dataSource;

@property(nonatomic, weak) id <ICESegmentViewDelegate> delegate;

@property(nonatomic, readonly) NSArray<NSString *> *segmentTitles;

@property(nonatomic, readonly) NSMapTable *viewControllers;

@property(nonatomic, readonly) ICESegmentView *segmentView;

@property(nonatomic) ICESegmentConfig *config;

@property(nonatomic) NSInteger selectedIndex;

- (void)reloadData;

@end
