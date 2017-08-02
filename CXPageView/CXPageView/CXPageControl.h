//
//  CXPageControl.h
//  CXPageView
//
//  Created by 郭晨香 on 2017/7/21.
//  Copyright © 2017年 郭晨香. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CXPageControl : UIView

/**
 * 分页数量
 */
@property(nonatomic, assign) NSInteger numberOfPages;
/**
 * 当前页码
 */
@property(nonatomic, assign) NSInteger currentPage;
/**
 * 选中短线颜色 ： 默认 white
 */
@property(nonatomic, strong) UIColor *selectedColor;
/**
 * 未选中短线颜色 ： 默认 gray
 */
@property(nonatomic, strong) UIColor *otherColor;
/**
 * 是否显示页码 ： 默认显示
 */
@property(nonatomic, assign) BOOL isShowPagination;

#pragma mark - publicMethod
/**
 * 设置短线长度（默认14)，短线高度（默认2），短线间间隔（默认4）
 * 不需设置的设为nil即可
 */
- (void)setLineWidth:(CGFloat)lineWidth height:(CGFloat)heigth spaceWidth:(CGFloat)spaceWidth;

/**
 * 设置页码颜色（默认 white），字体大小(默认10)
 * 不需设置的设为nil即可
 */
- (void)setPagiationColor:(UIColor *)pagiationColor fontSize:(CGFloat)fontSize;

/**
 * 返回控件的宽度
 */
- (CGFloat)width;

/**
 * 滑动动画
 */
- (void)slidePageControlAtProgress:(CGFloat)rate toNext:(BOOL)toNext;

@end
