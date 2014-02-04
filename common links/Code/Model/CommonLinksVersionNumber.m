//
//  CommonLinksVersionNumber.m
//  Common Links
//
//  Created by Jaydev Shah on 11/2/13.
//  Copyright (c) 2013 JC11Factory. All rights reserved.
//

#import "CommonLinksVersionNumber.h"

@implementation CommonLinksVersionNumber

NSString *const versionNumberKey = @"versionNumberKey";

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.versionNumber = [decoder decodeIntegerForKey:versionNumberKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInteger:self.versionNumber forKey:versionNumberKey];
}

@end
