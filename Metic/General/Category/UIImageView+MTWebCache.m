//
//  UIImageView+MTImageCache.m
//  WeShare
//
//  Created by 俊健 on 15/8/15.
//  Copyright (c) 2015年 WeShare. All rights reserved.
//

#import "UIImageView+MTWebCache.h"

@implementation UIImageView (MTWebCache)

//下载后将图片的key替换成云端路径

- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder cloudPath:(NSString *)path options:(SDWebImageOptions)options completed:(SDWebImageCompletionBlock)completedBlock
{
    [self sd_setImageWithURL:url placeholderImage:placeholder cloudPath:path options:options progress:nil completed:completedBlock];
}

- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder cloudPath:(NSString *)path completed:(SDWebImageCompletionBlock)completedBlock
{
    [self sd_setImageWithURL:url placeholderImage:placeholder cloudPath:path options:SDWebImageRetryFailed progress:nil completed:completedBlock];
}

- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder cloudPath:(NSString *)path
{
    [self sd_setImageWithURL:url placeholderImage:placeholder cloudPath:path options:SDWebImageRetryFailed progress:nil completed:nil];
}

- (void)sd_setImageWithURL:(NSURL *)url cloudPath:(NSString *)path
{
    [self sd_setImageWithURL:url placeholderImage:nil cloudPath:path options:SDWebImageRetryFailed progress:nil completed:nil];
}

- (void)sd_setImageWithURL:(NSURL *)url cloudPath:(NSString *)path completed:(SDWebImageCompletionBlock)completedBlock
{
    [self sd_setImageWithURL:url placeholderImage:nil cloudPath:path options:SDWebImageRetryFailed progress:nil completed:completedBlock];
}

- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder cloudPath:(NSString *)path options:(SDWebImageOptions)options
{
    [self sd_setImageWithURL:url placeholderImage:placeholder cloudPath:path options:SDWebImageRetryFailed progress:nil completed:nil];
}

- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder cloudPath:(NSString *)path options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock
{
    [self sd_setImageWithURL:url placeholderImage:placeholder cloudPath:path options:SDWebImageRetryFailed progress:progressBlock completed:nil];
}



- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder  cloudPath:(NSString *)path options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletionBlock)completedBlock
{
    [self sd_setImageWithURL:url placeholderImage:placeholder options:options progress:progressBlock completed:completedBlock];
}


@end
