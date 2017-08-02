//
//  CXPageView.h
//  CXPageView
//
//  Created by 郭晨香 on 2017/7/21.
//  Copyright © 2017年 郭晨香. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@class CXPageView;

typedef void(^ClickBlock)(NSInteger index);

//pageControl的显示位置
typedef enum {
    PositionDefault,           //默认值 == PositionBottomCenter
    PositionHide,           //隐藏
    PositionTopCenter,      //中上
    PositionBottomLeft,     //左下
    PositionBottomCenter,   //中下
    PositionBottomRight     //右下
} PageControlPosition;

//图片切换的方式
typedef enum {
    ChangeModeDefault,  //轮播滚动
    ChangeModeFade      //淡入淡出
} ChangeMode;

//三种分页控件
typedef enum {
    PageControlTypeDefault,  // 系统分页控件
    PageControlTypeLine,      // 底部line分页控件
    PageControlTypeShortLine // 短线分页控件
} PageControlType;

/**
 *  代理
 */
@protocol CXPageViewDelegate <NSObject>

/**
 *  该方法用来处理图片的点击，会返回图片在数组中的索引
 *  代理与block二选一即可，若两者都实现，block的优先级高
 *
 *  @param pageView 控件本身
 *  @param index        图片索引
 */
- (void)pageView:(CXPageView *)pageView clickImageAtIndex:(NSInteger)index;

@end


/**
 *  C语言函数，创建本地gif图片
 *  本地gif图片请使用该函数创建，否则gif无动画效果
 *  @param imageName 图片名称
 */
UIImage *gifImageNamed(NSString *imageName);


/**
 *  说明：要想正常使用，图片数组imageArray必须设置
 *  控件的frame必须设置，xib\sb创建的可不设置
 *  其他属性都有默认值，可不设置
 */
@interface CXPageView : UIView

#pragma mark 属性
/**
 *  设置图片的切换模式，默认为ChangeModeDefault
 */
@property (nonatomic, assign) ChangeMode changeMode;

/**
 *  设置分页控件类型，默认为PageControlTypeDefault
 *  在图片数组之前设置
 */
@property (nonatomic, assign) PageControlType pageControlType;

/**
 *  设置图片的内容模式，默认为UIViewContentModeScaleToFill
 */
@property (nonatomic, assign) UIViewContentMode contentMode;

/**
 *  设置分页控件位置，默认为PositionBottomCenter
 *  只有一张图片时，分页控件隐藏
 *  pageControlType 为 Line 时，设置失效
 *  在图片数组之前，分页控件类型之后设置
 */
@property (nonatomic, assign) PageControlPosition pagePosition;

/**
 *  占位图片，在设置图片数组之前设置
 *  不设置则为默认占位图
 */
@property (nonatomic, strong) UIImage *placeholderImage;

/**
 *  轮播的图片数组，视频占位图片，可以是本地图片（UIImage，不能是图片名称），也可以是网络路径
 *  支持网络gif图片，本地gif需做处理后传入
 *  若传入视频路径，取第一帧作为占位图
 */
@property (nonatomic, strong) NSArray *imageArray;

/**
 *  轮播的视频数组
 *  若需要自行设置视频占位图，imageArray中传占位url，videoArray中传视频url
 */
@property (nonatomic, strong) NSArray *videoArray;

/**
 *  图片描述的字符串数组，应与图片顺序对应
 *
 *  图片描述控件默认是隐藏的
 *  设置该属性，控件会显示
 *  设置为nil或空数组，控件会隐藏
 */
@property (nonatomic, strong) NSArray *titleArray;

/**
 *  图片描述的字符串数组，应与图片顺序对应
 *
 *  图片描述控件默认是隐藏的
 *  设置该属性，控件会显示
 *  设置为nil或空数组，控件会隐藏
 */
@property (nonatomic, strong) NSArray *descArray;

/**
 *  是否开启自动轮播，默认为YES
 */
@property (nonatomic, assign) BOOL autoCyclePlay;

/**
 *  每一页停留时间，默认为5s，最少2s
 *  当设置的值小于2s时，则为默认值
 */
@property (nonatomic, assign) NSTimeInterval time;

/**
 *  是否开启图片缓存，默认为YES
 */
@property (nonatomic, assign) BOOL autoCache;

/**
 *  点击图片后要执行的操作，会返回图片在数组中的索引
 */
@property (nonatomic, copy) ClickBlock imageClickBlock;

/**
 *  代理，用来处理图片的点击
 */
@property (nonatomic, weak) id<CXPageViewDelegate> delegate;


@property (nonatomic, strong) AVPlayerLayer *playerLayer;

@property (nonatomic, assign) BOOL isPlaying;
#pragma mark 方法

/**
 *  开启定时器
 *  默认已开启，调用该方法会重新开启
 */
- (void)startTimer;


/**
 *  停止定时器
 *  停止后，如果手动滚动图片，定时器会重新开启
 */
- (void)stopTimer;

#pragma mark - 系统分页控件 - PageControlTypeDefault
/**
 *  设置分页控件指示器的图片
 *  两个图片必须同时设置，否则设置无效
 *  不设置则为系统默认
 *
 *  @param image    其他页码的图片
 *  @param currentImage 当前页码的图片
 */
- (void)setPageImage:(UIImage *)image andCurrentPageImage:(UIImage *)currentImage;

/**
 *  设置分页控件指示器的颜色
 *  不设置则为系统默认
 *
 *  @param color        其他页码的颜色
 *  @param currentColor 当前页码的颜色
 */
- (void)setPageColor:(UIColor *)color andCurrentPageColor:(UIColor *)currentColor;

#pragma mark - 底端Line分页控件 - PageControlTypeLine
/**
 *  设置分页控件的颜色及高度
 *  不设置则为白色
 *
 *  @param currentColor 当前页码的颜色
 *  @param height 控件高度，默认2
 */
- (void)setProgressColor:(UIColor *)currentColor height:(CGFloat)height;

#pragma mark - 自定义短线分页控件 - PageControlTypeShortLine
/**
 *  设置分页控件 是否显示页码（默认显示），页码颜色（默认 white），字体大小(默认10)
 *  短线长度（默认14），短线高度（默认2），短线间间隔（默认4）
 *  选中短线颜色 ： 默认 white
 *  未选中短线颜色 ： 默认 gray
 *  不需设置的设为 nil / 0 即可
 */
- (void)setIsShowPagination:(BOOL)isShowPagination PagiationColor:(UIColor *)pagiationColor fontSize:(CGFloat)fontSize lineWidth:(CGFloat)lineWidth height:(CGFloat)heigth spaceWidth:(CGFloat)spaceWidth selectedColor:(UIColor *)selectedColor otherColor:(UIColor *)otherColor;

#pragma mark - 标题及描述控件
/**
 *  修改标题控件的部分属性，不需要修改的传nil
 *
 *  @param color   字体颜色，默认为 [UIColor whiteColor]
 *  @param font    字体，默认为 [UIFont fontWithName:@"PingFangSC-Semibold" size:24]
 *  @param bgColor 背景颜色，默认为 [UIColor clearColor]
 */
- (void)setTitleTextColor:(UIColor *)color font:(UIFont *)font bgColor:(UIColor *)bgColor;

/**
 *  修改描述控件的部分属性，不需要修改的传nil
 *  @param color   字体颜色，默认为[UIColor whiteColor]
 *  @param font    字体，默认为[UIFont systemFontOfSize:12]
 *  @param bgColor 背景颜色，默认为[UIColor clearColor]
 */
- (void)setDescTextColor:(UIColor *)color font:(UIFont *)font bgColor:(UIColor *)bgColor;


/**
 *  清除沙盒中的图片缓存
 */
+ (void)clearDiskCache;

/**
 *  开始播放
 */
- (void)playVideo;
/**
*  停止播放
*/
- (void)stopVideo;

@end
