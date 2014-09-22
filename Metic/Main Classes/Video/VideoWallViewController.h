//
//  VideoWallViewController.h
//  WeShare
//
//  Created by ligang6 on 14-8-31.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <MediaPlayer/MediaPlayer.h>
#import "MJRefreshHeaderView.h"
#import "MJRefreshFooterView.h"
#import "../MTUser.h"

@interface VideoWallViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,MJRefreshBaseViewDelegate>
@property(nonatomic,strong) NSNumber* eventId;
@property(nonatomic,strong) NSString* eventName;
@property(nonatomic,strong) UITableView* tableView;
@property(nonatomic,strong) NSMutableDictionary* seleted_videoInfo;
@property(nonatomic,strong) UIImage* seleted_videoThumb;
@property BOOL shouldReload;
- (IBAction)uploadVideo:(id)sender;
@end