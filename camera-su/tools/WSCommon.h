//
//  WSCommon.h
//  camera-su
//
//  Created by 苏文潇 on 2020/3/29.
//  Copyright © 2020 we_shell. All rights reserved.
//

#ifndef WSCommon_h
#define WSCommon_h


//屏幕
#define SCREEN_WIDTH   [UIScreen mainScreen].bounds.size.width
#define SCREENH_HEIGHT [UIScreen mainScreen].bounds.size.height

///屏幕适配（长宽）
// 竖屏
#define V_Width(value)  (value)*(SCREEN_WIDTH/768.0f)
#define V_Height(value)  (value)*(SCREENH_HEIGHT/1024.0f)

// 横屏
#define H_Width(value)  (value)*(SCREEN_WIDTH/1024.0f)
#define H_Height(value)  (value)*(SCREENH_HEIGHT/768.0f)


#endif /* WSCommon_h */
