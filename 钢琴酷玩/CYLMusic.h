//
//  CYLMusic.h
//  钢琴酷玩
//
//  Created by chang on 15-6-10.
//  Copyright (c) 2015年 CYL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CYLMusic : NSObject
//乐谱名称
@property (nonatomic,strong)NSString *name;
//乐谱曲谱
@property (nonatomic,strong)NSArray *composition;

//动态方法初始化
-(instancetype)initWithDictionary:(NSDictionary *)dict;

//静态方法初始化
+(instancetype)musicWithDictionary:(NSDictionary *)dict;

@end

