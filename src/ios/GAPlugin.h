#import <Cordova/CDVPlugin.h>

@interface GaPlugin : CDVPlugin
{
}
- (void)initGA:(CDVInvokedUrlCommand*)command;
- (void)sendEvent:(CDVInvokedUrlCommand*)command;
- (void)sendView:(CDVInvokedUrlCommand*)command;
- (void)setCustomDimension:(CDVInvokedUrlCommand*)command;
- (void)setCustomMetric:(CDVInvokedUrlCommand*)command;
- (void)sendTiming:(CDVInvokedUrlCommand*)command;
- (void)sendException:(CDVInvokedUrlCommand*)command;
@end
