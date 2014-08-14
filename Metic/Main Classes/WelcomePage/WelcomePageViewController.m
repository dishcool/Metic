//
//  WelcomePageViewController.m
//  Metic
//
//  Created by mac on 14-8-12.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "WelcomePageViewController.h"

@interface WelcomePageViewController ()
{
    NSInteger numberOfPages;
    UITapGestureRecognizer* tapRecognizer;
}

@end

@implementation WelcomePageViewController
@synthesize rootView;
@synthesize page_scrollview;
@synthesize pageControl;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    numberOfPages = 4;
    
    self.page_scrollview = [[UIScrollView alloc]init];
    self.page_scrollview.frame = self.view.frame;
    self.page_scrollview.scrollEnabled = YES;
    self.page_scrollview.pagingEnabled = YES;
    self.page_scrollview.showsHorizontalScrollIndicator = NO;
    self.page_scrollview.showsVerticalScrollIndicator = NO;
    self.page_scrollview.delegate = self;
    
    CGRect bounds = [UIScreen mainScreen].bounds;
    CGFloat view_width = bounds.size.width;
    CGFloat view_height = bounds.size.height;
    UIColor* bgColor = [CommonUtils colorWithValue:0x57caab];
    
    UIView* page1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, view_width, view_height)];
    UIImageView* imgV1_1 = [[UIImageView alloc]initWithFrame:CGRectMake(21, 70, view_width - 42, 115)];
    UIImageView* imgV1_2 = [[UIImageView alloc]initWithFrame:CGRectMake(-60, view_height - 385, view_width + 120, 385)];
    [page1 setBackgroundColor:bgColor];
    imgV1_1.image = [UIImage imageNamed:@"出图-文字1"];
    imgV1_2.image = [UIImage imageNamed:@"出图-主视觉1"];
    page1.clipsToBounds = YES;
    [page1 addSubview:imgV1_1];
    [page1 addSubview:imgV1_2];
    
    UIView* page2 = [[UIView alloc]initWithFrame:CGRectMake(view_width, 0, view_width, view_height)];
    UIImageView* imgV2_1 = [[UIImageView alloc]initWithFrame:CGRectMake(21, 70, view_width - 42, 115)];
    UIImageView* imgV2_2 = [[UIImageView alloc]initWithFrame:CGRectMake(-60, view_height - 385, view_width + 120, 385)];
    [page2 setBackgroundColor:bgColor];
    imgV2_1.image = [UIImage imageNamed:@"出图-文字2"];
    imgV2_2.image = [UIImage imageNamed:@"出图-主视觉2"];
    page2.clipsToBounds = YES;
    [page2 addSubview:imgV2_1];
    [page2 addSubview:imgV2_2];
    
    UIView* page3 = [[UIView alloc]initWithFrame:CGRectMake(view_width * 2, 0, view_width, view_height)];
    UIImageView* imgV3_1 = [[UIImageView alloc]initWithFrame:CGRectMake(21, 70, view_width - 42, 115)];
    UIImageView* imgV3_2 = [[UIImageView alloc]initWithFrame:CGRectMake(-60, view_height - 385, view_width + 120, 385)];
    [page3 setBackgroundColor:bgColor];
    imgV3_1.image = [UIImage imageNamed:@"出图-文字3"];
    imgV3_2.image = [UIImage imageNamed:@"出图-主视觉3"];
    page3.clipsToBounds = YES;
    [page3 addSubview:imgV3_1];
    [page3 addSubview:imgV3_2];
    
    UIView* page4 = [[UIView alloc]initWithFrame:CGRectMake(view_width * 3, 0, view_width, view_height)];
    UIImageView* imgV4_1 = [[UIImageView alloc]initWithFrame:CGRectMake(21, 70, view_width - 42, 115)];
    UIImageView* imgV4_2 = [[UIImageView alloc]initWithFrame:CGRectMake(-60, view_height - 385, view_width + 120, 385)];
    [page4 setBackgroundColor:bgColor];
    imgV4_1.image = [UIImage imageNamed:@"出图-文字4"];
    imgV4_2.image = [UIImage imageNamed:@"出图-主视觉4"];
    page4.clipsToBounds = YES;
    [page4 addSubview:imgV4_1];
    [page4 addSubview:imgV4_2];
    
    
    [page_scrollview addSubview:page1];
    [page_scrollview addSubview:page2];
    [page_scrollview addSubview:page3];
    [page_scrollview addSubview:page4];
    [rootView addSubview:page_scrollview];
    
    
    
    pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, self.rootView.frame.size.height - 80, self.rootView.frame.size.width, 50)];
    pageControl.numberOfPages = numberOfPages;
    pageControl.currentPage = 0;
    UIColor* indicatorTintColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
    pageControl.pageIndicatorTintColor = indicatorTintColor;
    [pageControl addTarget:self action:@selector(pageControlClicked:) forControlEvents:UIControlEventValueChanged];
    [self.rootView addSubview:pageControl];
    
    tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissWelcome)];
    [page4 addGestureRecognizer:tapRecognizer];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.page_scrollview.contentSize = CGSizeMake(320 * 4, 480);
    NSLog(@"view did appear");
    NSLog(@"content size: width: %f, height: %f",self.page_scrollview.contentSize.width, self.page_scrollview.contentSize.height);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dismissWelcome
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)pageControlClicked:(id)sender
{
    NSInteger page = pageControl.currentPage;
    
    CGRect kFrame = self.page_scrollview.frame;
    kFrame.origin.x = kFrame.size.width * page;
    kFrame.origin.y = 0;
//    [self.page_scrollview scrollRectToVisible:kFrame animated:YES];
    [self.page_scrollview setContentOffset:kFrame.origin animated:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    NSLog(@"touched begin");
//}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    NSLog(@"begin dragging");
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView               // any offset changes
{
    if (scrollView == self.page_scrollview) {
        if (pageControl.currentPage == numberOfPages - 1) {
            if (page_scrollview.contentOffset.x > page_scrollview.frame.size.width * (numberOfPages - 1)) {
                [self dismissWelcome];
            }
        }
        CGFloat page_width = page_scrollview.frame.size.width;
        int page_index = floor((page_scrollview.contentOffset.x - page_width/2) / page_width) +1;
        pageControl.currentPage = page_index;
        
    }
}

@end