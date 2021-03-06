//
//  SignSetttingViewController.m
//  Metic
//
//  Created by mac on 14-7-20.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "SignSetttingViewController.h"

@interface SignSetttingViewController ()
{
    NSString* newSign;
}

@end

@implementation SignSetttingViewController
@synthesize content_textView;
@synthesize rootView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initUI];
    [self initData];
}

//返回上一层
-(void)MTpopViewController{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initUI {
    
    [CommonUtils addLeftButton:self isFirstPage:NO];
    //    UIColor *color = [UIColor colorWithRed:0.29 green:0.76 blue:0.61 alpha:1];
    UIColor *color = [CommonUtils colorWithValue:0xbfbfbf];
    self.content_textView.layer.borderColor = color.CGColor;
    self.content_textView.layer.borderWidth = 1;
    self.content_textView.layer.cornerRadius = 3.5;
    self.content_textView.layer.masksToBounds = YES;
    self.content_textView.delegate = rootView;
    [self.right_barButton addTarget:self action:@selector(rightBarBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)initData {
    NSString *sign = [MTUser sharedInstance].sign;
    if ([sign isKindOfClass:[NSString class]] && ![sign isEqualToString:@""]) {
        self.content_textView.text = sign;
    }
}

-(void)rightBarBtnClicked:(id)sender
{
    newSign = self.content_textView.text;
    NSDictionary* json = [CommonUtils packParamsInDictionary:
                          [MTUser sharedInstance].userid,@"id",
                          newSign,@"sign",nil  ];
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender* http = [[HttpSender alloc]initWithDelegate:self];
    [http sendMessage:jsonData withOperationCode:CHANGE_SETTINGS];
}

#pragma mark - HttpSenderDelegate
-(void)finishWithReceivedData:(NSData*) rData
{
    NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
    MTLOG(@"Received Data: %@",temp);
    NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
    NSNumber* cmd = [response1 objectForKey:@"cmd"];
    MTLOG(@"cmd: %@",cmd);
    switch ([cmd integerValue]) {
        case NORMAL_REPLY:
        {
            MTLOG(@"个人描述修改成功");
            [MTUser sharedInstance].sign = newSign;
            [self.navigationController popViewControllerAnimated:YES];
        }
            break;
            
        default:
            MTLOG(@"个人描述修改失败");
            [CommonUtils showSimpleAlertViewWithTitle:@"系统提示" WithMessage:@"由于网络原因个人描述修改失败" WithDelegate:self WithCancelTitle:@"O.O ||"];
            break;
    }
    
}


@end
