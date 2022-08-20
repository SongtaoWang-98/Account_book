//
//  ABIncomeStatView.m
//  Account_book
//
//  Created by 王松涛 on 2020/7/18.
//  Copyright © 2020 Songtao Wang. All rights reserved.
//

#import "ABIncomeStatView.h"
#import "Definition.h"
#import "DataBase.h"

@interface ABIncomeStatView ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, copy) NSString *year;//当前年字符串
@property (nonatomic, copy) NSString *month;//当前月份字符串
@property (nonatomic, assign) double sumIncome;
@property (nonatomic, strong) NSMutableArray *incomeDate;//当前月有支出的日期
@property (nonatomic, strong) NSMutableArray *incomeLabel;//当前月支出所用标签
@property (nonatomic, strong) NSMutableArray *incomeLabelAmount;//当前月支出所用标签对应总金额
@property (nonatomic, strong, readwrite) UITableView *incomeRankTableview;

@end

@implementation ABIncomeStatView

- (instancetype)initWithFrame:(CGRect)frame andYear:(NSString *)year andMonth:(NSString *)month {
    self = [super initWithFrame:frame];
    if (self) {
        self.year = year;
        self.month = month;

        UILabel *chartView = [[UILabel alloc]init];
        [chartView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
        [chartView setBackgroundColor:[UIColor greenColor]];
        [chartView setText:[year stringByAppendingString:month]];
        [self addSubview:chartView];

        [self selectCurrentMonth];
        [self incomeAnalyze];
//        [self drawPieChart];
    }
    return self;
}

//筛选出当月有支出记录的日期 每个日期出现一次 且升序排列
- (void)selectCurrentMonth {
    NSArray *inDate = [[DataBase sharedDataBase] getInfoWithCommand:@"select * from record where type = '收入'" andColumn:@"date"];
    self.incomeDate = [[NSMutableArray alloc] init];
    NSRange yearRange = NSMakeRange(0, 4);
    NSRange monthRange = NSMakeRange(5, 2);
    NSRange dateRange = NSMakeRange(8, 2);
    NSString *str = @"";
    for (int i = 0; i < [inDate count]; i++) {
        if ([[[inDate objectAtIndex:i] substringWithRange:yearRange] isEqualToString:self.year] && [[[inDate objectAtIndex:i] substringWithRange:monthRange] isEqualToString:self.month]) {
            [self.incomeDate addObject:[inDate objectAtIndex:i]];
        }
    }
    if ([self.incomeDate count] >= 2) {
        for (int i = 0; i < [self.incomeDate count] - 1; i++) {
            for (int j = i + 1; j < [self.incomeDate count]; j++) {
                if ([[self.incomeDate objectAtIndex:i] isEqualToString:[self.incomeDate objectAtIndex:j]]) {
                    [self.incomeDate removeObjectAtIndex:j];
                    j--;
                }
                if ([[[self.incomeDate objectAtIndex:i] substringWithRange:dateRange] intValue] > [[[self.incomeDate objectAtIndex:j] substringWithRange:dateRange] intValue]) {
                    str = [self.incomeDate objectAtIndex:i];
                    [self.incomeDate replaceObjectAtIndex:i withObject:[self.incomeDate objectAtIndex:j]];
                    [self.incomeDate replaceObjectAtIndex:j withObject:str];
                }
            }
        }
    }
}

//根据有支出记录日期查找出现过的label，再根据label进行分析
- (void)incomeAnalyze {
    self.sumIncome = 0;
    self.incomeLabel = [[NSMutableArray alloc] init];
    self.incomeLabelAmount = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self.incomeDate count]; i++) {
        self.sumIncome += [[DataBase sharedDataBase] getSumAmountWithCommand:@"select * from record where date = ? and type = '收入'" andCondition:[self.incomeDate objectAtIndex:i] andColumn:@"amount"];
        NSArray *inLabel = [[DataBase sharedDataBase] getInfoWithCommand:@"select * from record where type = '收入' and date = ?" andCondition:[self.incomeDate objectAtIndex:i] andColumn:@"label"];
        for (int m = 0; m < [inLabel count]; m++) {
            [self.incomeLabel addObject:[inLabel objectAtIndex:m]];
        }
    }
    if ([self.incomeLabel count] >= 2) {
        for (int i = 0; i < [self.incomeLabel count] - 1; i++) {
            for (int j = i + 1; j < [self.incomeLabel count]; j++) {
                if ([[self.incomeLabel objectAtIndex:i] isEqualToString:[self.incomeLabel objectAtIndex:j]]) {
                    [self.incomeLabel removeObjectAtIndex:j];
                    j--;
                }
            }
        }
    }
    for (int i = 0; i < [self.incomeLabel count]; i++) {
        [self.incomeLabelAmount addObject:@"0"];
    }
    for (int i = 0; i < [self.incomeDate count]; i++) {
        for (int m = 0; m < [self.incomeLabel count]; m++) {
            double a = [[DataBase sharedDataBase] getSumAmountWithCommand:@"select * from record where date = ? and label = ?" andCondition1:[self.incomeDate objectAtIndex:i] andCondition2:[self.incomeLabel objectAtIndex:m] andColumn:@"amount"];
            if (a) {
                [self.incomeLabelAmount replaceObjectAtIndex:m withObject:[NSString stringWithFormat:@"%.2lf", [[self.incomeLabelAmount objectAtIndex:m] doubleValue] + a]];
            }
        }
    }
    if ([self.incomeLabel count] >= 2) {
        NSString *str = [[NSString alloc] init];
        for (int i = 0; i < [self.incomeLabel count] - 1; i++) {
            for (int j = i + 1; j < [self.incomeLabel count]; j++) {
                if ([[self.incomeLabelAmount objectAtIndex:i] doubleValue] < [[self.incomeLabelAmount objectAtIndex:j] doubleValue]) {
                    str = [self.incomeLabel objectAtIndex:i];
                    [self.incomeLabel replaceObjectAtIndex:i withObject:[self.incomeLabel objectAtIndex:j]];
                    [self.incomeLabel replaceObjectAtIndex:j withObject:str];
                    str = [self.incomeLabelAmount objectAtIndex:i];
                    [self.incomeLabelAmount replaceObjectAtIndex:i withObject:[self.incomeLabelAmount objectAtIndex:j]];
                    [self.incomeLabelAmount replaceObjectAtIndex:j withObject:str];
                }
            }
        }
    }

    self.incomeRankTableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 250, SCREEN_WIDTH, self.frame.size.height - 250) style:(UITableViewStyleGrouped)];
    self.incomeRankTableview.backgroundColor = [UIColor whiteColor];
    self.incomeRankTableview.delegate = self;
    self.incomeRankTableview.dataSource = self;
    [self addSubview:self.incomeRankTableview];
}

#pragma mark - UITableViewDataSource
//返回每组行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.incomeLabel count];
}

//返回每行单元格
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%ld%ld", indexPath.section, indexPath.row];//以indexPath来唯一确定cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];

        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 7, 36, 36)];
        imageView.layer.cornerRadius = 18;
        [imageView setImage:[UIImage imageNamed:[self.incomeLabel objectAtIndex:indexPath.row]]];
        imageView.backgroundColor = MAIN_COLOR;
        [cell addSubview:imageView];

        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(66, 15, 60, 20)];
        [label setText:[self.incomeLabel objectAtIndex:indexPath.row]];
        [cell addSubview:label];
        [label sizeToFit];

        UILabel *percentageLabel = [[UILabel alloc]initWithFrame:CGRectMake(160, 15, 60, 20)];
        double percentage = [[self.incomeLabelAmount objectAtIndex:indexPath.row] doubleValue] / self.sumIncome * 100;
        [percentageLabel setText:[NSString stringWithFormat:@"%.2lf%%", percentage]];
        [cell addSubview:percentageLabel];
        [label sizeToFit];

        UILabel *amountLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 140, 15, 120, 20)];
        [amountLabel setText:[self.incomeLabelAmount objectAtIndex:indexPath.row]];
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
    return 30;
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

//// 返回当前选中的 Row 是否高亮，一般在选择的时候才高亮
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

@end
