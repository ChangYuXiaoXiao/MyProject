//
//  CYLAppDelegate.h
//  谜底
//
//  Created by 畅岩磊 on 14-12-10.
//  Copyright (c) 2014年 畅岩磊. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PGMidi;
@class CYLViewController;

@interface CYLAppDelegate : UIResponder <UIApplicationDelegate>{
    PGMidi *midi;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CYLViewController *viewcontroler;
@end
