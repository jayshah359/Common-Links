//
//  CommonLinksSessionManager.m
//  Common Links
//
//  Created by Jaydev Shah on 1/20/14.
//  Copyright (c) 2014 JC11Factory. All rights reserved.
//

#import "CommonLinksSessionManager.h"
#import "CommonLinksVersionNumber.h"
#import "CommonLinksUserData.h"
#import "CommonLinksConstants.h"

#import <MultipeerConnectivity/MultipeerConnectivity.h>

NSString * const kMessage = @"message";
NSString * const kMessageDataReceived = @"dataReceived";
NSString * const kMessageResend = @"resend";

@interface CommonLinksSessionManager () <MCSessionDelegate, MCAdvertiserAssistantDelegate, MCBrowserViewControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, readwrite) BOOL transferring;
@property (nonatomic, readwrite) BOOL browserOpen;

@property (strong, nonatomic) MCSession * session;
@property (strong, nonatomic) MCPeerID * myPeerId;
@property (strong, nonatomic) MCBrowserViewController * browser;
@property (strong, nonatomic) MCAdvertiserAssistant * advertiser;

@property (strong, nonatomic) CommonLinksVersionNumber *localVersion;
@property (strong, nonatomic) CommonLinksVersionNumber *remoteVersion;

@property (strong, nonatomic) CommonLinksUserData *localUserData;

@property (strong, nonatomic) NSMutableArray* didSendLocalData; // this is confirmed by "AllClear" message
@property (strong, nonatomic) NSMutableArray* didReceiveLocalData; // this is confirmed by receiving data

@end


@implementation CommonLinksSessionManager

#pragma mark - Public methods

- (void)createSessionWithLocalUserData:(CommonLinksUserData *)data {
    self.localVersion = [[CommonLinksVersionNumber alloc] init];
    self.localVersion.versionNumber = kDataProtocolVersion;
    
    self.localUserData = data;
    
    self.myPeerId = [[MCPeerID alloc] initWithDisplayName:self.localUserData.userNameInfo.displayName];
    DebugLog(@"User: %@", self.myPeerId.displayName);
    
    self.transferring = NO;
    self.browserOpen = NO;
    
    self.session = [[MCSession alloc] initWithPeer:self.myPeerId];
    self.session.delegate = self;
    
    // init didExchange data vars
    self.didSendLocalData = [NSMutableArray array];
    self.didReceiveLocalData = [NSMutableArray array];
    
}

- (void)startAdvertising {
    DebugLog(@"");
    self.advertiser = [[MCAdvertiserAssistant alloc] initWithServiceType:kServiceType
                                                           discoveryInfo:nil
                                                                 session:self.session];
    [self.advertiser start];
}

- (void)stopAdvertising {
    [self.advertiser stop];
    self.advertiser = nil;
}

- (void)dealloc {
    DebugLog(@"");
    [self endSession];
}

- (void)searchForPeersWithViewController:(UIViewController *)viewController {
    self.browser = [[MCBrowserViewController alloc] initWithServiceType:kServiceType
                                                                session:self.session];
    self.browser.delegate = self;
    self.browser.minimumNumberOfPeers = 2; // 2 = 1 peer + 1 self
    self.browser.maximumNumberOfPeers = 2; // 2 = 1 peer + 1 self
    
    [viewController presentViewController:self.browser
                                 animated:YES
                               completion:nil];
    self.browserOpen = YES;
}

- (BOOL)tryToEndSession {
    BOOL didEndSession = NO;
    
    // attempt to end session if conditions are met
    if (self.session != nil && self.session.connectedPeers.count > 0) {
        // we have peers, have we finished exchanging data?
        BOOL finished = YES;
        for (MCPeerID* peerId in self.session.connectedPeers) {
            BOOL didSend = NO;
            BOOL didReceive = NO;
            
            for (MCPeerID* sentPeerId in self.didSendLocalData) {
                if (sentPeerId == peerId) {
                    // we sent our data to this peer
                    didSend = YES;
                }
            }
            for (MCPeerID* receivedPeerId in self.didReceiveLocalData) {
                if (receivedPeerId == peerId) {
                    // we received data from this peer
                    didReceive = YES;
                }
            }
            
            if (didSend == NO && didReceive == NO) {
                // we're not done yet
                DebugLog(@"Not finished exchanging data yet (still sending and receiving)...");
                finished = NO;
                break;
            } else if (didSend == NO) {
                // we're not done yet
                DebugLog(@"Not finished exchanging data yet (still sending)...");
                finished = NO;
                break;
            } else if (didReceive == NO) {
                // we're not done yet
                DebugLog(@"Not finished exchanging data yet (still receiving)...");
                finished = NO;
                break;
            }
        }
        
        if (finished) {
            DebugLog(@"Finished exchanging data.");
            [self endSession];
            didEndSession = YES;
        }
        
    } else {
        // no peers, just end session
        DebugLog(@"No peers to exchange data with.");
        [self endSession];
        didEndSession = YES;
    }
    
    return didEndSession;
}

- (void)endSession {
    DebugLog(@"");

    NSMutableArray* nameArray = [NSMutableArray array];
    for (MCPeerID* peer in self.session.connectedPeers) {
        [nameArray addObject:peer.displayName];
    }
    
    self.transferring = NO;

    // stop advertisting
    [self stopAdvertising];

    // disconnect session
    [self.session disconnect];
    
    // let delegate know we've disconnected
    if ([self.delegate respondsToSelector:@selector(sessionManager:didDisconnectFromPeers:)]) {
        [self.delegate sessionManager:self didDisconnectFromPeers:nameArray];
    }
}

- (void)dismissPeersSearch {
    [self.browser dismissViewControllerAnimated:YES completion:^{
        self.browserOpen = NO;
    }];
}


#pragma mark - Data handling methods

- (void)sendLocalVersionToPeer:(MCPeerID *)peerID {
    DebugLog(@"Send Local Version to Peer:%@", peerID.displayName);
    NSError *error;
    BOOL success = [self.session sendData:[NSKeyedArchiver archivedDataWithRootObject:self.localVersion]
                   toPeers:[NSArray arrayWithObject:peerID]
                  withMode:MCSessionSendDataReliable
                     error:&error];
    
    if (success == NO) {
        if (error != nil) {
            NSLog(@"Error sending local version: %@", error);
        } else {
            NSLog(@"Error sending local version: Unknown");
        }
        
        // resend a few times
        //[self sendLocalVersionToPeer:peerID];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"Unable to connect to remote device."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Close"
                                                  otherButtonTitles:nil];
            [alert show];
        });
    }
}

- (void)sendLocalUserDataToPeer:(MCPeerID *)peerID {
    if (self.localVersion.versionNumber == self.remoteVersion.versionNumber) {
        // great! versions are the same, just send it
        NSError *error;
        NSData* sendData = [NSKeyedArchiver archivedDataWithRootObject:self.localUserData];
        DebugLog(@"Send Local User Data (%0.02fk) to Peer:%@", sendData.length/1024.0, peerID.displayName);
        
        BOOL success = [self.session sendData:sendData
                                      toPeers:[NSArray arrayWithObject:peerID]
                                     withMode:MCSessionSendDataReliable
                                        error:&error];
        if (success == NO) {
            if (error != nil) {
                NSLog(@"Error sending local data: %@", error);
            } else {
                NSLog(@"Error sending local data: Unknown");
            }
            
            // resend a few times
            //[self sendLocalUserDataToPeer:peerID];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                message:@"Unable to connect to remote device."
                                                               delegate:nil
                                                      cancelButtonTitle:@"Close"
                                                      otherButtonTitles:nil];
                [alert show];
            });
        }
        
    } else if (self.remoteVersion.versionNumber < self.localVersion.versionNumber) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"The device you're trying to connect to needs to update to the latest version."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Close"
                                                  otherButtonTitles:nil];
            [alert show];
        });
        [self endSession];
        
    } else if (self.remoteVersion.versionNumber > self.localVersion.versionNumber){
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"You need to update to the latest version to connect to this device."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Close"
                                                  otherButtonTitles:@"Update", nil];
            [alert show];
        });
        [self endSession];
        
    }

}

- (void)sendDataReceivedMessageToPeer:(MCPeerID *)peerID {
    DebugLog(@"Send DataReceived Message to Peer:%@", peerID.displayName);

    NSError *error;
    BOOL success = [self.session sendData:[NSKeyedArchiver archivedDataWithRootObject:@{ kMessage : kMessageDataReceived }]
                   toPeers:[NSArray arrayWithObject:peerID]
                  withMode:MCSessionSendDataReliable
                     error:&error];
    
    if (success == NO) {
        if (error != nil) {
            NSLog(@"Error sending DataReceived message: %@", error);
        } else {
            NSLog(@"Error sending DataReceived message: Unknown");
        }
        
        // resend a few times
        //[self sendDataReceivedMessageToPeer:peerID];
    }

}

- (void)handleMessageOfType:(NSString *)messageType fromPeer:(MCPeerID *)peerID {
    if ([messageType isEqualToString:kMessageDataReceived]) {
        DebugLog(@"Peer %@ Data Received. Try to end session...", peerID.displayName);
        
        // got the data received from the peer, we successfully sent our local data
        [self.didSendLocalData addObject:peerID];
        if ([self.delegate respondsToSelector:@selector(sessionManager:didSendLocalDataToPeer:)]) {
            [self.delegate sessionManager:self didSendLocalDataToPeer:peerID.displayName];
        }
        
        // try to end session now
        [self tryToEndSession];
        
    } else {
        DebugLog(@"Warning: Unknown messageType: %@", messageType);
    }
}

#pragma mark - MCSessionDelegate methods

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    id remoteData = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    DebugLog(@"Peer:%@ => %@", peerID.displayName, remoteData);
    
    // this could be the incoming version
    if ([remoteData isKindOfClass:[CommonLinksVersionNumber class]]){
        // store remote version
        self.remoteVersion = (CommonLinksVersionNumber *)remoteData;
        
        // try to send our local user data to this peer
        [self sendLocalUserDataToPeer:peerID];
        
    // this could be the incoming user data
    } else if ([remoteData isKindOfClass:[CommonLinksUserData class]]){
        // inform delegate that we have the remote data
        if ([self.delegate respondsToSelector:@selector(sessionManager:didReceiveRemoteInfo:)]) {
            [self.delegate sessionManager:self didReceiveRemoteInfo:(CommonLinksUserData *)remoteData];
        }

        // we got this peer's data, send the DataReceived
        [self sendDataReceivedMessageToPeer:peerID];

        // we have received the remote data
        [self.didReceiveLocalData addObject:peerID];
        if ([self.delegate respondsToSelector:@selector(sessionManager:didRecieveRemoteDataFromPeer:)]) {
            [self.delegate sessionManager:self didRecieveRemoteDataFromPeer:peerID.displayName];
        }
        
        // we may have already got the all-clear from the peer, so try to end session again
        [self tryToEndSession];
        
    // this could be an incoming message (of various types)
    } else if ([remoteData isKindOfClass:[NSDictionary class]]) {
        // get message from dictionary
        NSString* message = [remoteData objectForKey:kMessage];
        
        // handle message
        [self handleMessageOfType:message fromPeer:peerID];
        
    } else {
        // unknown data type
        DebugLog(@"Warning: Unknown data of type: %@", remoteData);
        
    }
}


- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    if (self.session) {
        switch (state) {
            case MCSessionStateNotConnected: // 0
                DebugLog(@"Peer:%@ Disconnected", peerID.displayName);
                [self endSession];
                break;
                
            case MCSessionStateConnecting: // 1
                DebugLog(@"Peer:%@ Connecting", peerID.displayName);
                break;

            case MCSessionStateConnected: // 2
                // connected, start by sending local version to peer
                DebugLog(@"Peer:%@ Connected", peerID.displayName);

                dispatch_async(dispatch_get_main_queue(), ^{
                    // set transferring
                    self.transferring = YES;
                    
                    // let delegate know we've connected
                    if ([self.delegate respondsToSelector:@selector(sessionManager:didConnectWithPeer:)]) {
                        [self.delegate sessionManager:self didConnectWithPeer:peerID.displayName];
                    }
                    
                    // post new connection notification to anyone who is interested (listening)
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNewConnectionNotification
                                                                        object:self
                                                                      userInfo:@{ kPeerIDKey : peerID.displayName }];

                    // dismiss peers search
                    //[self dismissPeersSearch];

                    // clear existing exhange data
                    for (MCPeerID* existingPeer in self.didSendLocalData) {
                        [self.didSendLocalData removeObject:existingPeer];
                        break;
                    }
                    for (MCPeerID* existingPeer in self.didReceiveLocalData) {
                        [self.didReceiveLocalData removeObject:existingPeer];
                        break;
                    }
                    
                    // network
                    [self sendLocalVersionToPeer:peerID];
                });
                break;
        }
    }
}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress {
    DebugLog(@"");
}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error {
    DebugLog(@"");
}

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID {
    DebugLog(@"");
}

#pragma mark - MCAdvertiserAssistantDelegate methods

- (void)advertiserAssitantWillPresentInvitation:(MCAdvertiserAssistant *)advertiserAssistant {
    
}

- (void)advertiserAssistantDidDismissInvitation:(MCAdvertiserAssistant *)advertiserAssistant {
    
}

#pragma mark - MCBrowserViewControllerDelegate methods

- (BOOL)browserViewController:(MCBrowserViewController *)browserViewController shouldPresentNearbyPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info {
    
    return YES;
}

- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController
{
    [self.browser dismissViewControllerAnimated:YES completion:^{
        self.browserOpen = NO;
    }];
}

- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)picker
{
    [self.browser dismissViewControllerAnimated:YES completion:^{
        self.browserOpen = NO;
    }];
}

#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex != [alertView cancelButtonIndex]){
        //update clicked
        if ([self.delegate respondsToSelector:@selector(sessionManager:showSKStoreAppWithIdentifier:)]) {
            [self.delegate sessionManager:self showSKStoreAppWithIdentifier:kAppID];
        }
    }
}

@end
