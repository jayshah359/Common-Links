//
//  CommonLinksLikeInfo.m
//  Common Links
//
//  Created by Jaydev Shah on 10/27/13.
//  Copyright (c) 2013 JC11Factory. All rights reserved.
//

#import "CommonLinksLikeInfo.h"

@implementation CommonLinksLikeInfo

NSString *const likeNameKey = @"likeNameKey";
NSString *const likeIDKey = @"likeIDKey";

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.likeName = [decoder decodeObjectForKey:likeNameKey];
        self.likeID = [decoder decodeObjectForKey:likeIDKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.likeName forKey:likeNameKey];
    [encoder encodeObject:self.likeID forKey:likeIDKey];
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    return [self isEqualToWidget:other];
}

- (BOOL)isEqualToWidget:(CommonLinksLikeInfo *)likeInfo {
    if (self == likeInfo)
        return YES;
    if ([self likeID] != [likeInfo likeID] && ![(id)[self likeID] isEqual:[likeInfo likeID]])
        return NO;
    return YES;
}

- (NSUInteger)hash {
    return [[self likeID] hash];
}

@end
