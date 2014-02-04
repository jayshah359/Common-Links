//
//  CommonLinksDataManager.h
//  Common Links
//
//  Created by Jaydev Shah on 1/23/14.
//  Copyright (c) 2014 JC11Factory. All rights reserved.
//

#import "CommonLinksUserData.h"

@interface CommonLinksDataManager : NSObject

@property (strong, nonatomic) CommonLinksUserData *localUserData;
@property (strong, nonatomic) CommonLinksUserData *remoteUserData;
@property (strong, nonatomic) CommonLinksUserData *matchedUserData;

// get singleton
+ (id)sharedInstance;

//match the local and remote user data and put the results in the matchUserData property
- (void)matchLocalAndRemoteUserData;

// save to disk (syncronous)
- (BOOL)saveUserData;

// load from disk (syncronous)
- (BOOL)loadUserDataForUserName:(NSString *)userName;

// load from Facebook (asyncronous)
- (void)fetchFromFacebook;

@end
