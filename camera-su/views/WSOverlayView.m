//
//  WSOverlayView.m
//  camera-su
//
//  Created by 苏文潇 on 2020/3/29.
//  Copyright © 2020 we_shell. All rights reserved.
//

#import "WSOverlayView.h"
@interface WSOverlayView()

@property (nonatomic, strong) UIButton *cancelBtn; // 退出按钮
@property (nonatomic, strong) UIButton *flashBtn;  // 闪光灯按钮
@property (nonatomic, strong) UIButton *cameraBtn; // 拍照按钮
@property (nonatomic, strong) UIButton *changeCameraBtn; // 翻转摄像头按钮

@end

@implementation WSOverlayView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUI];
    }
    return self;
}

- (void)setUI {
    [self addSubview:self.cancelBtn];
    [self addSubview:self.flashBtn];
    [self addSubview:self.cameraBtn];
    [self addSubview:self.changeCameraBtn];
}

- (void)setFlashHidden:(BOOL)flashHidden {
    if (_flashHidden != flashHidden) {
        _flashHidden = flashHidden;
        self.flashBtn.hidden = flashHidden;
    } 
}

#pragma mark - face detect
- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.cancelBtn.frame = CGRectMake(10, 20, 40, 40);
    self.flashBtn.frame = CGRectMake(10, 70, 40, 40);
    self.cameraBtn.frame = CGRectMake((SCREEN_WIDTH-68)/2, SCREENH_HEIGHT-80, 68, 68);
    self.changeCameraBtn.frame = CGRectMake(SCREEN_WIDTH-50, 20, 40, 40);
}

// MARK: - touch event
- (void)cancelClcik {
    if (self.delegate && [self.delegate respondsToSelector:@selector(exit)]) {
        [self.delegate exit];
    }
}

- (void)flashClcik:(UIButton *)btn {
    self.flashBtn.selected = !btn.isSelected;
    if (self.delegate && [self.delegate respondsToSelector:@selector(flashOpen:)]) {
        NSString *flashText = (btn.isSelected == YES) ? @"开" : @"关";
        [btn setTitle:flashText forState:UIControlStateNormal];
        [self.delegate flashOpen:btn.isSelected];
    }
}

- (void)cameraBtnClick:(UIButton *)btn {
    if (self.delegate && [self.delegate respondsToSelector:@selector(takePhoto)]) {
        [self.delegate takePhoto];
    }
}

- (void)changCameraClcik: (UIButton *)btn {
    if (self.delegate && [self.delegate respondsToSelector:@selector(changeCamera)]) {
        [self.delegate changeCamera];
    }
}

// MARK: - touch point
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if ([self.cameraBtn pointInside:[self convertPoint:point toView:self.cameraBtn] withEvent:event] ||
        [self.cancelBtn pointInside:[self convertPoint:point toView:self.cancelBtn] withEvent:event] ||
        [self.flashBtn pointInside:[self convertPoint:point toView:self.flashBtn] withEvent:event] ||
        [self.changeCameraBtn pointInside:[self convertPoint:point toView:self.changeCameraBtn] withEvent:event]) {
        return YES;
    }
    return NO;
}

// MARK: - 控件
- (UIButton *)cameraBtn {
    if (!_cameraBtn) {
        _cameraBtn = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-68)/2, SCREENH_HEIGHT-80, 68, 68)];
        _cameraBtn.adjustsImageWhenHighlighted = NO;
        _cameraBtn.adjustsImageWhenDisabled = NO;
        _cameraBtn.layer.cornerRadius = 34;
        _cameraBtn.layer.masksToBounds = YES;
        [_cameraBtn setTitle:@"拍" forState:UIControlStateNormal];
        [_cameraBtn addTarget:self action:@selector(cameraBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        _cameraBtn.backgroundColor = [UIColor orangeColor];
    }
    return _cameraBtn;
}

- (UIButton *)cancelBtn {
    if (!_cancelBtn) {
        _cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 20, 40, 40)];
        _cancelBtn.layer.cornerRadius = 20;
        _cancelBtn.layer.masksToBounds = YES;
        [_cancelBtn setTitle:@"X" forState:UIControlStateNormal];
        [_cancelBtn addTarget:self action:@selector(cancelClcik) forControlEvents:UIControlEventTouchUpInside];
        _cancelBtn.backgroundColor = [UIColor orangeColor];
    }
    return _cancelBtn;
}

- (UIButton *)flashBtn {
    if (!_flashBtn) {
        _flashBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 70, 40, 40)];
        _flashBtn.layer.cornerRadius = 20;
        _flashBtn.layer.masksToBounds = YES;
        [_flashBtn setTitle:@"关" forState:UIControlStateNormal];
        [_flashBtn addTarget:self action:@selector(flashClcik:) forControlEvents:UIControlEventTouchUpInside];
        _flashBtn.backgroundColor = [UIColor orangeColor];
    }
    return _flashBtn;
}


- (UIButton *)changeCameraBtn {
    if (!_changeCameraBtn) {
        _changeCameraBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-50, 20, 40, 40)];
        _changeCameraBtn.layer.cornerRadius = 20;
        _changeCameraBtn.layer.masksToBounds = YES;
        [_changeCameraBtn setTitle:@"转" forState:UIControlStateNormal];
        [_changeCameraBtn addTarget:self action:@selector(changCameraClcik:) forControlEvents:UIControlEventTouchUpInside];
        _changeCameraBtn.backgroundColor = [UIColor orangeColor];
    }
    return _changeCameraBtn;
}


@end
