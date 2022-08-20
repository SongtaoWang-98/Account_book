//
//  MyKeyboardView.h
//  Account_book
//
//  Created by 王松涛 on 2020/6/23.
//  Copyright © 2020 Songtao Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface MyKeyboardView : UIView

- (instancetype)initWithFrame:(CGRect)frame andType:(NSString *)type andButtonTag:(NSInteger)tag;

@end

NS_ASSUME_NONNULL_END
