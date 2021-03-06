//
//  CustomCellTableViewCell.m
//  Metic
//
//  Created by ligang_mac4 on 14-5-28.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "CustomCellTableViewCell.h"
#import "PictureWall2.h"
#import "VideoWallViewController.h"
#import "SVProgressHUD.h"
#import "UIImageView+MTWebCache.h"
#import "MegUtils.h"
#import "MTOperation.h"

@implementation CustomCellTableViewCell

@synthesize avatar;
@synthesize eventName;
@synthesize themePhoto;
//@synthesize eventDetail;
@synthesize videoWall;
@synthesize imgWall;
@synthesize timeInfo;
@synthesize location;
@synthesize launcherinfo;
@synthesize member_count;
@synthesize launcherId;


#define widthspace 10
#define deepspace 4

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        
        // Initialization code
        
    }
    return self;
    
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
//    //frame.origin.x += widthspace;
//    frame.origin.y += deepspace;
//    //frame.size.width -= 2 * widthspace;
//    frame.size.height -= 2 * deepspace;
//    [super setFrame:frame];
//    
}

-(void)drawOfficialFlag:(BOOL)isOfficial
{
    if (isOfficial) {
        if (self.officialFlag) {
            [self addSubview:self.officialFlag];
        }else{
            float width = kMainScreenWidth;
            self.officialFlag = [[UIImageView alloc]initWithFrame:CGRectMake(width - 48 - 20, 4, 25.6, 28.4)];
            self.officialFlag.image = [UIImage imageNamed:@"flag.jpg"];
            UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 25.6, 28.4)];
            label.textAlignment = NSTextAlignmentCenter;
            label.text = @"官";
            label.font = [UIFont systemFontOfSize:15];
            label.textColor = [UIColor whiteColor];
            [self.officialFlag addSubview:label];
            [self addSubview:self.officialFlag];
        }
    }else{
        if (self.officialFlag) {
            [self.officialFlag removeFromSuperview];
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

-(void)setController:(UIViewController *)controller
{
    _homeController = controller;
}

- (void)applyData:(NSDictionary*)data
{
    self.eventInfo = data;
    self.eventName.text = [data valueForKey:@"subject"];
    self.event = [data valueForKey:@"subject"];
    NSString* beginT = [data valueForKey:@"time"];
    NSString* endT = [data valueForKey:@"endTime"];
    
    [CommonUtils generateEventContinuedInfoLabel:self.eventTime beginTime:beginT endTime:endT];
    
    self.timeInfo.text = [CommonUtils calculateTimeInfo:beginT endTime:endT launchTime:[data valueForKey:@"launch_time"]];
    self.location.text = [[NSString alloc]initWithFormat:@"活动地点: %@",[data valueForKey:@"location"] ];
    
    NSInteger participator_count = [[data valueForKey:@"member_count"] integerValue];
    NSString* partiCount_Str = [NSString stringWithFormat:@"%ld",(long)participator_count];
    NSString* participator_Str = [NSString stringWithFormat:@"已有 %@ 人参加",partiCount_Str];
    
    self.member_count.font = [UIFont systemFontOfSize:15];
    self.member_count.numberOfLines = 0;
    self.member_count.lineBreakMode = NSLineBreakByCharWrapping;
    self.member_count.tintColor = [UIColor lightGrayColor];
    [self.member_count setText:participator_Str afterInheritingLabelAttributesAndConfiguringWithBlock:^(NSMutableAttributedString *mutableAttributedString) {
        NSRange redRange = [participator_Str rangeOfString:partiCount_Str];
        UIFont *systemFont = [UIFont systemFontOfSize:18];
        
        if (redRange.location != NSNotFound) {
            // Core Text APIs use C functions without a direct bridge to UIFont. See Apple's "Core Text Programming Guide" to learn how to configure string attributes.
            [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[CommonUtils colorWithValue:0xef7337].CGColor range:redRange];
            
            CTFontRef italicFont = CTFontCreateWithName((__bridge CFStringRef)systemFont.fontName, systemFont.pointSize, NULL);
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)italicFont range:redRange];
            CFRelease(italicFont);
        }
        return mutableAttributedString;
    }];
    
    NSString* launcher = [MTOperation getAliasWithUserId:data[@"launcher_id"] userName:data[@"launcher"]];

    self.launcherinfo.text = [[NSString alloc]initWithFormat:@"发起人: %@",launcher];
    NSInteger visibility = [data[@"visibility"] integerValue];
    switch (visibility) {
        case 0:
            self.eventType.text = @"活动类型: 私人活动";
            break;
        case 1:
            self.eventType.text = @"活动类型: 公开 (内容不可见)";
            break;
        case 2:
            self.eventType.text = @"活动类型: 公开 (内容可见)";
            break;
        default:
            break;
    }
    
    self.eventId = [data valueForKey:@"event_id"];
    self.launcherId = [data valueForKey:@"launcher_id"];
    //cell.avatar.layer.masksToBounds = YES;
    [self.avatar.layer setCornerRadius:15];
    
    [self drawOfficialFlag:[[data valueForKey:@"verify"] boolValue]];
    
    
    PhotoGetter* avatarGetter = [[PhotoGetter alloc]initWithData:self.avatar authorId:[data valueForKey:@"launcher_id"]];
    [avatarGetter getAvatar];
    
    PhotoGetter* bannerGetter = [[PhotoGetter alloc]initWithData:self.themePhoto authorId:[data valueForKey:@"event_id"]];
    NSString* bannerURL = [data valueForKey:@"banner"];
    NSString* bannerPath = [MegUtils bannerImagePathWithEventId:self.eventId];
    [bannerGetter getBanner:[data valueForKey:@"code"] url:bannerURL path:bannerPath];
    
    self.homeController = self.homeController;
    
    NSArray *memberids = [data valueForKey:@"member"];
    
    for (int i =3; i>=0; i--) {
        UIImageView *tmp = self.avatarArray[i];
        if (i < participator_count) {
            tmp.hidden = NO;
            PhotoGetter* miniGetter = [[PhotoGetter alloc]initWithData:tmp authorId:memberids[i]];
            [miniGetter getAvatar];
        }else{
            tmp.hidden = YES;
            [tmp sd_cancelCurrentImageLoad];
            tmp.image = nil;
        }
    }
}

- (IBAction)jumpToPictureWall:(id)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle: nil];
    PictureWall2 *pictureWall = [mainStoryboard instantiateViewControllerWithIdentifier: @"PictureWall2"];
    pictureWall.eventId = self.eventId;
    pictureWall.eventLauncherId = self.launcherId;
    pictureWall.eventName = self.event;
    pictureWall.eventInfo = self.eventInfo;
    [self.homeController.navigationController pushViewController:pictureWall animated:YES];
    return;
    
    self.homeController.selete_Eventid = self.eventId;
    self.homeController.selete_EventLauncherid = self.launcherId;
    self.homeController.selete_EventName = _event;
    [self.homeController performSegueWithIdentifier:@"HomeToPictureWall" sender:self.homeController];
}

- (IBAction)jumpToVideoWall:(id)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle: nil];
    VideoWallViewController *videowall = [mainStoryboard instantiateViewControllerWithIdentifier: @"VideoWallViewController"];
//    VideoWallViewController* videowall = [[VideoWallViewController alloc]init];
    videowall.eventId = self.eventId;
    videowall.eventLauncherId = self.launcherId;
    videowall.eventName = self.event;
    videowall.eventInfo = self.eventInfo;
    [self.homeController.navigationController pushViewController:videowall animated:YES];
    
    return;
    self.homeController.selete_Eventid = self.eventId;
    self.homeController.selete_EventLauncherid = self.launcherId;
    self.homeController.selete_EventName = _event;
    [self.homeController performSegueWithIdentifier:@"HomeToVideoWall" sender:self.homeController];
}



- (void)dealloc {
    
    
}


@end