//
//  CommonLinksAppDelegate.h
//  Common Links
//
//  Created by Jaydev Shah on 6/21/13.
//  Copyright (c) 2013 JC11Factory. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

#import "CommonLinksHomeViewController.h"

@interface CommonLinksAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, weak) CommonLinksHomeViewController* homeViewController;

- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI;

- (void)closeSession;

@end
