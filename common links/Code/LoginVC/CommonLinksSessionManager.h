//
//  CommonLinksSessionManager.h
//  Common Links
//
//  Created by Jaydev Shah on 1/20/14.
//  Copyright (c) 2014 JC11Factory. All rights reserved.
//

#import "CommonLinksSessionManagerDelegate.h"

@interface CommonLinksSessionManager : NSObject

@property (nonatomic, weak) id <CommonLinksSessionManagerDelegate>delegate;

@property (nonatomic, readonly) BOOL transferring;
@property (nonatomic, readonly) BOOL browserOpen;

// create/end session
- (void)createSessionWithLocalUserData:(CommonLinksUserData *)data;
- (void)endSession;

// start/stop advertising
- (void)startAdvertising;
- (void)stopAdvertising;

// show/dismiss peer search browser
- (void)searchForPeersWithViewController:(UIViewController *)viewController;
- (void)dismissPeersSearch;

@end
