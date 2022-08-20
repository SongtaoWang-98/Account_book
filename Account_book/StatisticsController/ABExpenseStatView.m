//
//  ABExpenseStatView.m
//  Account_book
//
//  Created by 王松涛 on 2020/7/18.
//  Copyright © 2020 Songtao Wang. All rights reserved.
//

#import "ABExpenseStatView.h"
#import "Definition.h"
#import "DataBase.h"
@interface ABExpenseStatView ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, copy) NSString *year;//当前年字符串
@property (nonatomic, copy) NSString *month;//当前月份字符串

@property (nonatomic, assign) double sumExpense;//当前月份字符串

@property (nonatomic, strong) NSMutableArray *expenseDate;//当前月有支出的日期
@property (nonatomic, strong) NSMutableArray *expenseLabel;//当前月支出所用标签
@property (nonatomic, strong) NSMutableArray *expenseLabelAmount;//当前月支出所用标签对应总金额

@property (nonatomic, strong, readwrite) UITableView *expenseRankTableview;

@end

@implementation ABExpenseStatView

- (instancetype)initWithFrame:(CGRect)frame andYear:(NSString *)year andMonth:(NSString *)month {
    self = [super initWithFrame:frame];
    if (self) {
        self.year = year;
        self.month = month;

        UILabel *chartView = [[UILabel alloc]init];
        [chartView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
        [chartView setBackgroundColor:[UIColor yellowColor]];
        [chartView setText:[year stringByAppendingString:month]];
        [self addSubview:chartView];

        [self selectCurrentMonth];
        [self expenseAnalyze];
//        [self drawPieChart];
    }
    return self;
}

//筛选出当月有支出记录的日期 每个日期出现一次 且升序排列
- (void)selectCurrentMonth {
    NSArray *exDate = [[DataBase sharedDataBase] getInfoWithCommand:@"select * from record where type = '支出'" andColumn:@"date"];
    self.expenseDate = [[NSMutableArray alloc] init];
    NSRange yearRange = NSMakeRange(0, 4);
    NSRange monthRange = NSMakeRange(5, 2);
    NSRange dateRange = NSMakeRange(8, 2);
    NSString *str = @"";
    for (int i = 0; i < [exDate count]; i++) {
        if ([[[exDate objectAtIndex:i] substringWithRange:yearRange] isEqualToString:self.year] && [[[exDate objectAtIndex:i] substringWithRange:monthRange] isEqualToString:self.month]) {
            [self.expenseDate addObject:[exDate objectAtIndex:i]];
        }
    }
    if ([self.expenseDate count] >= 2) {
        for (int i = 0; i < [self.expenseDate count] - 1; i++) {
            for (int j = i + 1; j < [self.expenseDate count]; j++) {
                if ([[self.expenseDate objectAtIndex:i] isEqualToString:[self.expenseDate objectAtIndex:j]]) {
                    [self.expenseDate removeObjectAtIndex:j];
                    j--;
                }
                if ([[[self.expenseDate objectAtIndex:i] substringWithRange:dateRange] intValue] > [[[self.expenseDate objectAtIndex:j] substringWithRange:dateRange] intValue]) {
                    str = [self.expenseDate objectAtIndex:i];
                    [self.expenseDate replaceObjectAtIndex:i withObject:[self.expenseDate objectAtIndex:j]];
                    [self.expenseDate replaceObjectAtIndex:j withObject:str];
                }
            }
        }
    }
}

//根据有支出记录日期查找出现过的支出label，再根据label进行分析
- (void)expenseAnalyze {
    self.sumExpense = 0;
    self.expenseLabel = [[NSMutableArray alloc] init];
    self.expenseLabelAmount = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self.expenseDate count]; i++) {
        self.sumExpense += [[DataBase sharedDataBase] getSumAmountWithCommand:@"select * from record where date = ? and type = '支出'" andCondition:[self.expenseDate objectAtIndex:i] andColumn:@"amount"];
        NSArray *exLabel = [[DataBase sharedDataBase] getInfoWithCommand:@"select * from record where type = '支出' and date = ?" andCondition:[self.expenseDate objectAtIndex:i] andColumn:@"label"];
        for (int m = 0; m < [exLabel count]; m++) {
            [self.expenseLabel addObject:[exLabel objectAtIndex:m]];
        }
    }
    if ([self.expenseLabel count] >= 2) {
        for (int i = 0; i < [self.expenseLabel count] - 1; i++) {
            for (int j = i + 1; j < [self.expenseLabel count]; j++) {
                if ([[self.expenseLabel objectAtIndex:i] isEqualToString:[self.expenseLabel objectAtIndex:j]]) {
                    [self.expenseLabel removeObjectAtIndex:j];
                    j--;
                }
            }
        }
    }
    for (int i = 0; i < [self.expenseLabel count]; i++) {
        [self.expenseLabelAmount addObject:@"0"];
    }
    for (int i = 0; i < [self.expenseDate count]; i++) {
        for (int m = 0; m < [self.expenseLabel count]; m++) {
            double a = [[DataBase sharedDataBase] getSumAmountWithCommand:@"select * from record where date = ? and label = ?" andCondition1:[self.expenseDate objectAtIndex:i] andCondition2:[self.expenseLabel objectAtIndex:m] andColumn:@"amount"];
            if (a) {
                [self.expenseLabelAmount replaceObjectAtIndex:m withObject:[NSString stringWithFormat:@"%.2lf", [[self.expenseLabelAmount objectAtIndex:m] doubleValue] + a]];
            }
        }
    }
    if ([self.expenseLabel count] >= 2) {
        NSString *str = [[NSString alloc] init];
        for (int i = 0; i < [self.expenseLabel count] - 1; i++) {
            for (int j = i + 1; j < [self.expenseLabel count]; j++) {
                if ([[self.expenseLabelAmount objectAtIndex:i] doubleValue] < [[self.expenseLabelAmount objectAtIndex:j] doubleValue]) {
                    str = [self.expenseLabel objectAtIndex:i];
                    [self.expenseLabel replaceObjectAtIndex:i withObject:[self.expenseLabel objectAtIndex:j]];
                    [self.expenseLabel replaceObjectAtIndex:j withObject:str];
                    str = [self.expenseLabelAmount objectAtIndex:i];
                    [self.expenseLabelAmount replaceObjectAtIndex:i withObject:[self.expenseLabelAmount objectAtIndex:j]];
                    [self.expenseLabelAmount replaceObjectAtIndex:j withObject:str];
                }
            }
        }
    }

    self.expenseRankTableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 250, SCREEN_WIDTH, self.frame.size.height - 250) style:(UITableViewStyleGrouped)];
    self.expenseRankTableview.backgroundColor = [UIColor whiteColor];
    self.expenseRankTableview.delegate = self;
    self.expenseRankTableview.dataSource = self;
    [self addSubview:self.expenseRankTableview];
}

#pragma mark - UITableViewDataSource
//返回每组行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.expenseLabel count];
}

//返回每行单元格
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%ld%ld", indexPath.section, indexPath.row];//以indexPath来唯一确定cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];

        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 7, 36, 36)];
        imageView.layer.cornerRadius = 18;
        [imageView setImage:[UIImage imageNamed:[self.expenseLabel objectAtIndex:indexPath.row]]];
        imageView.backgroundColor = MAIN_COLOR;
        [cell addSubview:imageView];

        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(66, 15, 60, 20)];
        [label setText:[self.expenseLabel objectAtIndex:indexPath.row]];
        [cell addSubview:label];
        [label sizeToFit];

        UILabel *percentageLabel = [[UILabel alloc]initWithFrame:CGRectMake(160, 15, 60, 20)];
        double percentage = [[self.expenseLabelAmount objectAtIndex:indexPath.row] doubleValue] / self.sumExpense * 100;
        [percentageLabel setText:[NSString stringWithFormat:@"%.2lf%%", percentage]];
        [cell addSubview:percentageLabel];
        [label sizeToFit];

        UILabel *amountLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 140, 15, 120, 20)];
        [amountLabel setText:[self.expenseLabelAmount objectAtIndex:indexPath.row]];
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
