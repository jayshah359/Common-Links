//
//  CommonLinksViewController.m
//  Common Links
//
//  Created by Jaydev Shah on 6/21/13.
//  Copyright (c) 2013 JC11Factory. All rights reserved.
//

#import "CommonLinksLoginViewController.h"

#import <FacebookSDK/FacebookSDK.h>
#import <MediaPlayer/MediaPlayer.h>

#import "CommonLinksDataManager.h"
#import "CommonLinksSessionManager.h"
#import "CommonLinksConstants.h"

#import "CommonLinksHomeViewController.h"

#import "CommonLinksAppDelegate.h"
#import "CommonLinksLikeInfo.h"

#import "CommonLinksInAppPurchaseManager.h"

@interface CommonLinksLoginViewController ()

// we create it here, but do not use it
@property (strong, nonatomic) CommonLinksSessionManager* sessionManager;

@property (nonatomic, weak) CommonLinksDataManager* dataManager;

@property (nonatomic) BOOL gotUserData;
@property (nonatomic) BOOL gotUserLikes;
@property (nonatomic) BOOL gotUserFriends;
@property (nonatomic) BOOL connectionError;

@property (nonatomic) BOOL gotNewData;

@end


@implementation CommonLinksLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.navigationItem.title = @"";

    self.dataManager = [CommonLinksDataManager sharedInstance];

    self.sessionManager = [[CommonLinksSessionManager alloc] init];

    // we are not going to use this here, but we do need to intialize it as soon as we can
    [CommonLinksInAppPurchaseManager sharedInstance];

    // try to get user data from cache
    NSString* facebookUserName = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsFacebookUserNameKey];
    if (facebookUserName != nil) {
        [self.dataManager loadUserDataForUserName:facebookUserName];
    }
    
    if (self.dataManager.localUserData == nil) {
        DebugLog(@"Get Data from Facebook");
        
        // Check the session for a cached token to show the proper authenticated
        // UI. However, since this is not intitiated by the person using your app, do not show the login UX.
        CommonLinksAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        [appDelegate openSessionWithAllowLoginUI:NO];
        
    } else {
        DebugLog(@"Got Data from Disk");
        
        //NSTimeInterval lastTime = [self.dataManager.localUserData.lastRefreshDate timeIntervalSince1970];
        //NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
        
        // 60 secs * 60 mins * 24 hours * 7 days
        //NSInteger days = 7;
        //DebugLog(@"Age: %0.02f seconds", nowTime - lastTime);
        //if (nowTime - lastTime > 60 * 60 * 24 * days) {
        //if (nowTime - lastTime > 60) {
            // too old!
            //DebugLog(@"Old Data, Needs Refresh");
            //[self.dataManager fetchFromFacebook];
            
            // Check the session for a cached token to show the proper authenticated
            // UI. However, since this is not intitiated by the person using your app, do not show the login UX.
            //CommonLinksAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
            //[appDelegate openSessionWithAllowLoginUI:NO];
            
        //} else {
        
        // we have current localUserData, try to jump to the Home screen
        [self.authButton setTitle:@"  Logout of Facebook" forState:UIControlStateNormal];
        //[self.authButton setBackgroundColor:[[UIColor alloc] initWithRed:244.0 green:114.0 blue:3.0 alpha:1.0]]; //set button to orange
        
        self.gotUserData = YES;
        self.gotUserFriends = YES;
        self.gotUserLikes = YES;
        
        [self tryToPerformSegue];
        //}
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kFBSessionStateChangedNotification
                                                  object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sessionStateChanged:)
                                                 name:kFBSessionStateChangedNotification
                                               object:nil];
    
    [self.navigationController setNavigationBarHidden:YES];
    
    if ([self.authButton.titleLabel.text isEqualToString:@"  Logout of Facebook"]) {
        [self.loginScreenGraphic setImage:[UIImage imageNamed:@"logout-screen-graphic"]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)returnButtonAction:(id)sender {
    [self performSegueWithIdentifier:@"LoginToHome" sender:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kFBSessionStateChangedNotification
                                                  object:nil];
}

- (IBAction)authButtonAction:(id)sender {
    CommonLinksAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    // If the person is authenticated, log out when the button is clicked.
    // If the person is not authenticated, log in when the button is clicked.
    if (FBSession.activeSession.isOpen) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultsFacebookUserNameKey];
        [appDelegate closeSession];
    } else if ([self.authButton.titleLabel.text isEqualToString:@"  Login with Facebook"]) {
        // The person has initiated a login, so call the openSession method
        // and show the login UX if necessary.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"To find your common links, we'll need to connect to your Facebook profile and iTunes library. Nothing will be posted on your wall and no personal data will be stored on our servers."
                                                       delegate:self
                                              cancelButtonTitle:@"Close"
                                              otherButtonTitles:nil];
        [alert show];
    } else {
        [self.returnButton setHidden:YES];
        [self.loginSpinner stopAnimating];
        [self.loginScreenGraphic setImage:[UIImage imageNamed:@"login-screen-graphic"]];
        self.authButton.userInteractionEnabled = YES;
        self.authButton.alpha = 1.0;
        self.loginScreenGraphic.alpha = 1.0;
        [self.authButton setTitle:@"  Login with Facebook" forState:UIControlStateNormal];
        //[self.authButton setBackgroundColor:[[UIColor alloc] initWithRed:50.0 green:79.0 blue:133.0 alpha:1.0]]; //set button to blue
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultsFacebookUserNameKey];
    }
}

-(void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    CommonLinksAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    if(buttonIndex==0)
    {
        //Code that will run after you press ok button
        [appDelegate openSessionWithAllowLoginUI:YES];
        [self.loginSpinner startAnimating];
        self.authButton.userInteractionEnabled = NO;
        self.authButton.alpha = 0.5;
        self.loginScreenGraphic.alpha = 0.5;
    }
}

- (void)sessionStateChanged:(NSNotification*)notification {
    DebugLog(@"");
    if (FBSession.activeSession.isOpen) {
        [self.authButton setTitle:@"  Logout of Facebook" forState:UIControlStateNormal];
        [self.loginSpinner startAnimating];
        [self.loginScreenGraphic setImage:[UIImage imageNamed:@"logout-screen-graphic"]];
        self.authButton.userInteractionEnabled = NO;
        self.authButton.alpha = 0.5;
        self.loginScreenGraphic.alpha = 0.5;
        //[self.authButton setBackgroundColor:[[UIColor alloc] initWithRed:244.0 green:114.0 blue:3.0 alpha:1.0]]; //set button to orange
        [self loadInitialData];
    } else {
        [self.returnButton setHidden:YES];
        [self.loginSpinner stopAnimating];
        [self.loginScreenGraphic setImage:[UIImage imageNamed:@"login-screen-graphic"]];
        self.authButton.userInteractionEnabled = YES;
        self.authButton.alpha = 1.0;
        self.loginScreenGraphic.alpha = 1.0;
        [self.authButton setTitle:@"  Login with Facebook" forState:UIControlStateNormal];
        //[self.authButton setBackgroundColor:[[UIColor alloc] initWithRed:50.0 green:79.0 blue:133.0 alpha:1.0]]; //set button to blue
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"LoginToHome"]) {
        
        // Get destination view
        CommonLinksHomeViewController *homeViewController = [segue destinationViewController];
        
        homeViewController.sessionManager = self.sessionManager;
    }
}

- (void)loadInitialData
{
    self.dataManager.localUserData = [[CommonLinksUserData alloc] init];
    self.dataManager.localUserData.userNameInfo = [[CommonLinksUserNameInfo alloc] init];
    self.dataManager.localUserData.artistsNames = [[NSMutableArray alloc] init];
    
    self.gotNewData = YES;
    self.gotUserData = NO;
    self.gotUserFriends = NO;
    self.gotUserLikes = NO;
    self.connectionError = NO;
    
    // Fetch artists
    MPMediaQuery *artistsQuery = [MPMediaQuery artistsQuery];
    NSArray *artistsFromQuery = artistsQuery.collections;

    for (MPMediaItemCollection *artistCollection in artistsFromQuery) {
        NSString *artistTitle = [[artistCollection representativeItem] valueForProperty:MPMediaItemPropertyArtist];
        if (![self.dataManager.localUserData.artistsNames containsObject:artistTitle]) {
            [self.dataManager.localUserData.artistsNames addObject:artistTitle];
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
             self.dataManager.localUserData.userNameInfo.userName = user.username;
             self.dataManager.localUserData.userNameInfo.firstName = user.first_name;
             self.dataManager.localUserData.userNameInfo.lastName = user.last_name;
             self.dataManager.localUserData.userNameInfo.userID = user.id;
             DebugLog(@"%@", self.dataManager.localUserData.userNameInfo.userName);
         }
         
         dispatch_async(dispatch_get_main_queue(), ^{
             self.gotUserData = YES;
             [self tryToPerformSegue];
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
             self.dataManager.localUserData.likeNames = [[NSMutableArray alloc] initWithCapacity:likes.count];
             for (NSDictionary<FBGraphObject>* like in likes) {
                 CommonLinksLikeInfo *likeInfo = [[CommonLinksLikeInfo alloc] init];
                 likeInfo.likeID = [like objectForKey:@"id"];
                 likeInfo.likeName = [like objectForKey:@"name"];
                 [self.dataManager.localUserData.likeNames addObject:likeInfo];
             }
             DebugLog(@"%u likes", self.dataManager.localUserData.likeNames.count);
         }
         
         dispatch_async(dispatch_get_main_queue(), ^{
             self.gotUserLikes = YES;
             [self tryToPerformSegue];
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
             self.dataManager.localUserData.friendList = [[NSMutableArray alloc] initWithCapacity:friends.count];
             for (NSDictionary<FBGraphUser>* friend in friends) {
                 CommonLinksUserNameInfo *friendNameInfo = [[CommonLinksUserNameInfo alloc] init];
                 friendNameInfo.userID = friend.id;
                 friendNameInfo.userName = friend.username;
                 friendNameInfo.firstName = friend.first_name;
                 friendNameInfo.lastName = friend.last_name;
                 [self.dataManager.localUserData.friendList addObject:friendNameInfo];
             }
             DebugLog(@"%u friends", self.dataManager.localUserData.friendList.count);
         }
         
         dispatch_async(dispatch_get_main_queue(), ^{
             self.gotUserFriends = YES;
             [self tryToPerformSegue];
         });
     }];
}

- (BOOL)tryToPerformSegue {
    BOOL didSegue = NO;
    CommonLinksAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    if (self.connectionError == YES && self.gotUserData && self.gotUserFriends && self.gotUserLikes) {
        //display error message, don't erase localuserdata
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"Unable to connect Facebook."
                                                       delegate:nil
                                              cancelButtonTitle:@"Close"
                                              otherButtonTitles:nil];
        [alert show];
        
        if (FBSession.activeSession.isOpen) {
            [appDelegate closeSession];
        }
    } else if (self.gotUserData && self.gotUserFriends && self.gotUserLikes) {
        if (self.gotNewData) {
            // set last refreshed date
            self.dataManager.localUserData.lastRefreshDate = [NSDate date];
            
            // save current username to NSUserDefaults
            [[NSUserDefaults standardUserDefaults] setObject:self.dataManager.localUserData.userNameInfo.userName
                                                      forKey:kUserDefaultsFacebookUserNameKey];
            // commit changes to disk
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            // store user data
            [self.dataManager saveUserData];
            
            self.gotNewData = NO;
        }
        
        [self.loginSpinner stopAnimating];
        self.authButton.userInteractionEnabled = YES;
        self.authButton.alpha = 1.0;
        self.loginScreenGraphic.alpha = 1.0;
        [self performSegueWithIdentifier:@"LoginToHome" sender:self];
        [self.returnButton setHidden:NO];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:kFBSessionStateChangedNotification
                                                      object:nil];
        
        didSegue = YES;
    }
    
    return didSegue;
}

@end
