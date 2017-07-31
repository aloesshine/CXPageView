//
//  VideoPlayViewController.m
//  CXPageView
//
//  Created by 郭晨香 on 2017/7/25.
//  Copyright © 2017年 郭晨香. All rights reserved.
//

#import "VideoPlayViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface VideoPlayViewController ()

@property (nonatomic, strong) UIImageView *containView;

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *layer;
@property (nonatomic, strong) AVPlayerItem *item;

@end

@implementation VideoPlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _containView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 50, 300, 300)];
    _containView.image = [UIImage imageNamed:@"XKPlaceholder"];
    [self.view addSubview:_containView];
    
    NSURL * url = [NSURL URLWithString:@"http://dl.w.xk.miui.com/ab2f6395d1a3a0092404ab9e358273b1.720p.mp4"];
    self.item = [AVPlayerItem playerItemWithURL:url];
    self.player = [AVPlayer playerWithPlayerItem:self.item];
    [self.player addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    self.layer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.layer.videoGravity     = AVLayerVideoGravityResizeAspect;
    self.layer.frame = self.containView.bounds;
    [self.containView.layer addSublayer:self.layer];
}

/* 属性发生变化，KVO响应函数 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"status"]) {//状态发生改变
        AVPlayerStatus status = [[change objectForKey:@"new"] integerValue];
        if (status == AVPlayerStatusReadyToPlay) {
            [_player play];
        }
    }
}

- (void)dealloc
{
    [self.player removeObserver:self forKeyPath:@"status"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
