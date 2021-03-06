//
//  NSObject+wzmcate.h
//  test
//
//  Created by wangzhaomeng on 16/8/16.
//  Copyright © 2016年 MaoChao Network Co. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (wzmcate)

#if DEBUG
+ (void)wzm_loadDealloc;
#endif

- (void)setWzm_tag:(NSInteger)wzm_tag;
- (NSInteger)wzm_tag;

- (NSString *)wzm_className;
+ (NSString *)wzm_className;

///方法交换
+ (BOOL)wzm_swizzleSystemSel:(SEL)origSel swizzSel:(SEL)altSel;

@end
