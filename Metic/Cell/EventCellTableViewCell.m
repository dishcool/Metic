//
//  CustomCellTableViewCell.m
//  Metic
//
//  Created by ligang_mac4 on 14-5-28.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "EventCellTableViewCell.h"
#import "BannerViewController.h"
#import "../Source/SVProgressHUD/SVProgressHUD.h"

@implementation EventCellTableViewCell

@synthesize themePhoto;
@synthesize eventName;
@synthesize eventDetail;
@synthesize videoWall;
@synthesize imgWall;
@synthesize beginTime;
@synthesize beginDate;
@synthesize endTime;
@synthesize endDate;
@synthesize timeInfo;
@synthesize location;
@synthesize launcherinfo;
@synthesize member_count;
@synthesize comment;
@synthesize commentInputView;
@synthesize addPaticipator;


#define widthspace 10
#define deepspace 4

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        
        // Initialization code
        

        
    }
    return self;
    
}

//- (void)setFrame:(CGRect)frame
//{
//    frame.origin.x += widthspace;
//    frame.origin.y += deepspace;
//    frame.size.width -= 2 * widthspace;
//    frame.size.height -= 2 * deepspace;
//    [super setFrame:frame];
//    
//}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    
    
    [super setSelected:selected animated:animated];
    
    
    
    // Configure the view for the selected state
    
}

- (IBAction)jumpToPictureWall:(id)sender {
    [self.eventController performSegueWithIdentifier:@"toPictureWall" sender:self.eventController];
//    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.eventController performSegueWithIdentifier:@"toPictureWall" sender:self.eventController];
//    });
}

- (IBAction)jumpToVideoWall:(id)sender {
    [self.eventController performSegueWithIdentifier:@"toVideoWall" sender:self.eventController];
//    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.eventController performSegueWithIdentifier:@"toVideoWall" sender:self.eventController];
//    });
    
}

- (IBAction)addComment:(id)sender {
}

- (IBAction)showParticipators:(id)sender {
    if (_eventController.isKeyBoard) {
        [_eventController.inputTextView resignFirstResponder];
    }else if (_eventController.isEmotionOpen){
        [_eventController button_Emotionpress:nil];
    } else [self.eventController performSegueWithIdentifier:@"showParticipators" sender:self.eventController];
}

- (IBAction)showBanner:(id)sender {
    if (_eventController.isKeyBoard) {
        [_eventController.inputTextView resignFirstResponder];
    }else if (_eventController.isEmotionOpen){
        [_eventController button_Emotionpress:nil];
    }else{
        BannerViewController* bannerView = [[BannerViewController alloc] init];
        bannerView.banner = themePhoto.image;
        [self.eventController presentViewController:bannerView animated:YES completion:^{}];
    }
}

-(void)drawOfficialFlag:(BOOL)isOfficial
{
    if (isOfficial) {
        if (_officialFlag) {
            [self addSubview:_officialFlag];
        }else{
            float width = self.bounds.size.width;
            _officialFlag = [[UIImageView alloc]initWithFrame:CGRectMake(width*0.85, 0, width*0.08, width*0.8/9)];
            _officialFlag.image = [UIImage imageNamed:@"flag.jpg"];
            UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, width*0.08, width*0.08)];
            label.textAlignment = NSTextAlignmentCenter;
            label.text = @"官";
            label.font = [UIFont systemFontOfSize:15];
            label.textColor = [UIColor whiteColor];
            [_officialFlag addSubview:label];
            [self addSubview:_officialFlag];
        }
    }else{
        if (_officialFlag) {
            [_officialFlag removeFromSuperview];
        }
    }
}

- (void)dealloc {
    
    
}


@end