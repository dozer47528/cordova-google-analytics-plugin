#import "GAPlugin.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "GAI.h"
#import <Cordova/CDVPluginResult.h>

@implementation GAPlugin


- (void)initGA:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options
{
	NSString *callbackId = [arguments pop];
	NSString *trackingId = [arguments objectAtIndex:0];
	int dispatchInterval = [[arguments objectAtIndex:1] intValue];
    
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = dispatchInterval;
    
    // Optional: set Logger to VERBOSE for debug information.
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
    
    // Initialize tracker.
    [[GAI sharedInstance] trackerWithTrackingId:trackingId];
    
	[self successWithMessage:[NSString stringWithFormat:@"initGA: accountID = %@; Interval = %d seconds", trackingId, dispatchInterval] toID:callbackId];
}


- (void)sendEvent:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options
{
	NSString *callbackId = [arguments pop];
	NSString *category = [arguments objectAtIndex:0];
	NSString *eventAction = [arguments objectAtIndex:1];
	NSString *eventLabel = [arguments objectAtIndex:2];
    NSNumber *eventValue = [arguments objectAtIndex:3];
    
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
	if(tracker)
	{
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:category     // Event category (required)
                                                              action:eventAction  // Event action (required)
                                                               label:eventLabel          // Event label
                                                               value:eventValue] build]];    // Event value
        
		[self successWithMessage:[NSString stringWithFormat:@"sendEvent: category = %@; action = %@; label = %@; value = %@", category, eventAction, eventLabel, eventValue] toID:callbackId];
	}
	else
	{
		[self failWithMessage:@"sendEvent failed - not initialized" toID:callbackId withError:nil];
	}
}

- (void)sendView:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options
{
	NSString *callbackId = [arguments pop];
	NSString *pageURL = [arguments objectAtIndex:0];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
	if(tracker)
	{
        
        // This screen name value will remain set on the tracker and sent with
        // hits until it is set to a new value or to nil.
        [tracker set:pageURL
               value:nil];
        
        [tracker send:[[GAIDictionaryBuilder createAppView] build]];
        
		[self successWithMessage:[NSString stringWithFormat:@"sendView: url = %@", pageURL] toID:callbackId];
	}
	else
	{
		[self failWithMessage:@"sendView failed - not initialized" toID:callbackId withError:nil];
	}
}

- (void)setCustomDimension:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options
{
	NSString *callbackId = [arguments pop];
	NSInteger index = [[arguments objectAtIndex:0] intValue];
	NSString *value = [arguments objectAtIndex:1];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
	if(tracker)
	{
		// May return nil if a tracker has not yet been initialized with a property ID.
        id tracker = [[GAI sharedInstance] defaultTracker];
        
        // Set the custom dimension value on the tracker using its index.
        [tracker set:[GAIFields customDimensionForIndex:index]
               value:value];
        
        [self successWithMessage:[NSString stringWithFormat:@"setCustom: index = %ld, value = %@;", (long)index, value] toID:callbackId];
	}
	else
	{
		[self failWithMessage:@"setCustom failed - not initialized" toID:callbackId withError:nil];
	}
}

- (void)setCustomMetric:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options
{
	NSString *callbackId = [arguments pop];
	NSInteger index = [[arguments objectAtIndex:0] intValue];
	NSString *value = [arguments objectAtIndex:1];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
	if(tracker)
	{
        [tracker set:[GAIFields customMetricForIndex:index]
               value:value];
        
		[self successWithMessage:[NSString stringWithFormat:@"setCustom: index = %ld, value = %@;", (long)index, value] toID:callbackId];
	}
	else
	{
		[self failWithMessage:@"setCustom failed - not initialized" toID:callbackId withError:nil];
	}
}

- (void)sendTiming:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options
{
	NSString *callbackId = [arguments pop];
    
	NSString *category = [arguments objectAtIndex:0];
    NSNumber *time = [NSNumber numberWithLong:[[arguments objectAtIndex:1] longValue]];
	NSString *name = [arguments objectAtIndex:2];
	NSString *label = [arguments objectAtIndex:3];
    
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
	if(tracker)
	{
        [tracker send:[[GAIDictionaryBuilder createTimingWithCategory:@"resources"    // Timing category (required)
                                                            interval:time        // Timing interval (required)
                                                                name:@"high scores"  // Timing name
                                                               label:nil] build]];    // Timing label
        
		[self successWithMessage:[NSString stringWithFormat:@"sendTimingWithCategory: category = %@, time = %@, name = %@, label = %@;", category, time, name, label] toID:callbackId];
	}
	else
	{
		[self failWithMessage:@"sendTimingWithCategory failed - not initialized" toID:callbackId withError:nil];
	}
}

- (void)sendException:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options
{
	NSString *callbackId = [arguments pop];
    
	NSString *message = [arguments objectAtIndex:0];
	NSNumber *fatal = [arguments objectAtIndex:1];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
	if(tracker)
	{
        [tracker send:[[GAIDictionaryBuilder
                       createExceptionWithDescription:message// Exception description. May be truncated to 100 chars.
                       withFatal:fatal] build]];  // isFatal (required). NO indicates non-fatal exception.
        [self successWithMessage:[NSString stringWithFormat:@"sendException: message = %@;", message] toID:callbackId];
	}
	else
	{
		[self failWithMessage:@"sendException failed - not initialized" toID:callbackId withError:nil];
	}
}

- (void)successWithMessage:(NSString *)message toID:(NSString *)callbackID
{
	CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:message];
    
	[self writeJavascript:[commandResult toSuccessCallbackString:callbackID]];
}

- (void)failWithMessage:(NSString *)message toID:(NSString *)callbackID withError:(NSError *)error
{
	NSString *errorMessage = (error) ? [NSString stringWithFormat:@"%@ - %@", message, [error localizedDescription]] : message;
	CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:errorMessage];
    
	[self writeJavascript:[commandResult toErrorCallbackString:callbackID]];
}

@end
