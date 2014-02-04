//
//  JTBStopwatch.h
//  InAppPurchaseTest
//
//  Created by Jonathan Backer on 1/25/14.
//  Copyright (c) 2014 Jonathan Backer. All rights reserved.
//

@interface JTBStopwatch : NSObject

/**
 * @abstract Return a shared instance of the JTBStopwatch object
 */

+ (id)sharedInstance;


/**
 * @abstract Create and Start a new Timer
 *           Resume an existing paused timer
 *
 * @param Name of timer
 */

- (void)startStopwatch:(NSString *)stopwatchName;


/**
 * @abstract Pause an existing running timer
 *
 * @param Name of timer
 */

- (void)pauseStopwatch:(NSString *)stopwatchName;


/**
 * @abstract Reset an existing timer
 *
 * @param Name of timer
 */

- (void)resetStopwatch:(NSString *)stopwatchName;


/**
 * @abstract Current time elapsed on a timer
 *
 * @param Name of timer
 *
 * @return Seconds elapsed
 */

- (NSTimeInterval)timeOnStopwatch:(NSString *)stopwatchName;


/**
 * @abstract Output current time elapsed on a timer to NSLog
 *
 * @param Name of timer
 */

- (void)logStopwatch:(NSString *)stopwatchName;


/**
 * @abstract Output current time elapsed on all existing timers to NSLog
 */

- (void)logAllStopwatches;


/**
 * @abstract Reset all existing timers
 */

- (void)resetAllStopwatches;

@end