//
//  accountInfoView.m
//  钢琴酷玩
//
//  Created by chang on 15-5-12.
//  Copyright (c) 2015年 CYL. All rights reserved.
//

#import "accountInfoView.h"
#define logInName @"logInName"
#define accountName @"accountName"

@interface accountInfoView()
@property (strong,nonatomic) NSArray *names;

@end

@implementation accountInfoView

+(instancetype)accountInfoView
{
    return [[[NSBundle mainBundle]loadNibNamed:@"accountInfoView" owner:nil options:nil]lastObject];
}
-(NSArray *)names
{
    if (!_names)
    {
        _names = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"name" ofType:@"plist"]];
    }
    return _names;
}
-(void)setMoney:(int)money
{

    _money = money;
    self.moneyLabel.text = [NSString stringWithFormat:@"%d",money];
    if (money < 0) self.nameLabel.text = [self.names objectAtIndex:0];
        else if(money >= 0 && money < 500)
            self.nameLabel.text = [self.names objectAtIndex:1];
        else if (money >=500 && money < 1000)
            self.nameLabel.text = [self.names objectAtIndex:2];
        else if (money >=1000 && money < 2000)
            self.nameLabel.text = [self.names objectAtIndex:3];
        else if (money >=2000 && money < 4000)
            self.nameLabel.text = [self.names objectAtIndex:4];
        else if (money >=4000 && money < 6000)
            self.nameLabel.text = [self.names objectAtIndex:5];
        else if (money >=6000 && money < 10000)
            self.nameLabel.text = [self.names objectAtIndex:6];
        else if (money >=10000)
            self.nameLabel.text = [self.names objectAtIndex:7];
    
}
@end
