//
//  pianoKeyboard.m
//  钢琴酷玩
//
//  Created by chang on 15-6-11.
//  Copyright (c) 2015年 CYL. All rights reserved.
//

#import "pianoKeyboardView.h"

@implementation pianoKeyboardView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
+(instancetype)pianoKeyboardView
{
    return [[[NSBundle mainBundle]loadNibNamed:@"pianoKeyboardView" owner:nil options:nil]lastObject];
}
@end
