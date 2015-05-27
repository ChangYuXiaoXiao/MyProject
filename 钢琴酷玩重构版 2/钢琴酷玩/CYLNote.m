//
//  note.m
//  钢琴酷玩
//
//  Created by chang on 15-5-1.
//  Copyright (c) 2015年 CYL. All rights reserved.
//

#import "CYLNote.h"
#define do 72
#define doPosition 490
#define lineW 70.5
#define lineH 4
#define noteW 23.5
#define noteH 15

@interface CYLNote()
{
    NSArray *positions;
}
@end

@implementation CYLNote

-(void)notePositionWithNumber:(NSNumber *)number
{
    //1.拿出包中的position文件，用一个数组接收
    if (!positions)
    {
        positions = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"position" ofType:@"plist"]];
    }
    //2.将传入的对象转换成基本数据类型，获取弹奏的音高信息
    int pitch = [number intValue];
    
    //3.根据音高从数组中提取显示音符的位置信息
    int index = (pitch - 12)%12;
    float position = [positions[index] intValue];
    if(pitch >= do)
    {
        //3.1如果该音大于高音do，计算其位置赋给note
        _noteX = (pitch - do)*7.5 + 612;
        _noteY = position;
        if (position <= doPosition - 30)
        {
            
            //3.1.1 如果显示位置高于第一线，则初始化上加一线
            _up1Line = [[UIView alloc]initWithFrame:CGRectMake(_noteX - noteW, doPosition - 32, lineW, lineH)];
            _up1Line.backgroundColor = [UIColor blackColor];
            
            //3.1.2 如果显示位置高于上加一线，则初始化上加二线
            if (position <= doPosition - 45)
            {
                _up2Line = [[UIView alloc]initWithFrame:CGRectMake(_noteX - noteW, doPosition - 47.5, lineW, lineH)];
                _up2Line.backgroundColor = [UIColor blackColor];
            }
        }
    }
    else
    {
        // 3.2 如果该音小于高音do，则计算低八度数，将其位置赋给note
        int degree = ((do-1-pitch)/12)+1;
        if (degree >= 4) degree = 3;
        
        _noteX = (pitch - do)*7.5 + 612;
        _noteY = position + (degree * 52.5);

        // 3.2.1若生成音符在大谱表中间，则初始化中间线
        if (_noteY >= doPosition+45 && _noteY <= doPosition+60) {
            _centerLine = [[UIView alloc]initWithFrame:CGRectMake(_noteX - noteW, doPosition + 58, lineW, lineH)];
            _centerLine.backgroundColor = [UIColor blackColor];
        }
        // 3.2.2同上，根据显示位置初始化下加一线，下加二线
        if (_noteY >= doPosition + 135)
        {
            _down1Line = [[UIView alloc]initWithFrame:CGRectMake( _noteX-noteW, doPosition+148, lineW, lineH)];
            _down1Line.backgroundColor = [UIColor blackColor];
            if (_noteY >= doPosition + 150)
            {
                _down2Line = [[UIView alloc]initWithFrame:CGRectMake(_noteX - noteW, doPosition + 163, lineW, lineH)];
                _down2Line.backgroundColor = [UIColor blackColor];
            }
        }
    }
    
    if (index ==1||index==3||index==6||index==8||index==10)
    {
         //当弹奏为黑键时，初始化升记号
        _upMark = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"upMark.png"]];
        _upMark.frame = CGRectMake(_noteX - 15, _noteY, noteH, noteH);
    }

}

@end
