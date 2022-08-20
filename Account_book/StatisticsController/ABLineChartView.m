//
//  ABLineChartView.m
//  Account_book
//
//  Created by 王松涛 on 2020/7/19.
//  Copyright © 2020 Songtao Wang. All rights reserved.
//

#import "ABLineChartView.h"
#import "Definition.h"

@implementation ABLineChartView

- (instancetype)initWithValue1:(NSArray *)value1 andValue2:(NSArray *)value2 andXTitles:(NSArray *)xTitles andYTitlesCount:(NSUInteger)count{
    self = [super init];
    if(self){
        [self setBackgroundColor:[UIColor yellowColor]];
        UILabel *dateInMonth = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
        [self addSubview:dateInMonth];
        [dateInMonth setText:[value1 componentsJoinedByString:@","]];
        UILabel *value1Label = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, SCREEN_WIDTH, 30)];
        [self addSubview:value1Label];
        [value1Label setText:[value2 componentsJoinedByString:@","]];
        UILabel *value1Labe2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, SCREEN_WIDTH, 30)];
        [self addSubview:value1Labe2];
        [value1Labe2 setText:[NSString stringWithFormat:@"xtitlecount:%ld",[xTitles count]]];
    }
    return self;
}

@end
