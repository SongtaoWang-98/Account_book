//
//  ABEachDetailViewController.m
//  Account_book
//
//  Created by 王松涛 on 2020/7/25.
//  Copyright © 2020 Songtao Wang. All rights reserved.
//

#import "ABEachDetailViewController.h"
#import "Definition.h"
#import "DataBase.h"

@interface ABEachDetailViewController ()

//导航栏元素
@property (nonatomic, strong, readwrite) UIView *naviView;
@property (nonatomic, strong, readwrite) UIButton *backBtn;
@property (nonatomic, strong, readwrite) UILabel *titleLabel;

@property (nonatomic, strong, readwrite) UIView *detailView;

@property (nonatomic, copy) NSString *idStr;
@property (nonatomic, copy) NSString *typeStr;
@property (nonatomic, copy) NSString *amountStr;
@property (nonatomic, copy) NSString *accountStr;
@property (nonatomic, copy) NSString *remarkStr;
@property (nonatomic, copy) NSString *dateStr;
@property (nonatomic, strong, readwrite) UILabel *typeLabel;
@property (nonatomic, strong, readwrite) UILabel *dateLabel;
@property (nonatomic, strong, readwrite) UILabel *amountLabel;
@property (nonatomic, strong, readwrite) UILabel *accountLabel;
@property (nonatomic, strong, readwrite) UILabel *remarkLabel;

@end

@implementation ABEachDetailViewController
- (instancetype)initWithDetailID:(NSString *)ID andType:(NSString *)type andDate:(NSString *)date andAccount:(NSString *)account andAmount:(NSString *)amount andRemark:(NSString *)remark{
    self = [super init];
    if (self) {
        self.idStr = ID;
        self.dateStr = date;
        self.accountStr = account;
        self.amountStr = amount;
        self.typeStr = type;
        self.remarkStr = remark;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    self.naviView = [[UIView alloc] init];
    [self.naviView setBackgroundColor:MAIN_COLOR];
    [self.view addSubview:self.naviView];
    self.backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [self.backBtn setBackgroundColor:[UIColor blackColor]];
    [self.backBtn addTarget:self action:@selector(returnToLastView) forControlEvents:UIControlEventTouchUpInside];
    [self.naviView addSubview:self.backBtn];
    self.titleLabel = [[UILabel alloc] init];
    [self.titleLabel setFont:[UIFont systemFontOfSize:20]];
    [self.naviView addSubview:self.titleLabel];
    
    self.detailView = [[UIView alloc] init];
    [self.view addSubview:self.detailView];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.naviView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, STATUS_HEIGHT + NAVI_HEIGHT)];
    [self.detailView setFrame:CGRectMake(0, STATUS_HEIGHT + NAVI_HEIGHT, SCREEN_WIDTH, 350)];
    [self showButtonsAndLabels];
}

- (void)showButtonsAndLabels {
    [self.backBtn setCenter:CGPointMake(40, STATUS_HEIGHT + NAVI_HEIGHT / 2)];
    [self.titleLabel setText:@"明细详情"];
    [self.titleLabel sizeToFit];
    [self.titleLabel setCenter:CGPointMake(SCREEN_WIDTH / 2, STATUS_HEIGHT + NAVI_HEIGHT / 2)];
    NSArray *labels = [NSArray arrayWithObjects:@"类型:",@"日期:",@"账户:",@"金额:",@"备注:",nil];
    for (int i = 0; i<5; i++){
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(20, 70*i+69.5, SCREEN_WIDTH - 20, 0.5)];
        [line setBackgroundColor:[UIColor lightGrayColor]];
        [self.detailView addSubview:line];
        UILabel *label = [[UILabel alloc] init];
        [label setText:[labels objectAtIndex:i]];
        [label sizeToFit];
        [label setCenter:CGPointMake(40, 70*i+35)];
        [label setTextColor:[UIColor grayColor]];
        [self.detailView addSubview:label];
    }
    self.typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 25, 60, 40)];
    [self.typeLabel setText:self.typeStr];
    [self.typeLabel sizeToFit];
    [self.detailView addSubview:self.typeLabel];
    self.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 95, 60, 40)];
    [self.dateLabel setText:self.dateStr];
    [self.dateLabel sizeToFit];
    [self.detailView addSubview:self.dateLabel];
    self.accountLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 165, 60, 40)];
    [self.accountLabel setText:self.accountStr];
    [self.accountLabel sizeToFit];
    [self.detailView addSubview:self.accountLabel];
    self.amountLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 235, 60, 40)];
    [self.amountLabel setText:self.amountStr];
    [self.amountLabel sizeToFit];
    [self.detailView addSubview:self.amountLabel];
    self.remarkLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 305, 60, 40)];
    [self.remarkLabel setText:self.remarkStr];
    [self.remarkLabel sizeToFit];
    [self.detailView addSubview:self.remarkLabel];
}

- (void)returnToLastView {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
