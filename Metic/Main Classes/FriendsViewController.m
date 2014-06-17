//
//  FriendsViewController.m
//  SlideMenu
//
//  Created by Aryan Ghassemi on 12/31/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//

#import "FriendsViewController.h"


//#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
//if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
//{
//    self.edgesForExtendedLayout = UIRectEdgeNone;
//    self.extendedLayoutIncludesOpaqueBars = NO;
//    self.modalPresentationCapturesStatusBarAppearance = NO;
//}
//#endif
@implementation FriendsViewController
{
    NSString* DB_path;
}
@synthesize user;
@synthesize friendList;
@synthesize sortedFriendDic;
@synthesize searchFriendList;
@synthesize DB;

- (void)viewDidLoad
{
    [super viewDidLoad];
    //下面的if语句是为了解决iOS7上navigationbar可以和别的view重叠的问题
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0))
    {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    
    self.user = [MTUser sharedInstance];
    DB_path = [NSString stringWithFormat:@"%@/db",user.userid];
    self.DB = [[MySqlite alloc]init];
    self.friendTableView.delegate = self;
    self.friendTableView.dataSource = self;
    self.friendSearchBar.delegate = self;
    
    [self createFriendTable];
    [self synchronize_friends];
    NSLog(@"did reload friends");
    [self.friendTableView reloadData];
}

- (void)synchronize_friends
{
    NSNumber* userId = self.user.userid;
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    NSMutableArray* tempFriends = [self getFriendsFromDB];
    [dictionary setValue:userId forKey:@"id"];
    [dictionary setValue:[NSNumber numberWithInt:tempFriends.count] forKey:@"friends_number"];
    NSLog(@"%@",dictionary);
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
    [httpSender sendMessage:jsonData withOperationCode:SYNCHRONIZE_FRIEND];

}

- (IBAction)search_friends:(id)sender
{
//    NSString* text = self.friendSearchBar.text;
//    if ([CommonUtils isEmailValid:text]) {
//        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
//        dictionary = [CommonUtils packParamsInDictionary:text,@"email",nil];
//        NSLog(@"%@",dictionary);
//        
//        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
//        HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
//        [httpSender sendMessage:jsonData withOperationCode:SEARCH_FRIEND];
//    }
//    else
//    {
//        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
//        dictionary = [CommonUtils packParamsInDictionary:text,@"name",nil];
//        NSLog(@"%@",dictionary);
//        
//        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
//        HttpSender *httpSender = [[HttpSender alloc]initWithDelegate:self];
//        [httpSender sendMessage:jsonData withOperationCode:SEARCH_FRIEND];;
//    }
}

-(void) createFriendTable
{
    [self.DB openMyDB:DB_path];
    [self.DB createTableWithTableName:@"friend" andIndexWithProperties:@"id INTEGER PRIMARY KEY UNIQUE",@"name",@"email",@"gender",nil];
    [self.DB closeMyDB];
}

- (void) insertToFriendTable:(NSArray *)friends
{
//    NSString* path = [NSString stringWithFormat:@"%@/db",user.userid];
    [self.DB openMyDB:DB_path];
    for (NSDictionary* friend in friends) {
        NSString* friendEmail = [friend objectForKey:@"email"];
        NSNumber* friendID = [friend objectForKey:@"id"];
        NSNumber* friendGender = [friend objectForKey:@"gender"];
        NSString* friendName = [friend objectForKey:@"name"];
        
        NSLog(@"email: %@, id: %@, gender: %@, name: %@",friendEmail,friendID,friendGender,friendName);
        
        NSArray* columns = [[NSArray alloc]initWithObjects:@"'id'",@"'name'",@"'email'",@"'gender'", nil];
        NSArray* values = [[NSArray alloc]initWithObjects:
                           [NSString stringWithFormat:@"%@",[CommonUtils NSStringWithNSNumber:friendID]],
                           [NSString stringWithFormat:@"'%@'",friendName],
                           [NSString stringWithFormat:@"'%@'",friendEmail],
                           [NSString stringWithFormat:@"%@",[CommonUtils NSStringWithNSNumber:friendGender]], nil];
        [self.DB insertToTable:@"friend" withColumns:columns andValues:values];
    }
    [self.DB closeMyDB];

}

- (NSMutableArray*)getFriendsFromDB
{
    NSMutableArray* friends;
    [self.DB openMyDB:DB_path];
    friends = [self.DB queryTable:@"friend" withSelect:[[NSArray alloc]initWithObjects:@"*", nil] andWhere:nil];
    [self.DB closeMyDB];
    return friends;
}

- (NSMutableDictionary*)sortFriendList
{
    NSMutableDictionary* sorted = [[NSMutableDictionary alloc]init];
    for (NSMutableDictionary* aFriend in friendList) {
        NSString* fname_py = [CommonUtils pinyinFromNSString:[aFriend objectForKey:@"name"]];
        NSString* first_letter = [fname_py substringWithRange:NSMakeRange(0, 1)];
        NSMutableArray* groupOfFriends = [sortedFriendDic objectForKey:first_letter];
        if (groupOfFriends) {
            [groupOfFriends addObject:aFriend];
        }
        else
        {
            groupOfFriends = [[NSMutableArray alloc]init];
            [groupOfFriends addObject:aFriend];
        }
    }
    for (NSMutableArray* arr in sorted) {
        [self rankFriendsInArray:arr];
    }
    return sorted;
}

- (void)rankFriendsInArray:(NSMutableArray*)friends
{
    NSComparator cmptor = ^(id obj1, id obj2)
    {
        NSString* obj1_py = [CommonUtils pinyinFromNSString:(NSString*)[obj1 objectForKey:@"name"]];
        NSString* obj2_py = [CommonUtils pinyinFromNSString:(NSString*)[obj2 objectForKey:@"name"]];
        int result = [obj1_py compare:obj2_py];
        return result;
    };
    [friends sortUsingComparator:cmptor];
}

- (IBAction)switchToAddFriendView:(id)sender
{
    
}

#pragma mark - UITableViewDelegate


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = 0;
    
    return height;
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.friendList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FriendTableViewCell* cell = [self.friendTableView dequeueReusableCellWithIdentifier:@"friendcell"];
    if (nil == cell) {
        cell = [[FriendTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"friendcell"];
    }
    NSDictionary* aFriend = [self.friendList objectAtIndex:indexPath.row];
//    NSLog(@"a friend: %@",aFriend);
    NSString* name = [aFriend objectForKey:@"name"];
    cell.avatar.image = [UIImage imageNamed:@"default_avatar.jpg"];
    if (name) {
        cell.title.text = name;
    }
    else
    {
        cell.title.text = @"default";
    }
    
//    cell.image = [[UIImage alloc]init];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 26;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    
//}
//
//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
//{
//    
//}
//
//- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
//{
//    
//}

#pragma mark - UISearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar                     // return NO to not become first responder
{
    return YES;
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar                     // called when text starts editing
{
    
}
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar                        // return NO to not resign first responder
{
    return YES;
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar                       // called when text ends editing
{
    
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText   // called when text changes (including clear)
{
    
}

//- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar                    // called when cancel button pressed
//{
//    [searchBar resignFirstResponder];
//}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar                     // called when keyboard search button pressed
{
//    [self search_friends];
    [searchBar resignFirstResponder];
//    [self.friendTableView reloadData];
}


#pragma mark - HttpSenderDelegate
- (void)finishWithReceivedData:(NSData *)rData
{
    NSString* temp = [[NSString alloc]initWithData:rData encoding:NSUTF8StringEncoding];
    NSLog(@"Received Data: %@",temp);
    NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:rData options:NSJSONReadingMutableLeaves error:nil];
    NSNumber* cmd = [response1 objectForKey:@"cmd"];
    NSLog(@"cmd: %@",cmd);
    if (cmd) {
        if ([cmd intValue] == NORMAL_REPLY) {
            NSMutableArray* tempFriends = [response1 valueForKey:@"friend_list"];
            if (tempFriends.count) {
                [self insertToFriendTable:tempFriends];
                NSLog(@"好友列表更新完成！");
            }
            else
            {
                NSLog(@"好友列表已经是最新的啦～");
            }
            self.friendList = [self getFriendsFromDB];
            
            NSLog(@"synchronize friends: %@",friendList);
            
        }
        else
        {
            NSLog(@"synchronize friends failed");
        }
    }
    else
    {
        NSLog(@"server error");
    }
    
    [self.friendTableView reloadData];
}

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
	return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
	return NO;
}

@end
