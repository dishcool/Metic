//
//  MTTableView.m
//  Metic
//
//  Created by ligang_mac4 on 14-6-26.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "MTTableView.h"
#import "../Cell/CustomCellTableViewCell.h"

@implementation MTTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


#pragma mark 代理方法-UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.eventsSource) {
        return self.eventsSource.count;
    }else
        return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"customcell";
    BOOL nibsRegistered = NO;
    if (!nibsRegistered) {
        UINib *nib = [UINib nibWithNibName:NSStringFromClass([CustomCellTableViewCell class]) bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
        nibsRegistered = YES;
    }
    CustomCellTableViewCell *cell = (CustomCellTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    if (self.eventsSource) {
        NSDictionary *a = self.eventsSource[indexPath.row];
        cell.eventName.text = [a valueForKey:@"subject"];
        NSString* beginT = [a valueForKey:@"time"];
        NSString* endT = [a valueForKey:@"endTime"];
        cell.beginDate.text = [[[beginT substringWithRange:NSMakeRange(5, 5)] stringByAppendingString:@"日"] stringByReplacingOccurrencesOfString:@"-" withString:@"月"];
        cell.beginTime.text = [beginT substringWithRange:NSMakeRange(11, 5)];
        cell.endDate.text = [[[endT substringWithRange:NSMakeRange(5, 5)] stringByAppendingString:@"日"]  stringByReplacingOccurrencesOfString:@"-" withString:@"月"];
        cell.endTime.text = [endT substringWithRange:NSMakeRange(11, 5)];
        cell.location.text = [[NSString alloc]initWithFormat:@"活动地点: %@",[a valueForKey:@"location"] ];
        int participator_count = [[a valueForKey:@"member_count"] intValue];
        cell.member_count.text = [[NSString alloc] initWithFormat:@"已有 %d 人参加",participator_count];
        cell.launcherinfo.text = [[NSString alloc]initWithFormat:@"发起人: %@",[a valueForKey:@"launcher"] ];
        cell.eventId = [a valueForKey:@"event_id"];
        cell.avatar.layer.masksToBounds = YES;
        [cell.avatar.layer setBorderColor:[UIColor yellowColor].CGColor];
        [cell.avatar.layer setBorderWidth:2.0f];
        [cell.avatar.layer setCornerRadius:15];

        PhotoGetter *getter = [[PhotoGetter alloc]initWithData:cell.avatar authorId:[a valueForKey:@"launcher_id"]];
        [self performSelectorInBackground:@selector(BGgetPhoto:) withObject:getter];
        //[getter getPhoto];

        //cell.themePhoto.image = nil;
        PhotoGetter *bannerGetter = [[PhotoGetter alloc]initWithData:cell.themePhoto authorId:[a valueForKey:@"event_id"]];
        [self performSelectorInBackground:@selector(BGgetBanner:) withObject:bannerGetter];
        //[bannerGetter getBanner];
        cell.homeController = self.homeController;
        
        NSArray *memberids = [a valueForKey:@"member"];

        for (int i =3; i>=0; i--) {
            UIImageView *tmp = ((UIImageView*)[((UIView*)[cell viewWithTag:103]) viewWithTag:i+1]);
            if (i < participator_count) {
                PhotoGetter *getter = [[PhotoGetter alloc]initWithData:tmp authorId:memberids[i]];
                [self performSelectorInBackground:@selector(BGgetPhoto:) withObject:getter];
                //[getter getPhoto];
            }else tmp.image = nil;
            
        }
    }
    
	return cell;
}

-(void)BGgetBanner:(id)sender
{
    PhotoGetter* getter = sender;
    [getter getBanner];
}
-(void)BGgetPhoto:(id)sender
{
    PhotoGetter* getter = sender;
    [getter getPhoto];
}

@end
