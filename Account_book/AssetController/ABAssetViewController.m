//
//  ABAssetViewController.m
//  Account_book
//
//  Created by 王松涛 on 2020/6/8.
//  Copyright © 2020 Songtao Wang. All rights reserved.
//

#import "ABAssetViewController.h"
#import "Definition.h"
#import "DataBase.h"
#import "ABAssetRecordViewController.h"
#import "ABBorrowLendViewController.h"

@interface ABAssetViewController ()<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong, readwrite) UIView *titleView;
@property (nonatomic, strong, readwrite) UICollectionView *collectionView;
@property (nonatomic, strong, readwrite) UILabel *totalAssetsAmount;
@property (nonatomic, strong, readwrite) UILabel *assetAmount;
@property (nonatomic, strong, readwrite) UILabel *debtAmount;
@property (nonatomic, strong, readwrite) UILabel *totalAssetsLabel;
@property (nonatomic, strong, readwrite) UILabel *assetLabel;
@property (nonatomic, strong, readwrite) UILabel *debtLabel;

@end

@implementation ABAssetViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.tabBarItem.title = @"资产";
        self.tabBarItem.image = [UIImage imageNamed:@"icon.bundle/home_normal@2x.png"];
        self.tabBarItem.selectedImage = [[UIImage imageNamed:@"icon.bundle/home_highlight@2x.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//        NSDictionary *dict = [NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName];
//        [self.tabBarItem setTitleTextAttributes:dict forState:UIControlStateSelected];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [DataBase sharedDataBase];

    //上方自定义导航栏
    self.titleView = [[UIView alloc] init];
    self.titleView.backgroundColor = MAIN_COLOR;
    [self.view addSubview:self.titleView];
    //UIClooectionView
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) collectionViewLayout:flowLayout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    //注册Item class
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"MyHeader"];
    [self.view addSubview:self.collectionView];
    //资产情况标题初始化
    self.totalAssetsLabel = [[UILabel alloc] init];
    self.totalAssetsLabel.text = @"总资产（元）";
    [self.titleView addSubview:self.totalAssetsLabel];
    [self.totalAssetsLabel setFont:[UIFont systemFontOfSize:20]];
    self.assetLabel = [[UILabel alloc] init];
    self.assetLabel.text = @"资产：";
    [self.titleView addSubview:self.assetLabel];
    [self.assetLabel setFont:[UIFont systemFontOfSize:18]];
    self.debtLabel = [[UILabel alloc] init];
    self.debtLabel.text = @"负债：";
    [self.titleView addSubview:self.debtLabel];
    [self.debtLabel setFont:[UIFont systemFontOfSize:18]];
    //资产情况数额初始化
    self.totalAssetsAmount = [[UILabel alloc] init];
    [self.titleView addSubview:self.totalAssetsAmount];
    [self.totalAssetsAmount setFont:[UIFont systemFontOfSize:40]];
    self.assetAmount = [[UILabel alloc] init];
    [self.titleView addSubview:self.assetAmount];
    [self.assetAmount setFont:[UIFont systemFontOfSize:18]];
    self.assetAmount.textColor = [UIColor greenColor];
    self.debtAmount = [[UILabel alloc] init];
    [self.titleView addSubview:self.debtAmount];
    [self.debtAmount setFont:[UIFont systemFontOfSize:18]];
    self.debtAmount.textColor = [UIColor redColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.titleView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, ASSETVIEW_HEIGHT)];
    [self.collectionView setFrame:CGRectMake(0, ASSETVIEW_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - ASSETVIEW_HEIGHT)];
    self.navigationController.navigationBarHidden = YES;
    //显示资产状况
    [self showTotalAssets];
    [self.collectionView reloadData];
}

//显示总资产数额
- (void)showTotalAssets {
    double asset = [[DataBase sharedDataBase] getSumAmountWithCommand:@"select * from account where accounttype = '普通账户'" andCondition:@"" andColumn:@"money"] + [[DataBase sharedDataBase] getSumAmountWithCommand:@"select * from account where accounttype = '其他'" andCondition:@"" andColumn:@"money"];
    double debt = -([[DataBase sharedDataBase] getSumAmountWithCommand:@"select * from account where accounttype = '信用账户'" andCondition:@"" andColumn:@"money"] + [[DataBase sharedDataBase] getSumAmountWithCommand:@"select * from account where accountname = '借入'" andCondition:@"" andColumn:@"money"]);
    double totalAssets = asset - debt;
    //更新资产信息格式
    [self.totalAssetsLabel setFrame:CGRectMake(30, STATUS_HEIGHT + 20, 150, 40)];
    [self.totalAssetsLabel sizeToFit];
    [self.totalAssetsAmount setFrame:CGRectMake(28, STATUS_HEIGHT + NAVI_HEIGHT + 15, 150, 40)];
    [self.totalAssetsAmount setText:[NSString stringWithFormat:@"%.2lf", totalAssets]];
    [self.totalAssetsAmount sizeToFit];
    [self.assetLabel setFrame:CGRectMake(30, STATUS_HEIGHT + NAVI_HEIGHT + 75, 30, 15)];
    [self.assetLabel sizeToFit];
    [self.assetAmount setFrame:CGRectMake(80, STATUS_HEIGHT + NAVI_HEIGHT + 75, 30, 15)];
    [self.assetAmount setText:[NSString stringWithFormat:@"%.2lf", asset]];
    [self.assetAmount sizeToFit];
    [self.debtLabel setFrame:CGRectMake(100 + self.assetAmount.bounds.size.width, STATUS_HEIGHT + NAVI_HEIGHT + 75, 30, 15)];
    [self.debtLabel sizeToFit];
    [self.debtAmount setFrame:CGRectMake(150 + self.assetAmount.bounds.size.width, STATUS_HEIGHT + NAVI_HEIGHT + 75, self.debtAmount.bounds.size.width, self.debtAmount.bounds.size.height)];
    [self.debtAmount setText:[NSString stringWithFormat:@"%.2lf", (debt == 0 ? 0 : debt)]];
    [self.debtAmount sizeToFit];
}

//刷新界面
- (void)assetRefresh {
    [self viewWillAppear:YES];
}

#pragma mark - UICollectionViewDelegateFlowLayout

//返回header尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(SCREEN_WIDTH, 40);
}

//返回footer尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeMake(SCREEN_WIDTH, 0);
}

//每一个cell的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(320, 120);
}

//上左下右边界缩进
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(40, (SCREEN_WIDTH - 320) / 2, 40, (SCREEN_WIDTH - 320) / 2);
}

//行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 30;
}

//列间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

#pragma mark - UICollectionViewDataSource
//返回每组cell个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger countPutong = [[DataBase sharedDataBase] getNumberWithCommand:@"select count(*) from account where accounttype = '普通账户'"];
    NSInteger countFuzhai = [[DataBase sharedDataBase] getNumberWithCommand:@"select count(*) from account where accounttype = '信用账户'"];
    NSInteger countQita = [[DataBase sharedDataBase] getNumberWithCommand:@"select count(*) from account where accounttype = '其他'"];
    switch (section) {
        case 0:
            return countPutong;
            break;
        case 1:
            return countFuzhai;
            break;
        case 2:
            return countQita;
            break;
        default:
            return 0;
            break;
    }
}

// 返回Section个数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 3;
}

// 返回cell内容
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UICollectionViewCell" forIndexPath:indexPath];
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }

    cell.contentView.backgroundColor = SHADOW_COLOR;
    cell.contentView.layer.cornerRadius = 20;
    cell.contentView.layer.masksToBounds = YES;
    NSArray *accountnameArray = [[NSArray alloc] init];
    NSArray *moneyArray = [[NSArray alloc] init];
    UIImageView *accountImage = [[UIImageView alloc] init];
    [cell.contentView addSubview:accountImage];
    UILabel *daihuan = [[UILabel alloc] initWithFrame:CGRectMake(100, 57, 30, 15)];
    [daihuan setText:@"待还"];
    [daihuan setFont:[UIFont systemFontOfSize:16]];
    [daihuan sizeToFit];
    switch (indexPath.section) {
        case 0:
            accountnameArray = [[DataBase sharedDataBase] getInfoWithCommand:@"select * from account where accounttype = ?" andCondition:@"普通账户" andColumn:@"accountname"];
            moneyArray = [[DataBase sharedDataBase] getInfoWithCommand:@"select * from account where accounttype = ?" andCondition:@"普通账户" andColumn:@"money"];
            [accountImage setFrame:CGRectMake(-60, 0, 120, 120)];
            [accountImage setImage:[UIImage imageNamed:[accountnameArray objectAtIndex:indexPath.row]]];
            break;
        case 1:
            accountnameArray = [[DataBase sharedDataBase] getInfoWithCommand:@"select * from account where accounttype = ?" andCondition:@"信用账户" andColumn:@"accountname"];
            moneyArray = [[DataBase sharedDataBase] getInfoWithCommand:@"select * from account where accounttype = ?" andCondition:@"信用账户" andColumn:@"money"];
            [accountImage setFrame:CGRectMake(-60, 0, 120, 120)];
            [accountImage setImage:[UIImage imageNamed:[accountnameArray objectAtIndex:indexPath.row]]];
            [cell.contentView addSubview:daihuan];
            break;
        case 2:
            accountnameArray = [[DataBase sharedDataBase] getInfoWithCommand:@"select * from account where accounttype = ?" andCondition:@"其他" andColumn:@"accountname"];
            moneyArray = [[DataBase sharedDataBase] getInfoWithCommand:@"select * from account where accounttype = ?" andCondition:@"其他" andColumn:@"money"];
            [accountImage setFrame:CGRectMake(20, 42, 36, 36)];
            [accountImage setImage:[UIImage imageNamed:[accountnameArray objectAtIndex:indexPath.row]]];
            break;
        default:
            break;
    }
    UILabel *accountnameLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 20, 30, 15)];
    [cell.contentView addSubview:accountnameLabel];
    [accountnameLabel setText:[accountnameArray objectAtIndex:indexPath.row]];
    [accountnameLabel setFont:[UIFont systemFontOfSize:20]];
    [accountnameLabel sizeToFit];

    UILabel *moneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(150, 50, 30, 15)];
    [cell.contentView addSubview:moneyLabel];
    if ([[moneyArray objectAtIndex:indexPath.row]doubleValue] > 0) {
        [moneyLabel setText:[NSString stringWithFormat:@"%.2lf", [[moneyArray objectAtIndex:indexPath.row]doubleValue]]];
        [moneyLabel setTextColor:[UIColor greenColor]];
    } else if ([[moneyArray objectAtIndex:indexPath.row]doubleValue] < 0) {
        [moneyLabel setText:[NSString stringWithFormat:@"%.2lf", -[[moneyArray objectAtIndex:indexPath.row]doubleValue]]];
        [moneyLabel setTextColor:[UIColor redColor]];
    } else {
        [moneyLabel setText:[NSString stringWithFormat:@"%.2lf", [[moneyArray objectAtIndex:indexPath.row]doubleValue]]];
        [moneyLabel setTextColor:[UIColor blackColor]];
    }
    [moneyLabel setFont:[UIFont systemFontOfSize:30]];
    [moneyLabel sizeToFit];
    return cell;
}

//返回Header/Footer内容
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"MyHeader" forIndexPath:indexPath];
    for (UIView *view in headerView.subviews) {
        [view removeFromSuperview];
    }
    headerView.backgroundColor = [UIColor yellowColor];
    UILabel *label = [[UILabel alloc] initWithFrame:headerView.bounds];
    label.textColor = [UIColor blackColor];
    [headerView addSubview:label];
    switch (indexPath.section) {
        case 0:
            label.text = @"普通账户";
            break;
        case 1:
            label.text = @"信用账户";
            break;
        case 2:
            label.text = @"其他";
            break;
        default:
            break;
    }
    return headerView;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *accountnameArray = [[NSArray alloc] init];
    ABAssetRecordViewController *recordController = [[ABAssetRecordViewController alloc] init];
    ABBorrowLendViewController *borrowRecordController = [[ABBorrowLendViewController alloc] init];
    switch (indexPath.section) {
        case 0:
            accountnameArray = [[DataBase sharedDataBase] getInfoWithCommand:@"select * from account where accounttype = ?" andCondition:@"普通账户" andColumn:@"accountname"];
            recordController = [[ABAssetRecordViewController alloc] initWithAccountName:[accountnameArray objectAtIndex:indexPath.row] andAccountType:@"普通账户"];
            [self.navigationController pushViewController:recordController animated:YES];
            break;
        case 1:
            accountnameArray = [[DataBase sharedDataBase] getInfoWithCommand:@"select * from account where accounttype = ?" andCondition:@"信用账户" andColumn:@"accountname"];
            recordController = [[ABAssetRecordViewController alloc] initWithAccountName:[accountnameArray objectAtIndex:indexPath.row] andAccountType:@"信用账户"];
            [self.navigationController pushViewController:recordController animated:YES];
            break;
        case 2:
            accountnameArray = [[DataBase sharedDataBase] getInfoWithCommand:@"select * from account where accounttype = ?" andCondition:@"其他" andColumn:@"accountname"];
            borrowRecordController = [[ABBorrowLendViewController alloc] initWithType:[accountnameArray objectAtIndex:indexPath.row]];
            [self.navigationController pushViewController:borrowRecordController animated:YES];
            break;
        default:
            break;
    }
}

@end
