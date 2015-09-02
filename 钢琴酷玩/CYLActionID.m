//
//  CYLActionID.m
//  钢琴酷玩
//
//  Created by 王 on 15/6/20.
//  Copyright (c) 2015年 CYL. All rights reserved.
//

#import "CYLActionID.h"
static int signIn = 1002;
static int logIn = 1003;
static int getMoney = 1007;
static int changeMoney = 1010;
static int getRankingList = 1001;
static int resetGame = 1005;
@implementation CYLActionID

+(int)signIn
{
    return signIn;
}
+(int)logIn
{
    return logIn;
}
+(int)getMoney
{
    return getMoney;
}
+(int)changeMoney
{
    return changeMoney;
}
+(int)getRankingList
{
    return getRankingList;
}
+(int)resetGame
{
    return resetGame;
}
@end
