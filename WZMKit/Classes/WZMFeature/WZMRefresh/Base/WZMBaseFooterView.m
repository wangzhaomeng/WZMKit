//
//  WZMBaseFooterView.m
//  WZMKit
//
//  Created by WangZhaomeng on 2017/11/25.
//  Copyright © 2017年 WangZhaomeng. All rights reserved.
//

#import "WZMBaseFooterView.h"
#import <objc/message.h>

// 运行时objc_msgSend
#define WZMRefreshMsgSend(...)       ((void (*)(void *, SEL, UIView *))objc_msgSend)(__VA_ARGS__)
#define WZMRefreshMsgTarget(target)  (__bridge void *)(target)
@implementation WZMBaseFooterView {
    CGFloat _contentOffsetY;
    CGFloat _lastContentHeight;
}

+ (instancetype)footerWithRefreshingTarget:(id)target refreshingAction:(SEL)action {
    WZMBaseFooterView *refreshFooter = [[self alloc] init];
    refreshFooter.refreshingTarget = target;
    refreshFooter.refreshingAction = action;
    [[NSNotificationCenter defaultCenter] addObserver:refreshFooter selector:@selector(refreshMoreData:) name:WZMRefreshMoreData object:nil];
    return refreshFooter;
}

- (void)refreshMoreData:(NSNotification *)notification {
    
    BOOL moreData = [notification.object boolValue];
    if (moreData) {
        [self WZM_RefreshNormal];
    }
    else {
        [self WZM_NoMoreData];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.scrollView.contentSize.height > self.scrollView.bounds.size.height) {
        _contentOffsetY = self.scrollView.contentSize.height-self.scrollView.bounds.size.height;
    }
    else {
        _contentOffsetY = 0.0;
    }
    CGRect frame = self.frame;
    frame.origin.y = self.scrollView.bounds.size.height+_contentOffsetY;
    self.frame = frame;
}

- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change{
    [super scrollViewContentOffsetDidChange:change];
    if (self.scrollView.contentOffset.y <= 0) return;
    
    if (_refreshState == WZMRefreshStateNoMoreData) {
        //没有更多数据
    }
    else {
        if (self.scrollView.contentOffset.y < WZMRefreshFooterHeight+_contentOffsetY) {
            [self WZM_RefreshNormal];
        }
        else {
            [self WZM_WiWZMRefresh];
        }
    }
}

- (void)scrollViewContentSizeDidChange:(NSDictionary *)change {
    [super scrollViewContentSizeDidChange:change];
    
    if (self.scrollView.contentSize.height > self.scrollView.bounds.size.height) {
        _contentOffsetY = self.scrollView.contentSize.height-self.scrollView.bounds.size.height;
    }
    else {
        _contentOffsetY = 0.0;
    }
    CGRect frame = self.frame;
    frame.origin.y = self.scrollView.bounds.size.height+_contentOffsetY;
    self.frame = frame;
}

- (void)scrollViewPanStateDidChange:(NSDictionary *)change{
    [super scrollViewPanStateDidChange:change];
    if (self.scrollView.panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if (self.scrollView.contentOffset.y >= WZMRefreshFooterHeight+_contentOffsetY) {
            [self WZM_BeginRefresh];
        }
    }
    else if (self.scrollView.panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
    }
}

- (void)WZM_BeginRefresh {
    if (self.isRefreshing == NO) {
        [super WZM_BeginRefresh];
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:.35 animations:^{
                self.scrollView.contentInset = UIEdgeInsetsMake(-WZMRefreshFooterHeight-_contentOffsetY, 0, 0, 0);
                _lastContentHeight = self.scrollView.contentSize.height;
            } completion:^(BOOL finished) {
                if ([self.refreshingTarget respondsToSelector:self.refreshingAction]) {
                    WZMRefreshMsgSend(WZMRefreshMsgTarget(self.refreshingTarget), self.refreshingAction, self);
                }
            }];
        });
    }
}

- (void)WZM_EndRefresh:(BOOL)more {
    if (self.isRefreshing) {
        [super WZM_EndRefresh:more];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (more == NO) {
                [UIView animateWithDuration:.35 animations:^{
                    self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
                }];
            }
            else if (_contentOffsetY == 0) {
                
                if (self.scrollView.contentSize.height >= self.scrollView.bounds.size.height) {
                    self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
                }
                else {
                    [UIView animateWithDuration:.35 animations:^{
                        self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
                    }];
                }
            }
            else {
                //[UIView animateWithDuration:.35 animations:^{
                self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
                self.scrollView.contentOffset = CGPointMake(0, _lastContentHeight-self.scrollView.bounds.size.height+WZMRefreshFooterHeight);
                //}];
            }
        });
    }
}

- (void)WZM_EndRefresh {
    if (self.isRefreshing) {
        BOOL more = !(_lastContentHeight == self.scrollView.contentSize.height);
        [super WZM_EndRefresh:more];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (more == NO) {
                [UIView animateWithDuration:.35 animations:^{
                    self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
                }];
            }
            else if (_contentOffsetY == 0) {
                
                if (self.scrollView.contentSize.height >= self.scrollView.bounds.size.height) {
                    self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
                }
                else {
                    [UIView animateWithDuration:.35 animations:^{
                        self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
                    }];
                }
            }
            else {
                //[UIView animateWithDuration:.35 animations:^{
                self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
                self.scrollView.contentOffset = CGPointMake(0, _lastContentHeight-self.scrollView.bounds.size.height+WZMRefreshFooterHeight);
                //}];
            }
        });
    }
}

@end
