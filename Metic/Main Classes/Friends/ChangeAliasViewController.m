//
//  ChangeAliasViewController.m
//  WeShare
//
//  Created by ligang_mac4 on 14-10-20.
//  Copyright (c) 2014年 WeShare. All rights reserved.
//

#import "ChangeAliasViewController.h"

@interface ChangeAliasViewController ()
{
    
    
}

@end

@implementation ChangeAliasViewController
@synthesize alias_view;
@synthesize ok_btn;
@synthesize fid;
@synthesize rootView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)initViews
{
    rootView = [[InputHandleView alloc]initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
    self.view = rootView;
    [self.view setBackgroundColor:[UIColor whiteColor]];  //不设背景会有一种视觉上的违和感
    self.navigationItem.title = @"修改好友备注";
    
    alias_view = [[myInputView alloc]init];
    [alias_view setFrame:CGRectMake(20, 60, 280, 25)];
    alias_view.prefix_label.text = @"备注名";
    alias_view.textField.delegate = rootView;
    
    ok_btn = [[UIBarButtonItem alloc]initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(okBtnClick)];
    
    self.navigationItem.rightBarButtonItem = ok_btn;
    [self.view addSubview:alias_view];
    
}

-(void)okBtnClick
{
    NSString* newAlias = alias_view.textField.text? alias_view.textField.text:@"";
    NSMutableDictionary* json_dic = [CommonUtils packParamsInDictionary:
                                     [MTUser sharedInstance].userid, @"id",
                                     fid, @"friend_id",
                                     ALIAS_SET, @"operation",
                                     newAlias, @"alias", nil];
    NSData* json_data = [NSJSONSerialization dataWithJSONObject:json_dic options:NSJSONWritingPrettyPrinted error:nil];
    
    void(^setAliasDone)(NSData *rData) = ^(NSData *rData)
    {
        NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
        NSLog(@"Received Data: %@",temp);
        NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
        NSInteger cmd = [[response1 objectForKey:@"cmd"]intValue];
        NSLog(@"cmd: %d",cmd);
        switch (cmd) {
            case NORMAL_REPLY:
            {
                
            }
                break;
                
            default:
                break;
        }
    };
    HttpSender *http = [[HttpSender alloc]initWithDelegate:self];
    [http sendMessage:json_data withOperationCode:ALIAS_OPERATION finshedBlock:setAliasDone];
}

@end
