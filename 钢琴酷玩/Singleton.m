//
//  Singleton.m
//  钢琴酷玩
//
//  Created by 王 on 15/6/22.
//  Copyright (c) 2015年 CYL. All rights reserved.
//

#import "Singleton.h"

@implementation Singleton

+(Singleton *) sharedInstance
{
    
    static Singleton *sharedInstace = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedInstace = [[self alloc] init];
    });
    
    return sharedInstace;
}

-(AsyncSocket *)socket
{
    if (!_socket)
    {
        self.socket = [[AsyncSocket alloc]initWithDelegate:self];
        [_socket connectToHost:@"172.17.53.8" onPort:9003 error:nil];
    }
    return _socket;
}

@end
