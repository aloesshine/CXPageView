//
//  CXPageControl.m
//  CXPageView
//
//  Created by 郭晨香 on 2017/7/21.
//  Copyright © 2017年 郭晨香. All rights reserved.
//

#import "CXPageControl.h"

@interface CXPageControl()

@property (nonatomic, strong) UILabel *pagiationLabel; // 页码Label
@property (nonatomic, strong) UIView *selectedLine; // 选中View
@property (nonatomic, strong) NSMutableArray *otherViewsArray; // 未选中Views
@property (nonatomic, assign) CGFloat lineWidth; // 短线宽度
@property (nonatomic, assign) CGFloat lineHeight; // 短线高度
@property (nonatomic, assign) CGFloat spaceWidth; // 短线间间隔

@end

@implementation CXPageControl

- (id)initWithFrame:(CGRect)frame 
{
    if(self = [super initWithFrame:frame]) {
        [self initSubview];
    }
    return self;
}

- (instancetype)init
{
    if(self = [super init]) {
        [self initSubview];
    }
    return self;
}

- (void)initSubview
{
    self.backgroundColor = [UIColor clearColor];
    _currentPage = 0;
    _lineWidth = 14;
    _spaceWidth = 4;
    _lineHeight = 2;
    _selectedColor = [UIColor whiteColor];
    _otherColor =  [UIColor grayColor];
    _otherViewsArray = [NSMutableArray array];
    _isShowPagination = YES;
    [self addSubview: self.pagiationLabel];
}

#pragma mark - 方便获取 self 的 frame

- (CGFloat)height
{
    return self.frame.size.height;
}

- (CGFloat)width
{
    return (_numberOfPages - 1 ) * (_lineWidth + _spaceWidth) + _lineWidth;
}

- (CGFloat)x
{
    return self.frame.origin.x;
}

- (CGFloat)y
{
    return self.frame.origin.y;
}

#pragma mark - setter getter

- (void)setNumberOfPages:(NSInteger)numberOfPages
{
    if(_numberOfPages != numberOfPages) {
        _numberOfPages = numberOfPages;
        [self drawPagiationLine];
        [self drawCurrentPage];
    }
}

- (void)setCurrentPage:(NSInteger)currentPage
{
    if(_currentPage != currentPage)
    {
        _currentPage = currentPage;
        [self drawCurrentPage];
    }
}

- (void)setSelectedColor:(UIColor *)selectedColor
{
    if(_selectedColor != selectedColor) {
        _selectedColor = selectedColor;
        _selectedLine.backgroundColor = _selectedColor;
    }
}

- (void)setOtherColor:(UIColor *)otherColor
{
    if (_otherColor != otherColor) {
        _otherColor = otherColor;
        for (UIView *line in self.otherViewsArray) {
            line.backgroundColor = _otherColor;
        }
    }
}

- (void)setIsShowPagination:(BOOL)isShowPagination
{
    if (_isShowPagination != isShowPagination) {
        _isShowPagination = isShowPagination;
        self.pagiationLabel.hidden = !_isShowPagination;
    }
}

- (UILabel *)pagiationLabel
{
    if(!_pagiationLabel){
        _pagiationLabel = [[UILabel alloc] init];
        _pagiationLabel.textAlignment = NSTextAlignmentCenter;
        _pagiationLabel.textColor = [UIColor whiteColor];
        _pagiationLabel.font = [UIFont systemFontOfSize: 10];
        _pagiationLabel.hidden = !_isShowPagination;
    }
    return _pagiationLabel;
}

#pragma mark - other
- (void)drawPagiationLine
{
    // 移除之前的view
    for (UIView *line in self.otherViewsArray) {
        [line removeFromSuperview];
    }
    // 定义新的view
    for (int i = 0; i < _numberOfPages; i++) {
        CGFloat lineX = (_lineWidth + _spaceWidth) * i;
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(lineX, [self height] - _lineHeight, _lineWidth, _lineHeight)];
        line.backgroundColor = _otherColor;
        [self addSubview:line];
        [self.otherViewsArray addObject:line];
    }
}

- (void)drawCurrentPage
{
    if (!_selectedLine) {
        _selectedLine = [[UIView alloc] init];
        _selectedLine.backgroundColor = _selectedColor;
        [self addSubview:_selectedLine];
    }
    CGFloat lineX = (_lineWidth + _spaceWidth) * _currentPage;
    _selectedLine.frame = CGRectMake(lineX, [self height] - _lineHeight, _lineWidth, _lineHeight);
    // 调整 Label 的 Frame
    self.pagiationLabel.frame = CGRectMake(lineX, 0, _lineWidth, [self height] - _lineHeight);
    self.pagiationLabel.text = [NSString stringWithFormat:@"%02ld",_currentPage  + 1];
    [self bringSubviewToFront:_selectedLine];
}

#pragma mark - publicMethod
/**
 * 设置短线长度（默认14），短线高度（默认2），短线间间隔（默认4）
 * 不需设置的设为nil即可
 */
- (void)setLineWidth:(CGFloat)lineWidth height:(CGFloat)heigth spaceWidth:(CGFloat)spaceWidth
{
    if(lineWidth) _lineWidth = lineWidth;
    if (heigth) _lineHeight = heigth;
    if (spaceWidth) _spaceWidth = spaceWidth;
    [self drawPagiationLine];
    [self drawCurrentPage];
}

/**
 * 设置页码颜色（默认 white），字体大小(默认10)
 * 不需设置的设为nil即可
 */
- (void)setPagiationColor:(UIColor *)pagiationColor fontSize:(CGFloat)fontSize
{
    if (pagiationColor) self.pagiationLabel.textColor = pagiationColor;
    if (fontSize) self.pagiationLabel.font = [UIFont systemFontOfSize:fontSize];
}

// 页码切换动画
- (void)slidePageControlAtProgress:(CGFloat)rate toNext:(BOOL)toNext
{
    CGFloat lineX = (_lineWidth + _spaceWidth) * _currentPage;
    if (!toNext) {
        if (rate <= 0.5) {
            _selectedLine.frame = CGRectMake(_selectedLine.frame.origin.x, _selectedLine.frame.origin.y, _lineWidth + (_spaceWidth + _lineWidth) * (rate / 0.5), _lineHeight);
            self.pagiationLabel.text = [NSString stringWithFormat:@"%02ld",_currentPage  + 1];
        } else {
            _selectedLine.frame = CGRectMake(lineX + (rate / 0.5 - 1) * (_spaceWidth + _lineWidth), _selectedLine.frame.origin.y, _lineWidth + (2 - 2 * rate) * (_lineWidth + _spaceWidth), _lineHeight);
            self.pagiationLabel.text = [NSString stringWithFormat:@"%02ld",(_currentPage  + 1) % _numberOfPages + 1];
        }
        // 调整 Label 的 Frame
        self.pagiationLabel.frame = CGRectMake(lineX + rate * (_spaceWidth + _lineWidth), 0, _lineWidth, [self height] - _lineHeight);
    } else {
        if (rate <= 0.5) {
            _selectedLine.frame = CGRectMake(lineX - (_spaceWidth + _lineWidth) * 2 * rate, _selectedLine.frame.origin.y, _lineWidth + (_spaceWidth + _lineWidth) * (rate / 0.5), _lineHeight);
            self.pagiationLabel.text = [NSString stringWithFormat:@"%02ld",_currentPage  + 1];
        } else {
            _selectedLine.frame = CGRectMake(lineX - (_spaceWidth + _lineWidth), _selectedLine.frame.origin.y, _lineWidth + (2 - 2 * rate) * (_lineWidth + _spaceWidth), _lineHeight);
            self.pagiationLabel.text = [NSString stringWithFormat:@"%02ld",_currentPage ? _currentPage : _numberOfPages];
        }
        self.pagiationLabel.frame = CGRectMake(lineX - rate * (_spaceWidth + _lineWidth), 0, _lineWidth, [self height] - _lineHeight);
    }
}

@end
