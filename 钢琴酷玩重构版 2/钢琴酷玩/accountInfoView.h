//
//  accountInfoView.h
//  钢琴酷玩
//
//  Created by chang on 15-5-12.
//  Copyright (c) 2015年 CYL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface accountInfoView : UIView
@property (assign,nonatomic) int money;
@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
+(instancetype)accountInfoView;
@end
