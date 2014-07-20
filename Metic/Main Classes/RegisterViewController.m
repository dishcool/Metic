//
//  RegisterViewController.m
//  Metic
//
//  Created by ligang_mac4 on 14-5-27.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "RegisterViewController.h"

@interface RegisterViewController ()

@end

@implementation RegisterViewController
@synthesize textField_email;
@synthesize textField_confromPassword;
@synthesize textField_password;
@synthesize textField_userName;
@synthesize segmentedControl_gender;
@synthesize button_backToLogin;
@synthesize button_signUp;
@synthesize scrollView;
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
    self.navigationController.navigationBar.hidden = NO;
    // Do any additional setup after loading the view.
    
    UIColor *backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"背景颜色方格.png"]];
    [self.view setBackgroundColor:backgroundColor];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.scrollView.delegate  = self;
    
    rootView.myDelegate = self;
    textField_confromPassword.delegate = rootView;
    textField_email.delegate = rootView;
    textField_password.delegate = rootView;
    textField_userName.delegate = rootView;
    
    textField_confromPassword.placeholder = @"请再次输入密码";
    textField_email.placeholder = @"请输入您的邮箱";
    textField_password.placeholder = @"请输入您的密码，至少6位";
    textField_userName.placeholder = @"请输入您的用户名";
    
    textField_email.keyboardType = UIKeyboardTypeEmailAddress;
    
    textField_password.secureTextEntry = YES;
    textField_confromPassword.secureTextEntry = YES;
    
    textField_userName.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField_password.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField_email.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField_confromPassword.clearButtonMode = UITextFieldViewModeWhileEditing;

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

- (void)jumpToLogin
{
    [self performSegueWithIdentifier:@"RegisterToLogin" sender:self];
}

- (void)jumpToMain
{
    [self performSegueWithIdentifier:@"RegisterToMain" sender:self];
}


#pragma mark - button click
-(IBAction)signUpButtonClicked:(id)sender
{
    NSString* email = [textField_email text];
    NSString* password = [textField_password text];
    NSString* conformPassword = [textField_confromPassword text];
    NSString* userName = [textField_userName text];
    NSNumber* gender = [NSNumber numberWithInteger:[segmentedControl_gender selectedSegmentIndex]];
    NSString* salt = [CommonUtils randomStringWithLength:6];
    
    
    //    NSLog(@"random String: %@",salt);
    if (password.length<6) {
        [CommonUtils showSimpleAlertViewWithTitle:@"Warning" WithMessage:@"Wrong password length" WithDelegate:self WithCancelTitle:@"OK"];
    }
    else if (![CommonUtils isEmailValid:email]) {
        [CommonUtils showSimpleAlertViewWithTitle:@"Warning" WithMessage:@"Wrong email format" WithDelegate:self WithCancelTitle:@"OK"];
    }
    else if (![conformPassword isEqualToString:password])
    {
        [CommonUtils showSimpleAlertViewWithTitle:@"Warning" WithMessage:@"Password conformed error" WithDelegate:self WithCancelTitle:@"OK"];
    }
    else
    {
        NSMutableString* md5_str = [CommonUtils MD5EncryptionWithString:[[NSString alloc]initWithFormat:@"%@%@",password,salt]];
        NSMutableDictionary* mDic = [CommonUtils packParamsInDictionary:email,@"email",md5_str,@"passwd",userName,@"name",gender,@"gender",salt,@"salt",nil];
        
        NSLog(@"test packDictionary: %@",mDic);
        
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:mDic options:NSJSONWritingPrettyPrinted error:nil];
        HttpSender* httpSender = [[HttpSender alloc]initWithDelegate:self];
        [httpSender sendMessage:jsonData withOperationCode:REGISTER];
    }
    
    
    //    NSMutableDictionary* mDic = [CommonUtils packParamsInDictionary:[NSNumber numberWithInt:4],email,@"email",md5_str,@"passwd",userName,@"name",gender,@"gender",salt,@"salt",nil];
    
    
    
}

- (IBAction)backToLoginButtonClicked:(id)sender
{
    [self jumpToLogin];
}

//- (IBAction)text_Clear:(id)sender {
//    if ([sender superview] == [self.textField_userName superview])
//    {
//        self.textField_userName.text =@"";
//    }
//    else if([sender superview] == [self.textField_email superview])
//    {
//        self.textField_email.text = @"";
//    }
//    else if([sender superview] == [self.textField_password superview])
//    {
//        self.textField_password.text = @"";
//    }
//    else if([sender superview] == [self.textField_confromPassword superview])
//    {
//        self.textField_confromPassword.text = @"";
//    }
//}

- (IBAction)step_next:(id)sender {
    CGPoint offset = CGPointMake(0, 265);
    [self.scrollView setContentOffset:offset animated:YES];
}



#pragma mark - HttpSenderDelegate

-(void)finishWithReceivedData:(NSData *)rData
{
    NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
    NSLog(@"Register received Data: %@",temp);
    NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
    NSNumber *cmd = [response1 valueForKey:@"cmd"];
    switch ([cmd intValue]) {
        case NORMAL_REPLY:
            NSLog(@"register succeeded");
            [self jumpToMain];
            break;
        case USER_EXIST:
            NSLog(@"user existed");
            break;
        default:
            break;
    }
}


//#pragma mark - UItextFieldDelegate
//
//- (void)textFieldDidBeginEditing:(UITextField *)textField;           // became first responder
//{
//    
//}
//
//
//- (void)textFieldDidEndEditing:(UITextField *)textField;             // may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
//{
//    [textField resignFirstResponder];
//    
//}

@end
