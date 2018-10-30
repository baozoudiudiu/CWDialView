//
//  ViewController.m
//  DialDemo
//
//  Created by 罗泰 on 2018/10/25.
//  Copyright © 2018 chenwang. All rights reserved.
//

#import "ViewController.h"
#import "CWDialView.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width

@interface ViewController ()
@property (nonatomic, strong) CWDialView                    *testView;

@property (nonatomic, weak) IBOutlet UISlider               *slider;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.slider.userInteractionEnabled = false;
    CWDialView *testView = [[CWDialView alloc] initWithFrame:CGRectMake(0, 100, kScreenWidth, 300)];
    testView.backgroundColor = UIColor.groupTableViewBackgroundColor;
    testView.lineNormalLength = 16.0f;
    testView.lineCurrentLength = 20.f;
    testView.lineNormalWidth = 2.5f;
    testView.lineCurrentWidth = 3.0f;
    testView.maxValue = 100;
    testView.numOfLine = 100 / 2;
    testView.colors = @[@[(id)UIColor.cyanColor.CGColor, (id)UIColor.greenColor.CGColor],
                    @[(id)UIColor.blueColor.CGColor, (id)UIColor.cyanColor.CGColor],
                    @[(id)UIColor.orangeColor.CGColor, (id)UIColor.cyanColor.CGColor],
                    @[(id)UIColor.orangeColor.CGColor, (id)UIColor.yellowColor.CGColor],
                    @[(id)UIColor.redColor.CGColor, (id)UIColor.orangeColor.CGColor]];
    
    [self.view addSubview:testView];
    self.testView = testView;
    [self.slider addTarget:self action:@selector(sliderHandle:) forControlEvents:UIControlEventValueChanged];
    
    [self gradientTest];
}


- (void)gradientTest {
    // 1.
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    // 2.
    UIBezierPath *bPath = [UIBezierPath bezierPath];
    [bPath moveToPoint:CGPointMake(15, 30)];
    [bPath addLineToPoint:CGPointMake(kScreenWidth - 120 - 15, 30)];
    shapeLayer.path = bPath.CGPath;
    shapeLayer.strokeColor = UIColor.redColor.CGColor;
    shapeLayer.lineWidth = 30;
    shapeLayer.lineCap = kCALineCapRound;
    // 3.
    gradientLayer.colors = @[(id)UIColor.cyanColor.CGColor, (id)UIColor.blueColor.CGColor];
    gradientLayer.frame = CGRectMake(60, 20, kScreenWidth - 120, 60);
    gradientLayer.startPoint = CGPointMake(0, 0.5);
    gradientLayer.endPoint = CGPointMake(1, 0.5);
    [self.view.layer addSublayer:gradientLayer];
    [gradientLayer setMask:shapeLayer];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.slider setValue:51 animated:YES];
    [self.testView showDialValue:51];
    [self performSelector:@selector(valueChanged) withObject:nil afterDelay:1.0];
}


- (void)valueChanged {
    NSInteger value = arc4random()%100 + 1;
    [self.slider setValue:value animated:YES];
    [self.testView showDialValue:value];
    [self performSelector:@selector(valueChanged) withObject:nil afterDelay:1.0];
}

- (void)sliderHandle:(UISlider *)sender {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(valueChanged) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self.testView showDialValue:sender.value];
    [self performSelector:@selector(valueChanged) withObject:nil afterDelay:1.0];
}
@end
