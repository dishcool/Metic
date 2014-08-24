//
//  MCommentTableViewCell.m
//  Metic
//
//  Created by ligang6 on 14-6-15.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "MCommentTableViewCell.h"
#import "FriendInfoViewController.h"
#import "ReportViewController.h"

@interface MCommentTableViewCell ()

@end

@implementation MCommentTableViewCell

- (void)awakeFromNib
{
    // Initialization code
    //长按手势
    UILongPressGestureRecognizer * longRecognizer = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(showOption:)];
    [self addGestureRecognizer:longRecognizer];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)delete_Comment:(id)sender {
    [_controller delete_Comment:sender];
}


- (IBAction)appreciate:(id)sender {
    [_controller appreciate:sender];
}

- (IBAction)pushToFriendView:(id)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone"
															 bundle: nil];
	FriendInfoViewController *friendView = [mainStoryboard instantiateViewControllerWithIdentifier: @"FriendInfoViewController"];
    friendView.fid = self.authorId;
    [_controller.navigationController pushViewController:friendView animated:YES];
}

-(void)showOption:(UIGestureRecognizer*)sender
{
    if ([_commentid intValue]<0) {
        return;
    }
    if (sender.state == UIGestureRecognizerStateBegan) {
        NSLog(@"showOption");
        if (!_controller.optionShadowView) {
            CGRect frame = _controller.view.frame;
            frame.origin = CGPointMake(0, 0);
            _controller.optionShadowView = [[UIView alloc]initWithFrame:frame];
            [_controller.optionShadowView setBackgroundColor:[UIColor blackColor]];
            [_controller.optionShadowView setAlpha:0.4];
            //单击手势
            UITapGestureRecognizer * singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissOption)];
            [_controller.optionShadowView addGestureRecognizer:singleRecognizer];
            
            UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
            _controller.commentOptionView = button;
            frame.origin = CGPointMake(40, (frame.size.height - 40)/2);
            frame.size = CGSizeMake(frame.size.width-80, 40);
            [button setFrame:frame];
            [button setTitle:@"匿名举报" forState:UIControlStateNormal];
            [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
            [button addTarget:self action:@selector(report) forControlEvents:UIControlEventTouchUpInside];
            [button setUserInteractionEnabled:YES];
            [_controller.view addSubview:_controller.optionShadowView];
            [_controller.view addSubview:_controller.commentOptionView];
            [button setBackgroundColor:[UIColor whiteColor]];
            [button.layer setBorderColor:[UIColor darkGrayColor].CGColor];
            [button.layer setBorderWidth:2];
            button.layer.masksToBounds = YES;
            [button.layer setCornerRadius:5];
            [button setAlpha:1.0];
        }
        
    }
}

-(void)dismissOption
{
    NSLog(@"dismissOption");
    if (_controller.optionShadowView) {
        [_controller.optionShadowView removeFromSuperview];
        _controller.optionShadowView = nil;
    }
    if (_controller.commentOptionView) {
        [_controller.commentOptionView removeFromSuperview];
        _controller.commentOptionView = nil;

    }
}

-(void)report{
    NSLog(@"匿名投诉");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (_controller.optionShadowView) {
            [self dismissOption];
            
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone"
                                                                     bundle: nil];
            ReportViewController *viewcontroller = [mainStoryboard instantiateViewControllerWithIdentifier: @"ReportViewController"]; ;
            viewcontroller.eventId = _controller.eventId;
            viewcontroller.commentId = _commentid;
            viewcontroller.comment = _origincomment;
            viewcontroller.commentAuthor = self.author;
            viewcontroller.authorId = self.authorId;
            viewcontroller.event = [self.controller.event valueForKey:@"subject"];;
            
            viewcontroller.type = 3;
            [self.controller.navigationController pushViewController:viewcontroller animated:YES];
        }
        
    });
}

@end
