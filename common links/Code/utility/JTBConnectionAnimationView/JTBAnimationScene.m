//
//  JTBAnimationScene.m
//  common links
//
//  Created by Jonathan Backer on 2/2/14.
//  Copyright (c) 2014 JC11Factory. All rights reserved.
//

#import "JTBAnimationScene.h"

#import <CoreMotion/CoreMotion.h>
#import "JTBMotionManager.h"
#import "JTBBallNode.h"
#import "UIColor+Utilities.h"

#define kAverageEarthGravity 9.81
#define kBallScale 0.3
#define kMaxBalls 100
#define kBallSpawnRate 0.5

typedef enum {
    JTBAnimationStateNone = 0,
    JTBAnimationStateReady,
    JTBAnimationStateMoveIn,
    JTBAnimationStateBoth,
    JTBAnimationStateLocalOnly,
    JTBAnimationStateRemoteOnly,
    JTBAnimationStateMoveOut,
    
} JTBAnimationState;

typedef enum {
    JTBCollisionNone   = 0x1 << 0,
    JTBCollisionFrame  = 0x1 << 1,
    JTBCollisionFriend = 0x1 << 2,
    JTBCollisionArtist = 0x1 << 3,
    JTBCollisionLike   = 0x1 << 4,
    JTBCollisionTemp   = 0x1 << 5,
    
} JTBCollisionCategory;

@interface JTBAnimationScene ()

@property (nonatomic, strong) JTBMotionManager* motionManager;

@property (nonatomic, strong) NSMutableArray* friendNodes;
@property (nonatomic, strong) NSMutableArray* artistNodes;
@property (nonatomic, strong) NSMutableArray* likeNodes;

@property (nonatomic, strong) NSMutableArray* friendTempNodes;
@property (nonatomic, strong) NSMutableArray* artistTempNodes;
@property (nonatomic, strong) NSMutableArray* likeTempNodes;

@property (nonatomic) BOOL useTempNodes;

@property (nonatomic) NSInteger localFriendCount;
@property (nonatomic) NSInteger localArtistCount;
@property (nonatomic) NSInteger localLikeCount;
@property (nonatomic) NSInteger remoteFriendCount;
@property (nonatomic) NSInteger remoteArtistCount;
@property (nonatomic) NSInteger remoteLikeCount;

@property (nonatomic, strong) SKSpriteNode* localPhoneNode;
@property (nonatomic, strong) SKSpriteNode* remotePhoneNode;
@property (nonatomic, strong) SKSpriteNode* localBarsNode;
@property (nonatomic, strong) SKSpriteNode* remoteBarsNode;

@property (nonatomic) JTBAnimationState animationState;
@property (nonatomic) JTBAnimationState oldAnimationState;

@property (nonatomic) NSTimeInterval lastLocalBallSpawnedTime;
@property (nonatomic) NSTimeInterval lastRemoteBallSpawnedTime;
@property (nonatomic) NSTimeInterval lastUpdateTime;

@property (nonatomic, strong) SKShapeNode* touchNode;
@property (nonatomic) CGPoint touchPosition;

@end


@implementation JTBAnimationScene

- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        DebugLog(@"Size: %@", NSStringFromCGSize(size));
        
        /* Setup your scene here */
        self.backgroundColor = [UIColor whiteColor];
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];

        // hard-code gravity to "down"
        self.physicsWorld.gravity = CGVectorMake(0, -kAverageEarthGravity);

        // monitor device motion
        self.motionManager = [JTBMotionManager sharedInstance];
        [self.motionManager startMotionUpdates];
        
        // add node storage
        self.friendNodes = [NSMutableArray array];
        self.artistNodes = [NSMutableArray array];
        self.likeNodes = [NSMutableArray array];
        self.friendTempNodes = [NSMutableArray array];
        self.artistTempNodes = [NSMutableArray array];
        self.likeTempNodes = [NSMutableArray array];
        
        // add default count
        self.localFriendCount = 1;
        self.localArtistCount = 1;
        self.localLikeCount = 1;
        self.remoteFriendCount = 1;
        self.remoteArtistCount = 1;
        self.remoteLikeCount = 1;
        
        // setup initial nodes
        if (self.localPhoneNode == nil) {
            self.localPhoneNode = [SKSpriteNode spriteNodeWithImageNamed:@"LocalPhone"];
            self.remotePhoneNode = [SKSpriteNode spriteNodeWithImageNamed:@"RemotePhone"];
            
            [self addChild:self.localPhoneNode];
            [self addChild:self.remotePhoneNode];
        }
        
        self.localPhoneNode.position = CGPointMake(self.frame.size.width *  -0.5, self.frame.size.height / 2);
        self.remotePhoneNode.position = CGPointMake(self.frame.size.width * 1.5, self.frame.size.height / 2);
        
        self.animationState = JTBAnimationStateReady;
        self.oldAnimationState = JTBAnimationStateNone;

    }
    return self;
}

#pragma mark - Scene Update Methods

- (void)update:(NSTimeInterval)currentTime {
    /* Best place to process user input from touch-screen or accelerometer */
    /* Best place to process network data, enemy AI, game logic, etc */
    
    // calculate performance (in FPS)
    CGFloat fps = 0.0;
    if (self.lastUpdateTime > 0) {
        fps = 1.0 / (currentTime - self.lastUpdateTime);
        if (fps < 30.0 || [self realNodeCount] > kMaxBalls) {
            self.useTempNodes = YES;
        } else {
            self.useTempNodes = NO;
        }
    }
    self.lastUpdateTime = currentTime;
    
#if TARGET_IPHONE_SIMULATOR
    // hard-code gravity to "down"
    self.physicsWorld.gravity = CGVectorMake(0, -kAverageEarthGravity);
#else
    // alter physics gravity based on device tilt
    CMAcceleration gravity = [self.motionManager gravityWithMinimumValue:0.01 withPostMultiplier:kAverageEarthGravity];
    self.physicsWorld.gravity = CGVectorMake(gravity.x, gravity.y);
#endif

    [self addBallState];
    [self handleAnimationState];
    [self checkTempNodesForRemoval];
}

- (void)didEvaluateActions {
    /* Actions have been performed on Sprites */
    /* Adding actions from here on will not be performed until the next update loop */
    
    if (self.touchNode != nil && CGPointEqualToPoint(self.touchPosition, CGPointZero) == NO) {
        // pull body towards touch
        CGVector force = CGVectorMake((self.touchPosition.x - self.touchNode.position.x),
                                      (self.touchPosition.y - self.touchNode.position.y));
        [self.touchNode.physicsBody applyImpulse:force];
    }
}

- (void)didSimulatePhysics {
    /* Physics have been performed on Sprites */
    /* Physics changes from here on will not be performed until the next update loop */
    /* All Sprites are now in final render positions */
    
}

#pragma mark - Inputs

- (void)setLocalFriends:(NSInteger)friendCount artists:(NSInteger)artistCount likes:(NSInteger)likeCount {
    if (friendCount < 1) {
        self.localFriendCount = 1;
    } else {
        self.localFriendCount = friendCount;
    }
    
    if (artistCount < 1) {
        self.localArtistCount = 1;
    } else {
        self.localArtistCount = artistCount;
    }
    
    if (likeCount < 1) {
        self.localLikeCount = 1;
    } else {
        self.localLikeCount = likeCount;
    }
}

- (void)setRemoteFriends:(NSInteger)friendCount artists:(NSInteger)artistCount likes:(NSInteger)likeCount {
    if (friendCount < 1) {
        self.remoteFriendCount = 1;
    } else {
        self.remoteFriendCount = friendCount;
    }
    
    if (artistCount < 1) {
        self.remoteArtistCount = 1;
    } else {
        self.remoteArtistCount = artistCount;
    }
    
    if (likeCount < 1) {
        self.remoteLikeCount = 1;
    } else {
        self.remoteLikeCount = likeCount;
    }
}

- (void)startMoveIn {
    if (self.animationState == JTBAnimationStateReady) {
        self.animationState = JTBAnimationStateMoveIn;
    }
}

- (void)stopLocal {
    if (self.animationState == JTBAnimationStateBoth) {
        self.animationState = JTBAnimationStateRemoteOnly;
    } else if (self.animationState == JTBAnimationStateLocalOnly) {
        self.animationState = JTBAnimationStateMoveOut;
    }
}

- (void)stopRemote {
    if (self.animationState == JTBAnimationStateBoth) {
        self.animationState = JTBAnimationStateLocalOnly;
    } else if (self.animationState == JTBAnimationStateRemoteOnly) {
        self.animationState = JTBAnimationStateMoveOut;
    }
}

- (void)endAnimation {
    if (self.animationState != JTBAnimationStateNone && self.animationState != JTBAnimationStateReady) {
        self.animationState = JTBAnimationStateMoveOut;
    }
}

#pragma mark - Animation States

- (void)addBallState {
    switch (self.animationState) {
        case JTBAnimationStateNone:
        case JTBAnimationStateReady:
        case JTBAnimationStateMoveIn:
        case JTBAnimationStateMoveOut:
            // do nothing
            break;
            
        case JTBAnimationStateBoth:
            if ([[NSDate date] timeIntervalSince1970] - self.lastLocalBallSpawnedTime > kBallSpawnRate) {
                self.lastLocalBallSpawnedTime = [[NSDate date] timeIntervalSince1970];
                [self addBallAtPosition:self.localBarsNode.position isLocal:YES];
            }
            if ([[NSDate date] timeIntervalSince1970] - self.lastRemoteBallSpawnedTime > kBallSpawnRate) {
                self.lastRemoteBallSpawnedTime = [[NSDate date] timeIntervalSince1970];
                [self addBallAtPosition:self.remoteBarsNode.position isLocal:NO];
            }
            break;
            
        case JTBAnimationStateLocalOnly:
            if ([[NSDate date] timeIntervalSince1970] - self.lastLocalBallSpawnedTime > kBallSpawnRate) {
                self.lastLocalBallSpawnedTime = [[NSDate date] timeIntervalSince1970];
                [self addBallAtPosition:self.localBarsNode.position isLocal:YES];
            }
            break;
            
        case JTBAnimationStateRemoteOnly:
            if ([[NSDate date] timeIntervalSince1970] - self.lastRemoteBallSpawnedTime > kBallSpawnRate) {
                self.lastRemoteBallSpawnedTime = [[NSDate date] timeIntervalSince1970];
                [self addBallAtPosition:self.remoteBarsNode.position isLocal:NO];
            }
            break;
            
    }
}

- (void)handleAnimationState {
    if (self.animationState != self.oldAnimationState) {
        //DebugLog(@"%i", self.animationState);
        JTBAnimationState currentState = self.animationState;
        switch (currentState) {
            case JTBAnimationStateNone:
                // do nothing
                break;
                
            case JTBAnimationStateReady:
                // wait here for input
                break;
                
            case JTBAnimationStateMoveIn:
            {
                [self removeAllNodes];
                
                // addBars will change state to JTBAnimationStateBoth
                SKAction* moveAction = [SKAction sequence:@[[SKAction moveTo:CGPointMake(self.frame.size.width *  0.33, self.frame.size.height / 2) duration:1.0],
                                                            [SKAction performSelector:@selector(addBars) onTarget:self]]];
                [self.localPhoneNode runAction:moveAction];
                
                moveAction = [SKAction moveTo:CGPointMake(self.frame.size.width *  0.67, self.frame.size.height / 2) duration:1.0];
                [self.remotePhoneNode runAction:moveAction];
            }
                break;
                
            case JTBAnimationStateBoth:
                // wait here for input
                break;
                
            case JTBAnimationStateLocalOnly:
                // wait here for input
                break;
                
            case JTBAnimationStateRemoteOnly:
                // wait here for input
                break;
                                
            case JTBAnimationStateMoveOut:
            {
                [self removeBars];
                
                SKAction* moveAction = [SKAction moveTo:CGPointMake(self.frame.size.width *  -0.5, self.frame.size.height / 2) duration:1.0];
                [self.localPhoneNode runAction:moveAction];
                
                moveAction = [SKAction moveTo:CGPointMake(self.frame.size.width *  1.5, self.frame.size.height / 2) duration:1.0];
                [self.remotePhoneNode runAction:moveAction];
                
                self.animationState = JTBAnimationStateReady;
            }
                break;
        }
        self.oldAnimationState = currentState;
    }
}

- (void)addBars {
    if (self.localBarsNode == nil) {
        self.localBarsNode = [SKSpriteNode spriteNodeWithImageNamed:@"LocalTalk"];
        self.remoteBarsNode = [SKSpriteNode spriteNodeWithImageNamed:@"RemoteTalk"];
        self.localBarsNode.alpha = 0.0;
        self.remoteBarsNode.alpha = 0.0;
        self.localBarsNode.position = CGPointMake(self.localPhoneNode.position.x + 40, self.localPhoneNode.position.y);
        self.remoteBarsNode.position = CGPointMake(self.remotePhoneNode.position.x - 40, self.remotePhoneNode.position.y);
        
        [self addChild:self.localBarsNode];
        [self addChild:self.remoteBarsNode];
        
        SKAction* fadeAction = [SKAction sequence:@[[SKAction fadeInWithDuration:1.0],
                                                    [SKAction waitForDuration:1.0],
                                                    [SKAction fadeOutWithDuration:1.0],
                                                    [SKAction waitForDuration:1.0]]];
        fadeAction = [SKAction repeatActionForever:fadeAction];
        [self.localBarsNode runAction:fadeAction];
        
        fadeAction = [SKAction sequence:@[[SKAction waitForDuration:1.0],
                                          [SKAction fadeInWithDuration:1.0],
                                          [SKAction waitForDuration:1.0],
                                          [SKAction fadeOutWithDuration:1.0]]];
        fadeAction = [SKAction repeatActionForever:fadeAction];
        [self.remoteBarsNode runAction:fadeAction];
        
        self.animationState = JTBAnimationStateBoth;
        self.lastRemoteBallSpawnedTime = [[NSDate date] timeIntervalSince1970] - (kBallSpawnRate / 2);
    }
}

- (void)removeBars {
    [self.localBarsNode removeFromParent];
    self.localBarsNode = nil;
    
    [self.remoteBarsNode removeFromParent];
    self.remoteBarsNode = nil;
}

#pragma mark - Create Balls

- (void)addBallAtPosition:(CGPoint)position isLocal:(BOOL)local {
    JTBNodeType nodeType = JTBNodeFriend;
    
    // pick a ball type
    if (local) {
        NSInteger picked = arc4random_uniform(self.localFriendCount + self.localArtistCount + self.localLikeCount);
        if (picked < self.localFriendCount) {
            nodeType = JTBNodeFriend;
        } else if (picked < self.localFriendCount + self.localArtistCount) {
            nodeType = JTBNodeArtist;
        } else if (picked < self.localFriendCount + self.localArtistCount + self.localLikeCount) {
            nodeType = JTBNodeLike;
        }
    } else {
        NSInteger picked = arc4random_uniform(self.remoteFriendCount + self.remoteArtistCount + self.remoteLikeCount);
        if (picked < self.remoteFriendCount) {
            nodeType = JTBNodeFriend;
        } else if (picked < self.remoteFriendCount + self.remoteArtistCount) {
            nodeType = JTBNodeArtist;
        } else if (picked < self.remoteFriendCount + self.remoteArtistCount + self.remoteLikeCount) {
            nodeType = JTBNodeLike;
        }
    }
    
    JTBBallNode* node = [self ballNodeForType:nodeType];
    node.position = position;
    [self addChild:node];
    
    CGFloat dx = 0;
    if (local) {
        dx = -3;
    } else {
        dx = 3;
    }
    CGFloat dy = 6.0;
    [node.physicsBody applyImpulse:CGVectorMake(dx, dy)];
    
    switch (nodeType) {
        case JTBNodeFriend:
            if (self.useTempNodes == NO) {
                [self.friendNodes addObject:node];
                node.physicsBody.categoryBitMask = JTBCollisionFriend;
                node.physicsBody.collisionBitMask = JTBCollisionFrame | JTBCollisionFriend;
            } else {
                [self.friendTempNodes addObject:node];
                node.physicsBody.categoryBitMask = JTBCollisionTemp;
                node.physicsBody.collisionBitMask = JTBCollisionNone;
            }
            break;
            
        case JTBNodeArtist:
            if (self.useTempNodes == NO) {
                [self.artistNodes addObject:node];
                node.physicsBody.categoryBitMask = JTBCollisionArtist;
                node.physicsBody.collisionBitMask = JTBCollisionFrame | JTBCollisionArtist;
            } else {
                [self.friendTempNodes addObject:node];
                node.physicsBody.categoryBitMask = JTBCollisionTemp;
                node.physicsBody.collisionBitMask = JTBCollisionNone;
            }
            break;
            
        case JTBNodeLike:
            if (self.useTempNodes == NO) {
                [self.likeNodes addObject:node];
                node.physicsBody.categoryBitMask =  JTBCollisionLike;
                node.physicsBody.collisionBitMask = JTBCollisionFrame | JTBCollisionLike;
            } else {
                [self.likeTempNodes addObject:node];
                node.physicsBody.categoryBitMask = JTBCollisionTemp;
                node.physicsBody.collisionBitMask = JTBCollisionNone;
            }
            break;
    }
}

- (void)checkTempNodesForRemoval {
    NSMutableArray* removeArray = nil;
    
    CGRect rect = CGRectMake(-20, -20, self.frame.size.width + 20, self.frame.size.height + 20);
    
    removeArray = [NSMutableArray array];
    for (JTBBallNode* node in self.friendTempNodes) {
        if ([[self class] isCoordinates:node.position withinRect:rect] == NO) {
            [removeArray addObject:node];
        }
    }
    if (removeArray.count > 0) {
        [self.friendTempNodes removeObjectsInArray:removeArray];
        [self removeChildrenInArray:removeArray];
    }
    
    
    removeArray = [NSMutableArray array];
    for (JTBBallNode* node in self.artistTempNodes) {
        if ([[self class] isCoordinates:node.position withinRect:rect] == NO) {
            [removeArray addObject:node];
        }
    }
    if (removeArray.count > 0) {
        [self.artistTempNodes removeObjectsInArray:removeArray];
        [self removeChildrenInArray:removeArray];
    }

    
    removeArray = [NSMutableArray array];
    for (JTBBallNode* node in self.likeTempNodes) {
        if ([[self class] isCoordinates:node.position withinRect:rect] == NO) {
            [removeArray addObject:node];
        }
    }
    if (removeArray.count > 0) {
        [self.likeTempNodes removeObjectsInArray:removeArray];
        [self removeChildrenInArray:removeArray];
    }
}

- (void)removeAllNodes {
    [self removeTempNodes];
    [self removeRealNodes];
}

- (void)removeRealNodes {
    [self removeChildrenInArray:self.friendNodes];
    [self.friendNodes removeAllObjects];
    
    [self removeChildrenInArray:self.artistNodes];
    [self.artistNodes removeAllObjects];
    
    [self removeChildrenInArray:self.likeNodes];
    [self.likeNodes removeAllObjects];
}

- (void)removeTempNodes {
    [self removeChildrenInArray:self.friendTempNodes];
    [self.friendTempNodes removeAllObjects];
    
    [self removeChildrenInArray:self.artistTempNodes];
    [self.artistTempNodes removeAllObjects];
    
    [self removeChildrenInArray:self.likeTempNodes];
    [self.likeTempNodes removeAllObjects];
}

- (JTBBallNode *)ballNodeForType:(JTBNodeType)nodeType {
    JTBBallNode* node = nil;
    
    CGFloat radius = [self radiusForType:nodeType];
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddEllipseInRect(path, NULL, CGRectMake(-radius, -radius, radius * 2.0, radius * 2.0));
    
    node = [[JTBBallNode alloc] init];
    node.nodeType = nodeType;
    node.path = path;
    node.fillColor = [self colorForType:nodeType];
    node.strokeColor = nil;
    node.antialiased = YES;
    node.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:radius];
    node.physicsBody.mass = 0.02;
    
    CGPathRelease(path);

    return node;
}

- (UIColor *)colorForType:(JTBNodeType)nodeType {
    UIColor* color = nil;
    
    switch (nodeType) {
        case JTBNodeFriend:
            color = [UIColor colorWithHexString:@"5c76b1" alpha:0.18];
            break;
            
        case JTBNodeArtist:
            color = [UIColor colorWithHexString:@"ee3568" alpha:0.18];
            break;
            
        case JTBNodeLike:
            color = [UIColor colorWithHexString:@"2ac5f4" alpha:0.18];
            break;
    }
    
    return color;
}

- (CGFloat)radiusForType:(JTBNodeType)nodeType {
    CGFloat radius = 0;
    
    switch (nodeType) {
        case JTBNodeFriend:
        case JTBNodeArtist:
        case JTBNodeLike:
        {
            int size = arc4random_uniform(4);
            if (size == 0) {
                radius = 20;
            } else if (size == 2) {
                radius = 28;
            } else if (size == 3) {
                radius = 35;
            } else {
                radius = 52;
            }
            radius = radius * kBallScale;
        }
            break;
    }
    
    return radius;
}

- (NSInteger)realNodeCount {
    return self.friendNodes.count + self.artistNodes.count + self.likeNodes.count;
}

- (NSInteger)tempNodeCount {
    return self.friendTempNodes.count + self.artistTempNodes.count + self.likeTempNodes.count;
}

#pragma mark - Capture User Input

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.touchNode == nil) {
        UITouch* touch = [touches anyObject];
        CGPoint positionInScene = [touch locationInNode:self];
        
        CGFloat radius = 5.0;
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddEllipseInRect(path, NULL, CGRectMake(-radius, -radius, radius * 2.0, radius * 2.0));
        
        SKShapeNode* node = [[SKShapeNode alloc] init];
        node.path = path;
        node.fillColor = nil;//[UIColor lightGrayColor];
        node.strokeColor = nil;
        node.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:radius];
        node.physicsBody.mass = 1.0;
        node.position = positionInScene;
        [self addChild:node];
        
        CGPathRelease(path);
        
        self.touchNode = node;
        self.touchPosition = positionInScene;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.touchNode != nil) {
        UITouch* touch = [touches anyObject];
        CGPoint positionInScene = [touch locationInNode:self];
        self.touchPosition = positionInScene;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.touchNode != nil) {
        [self.touchNode removeFromParent];
        self.touchNode = nil;
        self.touchPosition = CGPointZero;
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.touchNode != nil) {
        [self.touchNode removeFromParent];
        self.touchNode = nil;
        self.touchPosition = CGPointZero;
    }
}


#pragma mark - Math Utility

+ (BOOL)isCoordinates:(CGPoint)coordinates
		   withinRect:(CGRect)rect {
	return (coordinates.x > rect.origin.x &&
			coordinates.y > rect.origin.y &&
			coordinates.x < rect.origin.x + rect.size.width &&
			coordinates.y < rect.origin.y + rect.size.height);
}

@end
