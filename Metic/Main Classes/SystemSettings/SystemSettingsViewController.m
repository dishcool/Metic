//
//  SystemSettingsViewController.m
//  Metic
//
//  Created by mac on 14-7-27.
//  Copyright (c) 2014年 dishcool. All rights reserved.
//

#import "SystemSettingsViewController.h"

@interface SystemSettingsViewController ()

@end

@implementation SystemSettingsViewController
{
    NSInteger numOfSections;
}
@synthesize settings_tableview;

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
    settings_tableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    settings_tableview.delegate = self;
    settings_tableview.dataSource = self;
    numOfSections = 4;
    [self.view addSubview:settings_tableview];
    
//    UIView* view = [[UIView alloc]initWithFrame:CGRectMake(40, 0, 300, 44)];
//    [view setBackgroundColor:[UIColor yellowColor]];
//    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
//    //        UIButton* button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 100, 40)];
//    button.frame = CGRectMake(0, 0, 300, 44);
//    //        button.center = view.center;
//    button.titleLabel.text = @"退出";
//    [button setBackgroundImage:[UIImage imageNamed:@"登陆界面按钮"] forState:UIControlStateNormal];
//    [button setBackgroundImage:[UIImage imageNamed:@"登陆界面按钮按下效果"] forState:UIControlStateSelected];
////    [view addSubview:button];
////    [settings_tableview.tableHeaderView addSubview:view];
//    settings_tableview.tableHeaderView = view;

    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return numOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
        {
            return 1;
        }
            break;
        case 1:
        {
            return 1;
        }
            break;
        case 2:
        {
            return 3;
        }
            break;
        case 3:
        {
            return 1;
        }
            break;
            
        default:
            return 0;
            break;
    }
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"setting"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"setting"];
    }
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 0) {
        cell.textLabel.text = @"通知栏提醒";
        UISwitch* nSwitch = [[UISwitch alloc]initWithFrame:CGRectMake(222, 8, 30, 30)];
        [cell addSubview:nSwitch];
    }
    else if(section == 1)
    {
        cell.textLabel.text = @"清空缓存";
    }
    else if(section == 2)
    {
        if (row == 0) {
            cell.textLabel.text = @"版本更新提醒";
            UISwitch* nSwitch = [[UISwitch alloc]initWithFrame:CGRectMake(222, 8, 30, 30)];
            [cell addSubview:nSwitch];
        }
        else if (row == 1)
        {
            cell.textLabel.text = @"检测更新";
        }
        else if (row == 2)
        {
            cell.textLabel.text = @"关于活动宝";
        }
    }
    else if (section == 3)
    {
//        UIView* view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
//        [view setBackgroundColor:[UIColor clearColor]];
//         UIButton* button = [[UIButton alloc]initWithFrame:CGRectMake(10, 0, 100, 40)];
////        UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
////        button.frame = CGRectMake(10, 0, 100, 40);
////        button.center = view.center;
//        button.titleLabel.text = @"退出";
//        [button setBackgroundColor:[UIColor yellowColor]];
//        
////        [button setBackgroundImage:[UIImage imageNamed:@"登陆界面按钮"] forState:UIControlStateNormal];
////        [button setBackgroundImage:[UIImage imageNamed:@"登陆界面按钮按下效果"] forState:UIControlStateSelected];
//        
//        [cell addSubview:button];
        UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 50, 30)];
        [label setBackgroundColor:[UIColor clearColor]];
        label.textAlignment = NSTextAlignmentLeft;
        label.text = @"退出";
        [cell setBackgroundColor:[UIColor redColor]];
        label.center = cell.center;
        [cell.contentView addSubview:label];
//        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
//        [cell setHighlighted:YES animated:YES];
    }
    
    return cell;
}

#pragma  mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
//    if (numOfSections == section +1) {
//        return 50;
//    }
    return 0;
}

//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
//{
//    if (section == numOfSections - 1) {
//        UIView* view = [[UIView alloc]initWithFrame:CGRectMake(10, 0, 300, 44)];
//        [view setBackgroundColor:[UIColor yellowColor]];
//        UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
////        UIButton* button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 100, 40)];
//        button.frame = CGRectMake(0, 0, 300, 44);
////        button.center = view.center;
//        button.titleLabel.text = @"退出";
//        [button setBackgroundImage:[UIImage imageNamed:@"登陆界面按钮"] forState:UIControlStateNormal];
//        [button setBackgroundImage:[UIImage imageNamed:@"登陆界面按钮按下效果"] forState:UIControlStateSelected];
//        [view addSubview:button];
//        return view;
//    }
//    return nil;
//}

@end