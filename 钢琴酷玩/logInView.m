//
//  logInView.m
//  钢琴酷玩
//
//  Created by chang on 15-5-11.
//  Copyright (c) 2015年 CYL. All rights reserved.
//

#import "logInView.h"
#import "NSString+Hash.h"
#import "CYLActionID.h"
#import "MBProgressHUD+NJ.h"
#import "Singleton.h"
#define LOGIN 1003
#define SIGNIN 1002

@interface logInView()<AsyncSocketDelegate>

@property (weak, nonatomic) IBOutlet UITextField *account;
@property (weak, nonatomic) IBOutlet UITextField *passWord;

@end

@implementation logInView

-(CYLSocketMessage *)message
{
    if (!_message) {
        self.message = [[CYLSocketMessage alloc]init];
    }
    return _message;
}

//静态方法初始化logInView对象
+(instancetype)logInView
{
    return [[[NSBundle mainBundle]loadNibNamed:@"logInView" owner:nil options:nil]lastObject];
}

//在由nib文件初始化时改变控件样式，添加观察者模式
- (void)awakeFromNib
{
    [self.layer setMasksToBounds:YES];
    [self.layer setCornerRadius:12];
    [self.layer setBorderWidth:1];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(textChange) name:UITextFieldTextDidChangeNotification object: self.account];
    [center addObserver:self selector:@selector(textChange) name:UITextFieldTextDidChangeNotification object: self.passWord];
}

//点击登录或注册按钮触发的方法
- (IBAction)logIn:(UIButton *)sender
{
    int actionId;
    //1.确定actionId以表明是登录还是注册
    if ([sender.titleLabel.text isEqualToString:@"登录"])
    {
        [MBProgressHUD showMessage:@"正在为您拼命登录……" toView:self];
        actionId = [CYLActionID logIn];
    }
    else if([sender.titleLabel.text isEqualToString:@"注册"])
    {
        [MBProgressHUD showMessage:@"正在为您拼命注册……" toView:self];
        actionId = [CYLActionID signIn];
    }
    //2.将用户的账户信息包装成消息发给服务器
    self.logInBtn.enabled = NO;
    NSString *userName = self.account.text;
    NSString *passWord = self.passWord.text;
    NSString *sentStr = [NSString stringWithFormat:@"MsgId=0&Sid=&Uid=0&ActionID=%d&Pid=%@&Pwd=%@",actionId,userName,passWord];
    const char * sentChar = [sentStr UTF8String];
    [Singleton sharedInstance].socket.delegate = self;
    [[Singleton sharedInstance].socket readDataWithTimeout:3 tag:1];
    [[Singleton sharedInstance].socket writeData:[CYLSocketMessage sentDataWithChardata:(char *)sentChar] withTimeout:3 tag:1];
    //3.将账号密码信息保存在本地
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:userName forKey:@"userName"];
    [defaults setObject:passWord forKey:@"passWord"];
    [defaults  synchronize];
}

-(void)textChange
{
    self.logInBtn.enabled = (self.account.text.length>0&&self.passWord.text.length>0);
}



#pragma mark AsyncSocketDelegate方法

//连接到服务器时自动调用
-(void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
//    NSLog(@"logInView -- connect to host");
    return;
}

//已接收到服务器发送的信息时调用

-(void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
//    NSLog(@"logInView -- read data");
    [MBProgressHUD hideHUDForView:self];
    self.message.receivedData = data;
    //注册时的合法性验证
    if (_message.actionID == [CYLActionID signIn])
    {
        if (_message.errorCode == 0) [self.delegate registerSucceed:self];
        else [self.delegate registerError:self WithError:_message.errorMessage];
    }else  //登录时的合法性验证
    if(_message.actionID == [CYLActionID logIn])
    {
        if (_message.errorCode == 0) [self.delegate logInSucceed:self];
        else [self.delegate logInError:self WithError:_message.errorMessage];
    }
    self.logInBtn.enabled = YES;
}

//连接服务器断开时调用
-(void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
//    NSLog(@"logInView -- disconnect to host");
    if (self.frame.origin.y > 700)
    {
        dispatch_queue_t mainQueue = dispatch_get_main_queue();
        dispatch_async(mainQueue, ^{
            [self.delegate socketDisconnect];
        });
        
        
    }else
    {
        [MBProgressHUD hideHUDForView:self];
        self.logInBtn.enabled = YES;
        dispatch_queue_t mainQueue = dispatch_get_main_queue();
        dispatch_async(mainQueue, ^{
            [MBProgressHUD showError:@"网络错误，请稍候再试" toView:self time:2];
        });
    }
    [Singleton sharedInstance].socket = nil;
}



@end
