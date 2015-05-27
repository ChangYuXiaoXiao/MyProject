//
//  CYLGamemodeViewController.m
//  钢琴酷玩
//
//  Created by chang on 15-5-1.
//  Copyright (c) 2015年 chang. All rights reserved.
//
#import "PGMidi.h"
#import "iOSVersionDetection.h"
#import <CoreMIDI/CoreMIDI.h>
#import "CYLGamemodeViewController.h"
#import "staffView.h"
#import "accountInfoView.h"
#import "MBProgressHUD+NJ.h"
#import "moneyChangeView.h"
#define staffViewX 0
#define staffViewY 238
#define staffViewW 1024
#define staffViewH 292
#define noteX 970
#define noteY 277+number*7.5
#define noteW 23.5
#define noteH 15
#define logInName @"logInName"
#define accountName @"accountName"

@interface CYLGamemodeViewController ()<PGMidiDelegate, PGMidiSourceDelegate>
{
    int inputPitch;
    int countOfSubview;
    int money;
    int changeMoney;
    float noteFrequency;
    float noteSpeed;
    UIImageView *currentNote;
    NSArray *positions;
}
@property (nonatomic,strong) PGMidi *midi;
@property (strong, nonatomic) NSTimer *timer;
@property (weak, nonatomic) staffView *staffView;
@property (strong,nonatomic) accountInfoView *accounInfoView;
@property (weak, nonatomic) IBOutlet UIButton *beginBtn;
@property (weak, nonatomic) IBOutlet UIButton *gameOverBtn;
@property (weak, nonatomic) IBOutlet UILabel *connectLabel;
@property (weak, nonatomic) IBOutlet UILabel *judgeLabel;
@property (weak, nonatomic) IBOutlet UILabel *accountNameLable;
@property (weak, nonatomic) IBOutlet UISlider *noteFrequencySlider;
@property (weak, nonatomic) IBOutlet UISlider *noteSpeedSlider;

@end

@implementation CYLGamemodeViewController


#pragma mark viewcontroler

- (void)viewDidLoad
{
    [super viewDidLoad];
    //初始化midi对象
    self.midi = [[PGMidi alloc]init];
    _midi.networkEnabled = YES;
    //显示五线谱
    if (!_staffView)
    {
        // 设置五线谱图片
        self.staffView = [staffView staffViewWithGamemode];
        // 设置五线谱位置
        _staffView.frame = CGRectMake(staffViewX, staffViewY, staffViewW, staffViewH);;
        //显示五线谱
        [self.view addSubview:_staffView];
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:accountName] != nil)
    {
        //初始化账户名
        self.accountNameLable.text = [defaults objectForKey:accountName];
        //初始化账户相关信息
        self.accounInfoView = [accountInfoView accountInfoView];
        if ([defaults objectForKey:@"money"]==nil)
        {
            money = 100;
        }else
        {
             money= [[defaults objectForKey:@"money"]intValue];
            _accounInfoView.money = money;
            self.noteFrequencySlider.value = [[defaults objectForKey:@"frequency"]floatValue];
            self.noteSpeedSlider.value = [[defaults objectForKey:@"speed"]floatValue];
        }
        _accounInfoView.frame = CGRectMake(1024-160, 44, 160, 100);
        [self.view addSubview:_accounInfoView];
    }
    //初始化输入音高保存变量和当前的控件数
    inputPitch = 0;
    countOfSubview = (int)self.view.subviews.count;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    if (_midi.sources.count == 2) {
        self.connectLabel.text = @"连接成功！";
    }else
    {
        self.connectLabel.text = @"未连接，请等待。";
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.timer invalidate];
    
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}



#pragma mark IBAction

- (IBAction)gameBegin:(UIButton *)sender
{
    //点击开始按钮
    if ([sender.currentTitle isEqual:@"开始游戏"])
    {
        //将设置不可用，结束按钮可用
        self.gameOverBtn.enabled = YES;
        self.noteFrequencySlider.enabled = NO;
        self.noteSpeedSlider.enabled = NO;
        [self saveSetInfo];
        //开启定时器，不断产生音符
        [self noteAnimation];
        noteFrequency = 5.25 - self.noteFrequencySlider.value;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:noteFrequency target:self selector:@selector(noteAnimation) userInfo:nil repeats:YES];
        self.beginBtn.enabled = NO;
    }else
    //点击结束按钮
    {
        //关闭定时器，重新初始化游戏界面
        self.gameOverBtn.enabled = NO;
        [self.timer invalidate];
        self.judgeLabel.text = nil;
        self.beginBtn.enabled = YES;
        self.noteFrequencySlider.enabled = YES;
        self.noteSpeedSlider.enabled = YES;
        for (int i = countOfSubview; i<self.view.subviews.count; i++)
        {
            UIImageView *view = self.view.subviews[i];
            view.alpha = 0;
        }
        if ([sender.currentTitle isEqualToString:@"主菜单"])
        {
            [self performSegueWithIdentifier:@"back" sender:nil];
        }
        return;
    }
}

- (IBAction)test:(UIButton *)sender
{
    inputPitch = 72;
    money += 1000;
    [self judge];

}


#pragma mark 辅助函数

//将待弹奏的音符以动画的方式呈现
-(void)noteAnimation
{
        UIImageView *note = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"note.png"]];
        
        //根据number随机生成音符，添加到指定位置
        int number = arc4random()%28;
        note.frame = CGRectMake(noteX, noteY, noteW, noteH);
        [self.view addSubview:note];
        //将生成的音符以动画方式从左到右运行，完成后移除
        noteSpeed = 33 - self.noteSpeedSlider.value;
        [UIView animateWithDuration:noteSpeed delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            CGRect temp = note.frame;
            temp.origin.x = noteX - 788;
            note.frame = temp;
        } completion:^(BOOL finished){
            if ((note.alpha > 0.5)&&(_accounInfoView))
            {
                changeMoney = -2;
                
                [self updateMoney:changeMoney];
            }
            [note removeFromSuperview];
        }];
}

//更新数据
-(void)updateMoney:(int)CMoney
{
    money += CMoney;
    [moneyChangeView moneyChangeViewWithMoney:CMoney toView:self.view];
    _accounInfoView.money = money;
    [[NSUserDefaults standardUserDefaults]setObject: [NSNumber numberWithInt:money] forKey:@"money"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//保存设置信息
-(void)saveSetInfo
{
    if (_accounInfoView)
    {
        NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
        [defaults setObject:[NSNumber numberWithFloat:self.noteFrequencySlider.value] forKey:@"frequency"];
        [defaults setObject:[NSNumber numberWithFloat:self.noteSpeedSlider.value] forKey:@"speed"];
        [defaults synchronize];
    }else return;
}

//比较判定音符弹奏的正误
-(void)judge
{
    //根据plist文件获取音高的y值信息，保存在数组中
    if (!positions)
    {
        positions = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"position2" ofType:@"plist"]];
    }
    //取出当前输入的音高信息，pitchY
    float pitchY = [positions[inputPitch - 21] floatValue];
    NSLog(@"%lu",(unsigned long)self.view.subviews.count);
    if (self.view.subviews.count > countOfSubview)
    {
        for (int i = countOfSubview; i<self.view.subviews.count; i++)
        {
            //获取当前要弹奏的音符对象
            if ([self.view.subviews[i] isKindOfClass:[UIView class]])
            {
                currentNote = self.view.subviews[i];
                if (currentNote.alpha != 0)
                {
                    //如果输入音符的y值信息与当前要弹奏的音符y值相同，则弹奏正确
                    if (currentNote.frame.origin.y == pitchY)
                    {
                        currentNote.alpha = 0;
                        self.judgeLabel.text = @"弹奏正确！";
                        changeMoney = 4;
                    }else
                    {
                        changeMoney = -1;
                        //弹奏错误时更换音符图片提示用户
                        currentNote.image = [UIImage imageNamed:@"noteError.png"];
                        self.judgeLabel.text = @"弹奏错误，请重弹。";
                        //0.5秒后恢复图片
                        [self performSelector:@selector(reloadNotePicture) withObject:nil afterDelay:0.5f];
                    }
                    if (_accounInfoView)[self updateMoney:changeMoney];
                    break;
                }
            }
        }
    }else
    {
        [MBProgressHUD showError:@"没有待弹奏的音符" toView:self.view time:0.3];
    }
}

//恢复音符图片
-(void)reloadNotePicture
{
    currentNote.image = [UIImage imageNamed:@"note.png"];
}

//列出所有信号源
- (void) attachToAllExistingSources
{
    for (PGMidiSource *source in _midi.sources)
    {
        [source addDelegate:self];
    }
}

//将MIDI包转换为字符串
NSString *StringFromPacket(const MIDIPacket *packet)
{
    // Note - this is not an example of MIDI parsing. I'm just dumping
    // some bytes for diagnostics.
    // See comments in PGMidiSourceDelegate for an example of how to
    // interpret the MIDIPacket structure.
    return [NSString stringWithFormat:@"  %u bytes: [%02x,%02x,%02x]",
            packet->length,
            (packet->length > 0) ? packet->data[0] : 0,
            (packet->length > 1) ? packet->data[1] : 0,
            (packet->length > 2) ? packet->data[2] : 0
            ];
}


#pragma mark - 代理方法，监听MIDI连接与通信

//将MIDI的代理交给控制器去监听硬件改动
- (void) setMidi:(PGMidi*)m
{
    _midi.delegate = nil;
    _midi = m;
    _midi.delegate = self;
    
    [self attachToAllExistingSources];
}

//当信号源增加时，自动调用此方法
- (void) midi:(PGMidi*)midi sourceAdded:(PGMidiSource *)source
{
    [source addDelegate:self];
    if (_midi.sources.count >= 2) {
        _connectLabel.text = @"连接成功！";
    }
    
}

//当信号源移除时，自动调用此方法
- (void) midi:(PGMidi*)midi sourceRemoved:(PGMidiSource *)source
{
    if (_midi.sources.count < 2) {
        _connectLabel.text = @"未连接，请等待。";
    }
    return;
}

//当接收者增加时，自动调用此方法
- (void) midi:(PGMidi*)midi destinationAdded:(PGMidiDestination *)destination
{
    return;
}

//当接收者移除时，自动调用此方法
- (void) midi:(PGMidi*)midi destinationRemoved:(PGMidiDestination *)destination
{
    return;
}

//当接收到MIDI信号时，自动调用此方法，MIDI包作为参数传入此函数
- (void) midiSource:(PGMidiSource*)midi midiReceived:(const MIDIPacketList *)packetList
{
    const MIDIPacket *packet = &packetList->packet[0];
    for (int i = 0; i < packetList->numPackets; ++i)
    {
        if ((packet->data[0] == 144)&&(packet->data[2]!=0))
        {
            //inputPitch用于接收从电钢琴输入音高
            inputPitch = packet->data[1];
            //当前界面有音符时，判定输入
            if (self.view.subviews.count > countOfSubview)
            {
                [self performSelectorOnMainThread:@selector(judge) withObject:nil waitUntilDone:NO];
            }
        }
        packet = MIDIPacketNext(packet);
    }
}

@end
