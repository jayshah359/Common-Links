//
//  CommonLinksUserNameInfo.h
//  Common Links
//
//  Created by Jaydev Shah on 10/13/13.
//  Copyright (c) 2013 JC11Factory. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonLinksUserNameInfo : NSObject <NSCoding>

@property (nonatomic, strong) NSString * userName;
@property (readonly, nonatomic) NSString * displayName;
@property (readonly, nonatomic) NSString * displayNameFull;
@property (nonatomic, strong) NSString * firstName;
@property (nonatomic, strong) NSString * lastName;
@property (nonatomic, strong) NSString * userID;

@end
