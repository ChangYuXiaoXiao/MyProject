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
#import "musicSelectView.h"
#import "pianoKeyboardView.h"
#import "CYLMusic.h"
#import "Singleton.h"



#define staffViewX 0
#define staffViewY 238
#define staffViewW 1024
#define staffViewH 292
#define keyboardViewX 0
#define keyboardViewY 768-keyboardViewH-44
#define keyboardViewW 1024
#define keyboardViewH 166
#define noteX 970
#define noteY (277+number*7.5)
#define noteW 23.5
#define noteH 15
#define logInName @"logInName"
#define accountName @"accountName"

@interface CYLGamemodeViewController ()<PGMidiDelegate, PGMidiSourceDelegate,UIPickerViewDataSource,UIPickerViewDelegate,musicSelectViewDelegate,AsyncSocketDelegate,accountInfoViewDelegate>
{
    int inputPitch;//输入音高
    int countOfSubview;//初始化时界面上的控件数
    int money;//用户金币数
    int changeMoney;//增加或减少的金币数
    int positionOfComposition;//乐曲数组的序号
    float noteFrequency;//音符运行速度
    float noteSpeed;//音符出现频率
    BOOL isNeedChangeColorNote;//标志是否需要改变当前出现的音符颜色
    UIButton *currentKey;//当前要弹奏的键
    UIImageView *currentNote;//当前要弹奏的音符
    NSArray *positions;//存储输入音高对应y值信息
    NSString *musicName;//选择乐曲的名称
    NSArray *musicComposition;//乐曲数组集合
}
@property (nonatomic,strong) PGMidi *midi;
@property (strong, nonatomic) NSTimer *timer;
@property (weak, nonatomic) staffView *staffView;
@property (weak, nonatomic) pianoKeyboardView *keyboardView;
@property (weak,nonatomic) musicSelectView *musicSelectView;
@property (weak,nonatomic) accountInfoView *accounInfoView;
//存放乐谱模型的数组
@property (nonatomic, strong)NSArray *music;
@property (weak, nonatomic) IBOutlet UIButton *musicSelectBtn;
@property (weak, nonatomic) IBOutlet UIButton *beginBtn;
@property (weak, nonatomic) IBOutlet UIButton *gameOverBtn;
@property (weak, nonatomic) IBOutlet UILabel *connectLabel;
@property (weak, nonatomic) IBOutlet UILabel *judgeLabel;
@property (weak, nonatomic) IBOutlet UILabel *accountNameLable;
@property (weak, nonatomic) IBOutlet UISlider *noteFrequencySlider;
@property (weak, nonatomic) IBOutlet UISlider *noteSpeedSlider;
@property (weak, nonatomic) IBOutlet UILabel *musicLabel;

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
    //显示钢琴键盘
    if (!_keyboardView)
    {
        self.keyboardView = [pianoKeyboardView pianoKeyboardView];
        _keyboardView.frame = CGRectMake(keyboardViewX, keyboardViewY, keyboardViewW, keyboardViewH);
        [self.view addSubview:_keyboardView];
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [self.view addSubview:_accounInfoView];
    if ([defaults objectForKey:accountName] != nil)
    {
        //初始化账户名
        self.accountNameLable.text = [defaults objectForKey:accountName];
        //发送请求获取账户相关信息
        self.accounInfoView = [accountInfoView accountInfoView];
        _accounInfoView.delegate = self;
        _accounInfoView.frame = CGRectMake(1024-213, 44, 213, 126);
        NSString *sentStr = [NSString stringWithFormat:@"MsgId=0&Sid=%@&Uid=%@&ActionID=%d",[CYLSocketMessage sessionID],[CYLSocketMessage userID],[CYLActionID getMoney]];
        const char * sentChar = [sentStr UTF8String];
        [Singleton sharedInstance].socket.delegate = self;
        [[Singleton sharedInstance].socket readDataWithTimeout:3 tag:1];
        [[Singleton sharedInstance].socket writeData:[CYLSocketMessage sentDataWithChardata:(char *)sentChar] withTimeout:3 tag:1];
        self.noteFrequencySlider.value = [[defaults objectForKey:@"frequency"]floatValue];
        self.noteSpeedSlider.value = [[defaults objectForKey:@"speed"]floatValue];
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
    if (self.timer.valid)[self.timer invalidate];
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

-(NSArray *)music
{
    if (_music == nil)
    {
        NSArray *dictArray = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"music.plist" ofType:nil]];
        NSMutableArray *models = [NSMutableArray arrayWithCapacity:dictArray.count];
        for (NSDictionary *dict in dictArray )
        {
            CYLMusic *temp = [CYLMusic musicWithDictionary:dict];
            [models addObject:temp];
        }
        _music = models;
    }
    return _music;
}


#pragma mark IBAction

- (IBAction)gameBegin:(UIButton *)sender
{
    //点击开始按钮
    if ([sender.currentTitle isEqual:@"开始游戏"])
    {
        //将设置不可用按钮，结束按钮可用
        self.gameOverBtn.enabled = YES;
        self.musicSelectBtn.enabled = NO;
        self.noteFrequencySlider.enabled = NO;
        self.noteSpeedSlider.enabled = NO;
        isNeedChangeColorNote = YES;
        [self saveSetInfo];
        //开启定时器，不断产生音符
        positionOfComposition = 0;
        [self noteAnimation];
        noteFrequency = 5.25 - self.noteFrequencySlider.value;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:noteFrequency target:self selector:@selector(noteAnimation) userInfo:nil repeats:YES];
        self.beginBtn.enabled = NO;
    }else
    //点击结束按钮
    {
        //关闭定时器，重新初始化游戏界面
        self.gameOverBtn.enabled = NO;
        self.beginBtn.enabled = YES;
        self.musicSelectBtn.enabled = YES;
        self.noteFrequencySlider.enabled = YES;
        self.noteSpeedSlider.enabled = YES;
        if(currentKey.highlighted)[currentKey setHighlighted:NO];
        if (self.timer.valid) [self.timer invalidate];
        self.judgeLabel.text = nil;
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
- (IBAction)musicSelect:(UIButton *)sender
{
    //添加乐曲选择界面
    musicSelectView *msv = [musicSelectView musicSelectView];
    msv.delegate = self;
    msv.pickerView.dataSource = self;
    msv.pickerView.delegate = self;
    msv.frame = CGRectMake(0, 768, 1024, 768);
    [self.view addSubview:msv];
    [UIView animateWithDuration:0.3 animations:^{
        CGRect temp = CGRectMake(0, 0, 1024, 768);
        msv.frame = temp;
    }];
    //手动选择为随机
    [self pickerView:nil didSelectRow:0 inComponent:0];
}


#pragma mark 辅助函数

//将待弹奏的音符以动画的方式呈现
-(void)noteAnimation
{
    UIImageView *note = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"note.png"]];

    int number;
    if ([self.musicLabel.text isEqualToString:@"随机"])
    {
        //根据number随机生成音符，添加到指定位置
        number = arc4random()%28;
    }else
    {
        //根据选择的乐曲生成特定位置的音符
        number = [musicComposition[positionOfComposition++]intValue];
        if(positionOfComposition >= musicComposition.count)
        {
            [self.timer invalidate];
            note.tag = 999;
        }
    }
    note.frame = CGRectMake(noteX, noteY, noteW, noteH);
    [self.view addSubview:note];
    //将第一个音符对应的键变为高亮
    if (isNeedChangeColorNote)
    {
        currentKey = self.keyboardView.keyCollection[36-number];
        [currentKey setHighlighted:YES];
    }
    isNeedChangeColorNote = NO;
    //将生成的音符以动画方式从左到右运行，完成后移除
    noteSpeed = 33 - self.noteSpeedSlider.value;
    [UIView animateWithDuration:noteSpeed delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        CGRect temp = note.frame;
        temp.origin.x = noteX - 788;
        note.frame = temp;
    } completion:^(BOOL finished){
        if (note.alpha > 0.5)
        {
            if ([currentKey isHighlighted])
            {
                [currentKey setHighlighted:NO];
                [self performSelectorOnMainThread:@selector(changeNextKeyColor) withObject:nil waitUntilDone:NO];
            }
            if(_accounInfoView)
            {
                changeMoney = -2;
                [self updateMoney:changeMoney];
            }
        }
        if (!self.timer.valid && note.tag == 999)[self gameBegin:self.gameOverBtn];

        [note removeFromSuperview];
    }];
}

//更新数据
-(void)updateMoney:(int)CMoney
{
    //向服务器提交当前金币变化
    NSString *isPositive;
    int pCMoney = CMoney;
    if (CMoney>0) isPositive = @"true";
    else
    {
        isPositive = @"false";
        pCMoney = -CMoney;
    }
    NSString *sentStr = [NSString stringWithFormat:@"MsgId=0&Sid=%@&Uid=%@&ActionID=%d&Type=%@&Num=%d",[CYLSocketMessage sessionID],[CYLSocketMessage userID],1010,isPositive,pCMoney];
    const char * sentChar = [sentStr UTF8String];
    [[Singleton sharedInstance].socket readDataWithTimeout:3 tag:1];
    [[Singleton sharedInstance].socket writeData:[CYLSocketMessage sentDataWithChardata:(char *)sentChar] withTimeout:3 tag:1];
    [moneyChangeView moneyChangeViewWithMoney:CMoney toView:self.view];
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

//更改下一个音符对应键的颜色
-(void)changeNextKeyColor
{
    BOOL flag = YES;
    for (int i = countOfSubview; i<self.view.subviews.count; i++)
    {
        //获取下一个要弹奏的音符对象
        UIImageView *nextNote = self.view.subviews[i];
        if ( [nextNote isKindOfClass:[UIImageView class]] && nextNote.alpha != 0)
        {
            flag = NO;
            int number =(nextNote.frame.origin.y - 277.0)/7.5;
            currentKey = self.keyboardView.keyCollection[36-number];
            [currentKey setHighlighted:YES];
            break;
        }
    }
    if (flag)
    {
        isNeedChangeColorNote = YES;
    }
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
    int flag = 1;
    for (int i = countOfSubview; i<self.view.subviews.count; i++)
    {
        //获取当前要弹奏的音符对象
        currentNote = self.view.subviews[i];
        if ( [currentNote isKindOfClass:[UIImageView class]] && currentNote.alpha != 0)
        {
            //如果输入音符的y值信息与当前要弹奏的音符y值相同，则弹奏正确
            flag = 0;
            if (currentNote.frame.origin.y == pitchY)
            {
                currentNote.alpha = 0;
                self.judgeLabel.text = @"弹奏正确！";
                
                //弹奏正确，键颜色恢复正常
                [currentKey setHighlighted:NO];
                [self performSelectorOnMainThread:@selector(changeNextKeyColor) withObject:nil waitUntilDone:NO];
                changeMoney = 4;
                if (currentNote.tag == 999) [self gameBegin:self.gameOverBtn];
            }else
            {
                changeMoney = -1;
                //弹奏错误时更换音符图片提示用户,对应钢琴键颜色变红
                currentNote.image = [UIImage imageNamed:@"noteError.png"];
                UIButton *playedKey;
                for (UIButton *Key in self.keyboardView.keyCollection)
                {
                    if (Key.tag + 20 == inputPitch)
                    {
                        playedKey = Key;
                        [playedKey setSelected:YES];
                    }
                }
                self.judgeLabel.text = @"弹奏错误，请重弹。";
                
                //0.3秒后恢复图片，恢复对应键
                double delayInSeconds = 0.3f;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds*NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^{
                    [playedKey setSelected:NO];
                    currentNote.image = [UIImage imageNamed:@"note.png"];
                });
            }
            if (_accounInfoView)[self updateMoney:changeMoney];
            break;
        }
    }
    if (flag)[MBProgressHUD showError:@"没有待弹奏的音符" toView:self.view time:0.5];
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


#pragma mark pickerView 数据源方法
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.music.count;
}


#pragma mark pickerView  代理方法
-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    CYLMusic *music = self.music[row];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 280, 44)];
    label.adjustsFontSizeToFitWidth = YES;
    label.textAlignment = NSTextAlignmentCenter;
    label.text = music.name;
    label.textColor = [UIColor whiteColor];
    
    return label;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 44;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    CYLMusic *m = self.music[row];
    musicName = m.name;
    musicComposition = nil;
    musicComposition = m.composition;
}



#pragma mark musicSelectDelegate方法
-(void)confirm:(musicSelectView *)msv
{
    self.musicLabel.text = musicName;
    [self back:msv];
}
-(void)back:(musicSelectView *)msv
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect temp = CGRectMake(0, 768, 1024, 768);
        msv.frame = temp;
    } completion:^(BOOL finished) {
        [msv removeFromSuperview];
    }];
}

#pragma mark AsyncSocketDelegate方法

//连接到服务器时自动调用
-(void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"gameMode -- connect to host");
}

//已接收到服务器发送的信息时调用
-(void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"gamgeMode -- read data");
    CYLSocketMessage *message = [[CYLSocketMessage alloc]init];
    message.receivedData = data;
    //初始化时抓取的money信息
    if (message.actionID == [CYLActionID getMoney])
    {
        _accounInfoView.userInteractionEnabled = YES;
        money = message.money;
        _accounInfoView.money = money;
        _accounInfoView.rightRate = message.rightRate;
    }
    //游戏时实施提交money数据
    if (message.actionID == [CYLActionID changeMoney])
    {
        money = message.money;
        NSLog(@"%@",message.rightRate);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (double)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _accounInfoView.money = money;
            _accounInfoView.rightRate = message.rightRate;
        });
        
    }

}

-(void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_async(mainQueue, ^{
        [MBProgressHUD showError:@"网络链接错误，请重新登录" toView: self.view time:2];
    });
    
    [self gameBegin:self.gameOverBtn];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        CYLInitialViewController *controller = [storyboard instantiateInitialViewController];
        [self presentViewController:controller animated:YES completion:^{
            [controller LogOff];
        }];
    });
    [Singleton sharedInstance].socket = nil;
    
}

#pragma mark accountInfoViewDelegate方法
-(void)accountInfoViewRankingBtnClicked
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CYLRankingListViewController *controller =[storyboard instantiateViewControllerWithIdentifier:@"rankingList"];
    [self presentViewController:controller animated:YES completion:^{
        return;
    }];
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
