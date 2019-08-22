//
//  WZMFeature.h
//  WZMKit
//
//  Created by WangZhaomeng on 2019/8/22.
//  Copyright © 2019 wangzhaomeng. All rights reserved.
//

#ifndef WZMFeature_h
#define WZMFeature_h

///基类
#import "LLBaseModel.h"
#import "LLBaseDataProvider.h"
#import "LLPullListViewController.h"

///视图/工具类
#import "LLCrashManager.h"
#import "LLAVLameManager.h"
#import "LLAttributeTextView.h"

///扩展类
#import "UIButton+LLHelper.h"
#import "UIImage+LLCustomImage.h"
#import "UIWindow+LLTransformAnimation.h"
#import "UIViewController+LLModalAnimation.h"
#import "UINavigationController+LLNavAnimation.h"

///全局类
#import "LLWebViewController.h"
#import "LLNavigationController.h"
#import "LLTabBarController.h"

//第三方
#import "Aspects.h"
#import "ASScreenRecorder.h"

//接口相关
#define LL_BASE_URL     @"http://www.vasueyun.cn/apro/"

//其他自定义
#define THEME_COLOR     [UIColor ll_colorWithHex:0xa031ed]

#endif /* WZMFeature_h */
