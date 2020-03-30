//
//  WSPreView.h
//  camera-su
//
//  Created by 苏文潇 on 2020/3/29.
//  Copyright © 2020 we_shell. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol WSPreViewDelegate <NSObject>
/// 聚焦
- (void)tappedToFocusAtPoint:(CGPoint)point;
//- (void)tappedToExposeAtPoint:(CGPoint)point;//曝光
//- (void)tappedToResetFocusAndExposure;//点击重置聚焦&曝光

@end

@interface WSPreView : UIView

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, weak) id<WSPreViewDelegate> delegate;
@property (nonatomic, strong, readonly) AVCaptureVideoPreviewLayer *videoPreviewLayer;
/// 是否聚焦
@property (nonatomic, assign) BOOL focusEnabled;

@end

NS_ASSUME_NONNULL_END
