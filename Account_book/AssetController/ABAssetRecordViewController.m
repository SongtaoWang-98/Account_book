//
//  ABAssetRecordViewController.m
//  Account_book
//
//  Created by 王松涛 on 2020/7/21.
//  Copyright © 2020 Songtao Wang. All rights reserved.
//

#import "ABAssetRecordViewController.h"
#import "Definition.h"
#import "DataBase.h"

@interface ABAssetRecordViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, copy) NSString *accountName;
@property (nonatomic, copy) NSString *accountType;
//导航栏元素
@property (nonatomic, strong, readwrite) UIView *naviView;
@property (nonatomic, strong, readwrite) UIButton *backBtn;
@property (nonatomic, strong, readwrite) UILabel *titleLabel;
//显示账户余额
@property (nonatomic, strong, readwrite) UILabel *balanceLabel;
@property (nonatomic, strong, readwrite) UILabel *balanceAmount;
@property (nonatomic, strong, readwrite) UILabel *inflowLabel;
@property (nonatomic, strong, readwrite) UILabel *inflowAmount;
@property (nonatomic, strong, readwrite) UILabel *outflowLabel;
@property (nonatomic, strong, readwrite) UILabel *outflowAmount;
//该账户交易记录
@property (nonatomic, strong, readwrite) UITableView *accountRecordTabelView;
@property (nonatomic, strong) NSMutableArray *tradeMonth;//有记录的月份
@property (nonatomic, strong) NSMutableArray *tradeDate;//有记录的日期

@property (nonatomic, strong) NSMutableArray *dateArray;//时间数组的数组
@property (nonatomic, strong) NSMutableArray *labelArray;
@property (nonatomic, strong) NSMutableArray *amountArray;
@property (nonatomic, strong) NSMutableArray *typeArray;
@property (nonatomic, strong) NSMutableArray *remarkArray;

@end

@implementation ABAssetRecordViewController
- (instancetype)initWithAccountName:(NSString *)accountname andAccountType:(NSString *)type {
    self = [super init];
    if (self) {
        self.accountName = accountname;
        self.accountType = type;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    self.accountRecordTabelView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) style:(UITableViewStyleGrouped)];
    [self.view addSubview:self.accountRecordTabelView];
    self.accountRecordTabelView.delegate = self;
    self.accountRecordTabelView.dataSource = self;
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

    self.balanceLabel = [[UILabel alloc] init];
    [self.naviView addSubview:self.balanceLabel];
    [self.balanceLabel setFont:[UIFont systemFontOfSize:24]];
    self.inflowLabel = [[UILabel alloc] init];
    self.inflowLabel.text = @"流入：";
    [self.naviView addSubview:self.inflowLabel];
    [self.inflowLabel setFont:[UIFont systemFontOfSize:20]];
    self.outflowLabel = [[UILabel alloc] init];
    self.outflowLabel.text = @"流出：";
    [self.naviView addSubview:self.outflowLabel];
    [self.outflowLabel setFont:[UIFont systemFontOfSize:20]];

    self.balanceAmount = [[UILabel alloc] init];
    [self.naviView addSubview:self.balanceAmount];
    [self.balanceAmount setFont:[UIFont systemFontOfSize:30]];
    self.inflowAmount = [[UILabel alloc] init];
    [self.naviView addSubview:self.inflowAmount];
    [self.inflowAmount setFont:[UIFont systemFontOfSize:20]];
    self.outflowAmount = [[UILabel alloc] init];
    [self.naviView addSubview:self.outflowAmount];
    [self.outflowAmount setFont:[UIFont systemFontOfSize:20]];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.naviView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, ASSETVIEW_HEIGHT)];
    [self.accountRecordTabelView setFrame:CGRectMake(0, ASSETVIEW_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - ASSETVIEW_HEIGHT)];
    [self showButtonsAndLabels];
    [self seekTradeMonth];
    [self createAllArray];
}

- (void)showButtonsAndLabels {
    [self.backBtn setCenter:CGPointMake(40, STATUS_HEIGHT + NAVI_HEIGHT / 2)];
    [self.titleLabel setText:self.accountName];
    [self.titleLabel sizeToFit];
    [self.titleLabel setCenter:CGPointMake(SCREEN_WIDTH / 2, STATUS_HEIGHT + NAVI_HEIGHT / 2)];

    if ([self.accountType isEqualToString:@"信用账户"]) {
        self.balanceLabel.text = @"账户待还";
    } else {
        self.balanceLabel.text = @"账户余额";
    }
    [self.balanceLabel setFrame:CGRectMake(20, STATUS_HEIGHT + NAVI_HEIGHT + 10, 0, 0)];
    [self.balanceLabel sizeToFit];
    [self.inflowLabel setFrame:CGRectMake(20, STATUS_HEIGHT + NAVI_HEIGHT + 50, 0, 0)];
    [self.inflowLabel sizeToFit];
    [self.outflowLabel setFrame:CGRectMake(20, STATUS_HEIGHT + NAVI_HEIGHT + 80, 0, 0)];
    [self.outflowLabel sizeToFit];

    NSString *balanceStr = [[[DataBase sharedDataBase] getInfoWithCommand:@"select * from account where accountname = ?" andCondition:self.accountName andColumn:@"money"] objectAtIndex:0];
    [self.balanceAmount setFrame:CGRectMake(40 + self.balanceLabel.bounds.size.width, STATUS_HEIGHT + NAVI_HEIGHT + 6, 0, 0)];
    [self.balanceAmount setText:[NSString stringWithFormat:@"%.2f", [balanceStr doubleValue]]];
    [self.balanceAmount sizeToFit];

    double inflowD = [[DataBase sharedDataBase] getSumAmountWithCommand:@"select * from record where type = '收入' and account = ?" andCondition:self.accountName andColumn:@"amount"];
    [self.inflowAmount setFrame:CGRectMake(self.inflowLabel.bounds.size.width + 50, STATUS_HEIGHT + NAVI_HEIGHT + 50, 0, 0)];
    [self.inflowAmount setText:[NSString stringWithFormat:@"%.2f", inflowD]];
    [self.inflowAmount sizeToFit];

    double outflowD = [[DataBase sharedDataBase] getSumAmountWithCommand:@"select * from record where type = '支出' and account = ?" andCondition:self.accountName andColumn:@"amount"];
    [self.outflowAmount setFrame:CGRectMake(self.outflowLabel.bounds.size.width + 50, STATUS_HEIGHT + NAVI_HEIGHT + 80, 0, 0)];
    [self.outflowAmount setText:[NSString stringWithFormat:@"%.2f", outflowD]];
    [self.outflowAmount sizeToFit];
}

- (void)returnToLastView {
    [self.navigationController popViewControllerAnimated:YES];
}

//筛选出当前账户有交易记录的日期 和月份
- (void)seekTradeMonth {
    self.tradeDate = [[DataBase sharedDataBase] getInfoWithCommand:@"select * from record where account = ?" andCondition:self.accountName andColumn:@"date"];
    self.tradeMonth = [[NSMutableArray alloc] init];
    NSRange yearMonthRange = NSMakeRange(0, 7);
    NSRange yearRange = NSMakeRange(0, 4);
    NSRange monthRange = NSMakeRange(5, 2);
    NSString *str = @"";
    for (int i = 0; i < [self.tradeDate count]; i++) {
        [self.tradeMonth addObject:[[self.tradeDate objectAtIndex:i]substringWithRange:yearMonthRange]];
    }
    if ([self.tradeMonth count] >= 2) {
        for (int i = 0; i < [self.tradeMonth count] - 1; i++) {
            for (int j = i + 1; j < [self.tradeMonth count]; j++) {
                if ([[self.tradeMonth objectAtIndex:i] isEqualToString:[self.tradeMonth objectAtIndex:j]]) {
                    [self.tradeMonth removeObjectAtIndex:j];
                    j--;
                }
                if ([[[self.tradeMonth objectAtIndex:i] substringWithRange:yearRange] intValue] < [[[self.tradeMonth objectAtIndex:j] substringWithRange:yearRange] intValue] || ([[[self.tradeMonth objectAtIndex:i] substringWithRange:yearRange] isEqualToString:[[self.tradeMonth objectAtIndex:j] substringWithRange:yearRange]] && [[[self.tradeMonth objectAtIndex:i] substringWithRange:monthRange] intValue] < [[[self.tradeMonth objectAtIndex:j] substringWithRange:monthRange] intValue])) {
                    str = [self.tradeMonth objectAtIndex:i];
                    [self.tradeMonth replaceObjectAtIndex:i withObject:[self.tradeMonth objectAtIndex:j]];
                    [self.tradeMonth replaceObjectAtIndex:j withObject:str];
                }
            }
        }
    }
}
//计算tableview中需要的数据
- (void)createAllArray {
    self.dateArray = [[NSMutableArray alloc] init];
    self.labelArray = [[NSMutableArray alloc] init];
    self.amountArray = [[NSMutableArray alloc] init];
    self.typeArray = [[NSMutableArray alloc] init];
    self.remarkArray = [[NSMutableArray alloc] init];
    for(int m = 0;m < [self.tradeMonth count]; m++){
        NSMutableArray *dateArray_ = [[NSMutableArray alloc] init];
        NSMutableArray *labelArray_ = [[NSMutableArray alloc] init];
        NSMutableArray *amountArray_ = [[NSMutableArray alloc] init];
        NSMutableArray *typeArray_ = [[NSMutableArray alloc] init];
        NSMutableArray *remarkArray_ = [[NSMutableArray alloc] init];
        for (int i = 0; i < [self.tradeDate count]; i++) {
            if ([[[self.tradeDate objectAtIndex:i]substringWithRange:NSMakeRange(0, 7)] isEqualToString:[self.tradeMonth objectAtIndex:m]]) {
                [dateArray_ addObject:[self.tradeDate objectAtIndex:i]];
            }
        }
        if ([dateArray_ count] >= 2) {
            for (int i = 0; i < [dateArray_ count] - 1; i++) {
                for (int j = i + 1; j < [dateArray_ count]; j++) {
                    if ([[[dateArray_ objectAtIndex:i] substringWithRange:NSMakeRange(0, 4)] intValue] < [[[dateArray_ objectAtIndex:j] substringWithRange:NSMakeRange(0, 4)] intValue]
                        || ([[[dateArray_ objectAtIndex:i] substringWithRange:NSMakeRange(0, 4)] isEqualToString:[[dateArray_ objectAtIndex:j] substringWithRange:NSMakeRange(0, 4)]] && [[[dateArray_ objectAtIndex:i] substringWithRange:NSMakeRange(5, 2)] intValue] < [[[dateArray_ objectAtIndex:j] substringWithRange:NSMakeRange(5, 2)] intValue])
                        || ([[[dateArray_ objectAtIndex:i] substringWithRange:NSMakeRange(0, 8)] isEqualToString:[[dateArray_ objectAtIndex:j] substringWithRange:NSMakeRange(0, 8)]] && [[[dateArray_ objectAtIndex:i] substringWithRange:NSMakeRange(8, 2)] intValue] < [[[dateArray_ objectAtIndex:j] substringWithRange:NSMakeRange(8, 2)] intValue])) {
                        NSString *str = [dateArray_ objectAtIndex:i];
                        [dateArray_ replaceObjectAtIndex:i withObject:[dateArray_ objectAtIndex:j]];
                        [dateArray_ replaceObjectAtIndex:j withObject:str];
                    }
                }
            }
        }
        for (int i = 0; i < [dateArray_ count]; i++) {
            NSArray *label = [[DataBase sharedDataBase] getInfoWithCommand:@"select * from record where account = ? and date = ?" andCondition1:self.accountName andCondition2:[dateArray_ objectAtIndex:i] andColumn:@"label"];
            NSArray *amount = [[DataBase sharedDataBase] getInfoWithCommand:@"select * from record where account = ? and date = ?" andCondition1:self.accountName andCondition2:[dateArray_ objectAtIndex:i] andColumn:@"amount"];
            NSArray *type = [[DataBase sharedDataBase] getInfoWithCommand:@"select * from record where account = ? and date = ?" andCondition1:self.accountName andCondition2:[dateArray_ objectAtIndex:i] andColumn:@"type"];
            NSArray *remark = [[DataBase sharedDataBase] getInfoWithCommand:@"select * from record where account = ? and date = ?" andCondition1:self.accountName andCondition2:[dateArray_ objectAtIndex:i] andColumn:@"remark"];
            for (int j = 0; j < [label count]; j++) {
                [labelArray_ addObject:[label objectAtIndex:j]];
                [amountArray_ addObject:[amount objectAtIndex:j]];
                [typeArray_ addObject:[type objectAtIndex:j]];
                [remarkArray_ addObject:[remark objectAtIndex:j]];
            }
        }
        [self.dateArray addObject:dateArray_];
        [self.labelArray addObject:labelArray_];
        [self.amountArray addObject:amountArray_];
        [self.typeArray addObject:typeArray_];
        [self.remarkArray addObject:remarkArray_];
    }
}

#pragma mark - UITableViewDataSource
//返回每组行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int recordNum = 0;
    for (int i = 0; i < [self.tradeDate count]; i++) {
        if ([[[self.tradeDate objectAtIndex:i]substringWithRange:NSMakeRange(0, 7)]isEqualToString:[self.tradeMonth objectAtIndex:section]]) {
            recordNum++;
        }
    }
    return recordNum;
}

//返回每行单元格
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%ld%ld", indexPath.section, indexPath.row];//以indexPath来唯一确定cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 7, 36, 36)];
        dateLabel.layer.cornerRadius = 18;
        [dateLabel setText:[[[self.dateArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] substringWithRange:NSMakeRange(8, 2)]];
        [cell addSubview:dateLabel];

        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(50, 7, 36, 36)];
        imageView.layer.cornerRadius = 18;
        [imageView setImage:[UIImage imageNamed:[[self.labelArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]]];
        imageView.backgroundColor = MAIN_COLOR;
        [cell addSubview:imageView];

        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(90, 15, 60, 20)];
        [label setText:[[self.labelArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
        [cell addSubview:label];
        [label sizeToFit];

        UILabel *remarkLabel = [[UILabel alloc]initWithFrame:CGRectMake(90 + label.bounds.size.width + 10, 17, 80, 16)];
        [remarkLabel setText:[[self.remarkArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
        [cell addSubview:remarkLabel];
        [remarkLabel sizeToFit];

        UILabel *amountLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 140, 15, 120, 20)];
        NSString *amountOutput = [[NSString alloc] init];
        if ([[[self.typeArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]isEqualToString:@"支出"]) {
            amountOutput = [@"-" stringByAppendingString:[[self.amountArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
        } else if ([[[self.typeArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]isEqualToString:@"收入"]) {
            amountOutput = [@"+" stringByAppendingString:[[self.amountArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
        }
        [amountLabel setText:amountOutput];
        amountLabel.textAlignment = NSTextAlignmentRight;
        [cell addSubview:amountLabel];
    }
    return cell;
}

// 返回分组数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.tradeMonth count];
}

#pragma mark - UITableViewDelegate
// 返回每个 Cell 的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

// 返回每个 Section 的 HeaderView 高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 60;
}

// 返回每个 Section FooterView 的高度
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

// 返回 Section 自定义的 HeaderView
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor lightGrayColor];
    //年
    UILabel *yearLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, 80, 20)];
    [yearLabel setText:[[[self.tradeMonth objectAtIndex:section]substringWithRange:NSMakeRange(0, 4)]stringByAppendingString:@"年"]];
    [yearLabel setTextColor:[UIColor grayColor]];
    [yearLabel setFont:[UIFont systemFontOfSize:12]];
    [yearLabel sizeToFit];
    [headerView addSubview:yearLabel];
    //月份
    UILabel *monthLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 20, 80, 20)];
    [monthLabel setText:[[[self.tradeMonth objectAtIndex:section]substringWithRange:NSMakeRange(5, 2)]stringByAppendingString:@"月"]];
    [monthLabel setTextColor:[UIColor blackColor]];
    [monthLabel setFont:[UIFont systemFontOfSize:18]];
    [monthLabel sizeToFit];
    [headerView addSubview:monthLabel];

    return headerView;
}

// 返回 Section 自定义的 FooterView
- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] init];
    return footerView;
}

// 返回当前选中的 Row 是否高亮，一般在选择的时候才高亮
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

@end
