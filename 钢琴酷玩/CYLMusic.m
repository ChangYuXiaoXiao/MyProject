//
//  CYLMusic.m
//  钢琴酷玩
//
//  Created by chang on 15-6-10.
//  Copyright (c) 2015年 CYL. All rights reserved.
//

#import "CYLMusic.h"

@implementation CYLMusic

-(instancetype)initWithDictionary:(NSDictionary *)dict
{
    if (self = [super init])
    {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}
+(instancetype)musicWithDictionary:(NSDictionary *)dict
{
    return [[self alloc]initWithDictionary:dict];
}
@end
