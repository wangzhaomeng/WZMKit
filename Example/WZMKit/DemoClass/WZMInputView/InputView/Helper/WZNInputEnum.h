//
//  WZNInputEnum.h
//  WZMKit
//
//  Created by WangZhaomeng on 2019/7/23.
//  Copyright © 2019 wangzhaomeng. All rights reserved.
//

#ifndef WZNInputEnum_h
#define WZNInputEnum_h

typedef enum : NSUInteger {
    //键盘状态
    WZMKeyboardTypeIdle = 0, //闲置状态
    WZMKeyboardTypeSystem,   //系统键盘
    WZMKeyboardTypeOther,    //自定义键盘
    //自定义键盘类型
    WZMKeyboardTypeEmoticon, //表情键盘
    WZMKeyboardTypeMore,     //More键盘
} WZMKeyboardType;

typedef enum {
    WZMInputBtnTypeNormal = 0,   //系统默认类型
    WZMInputBtnTypeRetry,        //重发消息按钮
    WZMInputBtnTypeTool,         //键盘工具按钮
    WZMInputBtnTypeMoreKeyboard, //加号键盘按钮
} WZMInputBtnType;

typedef enum : NSInteger {
    WZMRecordTypeBegin = 0, //开始录音
    WZMRecordTypeCancel,    //取消录音
    WZMRecordTypeFinish,    //完成录音
} WZMRecordType;

typedef enum : NSInteger {
    WZInputMoreTypeImage = 0, //图片
    WZInputMoreTypeVideo,     //视频
    WZInputMoreTypeLocation,
    WZInputMoreTypeTransfer,
} WZInputMoreType;

#endif /* WZNInputEnum_h */
