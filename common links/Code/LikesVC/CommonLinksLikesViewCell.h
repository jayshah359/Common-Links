//
//  CommonLinksLikesViewCell.h
//  Common Links
//
//  Created by Jaydev Shah on 11/9/13.
//  Copyright (c) 2013 JC11Factory. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface CommonLinksLikesViewCell : UITableViewCell


@property (weak, nonatomic) IBOutlet FBProfilePictureView *profilePictureView;
@property (weak, nonatomic) IBOutlet UILabel *likeName;

@end
