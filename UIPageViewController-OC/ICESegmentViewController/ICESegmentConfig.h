//
//  ICESegmentConfig.h

#import <UIKit/UIKit.h>

@interface ICESegmentConfig : NSObject

@property(nonatomic) UIColor *normalColor;

@property(nonatomic) UIColor *selectedColor;

@property(nonatomic) UIFont *normalFont;

@property(nonatomic) UIFont *selectFont;

@property(nonatomic) CGFloat lineWidth;

@property(nonatomic) CGFloat lineHeight;

@property(nonatomic) CGFloat segmentHeight;

@property(nonatomic) UIColor *segmentColor;

/**
 标签视图是否平分父视图的宽度，如果不设，先检查代理（segmentWidth:）是否提供宽度值，
 都没有时标签的宽度为其标题内容文字所占长度
 */
@property(nonatomic) BOOL divideParent;

@property(nonatomic) BOOL alignCenter;

@property(nonatomic) BOOL preloadView;

@end
