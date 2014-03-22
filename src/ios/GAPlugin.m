#import "GAPlugin.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "GAI.h"
#import <Cordova/CDVPluginResult.h>

@implementation GaPlugin


- (void)initGA:(CDVInvokedUrlCommand*)command
{
	NSString *trackingId = [command.arguments objectAtIndex:0];
	int dispatchInterval = [[command.arguments objectAtIndex:1] intValue];
    
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = dispatchInterval;
    
    // Optional: set Logger to VERBOSE for debug information.
    //[[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
    
    // Initialize tracker.
    [[GAI sharedInstance] trackerWithTrackingId:trackingId];
    
    
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[NSString stringWithFormat:@"initGA: accountID = %@; Interval = %d seconds", trackingId, dispatchInterval]] callbackId:command.callbackId];
}


- (void)sendEvent:(CDVInvokedUrlCommand*)command
{
	NSString *category = [command.arguments objectAtIndex:0];
	NSString *eventAction = [command.arguments objectAtIndex:1];
	NSString *eventLabel = [command.arguments objectAtIndex:2];
    NSNumber *eventValue = [command.arguments objectAtIndex:3];
    
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
	if(tracker)
	{
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:category     // Event category (required)
                                                              action:eventAction  // Event action (required)
                                                               label:eventLabel          // Event label
                                                               value:eventValue] build]];    // Event value
        
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[NSString stringWithFormat:@"sendEvent: category = %@; action = %@; label = %@; value = %@", category, eventAction, eventLabel, eventValue]] callbackId:command.callbackId];
	}
	else
	{
        [self.commandDelegate sendPluginResult: [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"sendEvent failed - not initialized"] callbackId:command.callbackId];
	}
}

- (void)sendView:(CDVInvokedUrlCommand*)command
{
	NSString *pageURL = [command.arguments objectAtIndex:0];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
	if(tracker)
	{
        
        // This screen name value will remain set on the tracker and sent with
        // hits until it is set to a new value or to nil.
        [tracker set:pageURL
               value:nil];
        
        [tracker send:[[GAIDictionaryBuilder createAppView] build]];
        
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[NSString stringWithFormat:@"sendView: url = %@", pageURL]] callbackId:command.callbackId];
	}
	else
	{
        [self.commandDelegate sendPluginResult: [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"sendView failed - not initialized"] callbackId:command.callbackId];
	}
}

- (void)setCustomDimension:(CDVInvokedUrlCommand*)command
{
	NSInteger index = [[command.arguments objectAtIndex:0] intValue];
	NSString *value = [command.arguments objectAtIndex:1];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
	if(tracker)
	{
		// May return nil if a tracker has not yet been initialized with a property ID.
        id tracker = [[GAI sharedInstance] defaultTracker];
        
        // Set the custom dimension value on the tracker using its index.
        [tracker set:[GAIFields customDimensionForIndex:index]
               value:value];
        
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[NSString stringWithFormat:@"setCustom: index = %ld, value = %@;", (long)index, value]] callbackId:command.callbackId];
	}
	else
	{
        [self.commandDelegate sendPluginResult: [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"setCustom failed - not initialized"] callbackId:command.callbackId];
	}
}

- (void)setCustomMetric:(CDVInvokedUrlCommand*)command
{
	NSInteger index = [[command.arguments objectAtIndex:0] intValue];
	NSString *value = [command.arguments objectAtIndex:1];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
	if(tracker)
	{
        [tracker set:[GAIFields customMetricForIndex:index]
               value:value];
        
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[NSString stringWithFormat:@"setCustom: index = %ld, value = %@;", (long)index, value]] callbackId:command.callbackId];
	}
	else
	{
        [self.commandDelegate sendPluginResult: [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"setCustom failed - not initialized"] callbackId:command.callbackId];
	}
}

- (void)sendTiming:(CDVInvokedUrlCommand*)command
{
	NSString *category = [command.arguments objectAtIndex:0];
    NSNumber *time = [NSNumber numberWithLong:[[command.arguments objectAtIndex:1] longValue]];
	NSString *name = [command.arguments objectAtIndex:2];
	NSString *label = [command.arguments objectAtIndex:3];
    
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
	if(tracker)
	{
        [tracker send:[[GAIDictionaryBuilder createTimingWithCategory:@"resources"    // Timing category (required)
                                                            interval:time        // Timing interval (required)
                                                                name:@"high scores"  // Timing name
                                                               label:nil] build]];    // Timing label
        
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[NSString stringWithFormat:@"sendTimingWithCategory: category = %@, time = %@, name = %@, label = %@;", category, time, name, label]] callbackId:command.callbackId];
	}
	else
	{
        [self.commandDelegate sendPluginResult: [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"sendTimingWithCategory failed - not initialized"] callbackId:command.callbackId];
	}
}

- (void)sendException:(CDVInvokedUrlCommand*)command
{
	NSString *message = [command.arguments objectAtIndex:0];
	NSNumber *fatal = [command.arguments objectAtIndex:1];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
	if(tracker)
	{
        [tracker send:[[GAIDictionaryBuilder
                       createExceptionWithDescription:message// Exception description. May be truncated to 100 chars.
                       withFatal:fatal] build]];  // isFatal (required). NO indicates non-fatal exception.

        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[NSString stringWithFormat:@"sendException: message = %@;", message]] callbackId:command.callbackId];
	}
	else
	{
        [self.commandDelegate sendPluginResult: [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"sendException failed - not initialized"] callbackId:command.callbackId];
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
