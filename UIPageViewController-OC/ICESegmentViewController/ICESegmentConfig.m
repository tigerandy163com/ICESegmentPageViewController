//
//  ICESegmentConfig.m
 
#import "ICESegmentConfig.h"

@implementation ICESegmentConfig

- (instancetype)init {
    self = [super init];
    if (self) {
        self.segmentColor = [UIColor redColor];
        self.selectedColor = [UIColor redColor];
        self.selectFont = [UIFont systemFontOfSize:12];
        self.normalColor = [UIColor whiteColor];
        self.normalFont = [UIFont systemFontOfSize:12];
        self.segmentHeight = 40;
        self.lineHeight = 2;
    }
    return self;
}

@end
