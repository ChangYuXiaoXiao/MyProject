//
//  note.h
//  钢琴酷玩
//
//  Created by chang on 15-5-1.
//  Copyright (c) 2015年 CYL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CYLNote : NSObject
{

}
@property (assign,nonatomic) float noteX;
@property (assign,nonatomic) float noteY;
@property (strong,nonatomic) UIView *up1Line;
@property (strong,nonatomic) UIView *up2Line;
@property (strong,nonatomic) UIView *centerLine;
@property (strong,nonatomic) UIView *down1Line;
@property (strong,nonatomic) UIView *down2Line;
@property (strong,nonatomic) UIImageView *upMark;
-(void)notePositionWithNumber:(NSNumber *)number;
@end
