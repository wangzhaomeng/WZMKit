//
//  LLTabBarController.m
//  LLTabBarViewController
//
//  Created by zhaomengWang on 2017/3/31.
//  Copyright © 2017年 MaoChao Network Co. Ltd. All rights reserved.
//

#import "LLTabBarController.h"
#import "LLNavigationController.h"
#import "FirstViewController.h"
#import "SecondViewController.h"
#import "ThirdViewController.h"

@interface LLTabBarController (){
    
}

@end

@implementation LLTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view insertSubview:[self screenShotView] atIndex:0];
}

+ (instancetype)tabBarController {
    static LLTabBarController *tabBarController;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tabBarController = [[LLTabBarController alloc] init];
        tabBarController.tabBar.translucent = NO;
        
        FirstViewController *firstViewController = [[FirstViewController alloc] init];
        LLNavigationController *firstNav = [[LLNavigationController alloc] initWithRootViewController:firstViewController];
        
        SecondViewController *secondViewController = [[SecondViewController alloc] init];
        LLNavigationController *secondNav = [[LLNavigationController alloc] initWithRootViewController:secondViewController];
        
        ThirdViewController *thirdViewController = [[ThirdViewController alloc] init];
        LLNavigationController *thirdNav = [[LLNavigationController alloc] initWithRootViewController:thirdViewController];
        
        [tabBarController setViewControllers:@[firstNav,secondNav,thirdNav]];
        [tabBarController setConfig];
    });
    return tabBarController;
}

- (void)setConfig {
    NSArray *titles = @[@"首页",@"最新成交",@"商品分类",@"我"];
    NSArray *normalImages = @[@"tabbar_home",@"tabbar_auction",@"tabbar_classify",@"tabbar_mine"];
    NSArray *selectImages = @[@"tabbar_home_on",@"tabbar_auction_on",@"tabbar_classify_on",@"tabbar_mine_on"];

    for (NSInteger i = 0; i < self.viewControllers.count; i ++) {
        
        UIViewController *viewController = self.viewControllers[i];
        
        NSDictionary *atts = @{NSForegroundColorAttributeName:[UIColor blackColor],NSFontAttributeName:[UIFont systemFontOfSize:12]};
        NSDictionary *selAtts = @{NSForegroundColorAttributeName:[UIColor redColor],NSFontAttributeName:[UIFont systemFontOfSize:12]};
        
        UIImage *img = [[UIImage imageNamed:normalImages[i]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage *selImg = [[UIImage imageNamed:selectImages[i]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        viewController.tabBarItem.title = titles[i];
        viewController.tabBarItem.image = img;
        viewController.tabBarItem.selectedImage = selImg;
        [viewController.tabBarItem setTitleTextAttributes:atts forState:UIControlStateNormal];
        [viewController.tabBarItem setTitleTextAttributes:selAtts forState:UIControlStateSelected];
    }
}

- (void)setBadgeValue:(NSString *)badgeValue atIndex:(NSInteger)index{
    if (index < self.viewControllers.count) {
        UIViewController *vc = [self.viewControllers objectAtIndex:index];
        vc.tabBarItem.badgeValue = badgeValue;
    }
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.selectedViewController;
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.selectedViewController;
}

- (UIViewController *)childViewControllerForScreenEdgesDeferringSystemGestures {
    return self.selectedViewController;
}

#pragma mark - lazy load
- (LLScreenShotView *)screenShotView {
    if (_screenShotView == nil) {
        _screenShotView = [[LLScreenShotView alloc] init];
        _screenShotView.frame = WZM_SCREEN_BOUNDS;
        _screenShotView.hidden = YES;
    }
    return _screenShotView;
}

@end
