//
//  CommonLinksInAppPurchaseManagerDelegate.h
//  Common Links
//
//  Created by Jaydev Shah on 1/29/14.
//  Copyright (c) 2014 JC11Factory. All rights reserved.
//

#ifndef Common_Links_CommonLinksInAppPurchaseManagerDelegate_h
#define Common_Links_CommonLinksInAppPurchaseManagerDelegate_h

@class CommonLinksInAppPurchaseManager;


@protocol CommonLinksInAppPurchaseManagerDelegate <NSObject>

@required

- (void)purchaseManager:(CommonLinksInAppPurchaseManager *)purchaseManager didFinishUpdatingAvailableArray:(NSArray *)availableArray;
- (void)purchaseManager:(CommonLinksInAppPurchaseManager *)purchaseManager didFinishUpdatingPurchasedArray:(NSArray *)purchaseArray;

@optional

@end
#endif
