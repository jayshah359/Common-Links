//
//  JTBConnectionAnimationView.h
//  common links
//
//  Created by Jonathan Backer on 2/2/14.
//  Copyright (c) 2014 JC11Factory. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>

@interface JTBConnectionAnimationView : SKView

// resume animations (in general after being hidden)
- (void)resumeAnimationPlayer;

// set ratio of balls spawned
- (void)setLocalFriends:(NSInteger)friendCount artists:(NSInteger)artistCount likes:(NSInteger)likeCount;
- (void)setRemoteFriends:(NSInteger)friendCount artists:(NSInteger)artistCount likes:(NSInteger)likeCount;

// move states forward
- (void)startMoveIn;
- (void)stopLocal;
- (void)stopRemote;
- (void)endAnimation; // end with balls

@end
