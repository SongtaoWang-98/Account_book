//
//  Definition.h
//  Account_book
//
//  Created by 王松涛 on 2020/6/10.
//  Copyright © 2020 Songtao Wang. All rights reserved.
//

#ifndef Definition_h
#define Definition_h

#define MAIN_COLOR [UIColor colorWithRed:210/255.0 green:105/255.0 blue:30/255.0 alpha:1]
#define SHADOW_COLOR [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1]
#define GHOSTWHITE [UIColor colorWithRed:248/255.0 green:248/255.0 blue:255/255.0 alpha:1]

#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define NAVI_HEIGHT self.navigationController.navigationBar.frame.size.height
#define STATUS_HEIGHT ([UIApplication sharedApplication].windows.firstObject.windowScene.statusBarManager.statusBarFrame.size.height)
//总资产视图高度
#define ASSETVIEW_HEIGHT (STATUS_HEIGHT + NAVI_HEIGHT + 120)
//明细时间选择和收支视图高度
#define DETAILVIEW_HEIGHT (STATUS_HEIGHT + NAVI_HEIGHT + 120)

#define MONTHSELECT_HEIGHT 300
//统计视图
#define STATISTIC_HEIGHT (STATUS_HEIGHT + NAVI_HEIGHT + 120)
//我的视图
#define MINEVIEW_HEIGHT (STATUS_HEIGHT + NAVI_HEIGHT + 120)
//键盘高度
#define MYKEYBOARD_HEIGHT 300
//账户选择视图
#define ACCOUNTSELECT_HEIGHT 400
#define ACCOUNTSELECT_WIDTH 300
//选择记录时间视图ACCOUNT
#define DATESELECT_HEIGHT 380
#define DATESELECT_WIDTH 300

#endif /* Definition_h */
