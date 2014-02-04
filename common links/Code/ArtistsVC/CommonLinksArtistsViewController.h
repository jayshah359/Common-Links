//
//  CommonLinksArtistsViewController.h
//  Common Links
//
//  Created by Jaydev Shah on 10/19/13.
//  Copyright (c) 2013 JC11Factory. All rights reserved.
//

@interface CommonLinksArtistsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property BOOL localSummaryData;

@property (weak, nonatomic) IBOutlet UIButton *lockButton;
@property (weak, nonatomic) IBOutlet UIButton *rewindButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *forwardButton;
@property (weak, nonatomic) IBOutlet UIButton *shuffleToggleButton;

@property (weak, nonatomic) IBOutlet UILabel *nowPlayingLabel;
@property (weak, nonatomic) IBOutlet UITableView *artistsList;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomAnchor;

- (IBAction)lockAction:(id)sender;
- (IBAction)rewindAction:(id)sender;
- (IBAction)playAction:(id)sender;
- (IBAction)forwardAction:(id)sender;
- (IBAction)shuffleToggleAction:(id)sender;

- (IBAction)shuffleTextAction:(id)sender;
- (IBAction)shuffleIconAction:(id)sender;

@end
