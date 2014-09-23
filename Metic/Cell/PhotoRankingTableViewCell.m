//
//  PhotoRankingTableViewCell.m
//  WeShare
//
//  Created by ligang6 on 14-9-23.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "PhotoRankingTableViewCell.h"
#import "PhotoGetter.h"
#import "UIImageView+WebCache.h"

@implementation PhotoRankingTableViewCell
#define widthspace 10
#define deepspace 4

- (void)awakeFromNib
{
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    [_good_Btn setBackgroundImage:[CommonUtils createImageWithColor:[CommonUtils colorWithValue:0xe0e0e0]] forState:UIControlStateHighlighted];
    [_good_Btn addTarget:self action:@selector(addGood:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setFrame:(CGRect)frame
{
    //frame.origin.x += widthspace;
    frame.origin.y += deepspace;
    //frame.size.width -= 2 * widthspace;
    frame.size.height -= 2 * deepspace;
    [super setFrame:frame];
    
}

-(void)refresh
{
    self.author.text = [_photoInfo valueForKey:@"author"];
    self.time.text = [[_photoInfo valueForKey:@"time"] substringToIndex:10];
    self.authorId = [_photoInfo valueForKey:@"author_id"];
    PhotoGetter* avatarGetter = [[PhotoGetter alloc]initWithData:self.avatar authorId:self.authorId];
    [avatarGetter getAvatar];
    
    [self.good_Btn setEnabled:YES];
    [self setISZan:[[_photoInfo valueForKey:@"isZan"] boolValue]];
    [self setGood_buttonNum:[_photoInfo valueForKey:@"good"]];

    NSString *url = [CommonUtils getUrl:[NSString stringWithFormat:@"/images/%@",[_photoInfo valueForKey:@"photo_name"]]];
    NSLog(@"%@",url);
    [self.photo sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"活动图片的默认图片"]];
    
}

-(void)animationBegin
{
    if (!_controller.shouldFlash) {
        return;
    }
    [self setAlpha:0.5];
    [UIView beginAnimations:@"shadowViewDisappear" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    self.alpha = 1;
    [UIView commitAnimations];
}

-(void)setISZan:(BOOL)isZan
{
    self.isZan = isZan;
    if (isZan) {
        [self.good_Img setImage:[UIImage imageNamed:@"活动详情_点赞图按下效果"] ];
    }else{
        [self.good_Img setImage:[UIImage imageNamed:@"活动详情_点赞图"]];
    }
}

-(void)setGood_buttonNum:(NSNumber *)num
{
    [self.good_Num setText:[CommonUtils TextFromInt:[num intValue]]];
}


- (IBAction)addGood:(id)button
{

    [button setEnabled:NO];
    int photoid = [[self.photoInfo valueForKey:@"photo_id"] intValue];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self && ![button isEnabled] && [[self.photoInfo valueForKey:@"photo_id"] intValue] == photoid) {
            [button setEnabled:YES];
        }
    });
    
    BOOL isZan = [[_photoInfo valueForKey:@"isZan"] boolValue];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:[MTUser sharedInstance].userid forKey:@"id"];
    [dictionary setValue:[_photoInfo valueForKey:@"photo_id"] forKey:@"photo_id"];
    [dictionary setValue:[NSNumber numberWithInt:isZan? 2:3]  forKey:@"operation"];
    [dictionary setValue:self.eventId forKey:@"event_id"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    NSLog(@"%@",[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding]);
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:ADD_GOOD finshedBlock:^(NSData *rData) {
        [self.good_Btn setEnabled:YES];
        if (rData) {
            NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
            NSNumber *cmd = [response1 valueForKey:@"cmd"];
            if ([cmd intValue] == NORMAL_REPLY) {
                [_photoInfo setValue:[NSNumber numberWithBool:!isZan] forKey:@"isZan"];
                int zan_num = [[_photoInfo valueForKey:@"good"] intValue];
                if (isZan) {
                    zan_num --;
                }else{
                    zan_num ++;
                }
                [_photoInfo setValue:[NSNumber numberWithInt:zan_num] forKey:@"good"];
                _controller.shouldFlash = NO;
                [_controller.tableView reloadData];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    _controller.shouldFlash = YES;
                });
            }
        }
    }];
    
}

@end
