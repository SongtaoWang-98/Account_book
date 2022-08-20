//
//  ABTabBar.h
//  Account_book
//
//  Created by 王松涛 on 2020/6/10.
//  Copyright © 2020 Songtao Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ABTabBarDelegate <UITabBarDelegate>

@optional

//- (void)tabBarClickPlusButton:(ABTabBar *)tabBar;

@end

@interface ABTabBar : UITabBar

@property (nonatomic, weak) id<ABTabBarDelegate> myDelegate;
@property (nonatomic, strong) UIButton *plusButton;

@end

NS_ASSUME_NONNULL_END
