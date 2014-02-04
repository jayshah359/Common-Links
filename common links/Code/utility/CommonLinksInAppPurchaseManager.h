//
//  CommonLinksInAppPurchaseManager.h
//  Common Links
//
//  Created by Jaydev Shah on 1/29/14.
//  Copyright (c) 2014 JC11Factory. All rights reserved.
//

#import <StoreKit/StoreKit.h>
#import "CommonLinksInAppPurchaseManagerDelegate.h"

@interface CommonLinksInAppPurchaseManager : NSObject

@property (nonatomic, weak) id <CommonLinksInAppPurchaseManagerDelegate>delegate;

// SKProducts are available for sale and their details
// Array of SKProduct* from iTunes server
@property (nonatomic, strong) NSArray* availableArray;

// Items that have been purchased by user (stored locally in UserDefaults)
// Array of NSString* matching "com.jc11factory.feature" pattern
@property (nonatomic, strong) NSArray* purchasedArray;

// Shared singleton instance
+ (CommonLinksInAppPurchaseManager *)sharedInstance;

// Attempt to restore previous purchases (do not call without user consent)
- (void)restorePurchases;

// Attempt to purchase a particular SKProduct
- (void)buyProduct:(SKProduct *)product;


/**
 * @abstract Get formatted price from product (for example: "$9.99" or "AU$9.99")
 *
 * @param SKProduct to get formatted price from
 *
 */

+ (NSString *)formattedPriceForProduct:(SKProduct *)product;

@end
