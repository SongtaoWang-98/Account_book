//
//  ABAddBorrowRecordViewController.m
//  Account_book
//
//  Created by 王松涛 on 2020/7/31.
//  Copyright © 2020 Songtao Wang. All rights reserved.
//

#import "ABAddBorrowRecordViewController.h"
#import "Definition.h"
#import "DataBase.h"

@interface ABAddBorrowRecordViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, copy) NSString *operation;
@property (nonatomic, copy) NSString *type;
//导航栏元素
@property (nonatomic, strong, readwrite) UIView *naviView;
@property (nonatomic, strong, readwrite) UIButton *backBtn;
@property (nonatomic, strong, readwrite) UIButton *finishBtn;
@property (nonatomic, strong, readwrite) UILabel *titleLabel;
@property (nonatomic, strong, readwrite) UIView *infoView;
@property (strong, nonatomic) UIView *shadeView;
//添加日期
@property (strong, nonatomic) UIButton *btnDate;//日期按钮
@property (strong, nonatomic) UIView *dateSelectView;//日期选择界面
@property (strong, nonatomic) UIButton *dateConfirm;//日期选择确认按钮
@property (strong, nonatomic) UIButton *dateCancel;//日期选择取消按钮
@property (strong, nonatomic) UIDatePicker *datePicker;//日期选择控件
@property (nonatomic, strong) NSDate *dateSelected;//当前时间选择
@property (nonatomic, strong) NSDateFormatter *dateFormatter;//时间格式化
@property (nonatomic, copy) NSString *dateSelectedString;//当前时间字符串
//选择账户
@property (strong, nonatomic) UIButton *btnPayment;
@property (nonatomic, copy) NSString *account;//账户
@property (strong, nonatomic) UIView *accountSelectView;//账户选择界面
@property (strong, nonatomic) UITableView *accountTableView;//账户选择table
@property (strong, nonatomic) UIButton *accountClose;//账户选择关闭按钮
//
@property (strong, nonatomic) UITextField *amountField;
@property (strong, nonatomic) UITextField *nameField;

@end

@implementation ABAddBorrowRecordViewController
- (instancetype)initWithType:(NSString *)type andOperation:(NSString *)operation {
    self = [super init];
    if (self) {
        self.operation = operation;
        self.type = type;
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
    self.finishBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [self.finishBtn setBackgroundColor:[UIColor blackColor]];
    [self.finishBtn addTarget:self action:@selector(finishRecord) forControlEvents:UIControlEventTouchUpInside];
    [self.naviView addSubview:self.finishBtn];
    self.titleLabel = [[UILabel alloc] init];
    [self.titleLabel setFont:[UIFont systemFontOfSize:20]];
    [self.naviView addSubview:self.titleLabel];
    self.infoView = [[UIView alloc] init];
    [self.view addSubview:self.infoView];
    //时间格式化
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd"];
    self.dateSelected = [NSDate date];
    self.dateSelectedString = [self.dateFormatter stringFromDate:self.dateSelected];
    self.account = @"";
}

- (void)viewWillAppear:(BOOL)animated {
    [self.naviView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, STATUS_HEIGHT + NAVI_HEIGHT)];
    [self.infoView setFrame:CGRectMake(0, STATUS_HEIGHT + NAVI_HEIGHT, SCREEN_WIDTH, 280)];
    [self showButtonsAndLabels];
}

- (void)showButtonsAndLabels {
    [self.backBtn setCenter:CGPointMake(40, STATUS_HEIGHT + NAVI_HEIGHT / 2)];
    [self.finishBtn setCenter:CGPointMake(SCREEN_WIDTH - 40, STATUS_HEIGHT + NAVI_HEIGHT / 2)];
    UITapGestureRecognizer *centerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.infoView addGestureRecognizer:centerTap];
    NSArray *labels = [[NSArray alloc] init];
    if ([self.operation isEqualToString:@"添加"]) {
        [self.titleLabel setText:[@"新建" stringByAppendingString:self.type]];
        labels = [NSArray arrayWithObjects:@"对方名称:", [self.type stringByAppendingString:@"金额:"], [self.type stringByAppendingString:@"账户:"], [self.type stringByAppendingString:@"时间:"], nil];
    } else {
        if ([self.type isEqualToString:@"借入"]) {
            [self.titleLabel setText:@"还款"];
            labels = [NSArray arrayWithObjects:@"对方名称:", [@"还款" stringByAppendingString:@"金额:"], [@"还款" stringByAppendingString:@"账户:"], [@"还款" stringByAppendingString:@"时间:"], nil];
        } else {
            [self.titleLabel setText:@"收款"];
            labels = [NSArray arrayWithObjects:@"对方名称:", [@"收款" stringByAppendingString:@"金额:"], [@"收款" stringByAppendingString:@"账户:"], [@"收款" stringByAppendingString:@"时间:"], nil];
        }
    }
    [self.titleLabel sizeToFit];
    [self.titleLabel setCenter:CGPointMake(SCREEN_WIDTH / 2, STATUS_HEIGHT + NAVI_HEIGHT / 2)];
    for (int i = 0; i < 4; i++) {
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(20, 70 * i + 69.5, SCREEN_WIDTH - 20, 0.5)];
        [line setBackgroundColor:[UIColor lightGrayColor]];
        [self.infoView addSubview:line];
        UILabel *label = [[UILabel alloc] init];
        [label setText:[labels objectAtIndex:i]];
        [label sizeToFit];
        [label setCenter:CGPointMake(40, 70 * i + 35)];
        [label setTextColor:[UIColor blackColor]];
        [self.infoView addSubview:label];
    }
    self.nameField = [[UITextField alloc] initWithFrame:CGRectMake(150, 10, 200, 50)];
    [self.infoView addSubview:self.nameField];
    self.nameField.placeholder = @"输入对方名称";

    self.amountField = [[UITextField alloc] initWithFrame:CGRectMake(150, 80, 200, 50)];
    [self.infoView addSubview:self.amountField];
    self.amountField.placeholder = @"输入金额";

    self.btnDate = [[UIButton alloc]initWithFrame:CGRectMake(150, 220, 100, 50)];
    [self.infoView addSubview:self.btnDate];
    [self.btnDate setTitle:@"今天" forState:UIControlStateNormal];
    [self.btnDate setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.btnDate setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [self.btnDate setBackgroundColor:[UIColor lightGrayColor]];
    [self.btnDate addTarget:self action:@selector(dateSelectPop) forControlEvents:UIControlEventTouchUpInside];

    self.btnPayment = [[UIButton alloc]initWithFrame:CGRectMake(170, 150, 50, 50)];
    [self.infoView addSubview:self.btnPayment];
    [self.btnPayment setImage:[UIImage imageNamed:@"notselected"] forState:UIControlStateNormal];
    [self.btnPayment setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.btnPayment.layer.cornerRadius = 25;
    self.btnPayment.layer.borderWidth = 1.5;
    [self.btnPayment setBackgroundColor:[UIColor lightGrayColor]];
    [self.btnPayment addTarget:self action:@selector(accountSelectViewPop) forControlEvents:UIControlEventTouchUpInside];
}

- (void)returnToLastView {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)finishRecord {
    if (![self.nameField.text length]) {
        [self.nameField setBackgroundColor:[UIColor colorWithRed:220 / 255.0 green:20 / 255.0 blue:60 / 255.0 alpha:1]];
        [UIView animateWithDuration:0.3f animations:^{
            [self.nameField setBackgroundColor:[UIColor colorWithRed:220 / 255.0 green:20 / 255.0 blue:60 / 255.0 alpha:0]];
        } completion:^(BOOL finished) {
        }];
    } else if (![self isPureFloat:self.amountField.text]) {
        [self.amountField setBackgroundColor:[UIColor colorWithRed:220 / 255.0 green:20 / 255.0 blue:60 / 255.0 alpha:1]];
        [UIView animateWithDuration:0.3f animations:^{
            [self.amountField setBackgroundColor:[UIColor colorWithRed:220 / 255.0 green:20 / 255.0 blue:60 / 255.0 alpha:0]];
        } completion:^(BOOL finished) {
        }];
    } else if (![self.account length]) {
        [self.btnPayment setBackgroundColor:[UIColor colorWithRed:220 / 255.0 green:20 / 255.0 blue:60 / 255.0 alpha:1]];
        [UIView animateWithDuration:0.3f animations:^{
            [self.btnPayment setBackgroundColor:[UIColor colorWithRed:220 / 255.0 green:20 / 255.0 blue:60 / 255.0 alpha:0]];
        } completion:^(BOOL finished) {
        }];
    } else {
        if([self.type isEqualToString:@"借入"]){
            if([self.operation isEqualToString:@"添加"]){
            //新增一笔借入款，添加一条转入record，添加一条borrow，更新account与借入信息
            }
            else{//还一笔借入款，添加一条转出record，更新borrow，账户
                
            }
        }
        if([self.type isEqualToString:@"借出"]){
            if([self.operation isEqualToString:@"添加"]){
            //新增一笔借出款，添加一条转出record，添加一条borrow，更新账户与借出账户信息
            }
            else{//还一笔借出款，添加一条转入record，
                
            }
        }
        if([self.type isEqualToString:@"报销"]){
            if([self.operation isEqualToString:@"添加"]){
            //新增一笔待报销款，添加一条收入record，添加一条borrow，更新报销信息
            }
            else{//收到一笔报销款，添加一条转入record，更新borrow，更新首款账户与报销账户
                
            }
        }
        [self returnToLastView];
    }
}

- (void)hideKeyboard {
    [self.amountField endEditing:YES];
    [self.nameField endEditing:YES];
}

- (BOOL)isPureFloat:(NSString *)string {
    NSScanner *scan = [NSScanner scannerWithString:string];
    float val;
    return [scan scanFloat:&val] && [scan isAtEnd];
}

#pragma mark - 日期选择器
- (void)createDateSelectView {
    self.dateSelectView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - DATESELECT_WIDTH / 2, SCREEN_HEIGHT, DATESELECT_WIDTH, DATESELECT_HEIGHT)];
    self.dateSelectView.backgroundColor = [UIColor whiteColor];
    self.dateSelectView.layer.borderColor = [UIColor blackColor].CGColor;
    self.dateSelectView.layer.borderWidth = 0.5;
    self.dateSelectView.layer.cornerRadius = 10;

    UILabel *dateSelectLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 40)];
    [self.dateSelectView addSubview:dateSelectLabel];
    dateSelectLabel.textAlignment = NSTextAlignmentCenter;
    [dateSelectLabel setCenter:CGPointMake(DATESELECT_WIDTH / 2, 25)];
    [dateSelectLabel setText:@"选择日期"];

    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, DATESELECT_WIDTH, 280)];
    [self.datePicker setCenter:CGPointMake(DATESELECT_WIDTH / 2, DATESELECT_HEIGHT / 2)];
    self.datePicker.backgroundColor = [UIColor lightGrayColor];
    self.datePicker.locale = [NSLocale localeWithLocaleIdentifier:@"zh-Hans"];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    [self.dateSelectView addSubview:self.datePicker];

    self.dateConfirm = [[UIButton alloc] initWithFrame:CGRectMake(0, DATESELECT_HEIGHT - 50, DATESELECT_WIDTH / 2, 50)];
    [self.dateConfirm setTag:1001];
    self.dateConfirm.backgroundColor = [UIColor whiteColor];
    [self.dateConfirm setTitle:@"确认" forState:UIControlStateNormal];
    [self.dateConfirm setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.dateConfirm setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [self.dateSelectView addSubview:self.dateConfirm];
    self.dateConfirm.layer.cornerRadius = 10;
    [self.dateConfirm addTarget:self action:@selector(dateSelectHide:) forControlEvents:UIControlEventTouchUpInside];

    self.dateCancel = [[UIButton alloc] initWithFrame:CGRectMake(DATESELECT_WIDTH / 2, DATESELECT_HEIGHT - 50, DATESELECT_WIDTH / 2, 50)];
    [self.dateCancel setTag:1002];
    self.dateCancel.backgroundColor = [UIColor whiteColor];
    [self.dateCancel setTitle:@"取消" forState:UIControlStateNormal];
    [self.dateCancel setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.dateCancel setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [self.dateSelectView addSubview:self.dateCancel];
    self.dateCancel.layer.cornerRadius = 10;
    [self.dateCancel addTarget:self action:@selector(dateSelectHide:) forControlEvents:UIControlEventTouchUpInside];
}

//日期选择界面出现
- (void)dateSelectPop {
    [self hideKeyboard];
    if (!self.shadeView) {
        self.shadeView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        self.shadeView.backgroundColor = [UIColor colorWithRed:(33 / 255.0)  green:(33 / 255.0)  blue:(33 / 255.0) alpha:0];
        [[[[UIApplication sharedApplication] windows] objectAtIndex:0] addSubview:self.shadeView];
    }
    if (!self.dateSelectView) {
        [self createDateSelectView];
        [[[[UIApplication sharedApplication] windows] objectAtIndex:0] addSubview:self.dateSelectView];
    }
    [UIView animateWithDuration:0.3f animations:^{
        [self.dateSelectView setFrame:CGRectMake(SCREEN_WIDTH / 2 - DATESELECT_WIDTH / 2, SCREEN_HEIGHT / 2 - DATESELECT_HEIGHT / 2, DATESELECT_WIDTH, DATESELECT_HEIGHT)];
        self.shadeView.backgroundColor = [UIColor colorWithRed:(33 / 255.0)  green:(33 / 255.0)  blue:(33 / 255.0) alpha:0.2];
    } completion:^(BOOL finished) {
    }];
}

//日期选择界面消失
- (void)dateSelectHide:(UIButton *)sender {
    [UIView animateWithDuration:0.3f animations:^{
        [self.dateSelectView setFrame:CGRectMake(SCREEN_WIDTH / 2 - DATESELECT_WIDTH / 2, SCREEN_HEIGHT, DATESELECT_WIDTH, DATESELECT_HEIGHT)];
        self.shadeView.backgroundColor = [UIColor colorWithRed:(33 / 255.0)  green:(33 / 255.0)  blue:(33 / 255.0) alpha:0];
    } completion:^(BOOL finished) {
        [self.shadeView removeFromSuperview];
        self.shadeView = nil;
        [self.dateSelectView removeFromSuperview];
        self.dateSelectView = nil;
    }];
    //确认时间并进行计算
    if (sender.tag == 1001) {
        self.dateSelected = self.datePicker.date;
        self.dateSelectedString = [self.dateFormatter stringFromDate:self.dateSelected];
        [self.btnDate setTitle:self.dateSelectedString forState:UIControlStateNormal];
        [self.btnDate setTitle:[self calculateWithDate:self.dateSelected] forState:UIControlStateNormal];
    }
}

#pragma mark - 日期计算逻辑
//计算两个时间差
- (NSString *)calculateWithDate:(NSDate *)date {
    NSString *result = self.dateSelectedString;
    // 创建日历
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit type = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    // 利用日历对象比较两个时间的差值
    NSDateComponents *cmps = [calendar components:type fromDate:[NSDate date] toDate:date options:0];
    // 输出结果
    if (cmps.year == 0 && cmps.month == 0) {
        if (cmps.day == 0 && cmps.hour == 0) {
            result = @"今天";
        } else if (cmps.day == 0 && cmps.hour != 0) {
            result = @"明天";
        } else if (cmps.day == 1) {
            result = @"后天";
        } else if (cmps.day == 2) {
            result = @"大后天";
        } else if (cmps.day == -1) {
            result = @"昨天";
        } else if (cmps.day == -2) {
            result = @"前天";
        } else if (cmps.day == -3) {
            result = @"大前天";
        }
    }
    return result;
}

#pragma mark - 账户选择器
- (void)createAccountSelectView {
    self.accountSelectView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - ACCOUNTSELECT_WIDTH / 2, SCREEN_HEIGHT, ACCOUNTSELECT_WIDTH, ACCOUNTSELECT_HEIGHT)];
    self.accountSelectView.backgroundColor = [UIColor whiteColor];
    self.accountSelectView.layer.borderColor = [UIColor blackColor].CGColor;
    self.accountSelectView.layer.borderWidth = 0.5;
    self.accountSelectView.layer.cornerRadius = 10;

    UILabel *accountSelectLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 40)];
    [self.accountSelectView addSubview:accountSelectLabel];
    accountSelectLabel.textAlignment = NSTextAlignmentCenter;
    [accountSelectLabel setCenter:CGPointMake(ACCOUNTSELECT_WIDTH / 2, 25)];
    [accountSelectLabel setText:@"选择账户"];

    self.accountClose = [[UIButton alloc] initWithFrame:CGRectMake(ACCOUNTSELECT_WIDTH - 40, 15, 20, 20)];
    [self.accountClose setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [self.accountSelectView addSubview:self.accountClose];
    [self.accountClose addTarget:self action:@selector(accountSelectViewHide) forControlEvents:UIControlEventTouchUpInside];

    self.accountTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 60, ACCOUNTSELECT_WIDTH, 320)];
    self.accountTableView.delegate = self;
    self.accountTableView.dataSource = self;
    [self.accountSelectView addSubview:self.accountTableView];
}

- (void)accountSelectViewPop {
    [self hideKeyboard];
    if (!self.shadeView) {
        self.shadeView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        self.shadeView.backgroundColor = [UIColor colorWithRed:(33 / 255.0)  green:(33 / 255.0)  blue:(33 / 255.0) alpha:0];
        [[[[UIApplication sharedApplication] windows] objectAtIndex:0] addSubview:self.shadeView];
    }
    if (!self.accountSelectView) {
        [self createAccountSelectView];
        [[[[UIApplication sharedApplication] windows] objectAtIndex:0] addSubview:self.accountSelectView];
    }
    [UIView animateWithDuration:0.3f animations:^{
        [self.accountSelectView setFrame:CGRectMake(SCREEN_WIDTH / 2 - ACCOUNTSELECT_WIDTH / 2, SCREEN_HEIGHT / 2 - ACCOUNTSELECT_HEIGHT / 2, ACCOUNTSELECT_WIDTH, ACCOUNTSELECT_HEIGHT)];
        self.shadeView.backgroundColor = [UIColor colorWithRed:(33 / 255.0)  green:(33 / 255.0)  blue:(33 / 255.0) alpha:0.2];
    } completion:^(BOOL finished) {
    }];
}

- (void)accountSelectViewHide {
    [UIView animateWithDuration:0.3f animations:^{
        [self.accountSelectView setFrame:CGRectMake(SCREEN_WIDTH / 2 - ACCOUNTSELECT_WIDTH / 2, SCREEN_HEIGHT, ACCOUNTSELECT_WIDTH, ACCOUNTSELECT_HEIGHT)];
        self.shadeView.backgroundColor = [UIColor colorWithRed:(33 / 255.0)  green:(33 / 255.0)  blue:(33 / 255.0) alpha:0];
    } completion:^(BOOL finished) {
        [self.shadeView removeFromSuperview];
        self.shadeView = nil;
        [self.accountSelectView removeFromSuperview];
        self.accountSelectView = nil;
    }];
}

#pragma mark - UITableViewDataSource
//返回每组行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger countPutong = [[DataBase sharedDataBase] getNumberWithCommand:@"select count(*) from account where accounttype = '普通账户'"];
    NSInteger countFuzhai = [[DataBase sharedDataBase] getNumberWithCommand:@"select count(*) from account where accounttype = '信用账户'"];
    switch (section) {
        case 0:
            return countPutong;
            break;
        case 1:
            return countFuzhai;
            break;
        default:
            return 0;
            break;
    }
}

//返回每行单元格
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%ld%ld", indexPath.section, indexPath.row];//以indexPath来唯一确定cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    NSMutableArray *nameArray0 = [[DataBase sharedDataBase] getInfoWithCommand:@"select * from account where accounttype = '普通账户'" andColumn:@"accountname"];
    NSMutableArray *moneyArray0 = [[DataBase sharedDataBase] getInfoWithCommand:@"select * from account where accounttype = '普通账户'" andColumn:@"money"];
    NSMutableArray *nameArray1 = [[DataBase sharedDataBase] getInfoWithCommand:@"select * from account where accounttype = '信用账户'" andColumn:@"accountname"];
    NSMutableArray *moneyArray1 = [[DataBase sharedDataBase] getInfoWithCommand:@"select * from account where accounttype = '信用账户'" andColumn:@"money"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        NSString *text;
        NSString *money;
        switch (indexPath.section) {
            case 0:
                text = [nameArray0 objectAtIndex:indexPath.row];
                money = [moneyArray0 objectAtIndex:indexPath.row];
                break;
            case 1:
                text = [nameArray1 objectAtIndex:indexPath.row];
                money = [moneyArray1 objectAtIndex:indexPath.row];
                break;
            default:
                break;
        }
        UILabel *labelCount = [[UILabel alloc] initWithFrame:CGRectMake(55, 16, 80, 20)];
        [cell addSubview:labelCount];
        [labelCount setText:text];
        labelCount.font = [UIFont systemFontOfSize:18];
        [labelCount sizeToFit];

        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 7, 36, 36)];
        [imageView setImage:[UIImage imageNamed:text]];
        [cell addSubview:imageView];

        UILabel *labelMoney = [[UILabel alloc] initWithFrame:CGRectMake(cell.bounds.size.width - 120, 17, 80, 16)];
        [labelMoney setText:money];
        [cell addSubview:labelMoney];
        labelMoney.font = [UIFont systemFontOfSize:16];
        [labelMoney setTextColor:[UIColor grayColor]];
        [labelMoney sizeToFit];
    }
    return cell;
}

// 返回分组数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

// 返回每组头标题
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"普通账户";
            break;
        case 1:
            return @"信用账户";
            break;
        default:
            return @"";
            break;
    }
}

#pragma mark - UITableViewDelegate

// 返回每个 Cell 的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

// 返回每个 Section 的 HeaderView 高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

//// Cell 被选中的回调
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *nameArray0 = [[DataBase sharedDataBase] getInfoWithCommand:@"select accountname from account where accounttype = '普通账户'" andColumn:@"accountname"];
    NSMutableArray *nameArray1 = [[DataBase sharedDataBase] getInfoWithCommand:@"select accountname from account where accounttype = '信用账户'" andColumn:@"accountname"];
    NSString *text;
    switch (indexPath.section) {
        case 0:
            text = [nameArray0 objectAtIndex:indexPath.row];
            break;
        case 1:
            text = [nameArray1 objectAtIndex:indexPath.row];
            break;
        default:
            break;
    }
    self.account = text;
    [self.btnPayment setImage:[UIImage imageNamed:self.account] forState:UIControlStateNormal];
    [self accountSelectViewHide];
}

@end
