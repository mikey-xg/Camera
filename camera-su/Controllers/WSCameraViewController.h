//
//  WSCameraViewController.h
//  camera-su
//
//  Created by 苏文潇 on 2020/3/29.
//  Copyright © 2020 we_shell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol WSCameraViewControllerDelegate <NSObject>

- (void)deviceConfigFailedWithError:(NSError *)error;

@end

@interface WSCameraViewController : UIViewController

@property (nonatomic, strong, readonly) AVCaptureSession *captureSession;

@property (nonatomic, readonly) BOOL cameraSupportFocus; //聚焦
@property (nonatomic, readonly) NSUInteger cameraCount; // 个数
@property (nonatomic, readonly) BOOL cameraFlash; //闪光灯
@property (nonatomic) AVCaptureFlashMode flashMode; //闪光灯模式
@property (nonatomic) AVCaptureTorchMode torchMode; //手电筒模式

@property (nonatomic, weak) id<WSCameraViewControllerDelegate> delegate;

// session 配置
- (BOOL)setSession:(NSError *)error;
- (void)startSession;
- (void)stopSession;

// 摄像头切换
- (BOOL)switchCameras;

/// 对焦
- (void)focusAtPoint:(CGPoint)point;
/// 重置曝光/对焦
- (void)resetFocusAndExposureModes;

/// 拍照
- (void)takePhoto;

@end

