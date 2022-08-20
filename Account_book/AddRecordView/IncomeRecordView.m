//
//  IncomeRecordView.m
//  Account_book
//
//  Created by 王松涛 on 2020/6/23.
//  Copyright © 2020 Songtao Wang. All rights reserved.
//

#import "IncomeRecordView.h"
#import "Definition.h"
#import "MyKeyboardView.h"
@interface IncomeRecordView()

@property (nonatomic, strong, readwrite) UIScrollView *incomeSelectView;
@property (nonatomic, strong, readwrite) MyKeyboardView *mKeyboard;
@property (assign,nonatomic) int buttonNumber;
@property (nonatomic, strong, readwrite) UIButton *currentButton;

@end


@implementation IncomeRecordView

- (instancetype)init{
    self = [super init];
    if(self){
        self.frame = CGRectMake(SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_HEIGHT - STATUS_HEIGHT - 40);
        self.backgroundColor = [UIColor darkGrayColor];
        //支出记录按钮竖向滚动视图
        self.incomeSelectView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.frame.size.height)];
        self.incomeSelectView.backgroundColor = [UIColor whiteColor];
        self.incomeSelectView.contentSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT);
        [self addSubview:self.incomeSelectView];
        //视图上支出方式选择按钮
        [self createButtonWithImage:@"canyin" andTag:300 andName:@"工资"];
        [self createButtonWithImage:@"canyin" andTag:301 andName:@"兼职"];
        [self createButtonWithImage:@"canyin" andTag:302 andName:@"理财"];
        [self createButtonWithImage:@"canyin" andTag:303 andName:@"礼金"];
        [self createButtonWithImage:@"canyin" andTag:304 andName:@"奖金"];
        [self createButtonWithImage:@"canyin" andTag:305 andName:@"补助"];
        [self createButtonWithImage:@"canyin" andTag:306 andName:@"生活费"];
        [self createButtonWithImage:@"canyin" andTag:307 andName:@"其他"];
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
    UIButton *incomeButton = [[UIButton alloc] initWithFrame:CGRectMake(posX, posY, btnSize, btnSize)];
    [incomeButton setBackgroundColor:SHADOW_COLOR];
    incomeButton.layer.cornerRadius = btnSize/2;
    incomeButton.layer.masksToBounds = YES;
    incomeButton.layer.borderWidth = 1.0;
    [self.incomeSelectView addSubview:incomeButton];
    [incomeButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [incomeButton setTag:tag];
    [incomeButton addTarget:self action:@selector(keyboardPopWithButton:) forControlEvents:UIControlEventTouchUpInside];
    UILabel *incomeLabel = [[UILabel alloc] initWithFrame:CGRectMake(posX, posY, 50, 15)];
    [incomeLabel setCenter:CGPointMake((posX * 2 + btnSize) / 2, posY + btnSize + 10)];
    incomeLabel.textAlignment = NSTextAlignmentCenter;
    [incomeLabel setText:name];
    [incomeLabel setFont:[UIFont systemFontOfSize:16]];
    [self.incomeSelectView addSubview:incomeLabel];
    self.buttonNumber += 1;
}

//弹出自定义键盘
- (void)keyboardPopWithButton:(UIButton *)button{
    if(!self.mKeyboard){
        self.mKeyboard = [[MyKeyboardView alloc] initWithFrame:CGRectMake(0, self.frame.size.height, SCREEN_WIDTH, MYKEYBOARD_HEIGHT) andType:@"收入" andButtonTag:button.tag];
        [self addSubview:self.mKeyboard];
        [self.mKeyboard setFrame:CGRectMake(0, self.frame.size.height - MYKEYBOARD_HEIGHT, SCREEN_WIDTH, MYKEYBOARD_HEIGHT)];
        [self.incomeSelectView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.frame.size.height - MYKEYBOARD_HEIGHT)];
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
        [self.incomeSelectView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.frame.size.height)];
        [self.currentButton setBackgroundColor:SHADOW_COLOR];
        self.mKeyboard = nil;
        [self.mKeyboard removeFromSuperview];
    }
}
@end
