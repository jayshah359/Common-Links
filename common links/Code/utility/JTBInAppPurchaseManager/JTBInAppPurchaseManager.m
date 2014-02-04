//
//  JTBInAppPurchaseManager.m
//  InAppPurchaseTest
//
//  Created by Jonathan Backer on 1/20/14.
//  Copyright (c) 2014 Jonathan Backer. All rights reserved.
//

#import "JTBInAppPurchaseManager.h"

@interface JTBInAppPurchaseManager () <SKProductsRequestDelegate, SKPaymentTransactionObserver>

@end


@implementation JTBInAppPurchaseManager

- (id)init {
    if (self = [super init]) {
        // observe SKPaymentQueue (SKProductsRequestDelegate)
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

- (void)dealloc {
    // clean up
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

#pragma mark - Public methods

- (void)fetchProductsForIdentifers:(NSArray *)productIndentifiers {
    if (productIndentifiers != nil && productIndentifiers.count > 0) {
        // create products request
        SKProductsRequest* productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:productIndentifiers]];
        productsRequest.delegate = self;
        
        // fetch products from iTunes Connect
        DebugLog(@"Starting products request...");
        [productsRequest start];
    }
}

- (void)buyProduct:(SKProduct *)product {
    if (product != nil) {
        // create payment request
        SKMutablePayment* payment = [SKMutablePayment paymentWithProduct:product];
        if (payment != nil) {
            // submit payment request
            DebugLog(@"Purchase: %@", payment.productIdentifier);
            [[SKPaymentQueue defaultQueue] addPayment:payment];
        }
        
    } else {
        DebugLog(@"Error: Product is nil");
    }
}

- (void)restorePurchases {
    DebugLog(@"");
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}


- (void)finishTransaction:(SKPaymentTransaction *)transaction {
    if (transaction != nil) {
        SKPaymentQueue* queue = [SKPaymentQueue defaultQueue];
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
            case SKPaymentTransactionStateRestored:
            case SKPaymentTransactionStateFailed:
                [queue finishTransaction:transaction];
                break;
                
            case SKPaymentTransactionStatePurchasing:
                break;
        }
    }
}

#pragma mark - SKProductsRequestDelegate methods

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    DebugLog(@"");
    if ([self.delegate respondsToSelector:@selector(purchaseManager:didRecieveProductsResponse:withError:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate purchaseManager:self didRecieveProductsResponse:response withError:nil];
        });
    }
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    DebugLog(@"Error: %@", error);
    if ([self.delegate respondsToSelector:@selector(purchaseManager:didRecieveProductsResponse:withError:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate purchaseManager:self didRecieveProductsResponse:nil withError:error];
        });
    }
}

#pragma mark - SKPaymentTransactionObserver methods

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction* transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing:
                // purchasing, update UI (if needed)
                DebugLog(@"Purchasing: %@", transaction.payment.productIdentifier);
                if ([self.delegate respondsToSelector:@selector(purchaseManager:purchaseInProgress:)]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.delegate purchaseManager:self purchaseInProgress:transaction];
                    });
                }
                break;

            case SKPaymentTransactionStatePurchased:
            case SKPaymentTransactionStateRestored:
                // new item purchased or old item restored
                DebugLog(@"Purchased: %@", transaction.payment.productIdentifier);
                if ([self.delegate respondsToSelector:@selector(purchaseManager:purchaseCompleted:)]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.delegate purchaseManager:self purchaseCompleted:transaction];
                    });
                }
                break;

            case SKPaymentTransactionStateFailed:
                // failed, present error to user
                DebugLog(@"Failed: %@", transaction.payment.productIdentifier);
                if ([self.delegate respondsToSelector:@selector(purchaseManager:purchaseFailed:)]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.delegate purchaseManager:self purchaseFailed:transaction];
                    });
                }
                break;
        }
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction* transaction in transactions) {
        DebugLog(@"Removed: %@", transaction.payment.productIdentifier);
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    DebugLog(@"Error: %@", error);
    // no purchases found
    if ([self.delegate respondsToSelector:@selector(purchaseManager:purchaseRestored:withError:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate purchaseManager:self purchaseRestored:NO withError:error];
        });
    }
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    DebugLog(@"");
    if (queue.transactions == nil || queue.transactions.count == 0) {
        // no purchases found
        if ([self.delegate respondsToSelector:@selector(purchaseManager:purchaseRestored:withError:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate purchaseManager:self purchaseRestored:NO withError:nil];
            });
        }
    } else {
        // only include restored purchases
        NSMutableArray* restoredTransactions = [NSMutableArray array];
        for (SKPaymentTransaction* transaction in queue.transactions) {
            if (transaction.originalTransaction != nil) {
                [restoredTransactions addObject:transaction];
            }
        }
        if ([self.delegate respondsToSelector:@selector(purchaseManager:purchaseRestored:withError:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate purchaseManager:self purchaseRestored:(restoredTransactions.count > 0) withError:nil];
            });
        }
    }
}

#pragma mark - Utility methods

+ (NSString *)formattedPriceForProduct:(SKProduct *)product {
    NSString* formattedPrice = nil;
    
    NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:product.priceLocale];
    formattedPrice = [numberFormatter stringFromNumber:product.price];
    
    return formattedPrice;
}

@end
