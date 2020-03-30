//
//  DeviceOrientation.h
//  camera-su
//
//  Created by 苏文潇 on 2020/3/29.
//  Copyright © 2020 we_shell. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,TgDirection) {
    TgDirectionUnkown,
    TgDirectionPortrait,
    TgDirectionDown,
    TgDirectionRight,
    TgDirectionleft,
};

@protocol DeviceOrientationDelegate <NSObject>

- (void)directionChange:(TgDirection)direction;

@end
@interface DeviceOrientation : NSObject

@property(nonatomic,strong)id<DeviceOrientationDelegate>delegate;

- (instancetype)initWithDelegate:(id<DeviceOrientationDelegate>)delegate;
/**
 开启监听
 */
- (void)startMonitor;
/**
 结束监听，请stop
 */
- (void)stop;

@end
