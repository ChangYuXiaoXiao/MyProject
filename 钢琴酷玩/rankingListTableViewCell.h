//
//  rankingListViewCellTableViewCell.h
//  钢琴酷玩
//
//  Created by 王 on 15/6/22.
//  Copyright (c) 2015年 CYL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface rankingListTableViewCell : UITableViewCell

+(instancetype)rankingListTableViewCell;

@property (weak, nonatomic) IBOutlet UILabel *userNumberLable;
@property (weak, nonatomic) IBOutlet UILabel *userNameLable;
@property (weak, nonatomic) IBOutlet UILabel *scoreLable;
@property (weak, nonatomic) IBOutlet UILabel *rightRateLable;
@end
