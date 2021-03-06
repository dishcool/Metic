//
//  EventPreviewViewController.m
//  WeShare
//
//  Created by 俊健 on 15/4/13.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import "EventPreviewViewController.h"
#import "EventCellTableViewCell.h"
#import "EventPhotosTableViewCell.h"
#import "Reachability.h"
#import "UIImageView+MTWebCache.h"
#import "SVProgressHUD.h"
#import "MTDatabaseHelper.h"
#import "MTOperation.h"
#import "MegUtils.h"
#import "MTTextInputView.h"

#define MainFontSize 14


@interface EventPreviewViewController ()<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate,UIScrollViewDelegate,MTTextInputViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) MTTextInputView *textInputView;
@property(nonatomic,strong) NSArray* bestPhotos;
@property(nonatomic,strong) NSNumber* visibility;
@property(nonatomic,strong) NSNumber* eventId;
@property BOOL shouldShowPhoto;

@end

@implementation EventPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initUI];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.textInputView addKeyboardObserver];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.textInputView dismissKeyboard];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)initUI
{
    self.view.autoresizesSubviews = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    [CommonUtils addLeftButton:self isFirstPage:NO];
    [self.navigationItem setTitle:@"活动详情"];
    if (_tableView) {
        [_tableView setBackgroundColor:[UIColor colorWithWhite:242.0/255.0 alpha:1.0]];
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [_tableView setRowHeight:289];
        [_tableView setShowsVerticalScrollIndicator:NO];

        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_tableView reloadData];
    }
    
    if (self.beingInvited){
        [self setupInviteView];
    }else if (_visibility && ![_visibility boolValue] && !self.shareId)
    {
        //此活动不允许陌生人参与
        [self setupBottomLabel:@"此活动不允许陌生人参与" textColor:[UIColor grayColor] offset:64];
    }else if(_visibility){
        [self setupApplyTextView];
    }
}

- (void)initData
{
    _eventId = [_eventInfo valueForKey:@"event_id"];
    _visibility = [_eventInfo valueForKey:@"visibility"];
    if (_visibility && [_visibility boolValue] && [[Reachability reachabilityForInternetConnection] currentReachabilityStatus]!= 0) {
        _shouldShowPhoto = YES;
    }else _shouldShowPhoto = NO;
    if (_shouldShowPhoto) {
        [self pullPhotos];
    }
    [self visitEvent];

}

-(void)visitEvent
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    [dictionary setValue:self.eventId forKey:@"event_id"];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:VIEW_EVENT finshedBlock:^(NSData *rData) {
        if (rData) {
            NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
            NSNumber *cmd = [response1 valueForKey:@"cmd"];
            MTLOG(@"%@",cmd);
        }
    }
     ];
}

- (void)pullPhotos
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    [dictionary setValue:[NSNumber numberWithInt:4] forKey:@"number"];
    [dictionary setValue:self.eventId forKey:@"event_id"];
    MTLOG(@"%@",dictionary);
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:GET_GOOD_PHOTOS finshedBlock:^(NSData *rData) {
        if (rData) {
            NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
            NSNumber *cmd = [response1 valueForKey:@"cmd"];
            switch ([cmd intValue]) {
                case NORMAL_REPLY:{
                    NSMutableArray* newphoto_list =[[NSMutableArray alloc]initWithArray:[response1 valueForKey:@"good_photos"]];
                    for (int i = 0; i < newphoto_list.count; i++) {
                        NSMutableDictionary* dictionary = [[NSMutableDictionary alloc]initWithDictionary:newphoto_list[i]];
                        newphoto_list[i] = dictionary;
                    }
                    
                    _bestPhotos = newphoto_list;
                    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                }
                    break;
                default:{
                }
            }
            
        }else{
        }
    }];
}

-(void)setupBottomLabel:(NSString*)content textColor:(UIColor*)color offset:(NSInteger)offset
{
    UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(0, self.view.bounds.size.height - 50, kMainScreenWidth, 50)];
    label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    label.text = content;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = color;
    label.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:label];
    label.backgroundColor = [UIColor colorWithWhite:252.0/255.0 alpha:1.0];
    label.layer.borderColor = [UIColor colorWithWhite:220.0/255.0 alpha:1.0].CGColor;
    label.layer.borderWidth = 1;
}

-(void)setupApplyTextView
{
    if (self.textInputView && self.textInputView.style == MTInputSytleApply) {
        return;
    }
    
    self.textInputView = [[MTTextInputView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - 45, kMainScreenWidth, 45) style:MTInputSytleApply];
    self.textInputView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.textInputView.delegate = self;
    [self.view addSubview:self.textInputView];

}

-(void)setupInviteView
{
    //初始化评论框
    UIView *commentV = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height - 45, self.view.frame.size.width,45)];
    commentV.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [commentV setBackgroundColor:[UIColor whiteColor]];
    
    UIButton *ignoreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [ignoreBtn setTag:520];
    [ignoreBtn setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin];
    [ignoreBtn setFrame:CGRectMake(10, 5, kMainScreenWidth/2-15, 35)];
    [ignoreBtn setTitle:@"忽略邀请" forState:UIControlStateNormal];
    [ignoreBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [ignoreBtn.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:14]];
    [ignoreBtn setBackgroundImage:[CommonUtils createImageWithColor:[UIColor colorWithWhite:0.75 alpha:1.0f]] forState:UIControlStateNormal];
    ignoreBtn.layer.cornerRadius = 3;
    ignoreBtn.layer.masksToBounds = YES;
    [ignoreBtn addTarget:self action:@selector(ignoreInvitation) forControlEvents:UIControlEventTouchUpInside];
    [commentV addSubview:ignoreBtn];
    
    UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendBtn setTag:520];
    [sendBtn setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin];
    [sendBtn setFrame:CGRectMake(kMainScreenWidth/2+5, 5, kMainScreenWidth/2-15, 35)];
    [sendBtn setTitle:@"同意邀请" forState:UIControlStateNormal];
    [sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sendBtn.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:14]];
    [sendBtn setBackgroundImage:[CommonUtils createImageWithColor:[UIColor colorWithRed:85.0/255 green:203.0/255 blue:171.0/255 alpha:1.0f]] forState:UIControlStateNormal];
    sendBtn.layer.cornerRadius = 3;
    sendBtn.layer.masksToBounds = YES;
    [sendBtn addTarget:self action:@selector(agreeInvitation) forControlEvents:UIControlEventTouchUpInside];
    [commentV addSubview:sendBtn];
    
    [self.view addSubview:commentV];
    
}

-(void)ignoreInvitation
{
    NSMutableDictionary* msg_dic = (NSMutableDictionary*)_eventInfo;
    
    NSInteger seq1 = [[msg_dic objectForKey:@"seq"]integerValue];
    NSInteger cmd1 = [[msg_dic objectForKey:@"cmd"]integerValue];
    NSInteger event_id1 = [[msg_dic objectForKey:@"event_id"]integerValue];
    [[MTDatabaseHelper sharedInstance] updateDataWithTableName:@"notification"
                                                      andWhere:[CommonUtils packParamsInDictionary:[NSString stringWithFormat:@"%ld",(long)seq1],@"seq",nil]
                                                        andSet:[CommonUtils packParamsInDictionary:[NSString stringWithFormat:@"%d",0],@"ishandled",nil]];
    
    for (int i = 0; i < [MTUser sharedInstance].eventRequestMsg.count; i++) {
        NSMutableDictionary* msg = [MTUser sharedInstance].eventRequestMsg[i];
        NSInteger cmd2 = [[msg objectForKey:@"cmd"]integerValue];
        NSInteger event_id2 = [[msg objectForKey:@"event_id"]integerValue];
        NSInteger seq2 = [[msg objectForKey:@"seq"]integerValue];
        if (cmd1 == cmd2 && event_id1 == event_id2 && seq1 != seq2) {
            
            [[MTDatabaseHelper sharedInstance] deleteTurpleFromTable:@"notification" withWhere:[[NSDictionary alloc]initWithObjectsAndKeys:[[NSString alloc]initWithFormat:@"%ld", (long)seq2],@"seq", nil]];
            
            [[MTUser sharedInstance].eventRequestMsg removeObject:msg];
            continue;
        }
    }

    [[MTUser sharedInstance].eventRequestMsg removeObject:msg_dic];
    [msg_dic setValue:[NSNumber numberWithInteger:0] forKey:@"ishandled"];
    
    [[MTUser sharedInstance].historicalMsg insertObject:msg_dic atIndex:0];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)agreeInvitation
{
    [SVProgressHUD showWithStatus:@"正在处理" maskType:SVProgressHUDMaskTypeBlack];
    NSDictionary* msg_dic = _eventInfo;
    NSNumber* eventid = [msg_dic objectForKey:@"event_id"];
    NSMutableDictionary* json = [CommonUtils packParamsInDictionary:
                                 [NSNumber numberWithInt:NEW_EVENT_NOTIFICATION],@"cmd",
                                 [NSNumber numberWithInt:1],@"result",
                                 [MTUser sharedInstance].userid,@"id",
                                 eventid,@"event_id",
                                 nil];
    MTLOG(@"participate event okBtn, http json : %@",json );
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:PARTICIPATE_EVENT finshedBlock:^(NSData *rData) {
        if(rData){

            NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
            NSNumber *cmd = [response1 valueForKey:@"cmd"];
            switch ([cmd intValue]) {
                case NORMAL_REPLY:
                {

                    NSMutableDictionary* msg_dic = (NSMutableDictionary*)_eventInfo;
                    
                    NSInteger seq1 = [[msg_dic objectForKey:@"seq"]integerValue];
                    MTLOG(@"response event, seq: %ld",(long)seq1);
                    NSInteger cmd1 = [[msg_dic objectForKey:@"cmd"]integerValue];
                    NSInteger event_id1 = [[msg_dic objectForKey:@"event_id"]integerValue];
                    [[MTDatabaseHelper sharedInstance] updateDataWithTableName:@"notification"
                                                                      andWhere:[CommonUtils packParamsInDictionary:[NSString stringWithFormat:@"%ld",(long)seq1],@"seq",nil]
                                                                        andSet:[CommonUtils packParamsInDictionary:[NSString stringWithFormat:@"%@",@1],@"ishandled",nil]];
                    
                    for (int i = 0; i < [MTUser sharedInstance].eventRequestMsg.count; i++) {
                        NSMutableDictionary* msg = [MTUser sharedInstance].eventRequestMsg[i];
                        NSInteger cmd2 = [[msg objectForKey:@"cmd"]integerValue];
                        NSInteger event_id2 = [[msg objectForKey:@"event_id"]integerValue];
                        NSInteger seq2 = [[msg objectForKey:@"seq"]integerValue];
                        if (cmd1 == cmd2 && event_id1 == event_id2 && seq1 != seq2) {
                            
                            [[MTDatabaseHelper sharedInstance] deleteTurpleFromTable:@"notification" withWhere:[[NSDictionary alloc]initWithObjectsAndKeys:[[NSString alloc]initWithFormat:@"%ld", (long)seq2],@"seq", nil]];
                            
                            [[MTUser sharedInstance].eventRequestMsg removeObject:msg];
                            continue;
                        }
                    }
                    
                    [[MTUser sharedInstance].eventRequestMsg removeObject:msg_dic];
                    [msg_dic setValue:@1 forKey:@"ishandled"];
                    
                    [[MTUser sharedInstance].historicalMsg insertObject:msg_dic atIndex:0];
                    [SVProgressHUD dismissWithSuccess:@"加入活动成功" afterDelay:0.5];

                    //更新活动中心列表：
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"reloadEvent" object:nil userInfo:nil];
                    NSNumber* eventId = [_eventInfo valueForKey:@"event_id"];
                    [self toEventDetail:eventId];
                }
                    break;
                case REQUEST_FAIL:
                {
                    [SVProgressHUD dismissWithError:@"发送请求错误"];
                }
                    break;
                case ALREADY_IN_EVENT:
                {
                    NSMutableDictionary* msg_dic = (NSMutableDictionary*)_eventInfo;
                    NSInteger event_id1 = [[msg_dic objectForKey:@"event_id"]integerValue];
                    NSInteger cmd1 = [[msg_dic objectForKey:@"cmd"]integerValue];
                    NSInteger seq1 = [[msg_dic objectForKey:@"seq"]integerValue];
                    
                    [[MTDatabaseHelper sharedInstance]updateDataWithTableName:@"notification"
                                                                     andWhere:[CommonUtils packParamsInDictionary:[NSString stringWithFormat:@"%ld",(long)seq1],@"seq",nil]
                                                                       andSet:[CommonUtils packParamsInDictionary:[NSString stringWithFormat:@"%@",@1],@"ishandled",nil]];
                    
                    for (int i = 0; i < [MTUser sharedInstance].eventRequestMsg.count; i++) {
                        NSMutableDictionary* msg = [MTUser sharedInstance].eventRequestMsg[i];
                        NSInteger cmd2 = [[msg objectForKey:@"cmd"]integerValue];
                        NSInteger event_id2 = [[msg objectForKey:@"event_id"]integerValue];
                        NSInteger seq2 = [[msg objectForKey:@"seq"]integerValue];
                        if (cmd1 == cmd2 && event_id1 == event_id2 && seq1 != seq2) {
                            [[MTDatabaseHelper sharedInstance]deleteTurpleFromTable:@"notification" withWhere:[[NSDictionary alloc]initWithObjectsAndKeys:[[NSString alloc]initWithFormat:@"%ld", (long)seq2],@"seq", nil]];
                            [[MTUser sharedInstance].eventRequestMsg removeObject:msg];
                            continue;
                        }
                    }
                    [[MTUser sharedInstance].eventRequestMsg removeObject:msg_dic];
                    [SVProgressHUD dismissWithError:@"你已经在此活动中"];
                    NSNumber* eventId = [_eventInfo valueForKey:@"event_id"];
                    [self toEventDetail:eventId];
                }
                    break;
                case EVENT_NOT_EXIST:
                {
                    [SVProgressHUD dismissWithError:@"该活动已经解散" afterDelay:2.0];
                    
                    NSMutableDictionary* msg_dic = (NSMutableDictionary*)_eventInfo;
                    NSInteger event_id1 = [[msg_dic objectForKey:@"event_id"]integerValue];
                    NSInteger cmd1 = [[msg_dic objectForKey:@"cmd"]integerValue];
                    NSInteger seq1 = [[msg_dic objectForKey:@"seq"]integerValue];
                    [[MTDatabaseHelper sharedInstance]updateDataWithTableName:@"notification"
                                                                     andWhere:[CommonUtils packParamsInDictionary:[NSString stringWithFormat:@"%ld",(long)seq1],@"seq",nil]
                                                                       andSet:[CommonUtils packParamsInDictionary:[NSString stringWithFormat:@"%@",@1],@"ishandled",nil]];
                    
                    for (int i = 0; i < [MTUser sharedInstance].eventRequestMsg.count; i++) {
                        NSMutableDictionary* msg = [MTUser sharedInstance].eventRequestMsg[i];
                        NSInteger cmd2 = [[msg objectForKey:@"cmd"]integerValue];
                        NSInteger event_id2 = [[msg objectForKey:@"event_id"]integerValue];
                        NSInteger seq2 = [[msg objectForKey:@"seq"]integerValue];
                        if (cmd1 == cmd2 && event_id1 == event_id2 && seq1 != seq2) {
                            [[MTDatabaseHelper sharedInstance] deleteTurpleFromTable:@"notification"
                                                                           withWhere:[[NSDictionary alloc]initWithObjectsAndKeys:[[NSString alloc]initWithFormat:@"%ld", (long)seq2],@"seq", nil]];
                            [[MTUser sharedInstance].eventRequestMsg removeObject:msg];
                            continue;
                        }
                    }
                    [[MTUser sharedInstance].eventRequestMsg removeObject:msg_dic];
                    [SVProgressHUD dismissWithError:@"该活动已经解散" afterDelay:1.0];
                }
                    break;
                default:
                    
                    break;
            }
        } else{
            [SVProgressHUD dismissWithError:@"网络异常"];
        }
    }];
}

-(void)apply:(id)sender
{
    if (sender) {
        [sender setEnabled:NO];
    }
    NSString* confirmMsg = self.textInputView.text;
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    [dictionary setValue:[NSNumber numberWithInt:REQUEST_EVENT] forKey:@"cmd"];
    [dictionary setValue:confirmMsg forKey:@"confirm_msg"];
    [dictionary setValue:self.eventId forKey:@"event_id"];
    if (self.shareId) {
        [dictionary setValue:self.shareId forKey:@"share_id"];
    }

    MTLOG(@"%@",dictionary);
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:PARTICIPATE_EVENT finshedBlock:^(NSData *rData) {
        [sender setEnabled:YES];
        if (!rData) {
            [SVProgressHUD showErrorWithStatus:@"网络异常" duration:1.5f];
            return ;
        }
        NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
        NSNumber *cmd = [response1 valueForKey:@"cmd"];
        
        switch ([cmd intValue]) {
            case NORMAL_REPLY:
            {
                [self.textInputView dismissKeyboard];
                [self.textInputView removeKeyboardObserver];
                [self.textInputView removeFromSuperview];
//                self.textInputView = nil;
                
                [self setupBottomLabel:@"已申请加入" textColor:[UIColor colorWithRed:85.0/255 green:203.0/255 blue:171.0/255 alpha:1.0f] offset:0];
            }
                break;
            default:{
                
            }
        }
    }];
}

- (void)toEventDetail:(NSNumber*)eventId
{
    if (!eventId) return;
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle: nil];
    
    EventDetailViewController* eventDetail = [mainStoryboard instantiateViewControllerWithIdentifier: @"EventDetailViewController"];
    eventDetail.eventId = eventId;
    [_eventInfo setValue:@(YES) forKey:@"isIn"];
    eventDetail.event = (NSMutableDictionary*)_eventInfo;
    eventDetail.isFromQRCode = YES;
    [self.navigationController pushViewController:eventDetail animated:YES];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        
        NSString* cellClassName = @"EventCellTableViewCell";
        BOOL nibsRegistered = NO;
        if (!nibsRegistered) {
            UINib *nib = [UINib nibWithNibName:cellClassName bundle:nil];
            [tableView registerNib:nib forCellReuseIdentifier:cellClassName];
            nibsRegistered = YES;
        }
        
        MTTableViewCellBase *cell = (MTTableViewCellBase *)[tableView dequeueReusableCellWithIdentifier:cellClassName];
        cell.controller = self;
        [((EventCellTableViewCell*)cell).mediaEntrance setHidden:YES];
        if (self.eventInfo) {
            [cell applyData:self.eventInfo];
        }
        return cell;
    }else{
        BOOL nibsRegistered = NO;
        if (!nibsRegistered) {
            UINib *nib = [UINib nibWithNibName:NSStringFromClass([EventPhotosTableViewCell class]) bundle:nil];
            [tableView registerNib:nib forCellReuseIdentifier:@"EventPhotosTableViewCell"];
            nibsRegistered = YES;
        }
        EventPhotosTableViewCell *cell = (EventPhotosTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"EventPhotosTableViewCell"];
        if (_shouldShowPhoto) {
            cell.imagesView.hidden = NO;
            for (int i = 0; i < 4; i++) {
                UIImageView* imgView = cell.images[i];
                if (i < _bestPhotos.count) {
                    NSDictionary* photoInfo = _bestPhotos[i];
                    imgView.hidden = NO;
                    
                    [imgView setContentMode:UIViewContentModeScaleAspectFit];
                    imgView.image = [UIImage imageNamed:@"活动图片的默认图片"];
                    NSString* path = [MegUtils photoImagePathWithImageName:[photoInfo valueForKey:@"photo_name"]];
                    [[MTOperation sharedInstance] getUrlFromServer:path success:^(NSString *url) {
                        [imgView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"活动图片的默认图片"] cloudPath:path completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                            if (!image) {
                                imgView.image = [UIImage imageNamed:@"加载失败"];
                            }else{
                                [imgView setContentMode:UIViewContentModeScaleAspectFill];
                            }
                        }];
                    } failure:^(NSString *message) {
                        imgView.image = [UIImage imageNamed:@"加载失败"];
                    }];

                }else{
                    imgView.hidden = YES;
                }
            }
        }else{
            cell.imagesView.hidden = YES;
        }
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        
        NSString* text = [self.eventInfo valueForKey:@"remark"];
        float commentHeight = [CommonUtils calculateTextHeight:text width:kMainScreenWidth - 20 fontSize:MainFontSize isEmotion:NO];
        if (commentHeight < 25) commentHeight = 25;
        if (text && [text isEqualToString:@""]) {
        }else if(text) commentHeight += 5;
        return 128.0 + commentHeight + 158 * kMainScreenWidth / 320 + 31 * (kMainScreenWidth - 30) / 290.0f;
    }
    else {
        if (_shouldShowPhoto && _bestPhotos.count > 0)
            return 121*kMainScreenWidth/320+10;
        else return 51*kMainScreenWidth/320
            ;
    }
}

#pragma mark - Scroll view delegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.textInputView dismissKeyboard];
}

#pragma mark - MTTextInputView delegate
- (void)textInputView:(MTTextInputView *)textInputView sendMessage:(NSString *)message {
    if (textInputView.style == MTInputSytleApply) {
        [self apply:nil];
    }
}


@end
