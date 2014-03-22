#import <Cordova/CDVPlugin.h>

@interface GAPlugin : CDVPlugin
{
}
- (void)initGA:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options;
- (void)sendEvent:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options;
- (void)sendView:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options;
- (void)setCustomDimension:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options;
- (void)setCustomMetric:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options;
- (void)sendTiming:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options;
- (void)sendException:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options;
@end
