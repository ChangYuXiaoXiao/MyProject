//
//  CYLActionID.h
//  钢琴酷玩
//
//  Created by 王 on 15/6/20.
//  Copyright (c) 2015年 CYL. All rights reserved.
//

#import <Foundation/Foundation.h>


/*
 用于表明actionID对应的动作类型
 */
@interface CYLActionID : NSObject


+(int)signIn;
+(int)logIn;
+(int)getMoney;
+(int)changeMoney;
+(int)getRankingList;
+(int)resetGame;
@end
