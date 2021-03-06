
#import "WZMMosaicView.h"
#import "WZMLogPrinter.h"
#import "UIImage+wzmcate.h"

@interface WZMMosaicView ()

@property (nonatomic, strong) NSMutableArray *lines;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) NSMutableDictionary *pathDic;
@property (nonatomic, strong) NSMutableDictionary *shapeLayerDic;
@property (nonatomic, strong) NSMutableDictionary *mosaicImageLayerDic;

@end

@implementation WZMMosaicView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.lineWidth = 16.0;
        self.type = WZMMosaicViewTypeFilterMosaic;
        self.lines = [[NSMutableArray alloc] initWithCapacity:0];
        
        self.imageView = [[UIImageView alloc]initWithFrame:self.bounds];
        [self addSubview:self.imageView];
        
        self.pathDic = [[NSMutableDictionary alloc] init];
        self.shapeLayerDic = [[NSMutableDictionary alloc] init];
        self.mosaicImageLayerDic = [[NSMutableDictionary alloc] init];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
        [self addGestureRecognizer:pan];
    }
    return self;
}

#pragma mark - public method
//清空
- (void)recover {
    if (self.lines.count) {
        [self recoverLayer];
        [self.lines removeAllObjects];
        [self drawLines];
    }
}

//撤销
- (void)backforward {
    if (self.lines.count) {
        [self recoverLayer];
        [self.lines removeLastObject];
        [self drawLines];
    }
}

#pragma mark - private method
- (void)recoverLayer {
    NSArray *keys = [self releaseShapePath];
    for (NSString *key in keys) {
        CGMutablePathRef pathRef = CGPathCreateMutable();
        [self.pathDic setValue:(__bridge id)(pathRef) forKey:key];
    }
}

- (void)createMosaicLayersIfNeed {
    NSString *key = [self getKey:self.type];
    CALayer *mosaicImageLayer = [self.mosaicImageLayerDic valueForKey:key];
    if (mosaicImageLayer == nil) {
        mosaicImageLayer = [CALayer layer];
        mosaicImageLayer.frame = self.bounds;
        //mosaicImageLayer.wzm_contentMode = UIViewContentModeScaleAspectFill;
        [self.layer addSublayer:mosaicImageLayer];
        [self.mosaicImageLayerDic setValue:mosaicImageLayer forKey:key];
    }
    CAShapeLayer *shapeLayer = [self.shapeLayerDic valueForKey:key];
    if (shapeLayer == nil) {
        shapeLayer = [CAShapeLayer layer];
        shapeLayer.frame = self.bounds;
        shapeLayer.lineCap = kCALineCapRound;
        shapeLayer.lineJoin = kCALineJoinRound;
        shapeLayer.lineWidth = self.lineWidth;
        shapeLayer.fillColor = nil;
        shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
        [self.layer addSublayer:shapeLayer];
        mosaicImageLayer.mask = shapeLayer;
        [self.shapeLayerDic setValue:shapeLayer forKey:key];
    }
    
    CGMutablePathRef path = (__bridge CGMutablePathRef)([self.pathDic valueForKey:key]);
    if (path == nil) {
        path = CGPathCreateMutable();
        [self.pathDic setValue:(__bridge id)(path) forKey:key];
    }
}

- (void)drawLines {
    if (self.image == nil) return;
    [self createMosaicImageIfNeed];
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 0);
    [_lines enumerateObjectsUsingBlock:^(NSMutableDictionary  *_Nonnull dic, NSUInteger idx, BOOL * _Nonnull stop) {
        @autoreleasepool {
            NSMutableArray *pointsArray = [dic objectForKey:@"points"];
            CGFloat lineWidth = [[dic objectForKey:@"width"] floatValue];
            WZMMosaicViewType type = [[dic objectForKey:@"type"] integerValue];
            NSString *key = [self getKey:type];
            CAShapeLayer *shapeLayer = [self.shapeLayerDic valueForKey:key];
            CGMutablePathRef path = (__bridge CGMutablePathRef)([self.pathDic valueForKey:key]);
            if (pointsArray.count > 1) {
                CGPoint startPoint = [pointsArray[0] CGPointValue];
                CGPathMoveToPoint(path, NULL, startPoint.x, startPoint.y);
                shapeLayer.path = path;
                shapeLayer.lineWidth = lineWidth;
                
                NSInteger count = pointsArray.count;
                for (NSInteger i = 1; i < count; i ++) {
                    CGPoint endPoint = [pointsArray[i] CGPointValue];
                    CGPathAddLineToPoint(path, NULL, endPoint.x, endPoint.y);
                    CGContextRef currentContext = UIGraphicsGetCurrentContext();
                    CGContextAddPath(currentContext, path);
                    CGContextDrawPath(currentContext, kCGPathStroke);
                    shapeLayer.path = path;
                }
            }
        }
    }];
    UIGraphicsEndImageContext();
}

- (void)createMosaicImageIfNeed {
    for (NSString *key in self.mosaicImageLayerDic.allKeys) {
        CALayer *mosaicImageLayer = [self.mosaicImageLayerDic valueForKey:key];
        if (mosaicImageLayer.contents == nil) {
            //生成马赛克
            UIImage *image = self.mosaicImage;
            if (image == nil) {
                image = self.image;
            }
            WZMMosaicViewType type = (WZMMosaicViewType)key.integerValue;
            if (type < WZMMosaicViewTypeCodeBlur) {
                //滤镜
                CIImage *ciImage = [[CIImage alloc] initWithImage:image];
                CIFilter *filter;
                
                if (type == WZMMosaicViewTypeFilterMosaic) {
                    //马赛克
                    filter = [CIFilter filterWithName:@"CIPixellate"];
                    [filter setValue:@(30) forKey:kCIInputScaleKey];
                }
                else if (type == WZMMosaicViewTypeFilterSepia) {
                    //色调
                    filter = [CIFilter filterWithName:@"CISepiaTone"];
                    [filter setValue:@(30) forKey:kCIInputIntensityKey];
                }
                else {
                    //模糊
                    filter = [CIFilter filterWithName:@"CIGaussianBlur"];
                    [filter setValue:@(10) forKey:kCIInputRadiusKey];
                }
                [filter setValue:ciImage  forKey:kCIInputImageKey];
                CIImage *outImage = [filter valueForKey:kCIOutputImageKey];
                
                CIContext *context = [CIContext contextWithOptions:nil];
                CGImageRef cgImage = [context createCGImage:outImage fromRect:[outImage extent]];
                mosaicImageLayer.contents = (__bridge id)(cgImage);
                CGImageRelease(cgImage);
            }
            else {
                if (type == WZMMosaicViewTypeCodeMosaic) {
                    //马赛克
                    image = [image wzm_getMosaicImageWithLevel:30];
                    mosaicImageLayer.contents = (__bridge id)(image.CGImage);
                }
                else {
                    //模糊
                    image = [image wzm_getBlurImageWithScale:0.8];
                    mosaicImageLayer.contents = (__bridge id)(image.CGImage);
                }
            }
        }
    }
}

- (NSArray *)releaseShapePath {
    NSArray *keys = [NSArray arrayWithArray:self.pathDic.allKeys];
    for (CAShapeLayer *shapeLayer in self.shapeLayerDic.allValues) {
        shapeLayer.path = nil;
    }
    for (NSString *key in self.pathDic.allKeys) {
        CGMutablePathRef path = (__bridge CGMutablePathRef)([self.pathDic valueForKey:key]);
        [self.pathDic removeObjectForKey:key];
        if (path) {
            CGPathRelease(path);
        }
    }
    return keys;
}

- (NSString *)getKey:(WZMMosaicViewType)i {
    return [NSString stringWithFormat:@"%@",@(i)];
}

#pragma mark - setter
- (void)setImage:(UIImage *)image {
    _image = image;
    self.imageView.image = image;
}

- (void)setType:(WZMMosaicViewType)type {
    if (_type == type) return;
    _type = type;
    if (self.superview) {
        [self createMosaicLayersIfNeed];
        [self createMosaicImageIfNeed];
    }
}

- (void)setLineWidth:(CGFloat)lineWidth {
    if (_lineWidth == lineWidth) return;
    _lineWidth = lineWidth;
}

#pragma mark - super method
- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    if (newSuperview) {
        [self createMosaicLayersIfNeed];
        [self createMosaicImageIfNeed];
    }
}

- (void)panGesture:(UIPanGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [gesture locationInView:gesture.view];
        NSString *key = [self getKey:self.type];
        CAShapeLayer *shapeLayer = [self.shapeLayerDic valueForKey:key];
        
        CGMutablePathRef path = (__bridge CGMutablePathRef)([self.pathDic valueForKey:key]);
        CGPathMoveToPoint(path, NULL, point.x, point.y);
        shapeLayer.path = path;
        shapeLayer.lineWidth = self.lineWidth;
        
        NSMutableArray *pointArray = [[NSMutableArray alloc] initWithCapacity:0];
        [pointArray addObject:[NSValue valueWithCGPoint:point]];
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:0];
        [dic setObject:pointArray forKey:@"points"];
        [dic setObject:@(self.type) forKey:@"type"];
        [dic setObject:@(self.lineWidth) forKey:@"width"];
        [self.lines addObject:dic];
        
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 0);
    }
    else if (gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint point = [gesture locationInView:gesture.view];
        
        NSString *key = [self getKey:self.type];
        CAShapeLayer *shapeLayer = [self.shapeLayerDic valueForKey:key];
        CGMutablePathRef path = (__bridge CGMutablePathRef)([self.pathDic valueForKey:key]);
        CGPathAddLineToPoint(path, NULL, point.x, point.y);
        
        CGContextRef currentContext = UIGraphicsGetCurrentContext();
        CGContextAddPath(currentContext, path);
        CGContextDrawPath(currentContext, kCGPathStroke);
        shapeLayer.path = path;
        shapeLayer.lineWidth = self.lineWidth;
        
        NSDictionary *dic = [self.lines lastObject];
        NSMutableArray *pointArray = [dic objectForKey:@"points"];
        [pointArray addObject:[NSValue valueWithCGPoint:point]];
    }
    else if (gesture.state == UIGestureRecognizerStateEnded ||
             gesture.state == UIGestureRecognizerStateCancelled) {
        UIGraphicsEndImageContext();
    }
}

- (void)dealloc {
    [self releaseShapePath];
    WZMLog(@"马赛克释放了");
}

@end
