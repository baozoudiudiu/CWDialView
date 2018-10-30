//
//  CWDialView.m
//  DialDemo
//
//  Created by 罗泰 on 2018/10/26.
//  Copyright © 2018 chenwang. All rights reserved.
//

#import "CWDialView.h"
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kHighlightedColors @[(id)UIColor.grayColor.CGColor, (id)UIColor.lightGrayColor.CGColor]


@interface CWDialView()
@property (nonatomic, strong) NSArray<CAShapeLayer *>   *lineArr;
@property (nonatomic, strong) NSMutableArray<CAGradientLayer *> *gradientLayerArr;

@property (nonatomic, assign) NSInteger                 currentLineIndex;

@property (nonatomic, assign) NSInteger                 animationStartIndex;
@property (nonatomic, assign) NSInteger                 animationEndIndex;
@property (nonatomic, assign) NSInteger                 animationCurrentIndex;

@property (nonatomic, assign) BOOL                      isAnimation;

@property (nonatomic, strong) NSMutableArray            *valuesCachesArr;
@property (nonatomic, assign) CGFloat                   tempValue;

@property (nonatomic, strong) CAGradientLayer           *valueColorLayer;
@end


@implementation CWDialView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame])
    {
        [self defaultData];
        [self configureView];
    }
    return self;
}


- (void)defaultData {
    self.lineNormalWidth = 2.0f;
    self.lineCurrentWidth = 1.5f;
    self.lineNormalLength = 12.0f;
    self.lineCurrentLength = 18.0f;
    self.minValue = 0;
    self.maxValue = 100;
    self.numOfLine = 50;
    self.numOfLabel = 6;
    self.radius = self.frame.size.width * 0.5 * 0.6;
    self.labelFont = [UIFont systemFontOfSize:13];
    self.spaceLabelAndLine = 18.f;
    self.currentLineIndex = -1;
    self.valuesCachesArr = [NSMutableArray array];
    self.totalAnimationTime = 1.0f;
    self.labelColor = UIColor.grayColor;
    self.currentValue = 0;
    self.colors = @[@[(id)UIColor.cyanColor.CGColor, (id)UIColor.greenColor.CGColor],
                    @[(id)UIColor.blueColor.CGColor, (id)UIColor.cyanColor.CGColor],
                    @[(id)UIColor.yellowColor.CGColor, (id)UIColor.blueColor.CGColor],
                    @[(id)UIColor.orangeColor.CGColor, (id)UIColor.yellowColor.CGColor],
                    @[(id)UIColor.redColor.CGColor, (id)UIColor.orangeColor.CGColor]];
}

- (void)configureView {
    self.valueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self addSubview:self.valueLabel];
    self.valueLabel.textAlignment = NSTextAlignmentCenter;
    self.valueLabel.font = [UIFont systemFontOfSize:60];
    
    CAGradientLayer *graditentLayer = [CAGradientLayer layer];
    graditentLayer.colors = @[(id)UIColor.yellowColor.CGColor, (id)UIColor.redColor.CGColor];
    graditentLayer.startPoint = CGPointMake(0.5, 0);
    graditentLayer.endPoint = CGPointMake(0.5, 1);
    [graditentLayer setMask:self.valueLabel.layer];
    [self.layer addSublayer:graditentLayer];
    self.valueColorLayer = graditentLayer;
}
#pragma mark - Open Method
/// 显示刻度
- (void)showDialValue:(NSInteger)currentValue {
    if (currentValue < self.minValue) { return; }
    if (currentValue > self.maxValue) { return; }
    self.tempValue = currentValue;
    if (self.isAnimation)
    {
        self.currentLineIndex = self.animationCurrentIndex;
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        self.isAnimation = NO;
    }
    
    NSInteger count = currentValue / self.preValue;
    if (count > self.currentLineIndex)
    {
        NSInteger startIndex = self.currentLineIndex == -1 ? 0 : self.currentLineIndex;
        self.animationStartIndex = startIndex;
        self.animationCurrentIndex = startIndex;
        self.animationEndIndex = count;
        self.isAnimation = YES;
        [self animations:@(YES)];
    }
    else if (count < self.currentLineIndex)
    {
        self.animationStartIndex = self.currentLineIndex;
        self.animationCurrentIndex = self.currentLineIndex;
        self.animationEndIndex = count;
        self.isAnimation = YES;
        [self animations:@(NO)];
    }
}


- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [self.backgroundColor set];
    CGFloat s = M_PI / 180 * 6;
    NSInteger count = self.numOfLine;
    CGFloat perAngle = (M_PI + 2*s) / count;
    CGFloat startAngle = -s;
    CGFloat radius = self.radius;
    CGPoint center = CGPointMake(rect.size.width * 0.5, rect.size.height - 30);
    NSMutableArray *tempArr = [NSMutableArray array];
    self.gradientLayerArr = [NSMutableArray array];
    for (int i = 0; i <= count; i++)
    {
        // 1. 添加刻度
        CAShapeLayer *shapeLayer = [self addLinesCenter:center radius:radius startAngle:startAngle preAngle:perAngle index:i];
        [tempArr addObject:shapeLayer];
        // 2.添加刻度文字
        [self addLabels:i center:center radius:radius startAngle:startAngle perAngle:perAngle];
        // 3. 画点
        [self addPoint:i center:center radius:radius startAngle:startAngle perAngle:perAngle];
    }
    self.lineArr = [[[tempArr reverseObjectEnumerator] allObjects] copy];
    self.gradientLayerArr = [[[self.gradientLayerArr reverseObjectEnumerator] allObjects] mutableCopy];
}


#pragma mark - 业务逻辑处理
/// 刻度改变动画
- (void)animations:(NSNumber *)shun {
    BOOL isShun = shun.boolValue;
    if (isShun && self.animationCurrentIndex > self.animationEndIndex) { return; }
    if (!isShun && self.animationCurrentIndex < self.animationEndIndex) { return; }
    
    NSInteger i = self.animationCurrentIndex;
    CAShapeLayer *layer = self.lineArr[i];
    if (isShun)
    {
        [self preAnimationAscending:i layer:layer];
    }
    else
    {
        [self preAnimationDescending:i layer:layer];
    }
    NSInteger add = isShun ? 1 : -1;
    self.animationCurrentIndex = self.animationCurrentIndex + add;
    NSTimeInterval time = self.totalAnimationTime / labs((self.animationEndIndex - self.animationStartIndex));
    [self performSelector:@selector(animations:) withObject:shun afterDelay:time];
}


/// 刻度由小变大
- (void)preAnimationAscending:(NSInteger)i layer:(CAShapeLayer *)layer {
    layer.strokeColor = UIColor.blueColor.CGColor;
    [self setValueText:i];
    if (i == self.animationEndIndex)
    {
        [self setCurrentLightLayer:layer];
        self.currentLineIndex = self.animationEndIndex;
        [self setAnimationState:NO];
    }
    else
    {
        [self setLightLayer:layer];
    }
}


/// 刻度由大变小
- (void)preAnimationDescending:(NSInteger)i layer:(CAShapeLayer *)layer {
    [self setValueText:i];
    if (i == self.animationEndIndex && i != 0)
    {
        [self setCurrentLightLayer:layer];
        self.currentLineIndex = self.animationEndIndex;
        [self setAnimationState:NO];
    }
    else
    {
        [self setNormalLayer:layer];
        if (i == 0) { self.currentLineIndex = 0;  [self setAnimationState:NO]; }
    }
}


- (void)setNormalLayer:(CAShapeLayer *)layer {
    layer.strokeStart = (self.lineCurrentLength - self.lineNormalLength)* 0.5 / self.lineCurrentLength;
    layer.strokeEnd = 1 - (self.lineCurrentLength - self.lineNormalLength) * 0.5  / self.lineCurrentLength;
    layer.lineWidth = self.lineNormalWidth;
    layer.strokeColor = UIColor.grayColor.CGColor;
    
    NSInteger index = [self.lineArr indexOfObject:layer];
    CAGradientLayer *gLayer = [self.gradientLayerArr objectAtIndex:index];
    gLayer.colors = kHighlightedColors;
}


- (void)setLightLayer:(CAShapeLayer *)layer {
    [self setNormalLayer:layer];
    layer.strokeColor = UIColor.blueColor.CGColor;
    
    NSInteger index = [self.lineArr indexOfObject:layer];
    CAGradientLayer *graLayer = [self.gradientLayerArr objectAtIndex:index];
    
    NSInteger pre = (self.maxValue - self.minValue) / (self.numOfLabel - 1);
    NSInteger value = self.valueLabel.text.integerValue;
    NSInteger count = value / pre;
//    graLayer.colors = @[(id)UIColor.greenColor.CGColor, (id)UIColor.cyanColor.CGColor];
    count = count >= self.colors.count ? self.colors.count - 1 : count;
    graLayer.colors = self.colors[count];
    self.valueColorLayer.colors = [[[self.colors[count] reverseObjectEnumerator] allObjects] copy];
}


- (void)setCurrentLightLayer:(CAShapeLayer *)layer {
    [self setLightLayer:layer];
    layer.strokeStart = 0;
    layer.strokeEnd = 1;
    layer.lineWidth = self.lineCurrentWidth;
}


- (void)addPoint:(NSInteger)index center:(CGPoint)center radius:(CGFloat)radius startAngle:(CGFloat)startAngle perAngle:(CGFloat)perAngle {
    NSInteger count = self.numOfLine / (self.numOfLabel - 1);
    if (index % count != 0
        && (index - 1) % count != 0
        && (index + 1) % count != 0)
    {
        CGFloat angle = startAngle + index * perAngle;
        CGPoint startPoint = CGPointMake(center.x + radius * cos(angle),
                                         center.y + (-sin(angle) * radius));
        CGPoint endPoint = CGPointMake(startPoint.x + self.lineCurrentLength * cos(angle),
                                       startPoint.y + (-sin(angle) * self.lineCurrentLength));
        CGPoint pointOfPoint1 = CGPointMake(endPoint.x + self.spaceLabelAndLine * cos(angle),
                                           endPoint.y + (-sin(angle) * self.spaceLabelAndLine));
        CGPoint pointOfPoint2 = CGPointMake(pointOfPoint1.x + 1 * cos(angle),
                                            pointOfPoint1.y + (-sin(angle) * 1));
        UIBezierPath *bPath = [UIBezierPath bezierPath];
        [bPath moveToPoint:pointOfPoint1];
        [bPath addLineToPoint:pointOfPoint2];
        [bPath stroke];
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = bPath.CGPath;
        shapeLayer.lineCap = kCALineCapRound;
        shapeLayer.lineJoin = kCALineJoinRound;
        shapeLayer.fillColor = self.backgroundColor.CGColor;
        shapeLayer.backgroundColor = self.backgroundColor.CGColor;
        shapeLayer.strokeColor = self.labelColor.CGColor;
        shapeLayer.lineWidth = 3.0f;
        [self.layer addSublayer:shapeLayer];
    }
}


- (void)addLabels:(NSInteger)i center:(CGPoint)center radius:(CGFloat)radius startAngle:(CGFloat)startAngle perAngle:(CGFloat)perAngle {
    NSInteger count = self.numOfLine / (self.numOfLabel - 1);
    if (i % count == 0)
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        [self addSubview:label];
        label.text = [NSString stringWithFormat:@"%02ld", self.maxValue - i * self.preValue];
        label.textColor = self.labelColor;
        label.textAlignment = NSTextAlignmentCenter;
        CGFloat angle = startAngle + i * perAngle;
        CGPoint startPoint = CGPointMake(center.x + radius * cos(angle),
                                         center.y + (-sin(angle) * radius));
        CGPoint endPoint = CGPointMake(startPoint.x + self.lineCurrentLength * cos(angle),
                                       startPoint.y + (-sin(angle) * self.lineCurrentLength));
        label.font = self.labelFont;
        [label sizeToFit];
        label.center = CGPointMake(endPoint.x + self.spaceLabelAndLine * cos(angle),
                                   endPoint.y + (-sin(angle) * self.spaceLabelAndLine));
    }
}


- (CAShapeLayer *)addLinesCenter:(CGPoint)center radius:(CGFloat)radius startAngle:(CGFloat)startAngle preAngle:(CGFloat)perAngle index:(NSInteger)i {
    CGFloat angle = startAngle + i * perAngle;
    CGPoint startPoint = CGPointMake(center.x + radius * cos(angle),
                                     center.y + (-sin(angle) * radius));
//    CGPoint endPoint = CGPointMake(startPoint.x + self.lineCurrentLength * cos(angle),
//                                   startPoint.y + (-sin(angle) * self.lineCurrentLength));
    CGPoint centerPoint = CGPointMake(startPoint.x + self.lineCurrentLength * 0.5 * cos(angle),
                                      startPoint.y + (-sin(angle) * self.lineCurrentLength) * 0.5);
    UIBezierPath *bPath = [UIBezierPath bezierPath];
//    [bPath moveToPoint:startPoint];
//    [bPath addLineToPoint:endPoint];
    [bPath moveToPoint:CGPointMake(self.lineNormalWidth * 0.5, self.lineNormalWidth * 0.5)];
    [bPath addLineToPoint:CGPointMake(self.lineCurrentLength - self.lineNormalWidth * 0.5, self.lineNormalWidth * 0.5)];
    [bPath stroke];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = bPath.CGPath;
    shapeLayer.lineCap = kCALineCapRound;
    shapeLayer.lineJoin = kCALineJoinRound;
//    shapeLayer.fillColor = self.backgroundColor.CGColor;
//    shapeLayer.backgroundColor = self.backgroundColor.CGColor;
//    shapeLayer.strokeColor = UIColor.grayColor.CGColor;
    

    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = CGRectMake(centerPoint.x - self.lineCurrentLength * 0.5, centerPoint.y - self.lineNormalWidth * 0.5, self.lineCurrentLength, self.lineNormalWidth);
    gradientLayer.colors = kHighlightedColors;
    gradientLayer.startPoint = CGPointMake(0, 0.5);
    gradientLayer.endPoint = CGPointMake(1, 0.5);
    gradientLayer.transform = CATransform3DMakeRotation(-angle, 0, 0, 1);
    [gradientLayer setMask:shapeLayer];
    [self.layer addSublayer:gradientLayer];
    [self.gradientLayerArr addObject:gradientLayer];
    [self setNormalLayer:shapeLayer];
    return shapeLayer;
}


#pragma mark - Setter && Getter
- (NSInteger)preValue {
    return (self.maxValue - self.minValue) / self.numOfLine;
}

- (void)setAnimationState:(BOOL)animation {
    self.isAnimation = animation;
    self.currentValue = self.tempValue;
}

- (void)setCurrentValue:(CGFloat)currentValue {
    _currentValue = currentValue;
    self.valueLabel.text = [NSString stringWithFormat:@"%02ld", (NSInteger)_currentValue];
    [self.valueLabel sizeToFit];
    CGSize size = [self.valueLabel sizeThatFits:CGSizeMake(self.radius, 100)];
//    self.valueLabel.center = CGPointMake(self.frame.size.width * 0.5, self.frame.size.height - size.height * 0.5 - 10);
//    self.valueColorLayer.frame = self.valueLabel.frame;
//    self.valueLabel.frame = self.valueColorLayer.bounds;
    self.valueColorLayer.frame = CGRectMake(CGRectGetWidth(self.frame) * 0.5 - self.radius, self.frame.size.height - size.height - 10, CGRectGetWidth(self.frame) - (CGRectGetWidth(self.frame) * 0.5 - self.radius) * 2, size.height);
    self.valueLabel.frame = self.valueColorLayer.bounds;
    
}

- (void)setValueText:(NSInteger)index {
    NSInteger value = index * self.preValue;
    self.valueLabel.text = [NSString stringWithFormat:@"%02ld", (NSInteger)value];
    [self.valueLabel sizeToFit];
    CGSize size = [self.valueLabel sizeThatFits:CGSizeMake(self.radius, 100)];
//    self.valueLabel.center = CGPointMake(self.frame.size.width * 0.5, self.frame.size.height - size.height * 0.5 - 10);
//    self.valueColorLayer.frame = self.valueLabel.frame;
//    self.valueLabel.frame = self.valueColorLayer.bounds;
    self.valueColorLayer.frame = CGRectMake(CGRectGetWidth(self.frame) * 0.5 - self.radius, self.frame.size.height - size.height - 10, CGRectGetWidth(self.frame) - (CGRectGetWidth(self.frame) * 0.5 - self.radius) * 2, size.height);
    self.valueLabel.frame = self.valueColorLayer.bounds;
}
@end
