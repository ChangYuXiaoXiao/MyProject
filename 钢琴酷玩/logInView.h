//
//  logInView.h
//  钢琴酷玩
//
//  Created by chang on 15-5-11.
//  Copyright (c) 2015年 CYL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncSocket.h"
#import "CYLSocketMessage.h"
@class logInView;
//登录界面的代理协议
@protocol logInViewDelegate<NSObject>

//登录界面的代理方法
-(void)logInSucceed: (logInView *)logInView;
-(void)logInError: (logInView *)logInView WithError:(NSString *)error;
-(void)registerSucceed: (logInView *)logInView;
-(void)registerError: (logInView *)logInView WithError:(NSString *)error;
-(void)socketDisconnect;

@end

@interface logInView : UIButton

@property (weak, nonatomic)id<logInViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *logInBtn;
@property (strong,nonatomic) CYLSocketMessage *message;

//提供一个静态方法初始化一个logInView对象
+(instancetype)logInView;
@end
