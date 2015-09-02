//
//  CYLAboutViewController.m
//  钢琴酷玩
//
//  Created by chang on 15-6-9.
//  Copyright (c) 2015年 CYL. All rights reserved.
//

#import "CYLAboutViewController.h"
#define width 1024
#define height 7221

@interface CYLAboutViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
- (IBAction)chooseSegment:(UISegmentedControl *)sender;
@property (nonatomic) NSUInteger flag;
@end

@implementation CYLAboutViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.scrollView.contentSize = CGSizeMake(width, height);
    
    //    //创建个UIScrollView
    //
    //    UIScrollView *scView = [[UIScrollView alloc]init];
    //
    //    scView.frame = CGRectMake(0, 64, 320, 100);
    //    2
    
    //创建个UIImageView
    
    
    self.imageView.frame = CGRectMake(0, 0, width, height);
    
    self.imageView.image = [UIImage imageNamed:@"StaffKnowledge"];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (IBAction)chooseSegment:(UISegmentedControl *)sender {
    
    switch (sender.selectedSegmentIndex ) {
        case 0:
            self.scrollView.scrollEnabled = YES;
            self.scrollView.contentSize = CGSizeMake(width, height);
            self.imageView.frame = CGRectMake(0, 0, width, height);
            self.imageView.image = [UIImage imageNamed:@"StaffKnowledge"];
            break;
        case 1:
            self.scrollView.scrollEnabled = NO;
            self.scrollView.contentSize = CGSizeMake(width, 664);
            self.imageView.frame = CGRectMake(0, 104, width, 664);
            self.imageView.image = [UIImage imageNamed:@"ScoreRule"];
            break;
        default:
            break;
    }

    
}

@end