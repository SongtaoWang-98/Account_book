//
//  ABLineChartView.h
//  Account_book
//
//  Created by 王松涛 on 2020/7/19.
//  Copyright © 2020 Songtao Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ABLineChartView : UIView

- (instancetype)initWithValue1:(NSArray *)value1 andValue2:(NSArray *)value2 andXTitles:(NSArray *)xTitles andYTitlesCount:(NSUInteger)count;

@end

NS_ASSUME_NONNULL_END
