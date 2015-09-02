//
//  CYLReceivedMessage.h
//  钢琴酷玩
//
//  Created by 王 on 15/6/20.
//  Copyright (c) 2015年 CYL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CYLRangeUser.h"

@interface CYLSocketMessage : NSObject

@property(nonatomic,strong) NSData *receivedData;
@property(nonatomic,assign) int totalLength;
@property(nonatomic,assign) int packetLength;
@property(nonatomic,assign) int errorCode;
@property(nonatomic,assign) int messageID;
@property(nonatomic,copy) NSString *errorMessage;
@property(nonatomic,assign) int actionID;
@property(nonatomic,copy) NSString *st;
@property(nonatomic,copy) NSString *passWordID;
@property(nonatomic,copy) NSString *date;
@property(nonatomic,assign) BOOL isFirstLogIn;
@property(nonatomic,assign) int money;
@property(nonatomic,copy) NSString *rightRate;
@property(nonatomic,assign) int pageCount;
@property(nonatomic,assign) int listCount;
@property(nonatomic,assign) int unkonwn;
@property(nonatomic,strong) NSMutableArray *listArray;
@property(nonatomic,assign) int currentRank;

//提供一个类方法用于将要发送的char数据转化为NSData
+(NSData *)sentDataWithChardata:(char *)data;
+(NSString *)sessionID;
+(NSString *)userID;
@end
