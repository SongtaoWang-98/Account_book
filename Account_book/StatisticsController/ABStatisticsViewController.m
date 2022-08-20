//
//  ABStatisticsViewController.m
//  Account_book
//
//  Created by 王松涛 on 2020/6/8.
//  Copyright © 2020 Songtao Wang. All rights reserved.
//

#import "ABStatisticsViewController.h"
#import "Definition.h"
#import "ABOverviewView.h"
#import "ABExpenseStatView.h"
#import "ABIncomeStatView.h"

@interface ABStatisticsViewController ()<UIScrollViewDelegate>

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
@property (nonatomic, strong) NSDate *yearSelected;//当前年选择
@property (nonatomic, strong) NSDateFormatter *dateFormatter;//年月日时间格式化
@property (nonatomic, strong) NSDateFormatter *monthFormatter;//月时间格式化
@property (nonatomic, strong) NSDateFormatter *yearFormatter;//年时间格式化
@property (nonatomic, copy) NSString *monthSelectedString;//当前时间字符串

//统计内容选择 总览/支出/收入
@property (nonatomic, strong, readwrite) UIView *modeSelectView;
@property (nonatomic, strong, readwrite) UIScrollView *currentView;
@property (nonatomic, strong, readwrite) UIButton *btnOverview;
@property (nonatomic, strong, readwrite) UIButton *btnExpenseStat;
@property (nonatomic, strong, readwrite) UIButton *btnIncomeStat;
@property (nonatomic, strong, readwrite) UIButton *btnCurrentStat;

@property (nonatomic, strong, readwrite) ABOverviewView *overviewView;
@property (nonatomic, strong, readwrite) ABExpenseStatView *expenseStatView;
@property (nonatomic, strong, readwrite) ABIncomeStatView *incomeStatView;

@end

@implementation ABStatisticsViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.tabBarItem.title = @"统计";
        self.tabBarItem.image = [UIImage imageNamed:@"icon.bundle/fishpond_normal@2x.png"];
        self.tabBarItem.selectedImage = [[UIImage imageNamed:@"icon.bundle/fishpond_highlight@2x.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
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
    //自定义bar
    self.titleView = [[UIView alloc] init];
    self.titleView.backgroundColor = MAIN_COLOR;
    [self.view addSubview:self.titleView];

    self.currentView = [[UIScrollView alloc] init];
    self.currentView.backgroundColor = [UIColor whiteColor];
    self.currentView.pagingEnabled = YES;
    self.currentView.showsHorizontalScrollIndicator = NO;
    self.currentView.delegate = self;
    [self.view addSubview:self.currentView];
    
    //月份选择按钮
    self.monthButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 130, 40)];
    [self.titleView addSubview:self.monthButton];
    [self.monthButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.monthButton.layer.borderWidth = 1;
    self.monthButton.layer.cornerRadius = 10;
    [self.monthButton addTarget:self action:@selector(monthSelectPop) forControlEvents:UIControlEventTouchUpInside];
    
    //上/下一月选择按钮
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
    
    //统计模式选择
    self.modeSelectView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 330, 45)];
    [self.titleView addSubview:self.modeSelectView];
    self.modeSelectView.layer.borderWidth = 1;
    self.modeSelectView.layer.cornerRadius = 10;
    self.modeSelectView.layer.masksToBounds = YES;
    //三个统计模式按键
    self.btnOverview = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 110, 45)];
    self.btnOverview.tag = 4000;
    [self.modeSelectView addSubview:self.btnOverview];
    [self.btnOverview setTitle:@"总览" forState:UIControlStateNormal];
    [self.btnOverview setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.btnOverview addTarget:self action:@selector(changeStatisticMode:) forControlEvents:UIControlEventTouchUpInside];
    self.btnExpenseStat = [[UIButton alloc] initWithFrame:CGRectMake(110, 0, 110, 45)];
    self.btnExpenseStat.tag = 4001;
    [self.modeSelectView addSubview:self.btnExpenseStat];
    [self.btnExpenseStat setTitle:@"支出统计" forState:UIControlStateNormal];
    [self.btnExpenseStat setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.btnExpenseStat addTarget:self action:@selector(changeStatisticMode:) forControlEvents:UIControlEventTouchUpInside];
    self.btnIncomeStat = [[UIButton alloc] initWithFrame:CGRectMake(220, 0, 110, 45)];
    self.btnIncomeStat.tag = 4002;
    [self.modeSelectView addSubview:self.btnIncomeStat];
    [self.btnIncomeStat setTitle:@"收入统计" forState:UIControlStateNormal];
    [self.btnIncomeStat setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.btnIncomeStat addTarget:self action:@selector(changeStatisticMode:) forControlEvents:UIControlEventTouchUpInside];
    UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(110, 0, 1, 45)];
    [self.modeSelectView addSubview:line1];
    [line1 setBackgroundColor:[UIColor blackColor]];
    UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(220, 0, 1, 45)];
    [self.modeSelectView addSubview:line2];
    [line2 setBackgroundColor:[UIColor blackColor]];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.titleView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, STATISTIC_HEIGHT)];
    [self.currentView setFrame:CGRectMake(0, STATISTIC_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - STATISTIC_HEIGHT)];
    self.currentView.contentSize = CGSizeMake(SCREEN_WIDTH * 3, SCREEN_HEIGHT - STATISTIC_HEIGHT);
    self.navigationController.navigationBarHidden = YES;
    [self showButtonsAndLabels];
    [self showStatisticViews];
}
- (void)showButtonsAndLabels{
    self.monthSelected = [NSDate date];
    self.yearSelected = [NSDate date];
    self.monthSelectedString = [[[[self.yearFormatter stringFromDate:self.yearSelected] stringByAppendingString:@"年"] stringByAppendingString:[self.monthFormatter stringFromDate:self.monthSelected]] stringByAppendingString:@"月"];
    
    self.monthButton.center = CGPointMake(SCREEN_WIDTH / 2, STATUS_HEIGHT + NAVI_HEIGHT);
    [self.monthButton setTitle:self.monthSelectedString forState:UIControlStateNormal];
    [self.btnLastMonth setFrame:CGRectMake(SCREEN_WIDTH / 2 - 110, STATUS_HEIGHT + NAVI_HEIGHT - 20, 40, 40)];
    [self.btnNextMonth setFrame:CGRectMake(SCREEN_WIDTH / 2 + 70, STATUS_HEIGHT + NAVI_HEIGHT - 20, 40, 40)];
    [self.modeSelectView setCenter:CGPointMake(SCREEN_WIDTH / 2, STATUS_HEIGHT + NAVI_HEIGHT + 55)];
    
    [self.btnCurrentStat setBackgroundColor:MAIN_COLOR];
    [self.btnCurrentStat setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.btnCurrentStat = self.btnOverview;
    self.currentView.contentOffset = CGPointMake(0, 0);
    [self.btnCurrentStat setBackgroundColor:[UIColor blackColor]];
    [self.btnCurrentStat setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}
//显示统计界面
- (void)showStatisticViews {
    if (self.overviewView) {
        [self.overviewView removeFromSuperview];
    }
    self.overviewView = [[ABOverviewView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - STATISTIC_HEIGHT) andYear:[self.yearFormatter stringFromDate:self.yearSelected] andMonth:[self.monthFormatter stringFromDate:self.monthSelected]];
    [self.currentView addSubview:self.overviewView];
    if (self.expenseStatView) {
        [self.expenseStatView removeFromSuperview];
    }
    self.expenseStatView = [[ABExpenseStatView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_HEIGHT - STATISTIC_HEIGHT) andYear:[self.yearFormatter stringFromDate:self.yearSelected] andMonth:[self.monthFormatter stringFromDate:self.monthSelected]];
    [self.currentView addSubview:self.expenseStatView];
    if (self.incomeStatView) {
        [self.incomeStatView removeFromSuperview];
    }
    self.incomeStatView = [[ABIncomeStatView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH * 2, 0, SCREEN_WIDTH, SCREEN_HEIGHT - STATISTIC_HEIGHT) andYear:[self.yearFormatter stringFromDate:self.yearSelected] andMonth:[self.monthFormatter stringFromDate:self.monthSelected]];
    [self.currentView addSubview:self.incomeStatView];
}

//切换统计内容
- (void)changeStatisticMode:(UIButton *)button {
    [self.btnCurrentStat setBackgroundColor:MAIN_COLOR];
    [self.btnCurrentStat setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    switch (button.tag) {
        case 4000:
            self.btnCurrentStat = self.btnOverview;
            break;
        case 4001:
            self.btnCurrentStat = self.btnExpenseStat;
            break;
        case 4002:
            self.btnCurrentStat = self.btnIncomeStat;
            break;
        default:
            break;
    }
    [UIView animateWithDuration:0.25f animations:^{
        [self.btnCurrentStat setBackgroundColor:[UIColor blackColor]];
        [self.btnCurrentStat setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.currentView.contentOffset = CGPointMake((button.tag - 4000) * SCREEN_WIDTH, 0);
    }];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetRate = self.currentView.contentOffset.x / SCREEN_WIDTH;
    if (offsetRate == 0) {
        [self.btnCurrentStat setBackgroundColor:MAIN_COLOR];
        [self.btnCurrentStat setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.btnCurrentStat = self.btnOverview;
    } else if (offsetRate == 1) {
        [self.btnCurrentStat setBackgroundColor:MAIN_COLOR];
        [self.btnCurrentStat setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.btnCurrentStat = self.btnExpenseStat;
    } else if (offsetRate == 2) {
        [self.btnCurrentStat setBackgroundColor:MAIN_COLOR];
        [self.btnCurrentStat setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.btnCurrentStat = self.btnIncomeStat;
    }
    [UIView animateWithDuration:0.25f animations:^{
        [self.btnCurrentStat setBackgroundColor:[UIColor blackColor]];
        [self.btnCurrentStat setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }];
}

#pragma mark - 月份选择器
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
        self.shadeView = [[UIView alloc]initWithFrame:CGRectMake(0, STATISTIC_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - STATISTIC_HEIGHT)];
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
        [self showStatisticViews];
    }
}

#pragma mark -

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
    [self showStatisticViews];
}

- (void)statisticsRefresh {
    [self viewWillAppear:YES];
}

@end
