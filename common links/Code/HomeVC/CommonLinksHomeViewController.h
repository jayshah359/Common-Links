//
//  CommonLinksHomeViewController.h
//  Common Links
//
//  Created by Jaydev Shah on 8/3/13.
//  Copyright (c) 2013 JC11Factory. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>

#import "CommonLinksSessionManager.h"

@interface CommonLinksHomeViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *localUserNameLabel;
@property (weak, nonatomic) IBOutlet FBProfilePictureView *localProfilePic;
@property (weak ,nonatomic) IBOutlet UIActivityIndicatorView* localSpinner;
@property (weak, nonatomic) IBOutlet UILabel *localLinkables;
@property (weak, nonatomic) IBOutlet UILabel *localLinkText;

@property (weak, nonatomic) IBOutlet UILabel *remoteUserNameLabel;
@property (weak, nonatomic) IBOutlet FBProfilePictureView *remoteProfilePic;
@property (weak ,nonatomic) IBOutlet UIActivityIndicatorView* remoteSpinner;
@property (weak, nonatomic) IBOutlet UILabel *remoteLinkables;
@property (weak, nonatomic) IBOutlet UILabel *remoteLinkText;

@property (weak, nonatomic) IBOutlet UILabel *matchStatus;
@property (weak, nonatomic) IBOutlet UIView *viewMatchData;

@property (weak, nonatomic) IBOutlet UIButton* searchButton;

@property (weak, nonatomic) IBOutlet UIView* animationContainerView;

// we use it here, but do not create it
@property (weak, nonatomic) CommonLinksSessionManager* sessionManager;

- (IBAction)searchButtonPressed:(UIButton *)button;

@end
