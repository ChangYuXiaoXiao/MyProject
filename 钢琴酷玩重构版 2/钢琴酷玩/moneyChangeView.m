//
//  moneyChangeView.m
//  钢琴酷玩
//
//  Created by chang on 15-5-15.
//  Copyright (c) 2015年 CYL. All rights reserved.
//

#import "moneyChangeView.h"

@interface moneyChangeView()
@property (weak, nonatomic) IBOutlet UILabel *changeMoneyLabel;

@end

@implementation moneyChangeView

+(instancetype)moneyChangeView
{
    return [[[NSBundle mainBundle]loadNibNamed:@"moneyChangeView" owner:nil options:nil]lastObject];
}

+(void)moneyChangeViewWithMoney:(int)money toView:(UIView *)view
{
    if (view == nil)
        view = [[UIApplication sharedApplication].windows lastObject];
    moneyChangeView *displayView = [moneyChangeView moneyChangeView];
    float displayViewX = view.frame.size.height*((1024.0-260.0)/1024.0);
    float displayViewY = view.frame.size.width*(144.0/768.0);
    displayView.frame = CGRectMake(displayViewX, displayViewY, 100 , 70);
    if (money > 0)
    {
        displayView.changeMoneyLabel.text = [NSString stringWithFormat:@"＋%d",money];
    }else
        displayView.changeMoneyLabel.text = [NSString stringWithFormat:@"%d",money];
    [view addSubview:displayView];
    [UIView animateWithDuration:0.5f animations:^{
        CGRect temp = CGRectMake(displayView.frame.origin.x, displayView.frame.origin.y - 100, displayView.frame.size.width, displayView.frame.size.height);
        displayView.frame = temp;
        displayView.alpha = 0.5;
    } completion:^(BOOL finished)
    {
        [displayView removeFromSuperview];
    }];
}

-(void)awakeFromNib
{
    [self.layer setMasksToBounds:YES];
    [self.layer setCornerRadius:30];
}
@end
