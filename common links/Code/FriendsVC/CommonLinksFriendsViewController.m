//
//  CommonLinksFriendsViewController.m
//  Common Links
//
//  Created by Jaydev Shah on 7/7/13.
//  Copyright (c) 2013 JC11Factory. All rights reserved.
//

#import "CommonLinksFriendsViewController.h"

#import <FacebookSDK/FacebookSDK.h>

#import "CommonLinksDataManager.h"
#import "CommonLinksFriendsViewCell.h"
#import "CommonLinksAppDelegate.h"
#import "CommonLinksConstants.h"

@interface CommonLinksFriendsViewController ()

@property (nonatomic, strong) CommonLinksDataManager* dataManager;

@end


@implementation CommonLinksFriendsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.dataManager = [CommonLinksDataManager sharedInstance];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newConnectionNotification:)
                                                 name:kNewConnectionNotification
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNewConnectionNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.localSummaryData)
    {
        self.navigationItem.title = [NSString stringWithFormat: @"Your Friends (%lu)", (unsigned long)self.dataManager.localUserData.friendList.count];
    }
    else
    {
        self.navigationItem.title = [NSString stringWithFormat: @"Mutual Friends (%lu)", (unsigned long)self.dataManager.matchedUserData.friendList.count];
    }
    //add check for 0 friends
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.localSummaryData)
        return self.dataManager.localUserData.friendList.count;
    else
        return self.dataManager.matchedUserData.friendList.count;
    //add check for 0 friends
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"friendsViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    if ([cell isKindOfClass:[CommonLinksFriendsViewCell class]])
    {
        FBProfilePictureView *profilePictureView = ((CommonLinksFriendsViewCell *)cell).profilePictureView;
        UILabel *friendName = ((CommonLinksFriendsViewCell *)cell).friendName;
        
        CommonLinksUserNameInfo *friendNameInfo;
        if(self.localSummaryData)
        {
            friendNameInfo = [self.dataManager.localUserData.friendList objectAtIndex:indexPath.row]; //check for validity of object
        }
        else
        {
            friendNameInfo = [self.dataManager.matchedUserData.friendList objectAtIndex:indexPath.row]; //check for validity of object
        }
        friendName.text = friendNameInfo.displayNameFull;
        profilePictureView.profileID = friendNameInfo.userID;
    }
    return cell;
    //add check for 0 friends
}

- (void)newConnectionNotification:(NSNotification *)notification {
    // pop to home!
    if (self.navigationController.topViewController == self) {
        NSString* peerConnected = [notification.userInfo objectForKey:kPeerIDKey];
        DebugLog(@"NewConnection with %@", peerConnected);
        
        CommonLinksAppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
        [self.navigationController popToViewController:appDelegate.homeViewController animated:YES];
    }
}

@end
