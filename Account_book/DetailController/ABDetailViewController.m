//
//  ABDetailViewController.m
//  Account_book
//
//  Created by 王松涛 on 2020/6/8.
//  Copyright © 2020 Songtao Wang. All rights reserved.
//

#import "ABDetailViewController.h"
#import "Definition.h"
#import "DataBase.h"
#import "ABEachDetailViewController.h"

@interface ABDetailViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong, readwrite) UITableView *tableView;
@property (nonatomic, strong, readwrite) UIView *titleView;
@property (nonatomic, strong, readwrite) UIButton *monthButton;
@property (nonatomic, strong, readwrite) UIView *monthSelectView;
@property (nonatomic, strong, readwrite) UIDatePicker *monthPicker;
@property (nonatomic, strong, readwrite) UIDatePicker *yearPicker;
@property (nonatomic, strong, readwrite) UIButton *monthConfirm;
@property (nonatomic, strong, readwrite) UIButton *monthCancel;
@property (nonatomic, strong, readwrite) UIView *shadeView;
@property (nonatomic, strong, readwrite) UIButton *btnNextMonth;
@property (nonatomic, strong, readwrite) UIButton *btnLastMonth;

@property (nonatomic, strong) NSDate *monthSelected;//当前月份选择
@property (nonatomic, strong) NSDate *yearSelected;//当前月份选择
@property (nonatomic, strong) NSDateFormatter *dateFormatter;//年月日时间格式化
@property (nonatomic, strong) NSDateFormatter *monthFormatter;//月时间格式化
@property (nonatomic, strong) NSDateFormatter *yearFormatter;//年时间格式化
@property (nonatomic, copy) NSString *monthSelectedString;//当前时间字符串

@property (nonatomic, strong) NSMutableArray *dateSelected;//当前月有记录的日期
@property (nonatomic, strong, readwrite) UILabel *incomeAmountLabel;
@property (nonatomic, strong, readwrite) UILabel *expenseAmountLabel;
@property (nonatomic, strong, readwrite) UILabel *surplusAmountLabel;

@property (nonatomic, strong, readwrite) UILabel *incomeLabel;//收支结余label
@property (nonatomic, strong, readwrite) UILabel *expenseLabel;
@property (nonatomic, strong, readwrite) UILabel *surplusLabel;

@property (nonatomic, strong) NSMutableArray *idArray;//时间数组的数组
@property (nonatomic, strong) NSMutableArray *labelArray;
@property (nonatomic, strong) NSMutableArray *amountArray;
@property (nonatomic, strong) NSMutableArray *accountArray;
@property (nonatomic, strong) NSMutableArray *typeArray;
@property (nonatomic, strong) NSMutableArray *remarkArray;

@end

@implementation ABDetailViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.tabBarItem.title = @"明细";
        self.tabBarItem.image = [UIImage imageNamed:@"icon.bundle/message_normal@2x.png"];
        self.tabBarItem.selectedImage = [[UIImage imageNamed:@"icon.bundle/message_highlight@2x.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//        NSDictionary *dict = [NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName];
//        [self.tabBarItem setTitleTextAttributes:dict forState:UIControlStateSelected];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //时间格式化
    self.yearFormatter = [[NSDateFormatter alloc] init];
    [self.yearFormatter setDateFormat:@"yyyy"];
    self.monthFormatter = [[NSDateFormatter alloc] init];
    [self.monthFormatter setDateFormat:@"MM"];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd"];

    //自定义导航栏
    self.titleView = [[UIView alloc] init];
    self.titleView.backgroundColor = MAIN_COLOR;
    [self.view addSubview:self.titleView];

    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) style:(UITableViewStyleGrouped)];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    self.monthButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 130, 40)];
    [self.titleView addSubview:self.monthButton];
    [self.monthButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.monthButton.layer.borderWidth = 1;
    self.monthButton.layer.cornerRadius = 10;
    [self.monthButton addTarget:self action:@selector(monthSelectPop) forControlEvents:UIControlEventTouchUpInside];
    
    self.btnLastMonth = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [self.titleView addSubview:self.btnLastMonth];
    self.btnLastMonth.tag = 3000;
    self.btnLastMonth.backgroundColor = [UIColor blueColor];
    [self.btnLastMonth addTarget:self action:@selector(lastOrNextMonth:) forControlEvents:UIControlEventTouchUpInside];
    
    self.btnNextMonth = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [self.titleView addSubview:self.btnNextMonth];
    self.btnNextMonth.tag = 3001;
    self.btnNextMonth.backgroundColor = [UIColor blueColor];
    [self.btnNextMonth addTarget:self action:@selector(lastOrNextMonth:) forControlEvents:UIControlEventTouchUpInside];
    
    self.incomeLabel = [[UILabel alloc] init];
    self.incomeLabel.text = @"收入";
    [self.titleView addSubview:self.incomeLabel];
    [self.incomeLabel sizeToFit];
    self.expenseLabel = [[UILabel alloc] init];
    self.expenseLabel.text = @"支出";
    [self.titleView addSubview:self.expenseLabel];
    [self.expenseLabel sizeToFit];
    self.surplusLabel = [[UILabel alloc] init];
    self.surplusLabel.text = @"结余";
    [self.titleView addSubview:self.surplusLabel];
    [self.surplusLabel sizeToFit];
    
    self.incomeAmountLabel = [[UILabel alloc] init];
    [self.titleView addSubview:self.incomeAmountLabel];
    self.expenseAmountLabel = [[UILabel alloc] init];
    [self.titleView addSubview:self.expenseAmountLabel];
    self.surplusAmountLabel = [[UILabel alloc] init];
    [self.titleView addSubview:self.surplusAmountLabel];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.titleView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, DETAILVIEW_HEIGHT)];
    [self.tableView setFrame:CGRectMake(0, DETAILVIEW_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - DETAILVIEW_HEIGHT)];
    self.navigationController.navigationBarHidden = YES;
    [self showButtonsAndLabels];
    [self selectCurrentMonth];
    [self calculateMoney];
    [self createAllArray];
    [self.tableView reloadData];
}

- (void)showButtonsAndLabels{
    self.monthSelected = [NSDate date];
    self.yearSelected = [NSDate date];
    self.monthSelectedString = [[[[self.yearFormatter stringFromDate:self.yearSelected] stringByAppendingString:@"年"] stringByAppendingString:[self.monthFormatter stringFromDate:self.monthSelected]] stringByAppendingString:@"月"];
    
    self.monthButton.center = CGPointMake(SCREEN_WIDTH / 2, STATUS_HEIGHT + NAVI_HEIGHT);
    [self.monthButton setTitle:self.monthSelectedString forState:UIControlStateNormal];
    [self.btnLastMonth setFrame:CGRectMake(SCREEN_WIDTH / 2 - 110, STATUS_HEIGHT + NAVI_HEIGHT - 20, 40, 40)];
    [self.btnNextMonth setFrame:CGRectMake(SCREEN_WIDTH / 2 + 70, STATUS_HEIGHT + NAVI_HEIGHT - 20, 40, 40)];
    
    //显示收支数据label
    self.incomeLabel.center = CGPointMake(SCREEN_WIDTH / 6, STATUS_HEIGHT + NAVI_HEIGHT + 50);
    self.expenseLabel.center = CGPointMake(SCREEN_WIDTH / 2, STATUS_HEIGHT + NAVI_HEIGHT + 50);
    self.surplusLabel.center = CGPointMake(SCREEN_WIDTH / 6 * 5, STATUS_HEIGHT + NAVI_HEIGHT + 50);
}
#pragma mark - 月份选择
- (void)createMonthSelectView {
    self.monthSelectView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, MONTHSELECT_HEIGHT)];
    self.monthSelectView.backgroundColor = [UIColor whiteColor];
    self.monthSelectView.layer.borderWidth = 0.5;

    UILabel *monthSelectLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 40)];
    [self.monthSelectView addSubview:monthSelectLabel];
    monthSelectLabel.textAlignment = NSTextAlignmentCenter;
    [monthSelectLabel setCenter:CGPointMake(SCREEN_WIDTH / 2, 20)];
    [monthSelectLabel setText:@"选择月份"];
    //自定义datepicker 显示年月
    UIView *monthPickerView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 + 30, 40, 60, 260)];
    [self.monthSelectView addSubview:monthPickerView];
    monthPickerView.layer.masksToBounds = YES;

    self.monthPicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(-170, 0, 400, 260)];
    self.monthPicker.backgroundColor = [UIColor whiteColor];
    self.monthPicker.locale = [NSLocale localeWithLocaleIdentifier:@"zh-Hans"];
    self.monthPicker.datePickerMode = UIDatePickerModeDate;
    [monthPickerView addSubview:self.monthPicker];

    UIView *yearPickerView = [[UIView alloc] initWithFrame:CGRectMake(0, 40, SCREEN_WIDTH / 2, 260)];
    [self.monthSelectView addSubview:yearPickerView];
    yearPickerView.layer.masksToBounds = YES;

    self.yearPicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(35, 0, SCREEN_WIDTH, 260)];
    self.yearPicker.backgroundColor = [UIColor whiteColor];
    self.yearPicker.locale = [NSLocale localeWithLocaleIdentifier:@"zh-Hans"];
    self.yearPicker.datePickerMode = UIDatePickerModeDate;
    [yearPickerView addSubview:self.yearPicker];
    //两条线
    UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(16, 152, SCREEN_WIDTH - 32, 1)];
    line1.backgroundColor = [UIColor colorWithRed:231 / 255.0 green:231 / 255.0 blue:231 / 255.0 alpha:1];
    [self.monthSelectView addSubview:line1];
    UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(16, 187, SCREEN_WIDTH - 32, 1)];
    line2.backgroundColor = [UIColor colorWithRed:231 / 255.0 green:231 / 255.0 blue:231 / 255.0 alpha:1];
    [self.monthSelectView addSubview:line2];
    //确认按钮
    self.monthConfirm = [[UIButton alloc] initWithFrame:CGRectMake(20, 10, 60, 30)];
    [self.monthConfirm setTag:2000];
    [self.monthConfirm setTitle:@"确认" forState:UIControlStateNormal];
    [self.monthConfirm setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.monthConfirm setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [self.monthSelectView addSubview:self.monthConfirm];
    [self.monthConfirm addTarget:self action:@selector(monthSelectHide:) forControlEvents:UIControlEventTouchUpInside];
    //取消按钮
    self.monthCancel = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 80, 10, 60, 30)];
    [self.monthCancel setTag:2001];
    [self.monthCancel setTitle:@"取消" forState:UIControlStateNormal];
    [self.monthCancel setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.monthCancel setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [self.monthSelectView addSubview:self.monthCancel];
    [self.monthCancel addTarget:self action:@selector(monthSelectHide:) forControlEvents:UIControlEventTouchUpInside];
}

//月份选择界面出现
- (void)monthSelectPop {
    if (!self.shadeView) {
        self.shadeView = [[UIView alloc]initWithFrame:CGRectMake(0, DETAILVIEW_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - DETAILVIEW_HEIGHT)];
        self.shadeView.backgroundColor = [UIColor colorWithRed:(33 / 255.0)  green:(33 / 255.0)  blue:(33 / 255.0) alpha:0];
        [[[[UIApplication sharedApplication] windows] objectAtIndex:0] addSubview:self.shadeView];
    }
    if (!self.monthSelectView) {
        [self createMonthSelectView];
        [[[[UIApplication sharedApplication] windows] objectAtIndex:0] addSubview:self.monthSelectView];
    }
    [UIView animateWithDuration:0.3f animations:^{
        [self.monthSelectView setFrame:CGRectMake(0, SCREEN_HEIGHT - MONTHSELECT_HEIGHT, SCREEN_WIDTH, MONTHSELECT_HEIGHT)];
        self.shadeView.backgroundColor = [UIColor colorWithRed:(33 / 255.0)  green:(33 / 255.0)  blue:(33 / 255.0) alpha:0.2];
    } completion:^(BOOL finished) {
    }];
}

//月份选择界面消失
- (void)monthSelectHide:(UIButton *)sender {
    [UIView animateWithDuration:0.3f animations:^{
        [self.monthSelectView setFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, MONTHSELECT_HEIGHT)];
        self.shadeView.backgroundColor = [UIColor colorWithRed:(33 / 255.0)  green:(33 / 255.0)  blue:(33 / 255.0) alpha:0];
    } completion:^(BOOL finished) {
        [self.shadeView removeFromSuperview];
        self.shadeView = nil;
        [self.monthSelectView removeFromSuperview];
        self.monthSelectView = nil;
    }];
    //确认月份
    if (sender.tag == 2000) {
        self.yearSelected = self.yearPicker.date;
        self.monthSelected = self.monthPicker.date;
        self.monthSelectedString = [[[[self.yearFormatter stringFromDate:self.yearSelected] stringByAppendingString:@"年"] stringByAppendingString:[self.monthFormatter stringFromDate:self.monthSelected]] stringByAppendingString:@"月"];
        [self.monthButton setTitle:self.monthSelectedString forState:UIControlStateNormal];
        [self selectCurrentMonth];
        [self calculateMoney];
        [self createAllArray];
        [self.tableView reloadData];
    }
}

-(void)createAllArray{
    self.idArray = [[NSMutableArray alloc] init];
    self.typeArray = [[NSMutableArray alloc] init];
    self.accountArray = [[NSMutableArray alloc] init];
    self.labelArray = [[NSMutableArray alloc] init];
    self.amountArray = [[NSMutableArray alloc] init];
    self.remarkArray = [[NSMutableArray alloc] init];
    for(int i = 0;i < [self.dateSelected count]; i++){
        [self.idArray addObject:[[DataBase sharedDataBase] getInfoWithCommand:@"select * from record where date = ?" andCondition:[self.dateSelected objectAtIndex:i] andColumn:@"id"]];
        [self.labelArray addObject:[[DataBase sharedDataBase] getInfoWithCommand:@"select * from record where date = ?" andCondition:[self.dateSelected objectAtIndex:i] andColumn:@"label"]];
        [self.typeArray addObject:[[DataBase sharedDataBase] getInfoWithCommand:@"select * from record where date = ?" andCondition:[self.dateSelected objectAtIndex:i] andColumn:@"type"]];
        [self.remarkArray addObject:[[DataBase sharedDataBase] getInfoWithCommand:@"select * from record where date = ?" andCondition:[self.dateSelected objectAtIndex:i] andColumn:@"remark"]];
        [self.accountArray addObject:[[DataBase sharedDataBase] getInfoWithCommand:@"select * from record where date = ?" andCondition:[self.dateSelected objectAtIndex:i] andColumn:@"account"]];
        [self.amountArray addObject:[[DataBase sharedDataBase] getInfoWithCommand:@"select * from record where date = ?" andCondition:[self.dateSelected objectAtIndex:i] andColumn:@"amount"]];
    }
}

#pragma mark -
//筛选出当月有记录的日期 每个日期出现一次 且升序排列
- (void)selectCurrentMonth {
    NSArray *date = [[DataBase sharedDataBase] getInfoWithCommand:@"select * from record" andColumn:@"date"];
    self.dateSelected = [[NSMutableArray alloc] init];
    NSRange yearRange = NSMakeRange(0, 4);
    NSRange monthRange = NSMakeRange(5, 2);
    NSRange dateRange = NSMakeRange(8, 2);
    NSString *str = @"";
    for (int i = 0; i < [date count]; i++) {
        if ([[[date objectAtIndex:i] substringWithRange:yearRange] isEqualToString:[self.yearFormatter stringFromDate:self.yearSelected]] && [[[date objectAtIndex:i] substringWithRange:monthRange] isEqualToString:[self.monthFormatter stringFromDate:self.monthSelected]]) {
            [self.dateSelected addObject:[date objectAtIndex:i]];
        }
    }
    if ([self.dateSelected count] >= 2) {
        for (int i = 0; i < [self.dateSelected count] - 1; i++) {
            for (int j = i + 1; j < [self.dateSelected count]; j++) {
                if ([[self.dateSelected objectAtIndex:i] isEqualToString:[self.dateSelected objectAtIndex:j]]) {
                    [self.dateSelected removeObjectAtIndex:j];
                    j--;
                }
                if ([[[self.dateSelected objectAtIndex:i] substringWithRange:dateRange] intValue] < [[[self.dateSelected objectAtIndex:j] substringWithRange:dateRange] intValue]) {
                    str = [self.dateSelected objectAtIndex:i];
                    [self.dateSelected replaceObjectAtIndex:i withObject:[self.dateSelected objectAtIndex:j]];
                    [self.dateSelected replaceObjectAtIndex:j withObject:str];
                }
            }
        }
    }
}

//计算并显示本月数据
- (void)calculateMoney {
    double sumIncome = 0;
    double sumExpense = 0;
    double sumSueplus = 0;
    for (int i = 0; i < [self.dateSelected count]; i++) {
        sumIncome += [[DataBase sharedDataBase] getSumAmountWithCommand:@"select * from record where date = ? and type = '收入'" andCondition:[self.dateSelected objectAtIndex:i] andColumn:@"amount"];
        sumExpense += [[DataBase sharedDataBase] getSumAmountWithCommand:@"select * from record where date = ? and type = '支出'" andCondition:[self.dateSelected objectAtIndex:i] andColumn:@"amount"];
    }
    sumSueplus = sumIncome - sumExpense;
    
    [self.incomeAmountLabel setText:[NSString stringWithFormat:@"¥%.2lf", sumIncome]];
    [self.incomeAmountLabel sizeToFit];
    [self.incomeAmountLabel setCenter:CGPointMake(SCREEN_WIDTH / 6, STATUS_HEIGHT + NAVI_HEIGHT + 80)];
    [self.expenseAmountLabel setText:[NSString stringWithFormat:@"¥%.2lf", sumExpense]];
    [self.expenseAmountLabel sizeToFit];
    [self.expenseAmountLabel setCenter:CGPointMake(SCREEN_WIDTH / 2, STATUS_HEIGHT + NAVI_HEIGHT + 80)];
    [self.surplusAmountLabel setText:[NSString stringWithFormat:@"¥%.2lf", sumSueplus]];
    [self.surplusAmountLabel sizeToFit];
    [self.surplusAmountLabel setCenter:CGPointMake(SCREEN_WIDTH / 6 * 5, STATUS_HEIGHT + NAVI_HEIGHT + 80)];
}

//上一月/下一月 按钮函数
- (void)lastOrNextMonth:(UIButton *)button {
    NSCalendar *calender = [NSCalendar currentCalendar];
    NSDateComponents *cmpM = [calender components:(NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:self.monthSelected];
    NSDateComponents *cmpY = [calender components:(NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:self.yearSelected];
    if (button.tag == 3000) {
        if ([cmpM month] == 1) {
            [cmpM setMonth:12];
            [cmpY setYear:[cmpY year] - 1];
        } else {
            [cmpM setMonth:[cmpM month] - 1];
        }
    } else {
        if ([cmpM month] == 12) {
            [cmpM setMonth:1];
            [cmpY setYear:[cmpY year] + 1];
        } else {
            [cmpM setMonth:[cmpM month] + 1];
        }
    }
    self.monthSelected = [calender dateFromComponents:cmpM];
    self.yearSelected = [calender dateFromComponents:cmpY];
    self.monthSelectedString = [[[[self.yearFormatter stringFromDate:self.yearSelected] stringByAppendingString:@"年"] stringByAppendingString:[self.monthFormatter stringFromDate:self.monthSelected]] stringByAppendingString:@"月"];
    [self.monthButton setTitle:self.monthSelectedString forState:UIControlStateNormal];
    [self selectCurrentMonth];
    [self calculateMoney];
    [self createAllArray];
    [self.tableView reloadData];
}

- (void)detailRefresh {
    [self viewWillAppear:YES];
}

//计算星期几函数
- (NSString *)calculateWeekday:(NSString *)dateStr {
    // 设置为UTC时区
    [self.dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSDate *date = [self.dateFormatter dateFromString:dateStr];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comp = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday fromDate:date];
    NSInteger weekDay = [comp weekday];
    NSArray *daysInWeeks = [NSArray arrayWithObjects:@"星期日", @"星期一",  @"星期二", @"星期三", @"星期四", @"星期五", @"星期六", nil];
    NSString *theDay = [daysInWeeks objectAtIndex:(weekDay - 1)];
    return theDay;
}

#pragma mark - UITableViewDataSource
//返回每组行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rowNumber = [[DataBase sharedDataBase] getNumberWithCommand:@"select count(*) from record where date = ?" andColumn:[self.dateSelected objectAtIndex:section]];
    return rowNumber;
}

//返回每行单元格
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%@%ld%ld", self.monthSelectedString, indexPath.section, indexPath.row];//以indexPath来唯一确定cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];

        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 7, 36, 36)];
        imageView.layer.cornerRadius = 18;
        [imageView setImage:[UIImage imageNamed:[[self.labelArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]]];
        imageView.backgroundColor = MAIN_COLOR;
        [cell addSubview:imageView];

        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(66, 15, 60, 20)];
        [label setText:[[self.labelArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
        [cell addSubview:label];
        [label sizeToFit];

        UILabel *remarkLabel = [[UILabel alloc]initWithFrame:CGRectMake(66 + label.bounds.size.width + 10, 17, 80, 16)];
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

        //用来调整账户名位置的隐藏label
        UILabel *amountLabelHide = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 140, 15, 120, 20)];
        [amountLabelHide setText:amountOutput];
        [amountLabelHide sizeToFit];

        UILabel *accountLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 180, 17, 80, 16)];
        [accountLabel setText:[[self.accountArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
        [cell addSubview:accountLabel];
        [accountLabel sizeToFit];
        accountLabel.frame = CGRectMake(SCREEN_WIDTH - 20 - amountLabelHide.bounds.size.width - accountLabel.bounds.size.width - 10, 17, 80, 16);
    }
    return cell;
}

// 返回分组数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.dateSelected count];
}

//// 返回每组头标题
//-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
//    return @"header";
//}
//// 返回每组尾部标题
//-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
//    return @"footer";
//}
//// 返回 Cell 是否在滑动时是否可以编辑
//-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath;
//// 返回 Cell 是否可以移动
//-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath;
//// TableView 右侧建立一个索引表需要的数组内容
//-(NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView;
//// 对 Cell 编辑结束后的回调
//-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;
//// 对 Cell 移动结束后的回调
//-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath;

#pragma mark - UITableViewDelegate

//// Cell 即将显示，可用于自定义 Cell 显示的动画效果
//-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
//// UITableView 的 HeaderView 即将显示，可用于自定义 HeaderView 显示的动画效果
//-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section;
//// UITableView 的 FooterView 即将显示，可用于自定义 FooterView 显示的动画效果
//-(void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section;
//// Cell 完成显示
//-(void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath;
//// HeaderView 完成显示
//-(void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section NS_AVAILABLE_IOS(6_0);
//// FooterView 完成显示
//-(void)tableView:(UITableView *)tableView didEndDisplayingFooterView:(UIView *)view forSection:(NSInteger)section;

// 返回每个 Cell 的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

// 返回每个 Section 的 HeaderView 高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

// 返回每个 Section FooterView 的高度
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

// 返回 Section 自定义的 HeaderView
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor whiteColor];
    //记录日期
    UILabel *dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, 80, 20)];
    [dateLabel setText:[self.dateSelected objectAtIndex:section]];
    [dateLabel setTextColor:[UIColor lightGrayColor]];
    [dateLabel sizeToFit];
    [headerView addSubview:dateLabel];
    //星期几
    UILabel *dayLabel = [[UILabel alloc]initWithFrame:CGRectMake(110, 5, 80, 20)];
    [dayLabel setText:[self calculateWeekday:[self.dateSelected objectAtIndex:section]]];
    [dayLabel setTextColor:[UIColor lightGrayColor]];
    [dayLabel sizeToFit];
    [headerView addSubview:dayLabel];

    double sumIncome = [[DataBase sharedDataBase] getSumAmountWithCommand:@"select * from record where date = ? and type = '收入'" andCondition:[self.dateSelected objectAtIndex:section] andColumn:@"amount"];
    double sumExpense = [[DataBase sharedDataBase] getSumAmountWithCommand:@"select * from record where date = ? and type = '支出'" andCondition:[self.dateSelected objectAtIndex:section] andColumn:@"amount"];
    UILabel *sumAmountLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 250, 5, 240, 20)];
    [sumAmountLabel setFont:[UIFont systemFontOfSize:15]];
    NSString *sumAmountStr = [[NSString alloc] init];
    if (sumIncome && sumExpense) {
        sumAmountStr = [NSString stringWithFormat:@"收入：%.2lf 支出：%.2lf", sumIncome, sumExpense];
    } else if (sumIncome && !sumExpense) {
        sumAmountStr = [NSString stringWithFormat:@"收入：%.2lf", sumIncome];
    } else if (!sumIncome && sumExpense) {
        sumAmountStr = [NSString stringWithFormat:@"支出：%.2lf", sumExpense];
    }
    [sumAmountLabel setText:sumAmountStr];
    [sumAmountLabel setTextColor:[UIColor lightGrayColor]];
    sumAmountLabel.textAlignment = NSTextAlignmentRight;
    [headerView addSubview:sumAmountLabel];

    return headerView;
}

// 返回 Section 自定义的 FooterView
- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] init];
    return footerView;
}

//// 返回当前选中的 Row 是否高亮，一般在选择的时候才高亮
//- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath;
//-(void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath;
//-(void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath;

// Cell 被选中的回调
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *idStr = [NSString stringWithFormat:@"%@",[[self.idArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
    ABEachDetailViewController *eachDetailViewController = [[ABEachDetailViewController alloc] initWithDetailID:idStr andType:[[self.typeArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] andDate:[self.dateSelected objectAtIndex:indexPath.section] andAccount:[[self.accountArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]  andAmount:[[self.amountArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]  andRemark:[[self.remarkArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:eachDetailViewController animated:YES];
}

@end
