//
//  MyKeyboardView.m
//  Account_book
//
//  Created by 王松涛 on 2020/6/23.
//  Copyright © 2020 Songtao Wang. All rights reserved.
//

#import "MyKeyboardView.h"
#import "Definition.h"
#import "DataBase.h"
#import "ABDetailViewController.h"
#import "ABAssetViewController.h"
#import "ABStatisticsViewController.h"

#define TOPBAR_HEIGHT    50
#define BOTTOMBAR_HEIGHT 24
#define REMARK_HEIGHT    50

@interface MyKeyboardView ()<UITableViewDelegate, UITableViewDataSource>

//自定义键盘相关属性
@property (strong, nonatomic) UITextField *m_textField;//计算器数字shu
@property (strong, nonatomic) UIButton *btnPayment;
@property (strong, nonatomic) UIButton *btnNotes;
@property (strong, nonatomic) UILabel *notesText;
@property (strong, nonatomic) UIView *topView;
@property (strong, nonatomic) UIButton *btnFinish;//完成按钮
@property (strong, nonatomic) UIButton *btnEqual;//等于按钮
@property (strong, nonatomic) UIButton *btnDate;//日期按钮
//选择账户
@property (strong, nonatomic) UIView *accountSelectView;//账户选择界面
@property (strong, nonatomic) UITableView *accountTableView;//账户选择table
@property (strong, nonatomic) UIButton *accountClose;//账户选择关闭按钮

//添加备注
@property (strong, nonatomic) UIView *remarkView;//备注输入界面
@property (strong, nonatomic) UIView *shadeView;//遮罩层
@property (strong, nonatomic) UIButton *btnOK;//备注确认按钮
@property (strong, nonatomic) UITextField *remarkField;//备注输入框
//添加日期
@property (strong, nonatomic) UIView *dateSelectView;//日期选择界面
@property (strong, nonatomic) UIButton *dateConfirm;//日期选择确认按钮
@property (strong, nonatomic) UIButton *dateCancel;//日期选择取消按钮
@property (strong, nonatomic) UIDatePicker *datePicker;//日期选择控件
//数据库交互相关属性
@property (nonatomic, strong) NSDate *dateSelected;//当前时间选择
@property (nonatomic, strong) NSDateFormatter *dateFormatter;//时间格式化
@property (nonatomic, copy) NSString *dateSelectedString;//当前时间字符串
@property (nonatomic, copy) NSString *type;//当前页面类型（收入/支出/转账）
@property (nonatomic, copy) NSString *label;//标签
@property (nonatomic, copy) NSString *account;//账户
@property (nonatomic, copy) NSString *remark;//备注
//计算器相关属性
@property (nonatomic, copy) NSString *preText;//前面的数
@property (nonatomic, copy) NSString *text;//当前显示的数
@property (nonatomic, copy) NSString *operaType; /**< 点击了哪个运算符 */

@end

@implementation MyKeyboardView

static int maxLength = 10;

- (instancetype)initWithFrame:(CGRect)frame andType:(NSString *)type andButtonTag:(NSInteger)tag {
    self = [super initWithFrame:frame];
    if (self) {
        [self createTopBar];
        [self createRemarkView];
        [self createBottomBar];

        float keyWidth = (self.frame.size.width - 3) / 4;
        float keyHeight = (self.frame.size.height - BOTTOMBAR_HEIGHT - TOPBAR_HEIGHT - 6) / 4;
        for (int i = 1; i < 10; ++i) {
            [self createKey:[NSString stringWithFormat:@"%d", i] posX:((keyWidth + 1) * ((i - 1) % 3)) posY:(TOPBAR_HEIGHT + 2 + (keyHeight + 1) * ((i - 1) / 3)) width:keyWidth height:keyHeight tag:(100 + i)];
        }
        [self createKey:@"." posX:0 posY:(TOPBAR_HEIGHT + 2 + (keyHeight + 1) * 3) width:keyWidth height:keyHeight tag:110];
        [self createKey:@"0" posX:(keyWidth + 1) posY:(TOPBAR_HEIGHT + 2 + (keyHeight + 1) * 3) width:keyWidth height:keyHeight tag:100];
        [self createKey:@"清零" posX:(keyWidth * 2 + 2) posY:(TOPBAR_HEIGHT + 2 + (keyHeight + 1) * 3) width:keyWidth height:keyHeight tag:111];
        [self createKey:@"+" posX:(keyWidth + 1) * 3 posY:(TOPBAR_HEIGHT + 2 + (keyHeight + 1)) width:keyWidth height:keyHeight tag:112];
        [self createKey:@"-" posX:(keyWidth + 1) * 3 posY:(TOPBAR_HEIGHT + 2 + (keyHeight + 1) * 2) width:keyWidth height:keyHeight tag:113];

        //单独设置日期选择按键，以显示当前选择日期
        self.btnDate = [[UIButton alloc]initWithFrame:CGRectMake((keyWidth + 1) * 3, TOPBAR_HEIGHT + 2, keyWidth, keyHeight)];
        [self.btnDate setTag:115];
        [self addSubview:self.btnDate];
        self.btnDate.titleLabel.adjustsFontSizeToFitWidth = YES;
        [self.btnDate addTarget:self action:@selector(buttonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.btnDate setTitle:@"今天" forState:UIControlStateNormal];
        self.btnDate.titleLabel.font = [UIFont systemFontOfSize:16];
        [self.btnDate setImage:[UIImage imageNamed:@"calendar"] forState:UIControlStateNormal];
        [self.btnDate setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.btnDate setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
        [self.btnDate setBackgroundColor:[UIColor whiteColor]];
        [self.btnDate setBackgroundImage:[self createImageWithColor:[UIColor orangeColor] andSize:CGSizeMake(keyWidth, keyHeight)] forState:UIControlStateHighlighted];

        //单独设置=与完成键，并根据键入数据进行显示替换
        self.btnEqual = [[UIButton alloc]initWithFrame:CGRectMake((keyWidth + 1) * 3, (TOPBAR_HEIGHT + 2 + (keyHeight + 1) * 3), keyWidth, keyHeight)];
        [self.btnEqual setTag:114];
        [self.btnEqual addTarget:self action:@selector(buttonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.btnEqual setTitle:@"=" forState:UIControlStateNormal];
        [self.btnEqual setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
        [self.btnEqual setBackgroundColor:[UIColor lightGrayColor]];
        [self.btnEqual setBackgroundImage:[self createImageWithColor:[UIColor orangeColor] andSize:CGSizeMake(keyWidth, keyHeight)] forState:UIControlStateHighlighted];

        self.btnFinish = [[UIButton alloc]initWithFrame:CGRectMake((keyWidth + 1) * 3, (TOPBAR_HEIGHT + 2 + (keyHeight + 1) * 3), keyWidth, keyHeight)];
        [self.btnFinish setTag:116];
        [self addSubview:self.btnFinish];
        [self.btnFinish addTarget:self action:@selector(buttonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.btnFinish setTitle:@"完成" forState:UIControlStateNormal];
        [self.btnFinish setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [self.btnFinish setBackgroundColor:MAIN_COLOR];
        [self.btnFinish setBackgroundImage:[self createImageWithColor:[UIColor blackColor] andSize:CGSizeMake(keyWidth, keyHeight)] forState:UIControlStateHighlighted];
        //时间格式化
        self.dateFormatter = [[NSDateFormatter alloc] init];
        [self.dateFormatter setDateFormat:@"yyyy-MM-dd"];
        //初始化
        self.text = @"";
        self.preText = @"";
        self.operaType = @"";
        self.dateSelected = [NSDate date];
        self.dateSelectedString = [self.dateFormatter stringFromDate:self.dateSelected];
        self.type = type;
        self.label = [self labelSelected:tag];
        self.account = @"";
        self.remark = @"";
    }
    return self;
}

#pragma mark - 自定义键盘视图
- (void)createTopBar {
    //自定义键盘上方视图
    self.topView = [[UIView alloc] init];
    [self.topView setBackgroundColor:SHADOW_COLOR];
    [self addSubview:self.topView];
    self.topView.frame = CGRectMake(0, 1, CGRectGetWidth(self.frame), TOPBAR_HEIGHT);
    //输入框视图
    self.m_textField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.topView.frame) / 2, 0, CGRectGetWidth(self.topView.frame) / 2, CGRectGetHeight(self.topView.frame))];
    [self.topView addSubview:self.m_textField];
    self.m_textField.placeholder = @"0.00";
    self.m_textField.adjustsFontSizeToFitWidth = YES;
    self.m_textField.font = [UIFont systemFontOfSize:30];
    self.m_textField.textAlignment = NSTextAlignmentRight;
    [self.m_textField setEnabled:NO];

    //添加支付方式按钮
    self.btnPayment = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, TOPBAR_HEIGHT, TOPBAR_HEIGHT)];
    [self.topView addSubview:self.btnPayment];
    [self.btnPayment setImage:[UIImage imageNamed:@"notselected"] forState:UIControlStateNormal];
    [self.btnPayment setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.btnPayment.layer.cornerRadius = TOPBAR_HEIGHT / 2;
    self.btnPayment.layer.borderWidth = 1.5;
    [self.btnPayment setBackgroundColor:[UIColor whiteColor]];
    [self.btnPayment addTarget:self action:@selector(accountSelectViewPop) forControlEvents:UIControlEventTouchUpInside];

    self.btnNotes = [[UIButton alloc]initWithFrame:CGRectMake(TOPBAR_HEIGHT + 4, 0, TOPBAR_HEIGHT + 10, TOPBAR_HEIGHT)];
    [self.topView addSubview:self.btnNotes];
    [self.btnNotes setTitle:@"备注" forState:UIControlStateNormal];
    [self.btnNotes setImage:[UIImage imageNamed:@"notes"] forState:UIControlStateNormal];
    self.btnNotes.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.btnNotes setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.btnNotes addTarget:self action:@selector(showKeyboard) forControlEvents:UIControlEventTouchUpInside];

    self.notesText = [[UILabel alloc] initWithFrame:CGRectMake(TOPBAR_HEIGHT * 2 + 16, 0, SCREEN_WIDTH / 2 - (TOPBAR_HEIGHT * 2 + 16), TOPBAR_HEIGHT)];
    [self.topView addSubview:self.notesText];
    [self.notesText setTextColor:[UIColor blackColor]];
}

//自定义键盘下方设置安全区域
- (void)createBottomBar {
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - BOTTOMBAR_HEIGHT, self.frame.size.width, BOTTOMBAR_HEIGHT)];
    [bottomView setBackgroundColor:SHADOW_COLOR];
    [self addSubview:bottomView];
}

//创建每一个按钮
- (void)createKey:(NSString *)title posX:(float)posX posY:(float)posY width:(float)width height:(float)height tag:(NSInteger)tag {
    UIButton *btnKey = [[UIButton alloc]initWithFrame:CGRectMake(posX, posY, width, height)];
    [btnKey setTag:tag];
    [self addSubview:btnKey];
    [btnKey addTarget:self action:@selector(buttonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [btnKey setTitle:title forState:UIControlStateNormal];
    btnKey.titleLabel.font = [UIFont systemFontOfSize:20];
    [btnKey setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnKey setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [btnKey setBackgroundColor:SHADOW_COLOR];
    [btnKey setBackgroundImage:[self createImageWithColor:[UIColor lightGrayColor] andSize:CGSizeMake(width, height)] forState:UIControlStateHighlighted];
}

//将颜色转换为图片作为按键背景
- (UIImage *)createImageWithColor:(UIColor *)color andSize:(CGSize)size {
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

- (void)showKeyboard {
    [self.remarkField becomeFirstResponder];
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
    if (!self.shadeView) {
        self.shadeView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        self.shadeView.backgroundColor = [UIColor colorWithRed:(33 / 255.0)  green:(33 / 255.0)  blue:(33 / 255.0) alpha:0];
        UITapGestureRecognizer *centerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shadeViewClick)];
        [self.shadeView addGestureRecognizer:centerTap];
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

//// 返回 Cell 是否在滑动时是否可以编辑
//-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath;
//// 返回 Cell 是否可以移动
//-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath;
//// TableView 右侧建立一个索引表需要的数组内容
//-(NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView;

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
    [self.btnPayment setImage:[UIImage imageNamed:text] forState:UIControlStateNormal];
    [self accountSelectViewHide];
}

#pragma mark - 备注输入
//自定义备注输入框&遮罩层
- (void)createRemarkView {
    self.remarkView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, REMARK_HEIGHT)];
    self.remarkView.backgroundColor = [UIColor lightGrayColor];
    self.remarkView.layer.borderWidth = 0.7;
    [[[[UIApplication sharedApplication] windows] objectAtIndex:0] addSubview:self.remarkView];

    self.btnOK = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 72, 4, 60, 45)];
    self.btnOK.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    [self.btnOK setTitle:@"OK" forState:UIControlStateNormal];
    [self.btnOK addTarget:self action:@selector(senderClick) forControlEvents:UIControlEventTouchUpInside];
    [self.remarkView addSubview:self.btnOK];

    self.remarkField = [[UITextField alloc] initWithFrame:CGRectMake(10, 4, SCREEN_WIDTH - 72 - 10, 42)];
    self.remarkField.placeholder = @"输入备注信息";
    self.remarkField.layer.cornerRadius = 5;
    self.remarkField.layer.masksToBounds = YES;
    self.remarkField.backgroundColor = [UIColor lightGrayColor];
    self.remarkField.secureTextEntry = NO;
    [self.remarkView addSubview:self.remarkField];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

//点击OK 键盘隐藏
- (void)senderClick {
    [self.remarkField endEditing:YES];
    self.remark = self.remarkField.text;
    [self.notesText setText:self.remark];
}

//点击遮罩层键盘隐藏
- (void)shadeViewClick {
    [self.remarkField endEditing:YES];
}

#pragma mark -键盘监听方法
- (void)keyBoardWillShow:(NSNotification *)notification
{
//     获取用户信息
    NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:notification.userInfo];
    // 获取键盘高度
    CGRect keyBoardBounds = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyBoardHeight = keyBoardBounds.size.height;
    // 获取键盘动画时间
    CGFloat animationTime = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    // 设置遮罩层
    if (!self.shadeView) {
        self.shadeView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        self.shadeView.backgroundColor = [UIColor colorWithRed:(33 / 255.0)  green:(33 / 255.0)  blue:(33 / 255.0) alpha:0];
        UITapGestureRecognizer *centerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shadeViewClick)];
        [self.shadeView addGestureRecognizer:centerTap];
        [[[[UIApplication sharedApplication] windows] objectAtIndex:0] addSubview:self.shadeView];
        [[[[UIApplication sharedApplication] windows] objectAtIndex:0] addSubview:self.remarkView];
    }
    // 定义好动作
    void (^ animation)(void) = ^void (void) {
        self.remarkView.transform = CGAffineTransformMakeTranslation(0, -(keyBoardHeight + 50));
        self.shadeView.backgroundColor = [UIColor colorWithRed:(33 / 255.0)  green:(33 / 255.0)  blue:(33 / 255.0) alpha:0.2];
    };
    if (animationTime > 0) {
        [UIView animateWithDuration:animationTime animations:animation];
    } else {
        animation();
    }
}

- (void)keyBoardWillHide:(NSNotification *)notificaiton
{
    //获取用户信息
    NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:notificaiton.userInfo];
    //获取键盘动画时间
    CGFloat animationTime = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    //定义好动作
    void (^ animation)(void) = ^void (void) {
        self.remarkView.transform = CGAffineTransformIdentity;
    };
    if (animationTime > 0) {
        self.shadeView.backgroundColor = [UIColor colorWithRed:(33 / 255.0)  green:(33 / 255.0)  blue:(33 / 255.0) alpha:0];
        [UIView animateWithDuration:animationTime animations:animation];
    } else {
        animation();
    }
    [self.shadeView removeFromSuperview];
    self.shadeView = nil;
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

#pragma mark - 键盘按键响应
//根据tag区分每一个按钮分别的响应
- (void)buttonDidClicked:(UIButton *)button {
    //tag 100-109 0,1,2,3,4,5,6,7,8,9
    //110 111 112 113 114 115 116
    //.  清零  +   -   =   今天 完成
    switch (button.tag) {
        case 100: {
            //输入0:当前没有数字输入或者当前数字不为0时后添加0
            if (self.text.length == 0 || (self.text.length && ![self.text isEqualToString:@"0"] && self.text.length < maxLength)) {
                self.text = [self.text stringByAppendingString:button.currentTitle];
            }
        }
        break;
        case 101:
        case 102:
        case 103:
        case 104:
        case 105:
        case 106:
        case 107:
        case 108:
        case 109: {
            //输入1-9：当前为0则替换为输入数字，否则后面添加输入数字
            if ([self.text isEqualToString:@"0"]) {
                self.text = button.currentTitle;
            } else if (self.text.length < maxLength) {
                if ([self.text containsString:@"."]) {
                    //只能输入小数点后两位
                    if ([[self.text componentsSeparatedByString:@"."] objectAtIndex:1].length < 2) {
                        self.text = [self.text stringByAppendingString:button.currentTitle];
                    }
                } else {
                    self.text = [self.text stringByAppendingString:button.currentTitle];
                }
            }
        }
        break;
        case 110:
            //输入小数点：
            if (self.text.length) {
                if (![self.text containsString:@"."]) {
                    self.text = [self.text stringByAppendingString:button.currentTitle];
                }
            } else {
                self.text = @"0.";
            }
            break;
        case 111: {
            //清零，同时清零当前数字和之前数字
            self.text = @"";
            self.preText = @"";
            self.operaType = @"";
        }
        break;
        case 112:
        case 113: {
            //+-:若输入第一个数据且没有符号输入，增加符号
            if (!self.operaType.length && self.text.length) {
                self.operaType = button.currentTitle;
                self.preText = self.text;
                self.text = @"";
                [self addSubview:self.btnEqual];
            }
            //若输入了两个数据且有符号输入，计算并将结果作为第一个数据且增加符号
            else if (self.operaType.length && self.text.length && self.preText.length) {
                [self calculator];
                self.operaType = button.currentTitle;
                self.preText = self.text;
                self.text = @"";
                [self addSubview:self.btnEqual];
            }
        }
        break;
        case 114: {
            //=
            if (self.text.length && self.preText.length && self.operaType.length) {
                [self calculator];
                [self.btnEqual removeFromSuperview];
            }
        }
        break;
        case 115: {
            //选择日期
            [self dateSelectPop];
        }
        break;
        case 116: {
            //完成
            if (self.text.length) {
                if([self.account isEqualToString:@""]){
                    [self.btnPayment setBackgroundColor:[UIColor colorWithRed:220/255.0 green:20/255.0 blue:60/255.0 alpha:1]];
                    [UIView animateWithDuration:0.3f animations:^{
                        [self.btnPayment setBackgroundColor:[UIColor colorWithRed:220/255.0 green:20/255.0 blue:60/255.0 alpha:0]];
                    } completion:^(BOOL finished) {
                    }];
                }
                else{
                    Record *currentRecord = [[Record alloc] initWithDate:self.dateSelectedString andType:self.type andAccount:self.account andLabel:self.label andRemark:self.remark andAmount:self.text];
                    [[DataBase sharedDataBase]addRecord:currentRecord];
                    currentRecord = nil;
                    self.text = @"";
                    //如果位于账户或明细界面，关闭键盘前刷新界面
                    if ([[self findCurrentViewController] isMemberOfClass:[ABDetailViewController class]]) {
                        ABDetailViewController *vc = [self findCurrentViewController];
                        [vc detailRefresh];
                    } else if ([[self findCurrentViewController] isMemberOfClass:[ABAssetViewController class]]) {
                        ABAssetViewController *vc = [self findCurrentViewController];
                        [vc assetRefresh];
                    } else if ([[self findCurrentViewController] isMemberOfClass:[ABStatisticsViewController class]]) {
                        ABStatisticsViewController *vc = [self findCurrentViewController];
                        [vc statisticsRefresh];
                    }
                    [UIView animateWithDuration:0.3f animations:^{
                        [self.superview.superview.superview setFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT)];
                    } completion:^(BOOL finished) {
                        [self.superview.superview.superview removeFromSuperview];
                    }];
                }
            }
        }
        break;
        default:
            break;
    }
    self.m_textField.text = [[self.preText stringByAppendingString:self.operaType]stringByAppendingString:self.text];
}

#pragma mark - 计算器
//计算结果并输出有效位
- (void)calculator {
    NSDecimalNumber *result = [[NSDecimalNumber alloc] init];
    NSDecimalNumber *preNum = [NSDecimalNumber decimalNumberWithString:self.preText];
    NSDecimalNumber *num = [NSDecimalNumber decimalNumberWithString:self.text];
    if ([self.operaType isEqualToString:@"+"]) {
        result = [preNum decimalNumberByAdding:num];
    } else if ([self.operaType isEqualToString:@"-"]) {
        result = [preNum decimalNumberBySubtracting:num];
    }
    self.operaType = @"";
    self.preText = @"";
    self.text = [NSString stringWithFormat:@"%@", result];
}

#pragma mark - 功能label对应
//根据按钮tag返回按钮对应label
- (NSString *)labelSelected:(NSInteger)num {
    NSString *theLabel = @"";
    if ([self.type isEqualToString:@"支出"]) {
        NSArray *labels = [NSArray arrayWithObjects:@"餐饮", @"购物", @"日用", @"交通", @"蔬菜", @"水果", @"零食", @"运动", @"娱乐", @"通讯", @"服饰", @"美容", @"住房", @"居家", @"孩子", @"长辈", @"社交", @"旅行", @"烟酒", @"数码", @"汽车", @"医疗", @"礼金", @"学习", @"宠物", @"礼物", @"维修", @"捐赠", @"游戏", @"其他", nil];
        theLabel = [labels objectAtIndex:(num - 200)];
    } else if ([self.type isEqualToString:@"收入"]) {
        NSArray *labels = [NSArray arrayWithObjects:@"工资", @"兼职", @"理财", @"礼金", @"奖励", @"补助", @"生活费", @"其他", nil];
        theLabel = [labels objectAtIndex:(num - 300)];
    }
    return theLabel;
}

- (id)findCurrentViewController
{
    UIWindow *window = [[[UIApplication sharedApplication]windows]objectAtIndex:0];
    UIViewController *topViewController = [window rootViewController];

    while (true) {
        if (topViewController.presentedViewController) {
            topViewController = topViewController.presentedViewController;
        } else if ([topViewController isKindOfClass:[UINavigationController class]] && [(UINavigationController *)topViewController topViewController]) {
            topViewController = [(UINavigationController *)topViewController topViewController];
        } else if ([topViewController isKindOfClass:[UITabBarController class]]) {
            UITabBarController *tab = (UITabBarController *)topViewController;
            topViewController = tab.selectedViewController;
        } else {
            break;
        }
    }
    return topViewController;
}

@end
