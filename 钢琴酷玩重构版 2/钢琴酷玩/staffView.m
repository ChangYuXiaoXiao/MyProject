//
//  staffView.m
//  钢琴酷玩
//
//  Created by chang on 15-5-1.
//  Copyright (c) 2015年 chang. All rights reserved.
//

#import "staffView.h"

@implementation staffView

//提供两个静态方法，初始化两种模式的五线谱图像
+ (instancetype)staffViewWithStudymode
{
    return [[[NSBundle mainBundle]loadNibNamed:@"staffView" owner:nil options:nil]firstObject];
}
+(instancetype)staffViewWithGamemode
{
    return [[[NSBundle mainBundle]loadNibNamed:@"staffView" owner:nil options:nil]lastObject];
}

@end
