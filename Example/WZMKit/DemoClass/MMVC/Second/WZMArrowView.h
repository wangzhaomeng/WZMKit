//
//  WZMArrowView.h
//  WZMKit_Example
//
//  Created by Zhaomeng Wang on 2021/3/8.
//  Copyright © 2021 wangzhaomeng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, WZMArrowViewType) {
    WZMArrowViewTypeArrow = 0,   //单箭头
    WZMArrowViewTypeLine,        //直线
    WZMArrowViewTypeRulerArrow,  //双箭头尺
    WZMArrowViewTypeRulerLine    //双直线尺
};

typedef NS_ENUM(NSUInteger, WZMArrowViewTouchType) {
    WZMArrowViewTouchTypeNone = 0,
    WZMArrowViewTouchTypeStart,
    WZMArrowViewTouchTypeMid,
    WZMArrowViewTouchTypeEnd,
};

@interface WZMArrowView : UIView

@property (nonatomic, assign) WZMArrowViewType type;
@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, assign) CGPoint endPoint;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, strong) UIColor *normalColor;
@property (nonatomic, strong) UIColor *selectedColor;

@end

NS_ASSUME_NONNULL_END
