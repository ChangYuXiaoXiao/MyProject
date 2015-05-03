//
//  CYLGameViewController.m
//  钢琴酷玩
//
//  Created by chang on 03-2-21.
//  Copyright (c) 2003年 畅岩磊. All rights reserved.
//

#import "PGMidi.h"
#import "iOSVersionDetection.h"
#import <CoreMIDI/CoreMIDI.h>
#import "CYLGameViewController.h"
#define xquan 970

@interface CYLGameViewController ()<PGMidiDelegate, PGMidiSourceDelegate>
{
    int panding;
    int count;
    UIImageView *compareView;
}
@property (nonatomic,strong) PGMidi *midi;
@property (weak, nonatomic) IBOutlet UIButton *beginBtn;
@property (strong, nonatomic) NSTimer *timer;
@property (weak, nonatomic) IBOutlet UILabel *connectLabel;
@property (weak, nonatomic) IBOutlet UILabel *judgeLabel;

@end

@implementation CYLGameViewController


#pragma mark viewcontroler
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.midi = [[PGMidi alloc]init];
    _midi.networkEnabled = YES;
    panding = 0;
    count = (int)self.view.subviews.count;
}

- (void) viewWillAppear:(BOOL)animated
{
    if (_midi.sources.count == 2) {
        self.connectLabel.text = @"连接成功！";
    }else
    {
        self.connectLabel.text = @"未连接，请等待。";
    }
    
}


#pragma mark IBAction
- (IBAction)GameBegin:(UIButton *)sender
{

    if ([sender.currentTitle isEqual:@"开始游戏"])
        {
            [self yinfuyunxing];
            self.timer = [NSTimer scheduledTimerWithTimeInterval:6.0f target:self selector:@selector(yinfuyunxing) userInfo:nil repeats:YES];
            self.beginBtn.enabled = NO;
        }else
        {
            [self.timer invalidate];
            self.judgeLabel.text = nil;
            self.beginBtn.enabled = YES;
            for (int i = count; i<self.view.subviews.count; i++)
            {
                UIImageView *view = self.view.subviews[i];
                view.alpha = 0;
            }
            return;
        }
}

#pragma mark 辅助函数

//比较判定音符弹奏的正误
-(void)compare
{
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource:@"weizhi2" ofType:@"plist"];
    NSArray *weizhi = [NSArray arrayWithContentsOfFile:path];
    int yingao = panding - 21;
    float temp = [weizhi[yingao] floatValue];
    for (int i = count; i<self.view.subviews.count; i++)
    {
        compareView = self.view.subviews[i];
        if (compareView.alpha != 0)
        {
            if (compareView.frame.origin.y == temp)
            {
                compareView.alpha = 0;
                self.judgeLabel.text = @"弹奏正确！";
                break;
            }else
            {
                compareView.image = [UIImage imageNamed:@"quanyinfu_cuowu.png"];
                self.judgeLabel.text = @"弹奏错误，请重弹。";
                [self performSelector:@selector(changePng) withObject:nil afterDelay:0.5f];
            }
            break;
        }
    }
}

//弹奏错误时，更换音符图片
-(void)changePng
{
    compareView.image = [UIImage imageNamed:@"quanyinfu.png"];
}

//将待弹奏的音符以动画的方式呈现
-(void)yinfuyunxing
{
    UIImageView *quanyinfu = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"quanyinfu.png"]];
    
    //根据beishu随机生成音符，添加到指定位置
    int beishu = arc4random()%28;
    quanyinfu.frame = CGRectMake(xquan, 277+beishu*7.5, 23.5, 15);
    [self.view addSubview:quanyinfu];
    //将生成的音符以动画方式从左到右运行，完成后移除
    [UIView animateWithDuration:30.0f delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        CGRect temp = quanyinfu.frame;
        temp.origin.x = xquan-788;
        quanyinfu.frame = temp;
        } completion:^(BOOL finished){
            [quanyinfu removeFromSuperview];
        }];
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
        if ((packet->data[0] == 144)&&(packet->data[2]!=0)){
            int a = packet->data[1];
            panding = a;
            if (self.view.subviews.count > count) {
                [self performSelectorOnMainThread:@selector(compare) withObject:nil waitUntilDone:NO];
            }
        }
        packet = MIDIPacketNext(packet);
    }
}

@end
