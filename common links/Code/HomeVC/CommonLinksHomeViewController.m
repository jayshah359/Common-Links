//
//  CommonLinksHomeViewController.m
//  Common Links
//
//  Created by Jaydev Shah on 8/3/13.
//  Copyright (c) 2013 JC11Factory. All rights reserved.
//

#import "CommonLinksHomeViewController.h"

#import <StoreKit/StoreKit.h>

#import "CommonLinksSummaryViewController.h"

#import "CommonLinksDataManager.h"
#import "CommonLinksAppDelegate.h"
#import "CommonLinksConstants.h"

#import "JTBConnectionAnimationView.h"

@interface CommonLinksHomeViewController ()  <CommonLinksSessionManagerDelegate, SKStoreProductViewControllerDelegate>

@property (nonatomic, weak) CommonLinksDataManager* dataManager;
@property (nonatomic, strong) JTBConnectionAnimationView* animationView;

@property (nonatomic) BOOL startMoveIn;

@end


@implementation CommonLinksHomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    [self.sessionManager stopAdvertising];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNewConnectionNotification object:nil];

    CommonLinksAppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    appDelegate.homeViewController = nil;
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    BOOL performSegue = YES;
    
    if ([identifier isEqualToString:@"HomeToLocalSummary"]) {
        if (self.sessionManager.transferring == YES) {
            performSegue = NO;
        }
    } else if ([identifier isEqualToString:@"HomeToMatchSummary"]) {
        if (self.dataManager.remoteUserData == nil) {
            performSegue = NO;
        }
    }
    
    return performSegue;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"HomeToLocalSummary"]) {
        
        // Get destination view
        CommonLinksSummaryViewController *summaryViewController = [segue destinationViewController];
        
        summaryViewController.localSummaryData = YES;
        
    } else if ([[segue identifier] isEqualToString:@"HomeToMatchSummary"]) {
        // Get destination view
        CommonLinksSummaryViewController *summaryViewController = [segue destinationViewController];
        
        summaryViewController.localSummaryData = NO;
    }
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.localLinkables.text = [NSString stringWithFormat: @"%u", self.dataManager.localUserData.friendList.count + self.dataManager.localUserData.artistsNames.count + self.dataManager.localUserData.likeNames.count];

    [self.navigationController setNavigationBarHidden:NO];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // resume paused animations
    [self.animationView resumeAnimationPlayer];
    
    if (self.startMoveIn) {
        DebugLog(@"Start MoveIn");
        self.startMoveIn = NO;
        [self createAnimationView];
        [self.animationView startMoveIn];
    } else {
        DebugLog(@"");
    }
    
    //[UIView animateWithDuration:10.0 delay:0.0 options:UIViewAnimationOptionRepeat animations:^{
    //    self.localUserNameLabel.center = CGPointMake(200, self.localUserNameLabel.center.y);
    //} completion:^(BOOL finished) {
        // this will never be called since we are repeating
    //}];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
  
    CommonLinksAppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    appDelegate.homeViewController = self;
    
    self.dataManager = [CommonLinksDataManager sharedInstance];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newConnectionNotification:)
                                                 name:kNewConnectionNotification
                                               object:nil];
    
    NSLayoutConstraint *localHeightConstraint = [NSLayoutConstraint constraintWithItem:self.localProfilePic
                                                                             attribute:NSLayoutAttributeHeight
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:self.localProfilePic
                                                                             attribute:NSLayoutAttributeWidth
                                                                            multiplier:1.0
                                                                              constant:0];
    localHeightConstraint.priority = 1000;
    [self.localProfilePic.superview addConstraint:localHeightConstraint];

    NSLayoutConstraint *remoteHeightConstraint = [NSLayoutConstraint constraintWithItem:self.remoteProfilePic
                                                                             attribute:NSLayoutAttributeHeight
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:self.remoteProfilePic
                                                                             attribute:NSLayoutAttributeWidth
                                                                            multiplier:1.0
                                                                              constant:0];
    remoteHeightConstraint.priority = 1000;
    [self.remoteProfilePic.superview addConstraint:remoteHeightConstraint];
    
    self.localUserNameLabel.text = self.dataManager.localUserData.userNameInfo.displayNameFull;
    self.localProfilePic.profileID = self.dataManager.localUserData.userNameInfo.userID;
    [self.localSpinner stopAnimating];
    
    self.localLinkables.text = [NSString stringWithFormat: @"%u", self.dataManager.localUserData.friendList.count + self.dataManager.localUserData.artistsNames.count + self.dataManager.localUserData.likeNames.count];
    
    // create the session, listen for changes, start advertising
    self.sessionManager.delegate = self;
    [self.sessionManager createSessionWithLocalUserData:self.dataManager.localUserData];
    [self.sessionManager startAdvertising];

//    NSArray *keys = [NSArray arrayWithObjects:@"userID", @"versionNumber", nil];
//    NSArray *objects = [NSArray arrayWithObjects:self.localUserData.userNameInfo.userID, versionNumber, nil];
//    NSDictionary *discoveryDictionary = [NSDictionary dictionaryWithObjects:objects
//                                                                    forKeys:keys];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)searchButtonPressed:(UIButton *)button
{
    if (button == self.searchButton) {
        if (self.sessionManager.transferring == NO) {
            // see if we can find any other devices running this app
            [self.sessionManager searchForPeersWithViewController:self];
        } else {
            self.matchStatus.text = nil;
            [self.sessionManager endSession];
        }
    }
}

- (void)newConnectionNotification:(NSNotification *)notification {

    self.dataManager.remoteUserData = nil;
    self.dataManager.matchedUserData = nil;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // clear UI
        self.remoteUserNameLabel.text = nil;
        self.remoteProfilePic.profileID = nil;
        self.remoteLinkables.text = @"?";
        self.remoteLinkText.text = nil;
    });
}

#pragma mark - CommonLinksSessionManagerDelegate methods

- (void)sessionManager:(CommonLinksSessionManager *)sessionManager didReceiveRemoteInfo:(CommonLinksUserData *)data {
    DebugLog(@"");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.remoteSpinner stopAnimating];

        self.dataManager.remoteUserData = data;

        self.remoteUserNameLabel.text = self.dataManager.remoteUserData.userNameInfo.displayName;
        self.remoteProfilePic.profileID = self.dataManager.remoteUserData.userNameInfo.userID;
        
        self.remoteLinkables.text = [NSString stringWithFormat: @"%u", self.dataManager.remoteUserData.friendList.count + self.dataManager.remoteUserData.artistsNames.count + self.dataManager.remoteUserData.likeNames.count];
        
        self.remoteLinkText.text = [NSString stringWithFormat: @"Possible Links"];
        
        // this is process heavy, but pretty fast
        DebugLog(@"Matching data...");
        [self.dataManager matchLocalAndRemoteUserData];
        DebugLog(@"Completed!");
        
        self.matchStatus.text = [NSString stringWithFormat: @"You have %u Common Links",
                                 self.dataManager.matchedUserData.friendList.count + self.dataManager.matchedUserData.artistsNames.count + self.dataManager.matchedUserData.likeNames.count];
        
        DebugLog(@"%u friends, %u artists, %u likes, %u total",
                 self.dataManager.matchedUserData.friendList.count,
                 self.dataManager.matchedUserData.artistsNames.count,
                 self.dataManager.matchedUserData.likeNames.count,
                 self.dataManager.matchedUserData.friendList.count + self.dataManager.matchedUserData.artistsNames.count + self.dataManager.matchedUserData.likeNames.count);
    });
}

- (void)sessionManager:(CommonLinksSessionManager *)sessionManager showSKStoreAppWithIdentifier:(NSString *)identifier {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([SKStoreProductViewController class]) {
            SKStoreProductViewController *controller = [[SKStoreProductViewController alloc] init];
            controller.delegate = self;
            [controller loadProductWithParameters:@{ SKStoreProductParameterITunesItemIdentifier : identifier }
                                  completionBlock:NULL];
            
            [self presentViewController:controller animated:YES completion:nil];
            
        } else {
            // Fall back to opening App Store for iOS 5.
            NSString *iTunesLink = [NSString stringWithFormat:@"http://itunes.apple.com/app/id%@?mt=8", identifier];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
        }
    });
}

- (void)sessionManager:(CommonLinksSessionManager *)sessionManager didConnectWithPeer:(NSString *)displayName {
    DebugLog(@"");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.remoteSpinner startAnimating];
        
        // transferring updates to UI
        self.matchStatus.text = nil;
        // is browser window open?
        if (self.sessionManager.browserOpen) {
            // yes, connection browser is up
            DebugLog(@"View not on top");
            self.startMoveIn = YES;
        } else {
            DebugLog(@"View on top");
            self.startMoveIn = NO;
            [self createAnimationView];
            [self.animationView startMoveIn];
        }
        [self.searchButton setTitle:@"Cancel Connection" forState:UIControlStateNormal];
    });
}

- (void)sessionManager:(CommonLinksSessionManager *)sessionManager didDisconnectFromPeers:(NSArray *)displayNameArray {
    DebugLog(@"");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.remoteSpinner stopAnimating];
        [self.animationView endAnimation];
        self.startMoveIn = NO;
        [self.searchButton setTitle:@"Search for Nearby Users" forState:UIControlStateNormal];
        
        // recreate the session, listen for changes, start advertising
        [self.sessionManager createSessionWithLocalUserData:self.dataManager.localUserData];
        [self.sessionManager startAdvertising];
    });
}

- (void)sessionManager:(CommonLinksSessionManager *)sessionManager didSendLocalDataToPeer:(NSString *)displayName {
    DebugLog(@"");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.animationView stopLocal];
    });
}

- (void)sessionManager:(CommonLinksSessionManager *)sessionManager didRecieveRemoteDataFromPeer:(NSString *)displayName {
    DebugLog(@"");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.animationView stopRemote];
    });
}

#pragma mark - SKStoreProductViewControllerDelegate methods

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Create AnimationView

- (void)createAnimationView {
    // if it already exists, remove it from view
    [self.animationView removeFromSuperview];
    
    // create a new view
    self.animationView = [[JTBConnectionAnimationView alloc] initWithFrame:self.animationContainerView.bounds];
    
    // add to container
    [self.animationContainerView addSubview:self.animationView];
}

@end
