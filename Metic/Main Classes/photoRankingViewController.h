//
//  photoRankingViewController.h
//  WeShare
//
//  Created by ligang6 on 14-9-22.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface photoRankingViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong) UITableView* tableView;
@property(nonatomic,strong) NSNumber* eventId;
@property BOOL shouldFlash;
@end
