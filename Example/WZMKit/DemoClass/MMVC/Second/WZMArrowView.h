//
//  WZMArrowView.h
//  WZMKit_Example
//
//  Created by Zhaomeng Wang on 2021/3/8.
//  Copyright © 2021 wangzhaomeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WZMArrowLayer.h"

NS_ASSUME_NONNULL_BEGIN

@interface WZMArrowView : UIView

@property (nonatomic, assign) WZMArrowViewType type;
@property (nonatomic, strong) UIColor *normalColor;
@property (nonatomic, strong) UIColor *selectedColor;
@property (nonatomic, assign) CGFloat arrowWidth;
@property (nonatomic, strong, readonly) NSMutableArray *shapeLayers;

- (void)recover;
- (void)backforward;
- (void)clearSelectedLayer;

@end

NS_ASSUME_NONNULL_END
