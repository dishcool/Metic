//
//  PhotoBrowserViewController.m
//  WeShare
//
//  Created by 俊健 on 16/2/21.
//  Copyright © 2016年 WeShare. All rights reserved.
//

#import "PhotoBrowserViewController.h"
#import "PhotoDetailViewController.h"
#import "PictureWall2.h"
#import "PhotoBrowserCell.h"
#import "CommonUtils.h"
#import "SwipeView.h"

@interface PhotoBrowserViewController () <SwipeViewDataSource, SwipeViewDelegate>

@property (nonatomic, strong) IBOutlet SwipeView *swipeView;
@property (nonatomic, strong) PhotoDetailViewController *selectedPhotoDetailVC;

@property (nonatomic, strong) NSArray *photos;
@property (nonatomic, strong) NSDictionary *eventInfo;
@property (nonatomic) NSInteger showIndex;

@end

@implementation PhotoBrowserViewController

- (instancetype)initWithEventInfo:(NSDictionary *)eventInfo PhotoDists:(NSArray *)photos showPhotoIndex:(NSInteger)index {
    self = [self init];
    if (self) {
        self.photos = photos;
        self.eventInfo = eventInfo;
        self.showIndex = index;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    if (self.showIndex >= 0 && self.showIndex < self.photos.count) {
        [self.swipeView scrollToItemAtIndex:self.showIndex duration:0];
    }
    [self swipeViewDidEndDecelerating:self.swipeView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    self.swipeView.delegate = nil;
    self.swipeView.dataSource = nil;
}

#pragma mark - UI setup
- (void)setupUI {
    self.title = @"图片详情";
    [CommonUtils addLeftButton:self isFirstPage:NO];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.swipeView.dataSource = self;
    self.swipeView.delegate = self;
    self.swipeView.pagingEnabled = YES;
    [self.swipeView reloadData];
}

- (void)setTableViewScrollEnabled:(BOOL)scrollEnabled {
    self.swipeView.scrollEnabled = scrollEnabled;
}

- (PhotoDetailViewController *)photoDetailVCwithIndex:(NSInteger)index {
    
    if (index < 0 || index >= self.photos.count) {
        return nil;
    }
    
    if (self.showIndex > 0 && self.selectedPhotoDetailVC) {
        return self.selectedPhotoDetailVC;
    } else if (self.showIndex > 0 && !self.selectedPhotoDetailVC) {
        index = self.showIndex;
    }
    
    NSMutableDictionary *photoInfo = self.photos[index];
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle: nil];
    PhotoDetailViewController *detailViewController = [mainStoryboard instantiateViewControllerWithIdentifier: @"PhotoDetailViewController"];
    
    detailViewController.photoId = photoInfo[@"photo_id"];
    detailViewController.eventId = self.eventInfo[@"event_id"];
    detailViewController.eventLauncherId = self.eventInfo[@"launcher_id"];
    detailViewController.photoInfo = photoInfo;
    detailViewController.eventName = self.eventInfo[@"subject"];
    detailViewController.canManage = [[self.eventInfo valueForKey:@"isIn"]boolValue];
    
    if (self.showIndex > 0 && !self.selectedPhotoDetailVC) {
        self.selectedPhotoDetailVC = detailViewController;
    }
    return detailViewController;
}

#pragma mark iCarousel methods

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView
{
    return self.photos.count;
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    PhotoDetailViewController *detailViewController = [self photoDetailVCwithIndex:index];
    if (self.showIndex == index) {
        self.showIndex = -1;
        self.selectedPhotoDetailVC = nil;
    }
    [self addChildViewController:detailViewController];
    CGRect frame = self.swipeView.bounds;
    detailViewController.view.frame = frame;
    [detailViewController didMoveToParentViewController:self];
    
    return detailViewController.view;
}

#pragma mark SwipeView Delegate
- (void)swipeViewWillBeginDragging:(SwipeView *)swipeView {
    
    for (PhotoDetailViewController *detailVC in self.childViewControllers) {
        if (detailVC && [detailVC respondsToSelector:@selector(inputTextView)]) {
            if (detailVC.inputTextView.isFirstResponder) {
                [detailVC.inputTextView resignFirstResponder];
            }
        }
    }
}

- (void)swipeViewDidEndDecelerating:(SwipeView *)swipeView {
    
    PhotoDetailViewController *visibleVC;
    for (PhotoDetailViewController *detailVC in self.childViewControllers) {
        if (![swipeView.visibleItemViews containsObject:detailVC.view]) {
            [detailVC.view removeFromSuperview];
            [detailVC removeFromParentViewController];
        } else {
            visibleVC = detailVC;
        }
    }
    if (visibleVC) {
        [visibleVC tabbarButtonOption];
    }
}

@end
