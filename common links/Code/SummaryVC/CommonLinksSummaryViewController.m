//
//  CommonLinksSummaryViewController.m
//  Common Links
//
//  Created by Jaydev Shah on 8/11/13.
//  Copyright (c) 2013 JC11Factory. All rights reserved.
//

#import "CommonLinksSummaryViewController.h"

#import <FacebookSDK/FacebookSDK.h>

#import <MediaPlayer/MediaPlayer.h>

#import "CommonLinksSummaryViewFriendsCell.h"

#import "NSMutableArray+Shuffling.h"

#import "CommonLinksDataManager.h"
#import "CommonLinksFriendsViewController.h"
#import "CommonLinksArtistsViewController.h"
#import "CommonLinksLikesViewController.h"
#import "CommonLinksLikeInfo.h"
#import "CommonLinksConstants.h"
#import "CommonLinksAppDelegate.h"

@interface CommonLinksSummaryViewController () <UICollectionViewDataSource>

@property (nonatomic, weak) CommonLinksDataManager* dataManager;
@property (nonatomic, strong) CommonLinksUserData* temporaryUserData;

@property (nonatomic, strong) NSMutableArray *friendListShuffled;
@property (nonatomic, strong) NSMutableArray *artistsNamesShuffled;
@property (nonatomic, strong) NSMutableArray *likeNamesShuffled;

@property (nonatomic) BOOL refreshingFacebook;
@property (nonatomic) BOOL gotUserData;
@property (nonatomic) BOOL gotUserLikes;
@property (nonatomic) BOOL gotUserFriends;
@property (nonatomic) BOOL connectionError;

@end

@implementation CommonLinksSummaryViewController

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    BOOL performSegue = YES;
    
    if (self.refreshingFacebook == YES) {
        performSegue = NO;
    }
    if ([identifier isEqualToString:@"SummaryToFriends"]) {
        if (self.localSummaryData) {
            if (self.dataManager.localUserData.friendList.count == 0) {
                performSegue = NO;
            }
        } else {
            if (self.dataManager.matchedUserData.friendList.count == 0) {
                performSegue = NO;
            }
        }
    }
    else if ([identifier isEqualToString:@"SummaryToArtists"]) {
        if (self.localSummaryData) {
            if (self.dataManager.localUserData.artistsNames.count == 0) {
                performSegue = NO;
            }
        } else {
            if (self.dataManager.matchedUserData.artistsNames.count == 0) {
                performSegue = NO;
            }
        }
    }
    else if ([identifier isEqualToString:@"SummaryToLikes"]) {
        if (self.localSummaryData) {
            if (self.dataManager.localUserData.likeNames.count == 0) {
                performSegue = NO;
            }
        } else {
            if (self.dataManager.matchedUserData.likeNames.count == 0) {
                performSegue = NO;
            }
        }
    }
    
    return performSegue;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
        if ([[segue identifier] isEqualToString:@"SummaryToFriends"]) {
            
            // Get destination view
            CommonLinksFriendsViewController *friendsViewController = [segue destinationViewController];
            
            friendsViewController.localSummaryData = self.localSummaryData;
        }
        else if ([[segue identifier] isEqualToString:@"SummaryToArtists"]) {
            
            // Get destination view
            CommonLinksArtistsViewController *artistsViewController = [segue destinationViewController];
            
            artistsViewController.localSummaryData = self.localSummaryData;
        }
        else if ([[segue identifier] isEqualToString:@"SummaryToLikes"]) {
            
            // Get destination view
            CommonLinksLikesViewController *likesViewController = [segue destinationViewController];
            
            likesViewController.localSummaryData = self.localSummaryData;
        }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.friendListShuffled.count;
    //add check for 0 friends
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"summaryViewFriendsCell"
                                                                           forIndexPath:indexPath];
    if ([cell isKindOfClass:[CommonLinksSummaryViewFriendsCell class]])
    {
        FBProfilePictureView *profilePictureView = ((CommonLinksSummaryViewFriendsCell *)cell).profilePictureView;
        profilePictureView.profileID = nil;
        CommonLinksUserNameInfo *friendNameInfo = [self.friendListShuffled objectAtIndex:indexPath.row]; //check for validity of object
        profilePictureView.profileID = friendNameInfo.userID;
    }
    return cell;
}

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
        self.navigationItem.title = [NSString stringWithFormat: @"Your Possible Links (%u)", self.dataManager.localUserData.friendList.count + self.dataManager.localUserData.artistsNames.count + self.dataManager.localUserData.likeNames.count];
        self.friendListShuffled = [[NSMutableArray alloc] initWithArray:self.dataManager.localUserData.friendList];
        self.artistsNamesShuffled = [[NSMutableArray alloc] initWithArray:self.dataManager.localUserData.artistsNames];
        self.likeNamesShuffled = [[NSMutableArray alloc] initWithArray:self.dataManager.localUserData.likeNames];
    }
    else
    {
        self.navigationItem.title = [NSString stringWithFormat: @"Links with %@ (%u)", self.dataManager.remoteUserData.userNameInfo.displayName, self.dataManager.matchedUserData.friendList.count + self.dataManager.matchedUserData.artistsNames.count + self.dataManager.matchedUserData.likeNames.count];
        self.friendListShuffled = [[NSMutableArray alloc] initWithArray:self.dataManager.matchedUserData.friendList];
        self.artistsNamesShuffled = [[NSMutableArray alloc] initWithArray:self.dataManager.matchedUserData.artistsNames];
        self.likeNamesShuffled = [[NSMutableArray alloc] initWithArray:self.dataManager.matchedUserData.likeNames];
    }
    [self.friendListShuffled shuffle];
    [self.artistsNamesShuffled shuffle];
    [self.likeNamesShuffled shuffle];
    [self.friendsView reloadData];
    self.artistsLabel.text = [self.artistsNamesShuffled componentsJoinedByString:@", "];
    //add check for 0 artists
    self.likesLabel.text = @"";
    for (CommonLinksLikeInfo *likeNameInfo in self.likeNamesShuffled) {
        // do something with object
        self.likesLabel.text = [self.likesLabel.text stringByAppendingString:likeNameInfo.likeName];
        self.likesLabel.text = [self.likesLabel.text stringByAppendingString:@", "];
    }
    //remove last comma
    //add check for 0 items
    if (self.dataManager.matchedUserData.friendList.count == 0) {
        //
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.localSummaryData)
    {
        if(section==0){
            return [NSString stringWithFormat: @"Your Friends (%u)", self.dataManager.localUserData.friendList.count];
        }else if (section==1){
            return [NSString stringWithFormat: @"Your Artists (%u)", self.dataManager.localUserData.artistsNames.count];
        }else if (section==2){
            return [NSString stringWithFormat: @"Your Likes (%u)", self.dataManager.localUserData.likeNames.count];
        }else{
            return @"Undefined Section";
        }
    }
    else
    {
        if(section==0){
            return [NSString stringWithFormat: @"Friends (%u)", self.dataManager.matchedUserData.friendList.count];
        }else if (section==1){
            return [NSString stringWithFormat: @"Artists (%u)", self.dataManager.matchedUserData.artistsNames.count];
        }else if (section==2){
            return [NSString stringWithFormat: @"Likes (%u)", self.dataManager.matchedUserData.likeNames.count];
        }else{
            return @"Undefined Section";
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (IBAction)refreshLocalUserInfo:(id)sender {
    DebugLog(@"");
    
    // disable tableView cells
    self.refreshingFacebook = YES;
    self.connectionError = NO;
    self.tableView.allowsSelection = NO;
    
    self.temporaryUserData = [[CommonLinksUserData alloc] init];
    self.temporaryUserData.userNameInfo = [[CommonLinksUserNameInfo alloc] init];
    self.temporaryUserData.artistsNames = [[NSMutableArray alloc] init];
    
    self.gotUserData = NO;
    self.gotUserFriends = NO;
    self.gotUserLikes = NO;
    
    if (!FBSession.activeSession.isOpen) {
        CommonLinksAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        [appDelegate openSessionWithAllowLoginUI:YES];
    }
    
    // Fetch artists
    MPMediaQuery *artistsQuery = [MPMediaQuery artistsQuery];
    NSArray *artistsFromQuery = artistsQuery.collections;
    
    for (MPMediaItemCollection *artistCollection in artistsFromQuery) {
        NSString *artistTitle = [[artistCollection representativeItem] valueForProperty:MPMediaItemPropertyArtist];
        if (![self.temporaryUserData.artistsNames containsObject:artistTitle]) {
            [self.temporaryUserData.artistsNames addObject:artistTitle];
        }
    }
    
    
    // Fetch user data
    [FBRequestConnection
     startForMeWithCompletionHandler:^(FBRequestConnection *connection,
                                       id<FBGraphUser> user,
                                       NSError *error) {
         if(error) {
             DebugLog(@"%@", error);
             self.connectionError = YES;
         } else {
             self.temporaryUserData.userNameInfo.userName = user.username;
             self.temporaryUserData.userNameInfo.firstName = user.first_name;
             self.temporaryUserData.userNameInfo.lastName = user.last_name;
             self.temporaryUserData.userNameInfo.userID = user.id;
             DebugLog(@"%@", self.temporaryUserData.userNameInfo.userName);
         }
         
         dispatch_async(dispatch_get_main_queue(), ^{
             self.gotUserData = YES;
             [self tryToEndRefreshing];
         });
     }];
    
    // Fetch like list
    //check for 0 likes
    [FBRequestConnection startWithGraphPath:@"/me/likes?limit=1000"
                          completionHandler:^(FBRequestConnection *connection,
                                              id result,
                                              NSError *error)
     {
         if(error) {
             DebugLog(@"%@", error);
             self.connectionError = YES;
         } else {
             NSArray *likes = (NSArray*)[result data];
             self.temporaryUserData.likeNames = [[NSMutableArray alloc] initWithCapacity:likes.count];
             for (NSDictionary<FBGraphObject>* like in likes) {
                 CommonLinksLikeInfo *likeInfo = [[CommonLinksLikeInfo alloc] init];
                 likeInfo.likeID = [like objectForKey:@"id"];
                 likeInfo.likeName = [like objectForKey:@"name"];
                 [self.temporaryUserData.likeNames addObject:likeInfo];
             }
             DebugLog(@"%u likes", self.temporaryUserData.likeNames.count);
         }
         
         dispatch_async(dispatch_get_main_queue(), ^{
             self.gotUserLikes = YES;
             [self tryToEndRefreshing];
         });
     }];
    
    // Fetch friends list
    //check for 0 friends
    [[FBRequest requestForMyFriends] startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                                   NSDictionary* result,
                                                                   NSError *error)
     {
         if(error) {
             DebugLog(@"%@", error);
             self.connectionError = YES;
         } else {
             NSArray* friends = [result objectForKey:@"data"];
             self.temporaryUserData.friendList = [[NSMutableArray alloc] initWithCapacity:friends.count];
             for (NSDictionary<FBGraphUser>* friend in friends) {
                 CommonLinksUserNameInfo *friendNameInfo = [[CommonLinksUserNameInfo alloc] init];
                 friendNameInfo.userID = friend.id;
                 friendNameInfo.userName = friend.username;
                 friendNameInfo.firstName = friend.first_name;
                 friendNameInfo.lastName = friend.last_name;
                 [self.temporaryUserData.friendList addObject:friendNameInfo];
             }
             DebugLog(@"%u friends", self.temporaryUserData.friendList.count);
         }
         
         dispatch_async(dispatch_get_main_queue(), ^{
             self.gotUserFriends = YES;
             [self tryToEndRefreshing];
         });
     }];
}

- (BOOL)tryToEndRefreshing {
    BOOL didEndRefreshing = NO;
    
    if (self.connectionError == YES && self.gotUserData && self.gotUserFriends && self.gotUserLikes) {
        //display error message, don't erase localuserdata
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"Unable to connect Facebook."
                                                       delegate:nil
                                              cancelButtonTitle:@"Close"
                                              otherButtonTitles:nil];
        [alert show];
        
        [self.refreshControl endRefreshing];
        self.refreshingFacebook = NO;
        self.tableView.allowsSelection = NO;
        didEndRefreshing = YES;
    } else if (self.gotUserData && self.gotUserFriends && self.gotUserLikes) {
        //replace user data with temporarydata
        self.dataManager.localUserData = self.temporaryUserData;
        
        // set last refreshed date
        self.dataManager.localUserData.lastRefreshDate = [NSDate date];
        
        // save current username to NSUserDefaults
        [[NSUserDefaults standardUserDefaults] setObject:self.dataManager.localUserData.userNameInfo.userName
                                                  forKey:kUserDefaultsFacebookUserNameKey];
        // commit changes to disk
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        // store user data
        [self.dataManager saveUserData];
        
        //update UI
        [self.tableView reloadData];
        [self.friendsView reloadData];
        if (self.localSummaryData)
        {
            self.navigationItem.title = [NSString stringWithFormat: @"Your Possible Links (%u)", self.dataManager.localUserData.friendList.count + self.dataManager.localUserData.artistsNames.count + self.dataManager.localUserData.likeNames.count];
            self.friendListShuffled = [[NSMutableArray alloc] initWithArray:self.dataManager.localUserData.friendList];
            self.artistsNamesShuffled = [[NSMutableArray alloc] initWithArray:self.dataManager.localUserData.artistsNames];
            self.likeNamesShuffled = [[NSMutableArray alloc] initWithArray:self.dataManager.localUserData.likeNames];
        }
        else
        {
            [self.dataManager matchLocalAndRemoteUserData];
            self.navigationItem.title = [NSString stringWithFormat: @"Links with %@ (%u)", self.dataManager.remoteUserData.userNameInfo.displayName, self.dataManager.matchedUserData.friendList.count + self.dataManager.matchedUserData.artistsNames.count + self.dataManager.matchedUserData.likeNames.count];
            self.friendListShuffled = [[NSMutableArray alloc] initWithArray:self.dataManager.matchedUserData.friendList];
            self.artistsNamesShuffled = [[NSMutableArray alloc] initWithArray:self.dataManager.matchedUserData.artistsNames];
            self.likeNamesShuffled = [[NSMutableArray alloc] initWithArray:self.dataManager.matchedUserData.likeNames];
        }
        [self.friendListShuffled shuffle];
        [self.artistsNamesShuffled shuffle];
        [self.likeNamesShuffled shuffle];
        self.artistsLabel.text = [self.artistsNamesShuffled componentsJoinedByString:@", "];
        //add check for 0 artists
        self.likesLabel.text = @"";
        for (CommonLinksLikeInfo *likeNameInfo in self.likeNamesShuffled) {
            // do something with object
            self.likesLabel.text = [self.likesLabel.text stringByAppendingString:likeNameInfo.likeName];
            self.likesLabel.text = [self.likesLabel.text stringByAppendingString:@", "];
        }
        //remove last comma
        //add check for 0 movies
        
        [self.refreshControl endRefreshing];
        self.refreshingFacebook = NO;
        self.tableView.allowsSelection = YES;
        didEndRefreshing = YES;
    }
    
    return didEndRefreshing;
}

@end
