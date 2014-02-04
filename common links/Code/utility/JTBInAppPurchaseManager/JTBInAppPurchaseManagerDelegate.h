//
//  JTBInAppPurchaseManagerDelegate.h
//  InAppPurchaseTest
//
//  Created by Jonathan Backer on 1/20/14.
//  Copyright (c) 2014 Jonathan Backer. All rights reserved.
//

#ifndef InAppPurchaseTest_JTBInAppPurchaseManagerDelegate_h
#define InAppPurchaseTest_JTBInAppPurchaseManagerDelegate_h

#import <StoreKit/StoreKit.h>

@class JTBInAppPurchaseManager;

@protocol JTBInAppPurchaseManagerDelegate <NSObject>

/**
 * @abstract A list of SKProducts available for this app to purchase in iTunes
 *
 * Called in response to:
 *  - (void)fetchProductsForIdentifers:(NSArray *)productIdentifiers;
 *
 */

- (void)purchaseManager:(JTBInAppPurchaseManager *)purchaseManager didRecieveProductsResponse:(SKProductsResponse *)response withError:(NSError *)error;

/**
 * @abstract A completed/restored purchase for a particular SKProduct
 *
 * Called in response to:
 *  - (void)buyProduct:(SKProduct *)product;
 *  - (void)restorePurchases;
 */

- (void)purchaseManager:(JTBInAppPurchaseManager *)purchaseManager purchaseCompleted:(SKPaymentTransaction *)transaction;

/**
 * @abstract A failed purchase for a particular SKProduct
 *
 * Called in response to:
 *  - (void)buyProduct:(SKProduct *)product;
 */

- (void)purchaseManager:(JTBInAppPurchaseManager *)purchaseManager purchaseFailed:(SKPaymentTransaction *)transaction;

@optional

/**
 * @abstract A purchase in progress for a particular SKProduct
 *
 * Optional, but useful for updating the UI
 *
 * Called in response to:
 *  - (void)buyProduct:(SKProduct *)product;
 */

- (void)purchaseManager:(JTBInAppPurchaseManager *)purchaseManager purchaseInProgress:(SKPaymentTransaction *)transaction;

/**
 * @abstract A purchase in progress for a particular SKProduct
 *
 * Optional, but useful for showing the user an alert if restore failed for some reason
 *
 * If (productsWereRestored == NO && error == nil), then 
 *   There was no error, but this user has made no purchases at all
 *   Or this user has made no purchases that can be restored (purchases were consumable)
 *
 * Called in response to:
 *  - (void)restorePurchases;
 */

- (void)purchaseManager:(JTBInAppPurchaseManager *)purchaseManager purchaseRestored:(BOOL)productsWereRestored withError:(NSError *)error;

@end

#endif
