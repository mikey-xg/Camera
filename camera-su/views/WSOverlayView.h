//
//  WSOverlayView.h
//  camera-su
//
//  Created by 苏文潇 on 2020/3/29.
//  Copyright © 2020 we_shell. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol WSOverlayViewDelegate <NSObject>
/// 退出
- (void)exit;
/// 拍照
- (void)takePhoto;
/// 闪光灯
- (void)flashOpen:(BOOL)isOpen;
/// 翻转摄像头
- (void)changeCamera;

@end

@interface WSOverlayView : UIView

@property (nonatomic, weak) id<WSOverlayViewDelegate> delegate;
@property (nonatomic, assign) BOOL flashHidden;



@end

NS_ASSUME_NONNULL_END
