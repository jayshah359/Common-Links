//
//  CommonLinksArtistsViewCell.h
//  Common Links
//
//  Created by Jaydev Shah on 10/19/13.
//  Copyright (c) 2013 JC11Factory. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommonLinksArtistsViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *artistName;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *songPlayingActivityIndicator;

@end
