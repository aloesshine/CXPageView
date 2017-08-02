//
//  ViewController.m
//  CXPageScrollView
//
//  Created by 郭晨香 on 2017/7/18.
//  Copyright © 2017年 郭晨香. All rights reserved.
//

#import "CXViewController.h"
#import "CXPageView.h"
#import <AVFoundation/AVFoundation.h>

@interface CXViewController () <CXPageViewDelegate>

@property (nonatomic, strong) CXPageView *pageView;

@end

@implementation CXViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGFloat w = self.view.bounds.size.width;
    _pageView = [[CXPageView alloc] initWithFrame:CGRectMake(0, 100, w, 400)];
    _pageView.contentMode = UIViewContentModeScaleAspectFill;
    _pageView.delegate = self;
    _pageView.pageControlType = PageControlTypeShortLine;
    _pageView.time = 5;
    _pageView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:_pageView];
    NSArray *imagesURLStrings = @[
                                  @"http://dl.w.xk.miui.com/c64aea3266d6f8e777aa659152a22a73.720p.mp4",
                                  @"https://media.giphy.com/media/kFqoBzMYjV8TC/giphy.gif",
                                  @"https://media.giphy.com/media/12FparngCjPtC0/giphy.gif",
                                  @"https://media.giphy.com/media/lyLRTrqRpW8YU/giphy.gif",
                                  @"https://p1.pstatp.com/aweme/1080x1080/216a00017bc43d43f663.jpeg",
                                  @"http://dl.w.xk.miui.com/f221302d31d8179d2fbd9ee70fd0f188"
                                  ];
    _pageView.titleArray = @[
                                @"龙珠传奇：杨紫秦俊杰称兄道弟半夜座谈深宫诡计",
                                @"美丽的星空美丽的星空美丽的星空美丽的星空",
                                @"呜呜呜，小姐姐哭的好让人心疼",
                                @"原子质子中子电子夸克的运动状态？",
                                @"美腻的小姐姐小姐姐好美腻～",
                                @"没想到美甲也能算艺术？一起来了解并传递女性心声"
                                ];
    _pageView.descArray = @[
                               @"悠然1052 | 3:01",
                               @"aloes | 2:30",
                               @"wayo | 1:16",
                               @"gxxod | 0:48",
                               @"haha | 0:02",
                               @"xiangkan | 3:29"
                               ];
    [_pageView setDescTextColor:[UIColor colorWithWhite:0.8 alpha:1] font:nil bgColor:nil];
    [_pageView setIsShowPagination:YES PagiationColor:[UIColor colorWithWhite:0.8 alpha:1] fontSize:0 lineWidth:0 height:0 spaceWidth:0 selectedColor:[UIColor colorWithRed:249 / 255.0 green:87 / 255.0 blue:73 / 255.0 alpha:1] otherColor:[UIColor colorWithWhite:0.6 alpha:1]];
    _pageView.imageArray = imagesURLStrings;
    _pageView.pagePosition = PositionBottomRight;
}

#pragma mark CXPageViewDelegate
- (void)pageView:(CXPageView *)pageView clickImageAtIndex:(NSInteger)index {
    NSLog(@"点击了第%ld张图片", index);
}
@end
