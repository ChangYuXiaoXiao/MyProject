//
//  Singleton.h
//  钢琴酷玩
//
//  Created by 王 on 15/6/22.
//  Copyright (c) 2015年 CYL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncSocket.h"

#define DEFINE_SHARED_INSTANCE_USING_BLOCK(block) \
static dispatch_once_t onceToken = 0; \
__strong static id sharedInstance = nil; \
dispatch_once(&onceToken, ^{ \
sharedInstance = block(); \
}); \
return sharedInstance; \

@interface Singleton : NSObject

@property (nonatomic, strong) AsyncSocket *socket;

+(Singleton *)sharedInstance;

@end