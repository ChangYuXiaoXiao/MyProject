//
//  logInView.m
//  钢琴酷玩
//
//  Created by chang on 15-5-11.
//  Copyright (c) 2015年 CYL. All rights reserved.
//

#import "logInView.h"
@interface logInView()


@property (weak, nonatomic) IBOutlet UITextField *account;
@property (weak, nonatomic) IBOutlet UITextField *passWord;
@property (weak, nonatomic) IBOutlet UIButton *logInBtn;

@end

@implementation logInView


+(instancetype)logInView
{

    return [[[NSBundle mainBundle]loadNibNamed:@"logInView" owner:nil options:nil]lastObject];
}
- (void)awakeFromNib
{
    [self.layer setMasksToBounds:YES];
    [self.layer setCornerRadius:12];
    [self.layer setBorderWidth:1];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(textChange) name:UITextFieldTextDidChangeNotification object: self.account];
    [center addObserver:self selector:@selector(textChange) name:UITextFieldTextDidChangeNotification object: self.passWord];
}
- (IBAction)logIn:(UIButton *)sender
{
    
    if ([self.account.text isEqualToString:@"cyl"]&&[self.passWord.text isEqualToString:@"123"])
    {
        if ([self.delegate respondsToSelector:@selector(logInSucceed:)])
        [self.delegate logInSucceed:self];
    }
    else
    {
        if ([self.delegate respondsToSelector:@selector(logInError:)])
            [self.delegate logInError:self];
    }
}

-(void)textChange
{
    self.logInBtn.enabled = (self.account.text.length>0&&self.passWord.text.length>0);
}








@end
