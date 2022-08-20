//
//  ABMineViewController.m
//  Account_book
//
//  Created by 王松涛 on 2020/6/8.
//  Copyright © 2020 Songtao Wang. All rights reserved.
//

#import "ABMineViewController.h"
#import "Definition.h"

@interface ABMineViewController ()

@property (nonatomic, strong, readwrite) UITableView *tableView;
@property (nonatomic, strong ,readwrite) UIView *titleView;

@end

@implementation ABMineViewController

- (instancetype)init {
self = [super init];
if (self) {
    self.tabBarItem.title = @"我的";
    self.tabBarItem.image = [UIImage imageNamed:@"icon.bundle/account_normal@2x.png"];
    self.tabBarItem.selectedImage = [[UIImage imageNamed:@"icon.bundle/account_highlight@2x.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    NSDictionary *dict = [NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName];
//    [self.tabBarItem setTitleTextAttributes:dict forState:UIControlStateSelected];
}
return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, MINEVIEW_HEIGHT)];
    self.titleView.backgroundColor = MAIN_COLOR;
    [self.view addSubview:self.titleView];
    
    UILabel *titleText = [[UILabel alloc] init];
    titleText.text = @"我的";
    [self.titleView addSubview:titleText];
    [titleText sizeToFit];
    titleText.center = CGPointMake(SCREEN_WIDTH/2, STATUS_HEIGHT+NAVI_HEIGHT/2);
}
- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
}

#pragma mark -

@end
