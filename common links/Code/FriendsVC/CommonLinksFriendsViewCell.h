//
//  CommonLinksFriendsCell.h
//  Common Links
//
//  Created by Jaydev Shah on 10/12/13.
//  Copyright (c) 2013 JC11Factory. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface CommonLinksFriendsViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet FBProfilePictureView *profilePictureView;
@property (weak, nonatomic) IBOutlet UILabel *friendName;

@end
