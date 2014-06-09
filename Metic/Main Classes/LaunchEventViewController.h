//
//  LaunchEventViewController.h
//  Metic
//
//  Created by ligang6 on 14-6-3.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpSender.h"

@interface LaunchEventViewController : UIViewController<UIScrollViewDelegate,UITextFieldDelegate,HttpSenderDelegate>
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UITextField *event_text;
@property (strong, nonatomic) IBOutlet UITextField *begin_time_text;
@property (strong, nonatomic) IBOutlet UITextField *end_time_text;
- (IBAction)launch:(id)sender;
@property (strong, nonatomic) IBOutlet UITextField *subject_text;
@property (strong, nonatomic) IBOutlet UITextField *location_text;
@property (strong, nonatomic) IBOutlet UITextView *detail_text;



@end
