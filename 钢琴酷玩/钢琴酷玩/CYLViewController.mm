//
//  CYLViewController.m
//  谜底
//
//  Created by 畅岩磊 on 14-12-10.
//  Copyright (c) 2014年 畅岩磊. All rights reserved.
//

#import "CYLViewController.h"
#import "CYLinitialViewController.h"
#import "PGMidi.h"
#import "iOSVersionDetection.h"
#import <CoreMIDI/CoreMIDI.h>
#define do 72
#define pdo 490
#define imgCount 4

UInt8 RandomNoteNumber() { return UInt8(rand() / (RAND_MAX / 127)); }

@interface CYLViewController ()<PGMidiDelegate, PGMidiSourceDelegate>

@property (weak, nonatomic) IBOutlet UILabel *connectLable;
@property (weak, nonatomic) IBOutlet UIScrollView *ScrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *PageControl;
@property (nonatomic,strong) PGMidi *midi;

@end

@implementation CYLViewController

#pragma mark UIViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    //声明一个MIDI对象，用于监听和处理MIDI信号
    self.midi = [[PGMidi alloc]init];
    _midi.networkEnabled = YES;
    //加载教程图片
    CGFloat width = self.ScrollView.frame.size.width;
    CGFloat height = self.ScrollView.frame.size.height;
    for (int i = 0; i < imgCount; i++) {
        UIImageView *imageView = [[UIImageView alloc]init];
        CGFloat imageX = i * width;
        CGFloat imageY = 0.f;
        imageView.frame = CGRectMake(imageX, imageY, width, height);
        imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"jiaocheng_%1d.jpg",i]];
        [self.ScrollView addSubview:imageView];
    }
    self.ScrollView.contentSize = CGSizeMake(imgCount * width, 0);
    //设置分页
    self.ScrollView.pagingEnabled = YES;
    self.ScrollView.delegate = self;
    self.PageControl.numberOfPages = imgCount;
}
- (void) viewWillAppear:(BOOL)animated
{
    if (_midi.sources.count == 2) {
        self.connectLable.text = @"连接成功！";
    }else
    {
        self.connectLable.text = @"未连接，请等待。";
    }

}


#pragma mark IBActions

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
- (void) shibieyinfu:(NSNumber *)number
{
    //声明要在UI界面上显示的各个对象
    UIImageView *quanyinfu = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"quanyinfu.png"]];
    UIImageView *shenghao = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"5.png"]];
    UIView *shangjiayixian;
    UIView *shangjiaerxian;
    UIView *xiajiayixian;
    UIView *xiajiaerxian;
    UIView *zhongjianxian;
    
    //1.拿出包中的weizhi文件，用一个数组接收
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource:@"weizhi" ofType:@"plist"];
    NSArray *weizhi = [NSArray arrayWithContentsOfFile:path];
    
    //2.将传入的对象转换成基本数据类型，获取弹奏的音高信息
    int yingao = [number intValue];
    
    //3.根据音高从数组中提取显示音符的位置信息
    int suoyin = (yingao-12)%12;
    float b = [weizhi[suoyin] intValue];
    if(yingao>=do)
    {
        //3.1如果该音大于高音do，计算其位置赋给quanyinfu
        float x1 = (yingao-do)*7.5+612;
        float y1 = b;
        quanyinfu.frame = CGRectMake(x1, y1, 23.5, 15);
        if (y1 <= pdo-30)
        {
            
            //3.1.1 如果显示位置高于第一线，则添加shangjiayixian
            shangjiayixian = [[UIView alloc]initWithFrame:CGRectMake(x1-23.5, pdo-32, 70.5, 4)];
            shangjiayixian.backgroundColor = [UIColor blackColor];
            [self.view addSubview:shangjiayixian];
            
            //3.1.2 如果显示位置高于shangjiayixian，则添加shangjiaerxian
            if (y1<=pdo-45)
            {
                shangjiaerxian = [[UIView alloc]initWithFrame:CGRectMake(x1-23.5, pdo-47.5, 70.5, 4)];
                shangjiaerxian.backgroundColor = [UIColor blackColor];
                [self.view addSubview:shangjiaerxian];
                
            }
        }

        if (suoyin ==1||suoyin==3||suoyin==6||suoyin==8||suoyin==10)
        {
            //3.1.3 当弹奏为黑键时，添加升记号
            shenghao.frame = CGRectMake(x1-15, y1, 15, 15);
            [self.view addSubview:shenghao];
        }
    }
    else
    {
        // 3.2 如果该音小于高音do，则计算低的八度数，将其位置赋给quanyinfu
        int dibadu = ((do-1-yingao)/12)+1;
        if (dibadu>=4) {
            dibadu = 3;
        }
        float x2 = (yingao-do)*7.5+612;
        float y2 = b+(dibadu*52.5);
        quanyinfu.frame = CGRectMake(x2, y2, 23.5, 15);
        // 3.2.1若生成音符在大谱表中间，则添加zhongjianxian
        if (y2>=pdo+45&&y2<=pdo+60) {
            zhongjianxian = [[UIView alloc]initWithFrame:CGRectMake(x2-23.5,pdo+58, 70.5, 4)];
            zhongjianxian.backgroundColor = [UIColor blackColor];
            [self.view addSubview:zhongjianxian];
        }
        // 3.2.2同上，根据显示位置添加xiajiayixian，xiajiaerxian
        if (y2>=pdo+135) {
            xiajiayixian = [[UIView alloc]initWithFrame:CGRectMake(x2-23.5, pdo+148, 70.5, 4)];
            xiajiayixian.backgroundColor = [UIColor blackColor];
            [self.view addSubview:xiajiayixian];
            if (y2>=pdo+150) {
                xiajiaerxian = [[UIView alloc]initWithFrame:CGRectMake(x2-23.5, pdo+163, 70.5, 4)];
                xiajiaerxian.backgroundColor = [UIColor blackColor];
                [self.view addSubview:xiajiaerxian];
            }
        }
        // 3.2.3 弹奏为黑键时，添加升记号
        if (suoyin ==1||suoyin==3||suoyin==6||suoyin==8||suoyin==10)
        {
            shenghao.frame = CGRectMake(x2-15, y2, 15, 15);
            [self.view addSubview:shenghao];
        }
    }
    // 4.将该音符添加到ui界面上
    [self.view addSubview:quanyinfu];
    // 5. 动画显示，完成之后移除
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        quanyinfu.alpha = 0;
        shenghao.alpha = 0;
        shangjiayixian.alpha = 0;
        shangjiaerxian.alpha = 0;
        xiajiayixian.alpha = 0;
        xiajiaerxian.alpha = 0;
        zhongjianxian.alpha = 0;
    } completion:^(BOOL finished) {
        [quanyinfu removeFromSuperview];
        [shenghao removeFromSuperview];
        [shangjiayixian removeFromSuperview];
        [shangjiaerxian removeFromSuperview];
        [xiajiayixian removeFromSuperview];
        [xiajiaerxian removeFromSuperview];
        [zhongjianxian removeFromSuperview];
    }];
}

//在后台发送MIDI信号
- (void) sendMidiDataInBackground
{
    for (int n = 0; n < 20; ++n)
    {
        const UInt8 note      = RandomNoteNumber();
        const UInt8 noteOn[]  = { 0x90, note, 127 };
        const UInt8 noteOff[] = { 0x80, note, 0   };
        
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

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint offset = self.ScrollView.contentOffset;
    CGFloat offsetX = offset.x;
    CGFloat width = self.ScrollView.frame.size.width;
    int pagNum = (offsetX + 0.5*width)/width;
    self.PageControl.currentPage = pagNum;
}

#pragma mark 代理方法，监听MIDI连接与通信

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
        _connectLable.text = @"连接成功！";
    }
}

//当信号源移除时，自动调用此方法
- (void) midi:(PGMidi*)midi sourceRemoved:(PGMidiSource *)source
{
    if (_midi.sources.count < 2) {
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
        if ((packet->data[0] == 144)&&(packet->data[2]!=0)){
            int a = packet->data[1];
            NSNumber *number = [NSNumber numberWithInt:a];
            [self performSelectorOnMainThread:@selector(shibieyinfu:) withObject:number waitUntilDone:NO];}
        packet = MIDIPacketNext(packet);
    }
}


@end
