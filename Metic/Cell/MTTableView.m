//
//  MTTableView.m
//  Metic
//
//  Created by ligang_mac4 on 14-6-26.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "MTTableView.h"
#import "../Cell/CustomCellTableViewCell.h"
#import "../Utils/PhotoGetter.h"
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
        cell.beginTime.text = [a valueForKey:@"time"];
        cell.endTime.text = [a valueForKey:@"endTime"];
        cell.location.text = [[NSString alloc]initWithFormat:@"活动地点: %@",[a valueForKey:@"location"] ];
        int participator_count = [[a valueForKey:@"member_count"] intValue];
        cell.member_count.text = [[NSString alloc] initWithFormat:@"已有 %d 人参加",participator_count];
        cell.launcherinfo.text = [[NSString alloc]initWithFormat:@"发起人: %@",[a valueForKey:@"launcher"] ];
        //cell.eventDetail.text = [[NSString alloc]initWithFormat:@"%@ %@",[a valueForKey:@"remark"],@"\n \n \n \n \n \n \n \n \n \n" ];
        cell.eventId = [a valueForKey:@"event_id"];
        
        cell.avatar.image = nil;
        PhotoGetter *getter = [[PhotoGetter alloc]initWithData:cell.avatar path:[NSString stringWithFormat:@"/avatar/%@.jpg",[a valueForKey:@"launcher_id"]] type:1 cache:nil isCircle:YES borderColor:[UIColor orangeColor] borderWidth:10];
        [getter getPhoto];
        cell.themePhoto.image = [UIImage imageNamed:@"event.png"];
        cell.homeController = self.homeController;
        
        NSArray *memberids = [a valueForKey:@"member"];
        for (int i =3; i>=0; i--) {
            UIImageView *tmp = ((UIImageView*)[((UIView*)[cell viewWithTag:103]) viewWithTag:i+1]);
            tmp.image = nil;
            if (i < participator_count) {
                PhotoGetter *getter = [[PhotoGetter alloc]initWithData:tmp path:[NSString stringWithFormat:@"/avatar/%@.jpg",memberids[i]] type:1 cache:nil isCircle:NO borderColor:nil borderWidth:0];
                [getter getPhoto];
            }
            
        }
    }
    
	return cell;
}


@end