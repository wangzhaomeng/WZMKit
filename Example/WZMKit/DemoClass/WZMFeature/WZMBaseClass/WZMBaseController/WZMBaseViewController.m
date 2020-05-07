//
//  WZMBaseViewController.m
//  LLFeature
//
//  Created by WangZhaomeng on 2017/10/11.
//  Copyright © 2017年 WangZhaomeng. All rights reserved.
//

#import "WZMBaseViewController.h"
#import "UIColor+wzmcate.h"
#import "UINavigationController+wzmnav.h"

@implementation UIViewController (WZMBaseViewController)

@end

@interface WZMBaseViewController ()

@end

@implementation WZMBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor wzm_getDynamicColorByLightColor:[UIColor whiteColor] darkColor:[UIColor blackColor]];
    self.automaticallyAdjustsScrollViewInsets = NO;
    if (self.navigationController) {
        //自定义返回按钮
        self.navigationItem.backBarButtonItem = [UIBarButtonItem new];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.navigationController) {
        UIImage *navBGImage = [self navigatonBarBackgroundImage];
        if (navBGImage) {
            self.navigationController.navigationBar.translucent = YES;
            [self.navigationController.navigationBar setBackgroundImage:navBGImage forBarMetrics:UIBarMetricsDefault];
        }
        else {
            [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        }
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[self navigatonBarTitleColor]}];
        self.navigationController.navigationBar.tintColor = [self backItemColor];
        self.navigationItem.backBarButtonItem.title = [self backItemTitle];
        self.navigationController.navLineHidden = [self navigatonIsHiddenLine];
        self.navigationController.navigationBar.hidden = [self navigatonBarIsHidden];
    }
}

#pragma mark - custom method
- (UIInterfaceOrientationMask)wzm_supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

//设置导航栏左侧item
- (void)setLeftItemImage:(UIImage *)image {
    
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(leftButtonClick)];
    [leftView addGestureRecognizer:tap];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 7, 30, 30)];
    imageView.image = image;
    [leftView addSubview:imageView];
    
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftView];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
}

//设置导航栏右侧item
- (void)setRightItemImage:(UIImage *)image {
    
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rightButtonClick)];
    [rightView addGestureRecognizer:tap];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(14, 7, 30, 30)];
    imageView.image = image;
    [rightView addSubview:imageView];
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightView];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
}

- (void)leftButtonClick{}
- (void)rightButtonClick{}

#pragma mark - 导航栏
//导航栏是否隐藏
- (BOOL)navigatonBarIsHidden {
    return NO;
}

//导航栏背景图片
- (UIImage *)navigatonBarBackgroundImage {
    return nil;
}

//导航栏是否隐藏线条
- (BOOL)navigatonIsHiddenLine {
    return NO;
}

//title颜色
- (UIColor *)navigatonBarTitleColor {
    return [UIColor wzm_getDynamicColorByLightColor:[UIColor blackColor] darkColor:[UIColor whiteColor]];
}

//返回按钮颜色
- (UIColor *)backItemColor {
    return [UIColor wzm_getDynamicColorByLightColor:[UIColor blackColor] darkColor:[UIColor whiteColor]];
}

//返回按钮文字
- (NSString *)backItemTitle {
    return @"";
}

#pragma mark - super method
//屏蔽屏幕底部的系统手势
- (UIRectEdge)preferredScreenEdgesDeferringSystemGestures {
    return  UIRectEdgeNone;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    NSLog(@"%@释放了",NSStringFromClass(self.class));
}

@end
