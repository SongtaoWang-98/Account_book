//
//  DataBase.m
//  Account_book
//
//  Created by 王松涛 on 2020/6/28.
//  Copyright © 2020 Songtao Wang. All rights reserved.
//

#import "DataBase.h"
#import <FMDB.h>
static DataBase *_DBCtl = nil;

@interface DataBase()

@property(strong, nonatomic) FMDatabase *dataBase;

@end

@implementation DataBase

+ (instancetype)sharedDataBase{
    if(_DBCtl == nil){
        _DBCtl = [[DataBase alloc] init];
        [_DBCtl initDataBase];
    }
    return _DBCtl;
}

- (void)initDataBase{
    // 获得Documents目录路径
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    // 文件路径
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"model.sqlite"];
    NSLog(@"%@",filePath);
    // 实例化FMDataBase对象
    self.dataBase = [FMDatabase databaseWithPath:filePath];
    [self.dataBase open];
    //检测记录表是否存在 若不存在，初始化记录数据表
    int isExistRecordTable = 0;
    FMResultSet *rsR = [self.dataBase executeQuery:@"select name from sqlite_master where name = 'record'"];
    while ([rsR next]) {
        if([[rsR stringForColumn:@"name"] isEqualToString:@"record"]){
            isExistRecordTable = 1;
        }
    }
    //id 日期 星期 类型（收支转） 标签 备注 金额
    if(!isExistRecordTable){
        //初始化记录表
        NSString *recordSql = @"CREATE TABLE 'record' ('id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL ,'date' VARCHAR(255),'type' VARCHAR(255),'account' VARCHAR(255),'label' VARCHAR(255),'remark' VARCHAR(255),'amount' VARCHAR(255))";
        [self.dataBase executeUpdate:recordSql];
    }
    
    //检测账户表是否存在 若不存在，初始化账户数据表
    int isExistAccountTable = 0;
    FMResultSet *rsA = [self.dataBase executeQuery:@"select name from sqlite_master where name = 'account'"];
    while ([rsA next]) {
        if([[rsA stringForColumn:@"name"] isEqualToString:@"account"]){
            isExistAccountTable = 1;
        }
    }
    if(!isExistAccountTable){
        //初始化账户表
        NSString *accountSql = @"CREATE TABLE 'account' ('id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL ,'accountname' VARCHAR(255), 'money' VARCHAR(255), 'accounttype' VARCHAR(255))";
        [self.dataBase executeUpdate:accountSql];
        [self.dataBase executeUpdate:@"INSERT INTO account(accountname,money,accounttype)VALUES(?,?,?)",@"现金",@"0",@"普通账户"];
        [self.dataBase executeUpdate:@"INSERT INTO account(accountname,money,accounttype)VALUES(?,?,?)",@"储蓄卡",@"0",@"普通账户"];
        [self.dataBase executeUpdate:@"INSERT INTO account(accountname,money,accounttype)VALUES(?,?,?)",@"支付宝",@"0",@"普通账户"];
        [self.dataBase executeUpdate:@"INSERT INTO account(accountname,money,accounttype)VALUES(?,?,?)",@"微信",@"0",@"普通账户"];
        [self.dataBase executeUpdate:@"INSERT INTO account(accountname,money,accounttype)VALUES(?,?,?)",@"信用卡",@"0",@"信用账户"];
        [self.dataBase executeUpdate:@"INSERT INTO account(accountname,money,accounttype)VALUES(?,?,?)",@"蚂蚁花呗",@"0",@"信用账户"];
        [self.dataBase executeUpdate:@"INSERT INTO account(accountname,money,accounttype)VALUES(?,?,?)",@"京东白条",@"0",@"信用账户"];
        [self.dataBase executeUpdate:@"INSERT INTO account(accountname,money,accounttype)VALUES(?,?,?)",@"借入",@"0",@"其他"];
        [self.dataBase executeUpdate:@"INSERT INTO account(accountname,money,accounttype)VALUES(?,?,?)",@"借出",@"0",@"其他"];
        [self.dataBase executeUpdate:@"INSERT INTO account(accountname,money,accounttype)VALUES(?,?,?)",@"报销",@"0",@"其他"];
    }
    
    //检测借贷表是否存在 若不存在，初始化表
    int isExistBorrowTable = 0;
    FMResultSet *rsB = [self.dataBase executeQuery:@"select name from sqlite_master where name = 'borrow'"];
    while ([rsB next]) {
        if([[rsB stringForColumn:@"name"] isEqualToString:@"borrow"]){
            isExistBorrowTable = 1;
        }
    }
    //id 日期 类型 借款人 金额 账户
    if(!isExistBorrowTable){
        NSString *borrowSql = @"CREATE TABLE 'borrow' ('id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL ,'type' VARCHAR(255),'name' VARCHAR(255),'amount' VARCHAR(255))";
        [self.dataBase executeUpdate:borrowSql];
    }
    
    [self.dataBase close];
}
#pragma mark - 接口
//添加记录
- (void)addRecord:(Record *)record{
    [self.dataBase open];
    [self.dataBase executeUpdate:@"INSERT INTO record(date,type,account,label,remark,amount)VALUES(?,?,?,?,?,?)",record.date,record.type,record.account,record.label,record.remark,record.amount];
    
    FMResultSet *rsu = [self.dataBase executeQuery:@"SELECT money FROM account WHERE accountname = ?",record.account];
    double moneyNow = 0;
    double moneyUpdate = 0;
    while([rsu next]){
        moneyNow = [[rsu stringForColumn:@"money"] doubleValue];
    }
    if([record.type isEqualToString:@"支出"]){
        moneyUpdate = moneyNow - [record.amount doubleValue];
    }
    else if([record.type isEqualToString:@"收入"]){
        moneyUpdate = moneyNow + [record.amount doubleValue];
    }
    
    [self.dataBase executeUpdate:@"update 'account' set money = ? where accountname = ?",[NSString stringWithFormat:@"%@",@(moneyUpdate)],record.account];
    [self.dataBase close];
}
//删除记录
- (void)deleteRecord:(Record *)record{
    [self.dataBase open];
    [self.dataBase close];
}
//修改记录
- (void)updateRecord:(Record *)record{
    [self.dataBase open];
    [self.dataBase close];
}
//查询数量
- (NSInteger)getNumberWithCommand:(NSString *)command{
    [self.dataBase open];
    NSInteger count = [self.dataBase intForQuery:command];
    [self.dataBase close];
    return count;
}
- (NSInteger)getNumberWithCommand:(NSString *)command andColumn:(NSString *)column{
    [self.dataBase open];
    NSInteger count = [self.dataBase intForQuery:command,column];
    [self.dataBase close];
    return count;
}
//根据命令查询记录
- (NSMutableArray *)getInfoWithCommand:(NSString *)command andColumn:(NSString *)column{
    [self.dataBase open];
    FMResultSet *rs = [self.dataBase executeQuery:command];
    NSMutableArray *infoArray = [[NSMutableArray alloc] init];
    while([rs next]){
        [infoArray addObject:[rs stringForColumn:column]];
    }
    [self.dataBase close];
    return infoArray;
}
- (NSMutableArray *)getInfoWithCommand:(NSString *)command andCondition:(NSString *)condition andColumn:(NSString *)column{
    [self.dataBase open];
    FMResultSet *rs = [self.dataBase executeQuery:command,condition];
    NSMutableArray *infoArray = [[NSMutableArray alloc] init];
    while([rs next]){
        [infoArray addObject:[rs stringForColumn:column]];
    }
    [self.dataBase close];
    return infoArray;
}
- (NSMutableArray *)getInfoWithCommand:(NSString *)command andCondition1:(NSString *)condition1 andCondition2:(NSString *)condition2 andColumn:(NSString *)column{
    [self.dataBase open];
    FMResultSet *rs = [self.dataBase executeQuery:command,condition1,condition2];
    NSMutableArray *infoArray = [[NSMutableArray alloc] init];
    while([rs next]){
        [infoArray addObject:[rs stringForColumn:column]];
    }
    [self.dataBase close];
    return infoArray;
}
//查询某条件下金额总和
- (double)getSumAmountWithCommand:(NSString *)command andCondition:(NSString *)condition andColumn:(NSString *)column{
    [self.dataBase open];
    FMResultSet *rs = [self.dataBase executeQuery:command,condition];
    NSMutableArray *infoArray = [[NSMutableArray alloc] init];
    while([rs next]){
        [infoArray addObject:[rs stringForColumn:column]];
    }
    [self.dataBase close];
    double sum = 0;
    for(int i = 0; i < [infoArray count]; i++){
        sum += [[infoArray objectAtIndex:i] doubleValue];
    }
    return sum;
}
- (double)getSumAmountWithCommand:(NSString *)command andCondition1:(NSString *)condition1 andCondition2:(NSString *)condition2 andColumn:(NSString *)column{
    [self.dataBase open];
    FMResultSet *rs = [self.dataBase executeQuery:command,condition1,condition2];
    NSMutableArray *infoArray = [[NSMutableArray alloc] init];
    while([rs next]){
        [infoArray addObject:[rs stringForColumn:column]];
    }
    [self.dataBase close];
    double sum = 0;
    for(int i = 0; i < [infoArray count]; i++){
        sum += [[infoArray objectAtIndex:i] doubleValue];
    }
    return sum;
}

@end
