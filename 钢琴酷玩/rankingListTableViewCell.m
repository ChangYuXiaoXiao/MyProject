//
//  rankingListViewCellTableViewCell.m
//  钢琴酷玩
//
//  Created by 王 on 15/6/22.
//  Copyright (c) 2015年 CYL. All rights reserved.
//

#import "rankingListTableViewCell.h"

@implementation rankingListTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+(instancetype)rankingListTableViewCell
{
    return [[[NSBundle mainBundle]loadNibNamed:@"rankingListTableViewCell" owner:nil options:nil]lastObject];
}

@end
