//
//  WSViewController.m
//  camera-su
//
//  Created by 苏文潇 on 2020/3/29.
//  Copyright © 2020 we_shell. All rights reserved.
//

#import "WSViewController.h"
#import "WSPreView.h"
#import "WSOverlayView.h"
#import "WSCameraViewController.h"


@interface WSViewController () <WSOverlayViewDelegate, WSPreViewDelegate>

@property (nonatomic, strong) WSPreView *previewView; // 预览图层
@property (nonatomic, strong) WSOverlayView *overlayView; // 覆盖图层
@property (nonatomic, strong) WSCameraViewController *cameraVc; // 相机

@end

@implementation WSViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self setUI];
    [self setConfig];
}

- (void)setUI {
    [self.view addSubview:self.previewView];
    [self.view addSubview:self.overlayView];
}

- (void)setConfig {
    self.cameraVc = [[WSCameraViewController alloc] init];
    NSError *err;
    if ([self.cameraVc setSession:err]) {
        [self.previewView setSession:self.cameraVc.captureSession];
        [self.cameraVc startSession];
        self.overlayView.flashHidden = !self.cameraVc.cameraFlash; // 设置闪光灯
    }
    self.previewView.focusEnabled = self.cameraVc.cameraSupportFocus;
}

// MARK: - WSOverlayViewDelegate
/// 退出界面
- (void)exit {
    NSLog(@"退出");
    [self.cameraVc stopSession];
//    [self dismissViewControllerAnimated:YES completion:nil];
}
/// 点击拍照
- (void)takePhoto {
    [self.cameraVc takePhoto];
}
/// 闪光灯
- (void)flashOpen:(BOOL)isOpen {
    NSLog(@"闪光灯开启状态: %d", isOpen);
    if (isOpen) {
        self.cameraVc.flashMode = AVCaptureFlashModeOn;
    } else {
        self.cameraVc.flashMode = AVCaptureFlashModeOff;
    }
}
/// 翻转摄像头
- (void)changeCamera {
    NSLog(@"翻转摄像头");
    if ([self.cameraVc switchCameras]) {
        BOOL hidden = NO;
        hidden = !self.cameraVc.cameraFlash;
        self.overlayView.flashHidden = hidden;
        self.previewView.focusEnabled = self.cameraVc.cameraSupportFocus;
        [self.cameraVc resetFocusAndExposureModes];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.previewView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREENH_HEIGHT);
}

// MARK: - WSPreViewDelegate
/// 聚焦
- (void)tappedToFocusAtPoint:(CGPoint)point {
    [self.cameraVc focusAtPoint:point];
}

#pragma mark - 方向变化处理
/// 自动旋转
- (BOOL) shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (void) viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsPortrait(deviceOrientation) || UIDeviceOrientationIsLandscape(deviceOrientation)) {
        self.previewView.videoPreviewLayer.connection.videoOrientation = (AVCaptureVideoOrientation)deviceOrientation;
    }
}

// MARK: - 控件
-(WSPreView *)previewView {
    if (!_previewView) {
        _previewView = [[WSPreView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREENH_HEIGHT)];
        _previewView.backgroundColor = [UIColor redColor];
        _previewView.delegate = self;
    }
    
    return _previewView;
}

-(WSOverlayView *)overlayView {
    if (!_overlayView) {
        _overlayView = [[WSOverlayView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREENH_HEIGHT)];
        _overlayView.backgroundColor = [UIColor clearColor];
        _overlayView.delegate = self;
    }
    
    return _overlayView;
}

@end
