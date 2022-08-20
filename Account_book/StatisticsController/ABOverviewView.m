//
//  ABOverviewView.m
//  Account_book
//
//  Created by 王松涛 on 2020/7/18.
//  Copyright © 2020 Songtao Wang. All rights reserved.
//

#import "ABOverviewView.h"
#import "Definition.h"
#import "DataBase.h"
#import "ABLineChartView.h"
@interface ABOverviewView()

@property (nonatomic, strong ,readwrite) ABLineChartView *lineChartView;
@property(nonatomic, strong) NSMutableArray *dateInMonth;//折线统计图横坐标title
@property(nonatomic, strong) NSMutableArray *incomeValue;//当前月每天的收入值
@property(nonatomic, strong) NSMutableArray *expenseValue;//当前月每天的支出值

@property(nonatomic, strong) NSMutableArray *incomeDate;//当前月有收入的日期
@property(nonatomic, strong) NSMutableArray *expenseDate;//当前月有支出的日期
@property(nonatomic, strong) NSMutableArray *incomeAmount;//有收入日期对应的收入值
@property(nonatomic, strong) NSMutableArray *expenseAmount;//有支出日期对应的支出值

@property (nonatomic, copy) NSString *year;//当前年字符串
@property (nonatomic, copy) NSString *month;//当前月份字符串

@property(nonatomic,assign) NSInteger dayNumber;

@end

@implementation ABOverviewView

- (instancetype)initWithFrame:(CGRect)frame andYear:(NSString *)year andMonth:(NSString *)month{
    self = [super initWithFrame:frame];
    if(self){
        self.year = year;
        self.month = month;
        
        UILabel *chartView = [[UILabel alloc]init];
        [chartView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
        [chartView setBackgroundColor:[UIColor grayColor]];
        [chartView setText:[year stringByAppendingString:month]];
        [self addSubview:chartView];
        
        [self selectCurrentMonth];
        [self calculateMoney];
        [self drawLineChart];
    }
    return self;
}

//筛选出当月有记录的日期 每个日期出现一次 且升序排列
- (void)selectCurrentMonth{
    NSArray *inDate = [[DataBase sharedDataBase] getInfoWithCommand:@"select * from record where type = '收入'" andColumn:@"date"];
    NSArray *exDate = [[DataBase sharedDataBase] getInfoWithCommand:@"select * from record where type = '支出'" andColumn:@"date"];
    self.incomeDate = [[NSMutableArray alloc] init];
    self.expenseDate = [[NSMutableArray alloc] init];
    NSRange yearRange = NSMakeRange(0, 4);
    NSRange monthRange = NSMakeRange(5, 2);
    NSRange dateRange = NSMakeRange(8, 2);
    NSString *str = @"";
    for(int i = 0; i < [inDate count]; i++){
        if([[[inDate objectAtIndex:i] substringWithRange:yearRange] isEqualToString:self.year] && [[[inDate objectAtIndex:i] substringWithRange:monthRange] isEqualToString:self.month]){
            [self.incomeDate addObject:[inDate objectAtIndex:i]];
        }
    }
    for(int i = 0; i < [exDate count]; i++){
        if([[[exDate objectAtIndex:i] substringWithRange:yearRange] isEqualToString:self.year] && [[[exDate objectAtIndex:i] substringWithRange:monthRange] isEqualToString:self.month]){
            [self.expenseDate addObject:[exDate objectAtIndex:i]];
        }
    }
    if([self.incomeDate count]>=2){
        for(int i = 0; i < [self.incomeDate count] - 1; i++){
            for(int j = i + 1; j < [self.incomeDate count]; j++){
                if([[self.incomeDate objectAtIndex:i] isEqualToString:[self.incomeDate objectAtIndex:j]]){
                    [self.incomeDate removeObjectAtIndex:j];
                    j--;
                }
                if([[[self.incomeDate objectAtIndex:i] substringWithRange:dateRange] intValue] > [[[self.incomeDate objectAtIndex:j] substringWithRange:dateRange] intValue]){
                    str = [self.incomeDate objectAtIndex:i];
                    [self.incomeDate replaceObjectAtIndex:i withObject:[self.incomeDate objectAtIndex:j]];
                    [self.incomeDate replaceObjectAtIndex:j withObject:str];
                }
            }
        }
    }
    if([self.expenseDate count]>=2){
        for(int i = 0; i < [self.expenseDate count] - 1; i++){
            for(int j = i + 1; j < [self.expenseDate count]; j++){
                if([[self.expenseDate objectAtIndex:i] isEqualToString:[self.expenseDate objectAtIndex:j]]){
                    [self.expenseDate removeObjectAtIndex:j];
                    j--;
                }
                if([[[self.expenseDate objectAtIndex:i] substringWithRange:dateRange] intValue] > [[[self.expenseDate objectAtIndex:j] substringWithRange:dateRange] intValue]){
                    str = [self.expenseDate objectAtIndex:i];
                    [self.expenseDate replaceObjectAtIndex:i withObject:[self.expenseDate objectAtIndex:j]];
                    [self.expenseDate replaceObjectAtIndex:j withObject:str];
                }
            }
        }
    }
}

//计算并显示本月数据
- (void)calculateMoney{
    double sumIncome = 0;
    double sumExpense = 0;
    double sumSueplus = 0;
    self.incomeAmount = [[NSMutableArray alloc] init];
    self.expenseAmount = [[NSMutableArray alloc] init];
    for(int i = 0; i < [self.incomeDate count]; i++){
        sumIncome += [[DataBase sharedDataBase] getSumAmountWithCommand:@"select * from record where date = ? and type = '收入'" andCondition:[self.incomeDate objectAtIndex:i] andColumn:@"amount"];
        [self.incomeAmount addObject:[NSString stringWithFormat:@"%.2lf",[[DataBase sharedDataBase] getSumAmountWithCommand:@"select * from record where date = ? and type = '收入'" andCondition:[self.incomeDate objectAtIndex:i] andColumn:@"amount"]]];
    }
    for(int i = 0; i < [self.expenseDate count]; i++){
        sumExpense += [[DataBase sharedDataBase] getSumAmountWithCommand:@"select * from record where date = ? and type = '支出'" andCondition:[self.expenseDate objectAtIndex:i] andColumn:@"amount"];
        [self.expenseAmount addObject:[NSString stringWithFormat:@"%.2lf",[[DataBase sharedDataBase] getSumAmountWithCommand:@"select * from record where date = ? and type = '支出'" andCondition:[self.expenseDate objectAtIndex:i] andColumn:@"amount"]]];
    }
    sumSueplus = sumIncome - sumExpense;
    if([self.month intValue] == 1 || [self.month intValue] == 3 || [self.month intValue] == 5 || [self.month intValue] == 7 || [self.month intValue] == 8 || [self.month intValue] == 10 || [self.month intValue] == 12 ){
        self.dayNumber = 31;
    }
    else if( [self.month intValue] == 4 || [self.month intValue] == 6 || [self.month intValue] == 9 || [self.month intValue] == 11){
        self.dayNumber = 30;
    }
    else if( [self.month intValue] == 2 ){
        if(( [self.year intValue] % 4 == 0 && [self.year intValue] % 100 != 0) || ([self.year intValue] % 400 == 0)){
            self.dayNumber = 29;
        }
        else{
            self.dayNumber = 28;
        }
    }
    UILabel *monthIncomeLabel = [[UILabel alloc] init];
    [self addSubview:monthIncomeLabel];
    [monthIncomeLabel setText:[NSString stringWithFormat:@"总收入：¥%.2lf  平均日收入：¥%.2lf",sumIncome,sumIncome/self.dayNumber]];
    [monthIncomeLabel sizeToFit];
    [monthIncomeLabel setCenter:CGPointMake(SCREEN_WIDTH / 2 , 350)];
    UILabel *monthExpenseLabel = [[UILabel alloc] init];
    [self addSubview:monthExpenseLabel];
    [monthExpenseLabel setText:[NSString stringWithFormat:@"总支出：¥%.2lf  平均日支出：¥%.2lf",sumExpense,sumExpense/self.dayNumber]];
    [monthExpenseLabel sizeToFit];
    [monthExpenseLabel setCenter:CGPointMake(SCREEN_WIDTH / 2, 380)];
    UILabel *monthSurplusLabel = [[UILabel alloc] init];
    [self addSubview:monthSurplusLabel];
    [monthSurplusLabel setText:[NSString stringWithFormat:@"结余：¥%.2lf",sumSueplus]];
    [monthSurplusLabel sizeToFit];
    [monthSurplusLabel setCenter:CGPointMake(SCREEN_WIDTH / 2, 410)];
}

//折线统计图有关数据
- (void)makeDataOfChart{
    self.incomeValue = [[NSMutableArray alloc] init];
    self.expenseValue = [[NSMutableArray alloc] init];
    self.dateInMonth = [[NSMutableArray alloc] init];
    NSRange dateRange = NSMakeRange(8, 2);
    
    for(int i = 0;i < self.dayNumber;i++){
        [self.dateInMonth addObject:[NSString stringWithFormat:@"%d",i+1]];
        [self.expenseValue addObject:@"0"];
        [self.incomeValue addObject:@"0"];
        for(int n = 0;n < [self.expenseDate count];n++){
            if([[[self.expenseDate objectAtIndex:n] substringWithRange:dateRange] intValue] == i+1){
                [self.expenseValue replaceObjectAtIndex:i withObject:[self.expenseAmount objectAtIndex:n]];
            }
        }
        for(int n = 0;n < [self.incomeDate count];n++){
            if([[[self.incomeDate objectAtIndex:n] substringWithRange:dateRange] intValue] == i+1){
                [self.incomeValue replaceObjectAtIndex:i withObject:[self.incomeAmount objectAtIndex:n]];
            }
        }
    }
}

//画折线统计图
- (void)drawLineChart{
    [self makeDataOfChart];
    self.lineChartView = [[ABLineChartView alloc]initWithValue1:self.incomeValue andValue2:self.expenseValue andXTitles:self.dateInMonth andYTitlesCount:5];
    [self addSubview:self.lineChartView];
    [self.lineChartView setFrame:CGRectMake(0, 50, SCREEN_WIDTH, 200)];
}

@end
