//
//  CommonLinksArtistsViewController.m
//  Common Links
//
//  Created by Jaydev Shah on 10/19/13.
//  Copyright (c) 2013 JC11Factory. All rights reserved.
//

#import "CommonLinksArtistsViewController.h"

#import <MediaPlayer/MediaPlayer.h>

#import "CommonLinksDataManager.h"
#import "CommonLinksArtistsViewCell.h"
#import "CommonLinksArtistsShuffleCell.h"
#import "CommonLinksAppDelegate.h"
#import "CommonLinksConstants.h"

#import "CommonLinksPaywallViewController.h"

#import "CommonLinksInAppPurchaseManager.h"

@interface CommonLinksArtistsViewController () <CommonLinksInAppPurchaseManagerDelegate, UIAlertViewDelegate>

@property (nonatomic, weak) CommonLinksDataManager* dataManager;
@property (nonatomic, weak) CommonLinksInAppPurchaseManager* purchaseManager;

@property MPMusicPlayerController* iPodMusicPlayer;
@property NSInteger playlistSize;

@end

@implementation CommonLinksArtistsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // load data
    self.dataManager = [CommonLinksDataManager sharedInstance];
    
    // setup IAP manager
    self.purchaseManager = [CommonLinksInAppPurchaseManager sharedInstance];
    self.purchaseManager.delegate = self;

    // setup music player
    self.iPodMusicPlayer = [MPMusicPlayerController iPodMusicPlayer];

    // set default playlist size
    self.playlistSize = 0;
    
    // listen for new connections
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newConnectionNotification:)
                                                 name:kNewConnectionNotification
                                               object:nil];
    
    // listen for changes from music player
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(nowPlayingItemChanged:)
                                                 name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification
                                               object:self.iPodMusicPlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playbackStateChanged:)
                                                 name:MPMusicPlayerControllerPlaybackStateDidChangeNotification
                                               object:self.iPodMusicPlayer];
}

- (void)dealloc {
    // clean up observers
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNewConnectionNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:self.iPodMusicPlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:self.iPodMusicPlayer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // set here again in case someone else changed it
    self.purchaseManager.delegate = self;

    if (self.localSummaryData)
    {
        self.navigationItem.title = [NSString stringWithFormat: @"Your Artists (%u)", self.dataManager.localUserData.artistsNames.count];
        [self.nowPlayingLabel setHidden:YES]; //TODO
        [self.lockButton setHidden:YES];
        [self.rewindButton setHidden:YES];
        [self.playButton setHidden:YES];
        [self.forwardButton setHidden:YES];
        [self.shuffleToggleButton setHidden:YES];
        
        self.bottomAnchor.constant = -(self.nowPlayingLabel.frame.size.height + self.playButton.frame.size.height);
        [self.artistsList setAllowsSelection:NO];
    }
    else
    {
        self.navigationItem.title = [NSString stringWithFormat: @"Mutual Artists (%u)", self.dataManager.matchedUserData.artistsNames.count];
        [self.nowPlayingLabel setHidden:NO]; //TODO
        [self.lockButton setHidden:NO];
        [self.rewindButton setHidden:NO];
        [self.playButton setHidden:NO];
        [self.forwardButton setHidden:NO];
        [self.shuffleToggleButton setHidden:NO];
        
        self.bottomAnchor.constant = 0;
        [self.artistsList setAllowsSelection:YES];
        
        if ([self verifyMusicUnlocked]) {
            [self.lockButton setImage:nil forState:UIControlStateNormal];
            [self.lockButton setEnabled:NO];
        }
        
        self.iPodMusicPlayer = [MPMusicPlayerController iPodMusicPlayer];
        self.playlistSize = 0;
        [self.iPodMusicPlayer setShuffleMode: MPMusicShuffleModeSongs];
        [self.iPodMusicPlayer setRepeatMode: MPMusicRepeatModeNone];
        [self.iPodMusicPlayer stop];
                
        [self.iPodMusicPlayer beginGeneratingPlaybackNotifications];
    }
}

#pragma mark - TableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DebugLog(@"%i:%i", indexPath.section, indexPath.row);
    
    if(indexPath.row == 0 && !self.localSummaryData) { //TODO
        // do nothing on first row if matched view
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        if ([self isMusicUnlocked]) {
        
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSMutableArray *itemsFromArtistsQuery = [[NSMutableArray alloc] init];
                MPMediaQuery *myArtistQuery = [[MPMediaQuery alloc] init];
                
                if(self.localSummaryData)
                {
                    MPMediaPropertyPredicate *artistNamePredicate =
                    [MPMediaPropertyPredicate predicateWithValue: [self.dataManager.localUserData.artistsNames objectAtIndex:indexPath.row] //check for validity of object //TODO
                                                     forProperty: MPMediaItemPropertyArtist];
                    
                    [myArtistQuery addFilterPredicate: artistNamePredicate];
                    
                    [itemsFromArtistsQuery addObjectsFromArray:[myArtistQuery items]];
                }
                else
                {
                    MPMediaPropertyPredicate *artistNamePredicate =
                    [MPMediaPropertyPredicate predicateWithValue: [self.dataManager.matchedUserData.artistsNames objectAtIndex:indexPath.row - 1] //check for validity of object
                                                     forProperty: MPMediaItemPropertyArtist];
                    
                    [myArtistQuery addFilterPredicate: artistNamePredicate];
                    
                    [itemsFromArtistsQuery addObjectsFromArray:[myArtistQuery items]];
                }
                
                MPMediaItemCollection *userMediaItemCollection = [[MPMediaItemCollection alloc] initWithItems:(NSArray *)itemsFromArtistsQuery];
                
                [self.iPodMusicPlayer setQueueWithItemCollection: userMediaItemCollection];
                self.playlistSize = userMediaItemCollection.count;
                
                [self.iPodMusicPlayer setShuffleMode: MPMusicShuffleModeOff];
                [self.iPodMusicPlayer setRepeatMode: MPMusicRepeatModeNone];
                [self.iPodMusicPlayer play];
            });
        }
    }
}

#pragma mark - TableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 0;
    
    if (self.localSummaryData == NO) {
        rows = self.dataManager.matchedUserData.artistsNames.count + 1;
    } else {
        rows = self.dataManager.localUserData.artistsNames.count;
    }
    
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *simpleTableIdentifier;
    if(indexPath.row == 0 && !self.localSummaryData) //TODO
        simpleTableIdentifier = @"artistsShuffleCell";
    else
        simpleTableIdentifier = @"artistsViewCell";

    // try to reuse an existing cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        // build a new cell
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    if ([cell isKindOfClass:[CommonLinksArtistsViewCell class]])
    {
        UILabel *artistName = ((CommonLinksArtistsViewCell *)cell).artistName;
        
        if(self.localSummaryData)
        {
            artistName.text = [self.dataManager.localUserData.artistsNames objectAtIndex:indexPath.row]; //check for validity of object //TODO
        }
        else
        {
            artistName.text = [self.dataManager.matchedUserData.artistsNames objectAtIndex:(indexPath.row - 1)]; //check for validity of object
        }
        
        if(self.iPodMusicPlayer.playbackState == MPMusicPlaybackStatePlaying &&
           [[self.iPodMusicPlayer.nowPlayingItem valueForProperty: MPMediaItemPropertyArtist] isEqualToString:artistName.text]) {
            [((CommonLinksArtistsViewCell *)cell).songPlayingActivityIndicator startAnimating];
        } else {
            [((CommonLinksArtistsViewCell *)cell).songPlayingActivityIndicator stopAnimating];
        }
    }

    return cell;
    //add check for 0 friends
}

- (IBAction)shuffleTextAction:(id)sender {
    if ([self isMusicUnlocked]) {
        //DebugLog(@"shuffle text clicked");
        [self shuffleAction];
    }
}

- (IBAction)shuffleIconAction:(id)sender {
    if ([self isMusicUnlocked]) {
        //DebugLog(@"shuffle icon clicked");
        [self shuffleAction];
    }
}

- (void)shuffleAction {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //set play mode to shuffle
        [self.iPodMusicPlayer setShuffleMode: MPMusicShuffleModeSongs];
        //set shuffle toggle button to on
        [self.shuffleToggleButton setSelected:YES];
        
        //create playlist of all artists songs
        [self createFullPlaylist];
        [self.iPodMusicPlayer play];
    });
}

- (IBAction)lockAction:(id)sender {
    //if music playback not purchased, bring up in app purchase screen
    //else do nothing
    if ([self isMusicUnlocked]) {
    }
}

- (IBAction)rewindAction:(id)sender {
    //if music playback not purchased, bring up in app purchase screen
    if ([self isMusicUnlocked]) {
        [self.iPodMusicPlayer skipToPreviousItem];
    }
}

- (IBAction)playAction:(id)sender {
    //if music playback not purchased, bring up in app purchase screen
    if ([self isMusicUnlocked]) {
        if (self.iPodMusicPlayer.playbackState == MPMusicPlaybackStatePaused){
            [self.iPodMusicPlayer play];
        } else if (self.iPodMusicPlayer.playbackState == MPMusicPlaybackStateStopped){
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self createFullPlaylist];
                [self.iPodMusicPlayer setShuffleMode: MPMusicShuffleModeOff];
                [self.shuffleToggleButton setSelected:NO];
                [self.iPodMusicPlayer setRepeatMode: MPMusicRepeatModeNone];
                [self.iPodMusicPlayer play];
            });
        } else if (self.iPodMusicPlayer.playbackState == MPMusicPlaybackStatePlaying){
            [self.iPodMusicPlayer pause];
        } else { //other playback state
            //
        }
    }
}

- (void) createFullPlaylist {
    MPMediaQuery *everything = [[MPMediaQuery alloc] init];
    NSArray *itemsFromEverythingQuery = [everything items];
    NSMutableArray *filteredItems = [[NSMutableArray alloc] init];
    
    if(self.localSummaryData)
    {
        for (MPMediaItem *song in itemsFromEverythingQuery) {
            NSString *artistName = [song valueForProperty:MPMediaItemPropertyArtist];

            if ([self.dataManager.localUserData.artistsNames containsObject:artistName]) {
                [filteredItems addObject:song];
            }
        }
    }
    else
    {
        for (MPMediaItem *song in itemsFromEverythingQuery) {
            NSString *artistName = [song valueForProperty:MPMediaItemPropertyArtist];
            
            if ([self.dataManager.matchedUserData.artistsNames containsObject:artistName]) {
                [filteredItems addObject:song];
            }
        }
    }
    
    MPMediaItemCollection *userMediaItemCollection = [[MPMediaItemCollection alloc] initWithItems:(NSArray *)filteredItems];
    
    [self.iPodMusicPlayer setQueueWithItemCollection: userMediaItemCollection];
    self.playlistSize = userMediaItemCollection.count;
}

- (IBAction)forwardAction:(id)sender {
    //if music playback not purchased, bring up in app purchase screen
    if ([self isMusicUnlocked]) {
        [self.iPodMusicPlayer skipToNextItem];
    }
}

- (IBAction)shuffleToggleAction:(id)sender {
    if ([self isMusicUnlocked]) {
        if ([sender isSelected]) {
            //[sender setImage:[UIImage imageNamed:@"shuffle-grey.png"] forState:UIControlStateNormal];
            [sender setSelected:NO];
            [self.iPodMusicPlayer setShuffleMode: MPMusicShuffleModeOff];
        } else {
            //[sender setImage:[UIImage imageNamed:@"shuffle-back.png"] forState:UIControlStateSelected];
            [sender setSelected:YES];
            [self.iPodMusicPlayer setShuffleMode: MPMusicShuffleModeSongs];
        }
        
        if (self.playlistSize == 0 || self.playlistSize == 1) {
            [self.rewindButton setEnabled:NO];
            [self.forwardButton setEnabled:NO];
        } else {
            if ([self.iPodMusicPlayer indexOfNowPlayingItem] == 0) {
                [self.rewindButton setEnabled:NO];
                [self.forwardButton setEnabled:YES];
            } else if ([self.iPodMusicPlayer indexOfNowPlayingItem] == self.playlistSize-1) {
                [self.rewindButton setEnabled:YES];
                [self.forwardButton setEnabled:NO];
            } else {
                [self.rewindButton setEnabled:YES];
                [self.forwardButton setEnabled:YES];
            }
        }
    }
}

#pragma mark - Music Player delegate methods

- (void)nowPlayingItemChanged: (id) notification {
    //DebugLog(@"item changed notification");
    // Display the artist and song name for the now-playing media item
    if (self.playlistSize > 0) {
        [self.nowPlayingLabel setText: [
                                   NSString stringWithFormat: @"%@ - %@",
                                   [self.iPodMusicPlayer.nowPlayingItem valueForProperty: MPMediaItemPropertyArtist],
                                   [self.iPodMusicPlayer.nowPlayingItem valueForProperty: MPMediaItemPropertyTitle]]];
    }
    
    if (self.playlistSize == 0 || self.playlistSize == 1) {
        [self.rewindButton setEnabled:NO];
        [self.forwardButton setEnabled:NO];
    } else {
        if ([self.iPodMusicPlayer indexOfNowPlayingItem] == 0) {
            [self.rewindButton setEnabled:NO];
            [self.forwardButton setEnabled:YES];
        } else if ([self.iPodMusicPlayer indexOfNowPlayingItem] == self.playlistSize-1) {
            [self.rewindButton setEnabled:YES];
            [self.forwardButton setEnabled:NO];
        } else {
            [self.rewindButton setEnabled:YES];
            [self.forwardButton setEnabled:YES];
        }
    }
    
    for (UITableViewCell *cell in self.artistsList.visibleCells) {
        if ([cell isKindOfClass:[CommonLinksArtistsViewCell class]])
        {
            if ([[self.iPodMusicPlayer.nowPlayingItem valueForProperty: MPMediaItemPropertyArtist] isEqualToString:((CommonLinksArtistsViewCell *)cell).artistName.text]) {
                
                [((CommonLinksArtistsViewCell *)cell).songPlayingActivityIndicator startAnimating];
            } else {
                [((CommonLinksArtistsViewCell *)cell).songPlayingActivityIndicator stopAnimating];
            }
        }
    }
}

- (void)playbackStateChanged: (id) notification {
    //DebugLog(@"state changed notification");
    if (self.iPodMusicPlayer.playbackState == MPMusicPlaybackStatePaused){
        //update play/pause button
        [self.playButton setSelected:NO];
        for (UITableViewCell *cell in self.artistsList.visibleCells) {
            if ([cell isKindOfClass:[CommonLinksArtistsViewCell class]])
            {
                [((CommonLinksArtistsViewCell *)cell).songPlayingActivityIndicator stopAnimating];
            }
        }
    } else if (self.iPodMusicPlayer.playbackState == MPMusicPlaybackStateStopped){
        //update play/pause button
        [self.playButton setSelected:NO];
        [self.forwardButton setEnabled:NO];
        [self.rewindButton setEnabled:NO];
        [self.nowPlayingLabel setText:@""];
        for (UITableViewCell *cell in self.artistsList.visibleCells) {
            if ([cell isKindOfClass:[CommonLinksArtistsViewCell class]])
            {
                [((CommonLinksArtistsViewCell *)cell).songPlayingActivityIndicator stopAnimating];
            }
        }
    } else if ( self.iPodMusicPlayer.playbackState == MPMusicPlaybackStatePlaying){
        //update play/pause button
        [self.playButton setSelected:YES];
        for (UITableViewCell *cell in self.artistsList.visibleCells) {
            if ([cell isKindOfClass:[CommonLinksArtistsViewCell class]])
            {
                if ([[self.iPodMusicPlayer.nowPlayingItem valueForProperty: MPMediaItemPropertyArtist] isEqualToString:((CommonLinksArtistsViewCell *)cell).artistName.text]) {
                    
                    [((CommonLinksArtistsViewCell *)cell).songPlayingActivityIndicator startAnimating];
                }
            }
        }
    }
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

#pragma mark - InAppPurchase methods

- (BOOL)verifyMusicUnlocked {
    BOOL unlocked = NO;
    
    for (NSString* item in self.purchaseManager.purchasedArray) {
        if ([item isEqualToString:kIAPPlayMusic]) {
            unlocked = YES;
        }
    }
    
    return unlocked;
}

- (BOOL)isMusicUnlocked {
    BOOL unlocked = NO;
    
    for (NSString* item in self.purchaseManager.purchasedArray) {
        if ([item isEqualToString:kIAPPlayMusic]) {
            unlocked = YES;
        }
    }
    
    if (unlocked == NO) {
        // get info from purchase manager
        SKProduct* activeProduct = nil;
        for (SKProduct* product in self.purchaseManager.availableArray) {
            if ([product.productIdentifier isEqualToString:kIAPPlayMusic]) {
                activeProduct = product;
            }
        }
        
        if (activeProduct != nil) {
            [self performSegueWithIdentifier:@"PopupMusicPaywall" sender:self];
            
//            NSString* message = [NSString stringWithFormat:@"%@ (%@)", activeProduct.localizedDescription, [CommonLinksInAppPurchaseManager formattedPriceForProduct:activeProduct]];
//                                 
//            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:activeProduct.localizedTitle
//                                                                message:message
//                                                               delegate:self
//                                                      cancelButtonTitle:@"Cancel"
//                                                      otherButtonTitles:@"Purchase", @"Restore", nil];
//            [alertView show];
        } else {
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Play Music"
                                                                message:@"In-App Purchase not available at this time"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        }
        
    }
    
    return unlocked;
}

//#pragma mark - UIAlertViewDelegate methods
//
//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
//    if (buttonIndex == 0) {
//        // cancel, do nothing
//        
//    } else if (buttonIndex == 1) {
//        // get info from purchase manager
//        SKProduct* activeProduct = nil;
//        for (SKProduct* product in self.purchaseManager.availableArray) {
//            if ([product.productIdentifier isEqualToString:kIAPPlayMusic]) {
//                activeProduct = product;
//            }
//        }
//
//        // purchase! $$$
//        [self.purchaseManager buyProduct:activeProduct];
//        
//    } else if (buttonIndex == 2) {
//        // restore previous purchases
//        [self.purchaseManager restorePurchases];
//    }
//}

#pragma mark - CommonLinksInAppPurchaseManagerDelegate methods

- (void)purchaseManager:(CommonLinksInAppPurchaseManager *)purchaseManager didFinishUpdatingAvailableArray:(NSArray *)availableArray {
    // nothing to do here, unless we are updating some visible list of all in-app purchases (like in a TableView)
}

- (void)purchaseManager:(CommonLinksInAppPurchaseManager *)purchaseManager didFinishUpdatingPurchasedArray:(NSArray *)purchaseArray {
    // check to see if our particular item was purchased
    BOOL purchased = NO;
    for (NSString* item in self.purchaseManager.purchasedArray) {
        if ([item isEqualToString:kIAPPlayMusic]) {
            purchased = YES;
        }
    }
    
    if (purchased == YES) {
        // yay! change unlock button?
        [self.lockButton setImage:nil forState:UIControlStateNormal];
        
//        // show user a confirmation screen
//        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Purchase Complete"
//                                   message:@"Play Music Unlocked!"
//                                  delegate:nil
//                         cancelButtonTitle:@"OK"
//                         otherButtonTitles:nil];
//        [alertView show];
    }
}


@end