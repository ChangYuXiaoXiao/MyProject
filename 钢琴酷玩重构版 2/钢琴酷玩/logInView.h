//
//  logInView.h
//  钢琴酷玩
//
//  Created by chang on 15-5-11.
//  Copyright (c) 2015年 CYL. All rights reserved.
//

#import <UIKit/UIKit.h>
@class logInView;
@protocol logInViewDelegate<NSObject>
-(void)logInSucceed: (logInView *)logInView;
-(void)logInError:(logInView *)logInView;
@end

@interface logInView : UIButton

@property (weak, nonatomic)id<logInViewDelegate> delegate;


+(instancetype)logInView;
@end
