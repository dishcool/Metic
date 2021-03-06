//
//  UploadManageViewCell.m
//  WeShare
//
//  Created by 俊健 on 15/4/10.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import "UploadManageViewCell.h"
#import "UploadManageViewController.h"
#import "UIImageView+MTWebCache.h"
#import "UIImageView+WebCache.h"
#import "uploaderOperation.h"
#import "UploaderManager.h"
#import "CommonUtils.h"
//#import "MTprogressView.h"
#import "SDLoopProgressView.h"
#import "LCAlertView.h"
#import "MegUtils.h"

typedef enum {
    UPLOAD_UNKNOWN = -1,        ///<状态未知
    UPLOAD_WAITING = 0,        ///<上传等待
    UPLOAD_EXECUTING = 1,        ///<上传中
    UPLOAD_FINISH = 2,			///<上传完成
    UPLOAD_FAIL = 3,		///<上传失败
}uploadState;

@interface UploadManageViewCell ()
@property (strong, nonatomic) UIImageView *imgView;
@property (strong, nonatomic) NSNumber *photo_id;
@property (strong, nonatomic) NSString *photoName;
@property (nonatomic,weak) uploaderOperation *uploadTask;
@property (nonatomic,strong) UIView* progressView;
@property (nonatomic,strong) NSTimer* timer;
@property uploadState uploadState;
@property float progress;
@property (nonatomic,strong) UILongPressGestureRecognizer* longpressGR;
@end


@implementation UploadManageViewCell

- (void)applyData:(NSMutableDictionary *)photoInfo
{
    if (!_longpressGR) {
        _longpressGR = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longpressAction:)];
        [self addGestureRecognizer:_longpressGR];
    }
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    self.hidden = NO;
    self.alpha = 1.0f;
    _photoInfo = photoInfo;
    _photoName = [photoInfo valueForKey:@"imgName"];
    NSString* url = [photoInfo valueForKey:@"url"];
    if (!_imgView) {
        _imgView = [[UIImageView alloc]initWithFrame:self.bounds];
        [self addSubview:_imgView];
    }
    [_imgView setClipsToBounds:YES];
    [_imgView setContentMode:UIViewContentModeScaleAspectFit];
    [_imgView setBackgroundColor:[UIColor colorWithWhite:204.0/255 alpha:1.0f]];
    [_imgView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"活动图片的默认图片"] cloudPath:@"" completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image) {
            [_imgView setContentMode:UIViewContentModeScaleAspectFill];
        }else{
            _imgView.image = [UIImage imageNamed:@"加载失败"];
        }
    }];
    NSNumber* finishedB = [_photoInfo valueForKey:@"finished"];
    NSNumber* failedB = [_photoInfo valueForKey:@"failed"];
    if (finishedB && [finishedB boolValue]) {
        _uploadState = UPLOAD_FINISH;
        [_progressView setHidden:YES];
    }else if(failedB && [failedB boolValue]){
        _uploadState = UPLOAD_FAIL;
        [self refreshUI];
    }else{
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(checkState) userInfo:nil repeats:YES];
        [_timer fire];
    }
}

-(void)checkState
{
    if (!self.uploadManagerView) {
        if (_timer) {
            [_timer invalidate];
            _timer = nil;
        }
    }
    self.uploadState = UPLOAD_UNKNOWN;
    _uploadTask = [[UploaderManager sharedManager].taskswithPhotoName valueForKey:_photoName];
    NSMutableDictionary* realPhotoInfo;
    BOOL isFinished = false;
    BOOL wait = false;
    BOOL isExecuting = false;
    _progress = 0;
    if (_uploadTask) {
        realPhotoInfo = _uploadTask.photoInfo;
        isFinished = _uploadTask.isFinished;
        isExecuting = _uploadTask.executing;
        wait = _uploadTask.wait;
        _progress = _uploadTask.progress;
    }
    if (!_uploadTask || (!realPhotoInfo && (isFinished || !wait))) {
        //上传失败
        self.uploadState = UPLOAD_FAIL;
        [_photoInfo setValue:[NSNumber numberWithBool:YES] forKey:@"failed"];
    }else if(realPhotoInfo){
        //上传完成
        self.uploadState = UPLOAD_FINISH;
        [_photoInfo setValue:[NSNumber numberWithBool:YES] forKey:@"finished"];
    }else if(isExecuting){
        //正在上传
        self.uploadState = UPLOAD_EXECUTING;
    }else{
        //正在等待上传
        self.uploadState = UPLOAD_WAITING;
    }
    [self refreshUI];
    if (self.uploadState == UPLOAD_FINISH || self.uploadState == UPLOAD_FAIL ) {
        if (_timer) {
            [_timer invalidate];
            _timer = nil;
        }
    }
}

-(void)refreshUI
{
    if (!_progressView) {
        _progressView = [[UIView alloc]initWithFrame:self.bounds];
        _progressView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        [self addSubview:_progressView];
    }
    
    SDLoopProgressView* progreView = (SDLoopProgressView*)[_progressView viewWithTag:330];
    if (!progreView) {
        progreView = [SDLoopProgressView progressView];
        progreView.frame = CGRectMake(self.bounds.size.width/2 - 25, self.bounds.size.height/2 - 25, 50, 50);
        [progreView setTag:330];
        if(!progreView){
            NSLog(@"error");
        }
        [progreView setHidden:YES];
        progreView.progress = 0;
        [_progressView addSubview:progreView];
    }
    
    UIButton* cancel = (UIButton*)[_progressView viewWithTag:340];
    if (!cancel) {
        cancel = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancel setFrame:CGRectMake(self.bounds.size.width - 40, -10, 50, 50)];
        [cancel setImage:[UIImage imageNamed:@"上传任务删除"] forState:UIControlStateNormal];
        [cancel setTag:340];
        [cancel setHidden:YES];
        [cancel addTarget:self action:@selector(cancelUploadTask) forControlEvents:UIControlEventTouchUpInside];
        [_progressView addSubview:cancel];
    }
    
    UIButton* retry = (UIButton*)[_progressView viewWithTag:350];
    if (!retry) {
        retry = [UIButton buttonWithType:UIButtonTypeCustom];
        [retry setFrame:CGRectMake(self.bounds.size.width/2 - 25, self.bounds.size.height/2 - 40, 50, 70)];
        [retry setImage:[UIImage imageNamed:@"重新上传"] forState:UIControlStateNormal];
        [retry setTag:350];
        [retry setHidden:YES];
        [retry addTarget:self action:@selector(retryUploadTask) forControlEvents:UIControlEventTouchUpInside];
        [_progressView addSubview:retry];
        
        UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(0, 50, 50, 20)];
        [label setText:@"重新上传"];
        [label setFont:[UIFont systemFontOfSize:12]];
        [label setTextColor:[UIColor whiteColor]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [retry addSubview:label];
    }
    if (!progreView) {
        NSLog(@"error");
    }

    if(_uploadState == UPLOAD_WAITING){
        [progreView setHidden:YES];
        [cancel setHidden:YES];
        [retry setHidden:YES];
        _progressView.alpha = 1.0f;
        [_progressView setHidden:NO];
    }else if(_uploadState == UPLOAD_FAIL){
        [progreView setHidden:YES];
        [cancel setHidden:NO];
        [retry setHidden:NO];
        _progressView.alpha = 1.0f;
        [_progressView setHidden:NO];
    }else if(_uploadState == UPLOAD_EXECUTING){
        progreView.progress = _progress;
        [progreView setHidden:NO];
        [cancel setHidden:YES];
        [retry setHidden:YES];
        _progressView.alpha = 1.0f;
        [_progressView setHidden:NO];
    }else{
        progreView.progress = 1.0f;
        [UIView animateWithDuration:1 animations:^{
            _progressView.alpha = 0;
        } completion:^(BOOL finished) {
            [_progressView setHidden:YES];
            _progressView.alpha = 1.0f;
        }];
    }
}

-(void)cancelUploadTask
{
    MTLOG(@"取消上传任务");
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        self.hidden = YES;
        self.alpha = 1.0f;
        if (_uploadTask && [_photoInfo valueForKey:@"alasset"]) {
            [_uploadTask removeuploadTaskInDB];
        }
        [_uploadManagerView.uploadingPhotos removeObject:self.photoInfo];
        [_uploadManagerView.collelctionView reloadData];
    }];
}

-(void)retryUploadTask
{
    MTLOG(@"重试上传任务");
    [_photoInfo setValue:nil forKey:@"failed"];
    if ([_photoInfo valueForKey:@"alasset"]) {
        NSString* alassetStr = [_photoInfo valueForKey:@"alasset"];
        NSString* eventId = [_photoInfo valueForKey:@"event_id"];
        NSString* imgName = [_photoInfo valueForKey:@"imgName"];
        NSString* imageDescription = [_photoInfo valueForKey:@"imageDescription"];
        [[UploaderManager sharedManager] uploadImageStr:alassetStr eventId:[CommonUtils NSNumberWithNSString:eventId] imageName:imgName imageDescription:imageDescription];
    }
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(checkState) userInfo:nil repeats:YES];
    [_timer fire];
}

-(void)longpressAction:(UIGestureRecognizer*)sender
{
    if (sender.state != UIGestureRecognizerStateBegan) return;
    if (self.uploadState != UPLOAD_WAITING) return;
    LCAlertView *alert = [[LCAlertView alloc]initWithTitle:@"操作" message:nil delegate:self cancelButtonTitle:@"返回" otherButtonTitles:@"取消上传",nil];
    alert.alertAction = ^(NSInteger buttonIndex){
        if (buttonIndex == 1) {
            [self cancelUploading];
        }
    };
    [alert show];
}

- (void)cancelUploading
{
    MTLOG(@"cancelUploading");
    if (self.uploadState == UPLOAD_WAITING) {
        if(_uploadTask){
            [_uploadTask cancel];
        }
        [self cancelUploadTask];
    }
}

@end
