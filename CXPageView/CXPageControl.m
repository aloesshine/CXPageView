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
@property (nonatomic, assign) CGFloat selectedWidth; // 选中短线宽度
@property (nonatomic, assign) CGFloat otherWidth; // 未选中短线宽度
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
    _selectedWidth = 14;
    _otherWidth = 8;
    _spaceWidth = 4;
    _lineHeight = 2;
    _selectedColor = [UIColor whiteColor];
    _otherColor =  [UIColor grayColor];
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
    return (_numberOfPages - 1 ) * (_otherWidth + _spaceWidth) + _selectedWidth;
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
    }
}

- (void)setCurrentPage:(NSInteger)currentPage
{
    if(_currentPage != currentPage)
    {
        _currentPage = currentPage;
        [self drawPagiationLine]; // 画线
    }
}

- (void)setSelectedColor:(UIColor *)selectedColor
{
    if(_selectedColor != selectedColor) {
        _selectedColor = selectedColor;
        [self drawPagiationLine];
    }
}

- (void)setOtherColor:(UIColor *)otherColor
{
    if (_otherColor != otherColor) {
        _otherColor = otherColor;
        [self drawPagiationLine];
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
    for (UIView *line in self.subviews) {
        if (line != _pagiationLabel) {
            [line removeFromSuperview];
        }
    }
    // 定义新的view
    for (int i = 0; i < _numberOfPages; i++) {
        CGFloat lineX = (_otherWidth + _spaceWidth) * i;
        if (i > _currentPage) lineX += (_selectedWidth - _otherWidth);
        CGFloat lineW = (i == _currentPage) ? _selectedWidth : _otherWidth;
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(lineX, [self height] - _lineHeight, lineW, _lineHeight)];
        line.backgroundColor = _otherColor;
        // 调整 Label 的 Frame
        if (i == _currentPage) {
            self.pagiationLabel.frame = CGRectMake(lineX, 0, lineW, [self height] - _lineHeight);
            self.pagiationLabel.text = [NSString stringWithFormat:@"%02d",i  + 1];
            line.backgroundColor = _selectedColor;
        }
        [self addSubview:line];
    }
}

#pragma mark - publicMethod
/**
 * 设置选中状态的短线长度（默认14），非选中状态的短线长度（默认8），短线高度（默认2），短线间间隔（默认4）
 * 不需设置的设为nil即可
 */
- (void)setSelectedWidth:(CGFloat)selectedWidth otherWidth:(CGFloat)otherWidth height:(CGFloat)heigth spaceWidth:(CGFloat)spaceWidth
{
    if(selectedWidth) _selectedWidth = selectedWidth;
    if(otherWidth) _otherWidth = otherWidth;
    if (heigth) _lineHeight = heigth;
    if (spaceWidth) _spaceWidth = spaceWidth;
    [self drawPagiationLine];
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

@end
