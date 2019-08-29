//
//  Definition.h
//  news
//
//  Created by XJIMI on 2019/5/29.
//  Copyright © 2019 XJIMI. All rights reserved.
//

#ifndef Definition_h
#define Definition_h

#define XJ_PortraitW MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)

#define XJ_PortraitH MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)

#define XJ_iPhoneXS ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)

#define XJ_iPhoneXR ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(828, 1792), [[UIScreen mainScreen] currentMode].size) : NO)

#define XJ_iPhoneXS_MAX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2688), [[UIScreen mainScreen] currentMode].size) : NO)

#define XJ_iPhoneX_Series ((XJ_iPhoneXS || XJ_iPhoneXS_MAX || XJ_iPhoneXR) ? YES : NO)

#define XJ_iSiPad [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad

#define XJ_iS3X ([[UIScreen mainScreen] currentMode].size.width/[UIScreen mainScreen].bounds.size.width == 3) ? YES : NO

#define XJ_StatusBarH (XJ_iPhoneX_Series ? 44.0f : 20.0f)

#define XJ_HdHeight(width) ceil((width) * 9.0 / 16.0)

#endif /* Definition_h */
