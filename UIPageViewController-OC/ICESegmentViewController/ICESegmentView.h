//
//  ICESegmentView.h

#import <UIKit/UIKit.h>

#import "ICESegmentConfig.h"

@protocol ICESegmentViewDelagate;
@class ICESegmentCell;

@interface ICESegmentView : UIView

@property(nonatomic, weak) id <ICESegmentViewDelagate> delegate;

@property(nonatomic, readonly) UICollectionView *collection;

@property(nonatomic, readonly) NSMutableArray *dataSources;

@property(nonatomic) NSArray<NSString *> *datas;

@property(nonatomic) NSInteger selectedIndex;

@property(nonatomic) ICESegmentConfig *config;

@property(nonatomic, readonly) UIView *line;

@property(nonatomic) UIView *backgroundView;

+ (instancetype)segmentViewWithDatas:(NSArray<NSString *> *)datas;

- (void)setSelectedIndex:(NSInteger)selectedIndex animation:(BOOL)animation;

- (void)reloadData;

- (ICESegmentCell *)segmentAtIndex:(NSInteger)index;

- (void)moveLineToEndPoint:(CGPoint)pos;

- (void)moveLineToStartPoint:(CGPoint)pos;

- (CGPoint)lineStartPosOfIndex:(NSInteger)index;

- (CGPoint)lineEndPosOfIndex:(NSInteger)index;

- (CGFloat)segmentWidthOfIndex:(NSInteger)index;

@end

@protocol ICESegmentViewDelagate <NSObject>

- (void)segmentView:(ICESegmentView *)view didSelectedIndex:(NSInteger)index;

@end

#pragma Cell

@interface ICESegmentCell : UICollectionViewCell

@property(nonatomic) NSString *title;

@property(nonatomic) BOOL isSelected;

@property(nonatomic) UIColor *selectedColor;

@property(nonatomic) UIColor *normalColor;

@property(nonatomic) UIFont *normalFont;

@property(nonatomic) UIFont *selectFont;

@property(nonatomic) UIColor *titleColor;

@property(nonatomic) UIFont *titleFont;

@end

#pragma Model

@interface MCSegmentModel : NSObject

@property(nonatomic) NSString *title;

@property(nonatomic) CGFloat width;

@property(nonatomic) BOOL selected;

@property(nonatomic) UIFont *normalFont;

@property(nonatomic) UIFont *selectFont;

@end
