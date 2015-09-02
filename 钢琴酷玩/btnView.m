//
//  btnView.m
//  钢琴酷玩
//
//  Created by chang on 15-5-11.
//  Copyright (c) 2015年 CYL. All rights reserved.
//

#import "btnView.h"

@implementation btnView

- (void)awakeFromNib
{
    [self.layer setMasksToBounds:YES];
    [self.layer setCornerRadius:12];
    [self.layer setBorderWidth:1];

}

@end
