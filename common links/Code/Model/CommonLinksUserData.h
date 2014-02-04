//
//  CommonLinksUserData.h
//  Common Links
//
//  Created by Jaydev Shah on 8/4/13.
//  Copyright (c) 2013 JC11Factory. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonLinksUserNameInfo.h"

@interface CommonLinksUserData : NSObject <NSCoding>

@property (nonatomic, strong) CommonLinksUserNameInfo *userNameInfo;
@property (nonatomic, strong) NSMutableArray *friendList;
@property (nonatomic, strong) NSMutableArray *artistsNames;
@property (nonatomic, strong) NSMutableArray *likeNames;

@property (nonatomic, strong) NSDate* lastRefreshDate;

@end
