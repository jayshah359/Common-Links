//
//  CommonLinksUserNameInfo.m
//  Common Links
//
//  Created by Jaydev Shah on 10/13/13.
//  Copyright (c) 2013 JC11Factory. All rights reserved.
//

#import "CommonLinksUserNameInfo.h"

@interface CommonLinksUserNameInfo ()

@end

@implementation CommonLinksUserNameInfo

NSString *const userNameKey = @"userNameKey";
NSString *const firstNameKey = @"firstNameKey";
NSString *const lastNameKey = @"lastNameKey";
NSString *const userIDKey = @"userIDKey";

-(NSString *) displayName {
    if ([self.lastName length] < 1)
    {
        if ([self.firstName length] >= 1)
        {
            return self.firstName;
        }
        else
        {
            CFUUIDRef uuidRef = CFUUIDCreate(NULL);
            CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
            CFRelease(uuidRef);
            NSString *uuid = [NSString stringWithString:(__bridge NSString *)
                              uuidStringRef];
            CFRelease(uuidStringRef);
            return uuid;
        }
    }
    else
    {
        return [[[[self.firstName stringByAppendingString:@" "] stringByAppendingString:[self.lastName substringToIndex:1]] stringByAppendingString:@"."] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
}

-(NSString *) displayNameFull {
    if ([self.lastName length] < 1)
    {
        if ([self.firstName length] >= 1)
        {
            return self.firstName;
        }
        else
        {
            CFUUIDRef uuidRef = CFUUIDCreate(NULL);
            CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
            CFRelease(uuidRef);
            NSString *uuid = [NSString stringWithString:(__bridge NSString *)
                              uuidStringRef];
            CFRelease(uuidStringRef);
            return uuid;
        }
    }
    else
    {
        return [[[self.firstName stringByAppendingString:@" "] stringByAppendingString:self.lastName] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.userName = [decoder decodeObjectForKey:userNameKey];
        self.firstName = [decoder decodeObjectForKey:firstNameKey];
        self.lastName = [decoder decodeObjectForKey:lastNameKey];
        self.userID = [decoder decodeObjectForKey:userIDKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.userName forKey:userNameKey];
    [encoder encodeObject:self.firstName forKey:firstNameKey];
    [encoder encodeObject:self.lastName forKey:lastNameKey];
    [encoder encodeObject:self.userID forKey:userIDKey];
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    return [self isEqualToWidget:other];
}

- (BOOL)isEqualToWidget:(CommonLinksUserNameInfo *)userNameInfo {
    if (self == userNameInfo)
        return YES;
    if ([self userID] != [userNameInfo userID] && ![(id)[self userID] isEqual:[userNameInfo userID]])
        return NO;
    return YES;
}

- (NSUInteger)hash {
    return [[self userID] hash];
}

@end
