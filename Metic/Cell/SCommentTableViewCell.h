//
//  SCommentTableViewCell.h
//  Metic
//
//  Created by ligang6 on 14-6-15.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "../Main Classes/MTUser.h"
#import "../Utils/CommonUtils.h"
#import "../Utils/HttpSender.h"
#import "../Main Classes/EventDetailViewController.h"
#import "../Source/MLEmoji/MLEmojiLabel.h"

@interface SCommentTableViewCell : UITableViewCell<MLEmojiLabelDelegate>
- (IBAction)delete_Comment:(id)sender;
@property(strong,nonatomic) NSString* author;
@property(strong,nonatomic) NSNumber* authorid;
@property(strong,nonatomic) NSNumber* commentid;
@property (strong, nonatomic) IBOutlet MLEmojiLabel *comment;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *waitView;
@property(nonatomic,strong) EventDetailViewController *controller;
@property (strong, nonatomic) IBOutlet UIButton *resend_Button;
@end
