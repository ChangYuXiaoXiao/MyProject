//
//  musicSelectView.m
//  钢琴酷玩
//
//  Created by chang on 15-6-9.
//  Copyright (c) 2015年 CYL. All rights reserved.
//

#import "musicSelectView.h"
@interface musicSelectView()

@end

@implementation musicSelectView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
+(instancetype)musicSelectView
{
    return [[[NSBundle mainBundle]loadNibNamed:@"musicSelectView" owner:nil options:nil]lastObject];
}

-(void)awakeFromNib
{
    [self.selectView.layer setMasksToBounds:YES];
    [self.selectView.layer setCornerRadius:15];
    [self.selectView.layer setBorderWidth:1];
    [self.selectView.layer setBorderColor:[UIColor whiteColor].CGColor];
}
- (IBAction)musicConfirm:(UIButton *)sender
{
    [self.delegate confirm:self];
}
- (IBAction)backMenu:(UIButton *)sender
{
    [self.delegate back:self];
}
@end
