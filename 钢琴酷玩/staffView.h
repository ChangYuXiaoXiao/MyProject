//
//  staffView.h
//  钢琴酷玩
//
//  Created by chang on 15-5-1.
//  Copyright (c) 2015年 chang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface staffView : UIView

//提供两个静态方法，初始化两种模式的staffView
+(instancetype)staffViewWithStudymode;
+(instancetype)staffViewWithGamemode;

@end
