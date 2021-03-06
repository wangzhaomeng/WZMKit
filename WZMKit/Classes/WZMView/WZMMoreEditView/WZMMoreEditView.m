//
//  WZMMoreEditView.m
//  WZMKit_Example
//
//  Created by Zhaomeng Wang on 2021/3/1.
//  Copyright © 2021 wangzhaomeng. All rights reserved.
//

#import "WZMMoreEditView.h"
#import "UIView+wzmcate.h"
#import "WZMPublic.h"

@interface WZMMoreEditView ()

@property (nonatomic, assign) BOOL dotted;
@property (nonatomic, assign) BOOL addRote;
@property (nonatomic, assign) BOOL editing;
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, assign) CGFloat maxScale;
@property (nonatomic, assign) CGFloat minScale;
@property (nonatomic, strong) UIView *item0;
@property (nonatomic, strong) UIView *item1;
@property (nonatomic, strong) UIView *item2;
@property (nonatomic, strong) UIView *item3;
@property (nonatomic, assign) CGFloat itemSize;
@property (nonatomic, assign) CGFloat rotation;
@property (nonatomic, assign) CGFloat deltaAngle;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, assign) CGAffineTransform scaleTransform;
@property (nonatomic, assign) CGAffineTransform rotateTransform;
//记录item的初始中心点
@property (nonatomic, assign) CGPoint center0;
@property (nonatomic, assign) CGPoint center1;
@property (nonatomic, assign) CGPoint center2;
@property (nonatomic, assign) CGPoint center3;

@end

@implementation WZMMoreEditView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.dotted = YES;
        self.itemSize = 30.0;
        self.scale = 1.0;
        self.minScale = 0.5;
        self.maxScale = 2.0;
        self.rotation = 0.0;
        self.scaleTransform = CGAffineTransformIdentity;
        self.rotateTransform = CGAffineTransformIdentity;
        self.backgroundColor = [UIColor clearColor];
        
        CGRect contentRect = self.bounds;
        contentRect.origin.x = 1.0;
        contentRect.origin.y = 1.0;
        contentRect.size.width -= 2.0;
        contentRect.size.height -= 2.0;
        self.contentView = [[UIView alloc] initWithFrame:contentRect];
        self.contentView.clipsToBounds = YES;
        [self addSubview:self.contentView];
        
        UIImage *image0 = [self getImage0];
        if (image0) {
            self.item0 = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.itemSize, self.itemSize)];
            self.item0.tag = 0;
            self.item0.wzm_cornerRadius = self.itemSize/2.0;
            [self addSubview:self.item0];
            
            CGRect rect = self.item0.bounds;
            rect.origin = CGPointMake((rect.size.width-20.0)/2.0, (rect.size.height-20.0)/2.0);
            rect.size = CGSizeMake(20.0, 20.0);
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];
            imageView.image = image0;
            [self.item0 addSubview:imageView];
            
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemTapGesture:)];
            [self.item0 addGestureRecognizer:tapGesture];
        }
        
        UIImage *image1 = [self getImage1];
        if (image1) {
            self.item1 = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.itemSize, self.itemSize)];
            self.item1.tag = 1;
            self.item1.wzm_cornerRadius = self.itemSize/2.0;
            [self addSubview:self.item1];
            
            CGRect rect = self.item1.bounds;
            rect.origin = CGPointMake((rect.size.width-20.0)/2.0, (rect.size.height-20.0)/2.0);
            rect.size = CGSizeMake(20.0, 20.0);
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];
            imageView.image = image1;
            [self.item1 addSubview:imageView];
            
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemTapGesture:)];
            [self.item1 addGestureRecognizer:tapGesture];
        }
        
        UIImage *image2 = [self getImage2];
        if (image2) {
            self.item2 = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.itemSize, self.itemSize)];
            self.item2.tag = 2;
            self.item2.wzm_cornerRadius = self.itemSize/2.0;
            [self addSubview:self.item2];
            
            CGRect rect = self.item2.bounds;
            rect.origin = CGPointMake((rect.size.width-20.0)/2.0, (rect.size.height-20.0)/2.0);
            rect.size = CGSizeMake(20.0, 20.0);
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];
            imageView.image = image2;
            [self.item2 addSubview:imageView];
            
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemTapGesture:)];
            [self.item2 addGestureRecognizer:tapGesture];
        }
        
        UIImage *image3 = [self getImage3];
        if (image3) {
            self.item3 = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.itemSize, self.itemSize)];
            self.item3.tag = 3;
            self.item3.wzm_cornerRadius = self.itemSize/2.0;
            [self addSubview:self.item3];
            
            CGRect rect = self.item3.bounds;
            rect.origin = CGPointMake((rect.size.width-20.0)/2.0, (rect.size.height-20.0)/2.0);
            rect.size = CGSizeMake(20.0, 20.0);
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];
            imageView.image = image3;
            [self.item3 addSubview:imageView];
            
            if ([self allowRotate]) {
                UIPanGestureRecognizer *rotateGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(rotateGesture:)];
                [self.item3 addGestureRecognizer:rotateGesture];
                
                self.deltaAngle = atan2(self.frame.origin.y+self.frame.size.height-self.center.y,
                                        self.frame.origin.x+self.frame.size.width-self.center.x);
            }
            else {
                UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemTapGesture:)];
                [self.item3 addGestureRecognizer:tapGesture];
            }
        }
        [self setNeedsToEdit:YES];
        [self layoutSubItemViews];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
        [self addGestureRecognizer:tapGesture];
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
        [self addGestureRecognizer:panGesture];
        
        if ([self allowZoom]) {
            UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGesture:)];
            [self addGestureRecognizer:pinchGesture];
        }
    }
    return self;
}

- (void)itemTapGesture:(UITapGestureRecognizer *)recognizer {
    if ([self.delegate respondsToSelector:@selector(moreEditView:didSelectedIndex:)]) {
        [self.delegate moreEditView:self didSelectedIndex:recognizer.view.tag];
    }
}

//点击
- (void)tapGesture:(UITapGestureRecognizer *)recognizer {
    [self setNeedsToEdit:!self.editing];
}

//移动
- (void)panGesture:(UIPanGestureRecognizer *)recognizer {
    UIView *tapView = recognizer.view;
    CGPoint point_0 = [recognizer translationInView:self.superview];
    static CGPoint center;
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        center = tapView.center;
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat x = center.x+point_0.x;
        CGFloat y = center.y+point_0.y;
        if (x < 0 || x > self.superview.bounds.size.width) {
            return;
        }
        if (y < 0.0 || y > self.superview.bounds.size.height) {
            return;
        }
        tapView.center = CGPointMake(x, y);
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded ||
             recognizer.state == UIGestureRecognizerStateCancelled) {
        
    }
}

//捏合
- (void)pinchGesture:(UIPinchGestureRecognizer *)recognizer {
    static CGAffineTransform transform;
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        transform = self.scaleTransform;
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGAffineTransform transform2 = CGAffineTransformScale(transform, recognizer.scale, recognizer.scale);
        self.scale = sqrt(transform2.a * transform2.a + transform2.c * transform2.c);
        if (self.scale < self.minScale) {
            self.scale = self.minScale;
            transform2 = CGAffineTransformMakeScale(self.minScale, self.minScale);
        }
        else if (self.scale > self.maxScale) {
            self.scale = self.maxScale;
            transform2 = CGAffineTransformMakeScale(self.maxScale, self.maxScale);
        }
        self.scaleTransform = transform2;
        self.transform = CGAffineTransformConcat(self.rotateTransform, self.scaleTransform);
        [self zoomSubItemViews];
    }
}

//旋转
- (void)rotateGesture:(UIPanGestureRecognizer *)recognizer {
    static CGAffineTransform transform;
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        transform = self.rotateTransform;
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat ang = atan2([recognizer locationInView:self.superview].y - self.center.y, [recognizer locationInView:self.superview].x - self.center.x);
        self.rotation = -(self.deltaAngle - ang);
        CGAffineTransform transform2 = CGAffineTransformMakeRotation(self.rotation);
        self.rotateTransform = transform2;
        self.transform = CGAffineTransformConcat(self.rotateTransform, self.scaleTransform);
    }
}

//编辑状态
- (void)setNeedsToEdit:(BOOL)edit {
    self.dotted = edit;
    self.editing = edit;
    self.item0.hidden = !edit;
    self.item1.hidden = !edit;
    self.item2.hidden = !edit;
    self.item3.hidden = !edit;
}

//布局
- (void)layoutSubItemViews {
    if (self.item0) {
        CGPoint center = CGPointMake(0.0, 0.0);
        self.item0.center = center;
        self.center0 = self.item0.center;
    }
    if (self.item1) {
        CGPoint center = CGPointMake(self.bounds.size.width, 0.0);
        self.item1.center = center;
        self.center1 = self.item1.center;
    }
    if (self.item2) {
        CGPoint center = CGPointMake(0.0, self.bounds.size.height);
        self.item2.center = center;
        self.center2 = self.item2.center;
    }
    if (self.item3) {
        CGPoint center = CGPointMake(self.bounds.size.width, self.bounds.size.height);
        self.item3.center = center;
        self.center3 = self.item3.center;
    }
}

//布局
- (void)zoomSubItemViews {
    CGFloat scale = 1/self.scale;
//    CGFloat dl = self.itemSize*(1-scale)/2.0;
    if (self.item0) {
//        CGPoint center = self.center0;
//        center.x -= dl;
//        center.y -= dl;
//        self.item0.center = center;
        self.item0.transform = CGAffineTransformMakeScale(scale, scale);
    }
    if (self.item1) {
//        CGPoint center = self.center1;
//        center.x += dl;
//        center.y -= dl;
//        self.item1.center = center;
        self.item1.transform = CGAffineTransformMakeScale(scale, scale);
    }
    if (self.item2) {
//        CGPoint center = self.center2;
//        center.x -= dl;
//        center.y += dl;
//        self.item2.center = center;
        self.item2.transform = CGAffineTransformMakeScale(scale, scale);
    }
    if (self.item3) {
//        CGPoint center = self.center3;
//        center.x += dl;
//        center.y += dl;
//        self.item3.center = center;
        self.item3.transform = CGAffineTransformMakeScale(scale, scale);
    }
}

- (BOOL)allowZoom {
    return YES;
}

- (BOOL)allowRotate {
    return YES;
}

- (UIImage *)getImage0 {
    return [WZMPublic imageWithFolder:@"edit" imageName:@"edit_delete"];
}

- (UIImage *)getImage1 {
    return [WZMPublic imageWithFolder:@"edit" imageName:@"edit_bianji"];
}

- (UIImage *)getImage2 {
    return [WZMPublic imageWithFolder:@"edit" imageName:@"edit_tianjia"];
}

- (UIImage *)getImage3 {
    return [WZMPublic imageWithFolder:@"edit" imageName:@"edit_zoom"];
}

- (void)setDotted:(BOOL)dotted {
    if (_dotted == dotted) return;
    _dotted = dotted;
    if (self.superview) {
        [self setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    if (self.dotted == NO) return;
    CGFloat lineWidth = 1.0;
    CGFloat lengths[]= {6.0, 4.0};
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextSetLineWidth(context, lineWidth);
    CGContextSetLineDash(context, 0.0, lengths, 2);
    CGRect rect2 = self.bounds;
    rect2.origin.x = lineWidth*0.5;
    rect2.origin.y = lineWidth*0.5;
    rect2.size.width -= lineWidth;
    rect2.size.height -= lineWidth;
    CGContextAddRect(context, rect2);
    CGContextStrokePath(context);
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.item0) {
        if (CGRectContainsPoint(self.item0.frame, point)) {
            return self.item0;
        }
    }
    if (self.item1) {
        if (CGRectContainsPoint(self.item1.frame, point)) {
            return self.item1;
        }
    }
    if (self.item2) {
        if (CGRectContainsPoint(self.item2.frame, point)) {
            return self.item2;
        }
    }
    if (self.item3) {
        if (CGRectContainsPoint(self.item3.frame, point)) {
            return self.item3;
        }
    }
    return [super hitTest:point withEvent:event];
}

@end
