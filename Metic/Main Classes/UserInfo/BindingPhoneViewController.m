//
//  BindingPhoneViewController.m
//  WeShare
//
//  Created by mac on 14-9-3.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "BindingPhoneViewController.h"

@interface BindingPhoneViewController ()

@end

@implementation BindingPhoneViewController
@synthesize gou_imageview;
@synthesize hint1_textfield;
@synthesize bindingNumber_label;
@synthesize hint2_label;
@synthesize checkContact_button;
@synthesize changeNumber_button;

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
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSString* phone;
    NSUserDefaults* userDf = [NSUserDefaults standardUserDefaults];
    NSString* key = [NSString stringWithFormat:@"USER%@",[MTUser sharedInstance].userid];
    NSMutableDictionary* userSettings = [[NSMutableDictionary alloc]initWithDictionary:[userDf objectForKey:key]];
    BOOL hasUpload = [[userSettings objectForKey:@"hasUploadPhoneNumber"] boolValue];
    
    if (hasUpload) {
        phone = [userSettings objectForKey:@"userPhoneNumber"];
        hint1_textfield.hidden = NO;
        hint2_label.hidden = NO;
        gou_imageview.hidden = NO;
        bindingNumber_label.text = [NSString stringWithFormat:@"绑定的手机号：%@",phone];
        [changeNumber_button setTitle:@"更换绑定手机" forState:UIControlStateNormal];
    }
    else
    {
        hint1_textfield.hidden = YES;
        hint2_label.hidden = YES;
        gou_imageview.hidden = YES;
        bindingNumber_label.text = @"当前还未绑定手机号";
        [changeNumber_button setTitle:@"绑定手机号码" forState:UIControlStateNormal];
    }
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)checkContactClicked:(id)sender {
    [self performSegueWithIdentifier:@"bindphone_friendrecommend" sender:self];
}

- (IBAction)changeNumberClicked:(id)sender {
    UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"请输入需要绑定的手机号码" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    alertView.tag = 250;
    [alertView show];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        
    }
    else if (buttonIndex == 1)
    {
        NSString* phone = [alertView textFieldAtIndex:0].text;
        
        void (^uploadPhoneNumberDone)(NSData*) = ^(NSData* rData)
        {
            NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
            NSLog(@"upload phone number done, received Data: %@",temp);
            NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
            NSNumber* cmd = [response1 objectForKey:@"cmd"];
            if ([cmd integerValue] == 100)
            {
                NSUserDefaults* userDf = [NSUserDefaults standardUserDefaults];
                NSString* key = [NSString stringWithFormat:@"USER%@",[MTUser sharedInstance].userid];
                NSMutableDictionary* userSettings = [[NSMutableDictionary alloc]initWithDictionary:[userDf objectForKey:key]];
                [userSettings setValue:phone forKey:@"userPhoneNumber"];
                [userDf synchronize];
                [CommonUtils showSimpleAlertViewWithTitle:@"温馨提示" WithMessage:@"绑定手机成功" WithDelegate:self WithCancelTitle:@"确定"];
                hint1_textfield.hidden = NO;
                hint2_label.hidden = NO;
                gou_imageview.hidden = NO;
                bindingNumber_label.text = [NSString stringWithFormat:@"绑定的手机号：%@",phone];
                [changeNumber_button setTitle:@"更换绑定手机" forState:UIControlStateNormal];

            }

            
        };
        
        NSDictionary* jsonDic = [CommonUtils packParamsInDictionary:
                                 [MTUser sharedInstance].userid, @"id",
                                 phone, @"my_phone_number",nil];
        NSLog(@"upload number json: %@",jsonDic);
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDic options:NSJSONWritingPrettyPrinted error:nil];
        HttpSender* http = [[HttpSender alloc]initWithDelegate:self];
        [http sendMessage:jsonData withOperationCode:UPLOAD_PHONEBOOK finshedBlock:uploadPhoneNumberDone];
        
        
    }
}
@end