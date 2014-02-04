//
//  JTBConnectionAnimationView.m
//  common links
//
//  Created by Jonathan Backer on 2/2/14.
//  Copyright (c) 2014 JC11Factory. All rights reserved.
//

#import "JTBConnectionAnimationView.h"

#import "JTBAnimationScene.h"

@interface JTBConnectionAnimationView ()

@end


@implementation JTBConnectionAnimationView

- (id)initWithFrame:(CGRect)frame
{
    // loaded from code
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    // loaded from nib
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}

- (void)setup {
    //self.showsFPS = YES;
    //self.showsNodeCount = YES;
    
    if (self.scene == nil) {
        // Create and configure the scene.
        JTBAnimationScene* scene = [JTBAnimationScene sceneWithSize:self.bounds.size];
        scene.backgroundColor = [UIColor whiteColor];
        scene.scaleMode = SKSceneScaleModeResizeFill;
        
        // Present the scene.
        [self presentScene:scene];
    }
}

#pragma mark - Public methods

- (void)resumeAnimationPlayer {
    // resume the animation
    //DebugLog(@"");
    self.scene.paused = NO;
}

- (void)startMoveIn {
    //DebugLog(@"");
    [(JTBAnimationScene*)self.scene startMoveIn];
}

- (void)stopLocal {
    //DebugLog(@"");
    [(JTBAnimationScene*)self.scene stopLocal];
}

- (void)stopRemote {
    //DebugLog(@"");
    [(JTBAnimationScene*)self.scene stopRemote];
}

- (void)endAnimation {
    //DebugLog(@"");
    [(JTBAnimationScene*)self.scene endAnimation];
}

- (void)setLocalFriends:(NSInteger)friendCount artists:(NSInteger)artistCount likes:(NSInteger)likeCount {
    [(JTBAnimationScene*)self.scene setLocalFriends:friendCount artists:artistCount likes:likeCount];
}

- (void)setRemoteFriends:(NSInteger)friendCount artists:(NSInteger)artistCount likes:(NSInteger)likeCount {
    [(JTBAnimationScene*)self.scene setRemoteFriends:friendCount artists:artistCount likes:likeCount];
}

@end
