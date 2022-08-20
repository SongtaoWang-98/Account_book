//
//  Record.h
//  Account_book
//
//  Created by 王松涛 on 2020/6/29.
//  Copyright © 2020 Songtao Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Record : NSObject

//@property(assign, nonatomic) int ID;
@property(copy, nonatomic) NSString * date;
@property(copy, nonatomic) NSString * type;
@property(copy, nonatomic) NSString * account;
@property(copy, nonatomic) NSString *label;
@property(copy, nonatomic) NSString *remark;
@property(copy, nonatomic) NSString * amount;

- (instancetype)initWithDate:(NSString *)date andType:(NSString *)type andAccount:(NSString *)account andLabel:(NSString *)label andRemark:(NSString *)remark andAmount:(NSString *)amount;

@end

NS_ASSUME_NONNULL_END
