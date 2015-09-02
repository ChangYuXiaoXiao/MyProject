//
//  CYLInitialViewController.h
//  钢琴酷玩
//
//  Created by chang on 15-4-30.
//  Copyright (c) 2015年 chang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "AsyncSocket.h"
#import "CYLActionID.h"
@interface CYLInitialViewController : UIViewController<AsyncSocketDelegate>
-(void)LogOff;
@end
