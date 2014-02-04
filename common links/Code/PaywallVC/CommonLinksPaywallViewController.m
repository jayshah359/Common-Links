//
//  CommonLinksPaywallViewController.m
//  Common Links
//
//  Created by Jaydev Shah on 2/2/14.
//  Copyright (c) 2014 JC11Factory. All rights reserved.
//

#import "CommonLinksPaywallViewController.h"
#import "CommonLinksInAppPurchaseManager.h"
#import "CommonLinksConstants.h"

@interface CommonLinksPaywallViewController () <CommonLinksInAppPurchaseManagerDelegate>

@property (nonatomic, weak) CommonLinksInAppPurchaseManager* purchaseManager;

@end

@implementation CommonLinksPaywallViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.purchaseManager = [CommonLinksInAppPurchaseManager sharedInstance];
    
    // get info from purchase manager
    SKProduct* activeProduct = nil;
    for (SKProduct* product in self.purchaseManager.availableArray) {
        if ([product.productIdentifier isEqualToString:kIAPPlayMusic]) {
            activeProduct = product;
        }
    }
    
    if (activeProduct != nil) {
        [self.purchaseButton setTitle:[NSString stringWithFormat: @"Unlock Play Music - %@", [CommonLinksInAppPurchaseManager formattedPriceForProduct:activeProduct]]
                             forState:UIControlStateNormal];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)purchasePressed:(id)sender {
    // get info from purchase manager
    SKProduct* activeProduct = nil;
    for (SKProduct* product in self.purchaseManager.availableArray) {
        if ([product.productIdentifier isEqualToString:kIAPPlayMusic]) {
            activeProduct = product;
        }
    }
    
    // purchase! $$$
    [self.purchaseManager buyProduct:activeProduct];
}

- (IBAction)cancelPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)restorePressed:(id)sender {
    // restore previous purchases
    [self.purchaseManager restorePurchases];
}

#pragma mark - CommonLinksInAppPurchaseManagerDelegate methods

- (void)purchaseManager:(CommonLinksInAppPurchaseManager *)purchaseManager didFinishUpdatingAvailableArray:(NSArray *)availableArray {
    // nothing to do here, unless we are updating some visible list of all in-app purchases (like in a TableView)
}

- (void)purchaseManager:(CommonLinksInAppPurchaseManager *)purchaseManager didFinishUpdatingPurchasedArray:(NSArray *)purchaseArray {
    // check to see if our particular item was purchased
    BOOL purchased = NO;
    for (NSString* item in self.purchaseManager.purchasedArray) {
        if ([item isEqualToString:kIAPPlayMusic]) {
            purchased = YES;
        }
    }
    
    if (purchased == YES) {
        // yay! change unlock button?
        //[self.lockButton setImage:nil forState:UIControlStateNormal];
        
        // show user a confirmation screen
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Purchase Complete"
                                                            message:@"Play Music Unlocked!"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

@end
