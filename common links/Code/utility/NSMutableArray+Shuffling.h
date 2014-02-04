//
//  NSMutableArray+Shuffling.h
//  Common Links
//
//  Created by Jaydev Shah on 9/22/13.
//  Copyright (c) 2013 JC11Factory. All rights reserved.
//

#import <Foundation/Foundation.h>

/** This category enhances NSMutableArray by providing methods to randomly
 * shuffle the elements using the Fisher-Yates algorithm.
 */

@interface NSMutableArray (Shuffling)

- (void)shuffle;

@end
