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

+(instancetype)moneyChangeView;
+(void)moneyChangeViewWithMoney:(int)money toView:(UIView *)view;
@end
