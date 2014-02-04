//
//  CommonLinksDataManager.m
//  Common Links
//
//  Created by Jaydev Shah on 1/23/14.
//  Copyright (c) 2014 JC11Factory. All rights reserved.
//

#import "CommonLinksDataManager.h"
#import "CommonLinksConstants.h"

#import "JTBEncryptedArchiver.h"

@implementation CommonLinksDataManager

static CommonLinksDataManager* singleton = nil;

+ (id)sharedInstance {
    if (singleton == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            singleton = [[CommonLinksDataManager alloc] init];
        });
    }
    
    return singleton;
}

#pragma mark - Facebook fetch

// load from Facebook (asyncronous)
- (void)fetchFromFacebook {
    // TODO: move code from pull-to-refresh here
    
    // remember to update the lastRefreshDate when Facebook finally returns with new data
}

#pragma mark - Match data

- (void)matchLocalAndRemoteUserData {
    // this is process heavy, but pretty fast
    DebugLog(@"Matching data...");
    if (self.localUserData != nil && self.remoteUserData != nil) {
        self.matchedUserData = [[CommonLinksUserData alloc] init];
        
        //match friends list
        NSMutableSet *localFriends = [NSMutableSet setWithArray:self.localUserData.friendList];
        NSMutableSet *remoteFriends = [NSMutableSet setWithArray:self.remoteUserData.friendList];
        
        [localFriends intersectSet:remoteFriends];
        
        self.matchedUserData.friendList = [NSMutableArray arrayWithArray:[localFriends allObjects]];
        
        //match artists list
        NSMutableSet *localArtists = [NSMutableSet setWithArray:self.localUserData.artistsNames];
        NSMutableSet *remoteArtists = [NSMutableSet setWithArray:self.remoteUserData.artistsNames];
        
        [localArtists intersectSet:remoteArtists];
        
        self.matchedUserData.artistsNames = [NSMutableArray arrayWithArray:[localArtists allObjects]];
        
        //match movies list
        NSMutableSet *localLikes = [NSMutableSet setWithArray:self.localUserData.likeNames];
        NSMutableSet *remoteLikes = [NSMutableSet setWithArray:self.remoteUserData.likeNames];
        
        [localLikes intersectSet:remoteLikes];
        
        self.matchedUserData.likeNames = [NSMutableArray arrayWithArray:[localLikes allObjects]];
        DebugLog(@"Completed!");
    } else {
        DebugLog(@"Error in matching data");
    }
}

#pragma mark - Persistance

// save to disk (syncronous)
- (BOOL)saveUserData {
    BOOL didSave = NO;
    
    if (self.localUserData) {
        didSave = [JTBEncryptedArchiver saveObject:self.localUserData
                                        toFilename:self.localUserData.userNameInfo.userName
                                       inDirectory:NSCachesDirectory
                                 withEncryptionKey:kEncryptionKey];
    }
    
    return didSave;
}

// load from disk (syncronous)
- (BOOL)loadUserDataForUserName:(NSString *)userName {
    BOOL didLoad = NO;
    
    self.localUserData = [JTBEncryptedArchiver objectFromFilename:userName
                                                      inDirectory:NSCachesDirectory
                                                withDecryptionKey:kEncryptionKey];
    
    if (self.localUserData) {
        didLoad = YES;
    }
    
    return didLoad;
}

@end
