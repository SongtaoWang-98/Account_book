//
//  AddRecordView.m
//  Account_book
//
//  Created by 王松涛 on 2020/6/18.
//  Copyright © 2020 Songtao Wang. All rights reserved.
//

#import "AddRecordView.h"
#import "Definition.h"
#import "ExpenseRecordView.h"
#import "IncomeRecordView.h"

@interface AddRecordView()<UIScrollViewDelegate>

@property (nonatomic, strong, readwrite) UIScrollView *recordSelectView;
@property (nonatomic, strong, readwrite) UIView *recordSelectLabel;
@property (nonatomic, strong, readwrite) UIView *bottomLine;
@property (nonatomic, strong, readwrite) UIButton *currentButton;
@property (nonatomic, strong, readwrite) UIButton *expenseButton;
@property (nonatomic, strong, readwrite) ExpenseRecordView *recordExpenseView;
@property (nonatomic, strong, readwrite) UIButton *incomeButton;
@property (nonatomic, strong, readwrite) IncomeRecordView *recordIncomeView;


@end

@implementation AddRecordView

- (instancetype)init{
    self = [super init];
    if(self){
        self.frame = CGRectMake(0, STATUS_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - STATUS_HEIGHT);
        self.backgroundColor = MAIN_COLOR;        
        //记录收支选择
        self.recordSelectView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 40, SCREEN_WIDTH, self.frame.size.height-40)];
        self.recordSelectView.backgroundColor = MAIN_COLOR;
        self.recordSelectView.contentSize = CGSizeMake(SCREEN_WIDTH * 2, self.frame.size.height-40);
        self.recordSelectView.pagingEnabled = YES;
        self.recordSelectView.showsHorizontalScrollIndicator = NO;
        self.recordSelectView.delegate = self;
        [self addSubview:self.recordSelectView];
        //记录支出视图
        self.recordExpenseView = [[ExpenseRecordView alloc] init];
        [self.recordSelectView addSubview:self.recordExpenseView];
        //记录收入视图
        self.recordIncomeView = [[IncomeRecordView alloc] init];
        [self.recordSelectView addSubview:self.recordIncomeView];
        
        //收入支出标题视图
        self.recordSelectLabel = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 40, 150, 30)];
        self.recordSelectLabel.center = CGPointMake(SCREEN_WIDTH / 2, 25);
        self.recordSelectLabel.backgroundColor = MAIN_COLOR;
        [self addSubview:self.recordSelectLabel];
        //支出标签按钮
        self.expenseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.expenseButton.tag = 0;
        self.expenseButton.frame = CGRectMake(0, 0, 50, 30);
        self.expenseButton.center = CGPointMake(self.recordSelectLabel.frame.size.width/2-30, self.recordSelectLabel.frame.size.height/2-5);
        [self.expenseButton setTitle:@"支出" forState:(UIControlStateNormal)];
        [self.expenseButton setTitleColor:[UIColor grayColor] forState:(UIControlStateNormal)];
        [self.expenseButton setTitleColor:[UIColor blackColor] forState:(UIControlStateDisabled)];
        self.expenseButton.titleLabel.font = [UIFont systemFontOfSize:18];
        [self.expenseButton.titleLabel sizeToFit];
        [self.recordSelectLabel addSubview:self.expenseButton];
        [self.expenseButton addTarget:self action:@selector(selectIndexView:) forControlEvents:UIControlEventTouchUpInside];
        //收入标签按钮
        self.incomeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.incomeButton.tag = 1;
        self.incomeButton.frame = CGRectMake(0, 0, 50, 30);
        self.incomeButton.center = CGPointMake(self.recordSelectLabel.frame.size.width/2+30, self.recordSelectLabel.frame.size.height/2-5);
        [self.incomeButton setTitle:@"收入" forState:(UIControlStateNormal)];
        [self.incomeButton setTitleColor:[UIColor grayColor] forState:(UIControlStateNormal)];
        [self.incomeButton setTitleColor:[UIColor blackColor] forState:(UIControlStateDisabled)];
        self.incomeButton.titleLabel.font = [UIFont systemFontOfSize:18];
        [self.incomeButton.titleLabel sizeToFit];
        [self.recordSelectLabel addSubview:self.incomeButton];
        [self.incomeButton addTarget:self action:@selector(selectIndexView:) forControlEvents:UIControlEventTouchUpInside];
        
        // 右上角关闭按钮
        UIButton *closeBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.frame.size.width - 50, 10, 24, 24)];
        [closeBtn setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        [closeBtn addTarget:self action:@selector(disMissView) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeBtn];
        
        //初始化当前按钮
        self.currentButton = self.expenseButton;
        self.currentButton.enabled = NO;
        //指示器
        self.bottomLine = [[UIView alloc] initWithFrame:CGRectMake(self.expenseButton.frame.origin.x, 28, self.expenseButton.frame.size.width, 2)];
        self.bottomLine.backgroundColor = [UIColor blackColor];
        [self.recordSelectLabel addSubview:self.bottomLine];
        
    }
    return self;
}

//点击标题按钮响应
- (void)selectIndexView:(UIButton *)button {
    self.currentButton.enabled = YES;
    button.enabled = NO;
    self.currentButton = button;
    [self scrollViewDidScroll:self.recordSelectView];
    [UIView animateWithDuration:0.25f animations:^{
        self.bottomLine.frame = CGRectMake(self.currentButton.frame.origin.x, 28, self.currentButton.frame.size.width, 2);
        self.recordSelectView.contentOffset = CGPointMake(button.tag * SCREEN_WIDTH, 0);
    }];
}

// 展示从底部向上弹出的UIView
- (void)showInView {
    [[[[UIApplication sharedApplication] windows] objectAtIndex:0] addSubview:self];
    [self setFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - STATUS_HEIGHT)];
    [UIView animateWithDuration:0.35f animations:^{
        [self setFrame:CGRectMake(0, STATUS_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - STATUS_HEIGHT)];
    } completion:nil];
}

// 移除从上向底部弹下去的UIView
- (void)disMissView {
    [self setFrame:CGRectMake(0, STATUS_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - STATUS_HEIGHT)];
    [UIView animateWithDuration:0.3f animations:^{
        [self setFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT)];
    }completion:^(BOOL finished){
        [self removeFromSuperview];
    }];
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.recordExpenseView keyboardDisappear];
    [self.recordIncomeView keyboardDisappear];
    //当offset切换至第二个屏幕时，切换标签及指示器
    CGFloat offsetRate = self.recordSelectView.contentOffset.x/SCREEN_WIDTH;
    if(offsetRate==1 && self.currentButton==self.expenseButton){
        self.currentButton.enabled = YES;
        self.incomeButton.enabled = NO;
        self.currentButton = self.incomeButton;
    }
    else if (offsetRate==0 && self.currentButton==self.incomeButton){
        self.incomeButton.enabled = YES;
        self.expenseButton.enabled = NO;
        self.currentButton = self.expenseButton;
    }
    CGFloat buttonDistance = self.incomeButton.frame.origin.x - self.expenseButton.frame.origin.x;
    self.bottomLine.frame = CGRectMake(self.expenseButton.frame.origin.x + buttonDistance * offsetRate, 28, self.currentButton.frame.size.width, 2);
}

@end
