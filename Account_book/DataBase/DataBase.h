//
//  DataBase.h
//  Account_book
//
//  Created by 王松涛 on 2020/6/28.
//  Copyright © 2020 Songtao Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Record.h"

NS_ASSUME_NONNULL_BEGIN

@interface DataBase : NSObject

+ (instancetype)sharedDataBase;

//添加记录
- (void)addRecord:(Record *)record;
//删除记录
- (void)deleteRecord:(Record *)record;
//修改记录
- (void)updateRecord:(Record *)record;
//查询数量
- (NSInteger)getNumberWithCommand:(NSString *)command;
- (NSInteger)getNumberWithCommand:(NSString *)command andColumn:(NSString *)column;
//根据语句查询某列内容
- (NSMutableArray *)getInfoWithCommand:(NSString *)command andColumn:(NSString *)column;
- (NSMutableArray *)getInfoWithCommand:(NSString *)command andCondition:(NSString *)condition andColumn:(NSString *)column;
- (NSMutableArray *)getInfoWithCommand:(NSString *)command andCondition1:(NSString *)condition1 andCondition2:(NSString *)condition2 andColumn:(NSString *)column;

- (double)getSumAmountWithCommand:(NSString *)command andCondition:(NSString *)condition andColumn:(NSString *)column;
- (double)getSumAmountWithCommand:(NSString *)command andCondition1:(NSString *)condition1 andCondition2:(NSString *)condition2 andColumn:(NSString *)column;


@end

NS_ASSUME_NONNULL_END
