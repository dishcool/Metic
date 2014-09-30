//
//  AppDelegate.m
//  Metic
//
//  Created by ligang_mac4 on 14-5-26.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "AppDelegate.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialSinaHandler.h"
#import "Source/security/SFHFKeychainUtils.h"
#import "Main Classes/MTUser.h"
#import "MobClick.h"


@implementation AppDelegate
{
    BOOL isConnected;
    int numOfSyncMessages;
//    NSString* DB_path;
}
@synthesize mySocket;
@synthesize hostReach;
@synthesize heartBeatTimer;
@synthesize syncMessages;
@synthesize sql;
@synthesize notificationDelegate;
@synthesize networkStatusNotifier_view;
@synthesize isNetworkConnected;
@synthesize isLogined;
//@synthesize operationQueue;

//@synthesize user;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self umengTrack];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone"
															 bundle: nil];
	
//	MenuViewController *rightMenu = (MenuViewController*)[mainStoryboard
//                                                          instantiateViewControllerWithIdentifier: @"MenuViewController"];
//	//rightMenu.view.backgroundColor = [UIColor yellowColor];
//	rightMenu.cellIdentifier = @"rightMenuCell";
    NSUserDefaults* userDf = [NSUserDefaults standardUserDefaults];
    if (![userDf boolForKey:@"everLaunched"]) {
        [userDf setBool:YES forKey:@"everLaunched"];
        [userDf setBool:YES forKey:@"firstLaunched"];
        NSLog(@"The first launch");
        [userDf synchronize];
        
    }
    else
    {
        NSLog(@"Not the first launch");
        [userDf setBool:NO forKey:@"firstLaunched"];
        [userDf synchronize];
    }
	
	MenuViewController *leftMenu = (MenuViewController*)[mainStoryboard
                                                         instantiateViewControllerWithIdentifier: @"MenuViewController"];
	leftMenu.cellIdentifier = @"leftMenuCell";
	
//	[SlideNavigationController sharedInstance].righMenu = rightMenu;
	[SlideNavigationController sharedInstance].leftMenu = leftMenu;
    [self initApp];
    self.sql = [[MySqlite alloc]init];
    self.syncMessages = [[NSMutableArray alloc]init];
    numOfSyncMessages = -1;
    isNetworkConnected = YES;
    isLogined = NO;
    [self initViews];
//    [self initApp];
    
    _mapManager = [[BMKMapManager alloc]init];
    BOOL ret = [_mapManager start:@"oHzEkwMGSfXfqGcBF0B0vWK5" generalDelegate:nil];
	if (!ret) {
		NSLog(@"manager start failed!");
	}
    [UMSocialData setAppKey:@"53bb542e56240ba6e80a4bfb"];
    [UMSocialWechatHandler setWXAppId:@"wx4ec735a39c7a60f9" url:@"http://www.whatsact.com"];
    [UMSocialSinaHandler openSSOWithRedirectURL:@"http://www.whatsact.com"];
//    DB_path = [NSString stringWithFormat:@"%@/db",[MTUser sharedInstance].userid];
   
    //running in background
//    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
//    NSError *setCategoryErr = nil;
//    NSError *activationErr  = nil;
//    [[AVAudioSession sharedInstance]
//     setCategory: AVAudioSessionCategoryPlayback
//     error: &setCategoryErr];
//    [[AVAudioSession sharedInstance]
//     setActive: YES
//     error: &activationErr];
    
    // 监测网络情况
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name: kReachabilityChangedNotification
                                               object: nil];
    hostReach = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    [hostReach startNotifier];
    
//    application.applicationIconBadgeNumber = 0;
    
    //判断是否由远程消息通知触发应用程序启动
//    if ([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey] != nil) {
//        //获取应用程序消息通知标记数
//        int badge = [UIApplication sharedApplication].applicationIconBadgeNumber;
//        if (badge > 0) {
//            badge--;
//            [UIApplication sharedApplication].applicationIconBadgeNumber = badge;
//        }
//        
//    }
//    
//    //消息推送注册
//    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
//     UIRemoteNotificationTypeSound |
//     UIRemoteNotificationTypeAlert |
//     UIRemoteNotificationTypeBadge];
    
    return YES;

}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
//     [[UIApplication sharedApplication] setKeepAliveTimeout:600 handler:^{
//         /*todo send keep live */
//         NSLog(@"alive in background");
//         [NSThread sleepForTimeInterval:10];
//     }];
     NSLog(@"enter Background====================");
    application.applicationIconBadgeNumber = 0;
    
    UIApplication*   app = [UIApplication sharedApplication];
    __block    UIBackgroundTaskIdentifier bgTask;
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid)
            {
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    }];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid)
            {
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    });
    
    //预先保存mtuser内容
    NSString *userStatus = [[NSUserDefaults standardUserDefaults] objectForKey:@"MeticStatus"];
    if ([userStatus isEqualToString:@"in"]) {
        NSString* MtuserPath= [NSString stringWithFormat:@"%@/Documents/MTuser.txt", NSHomeDirectory()];
        if ([MTUser sharedInstance].name) {
            [self saveMarkers:[[NSMutableArray alloc] initWithObjects:[MTUser sharedInstance],nil] toFilePath:MtuserPath];
        }
    }
   
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[UIApplication sharedApplication] clearKeepAliveTimeout];
    NSLog(@"enter foreground");
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    application.applicationIconBadgeNumber = 0;
    NSLog(@"did become active");
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    //点击提示框的打开
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSLog(@"Metic被残忍杀死了");
    NSString *userStatus = [[NSUserDefaults standardUserDefaults] objectForKey:@"MeticStatus"];
    if ([userStatus isEqualToString:@"in"]) {
        NSString* MtuserPath= [NSString stringWithFormat:@"%@/Documents/MTuser.txt", NSHomeDirectory()];
        if ([MTUser sharedInstance].name) {
            [self saveMarkers:[[NSMutableArray alloc] initWithObjects:[MTUser sharedInstance],nil] toFilePath:MtuserPath];
        }
    }
    
    
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *token = [NSString stringWithFormat:@"%@",deviceToken];
    NSLog(@"Device token is : %@",token);
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSString *error_str = [NSString stringWithFormat:@"%@",error];
    NSLog(@"Failed to get token, error: %@",error_str);
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    //在此处理接受到的消息
    NSLog(@"APP receive remote notification: %@", userInfo);
}

-(void)initApp
{
    NSString *userStatus = [[NSUserDefaults standardUserDefaults] objectForKey:@"MeticStatus"];
    if ([userStatus isEqualToString:@"in"]) {
        NSString* MtuserPath= [NSString stringWithFormat:@"%@/Documents/MTuser.txt", NSHomeDirectory()];
        NSArray* users = [NSKeyedUnarchiver unarchiveObjectWithFile:MtuserPath];
        if (!users || users.count == 0) {
            [[NSUserDefaults standardUserDefaults] setObject:@"out" forKey:@"MeticStatus"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[MTUser alloc]init];
        }
    }else{
        [[MTUser alloc]init];
    }

}

+(void)refreshMenu
{
    [(MenuViewController*)[SlideNavigationController sharedInstance].leftMenu refresh];
    [(MenuViewController*)[SlideNavigationController sharedInstance].leftMenu clearVC];

}

//======================================Network Status Checking=====================================
-(void)initViews
{
//    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    CGRect frame = [UIScreen mainScreen].bounds;
    networkStatusNotifier_view = [[UIView alloc]initWithFrame:CGRectMake(0, frame.size.height + 1, frame.size.width, 20)];
//    [networkStatusNotifier_view setBackgroundColor:[UIColor yellowColor]];
    UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, 20)];
    label.text = @"网络连接异常，请检查网络设置";
    [label setBackgroundColor:[UIColor redColor]];
    label.font = [UIFont systemFontOfSize:13];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
//    label.center = networkStatusNotifier_view.center;
    label.tag = 110;
    [networkStatusNotifier_view addSubview:label];
//    [self.window addSubview:networkStatusNotifier_view];
//    [self.window.rootViewController.view addSubview:networkStatusNotifier_view];
//    [self.window bringSubviewToFront:networkStatusNotifier_view];
//    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:networkStatusNotifier_view];
//    networkStatusNotifier_view.hidden = YES;
    CGRect f = networkStatusNotifier_view.frame;
    NSLog(@"network view: x: %f, y: %f, width: %f, height: %f",f.origin.x,f.origin.y,f.size.width,f.size.height);
}


- (void)reachabilityChanged:(NSNotification *)note {
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    NetworkStatus status = [curReach currentReachabilityStatus];
    
    if (status == NotReachable) {
        if (isNetworkConnected) {
            [self showNetworkNotification:@"网络连接异常，请检查网络设置"];
        }
        isNetworkConnected = NO;
        
        if (isConnected) {
            [self disconnect];
        }
        
        NSLog(@"Network is not reachable");
    }
    else
    {
        if (!isNetworkConnected) {
            
            [UIView beginAnimations:@"showNetworkStatus" context:nil];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationDidStopSelector:@selector(hideNetworkNotification)];
            [UIView setAnimationDuration:3];
            [UIView setAnimationDelegate:self];
            UILabel* label = (UILabel*)[networkStatusNotifier_view viewWithTag:110];
            label.text = @"网络连接恢复正常";
            [UIView commitAnimations];

        }
        isNetworkConnected = YES;
        while (!isLogined) {
            [[NSRunLoop currentRunLoop]runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
        if (!isConnected) {
            [self connect];
        }

        
        
        NSLog(@"Network is reachable");
    }
}

+(BOOL)isEnableWIFI
{
    return ([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] != NotReachable);
}

+(BOOL)isEnableGPRS
{
    return ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable);
}

-(void)showNetworkNotification:(NSString*)message
{
    UILabel* label = (UILabel*)[networkStatusNotifier_view viewWithTag:110];
    label.text = message;
    CGRect frame = [UIApplication sharedApplication].keyWindow.frame;
    [[UIApplication sharedApplication].keyWindow addSubview:networkStatusNotifier_view];
    
    [UIView beginAnimations:@"showNetworkStatus" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//    [UIView setAnimationDidStopSelector:@selector(hideNetworkNotification)];
    
    [UIView setAnimationDuration:1];
//    [UIView setAnimationRepeatCount:1];
    [UIView setAnimationDelegate:self];
    
    [networkStatusNotifier_view setFrame:CGRectMake(0, frame.size.height - networkStatusNotifier_view.frame.size.height, frame.size.width, networkStatusNotifier_view.frame.size.height)];
    [UIView commitAnimations];
    NSLog(@"show network notification");
    NSLog(@"notification bar, y: %f, height: %f",networkStatusNotifier_view.frame.origin.y, networkStatusNotifier_view.frame.size.height);
}

-(void)hideNetworkNotification
{
    CGRect frame = [UIScreen mainScreen].bounds;
    [UIView beginAnimations:@"hideNetworkStatus" context:nil];
    //    networkStatusNotifier_view.hidden = NO;
    [UIView setAnimationDelay:5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    
    [UIView setAnimationDidStopSelector:@selector(NetworkNotificationDidHide)];
    [UIView setAnimationDuration:1];
//    [UIView setAnimationRepeatCount:1];
    [UIView setAnimationDelegate:self];
    
    [networkStatusNotifier_view setFrame:CGRectMake(0, frame.size.height + 1, frame.size.width, networkStatusNotifier_view.frame.size.height)];
    [UIView commitAnimations];
    
    NSLog(@"hide network notification");
    
}

-(void)NetworkNotificationDidHide
{
    [networkStatusNotifier_view removeFromSuperview];
}

//==========================================================================================

//===================================友盟统计 METHODS============================================

- (void)umengTrack {
    //    [MobClick setCrashReportEnabled:NO]; // 如果不需要捕捉异常，注释掉此行
    [MobClick setLogEnabled:NO];  // 打开友盟sdk调试，注意Release发布时需要注释掉此行,减少io消耗
    [MobClick setAppVersion:XcodeAppVersion]; //参数为NSString * 类型,自定义app版本信息，如果不设置，默认从CFBundleVersion里取
    //
    [MobClick startWithAppkey:UMENG_APPKEY reportPolicy:(ReportPolicy) REALTIME channelId:@""];
    //   reportPolicy为枚举类型,可以为 REALTIME, BATCH,SENDDAILY,SENDWIFIONLY几种
    //   channelId 为NSString * 类型，channelId 为nil或@""时,默认会被被当作@"App Store"渠道
    
    [MobClick checkUpdate];   //自动更新检查, 如果需要自定义更新请使用下面的方法,需要接收一个(NSDictionary *)appInfo的参数
    //    [MobClick checkUpdateWithDelegate:self selector:@selector(updateMethod:)];
    
    [MobClick updateOnlineConfig];  //在线参数配置
    
    //    1.6.8之前的初始化方法
    //    [MobClick setDelegate:self reportPolicy:REALTIME];  //建议使用新方法
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onlineConfigCallBack:) name:UMOnlineConfigDidFinishedNotification object:nil];
    
}

- (void)onlineConfigCallBack:(NSNotification *)note {
    
    NSLog(@"online config has fininshed and note = %@", note.userInfo);
}





//==========================================================================================

//===================================SOCKET METHODS============================================

- (void)handleReceivedNotifications
{
    NSString* path = [NSString stringWithFormat:@"%@/db",[MTUser sharedInstance].userid];
    [self.sql openMyDB:path];
    while (![self.sql isExistTable:@"notification"]) {
        [[NSRunLoop currentRunLoop]runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    NSArray* columns = [[NSArray alloc]initWithObjects:@"seq",@"timestamp",@"msg",@"ishandled", nil];
    
    for (NSDictionary* message in self.syncMessages) {
        NSString* timeStamp = [message objectForKey:@"timestamp"];
        NSNumber* seq = [message objectForKey:@"seq"];
        NSString* msg = [message objectForKey:@"msg"];
        NSArray* values = [[NSArray alloc]initWithObjects:
                           [NSString stringWithFormat:@"%@",seq],
                           [NSString stringWithFormat:@"'%@'",timeStamp],
                           [NSString stringWithFormat:@"'%@'",msg],
                           [NSString stringWithFormat:@"%d",-1],
                           nil];
        [self.sql insertToTable:@"notification" withColumns:columns andValues:values];
    }
    [self.sql closeMyDB];
    
    //通知铃声
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    AudioServicesPlayAlertSound(1106);
    
    NSUserDefaults* userDf = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary* userSettings = [userDf objectForKey:[NSString stringWithFormat:@"USER%@",[MTUser sharedInstance].userid]];
    BOOL flag = [[userSettings objectForKey:@"systemSetting1"] boolValue];
    NSLog(@"system setting1 flag: %d",flag);
    //发送通知
    UILocalNotification *notification=[[UILocalNotification alloc] init];
    if (notification!=nil) {
        NSDate *now=[NSDate new];
        notification.fireDate=[now dateByAddingTimeInterval:0];//0秒后通知
        notification.repeatInterval=0;//循环次数，kCFCalendarUnitWeekday一周一次
        notification.timeZone=[NSTimeZone defaultTimeZone];
        notification.applicationIconBadgeNumber += numOfSyncMessages; //应用的红色数字
        notification.soundName= UILocalNotificationDefaultSoundName;//声音，可以换成alarm.soundName = @"myMusic.caf"
        if (flag) {
            //去掉下面2行就不会弹出提示框
            notification.alertBody=@"有新的消息来啦╮(╯▽╰)╭ ";//提示信息 弹出提示框
            notification.alertAction = @"打开";  //提示框按钮
            notification.hasAction = NO; //是否显示额外的按钮，为no时alertAction消失
        }
        
        // NSDictionary *infoDict = [NSDictionary dictionaryWithObject:@"someValue" forKey:@"someKey"];
        //notification.userInfo = infoDict; //添加额外的信息
        
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        [((MenuViewController*)[SlideNavigationController sharedInstance].leftMenu) showUpdateInRow:4];
    }
    
    if ([(UIViewController*)self.notificationDelegate respondsToSelector:@selector(notificationDidReceive:)]) {
        [self.notificationDelegate notificationDidReceive:self.syncMessages];
    }

    numOfSyncMessages = -1;
    [self.syncMessages removeAllObjects];
}

//#pragma mark - NotificationDelegate
//
//- (void) notificationDidReceive:(NSArray*) messages
//{
//    
//}


#pragma mark - WebSocket
- (void)connect
{
    mySocket.delegate = nil;
    [mySocket close];
    
//    NSString* str = @"ws://203.195.174.128:10088/"; //腾讯
//    NSString* str = @"ws://115.29.103.9:10088/";
//    NSString* str = @"ws://localhost:9000/chat";
    
    NSString* str = @"ws://42.96.203.86:10088/";//阿里 测试服
//    NSString* str = @"ws://whatsact.gz.1251096186.clb.myqcloud.com:10088/";//腾讯 正式服
    
    NSURL* url = [[NSURL alloc]initWithString:str];
    
    NSURLRequest* request = [[NSURLRequest alloc]initWithURL:url];
    mySocket = [[SRWebSocket alloc]initWithURLRequest:request];
    mySocket.delegate = self;
    NSLog(@"Connecting...");
    [mySocket open];
}

- (void)scheduleHeartBeat
{
    self.heartBeatTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(sendHeartBeatMessage) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop]addTimer:heartBeatTimer forMode:NSRunLoopCommonModes];
}

- (void)unscheduleHeartBeat
{
    [self.heartBeatTimer invalidate];
}

- (void)sendHeartBeatMessage
{
    if (isConnected) {
        
        [mySocket send:@""];
        NSLog(@"Heart beats_^_^_");
    }
    else
    {
        [self disconnect];
//        [self connect];
//        NSLog(@"Reconnecting...");
    }
    
}

- (void)disconnect
{
    [self.mySocket close];
    [self unscheduleHeartBeat];
    NSLog(@"Disconnected");
}

#pragma mark - SRWebSocketDelegate

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    NSData* temp = [[NSData alloc]init];
    if ([message isKindOfClass:[NSString class]]) {
        temp = [message dataUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"Get message(string): %@",message);
    }
    else if ([message isKindOfClass:[NSData class]])
    {
        temp = message;
        NSLog(@"Get message(data): %@",message);
    }
//    NSLog(@"Get message(data): %@",temp);
//    NSString* temp2 = [[NSString alloc]initWithData:temp encoding:NSUTF8StringEncoding];
//    NSLog(@"Transformed message(string): %@",temp2);

    NSMutableDictionary *response1 = [NSJSONSerialization JSONObjectWithData:temp options:NSJSONReadingMutableLeaves error:nil];
    NSString* cmd = [response1 objectForKey:@"cmd"];
    
    //处理推送消息
    if ([cmd isEqualToString:@"sync"]) {
        
        /*
         这种情况的推送的json格式：
         “timestamp": string
         "cmd": "sync"
         "num": int
         */
        
        if (numOfSyncMessages == -1) {
            numOfSyncMessages = [(NSNumber*)[response1 objectForKey:@"num"] intValue];
        };
    }
    else if([cmd isEqualToString:@"message"])
    {
        /*
         这种情况的推送的json格式：
         “timestamp": string
         "cmd": "message"
         "seq": int
         "msg": json(string)
         */
        
        [self.syncMessages addObject:response1];
        NSString* msg_str = [response1 objectForKey:@"msg"];
        NSMutableDictionary* msg_dic = [CommonUtils NSDictionaryWithNSString:msg_str];
        [msg_dic setValue:[NSNumber numberWithInteger:-1] forKeyPath:@"ishandled"];
        NSInteger msg_cmd = [[msg_dic objectForKey:@"cmd"] integerValue];
        NSNumber* event_id1 = [msg_dic objectForKey:@"event_id"];
        NSNumber* fid1 = [response1 objectForKey:@"id"];
        
        for (NSDictionary* response2 in syncMessages) {
            NSString* msg_str2 = [response2 objectForKey:@"msg"];
            NSMutableDictionary* msg_dic2 = [CommonUtils NSDictionaryWithNSString:msg_str2];
            NSInteger msg_cmd2 = [[msg_dic2 objectForKey:@"cmd"] integerValue];
            if (msg_cmd == msg_cmd2) {
                if (event_id1) {
                    NSNumber* event_id2 = [msg_dic2 objectForKey:@"event_id"];
                    if (event_id2) {
                        if ([event_id1 integerValue] == [event_id2 integerValue]) {
                            [self.syncMessages removeObject:response2];
                        }
                    }
                }
                else
                {
                    NSNumber* fid2 = [response2 objectForKey:@"id"];
                    if (fid2) {
                        if (fid1 == fid2) {
                            [self.syncMessages removeObject:response2];
                        }
                        
                    }
                }
            }
            
        }

        if (msg_cmd  == ADD_FRIEND_RESULT) //cmd 998
        {
            [[MTUser sharedInstance].systemMsg insertObject:msg_dic atIndex:0];
            [[MTUser sharedInstance] synchronizeFriends];
            NSNumber* result = [msg_dic objectForKey:@"result"];
            NSLog(@"friend request result: %@",result);
            if ([result integerValue] == 1) {
                NSString* name = [msg_dic objectForKey:@"name"];
                NSString* email = [msg_dic objectForKey:@"email"];
                NSNumber* fid = [msg_dic objectForKey:@"id"];
                NSNumber* gender = [msg_dic objectForKey:@"gender"];
                NSString* path = [NSString stringWithFormat:@"%@/db",[MTUser sharedInstance].userid];
                [sql openMyDB:path];
                [sql insertToTable:@"friend"
                        withColumns:[[NSArray alloc]initWithObjects:@"id",@"name",@"email",@"gender", nil]
                          andValues:[[NSArray alloc] initWithObjects:
                                     [NSString stringWithFormat:@"%@",fid],
                                     [NSString stringWithFormat:@"'%@'",name],
                                     [NSString stringWithFormat:@"'%@'",email],
                                     [NSString stringWithFormat:@"%@",gender], nil]];
                [sql closeMyDB];
//                [MTUser sharedInstance].friendList = [[MTUser sharedInstance] getFriendsFromDB];
                NSDictionary* newFriend = [CommonUtils packParamsInDictionary:fid,@"id",name,@"name",gender,@"gender",email,@"email",nil];
                [[MTUser sharedInstance].friendList addObject:newFriend];
                [[MTUser sharedInstance] friendListDidChanged];
            }
            else if ([result integerValue] == 0)
            {
                NSLog(@"friend request is refused");
            }
            
        }
        else if (msg_cmd == 993 || msg_cmd == 992 || msg_cmd == 991) {
            if (![[MTUser sharedInstance].updateEventIds containsObject:[msg_dic valueForKey:@"event_id"]]) {
                [[MTUser sharedInstance].updateEventIds addObject:[msg_dic valueForKey:@"event_id"]];
                [[MTUser sharedInstance].updateEvents addObject:msg_dic];
                NSLog(@"新动态+1, updateEvents: %@",[MTUser sharedInstance].updateEvents);
            }
            NSLog(@"%d",[MTUser sharedInstance].updateEventIds.count);
        }
        else if (msg_cmd == 988 || msg_cmd == 989) {
            [[MTUser sharedInstance].atMeEvents addObject:msg_dic];
        }
        else if (msg_cmd == ADD_FRIEND_NOTIFICATION)
        {
            [[MTUser sharedInstance].friendRequestMsg insertObject:msg_dic atIndex:0];
        }
        else if (msg_cmd == EVENT_INVITE_RESPONSE || msg_cmd == REQUEST_EVENT_RESPONSE)
        {
            [[MTUser sharedInstance].systemMsg insertObject:msg_dic atIndex:0];
        }
        else if (msg_cmd == NEW_EVENT_NOTIFICATION || msg_cmd == REQUEST_EVENT)
        {
            NSInteger cmd2;
            NSInteger eventid1, eventid2;
            eventid1 = [[msg_dic objectForKey:@"event_id"] integerValue];
            NSInteger count = [MTUser sharedInstance].eventRequestMsg.count;
            for (NSInteger i = 0; i < count; i++) {
                NSMutableDictionary* aMsg = [MTUser sharedInstance].eventRequestMsg[i];
                cmd2 = [[aMsg objectForKey:@"cmd"] integerValue];
                NSLog(@"cmd1: %d, cmd2: %d",msg_cmd,cmd2);
                if (msg_cmd == cmd2) {
                    eventid2 = [[aMsg objectForKey:@"event_id"] integerValue];
                    NSLog(@"event_id1: %d, event_id2: %d",eventid1,eventid2);
                    if (eventid1 == eventid2) {
                        [[MTUser sharedInstance].eventRequestMsg removeObject:aMsg];
                        break;
                    }
                    
                }
            }
            [[MTUser sharedInstance].eventRequestMsg insertObject:msg_dic atIndex:0];
        }

        
        if (self.syncMessages.count == numOfSyncMessages) {
            NSNumber* seq = [response1 objectForKey:@"seq"];
            NSMutableDictionary* json = [CommonUtils packParamsInDictionary:
                                         @"feedback",@"cmd",[MTUser sharedInstance].userid, @"uid",
                                         seq,@"seq",
                                         nil];
            NSData* jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
            [mySocket send:jsonData];
            NSLog(@"feedback send json: %@",json);
            NSThread* thread = [[NSThread alloc]initWithTarget:self selector:@selector(handleReceivedNotifications) object:nil];
            
            [thread start];
            
            
        }
        
    }
    else if ([cmd isEqualToString:@"init"])
    {
        /*
         这种情况的推送的json格式：
         "cmd": "init"
         "seq": int
         */
        
        [self scheduleHeartBeat];
    }
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket;
{
    NSLog(@"Websocket Connected");
    isConnected = YES;
    NSDictionary* json = [CommonUtils packParamsInDictionary:[MTUser sharedInstance].userid,@"uid",nil];
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
    [mySocket send:jsonData];
    
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;
{
    NSLog(@":( Websocket Failed With Error %@", error);
    isConnected = NO;
    [self disconnect];
    NSString *userStatus =  [[NSUserDefaults standardUserDefaults] objectForKey:@"MeticStatus"];
    NSLog(@"isNetworkConnected: %d, login status: %@",isNetworkConnected, userStatus);
    if (isNetworkConnected && [userStatus isEqualToString:@"in"]) {
        [self connect];
        NSLog(@"Reconnecting from fail...");
    }
    
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{
    NSLog(@"WebSocket closed, code: %d,reason: %@",code,reason);
    isConnected = NO;
    [self disconnect];
    NSString *userStatus =  [[NSUserDefaults standardUserDefaults] objectForKey:@"MeticStatus"];
    NSLog(@"isNetworkConnected: %d, login status: %@",isNetworkConnected, userStatus);
    if (isNetworkConnected && [userStatus isEqualToString:@"in"]) {
        [self connect];
        NSLog(@"Reconnecting from close...");
    }
}
//=============================================================================================


- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return  [UMSocialSnsService handleOpenURL:url];
}
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return  [UMSocialSnsService handleOpenURL:url];
}

- (NSMutableArray *)loadMarkersFromFilePath:(NSString *)filePath {
    NSMutableArray *markers = nil;
    if (filePath == nil || [filePath length] == 0 ||
        [[NSFileManager defaultManager] fileExistsAtPath:filePath] == NO) {
        markers = [[NSMutableArray alloc] init];
    } else {
        markers = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    }
    return markers;
}




- (void)saveMarkers:(NSMutableArray *)markers toFilePath:(NSString *)filePath {
    [NSKeyedArchiver archiveRootObject:markers toFile:filePath];
}

@end
