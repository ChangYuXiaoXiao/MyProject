//
//  musicSelectView.h
//  钢琴酷玩
//
//  Created by chang on 15-6-9.
//  Copyright (c) 2015年 CYL. All rights reserved.
//

#import "DRNRealTimeBlurView.h"
@class musicSelectView;
@protocol musicSelectViewDelegate <NSObject>

// 点击确认时调用
-(void)confirm:(musicSelectView *)msv;

//点击返回时调用
-(void)back:(musicSelectView *)msv;

@end


@interface musicSelectView : UIView

@property (weak, nonatomic)id<musicSelectViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UIView *selectView;

//提供一个静态方法初始化乐曲选择节目
+(instancetype)musicSelectView;
@end
