//
//  WZMProgressHUD.h
//  WZMKit
//
//  Created by WangZhaomeng on 2017/10/26.
//  Copyright © 2017年 WangZhaomeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WZMProgressView : UIView

@end

@interface WZMProgressConfig : NSObject

///背景色
@property (nonatomic, strong) UIColor *backgroundColor;
///圆环色
@property (nonatomic, strong) UIColor *progressColor;
///文本色
@property (nonatomic, strong) UIColor *textColor;
///文本字体
@property (nonatomic, strong) UIFont *font;

+ (instancetype)defaultConfig;

@end

@interface WZMProgressHUD : UIView

///是否正在显示
@property (nonatomic, assign, getter=isShow) BOOL show;
///是否允许操作
@property (nonatomic, assign,getter=isUserEnabled) BOOL userEnabled;

+ (instancetype)defaultHUD;
+ (void)setProgressConfig:(WZMProgressConfig *)config;
+ (void)showInfoMessage:(NSString *)message;
+ (void)showProgressMessage:(NSString *)message;
+ (void)dismiss;

@end
