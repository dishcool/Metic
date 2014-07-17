//
//  PhotoGetter.m
//  Metic
//
//  Created by ligang_mac4 on 14-6-26.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "PhotoGetter.h"
#import "CommonUtils.h"
#import "UIImage+UIImageExtras.h"
#import "UIImageView+WebCache.h"

@interface PhotoGetter ()
@property(nonatomic,strong) UIImage* uploadImage;
@property(nonatomic,strong) NSString* imgName;
@property BOOL isUpload;

@end


@implementation PhotoGetter


- (instancetype)initWithData:(UIImageView*)animageView authorId:(NSNumber*)authorId //type:(int)type cache:(NSMutableDictionary*)cache
{
    if (self) {
        self = [super init];
        self.user = [MTUser sharedInstance];
        self.imageView = animageView;
        self.avatarId = authorId;
        self.path = [NSString stringWithFormat:@"/avatar/%@.jpg",authorId];
        self.isUpload = NO;
    }
    return self;
}

- (instancetype)initUploadMethod:(UIImage*)aImage type:(int)type
{
    if (self) {
        self = [super init];
        self.user = [MTUser sharedInstance];
        self.uploadImage = aImage;
        self.type = type;
    }
    return self;
}



-(void)getPhoto
{
    
    NSString *url = [self getLocalAvatarUrl];
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"默认用户头像"]];
}


-(void)getBanner
{
    NSString *url = [self getLocalBannerUrl];
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"event.png"]];
}



-(void)updatePhoto
{
    CloudOperation * cloudOP = [[CloudOperation alloc]initWithDelegate:self];
    [cloudOP CloudToDo:DOWNLOAD path:_path uploadPath:nil container:self.imageView authorId:nil];
}

-(void)uploadPhoto
{
    self.isUpload = YES;
    UIImage* compressedImage = self.uploadImage;
    NSData* imageData = UIImageJPEGRepresentation(compressedImage, 1.0);
    if (compressedImage.size.width> 640) {
        CGSize imagesize=CGSizeMake(640.0, compressedImage.size.height * 640.0/compressedImage.size.width);
        compressedImage = [compressedImage imageByScalingToSize:imagesize];
        imageData = UIImageJPEGRepresentation(compressedImage, 1.0);
    }
    float para = 1.0;
    int restOp = 5;
    while (imageData.length > 100000) {
        imageData = UIImageJPEGRepresentation(compressedImage, para*0.5);
        compressedImage = [UIImage imageWithData:imageData];
        if (!restOp--) {
            [CommonUtils showSimpleAlertViewWithTitle:@"消息" WithMessage:@"文件太大，不能处理" WithDelegate:nil WithCancelTitle:@"确定"];
            return;
        }
    }

    
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc ] init];
    [formatter setDateFormat:[NSString stringWithFormat:@"%@YYYYMMddHHmmssSSSSS",[MTUser sharedInstance].userid]];
    NSString *date =  [formatter stringFromDate:[NSDate date]];
    NSString *timeLocal = [[NSString alloc] initWithFormat:@"%@", date];
    
    self.path = [NSString stringWithFormat:@"/images/%@.png",timeLocal];
    self.imgName =[NSString stringWithFormat:@"%@.png",timeLocal];
    NSString *filePath = [NSString stringWithFormat:@"%@/Documents/media%@", NSHomeDirectory(),_path];
    [imageData writeToFile:filePath atomically:YES];

    CloudOperation * cloudOP = [[CloudOperation alloc]initWithDelegate:self];
    NSString* uploadfilePath = filePath;
    [cloudOP CloudToDo:UPLOAD path:self.path uploadPath:uploadfilePath container:nil authorId:nil];
    
}

-(void)uploadBanner:(NSNumber*)eventId
{
    self.isUpload = YES;
    UIImage* compressedImage = self.uploadImage;
    NSData* imageData = UIImageJPEGRepresentation(compressedImage, 1.0);
    if (compressedImage.size.width> 640) {
        CGSize imagesize=CGSizeMake(640.0, compressedImage.size.height * 640.0/compressedImage.size.width);
        compressedImage = [compressedImage imageByScalingToSize:imagesize];
        imageData = UIImageJPEGRepresentation(compressedImage, 1.0);
    }
    float para = 0.8;
    int restOp = 5;
    while (imageData.length > 50000) {
        imageData = UIImageJPEGRepresentation(compressedImage, para*0.5);
        compressedImage = [UIImage imageWithData:imageData];
        if (!restOp--) {
            [CommonUtils showSimpleAlertViewWithTitle:@"消息" WithMessage:@"文件太大，不能处理" WithDelegate:nil WithCancelTitle:@"确定"];
            return;
        }
    }
    
    
    
    self.path = [NSString stringWithFormat:@"/banner/%@.jpg",eventId];
    self.imgName =[NSString stringWithFormat:@"%@.jpg",eventId];
    NSString *filePath = [NSString stringWithFormat:@"%@/Documents/media%@", NSHomeDirectory(),_path];
    [imageData writeToFile:filePath atomically:YES];
    
    CloudOperation * cloudOP = [[CloudOperation alloc]initWithDelegate:self];
    NSString* uploadfilePath = filePath;
    [cloudOP CloudToDo:UPLOAD path:self.path uploadPath:uploadfilePath container:nil authorId:nil];
    
}



-(NSString*)getLocalAvatarUrl
{
    NSString* url = [[MTUser sharedInstance].avatarURL valueForKey:[NSString stringWithFormat:@"%@",self.avatarId]];
    if (!url) {
        url = [CommonUtils getUrl:[NSString stringWithFormat:@"/avatar/%@.jpg",self.avatarId]];
        [[MTUser sharedInstance].avatarURL setValue:url forKey:[NSString stringWithFormat:@"%@",self.avatarId]];
    }
    return url;
}

-(NSString*)getLocalBannerUrl
{
    NSString* url = [[MTUser sharedInstance].bannerURL valueForKey:[NSString stringWithFormat:@"%@",self.avatarId]];
    if (!url) {
        url = [CommonUtils getUrl:[NSString stringWithFormat:@"/banner/%@.jpg",self.avatarId]];
        [[MTUser sharedInstance].bannerURL setValue:url forKey:[NSString stringWithFormat:@"%@",self.avatarId]];
    }
    return url;
}


-(void)finishwithOperationStatus:(BOOL)status type:(int)type data:(NSData *)mdata path:(NSString *)path
{
    if (self.isUpload) {
        if (status){
            [self.mDelegate finishwithNotification:nil image:nil type:100 container:self.imgName];
        }else{
            [self.mDelegate finishwithNotification:nil image:nil type:106 container:self.imgName];
        }
        return;
    }
}
@end

