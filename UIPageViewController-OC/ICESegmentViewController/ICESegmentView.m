//
//  ICESegmentView.m

#import "ICESegmentView.h"

@interface ICESegmentView () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>

@property(nonatomic) UICollectionView *collection;

@property(nonatomic) NSMutableArray *dataSources;

@property(nonatomic) UIView *line;

@end

@implementation ICESegmentView

+ (instancetype)segmentViewWithDatas:(NSArray<NSString *> *)datas {
    NSMutableArray *tmpArr = [NSMutableArray arrayWithCapacity:datas.count];
    BOOL isDefault = YES;
    for (NSString *str in datas) {
        MCSegmentModel *model = [[MCSegmentModel alloc] init];
        model.title = str;
        if (isDefault) {
            model.selected = YES;
            isDefault = NO;
        }
        [tmpArr addObject:model];
    }
    ICESegmentView *segment = [[ICESegmentView alloc] init];
    segment.dataSources = [NSMutableArray arrayWithArray:tmpArr];
    return segment;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.collection registerClass:[ICESegmentCell class] forCellWithReuseIdentifier:@"MCSegmentViewCellID"];
    }
    return self;
}

- (void)reloadData {
    [self.collection reloadData];
    [self setSelectedIndex:_selectedIndex animation:NO];
}

#pragma mark - setters

- (void)setConfig:(ICESegmentConfig *)config {
    _config = config;
    for (MCSegmentModel *model in self.dataSources) {
        model.normalFont = _config.normalFont;
        model.selectFont = _config.selectFont;
    }
    self.backgroundColor = _config.segmentColor;
    self.line.backgroundColor = _config.selectedColor;
    if (_config.divideParent) {
        if (self.dataSources.count > 0) {
            for (MCSegmentModel *model in self.dataSources) {
                model.width = self.frame.size.width / self.dataSources.count;
            }
        }
    }
}

- (void)setBackgroundView:(UIView *)backgroundView {
    [_backgroundView removeFromSuperview];
    _backgroundView = backgroundView;
    _backgroundView.frame = self.bounds;
    [self insertSubview:_backgroundView belowSubview:_collection];
}

- (void)setDatas:(NSArray<NSString *> *)datas {
    _datas = datas;
    NSMutableArray *tmpArr = [NSMutableArray arrayWithCapacity:datas.count];
    BOOL isDefault = YES;
    for (NSString *str in datas) {
        MCSegmentModel *model = [[MCSegmentModel alloc] init];
        model.title = str;
        model.normalFont = self.config.normalFont;
        if (isDefault) {
            model.selected = YES;
            isDefault = NO;
        }
        [tmpArr addObject:model];
    }
    self.dataSources = [NSMutableArray arrayWithArray:tmpArr];
}

- (void)setDataSources:(NSMutableArray *)dataSources {
    _dataSources = dataSources;
    if (_dataSources.count <= _selectedIndex) {
        _selectedIndex = 0;
    }
    [self reloadData];
}

- (void)setSelectedIndex:(NSInteger)selectedIndex animation:(BOOL)animation {
    self.config = self.config;
    _selectedIndex = selectedIndex;
    for (MCSegmentModel *model in self.dataSources) {
        model.selected = NO;
    }
    MCSegmentModel *model = [self.dataSources objectAtIndex:selectedIndex];
    model.selected = YES;
    [self.collection reloadData];
    NSIndexPath * path = [NSIndexPath indexPathForRow:selectedIndex inSection:0];
    if (!self.config.divideParent && !self.config.alignCenter) {
        if ([self segmentAtIndex:selectedIndex]) {
            [self.collection scrollToItemAtIndexPath:path atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:animation];
        }
    }
    [self moveLineToIndexPath:path animation:animation];
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    [self setSelectedIndex:selectedIndex animation:NO];
}

#pragma mark - Getter

- (UIView *)line {
    if (_line == nil) {
        _line = [[UIView alloc] init];
        _line.backgroundColor = self.config.selectedColor;
        [self.collection addSubview:_line];
    }
    return _line;
}

#pragma mark - UICollectionView & UICollectionViewDelegate & UICollectionViewDataSource
#pragma mark - UICollectionView

- (UICollectionView *)collection {
    if (_collection == nil) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        UICollectionView *collection = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];

        collection.delegate = self;
        collection.dataSource = self;
        collection.backgroundColor = self.backgroundColor;
        collection.showsVerticalScrollIndicator = NO;
        collection.showsHorizontalScrollIndicator = NO;
        [self addSubview:collection];
        _collection = collection;
    }
    return _collection;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSources.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ICESegmentCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MCSegmentViewCellID" forIndexPath:indexPath];
    cell.selectedColor = self.config.selectedColor;
    cell.normalColor = self.config.normalColor;
    cell.normalFont = self.config.normalFont;
    cell.selectFont = self.config.selectFont;
    MCSegmentModel *model = [self.dataSources objectAtIndex:indexPath.row];
    cell.title = model.title;
    cell.isSelected = model.selected;
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    [self setSelectedIndex:indexPath.row animation:YES];
    if (self.delegate && [self.delegate respondsToSelector:@selector(segmentView:didSelectedIndex:)]) {
        [self.delegate segmentView:self didSelectedIndex:indexPath.row];
    }
}

#pragma mark - UICollectionViewFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    MCSegmentModel *model = [self.dataSources objectAtIndex:indexPath.row];
    return CGSizeMake(model.width, self.frame.size.height);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsZero;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSIndexPath * path = [NSIndexPath indexPathForRow:_selectedIndex inSection:0];
    [self moveLineToIndexPath:path animation:YES];
}

- (void)moveLineToIndexPath:(NSIndexPath *)indexPath animation:(BOOL)animation {
    ICESegmentCell *cell = (ICESegmentCell *) [self.collection cellForItemAtIndexPath:indexPath];
    CGPoint lineCenter = self.line.center;
    lineCenter.x = cell.center.x;
    if (!cell) {
        CGFloat ox = 0;
        for (NSInteger index = 0; index < indexPath.row; index++) {
            if (self.dataSources.count >= index) {
                MCSegmentModel *model = self.dataSources[index];
                ox += model.width;
            }
        }
        MCSegmentModel *model = self.dataSources[indexPath.row];
        ox += model.width / 2;
        lineCenter.x = ox;
    }
    CGRect lineBounds = self.line.bounds;
    lineBounds.size.width = self.config.lineWidth ?: cell.bounds.size.width;

    if (animation) {
        [UIView animateWithDuration:0.3 animations:^{
            self.line.bounds = lineBounds;
            self.line.center = lineCenter;
        }];
    } else {
        self.line.bounds = lineBounds;
        self.line.center = lineCenter;
    }
}

- (ICESegmentCell *)segmentAtIndex:(NSInteger)index {
    ICESegmentCell *cell = (ICESegmentCell *) [self.collection cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    return cell;
}

- (CGPoint)lineEndPosOfIndex:(NSInteger)index {
    ICESegmentCell *cell = [self segmentAtIndex:index];
    return CGPointMake(cell.center.x + self.line.frame.size.width / 2, self.line.center.y);
}

- (CGPoint)lineStartPosOfIndex:(NSInteger)index {
    ICESegmentCell *cell = [self segmentAtIndex:index];
    return CGPointMake(cell.center.x - self.line.frame.size.width / 2, self.line.center.y);
}

- (CGFloat)segmentWidthOfIndex:(NSInteger)index {
    ICESegmentCell *cell = [self segmentAtIndex:index];
    return cell.bounds.size.width;
}

- (void)moveLineToEndPoint:(CGPoint)pos {
    CGRect frame = self.line.frame;
    frame.origin.x = pos.x - frame.size.width;
    self.line.frame = frame;
}

- (void)moveLineToStartPoint:(CGPoint)pos {
    CGRect frame = self.line.frame;
    frame.origin.x = pos.x;
    self.line.frame = frame;
}

#pragma mark - layoutSubviews

- (void)layoutSubviews {
    [super layoutSubviews];
    self.config = self.config;
    if (self.config.alignCenter) {
        CGRect frame = self.collection.frame;
        CGFloat w = 0;
        for (MCSegmentModel *model in self.dataSources) {
            w += model.width;
        }
        frame.size.width = w;
        frame.size.height = self.bounds.size.height;
        frame.origin.x = (self.bounds.size.width - w) / 2;
        self.collection.frame = frame;
        self.collection.bounces = NO;
    } else {
        self.collection.frame = self.bounds;
    }
    MCSegmentModel *model = [self.dataSources firstObject];
    self.line.frame = CGRectMake(4, CGRectGetHeight(self.frame) - self.config.lineHeight, self.config.lineWidth ?: model.width, self.config.lineHeight);
    [self setSelectedIndex:self.selectedIndex animation:NO];
}

@end

#pragma MCSegmentCell

@interface ICESegmentCell ()

@property(nonatomic, strong) UILabel *titleLabel;
@end

@implementation ICESegmentCell

- (void)setTitleColor:(UIColor *)titleColor {
    self.titleLabel.textColor = titleColor;
}

- (UIColor *)titleColor {
    return self.titleLabel.textColor;
}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_titleLabel];
    }

    return _titleLabel;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = title;
}

- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    self.titleLabel.textColor = isSelected ? _selectedColor : _normalColor;
    self.titleLabel.font = isSelected ? _selectFont : _normalFont;
}

- (void)setNormalFont:(UIFont *)font {
    _normalFont = font;
    self.titleLabel.font = _isSelected ? _selectFont : _normalFont;
}

- (void)setSelectFont:(UIFont *)font {
    _selectFont = font;
    self.titleLabel.font = _isSelected ? _selectFont : _normalFont;
}

- (void)setTitleFont:(UIFont *)titleFont {
    self.titleLabel.font = titleFont;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }

    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.titleLabel.frame = self.bounds;
}

@end


@implementation MCSegmentModel
- (instancetype)init {
    self = [super init];
    if (self) {
        _selected = NO;
    }

    return self;
}

- (CGFloat)width {
    if (_width <= 0) {
        CGFloat wid = [self.title boundingRectWithSize:CGSizeMake(0, 30) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: self.normalFont} context:nil].size.width;

        _width = wid + 10;
    }

    return _width;
}
@end
