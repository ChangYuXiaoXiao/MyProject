//
//  pianoKeyboard.h
//  钢琴酷玩
//
//  Created by chang on 15-6-11.
//  Copyright (c) 2015年 CYL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface pianoKeyboardView : UIView

//存的是钢琴上所有键的集合
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *keyCollection;

//提供一个类方法初始化钢琴界面
+(instancetype)pianoKeyboardView;
@end
