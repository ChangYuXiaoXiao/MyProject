//
//  CYLReceivedMessage.m
//  钢琴酷玩
//
//  Created by 王 on 15/6/20.
//  Copyright (c) 2015年 CYL. All rights reserved.
//

#import "CYLSocketMessage.h"
#import "CYLActionID.h"
@interface CYLSocketMessage()
{
    int i;
}

@end

 static NSString *userID;
 static NSString *sessionID;

@implementation CYLSocketMessage


//重写set方法时将接收到的消息解析存入对应数据成员中
-(void)setReceivedData:(NSData *)receivedData
{
    _receivedData = receivedData;
    i = 0;
    self.totalLength = [self readIntData];
    self.packetLength = [self readIntData];
    self.errorCode = [self readIntData];
    self.messageID = [self readIntData];
    self.errorMessage = [self readStrData];
    self.actionID = [self readIntData];
    self.st = [self readStrData];
    if (!_errorCode)
    {
        if (self.actionID == [CYLActionID signIn])
        {
            return;
        }
        if (self.actionID == [CYLActionID logIn])
        {
            self.passWordID = [self readStrData];
            userID = [self readStrData];
            sessionID = [self readStrData];
            self.date = [self readStrData];
            self.isFirstLogIn = [self readBoolData];
        }
        if (self.actionID == [CYLActionID getMoney]||self.actionID == [CYLActionID changeMoney])
        {
            self.money = [self readIntData];
            self.rightRate = [self readStrData];
        }
        if (self.actionID == [CYLActionID getRankingList])
        {
            self.pageCount = [self readIntData];
            self.listCount = [self readIntData];
            self.listArray = [[NSMutableArray alloc]init];
            for (int j = 0; j < _listCount; j++)
            {
                self.unkonwn = [self readIntData];
                CYLRangeUser *rangeUser = [[CYLRangeUser alloc]init];
                rangeUser.userName = [self readStrData];
                rangeUser.score = [self readIntData];
                rangeUser.rightRate = [self readStrData];
                [self.listArray addObject:rangeUser];
            }
            self.currentRank = [self readIntData];
        }

    }
}

//提供一个类方法用于将要发送的char数据转化为NSData
+(NSData *)sentDataWithChardata:(char *)data
{
    int length = strlen(data);
    int sign_len = 0;
    char sign_str[1] = {0};
    int len = strlen(data) + 6 +sign_len;
    char * str = new char[len+1];
    char * pOut = new char[len*3+1];
    memset(str, 0, len+1);
    memset(pOut, 0, len*3+1);
    snprintf(str, len, "%s&sign=%s", data, sign_str);
    url_encode((unsigned char*)str, len, pOut, len*3);
    
    char * userData = new char[len*3+4];
    snprintf(userData, len*3+3, "?d=%s", pOut);
    length = strlen(userData);
    char* pSendData = new char[length + 4];
    char* header = new char[4];
    memset(header, 0, 4);
    memset(pSendData, 0, length + 4);
    
    //reverse
    header[0] = (length & 0x000000ff);
    header[1] = (length & 0x0000ff00) >> 8;
    header[2] = (length & 0x00ff0000) >> 16;
    header[3] = length >> 24;
    //copy
    memcpy(pSendData, header, 4);
    memcpy(pSendData + 4, userData, length);
    return [NSData dataWithBytes:pSendData length:length+4];
}

+(NSString *)userID
{
    return userID;
}
+(NSString *)sessionID
{
    return sessionID;
}

#pragma mark 辅助函数

//解析1字节的bool数据
-(BOOL)readBoolData
{
    NSData *data = [_receivedData subdataWithRange:NSMakeRange(i, 1)];
    BOOL boolData;
    [data getBytes:&boolData length:sizeof(boolData)];
    i = i + 1;
    return boolData;
}


//解析四字节的int数据
-(int)readIntData
{
    NSData *data = [_receivedData subdataWithRange:NSMakeRange(i, 4)];
    int intData;
    [data getBytes:&intData length:sizeof(intData)];
    i = i + 4;
    return intData;
}

//解析之前给的长度的字符串数据
-(NSString *)readStrData
{
    NSData *data = [_receivedData subdataWithRange:NSMakeRange(i, 4)];
    int length;
    [data getBytes:&length length:sizeof(length)];
    NSData *data2 = [_receivedData subdataWithRange:NSMakeRange(i+4, length)];
    NSString *strData = [[NSString alloc]initWithData:data2 encoding:NSUTF8StringEncoding];
    i = i + 4 + length;
    return strData;
}

//url编码
int url_encode(unsigned char* src, int src_len, char* dst, int dst_len)
{
    static const char *dont_escape = "._-$,;~()";
    static const char *hex = "0123456789abcdef";
    const char *end = dst + dst_len;
    int Scutstlen = 0;
    for (int i = 0; i < src_len && dst < end; src++, i++, dst++, Scutstlen++) {
        if (isalnum(*(const unsigned char *) src) ||
            strchr(dont_escape, * (const unsigned char *) src) != NULL) {
            *dst = *src;
        } else if (dst + 2 < end) {
            dst[0] = '%';
            dst[1] = hex[(* (const unsigned char *) src) >> 4];
            dst[2] = hex[(* (const unsigned char *) src) & 0xf];
            dst += 2;
            Scutstlen+= 2;
        }
    }
    *dst = '\0';    
    return Scutstlen;
}
@end
