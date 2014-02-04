//
//  CommonLinksViewController.h
//  Common Links
//
//  Created by Jaydev Shah on 6/21/13.
//  Copyright (c) 2013 JC11Factory. All rights reserved.
//

@interface CommonLinksLoginViewController : UIViewController <UIAlertViewDelegate>

- (IBAction)authButtonAction:(id)sender;
- (IBAction)returnButtonAction:(id)sender;

- (void)loadInitialData;

@property (weak, nonatomic) IBOutlet UIButton *authButton;
@property (weak, nonatomic) IBOutlet UIButton *returnButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView* loginSpinner;
@property (weak, nonatomic) IBOutlet UIImageView* loginScreenGraphic;

@end
