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
#import "CYLSocketMessage.h"
#import "AppDelegate.h"
#import "Singleton.h"
#define logInName @"logInName"
#define accountName @"accountName"
#define firstUserBtnWidth 201
#define logInBtnWidth 210


@interface CYLInitialViewController ()<logInViewDelegate,UIActionSheetDelegate,AppDelegateDelegate,AsyncSocketDelegate>

@property (strong,nonatomic) logInView *logInView;
@property (strong,nonatomic) UIButton *cover;
@property (nonatomic,strong) NSString *soundFile;
@property (weak, nonatomic) IBOutlet UIButton *logInBtn;
@property (weak, nonatomic) IBOutlet UIButton *firstUserBtn;
@property (weak, nonatomic) IBOutlet UILabel *accountNameLable;
@property (weak, nonatomic) IBOutlet UIButton *studyModeBtn;
@property (weak, nonatomic) IBOutlet UIButton *gameModeBtn;
@property (weak, nonatomic) IBOutlet UIButton *resetGameBtn;
@property (weak, nonatomic) IBOutlet UIButton *aboutBtn;

@end

@implementation CYLInitialViewController


#pragma mark UIViewController初始化相关

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self.logInBtn.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.firstUserBtn.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.studyModeBtn setImage:[UIImage imageNamed:@"studyBtn.png"] forState:UIControlStateNormal];
    [self.gameModeBtn setImage:[UIImage imageNamed:@"gameBtn.png"] forState:UIControlStateNormal];
    [self.resetGameBtn setImage:[UIImage imageNamed:@"resetBtn.png"] forState:UIControlStateNormal];
    [self.aboutBtn setImage:[UIImage imageNamed:@"aboutBtn.png"] forState:UIControlStateNormal];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:accountName] != nil)
    {
        [Singleton sharedInstance].socket.delegate = self;
        [self.logInBtn setTitle:[defaults objectForKey:logInName] forState:UIControlStateNormal];
        self.logInBtn.frame = CGRectMake(self.logInBtn.frame.origin.x, self.logInBtn.frame.origin.y, self.firstUserBtn.frame.origin.x+self.firstUserBtn.frame.size.width-self.logInBtn.frame.origin.x, self.logInBtn.frame.size.height);
        self.firstUserBtn.frame = CGRectMake(self.firstUserBtn.frame.origin.x+self.firstUserBtn.frame.size.width-1, self.firstUserBtn.frame.origin.y, 1, self.firstUserBtn.frame.size.height);
        self.firstUserBtn.alpha = 0;
        self.accountNameLable.text = [defaults objectForKey:accountName];
        self.accountNameLable.textColor = [UIColor colorWithRed:255.0 green:215.0 blue:237.0 alpha:1.0];
    }
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark IBAction

- (IBAction)logIn:(UIButton *)sender
{
    if ([sender.titleLabel.text isEqualToString:@"用户登录"]||[sender.titleLabel.text isEqualToString:@"新用户"])
    {
        //初始化蒙板，并添加
        self.cover = [[UIButton alloc]initWithFrame:self.view.bounds];
        _cover.backgroundColor = [UIColor blackColor];
        _cover.alpha = 0.5f;
        [self.view addSubview:_cover];
        [_cover addTarget:self action:@selector(backMenu) forControlEvents:UIControlEventTouchUpInside];
        //初始化登录视图,动画添加
        self.logInView = [logInView logInView];
        if ([sender.titleLabel.text isEqualToString:@"新用户"])[_logInView.logInBtn setTitle:@"注册" forState:UIControlStateNormal];
        _logInView.frame = CGRectMake(312, 768, 400, 300);
        [self.view addSubview:_logInView];
        [UIView animateWithDuration:0.5 animations:^{
            CGRect frame = CGRectMake(312, 100, 400, 300);
            _logInView.frame = frame;
        }];
        _logInView.delegate = self;

    }else//如果是注销按钮,弹出确定窗口
    {
        UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:@"确定要注销么？" delegate: self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles:nil];
        sheet.tag = 1;
        [sheet showInView:self.view];
    }
}

- (IBAction)resetGame:(UIButton *)sender
{
    if (self.accountNameLable.text.length>0) {
        UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:@"确定要重置游戏数据么？" delegate: self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles:nil];
        sheet.tag = 0;
        [sheet showInView:self.view];
    }else
    {
        [MBProgressHUD showError:@"您未登录，无法重置游戏数据！" toView:self.view time:1.0f];
    }
}

//点击对应键时播放对应音
- (IBAction)musicPlay:(UIButton *)sender
{
    _soundFile = [NSString stringWithFormat:@"/%ld.mp3",(long)sender.tag];
    [self playSound: _soundFile];
}


#pragma mark actionsheet的代理方法，监听确定按钮点击

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //注销时弹出的警告
    if (actionSheet.tag)
    {
        if (0 == buttonIndex)
        {
            [self LogOff];
        }
    }else//重置游戏时弹出的警告
    {
        if (0 == buttonIndex)
        {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:[NSNumber numberWithInt:100] forKey:@"money"];
            NSString *sentStr = [NSString stringWithFormat:@"MsgId=0&Sid=%@&Uid=%@&ActionID=%d",[CYLSocketMessage sessionID],[CYLSocketMessage userID],[CYLActionID resetGame]];
            const char * sentChar = [sentStr UTF8String];
            [Singleton sharedInstance].socket.delegate = self;
            [[Singleton sharedInstance].socket readDataWithTimeout:3 tag:1];
            [[Singleton sharedInstance].socket writeData:[CYLSocketMessage sentDataWithChardata:(char *)sentChar] withTimeout:3 tag:1];
        }
    }
}


#pragma mark 自定义登录&注册视图的代理方法

-(void)logInError:(logInView *)logInView WithError:(NSString *)error
{
    [MBProgressHUD showError:error toView:self.logInView time:2.0f];
}

- (void)logInSucceed:(logInView *)logInView
{
    //登录成功后，移除登录界面
    self.logInBtn.enabled = NO;
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frame = CGRectMake(312, 768, 400, 300);
        logInView.frame = frame;
    } completion:^(BOOL finished)
    {
        [logInView removeFromSuperview];
        [self.view.subviews.lastObject removeFromSuperview];
        //添加用户名
        self.accountNameLable.text = [NSString stringWithFormat:@"%@,欢迎登录游戏！",logInView.message.passWordID];
        //更改用户登录按钮为注销
        [self.logInBtn setTitle:@"注销" forState:UIControlStateNormal];
        [UIView animateWithDuration:0.5 animations:^{
            CGRect temp = CGRectMake(self.firstUserBtn.frame.origin.x+self.firstUserBtn.frame.size.width-1, self.firstUserBtn.frame.origin.y, 1, self.firstUserBtn.frame.size.height);
            CGRect temp1 = CGRectMake(self.logInBtn.frame.origin.x, self.logInBtn.frame.origin.y, self.firstUserBtn.frame.origin.x+self.firstUserBtn.frame.size.width-self.logInBtn.frame.origin.x, self.logInBtn.frame.size.height);
            self.firstUserBtn.frame = temp;
            self.logInBtn.frame = temp1;
            self.firstUserBtn.alpha = 0;
        }];
        self.logInBtn.enabled = YES;
        //持久化登录数据，保存偏好设置信息
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        //1、保存登录按钮标题
        [defaults setObject:self.logInBtn.currentTitle forKey:logInName];
        //2、保存账户名
        [defaults setObject:self.accountNameLable.text forKey:accountName];
        [defaults synchronize];
    }];
}

-(void)registerSucceed:(logInView *)logInView
{
    //显示注册成功
    [MBProgressHUD showSuccess:@"注册成功" toView:self.logInView time:0.5f];
    //隔1秒后自动退出注册界面
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.5 animations:^{
            CGRect frame = CGRectMake(312, 768, 400, 300);
            logInView.frame = frame;
        } completion:^(BOOL finished)
         {
             [logInView removeFromSuperview];
             [self.view.subviews.lastObject removeFromSuperview];
         }];
    });
}

-(void)registerError: (logInView *)logInView WithError:(NSString *)error
{
    [MBProgressHUD showError:error toView:self.logInView time:2.0f];
}

-(void)socketDisconnect
{
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_async(mainQueue, ^{
        [MBProgressHUD showError:@"网络连接错误，请重新登录" toView:self.view time:2];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self LogOff];
    });

    
}

#pragma mark AsyncSocketDelegate方法

-(void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
    [self socketDisconnect];
}

#pragma mark AppDelegateDelegate方法

-(void)socketDisConnected:(NSError *)error
{
    [MBProgressHUD hideHUDForView:self.view];
    [self socketDisconnect];
}

-(void)socketConnecting
{
    [MBProgressHUD showMessage:@"正在拼命登录中，请稍候" toView:self.view];
}

-(void)socketConnected
{
    [MBProgressHUD hideHUDForView:self.view];
}

#pragma mark 辅助函数

//用户注销确认的方法
-(void)LogOff
{
    if (self.logInBtn.frame.size.width > 210)
    {
    self.accountNameLable.text = nil;
    [self.logInBtn setTitle:@"用户登录" forState:UIControlStateNormal];
    [UIView animateWithDuration:0.5 animations:^{
        self.firstUserBtn.alpha = 1;
        CGRect temp = CGRectMake(_firstUserBtn.frame.origin.x-firstUserBtnWidth+1, _firstUserBtn.frame.origin.y, firstUserBtnWidth, _firstUserBtn.frame.size.height);
        CGRect temp1 = CGRectMake(self.logInBtn.frame.origin.x, _logInBtn.frame.origin.y, logInBtnWidth, _logInBtn.frame.size.height);
        self.firstUserBtn.frame = temp;
        self.logInBtn.frame = temp1;
    }];
    //持久化登录数据，保存偏好设置信息
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //1、保存登录按钮标题
    [defaults setObject:self.logInBtn.currentTitle forKey:logInName];
    //2、保存账户名
    [defaults setObject:self.accountNameLable.text forKey:accountName];
    [defaults synchronize];
    }
}

//点击蒙板时撤销登录视图
-(void)backMenu
{
    if (self.logInView != nil&&self.cover != nil)
    {
        [Singleton sharedInstance].socket = nil;
        [UIView animateWithDuration:1 animations:^{
            CGRect frame = CGRectMake(312, 768, 400, 300);
            _logInView.frame = frame;
        }completion:^(BOOL finished) {
            [_logInView removeFromSuperview];
            [_cover removeFromSuperview];
        }];
    }


}

//该函数用于对传入的字符串对应的声音文件进行播放
-(void)playSound:(NSString*)soundKey
{
    
    NSString *path = [NSString stringWithFormat:@"%@%@",[[NSBundle mainBundle] resourcePath],soundKey];
    SystemSoundID soundID;
    NSURL *filePath = [NSURL fileURLWithPath:path isDirectory:NO];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)filePath, &soundID);
    AudioServicesPlaySystemSound(soundID);
    
}

@end
