//
//  CommonLinksFriendsCell.m
//  Common Links
//
//  Created by Jaydev Shah on 10/12/13.
//  Copyright (c) 2013 JC11Factory. All rights reserved.
//

#import "CommonLinksFriendsViewCell.h"

@implementation CommonLinksFriendsViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.profilePictureView.profileID = nil;
}

@end
