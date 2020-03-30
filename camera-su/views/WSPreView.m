//
//  WSPreView.m
//  camera-su
//
//  Created by 苏文潇 on 2020/3/29.
//  Copyright © 2020 we_shell. All rights reserved.
//

#import "WSPreView.h"

@interface WSPreView()

@property (strong, nonatomic) UIView *focusBox; // 聚焦
@property (strong, nonatomic) UITapGestureRecognizer *singleTapRecognizer;
//@property (strong, nonatomic) UIView *exposureBox; // 曝光
//@property (strong, nonatomic) UITapGestureRecognizer *doubleTapRecognizer;
//@property (strong, nonatomic) UITapGestureRecognizer *doubleDoubleTapRecognizer;

@end

@implementation WSPreView

+ (Class)layerClass {
    return [AVCaptureVideoPreviewLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor yellowColor];
        [self setUI];
    }
    return self;
}

- (AVCaptureVideoPreviewLayer *)videoPreviewLayer {
    return (AVCaptureVideoPreviewLayer *)self.layer;
}

- (AVCaptureSession *)session {
    return [(AVCaptureVideoPreviewLayer *)self.layer session];
}

- (void)setSession:(AVCaptureSession *)session {
    [(AVCaptureVideoPreviewLayer *)self.layer setSession:session];
    [self setOrientation];
}

- (void)setUI {
    [(AVCaptureVideoPreviewLayer *)self.layer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    self.singleTapRecognizer = singleTap;
    [self addGestureRecognizer:singleTap];
    [self addSubview:self.focusBox];
}

//-(void)layoutSubviews {
//    [super layoutSubviews];
//    
////    self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
//    NSLog(@"haha");
//}

///  设置方向(一定要设置)
- (void)setOrientation {
    UIInterfaceOrientation statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
    AVCaptureVideoOrientation initialVideoOrientation = AVCaptureVideoOrientationPortrait;
    if (statusBarOrientation != UIInterfaceOrientationUnknown) {
        initialVideoOrientation = (AVCaptureVideoOrientation)statusBarOrientation;
    }
    self.videoPreviewLayer.connection.videoOrientation = initialVideoOrientation;
}

// MARK: - touch event 
- (void)handleSingleTap:(UIGestureRecognizer *)tap {
    CGPoint point = [tap locationInView:tap.view];
    [self displayFoucsBoxView:self.focusBox point:point];
    if (self.delegate && [self.delegate respondsToSelector:@selector(tappedToFocusAtPoint:)]) {
        [self.delegate tappedToFocusAtPoint:[self captureDevicePointForPoint:point]];
    }
}

/// 展示聚焦 视图
- (void)displayFoucsBoxView:(UIView *)focusBoxView point:(CGPoint)point {
    focusBoxView.center = point;
    focusBoxView.hidden = NO;
    [UIView animateWithDuration:0.15f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        focusBoxView.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1.0);
    } completion:^(BOOL complete) {
        double delayInSeconds = 0.5f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            focusBoxView.hidden = YES;
            focusBoxView.transform = CGAffineTransformIdentity;
        });
    }];
}

// 屏幕坐标点 --> 摄像头坐标点
- (CGPoint)captureDevicePointForPoint:(CGPoint)point {
    AVCaptureVideoPreviewLayer *layer =
        (AVCaptureVideoPreviewLayer *)self.layer;
    return [layer captureDevicePointOfInterestForPoint:point];
}

- (void)setFocusEnabled:(BOOL)focusEnabled {
    _focusEnabled = focusEnabled;
    self.singleTapRecognizer.enabled = focusEnabled;
}

// MARK: - 控件
-(UIView *)focusBox {
    if (!_focusBox) {
        _focusBox = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150.0f, 150.0f)];
        _focusBox.backgroundColor = [UIColor clearColor];
        _focusBox.layer.borderColor = [UIColor orangeColor].CGColor;
        _focusBox.layer.borderWidth = 2;
        _focusBox.hidden = YES;
    }
    
    return _focusBox;
}

@end
