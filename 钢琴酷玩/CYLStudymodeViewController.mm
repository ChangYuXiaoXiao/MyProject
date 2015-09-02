//
//  CYLStudymodeViewController.m
//  钢琴酷玩
//
//  Created by chang on 15-5-1.
//  Copyright (c) 2015年 chang. All rights reserved.
//

#import <CoreMIDI/CoreMIDI.h>
#import "CYLStudymodeViewController.h"
#import "PGMidi.h"
#import "staffView.h"
#import "studyImage.h"
#import "CYLNote.h"

#define staffViewX 0
#define staffViewY 439
#define staffViewW 1024
#define staffViewH 262
#define studyImageX 112
#define studyImageY 100
#define studyImageW 800
#define studyImageH 300
#define noteW 23.5
#define noteH 15
#define do 72
#define pdo 490
#define imgCount 4

UInt8 RandomNoteNumber() { return UInt8(rand() / (RAND_MAX / 127)); }

@interface CYLStudymodeViewController ()<PGMidiDelegate, PGMidiSourceDelegate>
{
    NSNumber *testNumber;
    NSTimer *testTimer;
}
@property (nonatomic,strong) PGMidi *midi;
@property (strong,nonatomic) CYLNote *note;
@property (weak, nonatomic) staffView *staffView;
@property (weak, nonatomic) studyImage *studyImageView;
@property (weak, nonatomic) IBOutlet UILabel *connectLable;



@end

@implementation CYLStudymodeViewController


#pragma mark UIViewController初始化相关


- (void)viewDidLoad
{
    [super viewDidLoad];
    //声明一个MIDI对象，用于监听和处理MIDI信号
    if (!_midi)
    {
        self.midi = [[PGMidi alloc]init];
        _midi.networkEnabled = YES;
    }
    
     //创建教程图片
    if (!_studyImageView)
    {
        //设置教程图片内容
        self.studyImageView = [studyImage studyImage];
        _studyImageView.imageName = @"study";
        //设置教程图片位置
        _studyImageView.frame = CGRectMake(studyImageX, studyImageY, studyImageW, studyImageH);
        //显示图片并设置代理
        [self.view addSubview:_studyImageView];
        _studyImageView.scrollView.delegate = self;
    }
    
    //创建五线谱
    if (!_staffView)
    {
        // 设置五线谱图片
        self.staffView = [staffView staffViewWithStudymode];
        // 设置五线谱位置
        _staffView.frame = CGRectMake(staffViewX, staffViewY, staffViewW, staffViewH);
        //显示五线谱
        [self.view addSubview:_staffView];
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    if (_midi.sources.count == 2) {
        self.connectLable.text = @"连接成功！";
    }else
    {
        self.connectLable.text = @"未连接，请等待。";
    }
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

-(CYLNote *)note
{
    if (!_note) _note = [[CYLNote alloc]init];
    return _note;
}

//重写set方法，在方法中将MIDI的代理交给控制器去监听硬件改动
- (void) setMidi:(PGMidi*)m
{
    _midi.delegate = nil;
    _midi = m;
    _midi.delegate = self;
    [self attachToAllExistingSources];
}


#pragma mark IBActions

//测试音符显示，该方法不精确，容易被阻塞，略过
- (IBAction)test:(UIButton *)sender
{
    testNumber = [NSNumber numberWithInt:21];
    testTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(testDisplay) userInfo:nil repeats:YES];
}

- (void)testDisplay
{
    int i = [testNumber intValue];
    if (i == 108) [testTimer invalidate];
    [self noteDisplay:testNumber];
    testNumber = [NSNumber numberWithInt:i+1];
}

//向电钢琴发送midi信息
- (IBAction) sendMidiData
{
    [self performSelectorInBackground:@selector(sendMidiDataInBackground) withObject:nil];
}


#pragma mark 辅助函数

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

//将传入的包进行解析，在UI界面上显示弹奏的音符
- (void) noteDisplay:(NSNumber *)number
{
    //调用模型的notePositionWithNumber方法，获得要显示的对象
    [self.note notePositionWithNumber:number];
    //初始化音符图像，显示
    UIImageView *noteView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"note.png"]];
    noteView.frame = CGRectMake( _note.noteX, _note.noteY, noteW, noteH);
    [self.view addSubview:noteView];
    //初始化升记号，显示
    UIImageView *upMark = _note.upMark;
    [self.view addSubview:upMark];
    //初始化要显示的额外的线，显示
    UIView *up1Line = _note.up1Line;
    UIView *up2Line = _note.up2Line;
    UIView *centerLine = _note.centerLine;
    UIView *down1Line = _note.down1Line;
    UIView *down2Line = _note.down2Line;
    [self.view addSubview:up1Line];
    [self.view addSubview:up2Line];
    [self.view addSubview:centerLine];
    [self.view addSubview:down1Line];
    [self.view addSubview:down2Line];
     // 动画显示，完成之后移除
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            noteView.alpha = 0;
            upMark.alpha = 0;
            up1Line.alpha = 0;
            up2Line.alpha = 0;
            centerLine.alpha = 0;
            down1Line.alpha = 0;
            down2Line.alpha = 0;
        } completion:^(BOOL finished) {
            [noteView removeFromSuperview];
            [upMark removeFromSuperview];
            [up1Line removeFromSuperview];
            [up2Line removeFromSuperview];
            [centerLine removeFromSuperview];
            [down1Line removeFromSuperview];
            [down2Line removeFromSuperview];
        }];
}

//在后台发送MIDI信号
- (void) sendMidiDataInBackground
{
    for (int n = 0; n < 20; ++n)
    {
        const UInt8 pitch      = RandomNoteNumber();
        const UInt8 noteOn[]  = { 0x90, pitch, 127 };
        const UInt8 noteOff[] = { 0x80, pitch, 0   };
        
        [_midi sendBytes:noteOn size:sizeof(noteOn)];
        [NSThread sleepForTimeInterval:0.1];
        [_midi sendBytes:noteOff size:sizeof(noteOff)];
    }
}

//列出所有信号源
- (void) attachToAllExistingSources
{
    for (PGMidiSource *source in _midi.sources)
    {
        [source addDelegate:self];
    }
}


#pragma mark scrollview的代理方法

//监听教程图片拖动，更改页码
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint offset = _studyImageView.scrollView.contentOffset;
    CGFloat offsetX = offset.x;
    CGFloat width = _studyImageView.scrollView.frame.size.width;
    int pagNum = (offsetX + 0.5*width)/width;
    _studyImageView.pageControl.currentPage = pagNum;
}


#pragma mark 代理方法，监听MIDI连接与通信

//当信号源增加时，自动调用此方法
- (void) midi:(PGMidi*)midi sourceAdded:(PGMidiSource *)source
{
    [source addDelegate:self];
    if (_midi.sources.count >= 2)
    {
        _connectLable.text = @"连接成功！";
    }
}

//当信号源移除时，自动调用此方法
- (void) midi:(PGMidi*)midi sourceRemoved:(PGMidiSource *)source
{
    if (_midi.sources.count < 2)
    {
        _connectLable.text = @"未连接，请等待。";
    }
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
            //获取用户输入音高，并转化为NSNumber对象
            int a = packet->data[1];
            NSNumber *number = [NSNumber numberWithInt:a];
            //传入NSNumber对象到noteDisplay:进行显示
            [self performSelectorOnMainThread:@selector(noteDisplay:) withObject:number waitUntilDone:NO];
        }
        packet = MIDIPacketNext(packet);
    }
}

@end
