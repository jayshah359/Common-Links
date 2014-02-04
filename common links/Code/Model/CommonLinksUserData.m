//
//  CommonLinksUserData.m
//  Common Links
//
//  Created by Jaydev Shah on 8/4/13.
//  Copyright (c) 2013 JC11Factory. All rights reserved.
//

#import "CommonLinksUserData.h"

@interface CommonLinksUserData ()

@end

@implementation CommonLinksUserData

NSString *const userNameInfoKey = @"userNameInfoKey";
NSString *const friendListKey = @"friendListKey";
NSString *const artistsNamesKey = @"artistsNamesKey";
NSString *const likeNamesKey = @"likeNamesKey";
NSString *const refreshDateKey = @"refreshDateKey";

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.userNameInfo = [decoder decodeObjectForKey:userNameInfoKey];
        self.friendList = [decoder decodeObjectForKey:friendListKey];
        self.artistsNames = [decoder decodeObjectForKey:artistsNamesKey];
        self.likeNames = [decoder decodeObjectForKey:likeNamesKey];
        self.lastRefreshDate = [decoder decodeObjectForKey:refreshDateKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.userNameInfo forKey:userNameInfoKey];
    [encoder encodeObject:self.friendList forKey:friendListKey];
    [encoder encodeObject:self.artistsNames forKey:artistsNamesKey];
    [encoder encodeObject:self.likeNames forKey:likeNamesKey];
    [encoder encodeObject:self.lastRefreshDate forKey:refreshDateKey];
}

@end
