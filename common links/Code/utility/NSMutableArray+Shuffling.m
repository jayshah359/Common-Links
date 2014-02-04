//
//  NSMutableArray+Shuffling.m
//  Common Links
//
//  Created by Jaydev Shah on 9/22/13.
//  Copyright (c) 2013 JC11Factory. All rights reserved.
//

#import "NSMutableArray+Shuffling.h"

@implementation NSMutableArray (Shuffling)

- (void)shuffle
{
    NSUInteger count = [self count];
    for (long i = 0; i < count; ++i)
    {
        // Select a random element between i and end of array to swap with.
        long nElements = count - i;
        long n = arc4random_uniform((uint)nElements) + i;
        [self exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
}

@end
