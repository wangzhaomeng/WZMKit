//
//  WZMScrollImageView.m
//  WZMKit
//
//  Created by WangZhaomeng on 2017/12/12.
//  Copyright © 2017年 WangZhaomeng. All rights reserved.
//

#import "WZMScrollImageView.h"
#import "UIView+wzmcate.h"

@interface WZMScrollImageView ()<UIScrollViewDelegate>

@end

@implementation WZMScrollImageView {
    NSArray       *_showImages;
    UIScrollView  *_scrollView;
    UIPageControl *_pageControl;
    NSArray       *_imageViews;
    NSTimer       *_timer;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        [self addSubview:_scrollView];
        
        CGFloat pageControlH = self.wzm_height/4;
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.wzm_height-pageControlH, self.wzm_width, pageControlH)];
        _pageControl.userInteractionEnabled = NO;
        //[_pageControl addTarget:self action:@selector(pageControlValueChanged:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:_pageControl];
    }
    return self;
}

#pragma mark - 交互事件 && 代理事件
- (void)tapHandle:(UITapGestureRecognizer *)tap {
    if ([self.delegate respondsToSelector:@selector(scrollImageView:didSelectedAtIndex:)]) {
        [self.delegate scrollImageView:self didSelectedAtIndex:(tap.view.tag-(self.isLoop ? 1 : 0))];
    }
}

//- (void)pageControlValueChanged:(UIPageControl *)pageControl {
//    _currentPage = pageControl.currentPage;
//    CGPoint point = CGPointMake((_currentPage+(self.isLoop ? 1 : 0))*_scrollView.wzm_width, 0);
//    [_scrollView setContentOffset:point animated:YES];
//}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_showImages.count <= 0) return;
    CGFloat offsetX = scrollView.contentOffset.x;
    if (self.isLoop && offsetX <= 0) {
        _currentPage = 0;
        scrollView.contentOffset = CGPointMake(scrollView.wzm_width*(_showImages.count-2), 0);
    }
    else if (self.isLoop && offsetX >= scrollView.wzm_width*(_showImages.count-1)) {
        _currentPage = _showImages.count-3;
        scrollView.contentOffset = CGPointMake(scrollView.wzm_width, 0);
    }
    else {
        CGFloat c = scrollView.contentOffset.x/scrollView.wzm_width-(self.isLoop ? 1 : 0);
        _currentPage = (NSInteger)c;
        if (_currentPage != c) return;
    }
    [_pageControl setCurrentPage:_currentPage];
}

#pragma mark - setter && getter
- (void)setImages:(NSArray *)images {
    _images = images;
    if (self.isLoop) {
        NSMutableArray *temp = [NSMutableArray arrayWithCapacity:(images.count+2)];
        [temp addObject:images.lastObject];
        [temp addObjectsFromArray:images];
        [temp addObject:images.firstObject];
        _showImages = [temp copy];
    }
    else {
        _showImages = images;
    }
    
    NSInteger num = _showImages.count;
    _scrollView.contentSize = CGSizeMake(num*self.wzm_width, self.wzm_height);
    _pageControl.numberOfPages = images.count;
    //移除旧视图
    for (UIView *subview in _scrollView.subviews) {
        if ([subview isKindOfClass:[UIImageView class]]) {
            [subview removeFromSuperview];
        }
    }
    //添加新视图
    NSMutableArray *imageViews = [NSMutableArray arrayWithCapacity:num];
    for (NSInteger i = 0; i < num; i ++) {
        
        CGRect rect = _scrollView.bounds;
        rect.origin.x = i%num*_scrollView.wzm_width;
        
        id image = _showImages[i];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];
        imageView.tag = i;
        if ([image isKindOfClass:[UIImage class]]) {
            imageView.image = image;
        }
        else if ([image isKindOfClass:[NSString class]]) {
            UIImage *img = [UIImage imageNamed:image];
            if (img) {
                imageView.image = img;
            }
            else {
                
            }
        }
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.userInteractionEnabled = YES;
        [_scrollView addSubview:imageView];
        
        if (self.isLoop && (i !=0) && (i != num-1)) {
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandle:)];
            [imageView addGestureRecognizer:tap];
        }
        [imageViews addObject:imageView];
    }
    _imageViews = [imageViews copy];
    if (self.currentPage <= 0 || self.currentPage >= images.count) {
        _scrollView.contentOffset = CGPointMake(_scrollView.wzm_width*(self.isLoop ? 1 : 0), 0);
    }
    else {
        CGPoint point = CGPointMake((self.currentPage+(self.isLoop ? 1 : 0))*_scrollView.wzm_width, 0);
        [_scrollView setContentOffset:point animated:YES];
    }
}

- (void)setImageViewInset:(UIEdgeInsets)imageViewInset {
    if (_showImages.count <= 0) return;
    if (UIEdgeInsetsEqualToEdgeInsets(_imageViewInset, imageViewInset)) return;
    CGFloat top    = (imageViewInset.top    > 0 ? imageViewInset.top    : 0);
    CGFloat left   = (imageViewInset.left   > 0 ? imageViewInset.left   : 0);
    CGFloat bottom = (imageViewInset.bottom > 0 ? imageViewInset.bottom : 0);
    CGFloat right  = (imageViewInset.right  > 0 ? imageViewInset.right  : 0);
    for (UIImageView *imageView in _imageViews) {
        CGRect rect = imageView.frame;
        rect.origin.x += left;
        rect.origin.y += top;
        rect.size.width  -= (left+right);
        rect.size.height -= (top+bottom);
        imageView.frame = rect;
    }
    _imageViewInset = imageViewInset;
}

- (void)setShowPageControl:(BOOL)showPageControl {
    if (_showPageControl == showPageControl) return;
    _showPageControl = showPageControl;
    _pageControl.hidden = !showPageControl;
}

- (void)setPageIndicatorTintColor:(UIColor *)pageIndicatorTintColor {
    if (_pageIndicatorTintColor == pageIndicatorTintColor) return;
    _pageIndicatorTintColor = pageIndicatorTintColor;
    _pageControl.pageIndicatorTintColor = pageIndicatorTintColor;
}

- (void)setCurrentPageIndicatorTintColor:(UIColor *)currentPageIndicatorTintColor {
    if (_currentPageIndicatorTintColor == currentPageIndicatorTintColor) return;
    _currentPageIndicatorTintColor = currentPageIndicatorTintColor;
    _pageControl.currentPageIndicatorTintColor = currentPageIndicatorTintColor;
}

- (void)setCurrentPage:(NSInteger)currentPage {
    if (self.images.count) {
        if (currentPage <= 0 || currentPage >= self.images.count) {
            currentPage = 0;
        }
        if (_currentPage == currentPage) return;
        _currentPage = currentPage;
        _pageControl.currentPage = currentPage;
        
        CGPoint point = CGPointMake((currentPage+(self.isLoop ? 1 : 0))*_scrollView.wzm_width, 0);
        [_scrollView setContentOffset:point animated:YES];
    }
    else {
        if (_currentPage == currentPage) return;
        _currentPage = currentPage;
    }
}

- (void)setAutoScroll:(BOOL)autoScroll {
    if (_autoScroll == autoScroll) return;
    autoScroll ? [self timerFire] : [self timerInvalidate];
    _autoScroll = autoScroll;
}

#pragma mark - private method
- (void)timerFire {
    if (_timer == nil) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(timerRun:) userInfo:nil repeats:YES];
    }
}

- (void)timerInvalidate {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)timerRun:(NSTimer *)timer {
    if (_showImages.count <= 0) return;
    NSInteger index = ((_currentPage+(self.isLoop ? 1 : 0))+1)%_showImages.count;
    CGPoint point = CGPointMake(index*_scrollView.wzm_width, 0);
    [_scrollView setContentOffset:point animated:YES];
}

#pragma mark - super method
- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    if (newSuperview) {
        if (self.isAutoScroll) {
            [self timerFire];
        }
    }
}

- (void)removeFromSuperview {
    [self timerInvalidate];
    [super removeFromSuperview];
}

@end
