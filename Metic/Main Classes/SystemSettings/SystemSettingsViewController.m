//
//  SystemSettingsViewController.m
//  Metic
//
//  Created by mac on 14-7-27.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "SystemSettingsViewController.h"
#import "MenuViewController.h"
#import "XGPush.h"
#import "UMSocial.h"
#import "BOAlertController.h"
#import "MTAccount.h"
#import "SocialSnsApi.h"

@interface SystemSettingsViewController ()<UMSocialUIDelegate>
{
    NSString* currentVersion;
    NSIndexPath* clickedIndexPath;
}

@end

@implementation SystemSettingsViewController
{
    NSInteger numOfSections;
    NSNumber *statusOfSwitch1,*statusOfSwitch2;
    UITapGestureRecognizer* backgroundRecognizer;
    UIAlertView* quitAlert;
}
@synthesize settings_tableview;

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PopToHereAndTurnToNotificationPage:) name: @"PopToFirstPageAndTurnToNotificationPage" object:nil];
    // Do any additional setup after loading the view.
    [CommonUtils addLeftButton:self isFirstPage:YES];

    settings_tableview.delegate = self;
    settings_tableview.dataSource = self;
    numOfSections = 4;
    
    [self initParams];
    
//    UIView* view = [[UIView alloc]initWithFrame:CGRectMake(40, 0, 300, 44)];
//    [view setBackgroundColor:[UIColor yellowColor]];
//    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
//    //        UIButton* button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 100, 40)];
//    button.frame = CGRectMake(0, 0, 300, 44);
//    //        button.center = view.center;
//    button.titleLabel.text = @"退出";
//    [button setBackgroundImage:[UIImage imageNamed:@"登陆界面按钮"] forState:UIControlStateNormal];
//    [button setBackgroundImage:[UIImage imageNamed:@"登陆界面按钮按下效果"] forState:UIControlStateSelected];
////    [view addSubview:button];
////    [settings_tableview.tableHeaderView addSubview:view];
//    settings_tableview.tableHeaderView = view;

    
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [MobClick beginLogPageView:@"消息中心"];
    [self.view bringSubviewToFront:_shadowView];
    _shadowView.hidden = NO;
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

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name: @"PopToFirstPageAndTurnToNotificationPage" object:nil];
}

//返回本页并跳转到消息页
-(void)PopToHereAndTurnToNotificationPage:(id)sender
{
    MTLOG(@"PopToHereAndTurnToNotificationPage  from  systemSetting");
    
    if ([[SlideNavigationController sharedInstance].viewControllers containsObject:self]){
        MTLOG(@"Here");
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"shouldIgnoreTurnToNotifiPage"]) {
            [[SlideNavigationController sharedInstance] popToViewController:self animated:NO];
            [self ToNotificationCenter];
        }
    }else{
        MTLOG(@"NotHere");
    }
}

-(void)ToNotificationCenter
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone"
                                                             bundle: nil];
    UIViewController* vc = [MenuViewController sharedInstance].notificationsViewController;
    if(!vc){
        vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"NotificationsViewController"];
        [MenuViewController sharedInstance].notificationsViewController = vc;
    }
    
    [[SlideNavigationController sharedInstance] openMenuAndSwitchToViewController:vc withCompletion:nil];
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

-(void)initParams
{
    NSUserDefaults* userDf = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary* userSettings = [userDf objectForKey:[NSString stringWithFormat:@"USER%@",[MTUser sharedInstance].userid]];
    statusOfSwitch1 = [userSettings objectForKey:@"systemSetting1"];
    statusOfSwitch2 = [userSettings objectForKey:@"systemSetting2"];
    
    backgroundRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backgroundClicked)];
//    [self.settings_tableview addGestureRecognizer:backgroundRecognizer];
    
}

#pragma mark - Touches
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.nextResponder touchesBegan:touches withEvent:event];
    MTLOG(@"touch begin");
    [quitAlert dismissWithClickedButtonIndex:0 animated:YES];
}


-(void)backgroundClicked
{
    MTLOG(@"quit alert");
    [quitAlert dismissWithClickedButtonIndex:0 animated:YES];
}

-(void)switch1Clicked:(UISwitch*)sender
{
    NSString* key = [NSString stringWithFormat:@"USER%@",[MTUser sharedInstance].userid];
    NSUserDefaults* userDf = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary* userSettings = [[NSMutableDictionary alloc]initWithDictionary:[userDf objectForKey:key]];
    if ([sender isKindOfClass:[UISwitch class]]) {
//        [userDf setBool:sender.on forKey:@"systemSettings1"];
        [userSettings setValue:[NSNumber numberWithBool:sender.on] forKey:@"systemSetting1"];
        [userDf setObject:userSettings forKey:key];
        MTLOG(@"switch1: %@",[NSNumber numberWithBool:sender.on]);
    }
    [userDf synchronize];
}

-(void)switch2Clicked:(UISwitch*)sender
{
    NSString* key = [NSString stringWithFormat:@"USER%@",[MTUser sharedInstance].userid];
    NSUserDefaults* userDf = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary* userSettings = [[NSMutableDictionary alloc]initWithDictionary:[userDf objectForKey:key]];
    if ([sender isKindOfClass:[UISwitch class]]) {
        [userSettings setValue:[NSNumber numberWithBool:sender.on] forKey:@"systemSetting2"];
        [userDf setObject:userSettings forKey:key];
        MTLOG(@"switch2: %@",[NSNumber numberWithBool:sender.on]);;
    }
    [userDf synchronize];
}

-(void)clearBuffers:(NSIndexPath*)indexPath
{
    UITableViewCell* cell = [settings_tableview cellForRowAtIndexPath:clickedIndexPath];
    UIActivityIndicatorView* acView = (UIActivityIndicatorView*)[cell.contentView viewWithTag:10];
    [acView startAnimating];
    [NSTimer scheduledTimerWithTimeInterval:6.0 target:self selector:@selector(operationTimeOut:) userInfo:acView repeats:NO];
    
    //删除图片缓存
    SDImageCache* cache = [SDImageCache sharedImageCache];
    [cache clearDisk];
    [cache clearMemory];
    NSString* documentPath = [NSString stringWithFormat:@"%@/Documents/media/avatar",NSHomeDirectory()];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:documentPath error:nil];
    [fileManager createDirectoryAtPath:documentPath withIntermediateDirectories:YES attributes:nil error:nil];
    
    //删除视频缓存
    NSString* CacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString* webPath = [CacheDir stringByAppendingPathComponent:@"VideoTemp"];
    NSString* cachePath = [CacheDir stringByAppendingPathComponent:@"VideoCache"];
    
    [fileManager removeItemAtPath:webPath error:nil];
    [fileManager removeItemAtPath:cachePath error:nil];
    [fileManager createDirectoryAtPath:webPath withIntermediateDirectories:YES attributes:nil error:nil];
    [fileManager createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:nil];
    
    //删除url缓存
    
    [CommonUtils showSimpleAlertViewWithTitle:@"温馨提示" WithMessage:@"清理缓存完成" WithDelegate:self WithCancelTitle:@"确定"];
    [acView stopAnimating];
}

-(void)updateCheck
{
    currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    MTLOG(@"version: %@",currentVersion);
    
    [MobClick setAppVersion:currentVersion];
//    [MobClick checkUpdate:@"有新版本更新啦!" cancelButtonTitle:@"待会更新" otherButtonTitles:@"立刻更新"];
//    [MobClick checkUpdateWithDelegate:self selector:@selector(callBackSelectorWithDictionary:)];
    UITableViewCell* cell = [settings_tableview cellForRowAtIndexPath:clickedIndexPath];
    UIActivityIndicatorView* acView = (UIActivityIndicatorView*)[cell.contentView viewWithTag:21];
    [acView startAnimating];
    [NSTimer scheduledTimerWithTimeInterval:6.0 target:self selector:@selector(operationTimeOut:) userInfo:acView repeats:NO];
    
//    NSString *URL = @"http://itunes.apple.com/lookup?id=909214472";
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
//    [request setURL:[NSURL URLWithString:URL]];
//    [request setHTTPMethod:@"POST"];
//    NSHTTPURLResponse *urlResponse = nil;
//    NSError *error = nil;
//    NSData *recervedData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
//    
//    NSString *results = [[NSString alloc] initWithBytes:[recervedData bytes] length:[recervedData length] encoding:NSUTF8StringEncoding];
//    NSDictionary *dic = [CommonUtils NSDictionaryWithNSString:results];
//    MTLOG(@"get update dictionary: %@",dic);
//    NSArray *infoArray = [dic objectForKey:@"results"];
//    if ([infoArray count]) {
//        NSDictionary *releaseInfo = [infoArray objectAtIndex:0];
//        NSString *lastVersion = [releaseInfo objectForKey:@"version"];
//        
//        if (![lastVersion isEqualToString:currentVersion]) {
//            //trackViewURL = [releaseInfo objectForKey:@"trackVireUrl"];
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"更新" message:@"有新的版本更新，是否前往更新？" delegate:self cancelButtonTitle:@"关闭" otherButtonTitles:@"更新", nil];
//            alert.tag = 10000;
//            [alert show];
//        }
//        else
//        {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"更新" message:@"此版本为最新版本" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//            alert.tag = 10001;
//            [alert show];
//        }
//    }
    

}

-(void)aboutApp
{
    [self performSegueWithIdentifier:@"systemsettings_about" sender:self];
}

-(void)quit
{
    quitAlert = [[UIAlertView alloc]initWithTitle:@"系统提示" message:@"请选择退出方式" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"退出程序",@"切换账号", nil];
    [quitAlert show];
    
}

- (void)animationFinished:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    
    if ([animationID compare:@"exitApplication"] == 0) {
        
        exit(0);
        
    }
    
}

-(void)callBackSelectorWithDictionary:(NSDictionary*)appUpdateInfo
{
    MTLOG(@"appUpdateInfo: %@",appUpdateInfo);
    BOOL update = [[appUpdateInfo objectForKey:@"update"] boolValue];
    if (update) {
//        [MobClick checkUpdate:@"有新版本更新啦!" cancelButtonTitle:@"待会更新" otherButtonTitles:@"立刻更新"];
//        [MobClick checkUpdate];
//        [MobClick checkUpdateWithDelegate:nil selector:@selector(callBackSelectorWithDictionary:)];
    }
    else
    {
        [CommonUtils showSimpleAlertViewWithTitle:@"温馨提示" WithMessage:@"已经是最新的版本啦!" WithDelegate:self WithCancelTitle:@"确定"];
    }
    UITableViewCell* cell = [settings_tableview cellForRowAtIndexPath:clickedIndexPath];
    UIActivityIndicatorView* acView = (UIActivityIndicatorView*)[cell.contentView viewWithTag:21];
    [acView stopAnimating];

}

-(void)operationTimeOut:(NSTimer*)timer
{
    [[timer userInfo] stopAnimating];
    MTLOG(@"time out");
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == quitAlert) {
        if (buttonIndex == 1) {
            MTLOG(@"退出程序");
//            [[MTAccount singleInstance] deleteAccount];
//            [[NSUserDefaults standardUserDefaults] setObject:@"out" forKey:@"MeticStatus"];
//            [[NSUserDefaults standardUserDefaults] synchronize];
            MTLOG(@"Metic被用户残忍杀死了");
            NSString* MtuserPath= [NSString stringWithFormat:@"%@/Documents/MTuser.txt", NSHomeDirectory()];
            if ([MTUser sharedInstance]) {
                [((AppDelegate *)[[UIApplication sharedApplication] delegate]) saveMarkers:[[NSMutableArray alloc] initWithObjects:[MTUser sharedInstance],nil] toFilePath:MtuserPath];
            }
            [UIView beginAnimations:@"exitApplication" context:nil];
            [UIView setAnimationDuration:0.5];
            [UIView setAnimationDelegate:self];
            //        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.view.window cache:NO];
            [UIView setAnimationDidStopSelector:@selector(animationFinished:finished:context:)];
            self.view.window.bounds = CGRectMake(0, 0, 0, 0);
            [(SlideNavigationController*)self.navigationController leftMenu].view.hidden = YES;
            //        [(AppDelegate*)[UIApplication sharedApplication].delegate window].bounds = CGRectMake(0, 0, 0, 0);
            [UIView commitAnimations];
            //        exit(0);
            
        }
        else if (buttonIndex == 2)
        {
            MTLOG(@"切换账号");
            [XGPush unRegisterDevice];
            ((AppDelegate*)[[UIApplication sharedApplication] delegate]).isLogined = NO;
            [MTUser deleteUser];
            [[MTAccount singleInstance] deleteAccount];
            [[NSUserDefaults standardUserDefaults] setValue:@"change" forKey:@"MeticStatus"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }

    }
    else if (alertView.tag == 10000)
    {
        if (buttonIndex==1) {
            NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com"];
            [[UIApplication sharedApplication]openURL:url];
        }
    }
}

- (void)didPresentAlertView:(UIAlertView *)alertView
{
    MTLOG(@"did present alertview");
//    UIView* view = [alertView superview];
//    if (view) {
//        MTLOG(@"add gesture in view ");
//        view.userInteractionEnabled = YES;
//        [view addGestureRecognizer:backgroundRecognizer];
//    }
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return numOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
        {
            return 4;
        }
            break;
        case 1:
        {
            return 1;
        }
//            break;
//        case 2:
//        {
//            return 2;
//        }
//            break;
//        case 3:
//        {
//            return 1;
//        }
//            break;
//            
        default:
            return 0;
            break;
    }
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIColor *color = [UIColor colorWithRed:0.29 green:0.76 blue:0.61 alpha:1];
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"setting"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"setting"];
    }
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 0) {
        if (row == 0) {
            cell.textLabel.text = @"通知栏提醒";
            UISwitch* nSwitch1 = [[UISwitch alloc]initWithFrame:CGRectMake(kMainScreenWidth - 85, 8, 30, 30)];
            [nSwitch1 addTarget:self action:@selector(switch1Clicked:) forControlEvents:UIControlEventValueChanged];
            nSwitch1.on = [statusOfSwitch1 boolValue];
            nSwitch1.tag = 1;
            [cell addSubview:nSwitch1];
        }else if (row == 1){
            cell.textLabel.text = @"清空缓存";
            UIActivityIndicatorView* activityIndicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(230, 7, 28, 28)];
            [activityIndicator setColor:color];
            activityIndicator.tag = 10;
            [cell.contentView addSubview:activityIndicator];
        }else if (row == 2){
            cell.textLabel.text = @"推荐给好友";
        }else if (row == 3){
            cell.textLabel.text = @"关于活动宝";
        }
        
    }
    else if(section == 1)
    {
        UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 50, 30)];
        [label setBackgroundColor:[UIColor clearColor]];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"退出";
        [cell setBackgroundColor:[UIColor redColor]];
        label.center = cell.center;
        label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [cell.contentView addSubview:label];
    }

    return cell;
}

#pragma  mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
//    if (numOfSections == section +1) {
//        return 50;
//    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    clickedIndexPath = indexPath;
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    if (section == 0) {
        if (row == 0) {
            UISwitch* mSwitch = (UISwitch*)[cell viewWithTag:1];
            if ([mSwitch isKindOfClass:[UISwitch class]]) {
                [mSwitch setOn:!mSwitch.on animated:YES];
                [self switch1Clicked:mSwitch];
            }
        }else if (row == 1){
            BOAlertController *alertView = [[BOAlertController alloc] initWithTitle:@"系统消息" message:@"确定要清除缓存？" viewController:[SlideNavigationController sharedInstance]];
            
            RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:@"取消" action:^{
            }];
            [alertView addButton:cancelItem type:RIButtonItemType_Cancel];
            
            RIButtonItem *okItem = [RIButtonItem itemWithLabel:@"确定" action:^{
                [self clearBuffers:indexPath];
            }];
            [alertView addButton:okItem type:RIButtonItemType_Other];
            [alertView show];

        }else if (row == 2){
            [UMSocialData defaultData].extConfig.wechatSessionData.url = @"http://www.whatsact.com";
            [UMSocialData defaultData].extConfig.wechatTimelineData.url = @"http://www.whatsact.com";
            [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeWeb;
            [UMSocialData defaultData].extConfig.wechatSessionData.title = @"推荐你使用【活动宝】";
            [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeDefault;
            [UMSocialData defaultData].extConfig.qqData.title = @"推荐你使用【活动宝】";
            [UMSocialData defaultData].extConfig.qqData.url = @"http://www.whatsact.com";
            [[UMSocialData defaultData].extConfig.sinaData setUrlResource:[[UMSocialUrlResource alloc] initWithSnsResourceType:UMSocialUrlResourceTypeImage url:@"http://www.whatsact.com"]];
            [UMSocialData defaultData].extConfig.smsData.urlResource = nil;
            [UMSocialData defaultData].extConfig.smsData.shareText = nil;
            [UMSocialConfig hiddenNotInstallPlatforms:@[UMShareToQQ,UMShareToSina,UMShareToWechatSession,UMShareToWechatFavorite,UMShareToWechatTimeline]];
            NSMutableArray *shareToSns = [[NSMutableArray alloc] initWithObjects:UMShareToWechatSession,UMShareToWechatTimeline,UMShareToQQ,UMShareToSina, nil];
            if (![WXApi isWXAppInstalled] || ![WeiboSDK isWeiboAppInstalled] || ![QQApiInterface isQQInstalled]) {
                [shareToSns addObject:UMShareToSms];
            }
            [UMSocialSnsService presentSnsIconSheetView:self
                                                 appKey:@"53bb542e56240ba6e80a4bfb"
                                              shareText:@"活动宝，是一款以“活动”为主题提倡用户进行线上线下活动的社交管理工具。"
                                             shareImage:[UIImage imageNamed:@"AppIcon57x57"]
                                        shareToSnsNames:shareToSns
                                               delegate:self];
        }else if (row == 3){
            [self aboutApp];
        }
        
    }else if (section == 1){
        [self quit];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
//{
//    if (section == numOfSections - 1) {
//        UIView* view = [[UIView alloc]initWithFrame:CGRectMake(10, 0, 300, 44)];
//        [view setBackgroundColor:[UIColor yellowColor]];
//        UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
////        UIButton* button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 100, 40)];
//        button.frame = CGRectMake(0, 0, 300, 44);
////        button.center = view.center;
//        button.titleLabel.text = @"退出";
//        [button setBackgroundImage:[UIImage imageNamed:@"登陆界面按钮"] forState:UIControlStateNormal];
//        [button setBackgroundImage:[UIImage imageNamed:@"登陆界面按钮按下效果"] forState:UIControlStateSelected];
//        [view addSubview:button];
//        return view;
//    }
//    return nil;
//}

#pragma mark - UMSocialUIDelegate 友盟推荐回调
//实现回调方法（可选）：
-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    //根据`responseCode`得到发送结果,如果分享成功
    if(response.responseCode == UMSResponseCodeSuccess)
    {
        //得到分享到的微博平台名
        MTLOG(@"share to sns name is %@",[[response.data allKeys] objectAtIndex:0]);
    }
}

#pragma mark - SlideNavigationControllerDelegate
- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
	return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
	return NO;
}

-(void)sendDistance:(float)distance
{
    if (distance > 0) {
        self.shadowView.hidden = NO;
        
        [self.view bringSubviewToFront:self.shadowView];
        
        [self.shadowView setAlpha:distance/(kMainScreenWidth * 1.2f)];
        
        self.navigationController.navigationBar.alpha = 1 - distance/(kMainScreenWidth * 1.2f);
    }else{
        self.shadowView.hidden = YES;
        [self.view sendSubviewToBack:self.shadowView];
    }
}
@end
