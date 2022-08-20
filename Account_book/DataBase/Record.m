//
//  Record.m
//  Account_book
//
//  Created by 王松涛 on 2020/6/29.
//  Copyright © 2020 Songtao Wang. All rights reserved.
//

#import "Record.h"

@implementation Record

- (instancetype)initWithDate:(NSString *)date andType:(NSString *)type andAccount:(NSString *)account andLabel:(NSString *)label andRemark:(NSString *)remark andAmount:(NSString *)amount{
    self = [super init];
    if(self){
        self.date = date;
        self.type = type;
        self.account = account;
        self.label = label;
        self.remark = remark;
        self.amount = amount;
    }
    return self;
}

@end
