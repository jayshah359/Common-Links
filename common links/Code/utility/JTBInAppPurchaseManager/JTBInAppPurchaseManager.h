//
//  JTBInAppPurchaseManager.h
//  InAppPurchaseTest
//
//  Created by Jonathan Backer on 1/20/14.
//  Copyright (c) 2014 Jonathan Backer. All rights reserved.
//

#import <StoreKit/StoreKit.h>
#import "JTBInAppPurchaseManagerDelegate.h"

@interface JTBInAppPurchaseManager : NSObject

// you must assign this to your class to see delegate responses
@property (nonatomic, weak) id <JTBInAppPurchaseManagerDelegate>delegate;


/**
 * @discussion Step 1: Fetch Products from iTunesConnect
 *
 * Wait for delegate response:
 *  - (void)purchaseManager:(JTBInAppPurchaseManager *)purchaseManager didRecieveProductsResponse:(SKProductsResponse *)response withError:(NSError *)error;
 *
 * @param Array of NSString* productIdentifiers 
 *        You must provide this list yourself either hard-coded, from a local file, or from your own server.
 *        Identifiers are as setup in iTunes Connect, usually named "com.mycompany.iapitem".
 *
 */

- (void)fetchProductsForIdentifers:(NSArray *)productIdentifiers;


/**
 * @discussion Step 2a: Product Purchase
 *
 * Wait for delegate response:
 *  - (void)purchaseManager:(JTBInAppPurchaseManager *)purchaseManager purchaseCompleted:(SKPaymentTransaction *)transaction;
 *  - (void)purchaseManager:(JTBInAppPurchaseManager *)purchaseManager purchaseFailed:(SKPaymentTransaction *)transaction;
 *  - (void)purchaseManager:(JTBInAppPurchaseManager *)purchaseManager purchaseInProgress:(SKPaymentTransaction *)transaction;
 *
 * @param SKProduct to purchase (as returned by fetchProductsForIdentifiers: above
 */

- (void)buyProduct:(SKProduct *)product;


/**
 * @discussion Step 2b: Restore Previous Purchases
 *
 * Wait for delegate response:
 *  - (void)purchaseManager:(JTBInAppPurchaseManager *)purchaseManager purchaseRestored:(BOOL)productsWereRestored withError:(NSError *)error;
 *
 * Previous Purchases will then each be returned as separate calls from delegate:
 *  - (void)purchaseManager:(JTBInAppPurchaseManager *)purchaseManager purchaseCompleted:(SKPaymentTransaction *)transaction;
 *  - (void)purchaseManager:(JTBInAppPurchaseManager *)purchaseManager purchaseFailed:(SKPaymentTransaction *)transaction;
 *  - (void)purchaseManager:(JTBInAppPurchaseManager *)purchaseManager purchaseInProgress:(SKPaymentTransaction *)transaction;
 *
 */

 - (void)restorePurchases;


/**
 * @discussion Step 3: Finish Transaction (Remove from Queue)
 *
 * Call from purchaseManager:purchaseCompleted: and you have finished storing the transaction locally
 * Call when purchaseMnagaer:purchaseFailed: and user has been alerted
 *
 * @param SKPaymentTransaction to finish (as returned from purchaseManager:purchaseCompleted: or purchaseManager:purchaseFailed:)
 *
 */

- (void)finishTransaction:(SKPaymentTransaction *)transaction;


/**
 * @abstract Get formatted price from product (for example: "$9.99" or "AU$9.99")
 *
 * @param SKProduct to get formatted price from
 *
 */

+ (NSString *)formattedPriceForProduct:(SKProduct *)product;

@end
