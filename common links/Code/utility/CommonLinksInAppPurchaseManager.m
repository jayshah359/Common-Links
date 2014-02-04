//
//  CommonLinksInAppPurchaseManager.m
//  Common Links
//
//  Created by Jaydev Shah on 1/29/14.
//  Copyright (c) 2014 JC11Factory. All rights reserved.
//

#import "CommonLinksInAppPurchaseManager.h"

#import "JTBInAppPurchaseManager.h"
#import "CommonLinksConstants.h"

#define kIAPKey @"IAP"

@interface CommonLinksInAppPurchaseManager () <JTBInAppPurchaseManagerDelegate>

@property (nonatomic, strong) JTBInAppPurchaseManager* purchaseManager;

@end


@implementation CommonLinksInAppPurchaseManager

static CommonLinksInAppPurchaseManager* singleton = nil;

+ (id)sharedInstance {
    if (singleton == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            singleton = [[CommonLinksInAppPurchaseManager alloc] init];
        });
    }
    
    return singleton;
}


- (id)init {
    self = [super init];
    if (self) {
        // init
        self.purchaseManager = [[JTBInAppPurchaseManager alloc] init];
        self.purchaseManager.delegate = self;
     
        // get stored purchase array
        self.purchasedArray = [[NSUserDefaults standardUserDefaults] stringArrayForKey:kIAPKey];
        
        // hard-coded list (update this list when you add new IAP to iTunesConnect)
        NSArray* productKeyArray = @[ kIAPPlayMusic ];
        
        // get details for these products from iTunes servers
        [self.purchaseManager fetchProductsForIdentifers:productKeyArray];
    }
    return self;
}

#pragma mark - Public methods

// Attempt to restore previous purchases (do not call without user consent)
- (void)restorePurchases {
    [self.purchaseManager restorePurchases];
}

// Attempt to purchase a particular SKProduct
- (void)buyProduct:(SKProduct *)product {
    [self.purchaseManager buyProduct:product];
}

// Get formatted price from product (for example: "$9.99" or "AU$9.99")
+ (NSString *)formattedPriceForProduct:(SKProduct *)product {
    return [JTBInAppPurchaseManager formattedPriceForProduct:product];
}

#pragma mark - JTBInAppPurchaseManagerDelegate methods

- (void)purchaseManager:(JTBInAppPurchaseManager *)purchaseManager didRecieveProductsResponse:(SKProductsResponse *)response withError:(NSError *)error
{
    // update the available array
    self.availableArray = response.products;
    
    // let the delegate know we've updated it
    if ([self.delegate respondsToSelector:@selector(purchaseManager:didFinishUpdatingAvailableArray:)]) {
        [self.delegate purchaseManager:self didFinishUpdatingAvailableArray:self.availableArray];
    }
}

- (void)purchaseManager:(JTBInAppPurchaseManager *)purchaseManager purchaseCompleted:(SKPaymentTransaction *)transaction {
    // create a new mutable aray from the existing array
    NSMutableArray* newArray = [NSMutableArray arrayWithArray:self.purchasedArray];
    
    // get the purchased item
    NSString* purchasedItem = transaction.payment.productIdentifier;
    
    // have we already purchased this?
    BOOL alreadyPurchased = NO;
    for (NSString *item in self.purchasedArray) {
        if ([item isEqualToString:purchasedItem]) {
            alreadyPurchased = YES;
            break;
        }
    }
    
    if (alreadyPurchased == NO) {
        // add purchased item
        [newArray addObject:purchasedItem];
        self.purchasedArray = [NSArray arrayWithArray:newArray];
        
        // store purchased array
        [[NSUserDefaults standardUserDefaults] setObject:self.purchasedArray forKey:kIAPKey];
        
        // try to save it...
        if ([[NSUserDefaults standardUserDefaults] synchronize]) {
            // saved! safe to remove transaction
            [self.purchaseManager finishTransaction:transaction];
        }
    }
    
    // let the delegate know we've updated it
    if ([self.delegate respondsToSelector:@selector(purchaseManager:didFinishUpdatingPurchasedArray:)]) {
        [self.delegate purchaseManager:self didFinishUpdatingPurchasedArray:self.purchasedArray];
    }
}

- (void)purchaseManager:(JTBInAppPurchaseManager *)purchaseManager purchaseFailed:(SKPaymentTransaction *)transaction {
    NSString* alertString = @"In-App Purchase Failed";
    
    // purchase failed, alert the user
    if (transaction.error != nil) {
        alertString = transaction.error.localizedDescription;
    }
    
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"In-App Purchase" message:alertString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];

    // user alerted! safe to remove transaction
    [self.purchaseManager finishTransaction:transaction];
    
    // let the delegate know we've updated it
    if ([self.delegate respondsToSelector:@selector(purchaseManager:didFinishUpdatingPurchasedArray:)]) {
        [self.delegate purchaseManager:self didFinishUpdatingPurchasedArray:self.purchasedArray];
    }
}

- (void)purchaseManager:(JTBInAppPurchaseManager *)purchaseManager purchaseRestored:(BOOL)productsWereRestored withError:(NSError *)error {
    if (productsWereRestored == NO) {
        NSString* alertString = @"In-App Purchase Restore Failed";
        
        // purchase failed, alert the user
        if (error != nil) {
            alertString = error.localizedDescription;
        }
        
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"In-App Purchase" message:alertString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    
    // let the delegate know we've updated it
    if ([self.delegate respondsToSelector:@selector(purchaseManager:didFinishUpdatingPurchasedArray:)]) {
        [self.delegate purchaseManager:self didFinishUpdatingPurchasedArray:self.purchasedArray];
    }
}



@end
