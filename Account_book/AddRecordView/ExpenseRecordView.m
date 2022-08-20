//
//  ExpenseRecordView.m
//  Account_book
//
//  Created by 王松涛 on 2020/6/23.
//  Copyright © 2020 Songtao Wang. All rights reserved.
//

#import "ExpenseRecordView.h"
#import "Definition.h"
#import "MyKeyboardView.h"
@interface ExpenseRecordView()

@property (nonatomic, strong, readwrite) UIScrollView *expenseSelectView;
@property (nonatomic, strong, readwrite) MyKeyboardView *mKeyboard;
@property (assign,nonatomic) int buttonNumber;
@property (nonatomic, strong, readwrite) UIButton *currentButton;

@end

@implementation ExpenseRecordView

- (instancetype)init{
    self = [super init];
    if(self){
        self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - STATUS_HEIGHT - 40);
        self.backgroundColor = [UIColor darkGrayColor];
        self.buttonNumber = 0;
        self.currentButton = nil;
        //支出记录按钮竖向滚动视图
        self.expenseSelectView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.frame.size.height)];
        self.expenseSelectView.backgroundColor = [UIColor whiteColor];
        self.expenseSelectView.contentSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT);
        [self addSubview:self.expenseSelectView];
        //视图上支出方式选择按钮
        [self createButtonWithImage:@"canyin" andTag:200 andName:@"餐饮"];
        [self createButtonWithImage:@"canyin" andTag:201 andName:@"购物"];
        [self createButtonWithImage:@"canyin" andTag:202 andName:@"日用"];
        [self createButtonWithImage:@"canyin" andTag:203 andName:@"交通"];
        [self createButtonWithImage:@"canyin" andTag:204 andName:@"蔬菜"];
        [self createButtonWithImage:@"canyin" andTag:205 andName:@"水果"];
        [self createButtonWithImage:@"canyin" andTag:206 andName:@"零食"];
        [self createButtonWithImage:@"canyin" andTag:207 andName:@"运动"];
        [self createButtonWithImage:@"canyin" andTag:208 andName:@"娱乐"];
        [self createButtonWithImage:@"canyin" andTag:209 andName:@"通讯"];
        [self createButtonWithImage:@"canyin" andTag:210 andName:@"服饰"];
        [self createButtonWithImage:@"canyin" andTag:211 andName:@"美容"];
        [self createButtonWithImage:@"canyin" andTag:212 andName:@"住房"];
        [self createButtonWithImage:@"canyin" andTag:213 andName:@"居家"];
        [self createButtonWithImage:@"canyin" andTag:214 andName:@"孩子"];
        [self createButtonWithImage:@"canyin" andTag:215 andName:@"长辈"];
        [self createButtonWithImage:@"canyin" andTag:216 andName:@"社交"];
        [self createButtonWithImage:@"canyin" andTag:217 andName:@"旅行"];
        [self createButtonWithImage:@"canyin" andTag:218 andName:@"烟酒"];
        [self createButtonWithImage:@"canyin" andTag:219 andName:@"数码"];
        [self createButtonWithImage:@"canyin" andTag:220 andName:@"汽车"];
        [self createButtonWithImage:@"canyin" andTag:221 andName:@"医疗"];
        [self createButtonWithImage:@"canyin" andTag:222 andName:@"礼金"];
        [self createButtonWithImage:@"canyin" andTag:223 andName:@"学习"];
        [self createButtonWithImage:@"canyin" andTag:224 andName:@"宠物"];
        [self createButtonWithImage:@"canyin" andTag:225 andName:@"礼物"];
        [self createButtonWithImage:@"canyin" andTag:226 andName:@"维修"];
        [self createButtonWithImage:@"canyin" andTag:227 andName:@"捐赠"];
        [self createButtonWithImage:@"canyin" andTag:228 andName:@"游戏"];
        [self createButtonWithImage:@"canyin" andTag:229 andName:@"其他"];
    }
    return self;
}
//新建一个按钮
- (void)createButtonWithImage:(NSString *)imageName andTag:(int)tag andName:(NSString *)name{
    float btnSize = 40;
    float hWidth = (SCREEN_WIDTH - btnSize * 5 - 20 * 2)/4;
    float vWidth = 20;
    float posX = vWidth + (self.buttonNumber % 5) * (btnSize + hWidth);
    float posY = vWidth + floor(self.buttonNumber / 5) * (btnSize + vWidth + 20);
    UIButton *expenseButton = [[UIButton alloc] initWithFrame:CGRectMake(posX, posY, btnSize, btnSize)];
    [expenseButton setBackgroundColor:SHADOW_COLOR];
    expenseButton.layer.cornerRadius = btnSize/2;
    expenseButton.layer.masksToBounds = YES;
    expenseButton.layer.borderWidth = 1.0;
    [self.expenseSelectView addSubview:expenseButton];
    [expenseButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [expenseButton setTag:tag];
    [expenseButton addTarget:self action:@selector(keyboardPopWithButton:) forControlEvents:UIControlEventTouchUpInside];
    UILabel *expenseLabel = [[UILabel alloc] initWithFrame:CGRectMake(posX, posY, 50, 15)];
    [expenseLabel setCenter:CGPointMake((posX * 2 + btnSize) / 2, posY + btnSize + 10)];
    expenseLabel.textAlignment = NSTextAlignmentCenter;
    [expenseLabel setText:name];
    [expenseLabel setFont:[UIFont systemFontOfSize:16]];
    [self.expenseSelectView addSubview:expenseLabel];
    self.buttonNumber += 1;
}

//弹出自定义键盘
- (void)keyboardPopWithButton:(UIButton *)button{
    if(!self.mKeyboard){
        self.mKeyboard = [[MyKeyboardView alloc] initWithFrame:CGRectMake(0, self.frame.size.height, SCREEN_WIDTH, MYKEYBOARD_HEIGHT) andType:@"支出" andButtonTag:button.tag];
        [self addSubview:self.mKeyboard];
        [self.mKeyboard setFrame:CGRectMake(0, self.frame.size.height - MYKEYBOARD_HEIGHT, SCREEN_WIDTH, MYKEYBOARD_HEIGHT)];
        [self.expenseSelectView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.frame.size.height - MYKEYBOARD_HEIGHT)];
        self.currentButton = button;
        [self.currentButton setBackgroundColor:MAIN_COLOR];
    }
    else{
        [self.mKeyboard removeFromSuperview];
        self.mKeyboard = nil;
        [self.currentButton setBackgroundColor:SHADOW_COLOR];
        [self keyboardPopWithButton:button];
    }
}
//自定义键盘消失
- (void)keyboardDisappear{
    if(self.mKeyboard){
        [self.mKeyboard setFrame:CGRectMake(0, self.frame.size.height, SCREEN_WIDTH, MYKEYBOARD_HEIGHT)];
        [self.expenseSelectView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.frame.size.height)];
        [self.mKeyboard removeFromSuperview];
        self.mKeyboard = nil;
        [self.currentButton setBackgroundColor:SHADOW_COLOR];
    }
}
@end
