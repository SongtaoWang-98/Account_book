//
//  ABTabBar.m
//  Account_book
//
//  Created by 王松涛 on 2020/6/10.
//  Copyright © 2020 Songtao Wang. All rights reserved.
//

#import "ABTabBar.h"

@interface ABTabBar()

@property (nonatomic, strong) UILabel *plusButtonLabel;

@end

@implementation ABTabBar

- (instancetype) init{
    self = [super init];
    if(self){
        UIButton *pButton = [[UIButton alloc] init] ;
//        pButton.adjustsImageWhenHighlighted = NO;
        [pButton setBackgroundImage:[UIImage imageNamed:@"icon.bundle/post_animate_add.png"] forState:UIControlStateNormal];
        pButton.bounds = CGRectMake(0, 0, pButton.currentBackgroundImage.size.width, pButton.currentBackgroundImage.size.height);
        self.plusButton = pButton;
        [self addSubview:pButton];
    }
    return self;
}

- (void) layoutSubviews{
    [super layoutSubviews];
//    新增按钮属性
    self.plusButton.center = CGPointMake(CGRectGetWidth(self.frame) / 2, 0);
    
//    添加新增按钮标签
    UILabel * pLabel = [[UILabel alloc] init];
    self.plusButtonLabel = pLabel;
    self.plusButtonLabel.text = @"记一笔";
    self.plusButtonLabel.font = [UIFont systemFontOfSize:13];
    [self.plusButtonLabel sizeToFit];
    self.plusButtonLabel.textColor = [UIColor grayColor];
    [self addSubview:self.plusButtonLabel];
    self.plusButtonLabel.center = CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetMaxY(self.plusButton.frame) +10);

    
//    改变其余按钮位置
    CGFloat tabBarButtonWidth = CGRectGetWidth(self.frame) / 5;
    CGFloat tabBarButtonIndex = 0;
    for(UIView *view in self.subviews){
        Class class = NSClassFromString(@"UITabBarButton");
        if([view isKindOfClass:class]){
            view.frame = CGRectMake(tabBarButtonWidth * tabBarButtonIndex, CGRectGetMinY(view.frame), tabBarButtonWidth, CGRectGetHeight(view.frame));
            tabBarButtonIndex += (tabBarButtonIndex == 1 ? 2 : 1);
        }
    }
}

//重写hitTest方法，使按钮超出tabbar部分也可以响应
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    //判断是否有tabbar。
    if(self.isHidden == NO){
        //将当前tabbar坐标点转换坐标系，转换到按钮上，生成一个新点。
        CGPoint newPoint = [self convertPoint:point toView:self.plusButton];
        if([self.plusButton pointInside:newPoint withEvent:event]){
            //如果这个点在按钮上，处理时间的view就是按钮。
            return self.plusButton;
        }
        else{
            //如果不在按钮上，系统处理即可。
            return [super hitTest:point withEvent:event];
        }
    }
    else{
        //tabbar隐藏了，push到了其他页面。
        return [super hitTest:point withEvent:event];
    }
    return nil;
}


@end
