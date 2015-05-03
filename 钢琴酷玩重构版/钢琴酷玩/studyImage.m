//
//  studyImage.m
//  钢琴酷玩
//
//  Created by chang on 15-5-1.
//  Copyright (c) 2015年 CYL. All rights reserved.
//

#import "studyImage.h"
#define imgCount 4
@interface studyImage()


@end

@implementation studyImage

//静态方法初始化教程图片
+ (instancetype)studyImage
{
    studyImage *studyImage = [[[NSBundle mainBundle]loadNibNamed:@"studyImage" owner:nil options:nil]firstObject];
    return studyImage;
}

//设置轮播的图片数据
-(void)setImageName:(NSString *)imageName
{
    CGFloat width = self.scrollView.frame.size.width;
    CGFloat height = self.scrollView.frame.size.height;
    for (int i = 0; i < imgCount; i++) {
        UIImageView *imageView = [[UIImageView alloc]init];
        CGFloat imageX = i * width;
        CGFloat imageY = 0.f;
        imageView.frame = CGRectMake(imageX, imageY, width, height);
        imageView.image = [UIImage imageNamed:[imageName stringByAppendingString:[NSString stringWithFormat:@"_%1d.jpg",i]]];
        [self.scrollView addSubview:imageView];
    }
    self.scrollView.contentSize = CGSizeMake(imgCount * width, 0);
    self.scrollView.pagingEnabled = YES;
    self.pageControl.numberOfPages = imgCount;
}

@end
