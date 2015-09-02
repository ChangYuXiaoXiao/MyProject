//
//  CYLRankingListTableViewController.m
//  钢琴酷玩
//
//  Created by 王 on 15/6/22.
//  Copyright (c) 2015年 CYL. All rights reserved.
//

#import "CYLRankingListViewController.h"

@interface CYLRankingListViewController ()<AsyncSocketDelegate,UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) NSArray *listArray;
@property (weak, nonatomic) IBOutlet UILabel *currentRankLabel;

@end

@implementation CYLRankingListViewController



- (void)viewDidLoad {
    [super viewDidLoad];
//    [MBProgressHUD showMessage:@"正在拼命获取中，请稍候" toView:self.view];
    
    NSString *sentStr = [NSString stringWithFormat:@"MsgId=0&Sid=%@&Uid=%@&ActionID=%d&PageIndex=%d&PageSize=%d",[CYLSocketMessage sessionID],[CYLSocketMessage userID],[CYLActionID getRankingList],1,10];
    const char * sentChar = [sentStr UTF8String];
    [Singleton sharedInstance].socket.delegate = self;
    [[Singleton sharedInstance].socket readDataWithTimeout:3 tag:1];
    [[Singleton sharedInstance].socket writeData:[CYLSocketMessage sentDataWithChardata:(char *)sentChar] withTimeout:3 tag:1];
    
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.listArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 通过自定义cell显示排行榜信息
    rankingListTableViewCell *cell = [rankingListTableViewCell rankingListTableViewCell];
    cell.backgroundColor = [UIColor clearColor];
    //根据listArray中的数据显示对应行数据
    CYLRangeUser *user = self.listArray[indexPath.row];
    cell.userNumberLable.text = [NSString stringWithFormat:@"NO.%d",(int)indexPath.row+1];
    cell.userNameLable.text = user.userName;
    cell.scoreLable.text = [NSString stringWithFormat:@"%d",user.score];
    cell.rightRateLable.text = user.rightRate;
    
    // Configure the cell...
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark AsyncSocketDelegate方法

//连接到服务器时自动调用
-(void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"rankingList -- connect to host");
}

//已接收到服务器发送的信息时调用
-(void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"rankingList -- readData");
    [MBProgressHUD hideHUDForView:self.view];
    CYLSocketMessage *message = [[CYLSocketMessage alloc]init];
    message.receivedData = data;
    self.listArray = message.listArray;
    //显示当前排名信息
    self.currentRankLabel.text = [NSString stringWithFormat:@"您当前的排名为第%d名，继续加油哦！", message.currentRank];
    //    接收到服务器消息时初始化listTableView显示数据
    UITableView *listTableView = [[UITableView alloc]initWithFrame:CGRectMake(220, 144, 584, 600)];
    listTableView.dataSource = self;
    listTableView.delegate = self;
    listTableView.backgroundColor = [UIColor clearColor];
    listTableView.rowHeight = 60;
    listTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:listTableView];
    
}

// socket断开时调用
-(void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
    NSLog(@"rankingList -- disconnect to host");
    if ([self.view.subviews.lastObject isKindOfClass:[UITableView class]]) return;
    else
    {
        dispatch_queue_t mainQueue = dispatch_get_main_queue();
        dispatch_async(mainQueue, ^{
            [MBProgressHUD showError:@"网络连接错误，请稍候重试" toView:self.view time:2];
        });
        
    }
    [Singleton sharedInstance].socket = nil;
}


@end
