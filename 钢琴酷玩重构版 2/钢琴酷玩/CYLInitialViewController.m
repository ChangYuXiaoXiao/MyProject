//
//  CYLInitialViewController.m
//  钢琴酷玩
//
//  Created by chang on 15-4-30.
//  Copyright (c) 2015年 chang. All rights reserved.
//


#import "CYLInitialViewController.h"
#import "logInView.h"
#import "MBProgressHUD+NJ.h"
#define logInName @"logInName"
#define accountName @"accountName"

@interface CYLInitialViewController ()<logInViewDelegate,UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UIButton *logInBtn;
@property (weak, nonatomic) IBOutlet UILabel *accountNameLable;
@property (strong,nonatomic) logInView *logInView;
@property (strong,nonatomic) UIButton *cover;

@end

@implementation CYLInitialViewController


#pragma mark UIViewController初始化相关

-(void)viewDidLoad
{
    [super viewDidLoad];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:logInName] != nil)
    {
        [self.logInBtn setTitle:[defaults objectForKey:logInName] forState:UIControlStateNormal];
        self.accountNameLable.text = [defaults objectForKey:accountName];
    }
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}


#pragma mark IBAction

- (IBAction)logIn:(UIButton *)sender
{
    if ([sender.titleLabel.text isEqualToString:@"用户登录"])
    {
        //初始化蒙板，并添加
        self.cover = [[UIButton alloc]initWithFrame:self.view.bounds];
        _cover.backgroundColor = [UIColor blackColor];
        _cover.alpha = 0.5f;
        [self.view addSubview:_cover];
        [_cover addTarget:self action:@selector(backMenu) forControlEvents:UIControlEventTouchUpInside];
        //初始化登录视图,动画添加
        self.logInView = [logInView logInView];
        _logInView.frame = CGRectMake(312, 768, 400, 300);
        [self.view addSubview:_logInView];
        [UIView animateWithDuration:0.5 animations:^{
            CGRect frame = CGRectMake(312, 100, 400, 300);
            _logInView.frame = frame;
        }];
        _logInView.delegate = self;

    }else//如果是注销按钮,弹出确定窗口
    {
        UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:@"确定要注销么？" delegate: self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定！！！" otherButtonTitles:nil];
        sheet.tag = 1;
        [sheet showInView:self.view];
    }
}

- (IBAction)resetGame:(UIButton *)sender
{
    if (self.accountNameLable.text!=nil) {
        UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:@"确定要重置游戏数据么？" delegate: self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定以及肯定" otherButtonTitles:nil];
        sheet.tag = 0;
        [sheet showInView:self.view];
    }else
    {
        [MBProgressHUD showError:@"您未登录，无法重置游戏数据！" toView:self.view time:1.0f];
    }
}


#pragma mark actionsheet的代理方法，监听确定按钮点击

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag)
    {
        if (0 == buttonIndex)
        {
            self.accountNameLable.text = nil;
            [self.logInBtn setTitle:@"用户登录" forState:UIControlStateNormal];
            //持久化登录数据，保存偏好设置信息
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            //1、保存登录按钮标题
            [defaults setObject:self.logInBtn.currentTitle forKey:logInName];
            //2、保存账户名
            [defaults setObject:self.accountNameLable.text forKey:accountName];
            [defaults synchronize];
        }
    }else
    {
        if (0 == buttonIndex)
        {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:[NSNumber numberWithInt:100] forKey:@"money"];
        }
    }
}


#pragma mark 自定义登录视图的代理方法

-(void)logInError:(logInView *)logInView
{
    [MBProgressHUD showError:@"用户名或者密码错误！！！" toView:self.logInView time:0.5f];
}

- (void)logInSucceed:(logInView *)logInView
{
    //登录成功后，移除登录界面
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frame = CGRectMake(312, 768, 400, 300);
        logInView.frame = frame;
    } completion:^(BOOL finished)
    {
        [logInView removeFromSuperview];
        [self.view.subviews.lastObject removeFromSuperview];
        //添加用户名
        self.accountNameLable.text = @"cyl,欢迎回来！";
        //更改用户登录按钮为注销
        [self.logInBtn setTitle:@"注销。" forState:UIControlStateNormal];
        //持久化登录数据，保存偏好设置信息
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        //1、保存登录按钮标题
        [defaults setObject:self.logInBtn.currentTitle forKey:logInName];
        //2、保存账户名
        [defaults setObject:self.accountNameLable.text forKey:accountName];
        [defaults synchronize];
    }];
}


#pragma mark 辅助函数

//点击蒙板时撤销登录视图
-(void)backMenu
{
    if (self.logInView != nil&&self.cover != nil)
    {
        [UIView animateWithDuration:1 animations:^{
            CGRect frame = CGRectMake(312, 768, 400, 300);
            _logInView.frame = frame;
        }completion:^(BOOL finished) {
            [_logInView removeFromSuperview];
            [_cover removeFromSuperview];
        }];
    }


}

@end
