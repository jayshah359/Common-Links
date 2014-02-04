//
//  JTBStopwatch.m
//  InAppPurchaseTest
//
//  Created by Jonathan Backer on 1/25/14.
//  Copyright (c) 2014 Jonathan Backer. All rights reserved.
//

#import "JTBStopwatch.h"

#define kDefaultStopwatchName @"Default"

@interface JTBStopwatch ()

@property (nonatomic, strong) NSMutableDictionary* timerStartDateDictionary; // NSDate objects (start date when timer is running)
@property (nonatomic, strong) NSMutableDictionary* timerIntervalDictionary;  // NSNumber objects (NSTimeInterval sum of all start-stops)
@property (nonatomic, strong) NSMutableArray* timerOrderingArray;            // NSString objects (keyname of timer in order added)

@end


@implementation JTBStopwatch

#pragma mark - Singleton methods

static JTBStopwatch* singleton = nil;

+ (id)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[JTBStopwatch alloc] init];
    });
    return singleton;
}

#pragma mark - Public methods

- (id)init {
    if ((self = [super init])) {
        // create dictionaries
        self.timerStartDateDictionary = [[NSMutableDictionary alloc] init];
        self.timerIntervalDictionary = [[NSMutableDictionary alloc] init];
        self.timerOrderingArray = [[NSMutableArray alloc] init];
    }
    
    return self;
}

#pragma mark - Stopwatch Control methods

- (void)startStopwatch:(NSString *)stopwatchName {
    stopwatchName = [[self class] stopwatchNameForString:stopwatchName];

    // get stopwatch for name
    NSDate* stopWatchDate = [self.timerStartDateDictionary objectForKey:stopwatchName];
    NSNumber* stopWatchInterval = [self.timerIntervalDictionary objectForKey:stopwatchName];
    
    // is the stopwatch currently running?
    if (stopWatchDate == nil) {
        // no, create it (with now as the start time)
        stopWatchDate = [NSDate date];

        // does stopwatch already exist?
        if (stopWatchInterval == nil) {
            // no, set a default interval
            stopWatchInterval = [NSNumber numberWithDouble:0.0];
            // add to ordering
            [self.timerOrderingArray addObject:stopwatchName];
        }
        
        // add to dictionary
        [self.timerStartDateDictionary setObject:stopWatchDate forKey:stopwatchName];
        [self.timerIntervalDictionary setObject:stopWatchInterval forKey:stopwatchName];
        
    } else {
        // yes, stopwatch is already running
        // ignore
    }
}

- (void)pauseStopwatch:(NSString *)stopwatchName {
    stopwatchName = [[self class] stopwatchNameForString:stopwatchName];
    
    // get stopwatch for name
    NSDate* stopWatchDate = [self.timerStartDateDictionary objectForKey:stopwatchName];
    NSNumber* stopWatchInterval = [self.timerIntervalDictionary objectForKey:stopwatchName];
    
    // is the stopwatch currently running?
    if (stopWatchDate != nil) {
        // yes, calculate time difference
        NSTimeInterval newInterval = [[NSDate date] timeIntervalSinceDate:stopWatchDate];

        // convert current interval
        NSTimeInterval currentInterval = [stopWatchInterval doubleValue];
        
        // add new interval to current, replace current in dictionary
        [self.timerIntervalDictionary setObject:[NSNumber numberWithDouble:currentInterval + newInterval] forKey:stopwatchName];
        
        // timer is no longer running
        [self.timerStartDateDictionary removeObjectForKey:stopwatchName];
        
    } else {
        // no, stopwatch is not running or does not exist
        // ignore
    }
}

- (void)resetStopwatch:(NSString *)stopwatchName {
    stopwatchName = [[self class] stopwatchNameForString:stopwatchName];
    
    // try to remove stopwatch
    [self.timerStartDateDictionary removeObjectForKey:stopwatchName];
    [self.timerIntervalDictionary removeObjectForKey:stopwatchName];
    [self.timerOrderingArray removeObject:stopwatchName];
}

#pragma mark - Stopwatch Output methods

- (NSTimeInterval)timeOnStopwatch:(NSString *)stopwatchName {
    stopwatchName = [[self class] stopwatchNameForString:stopwatchName];
    
    NSTimeInterval currentInterval = 0;
    
    // get stopwatch for name
    NSNumber* stopWatchInterval = [self.timerIntervalDictionary objectForKey:stopwatchName];
    
    // does this stopwatch exist?
    if (stopWatchInterval != nil) {
        // yes, return current time on stopwatch
        currentInterval = [stopWatchInterval doubleValue];
    }
    
    return currentInterval;
}

- (void)logStopwatch:(NSString *)stopwatchName {
    stopwatchName = [[self class] stopwatchNameForString:stopwatchName];
    
    NSString* outputText = nil;
    
    // get stopwatch for name
    NSDate* stopWatchDate = [self.timerStartDateDictionary objectForKey:stopwatchName];
    NSTimeInterval currentInterval = [self timeOnStopwatch:stopwatchName];
    
    // is the stopwatch currently running?
    if (stopWatchDate != nil) {
        outputText = [NSString stringWithFormat:@"%@: %0.2f seconds (running)", stopwatchName, currentInterval];
    } else {
        outputText = [NSString stringWithFormat:@"%@: %0.2f seconds", stopwatchName, currentInterval];
    }
    
    NSLog(@"[Stopwatch] %@: %@", stopwatchName, outputText);
}

#pragma mark - All Timers listener

- (void)logAllStopwatches {
    NSTimeInterval sum = 0.0;
    
    // print out stopwatch times in order added
    for (NSString* stopwatchName in self.timerOrderingArray) {
        // log this stopwatch
        [self logStopwatch:stopwatchName];
        
        // add this stopwatch to sum
        NSTimeInterval currentInterval = [self timeOnStopwatch:stopwatchName];
        sum = sum + currentInterval;
    }
    
    NSLog(@"[Stopwatch] Total: %0.2f seconds", sum);
}

- (void)resetAllStopwatches {
    [self.timerStartDateDictionary removeAllObjects];
    [self.timerIntervalDictionary removeAllObjects];
    [self.timerOrderingArray removeAllObjects];
}

#pragma mark - Utility methods

+ (NSString*)stopwatchNameForString:(NSString *)stopwatchName {
    NSString* name = stopwatchName;
    
    // use default name if none provided
    if (name == nil || name.length == 0) {
       name = kDefaultStopwatchName;
    }
    
    return name;
}

@end
