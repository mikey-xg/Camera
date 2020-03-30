//
//  WSCameraViewController.m
//  camera-su
//
//  Created by 苏文潇 on 2020/3/29.
//  Copyright © 2020 we_shell. All rights reserved.
//

#import "WSCameraViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "DeviceOrientation.h"
#import <Photos/Photos.h>

@interface WSCameraViewController () <AVCapturePhotoCaptureDelegate>

@property (nonatomic, weak) AVCaptureDeviceInput *activeVideoInput;//记录当前是哪一个输入
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCapturePhotoOutput *imageOutput; // 图片输出
@property (nonatomic, strong) dispatch_queue_t photoQueue; // 队列
@property (nonatomic, strong) AVCapturePhotoSettings *photoSettings; //

@end

@implementation WSCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (BOOL)setSession:(NSError *)error {
    self.captureSession = [[AVCaptureSession alloc] init];
    self.captureSession.sessionPreset = AVCaptureSessionPresetHigh; // 图片质量
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    if (input) {
        if ([self.captureSession canAddInput:input]) {
            [self.captureSession addInput:input];
            self.activeVideoInput = input;
        } else {
            return NO;
        }
    }

    AVCapturePhotoOutput *outPut = [[AVCapturePhotoOutput alloc] init];
    self.imageOutput = outPut;
    
    NSDictionary *settingDic = @{AVVideoCodecKey:AVVideoCodecJPEG};
    AVCapturePhotoSettings *settings = [AVCapturePhotoSettings photoSettingsWithFormat:settingDic];
    self.photoSettings = settings;
    [outPut setPhotoSettingsForSceneMonitoring:settings];

    if ([self.captureSession canAddOutput:outPut]) {
        [self.captureSession addOutput:outPut];
    }
    
    self.photoQueue = dispatch_queue_create("we_shell.photoQueue", NULL);
    
    return YES;
}

- (void)startSession {
    if (![self.captureSession isRunning]) {
        dispatch_async(self.photoQueue, ^{
            [self.captureSession startRunning];
        });
    }
}

- (void)stopSession {
    if ([self.captureSession isRunning]) {
        dispatch_async(self.photoQueue, ^{
            [self.captureSession stopRunning];
        });
    }
}

// MARK: - 聚焦
- (BOOL)cameraSupportFocus {
    return [[self activeCamera] isFocusPointOfInterestSupported];
}
/// 聚焦
- (void)focusAtPoint:(CGPoint)point {
    AVCaptureDevice *device = [self activeCamera];
    if (device.isFocusPointOfInterestSupported && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *err;
        if ([device lockForConfiguration:&err]) {
            device.focusPointOfInterest = point;
            device.focusMode = AVCaptureFocusModeAutoFocus;
            [device unlockForConfiguration];
        } else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(deviceConfigFailedWithError:)]) {
                [self.delegate deviceConfigFailedWithError:err];
            }
        }
    }
}

- (void)resetFocusAndExposureModes {
    AVCaptureDevice *device = [self activeCamera];
    AVCaptureFocusMode focusMode = AVCaptureFocusModeContinuousAutoFocus;
    BOOL canResetFocus = [device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode];
    AVCaptureExposureMode exposureMode = AVCaptureExposureModeContinuousAutoExposure;
    BOOL canResetExposure = [device isFocusPointOfInterestSupported] && [device isExposureModeSupported:exposureMode];
    
    CGPoint centPoint = CGPointMake(0.5, 0.5);
    NSError *err;
    if ([device lockForConfiguration:&err]) {
        if (canResetFocus) {
            device.focusMode = focusMode;
            device.focusPointOfInterest = centPoint;
        }
        
        if (canResetExposure) {
            device.exposureMode = exposureMode;
            device.exposurePointOfInterest = centPoint;
        }
        
        [device unlockForConfiguration];
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(deviceConfigFailedWithError:)]) {
            [self.delegate deviceConfigFailedWithError:err];
        }
    }
    
}
//
// MARK: - 摄像头相关
- (NSUInteger)cameraCount {
    return [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera] mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionUnspecified].devices.count;;
}

- (BOOL)canUseSwitchCameras {
    return [self cameraCount] > 1;
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position {
    AVCaptureDeviceDiscoverySession *session = [AVCaptureDeviceDiscoverySession  discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera] mediaType:AVMediaTypeVideo position: position];
    NSArray *devices  = session.devices;
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}

// 切换
- (BOOL)switchCameras {
    if (![self canUseSwitchCameras]) {
        return NO;
    }
    NSError *err;
    AVCaptureDevice *videoDevice = [self inactiveCamera];
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&err];
    if (input) {
        [self.captureSession beginConfiguration];
        [self.captureSession removeInput:self.activeVideoInput];
        if ([self.captureSession canAddInput:input]) {
            [self.captureSession addInput:input];
            self.activeVideoInput = input;
        } else {
            [self.captureSession addInput:self.activeVideoInput];
        }
        [self.captureSession commitConfiguration];
    } else { // 出错
        if (self.delegate && [self.delegate respondsToSelector:@selector(deviceConfigFailedWithError:)]) {
            [self.delegate deviceConfigFailedWithError:err];
            return NO;
        }
    }
    return YES;
}

// 激活的设备
- (AVCaptureDevice *)activeCamera {
    return self.activeVideoInput.device;
}

/// 未激活的设备
- (AVCaptureDevice *)inactiveCamera {
    AVCaptureDevice *device = nil;
    if (self.cameraCount > 1) {
        if ([self activeCamera].position == AVCaptureDevicePositionBack) {
            device = [self cameraWithPosition:AVCaptureDevicePositionFront];
        } else {
            device = [self cameraWithPosition:AVCaptureDevicePositionBack];
        }
    }
    return device;
}

// MARK: - 闪光灯
- (BOOL)cameraFlash {
    return [[self activeCamera] hasFlash];
}

- (void)setFlashMode:(AVCaptureFlashMode)flashMode {
    AVCaptureDevice *device = [self activeCamera];
    if ([self.imageOutput.supportedFlashModes containsObject:@(flashMode)]) {
        NSError *err;
        if ([device lockForConfiguration:&err]) {
            self.photoSettings.flashMode = flashMode;
            [device unlockForConfiguration];
        } else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(deviceConfigFailedWithError:)]) {
                [self.delegate deviceConfigFailedWithError:err];
            }
        }
    }
}

- (void)takePhoto {
    AVCaptureConnection *connection = [self.imageOutput connectionWithMediaType:AVMediaTypeVideo];
    if (connection.isVideoOrientationSupported) {
        connection.videoOrientation = [self getCurrentOrientation];
    }
    if ([self.captureSession canAddConnection:connection]) {
        [self.captureSession addConnection:connection];
    }
    [self.imageOutput capturePhotoWithSettings:self.photoSettings delegate:self];
}

- (void)writeImageToAssetsLibrary:(UIImage *)image {
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [PHAssetChangeRequest creationRequestForAssetFromImage:image];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            NSLog(@"保存成功");
        } else {
            id message = [error localizedDescription];
            NSLog(@"保存失败。reason：%@",message);
        }
    }];
    
//    ALAssetsLibrary *library = [[ALAssetsLibrary alloc]init];
//    [library writeImageToSavedPhotosAlbum:image.CGImage orientation:(NSUInteger)image.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error) {
//        if (!error){
//            NSLog(@"保存成功");
//        } else {
//            id message = [error localizedDescription];
//            NSLog(@"%@",message);
//        }
//    }];
}

// MARK: - AVCapturePhotoCaptureDelegate
- (void)captureOutput:(AVCapturePhotoOutput *)captureOutput didFinishProcessingPhotoSampleBuffer:(nullable CMSampleBufferRef)photoSampleBuffer previewPhotoSampleBuffer:(nullable CMSampleBufferRef)previewPhotoSampleBuffer resolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings bracketSettings:(nullable AVCaptureBracketedStillImageSettings *)bracketSettings error:(nullable NSError *)error {
    __weak typeof(self) wSelf = self;
    
    wSelf.photoSettings = nil;
    NSDictionary *setDic = @{AVVideoCodecKey:AVVideoCodecJPEG};
    wSelf.photoSettings = [AVCapturePhotoSettings photoSettingsWithFormat:setDic];
    
    if (photoSampleBuffer != NULL) {
        NSData *data = [AVCapturePhotoOutput JPEGPhotoDataRepresentationForJPEGSampleBuffer:photoSampleBuffer previewPhotoSampleBuffer:previewPhotoSampleBuffer];
        UIImage *image = [UIImage imageWithData:data];
        [wSelf writeImageToAssetsLibrary:image];
    } else {
        NSLog(@"NULL Buffer:%@",[error localizedDescription]);
    }
}
    
///  方向
- (AVCaptureVideoOrientation)getCurrentOrientation {
    
    AVCaptureVideoOrientation orientation;
    
    switch ([UIDevice currentDevice].orientation) {
        case UIDeviceOrientationPortrait:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationLandscapeRight:
            orientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            orientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        default:
            orientation = AVCaptureVideoOrientationLandscapeRight;
            break;
    }
    
    return orientation;
}

- (void)dealloc {
    NSLog(@"销毁🌶🌶---%@", [self class]);
}

@end
