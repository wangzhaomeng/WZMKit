//
//  WZMAlbumLocalView.h
//  git_XNLocation
//
//  Created by Zhaomeng Wang on 2020/5/25.
//  Copyright © 2020 Zhaomeng Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WZMAlbumPhotoModel.h"

@interface WZMAlbumLocalView : UIView

- (instancetype)initWithModel:(WZMAlbumPhotoModel *)model;
- (void)show;

@end
