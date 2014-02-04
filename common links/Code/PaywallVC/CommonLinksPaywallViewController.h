//
//  CommonLinksPaywallViewController.h
//  Common Links
//
//  Created by Jaydev Shah on 2/2/14.
//  Copyright (c) 2014 JC11Factory. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommonLinksPaywallViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIButton* purchaseButton;

- (IBAction)purchasePressed:(id)sender;
- (IBAction)cancelPressed:(id)sender;
- (IBAction)restorePressed:(id)sender;

@end
