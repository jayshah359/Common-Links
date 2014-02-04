//
//  CommonLinksLikesViewController.m
//  Common Links
//
//  Created by Jaydev Shah on 11/9/13.
//  Copyright (c) 2013 JC11Factory. All rights reserved.
//

#import "CommonLinksLikesViewController.h"

#import "CommonLinksDataManager.h"
#import "CommonLinksLikeInfo.h"
#import "CommonLinksLikesViewCell.h"
#import "CommonLinksConstants.h"
#import "CommonLinksAppDelegate.h"

@interface CommonLinksLikesViewController ()

@property (nonatomic, weak) CommonLinksDataManager* dataManager;

@end


@implementation CommonLinksLikesViewController

- (void)viewDidLoad {
    [super viewDidLoad];

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
        self.navigationItem.title = [NSString stringWithFormat: @"Your Likes (%lu)", (unsigned long)self.dataManager.localUserData.likeNames.count];
    }
    else
    {
        self.navigationItem.title = [NSString stringWithFormat: @"Mutual Likes (%lu)", (unsigned long)self.dataManager.matchedUserData.likeNames.count];
    }
    //add check for 0 friends
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.localSummaryData)
        return self.dataManager.localUserData.likeNames.count;
    else
        return self.dataManager.matchedUserData.likeNames.count;
    //add check for 0 friends
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"likesViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    if ([cell isKindOfClass:[CommonLinksLikesViewCell class]])
    {
        FBProfilePictureView *profilePictureView = ((CommonLinksLikesViewCell *)cell).profilePictureView;
        profilePictureView.profileID = nil;
        UILabel *likeName = ((CommonLinksLikesViewCell *)cell).likeName;
        CommonLinksLikeInfo *likeInfo;
        
        if(self.localSummaryData)
        {
            likeInfo = [self.dataManager.localUserData.likeNames objectAtIndex:indexPath.row]; //check for validity of object
        }
        else
        {
            likeInfo = [self.dataManager.matchedUserData.likeNames objectAtIndex:indexPath.row]; //check for validity of object
        }
        likeName.text = likeInfo.likeName;
        profilePictureView.profileID = likeInfo.likeID;
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
