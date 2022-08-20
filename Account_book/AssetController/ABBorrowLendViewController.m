//
//  ABBorrowLendViewController.m
//  Account_book
//
//  Created by 王松涛 on 2020/7/26.
//  Copyright © 2020 Songtao Wang. All rights reserved.
//

#import "ABBorrowLendViewController.h"
#import "ABAddBorrowRecordViewController.h"
#import "Definition.h"
#import "DataBase.h"

@interface ABBorrowLendViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, copy) NSString *type;
//导航栏元素
@property (nonatomic, strong, readwrite) UIView *naviView;
@property (nonatomic, strong, readwrite) UIButton *backBtn;
@property (nonatomic, strong, readwrite) UILabel *titleLabel;
//显示待还金额
@property (nonatomic, strong, readwrite) UILabel *restLabel;
@property (nonatomic, strong, readwrite) UILabel *restAmount;
@property (nonatomic, strong, readwrite) UILabel *borrowLabel;
@property (nonatomic, strong, readwrite) UILabel *borrowAmount;
@property (nonatomic, strong, readwrite) UILabel *repayLabel;
@property (nonatomic, strong, readwrite) UILabel *repayAmount;
//借款记录
@property (nonatomic, strong, readwrite) UITableView *borrowRecordTabelView;

@property (nonatomic, strong, readwrite) UIButton *addBtn;
@property (nonatomic, strong, readwrite) UIButton *finishBtn;

@end

@implementation ABBorrowLendViewController
- (instancetype)initWithType:(NSString *)type {
    self = [super init];
    if (self) {
        self.type = type;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    self.borrowRecordTabelView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) style:(UITableViewStyleGrouped)];
    [self.view addSubview:self.borrowRecordTabelView];
    self.borrowRecordTabelView.delegate = self;
    self.borrowRecordTabelView.dataSource = self;
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

    self.restLabel = [[UILabel alloc] init];
    [self.naviView addSubview:self.restLabel];
    [self.restLabel setFont:[UIFont systemFontOfSize:24]];
    self.borrowLabel = [[UILabel alloc] init];
    [self.naviView addSubview:self.borrowLabel];
    [self.borrowLabel setFont:[UIFont systemFontOfSize:20]];
    self.repayLabel = [[UILabel alloc] init];
    [self.naviView addSubview:self.repayLabel];
    [self.repayLabel setFont:[UIFont systemFontOfSize:20]];

    self.restAmount = [[UILabel alloc] init];
    [self.naviView addSubview:self.restAmount];
    [self.restAmount setFont:[UIFont systemFontOfSize:30]];
    self.borrowAmount = [[UILabel alloc] init];
    [self.naviView addSubview:self.borrowAmount];
    [self.borrowAmount setFont:[UIFont systemFontOfSize:20]];
    self.repayAmount = [[UILabel alloc] init];
    [self.naviView addSubview:self.repayAmount];
    [self.repayAmount setFont:[UIFont systemFontOfSize:20]];
    
    self.addBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 74, SCREEN_WIDTH/2 ,50)];
    [self.view addSubview:self.addBtn];
    [self.addBtn setBackgroundColor:SHADOW_COLOR];
    self.addBtn.titleLabel.font = [UIFont systemFontOfSize:20];
    [self.addBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.addBtn addTarget:self action:@selector(addBorrowRecord) forControlEvents:UIControlEventTouchUpInside];
    
    self.finishBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT - 74, SCREEN_WIDTH/2, 50)];
    [self.view addSubview:self.finishBtn];
    [self.finishBtn setBackgroundColor:SHADOW_COLOR];
    self.finishBtn.titleLabel.font = [UIFont systemFontOfSize:20];
    [self.finishBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.finishBtn addTarget:self action:@selector(finishBorrowRecord) forControlEvents:UIControlEventTouchUpInside];
}
- (void)viewWillAppear:(BOOL)animated{
    [self.naviView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, ASSETVIEW_HEIGHT)];
    [self.borrowRecordTabelView setFrame:CGRectMake(0, ASSETVIEW_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - ASSETVIEW_HEIGHT - 74)];
    [self showButtonsAndLabels];
    [self.borrowRecordTabelView reloadData];
}
- (void)showButtonsAndLabels {
    [self.backBtn setCenter:CGPointMake(40, STATUS_HEIGHT + NAVI_HEIGHT / 2)];
    [self.titleLabel setText:self.type];
    [self.titleLabel sizeToFit];
    [self.titleLabel setCenter:CGPointMake(SCREEN_WIDTH / 2, STATUS_HEIGHT + NAVI_HEIGHT / 2)];

    if ([self.type isEqualToString:@"借入"]) {
        self.restLabel.text = @"待还";
        [self.restLabel setFrame:CGRectMake(20, STATUS_HEIGHT + NAVI_HEIGHT + 10, 0, 0)];
        [self.restLabel sizeToFit];
        self.borrowLabel.text = @"总借入：";
        [self.borrowLabel setFrame:CGRectMake(20, STATUS_HEIGHT + NAVI_HEIGHT + 50, 0, 0)];
        [self.borrowLabel sizeToFit];
        self.repayLabel.text = @"已还清：";
        [self.repayLabel setFrame:CGRectMake(20, STATUS_HEIGHT + NAVI_HEIGHT + 80, 0, 0)];
        [self.repayLabel sizeToFit];
        double borrowD = [[DataBase sharedDataBase] getSumAmountWithCommand:@"select * from record where label = '借入'" andCondition:@"" andColumn:@"amount"];
        [self.borrowAmount setFrame:CGRectMake(self.borrowLabel.bounds.size.width + 50, STATUS_HEIGHT + NAVI_HEIGHT + 50, 0, 0)];
        [self.borrowAmount setText:[NSString stringWithFormat:@"%.2f", borrowD]];
        [self.borrowAmount sizeToFit];
        double repayD = [[DataBase sharedDataBase] getSumAmountWithCommand:@"select * from record where label = '借入还款'" andCondition:@"" andColumn:@"amount"];
        [self.repayAmount setFrame:CGRectMake(self.repayLabel.bounds.size.width + 50, STATUS_HEIGHT + NAVI_HEIGHT + 80, 0, 0)];
        [self.repayAmount setText:[NSString stringWithFormat:@"%.2f", repayD]];
        [self.repayAmount sizeToFit];
        [self.addBtn setTitle:@"新借入" forState:UIControlStateNormal];
        [self.finishBtn setTitle:@"还款" forState:UIControlStateNormal];
    } else if([self.type isEqualToString:@"借出"]) {
        self.restLabel.text = @"待收";
        [self.restLabel setFrame:CGRectMake(20, STATUS_HEIGHT + NAVI_HEIGHT + 10, 0, 0)];
        [self.restLabel sizeToFit];
        self.borrowLabel.text = @"总借出：";
        [self.borrowLabel setFrame:CGRectMake(20, STATUS_HEIGHT + NAVI_HEIGHT + 50, 0, 0)];
        [self.borrowLabel sizeToFit];
        self.repayLabel.text = @"已还清：";
        [self.repayLabel setFrame:CGRectMake(20, STATUS_HEIGHT + NAVI_HEIGHT + 80, 0, 0)];
        [self.repayLabel sizeToFit];
        double borrowD = [[DataBase sharedDataBase] getSumAmountWithCommand:@"select * from record where label = '借出'" andCondition:@"" andColumn:@"amount"];
        [self.borrowAmount setFrame:CGRectMake(self.borrowLabel.bounds.size.width + 50, STATUS_HEIGHT + NAVI_HEIGHT + 50, 0, 0)];
        [self.borrowAmount setText:[NSString stringWithFormat:@"%.2f", borrowD]];
        [self.borrowAmount sizeToFit];
        double repayD = [[DataBase sharedDataBase] getSumAmountWithCommand:@"select * from record where label = '借出收款'" andCondition:@"" andColumn:@"amount"];
        [self.repayAmount setFrame:CGRectMake(self.repayLabel.bounds.size.width + 50, STATUS_HEIGHT + NAVI_HEIGHT + 80, 0, 0)];
        [self.repayAmount setText:[NSString stringWithFormat:@"%.2f", repayD]];
        [self.repayAmount sizeToFit];
        [self.addBtn setTitle:@"新借出" forState:UIControlStateNormal];
        [self.finishBtn setTitle:@"收款" forState:UIControlStateNormal];
    }else if([self.type isEqualToString:@"报销"]) {
        self.restLabel.text = @"待报销";
        [self.restLabel setFrame:CGRectMake(20, STATUS_HEIGHT + NAVI_HEIGHT + 10, 0, 0)];
        [self.restLabel sizeToFit];
        [self.borrowLabel removeFromSuperview];
        self.repayLabel.text = @"已报销：";
        [self.repayLabel setFrame:CGRectMake(20, STATUS_HEIGHT + NAVI_HEIGHT + 60, 0, 0)];
        [self.repayLabel sizeToFit];
        double repayD = [[DataBase sharedDataBase] getSumAmountWithCommand:@"select * from record where label = '报销款'" andCondition:@"" andColumn:@"amount"];
        [self.repayAmount setFrame:CGRectMake(self.repayLabel.bounds.size.width + 50, STATUS_HEIGHT + NAVI_HEIGHT + 60, 0, 0)];
        [self.repayAmount setText:[NSString stringWithFormat:@"%.2f", repayD]];
        [self.repayAmount sizeToFit];
        [self.addBtn setTitle:@"新建" forState:UIControlStateNormal];
        [self.finishBtn setTitle:@"收款" forState:UIControlStateNormal];
    }
    NSString *restStr = [[[DataBase sharedDataBase] getInfoWithCommand:@"select * from account where accountname = ?" andCondition:self.type andColumn:@"money"] objectAtIndex:0];
    [self.restAmount setFrame:CGRectMake(40 + self.restLabel.bounds.size.width, STATUS_HEIGHT + NAVI_HEIGHT + 6, 0, 0)];
    [self.restAmount setText:[NSString stringWithFormat:@"%.2f", [restStr doubleValue]]];
    [self.restAmount sizeToFit];
}
- (void)returnToLastView {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addBorrowRecord{
    ABAddBorrowRecordViewController *addBorrowController = [[ABAddBorrowRecordViewController alloc] initWithType:self.type andOperation:@"添加"];
    [self.navigationController pushViewController:addBorrowController animated:YES];
}

- (void)finishBorrowRecord{
    ABAddBorrowRecordViewController *addBorrowController = [[ABAddBorrowRecordViewController alloc] initWithType:self.type andOperation:@"完成"];
    [self.navigationController pushViewController:addBorrowController animated:YES];
}
#pragma mark - UITableViewDataSource
//返回每组行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rowNumber = [[DataBase sharedDataBase] getNumberWithCommand:@"select count(*) from borrow where type = ?" andColumn:self.type];
    return rowNumber;
}

//返回每行单元格
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *nameArray = [[DataBase sharedDataBase] getInfoWithCommand:@"select * from borrow where type = ?" andCondition:self.type andColumn:@"name"];
    NSArray *amountArray = [[DataBase sharedDataBase] getInfoWithCommand:@"select * from borrow where type = ?" andCondition:self.type andColumn:@"amount"];
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%ld%ld", indexPath.section, indexPath.row];//以indexPath来唯一确定cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 7, 36, 36)];
        nameLabel.layer.cornerRadius = 18;
        [nameLabel setText:[nameArray objectAtIndex:indexPath.row]];
        [cell addSubview:nameLabel];
        
        UILabel *amountLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 140, 15, 120, 20)];
        [amountLabel setText:[amountArray objectAtIndex:indexPath.row]];
        amountLabel.textAlignment = NSTextAlignmentRight;
        [cell addSubview:amountLabel];
    }
    return cell;
}

// 返回分组数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

#pragma mark - UITableViewDelegate

// 返回每个 Cell 的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

// 返回每个 Section 的 HeaderView 高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

// 返回每个 Section FooterView 的高度
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

// 返回 Section 自定义的 HeaderView
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] init];
    return headerView;
}

// 返回 Section 自定义的 FooterView
- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] init];
    return footerView;
}
@end
