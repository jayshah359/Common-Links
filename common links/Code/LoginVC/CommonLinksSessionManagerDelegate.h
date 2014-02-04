//
//  CommonLinksSessionManagerDelegate.h
//  Common Links
//
//  Created by Jaydev Shah on 1/20/14.
//  Copyright (c) 2014 JC11Factory. All rights reserved.
//

#ifndef Common_Links_CommonLinksSessionManagerDelegate_h
#define Common_Links_CommonLinksSessionManagerDelegate_h

#import "CommonLinksUserData.h"

@class CommonLinksSessionManager;


@protocol CommonLinksSessionManagerDelegate <NSObject>

@required

- (void)sessionManager:(CommonLinksSessionManager *)sessionManager didReceiveRemoteInfo:(CommonLinksUserData *)data;
- (void)sessionManager:(CommonLinksSessionManager *)sessionManager showSKStoreAppWithIdentifier:(NSString *)identifier;

@optional

- (void)sessionManager:(CommonLinksSessionManager *)sessionManager didConnectWithPeer:(NSString *)displayName;
- (void)sessionManager:(CommonLinksSessionManager *)sessionManager didDisconnectFromPeers:(NSArray *)displayNameArray;

- (void)sessionManager:(CommonLinksSessionManager *)sessionManager didSendLocalDataToPeer:(NSString *)displayName;
- (void)sessionManager:(CommonLinksSessionManager *)sessionManager didRecieveRemoteDataFromPeer:(NSString *)displayName;

@end

#endif
