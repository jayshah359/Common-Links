//
//  JTBMotionManager.h
//  SpriteKitTest
//
//  Created by Jonathan Backer on 12/23/13.
//  Copyright (c) 2013 Jonathan Backer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>

@interface JTBMotionManager : NSObject

// manage a shared instance on CoreMotion manager
+ (JTBMotionManager *)sharedInstance;

// start/stop monitoring motion
- (void)startMotionUpdates; // use current/default interval
- (void)startMotionUpdatesWithInterval:(NSTimeInterval)interval;
- (void)stopMotionUpdates;

// poll motion (raw)
- (CMDeviceMotion *)deviceMotion;
- (CMAcceleration)gravity;

// poll methods (processed)
- (CMAcceleration)gravityWithMinimumValue:(double)minimum withPostMultiplier:(double)multiplier;

@end
