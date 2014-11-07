//
//  VideoDetailViewController.h
//  WeShare
//
//  Created by ligang6 on 14-9-2.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "PhotoGetter.h"
#import "../../MJRefresh/MJRefreshFooterView.h"
#import "../../UIView/MTMessageTextView.h"
#import "../../Source/ASIHTTPRequest2/ASIHTTPRequest.h"
#import "../../Cell/VideoWallTableViewCell.h"

@interface VideoDetailViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,MJRefreshBaseViewDelegate,UITextViewDelegate,UIAlertViewDelegate>{
    ASIHTTPRequest *videoRequest;
    unsigned long long Recordull;
    BOOL isReady;
}
@property (nonatomic,strong) UIImage* video_thumb;
@property (nonatomic,strong) NSNumber* videoId;
@property (nonatomic,strong) NSNumber* eventId;
@property (nonatomic,strong) NSString* eventName;
@property (nonatomic,strong) NSDictionary * videoInfo;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) VideoWallTableViewCell *SeleVcell;
@property (strong, nonatomic) MJRefreshFooterView* footer;
@property (nonatomic,strong) UIView* optionShadowView;
@property (nonatomic,strong) UIView* commentOptionView;
@property (strong, nonatomic) IBOutlet UIView *commentView;
@property (strong, nonatomic) IBOutlet MTMessageTextView *inputTextView;
@property (strong, nonatomic) IBOutlet UIButton *moreBtn;
@property BOOL isEmotionOpen;
- (IBAction)publishComment:(id)sender;
- (IBAction)button_Emotionpress:(id)sender;
- (IBAction)more:(id)sender;
@end

