//
//  JTBMotionManager.m
//  SpriteKitTest
//
//  Created by Jonathan Backer on 12/23/13.
//  Copyright (c) 2013 Jonathan Backer. All rights reserved.
//

#import "JTBMotionManager.h"

#define kDefaultRefreshRate 1.0/60.0

@interface JTBMotionManager ()

@property (nonatomic, strong) CMMotionManager* motionManager;

@end


@implementation JTBMotionManager

#pragma mark - Create Singleton

+ (JTBMotionManager *)sharedInstance {
    static JTBMotionManager* sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // create singleton
        sharedInstance = [[JTBMotionManager alloc] init];
        
        // create CoreMotion manager
        sharedInstance.motionManager = [[CMMotionManager alloc] init];
        
        // set default update interval
        sharedInstance.motionManager.deviceMotionUpdateInterval = kDefaultRefreshRate;
    });
    return sharedInstance;
}

#pragma mark - Start/Stop Motion Updates

- (void)startMotionUpdates {
    if (self.motionManager.isDeviceMotionAvailable == YES) {
        [self.motionManager startDeviceMotionUpdates];
    }
}

- (void)startMotionUpdatesWithInterval:(NSTimeInterval)interval {
    self.motionManager.deviceMotionUpdateInterval = interval;
    [self startMotionUpdates];
}

- (void)stopMotionUpdates {
    if (self.motionManager.isDeviceMotionAvailable == YES) {
        [self.motionManager stopDeviceMotionUpdates];
    }
}

#pragma mark - Poll Motion (raw)

- (CMDeviceMotion *)deviceMotion {
    CMDeviceMotion* motion = nil;
    
    if (self.motionManager.isDeviceMotionAvailable == YES) {
        motion = [self.motionManager deviceMotion];
    }
    
    return motion;
}

- (CMAcceleration)gravity {
    CMAcceleration gravity;
    
    if (self.motionManager.isDeviceMotionAvailable == YES) {
        CMDeviceMotion* motion = [self.motionManager deviceMotion];
        gravity = motion.gravity;
    }
    
    return gravity;
}

#pragma mark - Poll Motion (processed)

- (CMAcceleration)gravityWithMinimumValue:(double)minimum withPostMultiplier:(double)multiplier {
    CMAcceleration gravity;
    
    if (self.motionManager.isDeviceMotionAvailable == YES) {
        gravity = [self gravity];
        
        if (fabs(gravity.x) < minimum) {
            gravity.x = 0;
        } else {
            gravity.x = gravity.x * multiplier;
        }
        if (fabs(gravity.y) < minimum) {
            gravity.y = 0;
        } else {
            gravity.y = gravity.y * multiplier;
        }
        if (fabs(gravity.z) < minimum) {
            gravity.z = 0;
        } else {
            gravity.z = gravity.z * multiplier;
        }
    }
    
    return gravity;
}

@end
