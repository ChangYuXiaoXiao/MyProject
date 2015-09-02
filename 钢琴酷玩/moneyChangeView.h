//
//  moneyChangeView.h
//  钢琴酷玩
//
//  Created by chang on 15-5-15.
//  Copyright (c) 2015年 CYL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD+NJ.h"

@interface moneyChangeView : UIView

//静态方法初始化一个moneyChangeView对象
+(instancetype)moneyChangeView;

//静态方法根据传入的值设置该对象的数据
+(void)moneyChangeViewWithMoney:(int)money toView:(UIView *)view;
@end
