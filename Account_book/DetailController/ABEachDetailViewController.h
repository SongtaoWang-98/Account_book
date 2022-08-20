//
//  ABEachDetailViewController.h
//  Account_book
//
//  Created by 王松涛 on 2020/7/25.
//  Copyright © 2020 Songtao Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ABEachDetailViewController : UIViewController

- (instancetype)initWithDetailID:(NSString *)ID andType:(NSString *)type andDate:(NSString *)date andAccount:(NSString *)account andAmount:(NSString *)amount andRemark:(NSString *)remark;

@end

NS_ASSUME_NONNULL_END
