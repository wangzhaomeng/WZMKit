//
//  WZMPhotoDuibiViewController.m
//  WZMKit_Example
//
//  Created by Zhaomeng Wang on 2021/1/28.
//  Copyright © 2021 wangzhaomeng. All rights reserved.
//

#import "WZMPhotoDuibiViewController.h"

#define LINE_COLOR [UIColor blueColor]
#define SHAN_CLOOR [UIColor redColor]
@interface WZMPhotoDuibiViewController ()<WZMAlbumNavigationControllerDelegate>

@property (nonatomic, strong) UIButton *addBtn;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *imageContentView1;
@property (nonatomic, strong) UIView *imageContentView2;
@property (nonatomic, strong) UIImageView *imageView1;
@property (nonatomic, strong) UIImageView *imageView2;
@property (nonatomic, strong) UIView *toolView;
@property (nonatomic, strong) UIView *trashView;
@property (nonatomic, assign, getter=isLocked) BOOL locked;
@property (nonatomic, strong) UILabel *trashLabel;

@end

@implementation WZMPhotoDuibiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.contentView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.contentView];
    
    self.imageContentView1 = [[UIView alloc] initWithFrame:self.contentView.bounds];
    self.imageContentView1.userInteractionEnabled = NO;
    [self.contentView addSubview:self.imageContentView1];
    
    self.imageContentView2 = [[UIView alloc] initWithFrame:self.contentView.bounds];
    self.imageContentView2.userInteractionEnabled = NO;
    [self.contentView addSubview:self.imageContentView2];
    
    self.imageView1 = [[UIImageView alloc] initWithFrame:self.imageContentView1.bounds];
    self.imageView1.alpha = 1.0;
    self.imageView1.contentMode = UIViewContentModeScaleAspectFit;
    [self.imageContentView1 addSubview:self.imageView1];
    
    self.imageView2 = [[UIImageView alloc] initWithFrame:self.imageContentView2.bounds];
    self.imageView2.alpha = 0.5;
    self.imageView2.contentMode = UIViewContentModeScaleAspectFit;
    [self.imageContentView2 addSubview:self.imageView2];
    
    self.addBtn = [[UIButton alloc] initWithFrame:CGRectMake((WZM_SCREEN_WIDTH-80.0)/2.0, (WZM_SCREEN_HEIGHT-80.0)/2.0, 80.0, 80.0)];
    [self.addBtn setBackgroundImage:[UIImage imageNamed:@"photo_add"] forState:UIControlStateNormal];
    [self.addBtn addTarget:self action:@selector(addBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.addBtn];
    
    CGFloat trashW = WZM_SCREEN_WIDTH/3.0;
    self.trashView = [[UIView alloc] initWithFrame:CGRectMake((WZM_SCREEN_WIDTH-trashW)/2.0, (WZM_SCREEN_HEIGHT-trashW)/2.0, trashW, trashW)];
    self.trashView.hidden = YES;
    self.trashView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
    self.trashView.wzm_cornerRadius = trashW/2.0;
    [self.contentView addSubview:self.trashView];
    
    self.trashLabel = [[UILabel alloc] initWithFrame:self.trashView.bounds];
    self.trashLabel.text = @"拖拽删除辅助线";
    self.trashLabel.textColor = [UIColor whiteColor];
    self.trashLabel.textAlignment = NSTextAlignmentCenter;
    self.trashLabel.font = [UIFont boldSystemFontOfSize:13];
    self.trashLabel.numberOfLines = 0;
    [self.trashView addSubview:self.trashLabel];
    
    self.toolView = [[UIView alloc] initWithFrame:CGRectMake(10.0, WZM_SCREEN_HEIGHT-100.0-WZM_BOTTOM_HEIGHT, WZM_SCREEN_WIDTH-20.0, 80.0)];
    self.toolView.wzm_cornerRadius = 5.0;
    self.toolView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [self.contentView addSubview:self.toolView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(contentTapClick)];
    [self.contentView addGestureRecognizer:tap];
    
    UIPanGestureRecognizer *pan2 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(contentPanClick:)];
    [self.contentView addGestureRecognizer:pan2];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(toolPanClick:)];
    [self.toolView addGestureRecognizer:pan];
    
    NSArray *btnTitles = @[@"换位",@"改图",@"复位",@"隐藏",@"锁定",@"横线",@"竖线"];
    CGFloat btnW = (self.toolView.wzm_width/btnTitles.count);
    for (NSInteger i = 0; i < btnTitles.count; i ++) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(i*btnW, 0.0, btnW, 40.0)];
        btn.tag = i;
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        [btn setTitle:btnTitles[i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(itemBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.toolView addSubview:btn];
    }
    
    UISlider *slider1 = [[UISlider alloc] initWithFrame:CGRectMake(5.0, 40.0, self.toolView.wzm_width-10.0, 30.0)];
    slider1.tag = 0;
    slider1.minimumValue = 0.0;
    slider1.maximumValue = 1.0;
    slider1.value = self.imageView2.alpha;
    slider1.maximumTrackTintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    [slider1 addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
    [slider1 addTarget:self action:@selector(touchChange:) forControlEvents:UIControlEventValueChanged];
    [slider1 addTarget:self action:@selector(touchUp:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside|UIControlEventTouchCancel];
    [slider1 setThumbImage:[UIImage wzm_getRoundImageByColor:[UIColor whiteColor] size:CGSizeMake(10.0, 10.0)] forState:UIControlStateNormal];
    [self.toolView addSubview:slider1];
}

//辅助线
- (void)addDotView:(BOOL)h {
    if (h) {
        UIView *hDotView = [[UIView alloc] initWithFrame:CGRectMake(0.0, (WZM_SCREEN_HEIGHT-50.0)/2.0+50.0, WZM_SCREEN_WIDTH, 50.0)];
        hDotView.wzm_tag = 0;
        [self.contentView addSubview:hDotView];
        
        UIView *hdot = [[UIView alloc] initWithFrame:CGRectMake(0.0, 24.5, WZM_SCREEN_WIDTH, 1.0)];
        hdot.tag = 1;
        hdot.backgroundColor = LINE_COLOR;
        [hDotView addSubview:hdot];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dotPanClick:)];
        [hDotView addGestureRecognizer:pan];
        
        UILongPressGestureRecognizer *longG = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longClick:)];
        [hDotView addGestureRecognizer:longG];
        
        [self animationWithView:hdot duration:0.5];
    }
    else {
        UIView *hDotView = [[UIView alloc] initWithFrame:CGRectMake((WZM_SCREEN_WIDTH-50.0)/2.0+50.0, 0.0, 50.0, WZM_SCREEN_HEIGHT)];
        hDotView.wzm_tag = 1;
        [self.contentView addSubview:hDotView];
        
        UIView *hdot = [[UIView alloc] initWithFrame:CGRectMake(24.5, 0.0, 1.0, WZM_SCREEN_HEIGHT)];
        hdot.tag = 1;
        hdot.backgroundColor = LINE_COLOR;
        [hDotView addSubview:hdot];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dotPanClick:)];
        [hDotView addGestureRecognizer:pan];
        
        UILongPressGestureRecognizer *longG = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longClick:)];
        [hDotView addGestureRecognizer:longG];
        
        [self animationWithView:hdot duration:0.5];
    }
    [self.toolView.superview bringSubviewToFront:self.toolView];
}

- (void)contentTapClick {
    [UIView animateWithDuration:0.35 animations:^{
        self.toolView.alpha = (1.0-self.toolView.alpha);
    } completion:^(BOOL finished) {
//        if (@available(iOS 11.0, *)) {
//            [self setNeedsUpdateOfScreenEdgesDeferringSystemGestures];
//        } else {
//            // Fallback on earlier versions
//        }
    }];
}

- (void)contentPanClick:(UIPanGestureRecognizer *)recognizer {
    if (self.isLocked) return;
    if (self.imageView2.isHidden) return;
    if (self.imageView2.image == nil) return;
    UIView *tapView = self.imageContentView2;
    CGPoint point_0 = [recognizer translationInView:recognizer.view];
    static CGRect rect;
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        rect = tapView.frame;
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat x = rect.origin.x+point_0.x;
        CGFloat y = rect.origin.y+point_0.y;
        tapView.frame = CGRectMake(x, y, tapView.frame.size.width, tapView.frame.size.height);
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded ||
             recognizer.state == UIGestureRecognizerStateCancelled) {
        
    }
}

- (void)toolPanClick:(UIPanGestureRecognizer *)recognizer {
    UIView *tapView = recognizer.view;
    CGPoint point_0 = [recognizer translationInView:tapView];
    static CGRect rect;
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        rect = tapView.frame;
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat y = rect.origin.y+point_0.y;
        if (y < WZM_STATUS_HEIGHT || y > WZM_SCREEN_HEIGHT-WZM_BOTTOM_HEIGHT-tapView.frame.size.height) {
            y = tapView.frame.origin.y;
        }
        tapView.frame = CGRectMake(10.0, y, tapView.frame.size.width, tapView.frame.size.height);
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded ||
             recognizer.state == UIGestureRecognizerStateCancelled) {
        
    }
}

- (void)dotPanClick:(UIPanGestureRecognizer *)recognizer {
    UIView *tapView = recognizer.view;
    CGPoint point_0 = [recognizer translationInView:tapView];
    static CGRect rect;
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        rect = tapView.frame;
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
        if (tapView.wzm_tag == 0) {
            CGFloat y = rect.origin.y+point_0.y;
            if (y < WZM_STATUS_HEIGHT-24.5) {
                y = WZM_STATUS_HEIGHT-24.5;
            }
            else if (y > WZM_SCREEN_HEIGHT-WZM_BOTTOM_HEIGHT-25.5) {
                y = WZM_SCREEN_HEIGHT-WZM_BOTTOM_HEIGHT-25.5;
            }
            tapView.frame = CGRectMake(0.0, y, tapView.frame.size.width, tapView.frame.size.height);
        }
        else {
            CGFloat x = rect.origin.x+point_0.x;
            if (x < -24.5) {
                x = -24.5;
            }
            else if (x > WZM_SCREEN_WIDTH-25.0) {
                x = WZM_SCREEN_WIDTH-25.0;
            }
            tapView.frame = CGRectMake(x, 0, tapView.frame.size.width, tapView.frame.size.height);
        }
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded ||
             recognizer.state == UIGestureRecognizerStateCancelled) {
        
    }
}

- (void)longClick:(UILongPressGestureRecognizer *)recognizer {
    static BOOL inside = NO;
    UIView *tapView = recognizer.view;
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        inside = NO;
        self.trashView.hidden = NO;
        AudioServicesPlaySystemSound(1520);
        UIView *dotView = [tapView viewWithTag:1];
        dotView.backgroundColor = [UIColor redColor];
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint point = [recognizer locationInView:tapView.superview];
        if (CGRectContainsPoint(self.trashView.frame, point)) {
            if (inside == NO) {
                inside = YES;
                AudioServicesPlaySystemSound(1520);
            }
            self.trashLabel.text = @"松开删除辅助线";
            self.trashLabel.textColor = [UIColor greenColor];
        }
        else {
            inside = NO;
            self.trashLabel.text = @"拖拽删除辅助线";
            self.trashLabel.textColor = [UIColor whiteColor];
        }
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded ||
             recognizer.state == UIGestureRecognizerStateCancelled) {
        CGPoint point = [recognizer locationInView:tapView.superview];
        if (CGRectContainsPoint(self.trashView.frame, point)) {
            [tapView removeFromSuperview];
        }
        else {
            UIView *dotView = [tapView viewWithTag:1];
            dotView.backgroundColor = LINE_COLOR;
        }
        self.trashView.hidden = YES;
        self.trashLabel.text = @"拖拽删除辅助线";
        self.trashLabel.textColor = [UIColor whiteColor];
    }
}

- (void)itemBtnClick:(UIButton *)btn {
    if (btn.tag == 0) {
        //交换位置
        UIImage *image = self.imageView1.image;
        self.imageView1.image = self.imageView2.image;
        self.imageView2.image = image;
    }
    else if (btn.tag == 1) {
        //修改图片
        [self addBtnClick:nil];
    }
    else if (btn.tag == 2) {
        //交换
        self.imageContentView1.frame = self.contentView.bounds;
        self.imageContentView2.frame = self.contentView.bounds;
    }
    else if (btn.tag == 3) {
        //隐藏
        self.imageView2.hidden = !self.imageView2.isHidden;
        [btn setTitle:(self.imageView2.isHidden ? @"显示" : @"隐藏") forState:UIControlStateNormal];
    }
    else if (btn.tag == 4) {
        //锁定
        self.locked = !self.isLocked;
        [btn setTitle:(self.isLocked ? @"解锁" : @"锁定") forState:UIControlStateNormal];
    }
    else if (btn.tag == 5) {
        //横线
        [self addDotView:YES];
    }
    else if (btn.tag == 6) {
        //竖线
        [self addDotView:NO];
    }
}

//进度条滑动开始
-(void)touchDown:(UISlider *)sl {
    
}

//进度条滑动
-(void)touchChange:(UISlider *)sl {
    self.imageView2.alpha = sl.value;
}

//进度条滑动结束
-(void)touchUp:(UISlider *)sl {
    
}

- (void)addBtnClick:(UIButton *)btn {
    WZMAlbumConfig *config = [[WZMAlbumConfig alloc] init];
    config.minCount = 1;
    config.maxCount = 2;
    config.allowPreview = NO;
    config.allowShowGIF = NO;
    config.allowShowVideo = NO;
    WZMAlbumNavigationController *nav = [[WZMAlbumNavigationController alloc] initWithConfig:config];
    nav.pickerDelegate = self;
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)albumNavigationController:(WZMAlbumNavigationController *)albumNavigationController didSelectedOriginals:(NSArray *)originals thumbnails:(NSArray *)thumbnails assets:(NSArray *)assets {
    if (originals.count == 1) {
        self.addBtn.hidden = YES;
        if (self.imageView1.image == nil) {
            self.imageView1.image = originals.firstObject;
        }
        else {
            self.imageView2.image = originals.firstObject;
        }
    }
    else if (originals.count == 2) {
        self.addBtn.hidden = YES;
        self.imageView1.image = originals.firstObject;
        self.imageView2.image = originals.lastObject;
    }
    else {
        [WZMViewHandle wzm_showAlertMessage:@"图片资源出错"];
    }
}

- (void)animationWithView:(UIView *)view duration:(NSTimeInterval)duration {
    CGFloat d = duration/5.0;
    [UIView animateWithDuration:d animations:^{
        view.backgroundColor = SHAN_CLOOR;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:d animations:^{
            view.backgroundColor = LINE_COLOR;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:d animations:^{
                view.backgroundColor = SHAN_CLOOR;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:d animations:^{
                    view.backgroundColor = LINE_COLOR;
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:d animations:^{
                        view.backgroundColor = SHAN_CLOOR;
                    } completion:^(BOOL finished) {
                        view.backgroundColor = LINE_COLOR;
                    }];
                }];
            }];
        }];
    }];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

//屏蔽屏幕底部的系统手势
//- (UIRectEdge)preferredScreenEdgesDeferringSystemGestures {
//    if (self.toolView.alpha == 0.0) {
//        return  UIRectEdgeAll;
//    }
//    return  UIRectEdgeNone;
//}

@end
