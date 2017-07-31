//
//  CXPageView.h
//  CXPageView
//
//  Created by 郭晨香 on 2017/7/21.
//  Copyright © 2017年 郭晨香. All rights reserved.
//

#import "CXPageView.h"
#import "CXPageControl.h"
#import <ImageIO/ImageIO.h>
#import <AVFoundation/AVFoundation.h>
#import "AVPlayerItem+WGCacheSupport.h"

#define DEFAULTTIME 5
#define HORMARGIN 10
#define VERMARGIN 5
#define DES_LABEL_H 20
#define TITLE_LABEL_H 60

@interface CXPageView() <UIScrollViewDelegate>
//轮播的图片/视频数组
@property (nonatomic, strong) NSMutableArray *images;
//滚动视图
@property (nonatomic, strong) UIScrollView *scrollView;
//当前显示的imageView
@property (nonatomic, strong) UIImageView *currImageView;
//滚动显示的imageView
@property (nonatomic, strong) UIImageView *otherImageView;
// 底部黑色渐变蒙版
@property (nonatomic, strong) UIView *currControlView;
@property (nonatomic, strong) UIView *nextControlView;
//当前显示标题
@property (nonatomic, strong) UILabel *currTitleLabel;
//将要显示的标题
@property (nonatomic, strong) UILabel *nextTitleLabel;
//当前显示描述
@property (nonatomic, strong) UILabel *currDescLabel;
//将要显示的描述
@property (nonatomic, strong) UILabel *nextDescLabel;
//当前显示图片的索引
@property (nonatomic, assign) NSInteger currIndex;
//将要显示图片的索引
@property (nonatomic, assign) NSInteger nextIndex;
//定时器
@property (nonatomic, strong) NSTimer *timer;
//任务队列
@property (nonatomic, strong) NSOperationQueue *queue;

//系统分页控件
@property (nonatomic, strong) UIPageControl *pageControl;
//pageControl图片大小
@property (nonatomic, assign) CGSize pageImageSize;
// 底部Line分页控件
@property (nonatomic, strong) UIView *pageProgress;
// shortLine分页控件
@property (nonatomic, strong) CXPageControl *cx_pageControl;

// 视频播放
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;

@end

static NSString *cache;


@implementation CXPageView
#pragma mark- 初始化方法
//创建用来缓存图片的文件夹
+ (void)initialize {
    cache = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"CXPageView"];
    BOOL isDir = NO;
    BOOL isExists = [[NSFileManager defaultManager] fileExistsAtPath:cache isDirectory:&isDir];
    if (!isExists || !isDir) {
        [[NSFileManager defaultManager] createDirectoryAtPath:cache withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

#pragma mark 代码创建
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initSubView];
    }
    return self;
}

#pragma mark nib创建
- (void)awakeFromNib {
    [super awakeFromNib];
    [self initSubView];
}

#pragma mark 初始化控件
- (void)initSubView {
    self.autoCache = YES;
    [self addSubview:self.scrollView];
    self.pageControlType = PageControlTypeDefault;
    self.pagePosition = PositionBottomCenter;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidPlayToEndTimeNotification:) name:AVPlayerItemDidPlayToEndTimeNotification  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(headerPlayVideo) name:NotificationPageViewShow object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)headerPlayVideo
{
    [self stopVideo];
    [self playVideo];
}

#pragma mark- frame相关
- (CGFloat)height {
    return self.scrollView.frame.size.height;
}

- (CGFloat)width {
    return self.scrollView.frame.size.width;
}

#pragma mark- 懒加载
- (NSOperationQueue *)queue {
    if (!_queue) {
        _queue = [[NSOperationQueue alloc] init];
    }
    return _queue;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.scrollsToTop = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.bounces = NO;
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.delegate = self;
        //添加手势监听图片的点击
        [_scrollView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageClick)]];
        [_scrollView addSubview:self.currImageView];
        [_scrollView addSubview:self.otherImageView];
    }
    return _scrollView;
}

- (UIImageView *)currImageView
{
    if (!_currImageView) {
        _currImageView = [[UIImageView alloc] init];
        _currImageView.clipsToBounds = YES;
        [_currImageView addSubview:self.currControlView];
        [_currImageView addSubview:self.currTitleLabel];
        [_currImageView addSubview:self.currDescLabel];
    }
    return  _currImageView;
}

- (UIImageView *)otherImageView
{
    if (!_otherImageView) {
        _otherImageView = [[UIImageView alloc] init];
        _otherImageView.clipsToBounds = YES;
        [_otherImageView addSubview:self.nextControlView];
        [_otherImageView addSubview:self.nextTitleLabel];
        [_otherImageView addSubview:self.nextDescLabel];
    }
    return  _otherImageView;
}

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.userInteractionEnabled = NO;
        _pageControl.hidden = YES;
    }
    return _pageControl;
}

- (CXPageControl *)cx_pageControl
{
    if (!_cx_pageControl) {
        _cx_pageControl = [[CXPageControl alloc] init];
        _cx_pageControl.userInteractionEnabled = NO;
        _cx_pageControl.hidden = YES;
    }
    return _cx_pageControl;
}

- (UIView *)currControlView
{
    if (!_currControlView) {
        _currControlView = [[UIView alloc] init];
        _currControlView.userInteractionEnabled = NO; // 禁掉交互防止滑动失效
        _currControlView.hidden = YES;
    }
    return _currControlView;
}

- (UIView *)nextControlView
{
    if (!_nextControlView) {
        _nextControlView = [[UIView alloc] init];
        _nextControlView.userInteractionEnabled = NO; // 禁掉交互防止滑动失效
        _nextControlView.hidden = YES;
    }
    return _nextControlView;
}

- (UIView *)pageProgress
{
    if (!_pageProgress) {
        _pageProgress = [[UIView alloc] init];
        _pageProgress.userInteractionEnabled = NO;
        _pageProgress.backgroundColor = [UIColor whiteColor];
        _pageProgress.hidden = YES;
    }
    return _pageProgress;
}

- (UILabel *)currTitleLabel
{
    if (!_currTitleLabel) {
        _currTitleLabel = [[UILabel alloc] init];
        _currTitleLabel.userInteractionEnabled = NO;
        _currTitleLabel.backgroundColor = [UIColor clearColor];
        _currTitleLabel.textColor = [UIColor whiteColor];
        _currTitleLabel.textAlignment = NSTextAlignmentLeft;
        _currTitleLabel.font = [UIFont systemFontOfSize:24];
        _currTitleLabel.numberOfLines = 2;
        _currTitleLabel.hidden = YES;
    }
    return _currTitleLabel;
}

- (UILabel *)nextTitleLabel
{
    if (!_nextTitleLabel) {
        _nextTitleLabel = [[UILabel alloc] init];
        _nextTitleLabel.userInteractionEnabled = NO;
        _nextTitleLabel.backgroundColor = [UIColor clearColor];
        _nextTitleLabel.textColor = [UIColor whiteColor];
        _nextTitleLabel.textAlignment = NSTextAlignmentLeft;
        _nextTitleLabel.font = [UIFont systemFontOfSize:24];
        _nextTitleLabel.numberOfLines = 2;
        _nextTitleLabel.hidden = YES;
    }
    return _nextTitleLabel;
}

- (UILabel *)currDescLabel
{
    if (!_currDescLabel) {
        _currDescLabel = [[UILabel alloc] init];
        _currDescLabel.userInteractionEnabled = NO;
        _currDescLabel.backgroundColor = [UIColor clearColor];
        _currDescLabel.textColor = [UIColor whiteColor];
        _currDescLabel.textAlignment = NSTextAlignmentLeft;
        _currDescLabel.font = [UIFont systemFontOfSize:12];
        _currDescLabel.numberOfLines = 1;
        _currDescLabel.hidden = YES;
    }
    return _currDescLabel;
}

- (UILabel *)nextDescLabel
{
    if (!_nextDescLabel) {
        _nextDescLabel = [[UILabel alloc] init];
        _nextDescLabel.userInteractionEnabled = NO;
        _nextDescLabel.backgroundColor = [UIColor clearColor];
        _nextDescLabel.textColor = [UIColor whiteColor];
        _nextDescLabel.textAlignment = NSTextAlignmentLeft;
        _nextDescLabel.font = [UIFont systemFontOfSize:12];
        _nextDescLabel.numberOfLines = 1;
        _nextDescLabel.hidden = YES;
    }
    return _nextDescLabel;
}

#pragma mark- --------设置相关方法--------
#pragma mark 设置分页控件类型
- (void)setPageControlType:(PageControlType)pageControlType {
    _pageControlType = pageControlType;
    switch (pageControlType) {
            
        case PageControlTypeDefault:
            [_pageProgress removeFromSuperview];
            [_cx_pageControl removeFromSuperview];
            [self addSubview:self.pageControl];
            self.pageControl.hidden = NO;
            break;
            
        case PageControlTypeLine:
            [_pageControl removeFromSuperview];
            [_cx_pageControl removeFromSuperview];
            [self addSubview:self.pageProgress];
            self.pageProgress.hidden = NO;
            break;
            
        case PageControlTypeShortLine:
            [_pageProgress removeFromSuperview];
            [_pageControl removeFromSuperview];
            [self addSubview:self.cx_pageControl];
            self.cx_pageControl.hidden = NO;
            
            break;
        default:
            break;
    }
}

#pragma mark 设置图片的内容模式
- (void)setContentMode:(UIViewContentMode)contentMode {
    _contentMode = contentMode;
    _currImageView.contentMode = contentMode;
    _otherImageView.contentMode = contentMode;
}

#pragma mark 设置图片数组
- (void)setImageArray:(NSArray *)imageArray{
    
    if (!imageArray.count) return;
    
    _imageArray = imageArray;
    _images = [NSMutableArray array];
    
    for (int i = 0; i < imageArray.count; i++) {
        if ([imageArray[i] isKindOfClass:[UIImage class]]) {
            [_images addObject:imageArray[i]];
        } else if ([imageArray[i] isKindOfClass:[NSString class]]){
            //如果是网络图片，则先添加占位图片，下载完成后替换
            if (_placeholderImage) [_images addObject:_placeholderImage];
            else [_images addObject:[UIImage imageNamed:@"占位logo"]];
            [self downloadImages:i];
        }
    }
    
    //防止在滚动过程中重新给imageArray赋值时报错
    if (_currIndex >= _images.count) _currIndex = _images.count - 1;
    self.currImageView.image = _images[_currIndex];
    self.currTitleLabel.text = _titleArray[_currIndex];
    self.currDescLabel.text = _descArray[_currIndex];
    switch (_pageControlType) {
            
        case PageControlTypeDefault:
            self.pageControl.numberOfPages = _images.count;
            break;
            
        case PageControlTypeLine:
            self.pageProgress.frame = CGRectMake(0, self.frame.size.height - 2, self.frame.size.width /(imageArray.count * 1.0), 2);
            break;
            
        case PageControlTypeShortLine:
            self.cx_pageControl.numberOfPages = _images.count;
            break;
            
        default:
            break;
    }
    [self layoutSubviews];
}

#pragma mark 设置标题数组
- (void)setTitleArray:(NSArray *)titleArray{
    _titleArray = titleArray;
    if (!titleArray.count) {
        _titleArray = nil;
        self.currTitleLabel.hidden = YES;
        self.nextTitleLabel.hidden = YES;
    } else {
        //如果描述的个数与图片个数不一致，则补空字符串
        if (titleArray.count < _images.count) {
            NSMutableArray *titles = [NSMutableArray arrayWithArray:titleArray];
            for (NSInteger i = titleArray.count; i < _images.count; i++) {
                [titles addObject:@""];
            }
            _titleArray = titles;
        }
        self.currTitleLabel.hidden = NO;
        self.nextTitleLabel.hidden = NO;
        self.currControlView.hidden = NO;
        self.nextControlView.hidden = NO;
        _currTitleLabel.text = _titleArray[_currIndex];
    }
    //重新计算pageControl的位置
    if (_pageControlType == PageControlTypeDefault || _pageControlType == PageControlTypeShortLine) {
        self.pagePosition = self.pagePosition;
    }
}

#pragma mark 设置desc数组
- (void)setDescArray:(NSArray *)descArray{
    _descArray = descArray;
    if (!descArray.count) {
        _descArray = nil;
        self.currDescLabel.hidden = YES;
        self.nextDescLabel.hidden = YES;
    } else {
        //如果描述的个数与图片个数不一致，则补空字符串
        if (descArray.count < _images.count) {
            NSMutableArray *describes = [NSMutableArray arrayWithArray:descArray];
            for (NSInteger i = descArray.count; i < _images.count; i++) {
                [describes addObject:@""];
            }
            _descArray = describes;
        }
        self.currDescLabel.hidden = NO;
        self.nextDescLabel.hidden = NO;
        _currDescLabel.text = _descArray[_currIndex];
    }
    //重新计算pageControl的位置
    if (_pageControlType == PageControlTypeDefault || _pageControlType == PageControlTypeShortLine) {
        self.pagePosition = self.pagePosition;
    }
}

#pragma mark 设置scrollView的contentSize
- (void)setScrollViewContentSize {
    if (_images.count > 1) {
        self.scrollView.contentSize = CGSizeMake(self.width * 5, 0);
        self.scrollView.contentOffset = CGPointMake(self.width * 2, 0);
        self.currImageView.frame = CGRectMake(self.width * 2, 0, self.width, self.height);
        
        if (_changeMode == ChangeModeFade) {
            //淡入淡出模式，两个imageView都在同一位置，改变透明度就可以了
            _currImageView.frame = CGRectMake(0, 0, self.width, self.height);
            _otherImageView.frame = self.currImageView.frame;
            _otherImageView.alpha = 0;
            [self insertSubview:self.currImageView atIndex:0];
            [self insertSubview:self.otherImageView atIndex:1];
        }
        
//        [self startTimer];
    } else {
        //只要一张图片时，scrollview不可滚动，且关闭定时器
        self.scrollView.contentSize = CGSizeZero;
        self.scrollView.contentOffset = CGPointZero;
        self.currImageView.frame = CGRectMake(0, 0, self.width, self.height);
//        [self stopTimer];
    }
}

#pragma mark 设置图片标题控件
- (void)setTitleTextColor:(UIColor *)color font:(UIFont *)font bgColor:(UIColor *)bgColor {
    if (color) {
        self.currTitleLabel.textColor = color;
        self.nextTitleLabel.textColor = color;
    }
    if (font) {
        self.currTitleLabel.font = font;
        self.nextTitleLabel.font = font;
    }
    if (bgColor) {
        self.currTitleLabel.backgroundColor = bgColor;
        self.nextTitleLabel.backgroundColor = bgColor;
    }
}

#pragma mark 设置图片描述控件
- (void)setDescTextColor:(UIColor *)color font:(UIFont *)font bgColor:(UIColor *)bgColor {
    if (color) {
        self.currDescLabel.textColor = color;
        self.nextDescLabel.textColor = color;
    }
    if (font) {
        self.currDescLabel.font = font;
        self.nextDescLabel.font = font;
    }
    if (bgColor) {
        self.currDescLabel.backgroundColor = bgColor;
        self.nextDescLabel.backgroundColor = bgColor;
    }
}

#pragma mark 设置Line分页控件
- (void)setProgressColor:(UIColor *)currentColor height:(CGFloat)height {
    self.pageProgress.backgroundColor = currentColor;
    self.pageProgress.frame = CGRectMake(0, self.frame.size.height - height, self.frame.size.width /(_images.count * 1.0), height);
}

#pragma mark - 设置ShortLine分页控件
- (void)setIsShowPagination:(BOOL)isShowPagination PagiationColor:(UIColor *)pagiationColor fontSize:(CGFloat)fontSize SelectedWidth:(CGFloat)selectedWidth otherWidth:(CGFloat)otherWidth height:(CGFloat)heigth spaceWidth:(CGFloat)spaceWidth selectedColor:(UIColor *)selectedColor otherColor:(UIColor *)otherColor
{
    if (isShowPagination) self.cx_pageControl.isShowPagination = isShowPagination;
    [self.cx_pageControl setPagiationColor:pagiationColor fontSize:fontSize];
    [self.cx_pageControl setSelectedWidth:selectedWidth otherWidth:otherWidth height:heigth spaceWidth:spaceWidth];
    if (selectedColor) self.cx_pageControl.selectedColor = selectedColor;
    if (otherColor) self.cx_pageControl.otherColor = otherColor;
}

#pragma mark 设置pageControl的指示器图片
- (void)setPageImage:(UIImage *)image andCurrentPageImage:(UIImage *)currentImage {
    if (!image || !currentImage) return;
    self.pageImageSize = image.size;
    [self.pageControl setValue:currentImage forKey:@"_currentPageImage"];
    [self.pageControl setValue:image forKey:@"_pageImage"];
}

#pragma mark 设置pageControl的指示器颜色
- (void)setPageColor:(UIColor *)color andCurrentPageColor:(UIColor *)currentColor {
    _pageControl.pageIndicatorTintColor = color;
    _pageControl.currentPageIndicatorTintColor = currentColor;
}

#pragma mark 设置pageControl 及 cx_pageControl的位置
- (void)setPagePosition:(PageControlPosition)pagePosition {
    _pagePosition = pagePosition;
    _pageControl.hidden = (_pagePosition == PositionHide) || (_imageArray.count == 1);
    _cx_pageControl.hidden = (_pagePosition == PositionHide) || (_imageArray.count == 1);
    _pageProgress.hidden = (_pagePosition == PositionHide) || (_imageArray.count == 1);
    switch (self.pageControlType) {
        case PageControlTypeDefault: {
            if (_pageControl.hidden) return;
            
            CGSize size;
            if (!_pageImageSize.width) {//没有设置图片，系统原有样式
                size.height = 8;
                size.width = self.width * 0.3;
            } else {//设置图片了
                size = CGSizeMake(_pageImageSize.width * (_pageControl.numberOfPages * 2 - 1), _pageImageSize.height);
            }
            self.pageControl.frame = CGRectMake(0, 0, size.width, size.height);
            
            CGFloat centerY = self.height - size.height * 0.5 - 13;
            CGFloat pointY = self.height - 13 - size.height;
            
            if (_pagePosition == PositionDefault || _pagePosition == PositionBottomCenter)
                _pageControl.center = CGPointMake(self.width * 0.5, centerY);
            else if (_pagePosition == PositionTopCenter)
                _pageControl.center = CGPointMake(self.width * 0.5, size.height * 0.5 + VERMARGIN);
            else if (_pagePosition == PositionBottomLeft)
                _pageControl.frame = CGRectMake(HORMARGIN, pointY, size.width, size.height);
            else
                _pageControl.frame = CGRectMake(self.width - 20 - size.width, pointY, size.width, size.height);

            break;
        }
        case PageControlTypeLine:
            if (_pageProgress.hidden) return;
            break;
        
        case PageControlTypeShortLine: {
            if (_cx_pageControl.hidden) return;
            CGSize size = CGSizeMake(self.cx_pageControl.width , 20);
            self.cx_pageControl.frame = CGRectMake(0, 0, size.width, size.height);
            
            CGFloat centerY = self.height - size.height * 0.5 - 13;
            CGFloat pointY = self.height - 13 - size.height;
            
            if (_pagePosition == PositionDefault || _pagePosition == PositionBottomCenter)
                self.cx_pageControl.center = CGPointMake(self.width * 0.5, centerY);
            else if (_pagePosition == PositionTopCenter)
                self.cx_pageControl.center = CGPointMake(self.width * 0.5, size.height * 0.5 + VERMARGIN);
            else if (_pagePosition == PositionBottomLeft)
                self.cx_pageControl.frame = CGRectMake(HORMARGIN, pointY, size.width, size.height);
            else
                self.cx_pageControl.frame = CGRectMake(self.width - 23 - size.width, pointY, size.width, size.height);

            break;
        }
        default:
            return;
            break;
    }
    
}

#pragma mark 设置定时器时间
- (void)setTime:(NSTimeInterval)time {
    _time = time;
//    [self startTimer];
}

#pragma mark- --------定时器相关方法--------
- (void)startTimer {
    //如果只有一张图片，则直接返回，不开启定时器
    if (_images.count <= 1) return;
    //如果定时器已开启，先停止再重新开启
    if (self.timer) [self stopTimer];
    self.timer = [NSTimer timerWithTimeInterval:_time < 2? DEFAULTTIME: _time target:self selector:@selector(nextPage) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)stopTimer {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)nextPage {
    if (_changeMode == ChangeModeFade) {
        //淡入淡出模式，不需要修改scrollview偏移量，改变两张图片的透明度即可
        self.nextIndex = (self.currIndex + 1) % _images.count;
        self.otherImageView.image = _images[_nextIndex];
        self.nextTitleLabel.text = _titleArray[_nextIndex];
        self.nextDescLabel.text = _descArray[_nextIndex];
        
        [UIView animateWithDuration:1.2 animations:^{
            self.currImageView.alpha = 0;
            self.otherImageView.alpha = 1;
            switch (self.pageControlType) {
                case PageControlTypeDefault:
                    self.pageControl.currentPage = _nextIndex;
                    break;
                    
                case PageControlTypeLine: {
                    CGFloat w = self.frame.size.width / (_images.count * 1.0);
                    self.pageProgress.frame = CGRectMake(w * _nextIndex, self.pageProgress.frame.origin.y, w, self.pageProgress.frame.size.height);
                    break;
                }
                case PageControlTypeShortLine:
                    self.cx_pageControl.currentPage = _nextIndex;
                    break;
                    
                default:
                    break;
            }
        } completion:^(BOOL finished) {
            [self changeToNext];
        }];
        
    } else [self.scrollView setContentOffset:CGPointMake(self.width * 3, 0) animated:YES];
}

#pragma mark- -----------其它-----------
#pragma mark 布局子控件
- (void)layoutSubviews {
    [super layoutSubviews];
    //有导航控制器时，会默认在scrollview上方添加64的内边距，这里强制设置为0
    _scrollView.contentInset = UIEdgeInsetsZero;
    
    _scrollView.frame = self.bounds;
    _currTitleLabel.frame = CGRectMake(20, self.height - TITLE_LABEL_H - 20 - DES_LABEL_H, self.width - 40, TITLE_LABEL_H);
    _currDescLabel.frame = CGRectMake(20, self.height - 13 - DES_LABEL_H, self.width - 40, DES_LABEL_H);
    _nextTitleLabel.frame = CGRectMake(20, self.height - TITLE_LABEL_H - 20 - DES_LABEL_H, self.width - 40, TITLE_LABEL_H);
    _nextDescLabel.frame = CGRectMake(20, self.height - 13 - DES_LABEL_H, self.width - 40, DES_LABEL_H);
    [self layoutControlViews];
    //重新计算pageControl的位置
    if (_pageControlType == PageControlTypeDefault || _pageControlType == PageControlTypeShortLine) {
        self.pagePosition = self.pagePosition;
    }
    [self setScrollViewContentSize];
}

- (void)layoutControlViews
{
    CGFloat h = 118.5 / 375.0 * self.height;
    _currControlView.frame = CGRectMake(0, self.height - h, self.frame.size.width, h);
    _currControlView.layer.sublayers = nil;
    CAGradientLayer *currGradientLayer = [CAGradientLayer layer];
    currGradientLayer.frame = _currControlView.bounds;
    // 设置颜色
    currGradientLayer.colors = @[(id)[[UIColor blackColor] colorWithAlphaComponent:0.0f].CGColor,
                             (id)[[UIColor blackColor] colorWithAlphaComponent:0.6f].CGColor];
    currGradientLayer.locations = @[[NSNumber numberWithFloat:0],
                                [NSNumber numberWithFloat:1.0f]];
    // 添加渐变图层
    [_currControlView.layer addSublayer:currGradientLayer];
    
    _nextControlView.frame = CGRectMake(0, self.height - h, self.frame.size.width, h);
    _nextControlView.layer.sublayers = nil;
    CAGradientLayer *nextGradientLayer = [CAGradientLayer layer];
    nextGradientLayer.frame = _nextControlView.bounds;
    // 设置颜色
    nextGradientLayer.colors = @[(id)[[UIColor blackColor] colorWithAlphaComponent:0.0f].CGColor,
                             (id)[[UIColor blackColor] colorWithAlphaComponent:0.6f].CGColor];
    nextGradientLayer.locations = @[[NSNumber numberWithFloat:0],
                                [NSNumber numberWithFloat:1.0f]];
    // 添加渐变图层
    [_nextControlView.layer addSublayer:nextGradientLayer];
}


#pragma mark 图片点击事件
- (void)imageClick {
    if (self.imageClickBlock) {
        self.imageClickBlock(self.currIndex);
    } else if ([_delegate respondsToSelector:@selector(pageView:clickImageAtIndex:)]){
        [_delegate pageView:self clickImageAtIndex:self.currIndex];
    }
}

#pragma mark 下载网络图片 
- (void)downloadImages:(int)index {
    NSString *urlString = _imageArray[index];
    NSString *imageName = [urlString stringByReplacingOccurrencesOfString:@"/" withString:@""];
    NSString *path = [cache stringByAppendingPathComponent:imageName];
    if (_autoCache) { // 如果开启了缓存功能，先从沙盒中取图片
        NSData *data = [NSData dataWithContentsOfFile:path];
        if (data) {
            _images[index] = getImageWithData(data);
            return;
        }
    }
    // 下载图片
    NSBlockOperation *download = [NSBlockOperation blockOperationWithBlock:^{
        UIImage *image;
        NSData *data;
        data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
        if (!data) return;
        image = getImageWithData(data);
    
        //取到的data有可能不是图片
        if (image) {
            self.images[index] = image;
            //如果下载的图片为当前要显示的图片，直接到主线程给imageView赋值，否则要等到下一轮才会显示
            if (_currIndex == index) [_currImageView performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:NO];
            if (_autoCache) [data writeToFile:path atomically:YES];
        }
    }];
    [self.queue addOperation:download];
    
}

/* 获取视频第一帧缩略图 */
- (UIImage *)getThumbailImageRequestWithUrlString:(NSString *)urlString {
    //视频文件URL地址
    NSURL *url = [NSURL URLWithString:urlString];
    //创建媒体信息对象AVURLAsset
    AVURLAsset *urlAsset = [AVURLAsset assetWithURL:url];
    //创建视频缩略图生成器对象AVAssetImageGenerator
    AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlAsset];
    //创建视频缩略图的时间，第一个参数是视频第几秒，第二个参数是每秒帧数
    CMTime time = CMTimeMake(0, 10);
    CMTime actualTime;//实际生成视频缩略图的时间
    NSError *error = nil;//错误信息
    //使用对象方法，生成视频缩略图，注意生成的是CGImageRef类型，如果要在UIImageView上显示，需要转为UIImage
    CGImageRef cgImage = [imageGenerator copyCGImageAtTime:time
                                                actualTime:&actualTime
                                                     error:&error];
    if (error) {
        NSLog(@"截取视频缩略图发生错误，错误信息：%@",error.localizedDescription);
        return nil;
    }
    //CGImageRef转UIImage对象
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    //记得释放CGImageRef
    CGImageRelease(cgImage);
    return image;
}

/* 判断url是否是视频 */
- (BOOL)isVideoUrlString:(NSString *)urlString
{
    // 判断是否含有视频轨道（是否是视频）
    AVAsset *asset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:urlString] options:nil];
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    return [tracks count] > 0;
}

#pragma mark 下载图片，如果是 gif 则计算动画时长
UIImage *getImageWithData(NSData *data) {
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    size_t count = CGImageSourceGetCount(imageSource);
    if (count <= 1) { //非gif
        CFRelease(imageSource);
        return [[UIImage alloc] initWithData:data];
    } else { //gif图片
        NSMutableArray *images = [NSMutableArray array];
        NSTimeInterval duration = 0;
        for (size_t i = 0; i < count; i++) {
            CGImageRef image = CGImageSourceCreateImageAtIndex(imageSource, i, NULL);
            if (!image) continue;
            duration += durationWithSourceAtIndex(imageSource, i);
            [images addObject:[UIImage imageWithCGImage:image]];
            CGImageRelease(image);
        }
        if (!duration) duration = 0.1 * count;
        CFRelease(imageSource);
        return [UIImage animatedImageWithImages:images duration:duration];
    }
}


#pragma mark 获取每一帧图片的时长
float durationWithSourceAtIndex(CGImageSourceRef source, NSUInteger index) {
    float duration = 0.1f;
    CFDictionaryRef propertiesRef = CGImageSourceCopyPropertiesAtIndex(source, index, nil);
    NSDictionary *properties = (__bridge NSDictionary *)propertiesRef;
    NSDictionary *gifProperties = properties[(NSString *)kCGImagePropertyGIFDictionary];
    
    NSNumber *delayTime = gifProperties[(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
    if (delayTime) duration = delayTime.floatValue;
    else {
        delayTime = gifProperties[(NSString *)kCGImagePropertyGIFDelayTime];
        if (delayTime) duration = delayTime.floatValue;
    }
    CFRelease(propertiesRef);
    return duration;
}


#pragma mark 清除沙盒中的图片缓存
+ (void)clearDiskCache {
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:cache error:NULL];
    for (NSString *fileName in contents) {
        [[NSFileManager defaultManager] removeItemAtPath:[cache stringByAppendingPathComponent:fileName] error:nil];
    }
    [AVPlayerItem removeVideoCache];
}

#pragma mark 当图片滚动过半时就修改当前页码
- (void)changeCurrentPageWithOffset:(CGFloat)offsetX {
    NSInteger currP;
    if (offsetX < self.width * 1.5) {
        NSInteger index = self.currIndex - 1;
        if (index < 0) index = self.images.count - 1;
       currP = index;
    } else if (offsetX > self.width * 2.5){
        currP = (self.currIndex + 1) % self.images.count;
    } else {
        currP = self.currIndex;
    }
    switch (_pageControlType) {
            
        case PageControlTypeDefault:
            self.pageControl.currentPage = currP;
            break;
            
        case PageControlTypeLine: {
            CGFloat w = self.frame.size.width / (_images.count * 1.0);
            self.pageProgress.frame = CGRectMake(w * currP, self.pageProgress.frame.origin.y, w, self.pageProgress.frame.size.height);
            break;
        }
        case PageControlTypeShortLine:
            self.cx_pageControl.currentPage = currP;
            break;
            
        default:
            break;
    }

}

#pragma mark- --------UIScrollViewDelegate--------
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (CGSizeEqualToSize(CGSizeZero, scrollView.contentSize)) return;
    CGFloat offsetX = scrollView.contentOffset.x;
    //滚动过程中改变分页控件的当前页码
    [self changeCurrentPageWithOffset:offsetX];
    //向右滚动
    if (offsetX < self.width * 2) {
        if (_changeMode == ChangeModeFade) {
            self.currImageView.alpha = offsetX / self.width - 1;
            self.otherImageView.alpha = 2 - offsetX / self.width;
        } else self.otherImageView.frame = CGRectMake(self.width, 0, self.width, self.height);
        
        self.nextIndex = self.currIndex - 1;
        if (self.nextIndex < 0) self.nextIndex = _images.count - 1;
        self.otherImageView.image = self.images[self.nextIndex];
        self.nextTitleLabel.text = self.titleArray[self.nextIndex];
        self.nextDescLabel.text = self.descArray[self.nextIndex];
        if (offsetX <= self.width) {
            [self changeToNext];
        }
    //向左滚动
    } else if (offsetX > self.width * 2){
        if (_changeMode == ChangeModeFade) {
            self.otherImageView.alpha = offsetX / self.width - 2;
            self.currImageView.alpha = 3 - offsetX / self.width;
        } else self.otherImageView.frame = CGRectMake(CGRectGetMaxX(_currImageView.frame), 0, self.width, self.height);
        
        self.nextIndex = (self.currIndex + 1) % _images.count;
        self.otherImageView.image = self.images[self.nextIndex];
        self.nextTitleLabel.text = self.titleArray[self.nextIndex];
        self.nextDescLabel.text = self.descArray[self.nextIndex];
        if (offsetX >= self.width * 3) {
            [self changeToNext];
        }
    }
}

- (void)changeToNext {
    
    [self stopVideo];
    
    if (_changeMode == ChangeModeFade) {
        self.currImageView.alpha = 1;
        self.otherImageView.alpha = 0;
    }
    //切换到下一张图片
    self.currImageView.image = self.otherImageView.image;
    self.currTitleLabel.text = self.nextTitleLabel.text;
    self.currDescLabel.text = self.nextDescLabel.text;
    self.scrollView.contentOffset = CGPointMake(self.width * 2, 0);
    [self.scrollView layoutSubviews];
    self.currIndex = self.nextIndex;
    
    switch (self.pageControlType) {
        case PageControlTypeDefault:
            self.pageControl.currentPage = self.currIndex;
            break;
            
        case PageControlTypeLine: {
            CGFloat w = self.frame.size.width / (_images.count * 1.0);
            self.pageProgress.frame = CGRectMake(w * _currIndex, self.pageProgress.frame.origin.y, w, self.pageProgress.frame.size.height);
            break;
        }
        case PageControlTypeShortLine:
            self.cx_pageControl.currentPage = self.currIndex;
            break;
            
        default:
            break;
    }
    
}

- (void)stopVideo
{
    [self.player pause];
    self.player = nil;
    [self.playerLayer removeFromSuperlayer];
    self.playerLayer = nil;
}

// 在当前imageView播放视频
- (void)playVideo
{
    NSString *url = self.videoArray[_currIndex];
    // 再开一个线程创建 AVPlayerItem
    dispatch_queue_t globalQueue = dispatch_get_global_queue(0, 0);
    dispatch_async(globalQueue, ^{
        //创建AVPlayerItem
        AVPlayerItem *playerItem=[AVPlayerItem wg_playerItemWithURL:[NSURL URLWithString:url]];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (playerItem) {
                if (!_player) {
                    self.player = [AVPlayer playerWithPlayerItem:playerItem];
                    self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
                    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
                    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
                    self.playerLayer.frame = self.currImageView.bounds;
                    [self.currImageView.layer addSublayer:self.playerLayer];
                    [self.currImageView bringSubviewToFront:self.currControlView];
                    [self.currImageView bringSubviewToFront:self.currTitleLabel];
                    [self.currImageView bringSubviewToFront:self.currDescLabel];
                    [self.player play];
                }
            }
        });
    });
    
}

- (void)playerItemDidPlayToEndTimeNotification:(NSNotification *)sender
{
    [_player seekToTime:kCMTimeZero]; // seek to zero
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
//    [self stopTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
//    [self startTimer];
    
    BOOL dragToDragStop = scrollView.tracking && !scrollView.dragging && !scrollView.decelerating;
    if (dragToDragStop) {
        [self scrollViewDidEndScroll];
    }
}

//该方法用来修复滚动过快导致分页异常的bug
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (_changeMode == ChangeModeFade) return;
    CGPoint currPointInSelf = [_scrollView convertPoint:_currImageView.frame.origin toView:self];
    if (currPointInSelf.x >= -self.width / 2.0 && currPointInSelf.x <= self.width / 2.0)
        [self.scrollView setContentOffset:CGPointMake(self.width * 2.0, 0) animated:YES];
    else [self changeToNext];
    
    BOOL scrollToScrollStop = !scrollView.tracking && !scrollView.dragging && !scrollView.decelerating;
    if (scrollToScrollStop) {
        [self scrollViewDidEndScroll];
    }
}

#pragma mark - scrollView 停止滚动监测
- (void)scrollViewDidEndScroll {
    [self playVideo];
}

@end


UIImage *gifImageNamed(NSString *imageName) {
    
    if (![imageName hasSuffix:@".gif"]) {
        imageName = [imageName stringByAppendingString:@".gif"];
    }
    
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:imageName ofType:nil];
    NSData *data = [NSData dataWithContentsOfFile:imagePath];
    if (data) return getImageWithData(data);
    
    return [UIImage imageNamed:imageName];
}

