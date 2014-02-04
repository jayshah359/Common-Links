//
//  CommonLinksSummaryViewController.h
//  Common Links
//
//  Created by Jaydev Shah on 8/11/13.
//  Copyright (c) 2013 JC11Factory. All rights reserved.
//

@interface CommonLinksSummaryViewController : UITableViewController

@property BOOL localSummaryData;

@property (weak, nonatomic) IBOutlet UICollectionView *friendsView;
@property (weak, nonatomic) IBOutlet UILabel *artistsLabel;
@property (weak, nonatomic) IBOutlet UILabel *likesLabel;

- (IBAction)refreshLocalUserInfo:(id)sender;

@end
