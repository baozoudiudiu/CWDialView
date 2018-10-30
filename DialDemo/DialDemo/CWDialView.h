//
//  CWDialView.h
//  DialDemo
//
//  Created by 罗泰 on 2018/10/26.
//  Copyright © 2018 chenwang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CWDialView : UIView
#pragma mark - 属性 - Property
/**
 表盘最大值
 默认为: 100
 */
@property (nonatomic, assign) NSInteger                 maxValue;

/**
 表盘最小值
 默认为: 0
 */
@property (nonatomic, assign) NSInteger                 minValue;

/**
 当前值
 */
@property (nonatomic, assign, readonly) CGFloat                   currentValue;

/**
 将 minValue 到 maxValue 之间的值分成多少分, 最好是自己算一下 (max - min) / (每格刻度的值)
 默认为: 50
 */
@property (nonatomic, assign) NSInteger                 numOfLine;

/**
 刻度描述label的个数
 默认为: 6
 */
@property (nonatomic, assign) NSInteger                 numOfLabel;

/**
 每个刻度的值 preValue = maxValue / mumOfLine
 */
@property (nonatomic, assign, readonly) NSInteger       preValue;

/**
 表盘半径
 默认: dialView.size.width * 0.5 * 0.6
 */
@property (nonatomic, assign) CGFloat                   radius;

/**
 刻度尺线条宽度
 默认: 2.0f
 */
@property (nonatomic, assign) CGFloat                   lineNormalWidth;

/**
 当前刻度尺,线条宽度
 默认: 1.5f
 */
@property (nonatomic, assign) CGFloat                   lineCurrentWidth;

/**
 刻度尺线条长度
 默认: 12.0f
 */
@property (nonatomic, assign) CGFloat                   lineNormalLength;

/**
 当前刻度尺,线条长度
 默认: 18.0f
 */
@property (nonatomic, assign) CGFloat                   lineCurrentLength;

/**
 刻度文字的字体
 */
@property (nonatomic, strong) UIFont                    *labelFont;

/**
 刻度label和刻度小点的颜色
 */
@property (nonatomic, strong) UIColor                   *labelColor;

/**
 刻度文字中心点离刻度尺的距离
 默认: 20
 */
@property (nonatomic, assign) CGFloat                   spaceLabelAndLine;

/**
 从 minValue 到 maxValue 动画加载的动画时长
 默认: 0.35
 */
@property (nonatomic, assign) NSTimeInterval            totalAnimationTime;

/**
 最中间的label
 */
@property (nonatomic, strong) UILabel                   *valueLabel;

/**
 表盘不同的范围渐变色数组
 数组中的元素为: 单个刻度的渐变色数组
 */
@property (nonatomic, strong) NSArray<NSArray *>        *colors;
#pragma mark - Method
- (void)showDialValue:(NSInteger)currentValue;

@end

NS_ASSUME_NONNULL_END
