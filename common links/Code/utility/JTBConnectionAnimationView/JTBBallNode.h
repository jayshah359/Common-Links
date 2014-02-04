//
//  JTBBallNode.h
//  common links
//
//  Created by Jonathan Backer on 2/2/14.
//  Copyright (c) 2014 JC11Factory. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

typedef enum {
    JTBNodeFriend = 0,
    JTBNodeArtist,
    JTBNodeLike
    
} JTBNodeType;


@interface JTBBallNode : SKShapeNode

@property (nonatomic) JTBNodeType nodeType;

@end
