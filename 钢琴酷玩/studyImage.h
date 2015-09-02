//
//  studyImage.h
//  钢琴酷玩
//
//  Created by chang on 15-5-1.
//  Copyright (c) 2015年 CYL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface studyImage : UIView

@property (copy,nonatomic) NSString *imageName;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

//静态方法初始化studyImage对象
+(instancetype)studyImage;
@end
