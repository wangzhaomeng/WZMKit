//
//  WZMBaseViewController.m
//  LLFeature
//
//  Created by WangZhaomeng on 2017/10/11.
//  Copyright © 2017年 WangZhaomeng. All rights reserved.
//

#import "WZMBaseViewController.h"
#import "UIImage+wzmcate.h"
#import "UIColor+wzmcate.h"
#import "UIViewController+wzmcate.h"
#import "UINavigationController+wzmnav.h"

@interface WZMBaseViewController ()

@property (nonatomic, strong) UIView *contentView;

@end

@implementation WZMBaseViewController

- (void)loadView {
    [super loadView];
    [self.view addSubview:self.contentView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.userInterfaceStyle = WZMUserInterfaceStyleLight;
    if (@available(iOS 12.0, *)) {
        if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
            self.userInterfaceStyle = WZMUserInterfaceStyleDark;
        }
    }
    self.view.backgroundColor = [UIColor wzm_getDynamicColorByLightColor:[UIColor whiteColor] darkColor:WZM_DARK_COLOR];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.navigationController != nil && [self capturesNavigatonBar]) {
        UIColor *navBGColor = [self navigatonBarBackgroundColor];
        self.navigationController.navigationBar.translucent = YES;
        [self.navigationController.navigationBar setBackgroundImage:[UIImage wzm_getImageByColor:navBGColor] forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[self navigatonBarTitleColor]}];
        self.navigationController.navLineHidden = [self navigatonBarIsHiddenLine];
        self.navigationController.navigationBar.hidden = [self navigatonBarIsHidden];
        [self setNavigatonLeftItemImage:[self navigatonLeftItemImage]];
        [self setNavigatonRightItemImage:[self navigatonRightItemImage]];
    }
}

#pragma mark - private method
//设置导航栏左侧item
- (void)setNavigatonLeftItemImage:(UIImage *)image {
    if (image == nil) return;
    UIView *leftView = [self navigatonLeftItemView];
    if (leftView == nil) {
        leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navigatonLeftButtonClick)];
        [leftView addGestureRecognizer:tap];
    }
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 7, 30, 30)];
    imageView.image = image;
    [leftView addSubview:imageView];
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftView];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
}

//设置导航栏右侧item
- (void)setNavigatonRightItemImage:(UIImage *)image {
    if (image == nil) return;
    UIView *rightView = [self navigatonRightItemView];
    if (rightView == nil) {
        rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navigatonRightButtonClick)];
        [rightView addGestureRecognizer:tap];
    }
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(14, 7, 30, 30)];
    imageView.image = image;
    [rightView addSubview:imageView];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightView];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
}

#pragma mark - 子类重载
- (UIView *)navigatonLeftItemView {
    return nil;
}

- (UIView *)navigatonRightItemView {
    return nil;
}

- (UIImage *)navigatonLeftItemImage {
    if (self.navigationController.childViewControllers.count > 1) {
        if (self.userInterfaceStyle == WZMUserInterfaceStyleLight) {
            return [UIImage imageNamed:@"wzm_back_black"];
        }
        else {
            return [UIImage imageNamed:@"wzm_back_white"];
        }
    }
    return nil;
}

- (UIImage *)navigatonRightItemImage {
    return nil;
}

- (void)navigatonLeftButtonClick {
    [self wzm_goBack];
}

- (void)navigatonRightButtonClick {
    
}

#pragma mark - setter / getter
- (UIView *)contentView {
    if (_contentView == nil) {
        CGRect rect = self.view.bounds;
        WZMContentType type = [self contentType];
        if (type != WZMContentTypeNone) {
            if (type & WZMContentTypeTopBar) {
                rect.origin.y = WZM_NAVBAR_HEIGHT;
                rect.size.height -= WZM_NAVBAR_HEIGHT;
            }
            if (type & WZMContentTypeBottomBar) {
                rect.size.height -= WZM_TABBAR_HEIGHT;
            }
        }
        _contentView = [[UIView alloc] initWithFrame:rect];
    }
    return _contentView;
}

#pragma mark - 导航栏
//视图类型
- (WZMContentType)contentType {
    return WZMContentTypeNone;
}

//是否接管导航栏
- (BOOL)capturesNavigatonBar {
    return YES;
}

//导航栏是否隐藏
- (BOOL)navigatonBarIsHidden {
    return NO;
}

//导航栏是否隐藏线条
- (BOOL)navigatonBarIsHiddenLine {
    return NO;
}

//导航栏背景色
- (UIColor *)navigatonBarBackgroundColor {
    return [UIColor wzm_getDynamicColorByLightColor:[UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0] darkColor:WZM_DARK_COLOR];
}

//导航栏title颜色
- (UIColor *)navigatonBarTitleColor {
    return [UIColor wzm_getDynamicColorByLightColor:[UIColor blackColor] darkColor:[UIColor whiteColor]];
}

#pragma mark - super method
//屏幕方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    BOOL isLight = YES;
    if (@available(iOS 12.0, *)) {
        if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
            isLight = NO;
            self.userInterfaceStyle = WZMUserInterfaceStyleDark;
            [self userInterfaceStyleDidChange:WZMUserInterfaceStyleDark];
        }
    }
    if (isLight) {
        self.userInterfaceStyle = WZMUserInterfaceStyleLight;
        [self userInterfaceStyleDidChange:WZMUserInterfaceStyleLight];
    }
    if (self.navigationController) {
        [self setNavigatonLeftItemImage:[self navigatonLeftItemImage]];
        [self setNavigatonRightItemImage:[self navigatonRightItemImage]];
        UIColor *navBGColor = [self navigatonBarBackgroundColor];
        [self.navigationController.navigationBar setBackgroundImage:[UIImage wzm_getImageByColor:navBGColor] forBarMetrics:UIBarMetricsDefault];
    }
}
- (void)userInterfaceStyleDidChange:(WZMUserInterfaceStyle)style {}

//屏蔽屏幕底部的系统手势
- (UIRectEdge)preferredScreenEdgesDeferringSystemGestures {
    return  UIRectEdgeNone;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
