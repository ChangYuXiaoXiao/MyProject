//
//  visualView.m
//  钢琴酷玩
//
//  Created by chang on 15-6-9.
//  Copyright (c) 2015年 CYL. All rights reserved.
//

#import "visualView.h"

@implementation visualView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)awakeFromNib
{
    [self.layer setMasksToBounds:YES];
    [self.layer setCornerRadius:12];
    [self.layer setBorderWidth:1];
    
}
@end
