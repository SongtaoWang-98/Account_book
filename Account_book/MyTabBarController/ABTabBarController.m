//
//  ABTabBarController.m
//  Account_book
//
//  Created by 王松涛 on 2020/6/10.
//  Copyright © 2020 Songtao Wang. All rights reserved.
//

#import "ABTabBarController.h"
#import "AddRecordView.h"

@interface ABTabBarController ()

@property (nonatomic, strong) AddRecordView *addView;

@end

@implementation ABTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    ABTabBar *abTabBar = [[ABTabBar alloc] init];
    [self setValue:abTabBar forKey:@"tabBar"];
    [abTabBar.plusButton addTarget:self action:@selector(btnClicked) forControlEvents:UIControlEventTouchUpInside];
}

-(void) btnClicked{
    self.addView = [[AddRecordView alloc] init];
    [self.addView showInView];
}
@end
