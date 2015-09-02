//
//  accountInfoView.h
//  钢琴酷玩
//
//  Created by chang on 15-5-12.
//  Copyright (c) 2015年 CYL. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol accountInfoViewDelegate<NSObject>
-(void)accountInfoViewRankingBtnClicked;
@end
@interface accountInfoView : UIView

@property (weak, nonatomic)id<accountInfoViewDelegate> delegate;
@property (assign,nonatomic) int money;
@property (copy,nonatomic) NSString *rightRate;
@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightRateLabel;


//提供一个静态方法初始化accountInfoView对象
+(instancetype)accountInfoView;
@end
