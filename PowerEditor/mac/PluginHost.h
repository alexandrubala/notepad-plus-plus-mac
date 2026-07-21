#pragma once
#import <Cocoa/Cocoa.h>

@interface PluginHost : NSObject
+ (instancetype)sharedHost;
- (void)loadPluginsFromBundle;
- (NSArray<NSDictionary *> *)loadedPlugins;
- (void)showAdminPanel;
@end

// Minimal plugin ABI for macOS .dylib plugins
#ifdef __cplusplus
extern "C" {
#endif
typedef struct NppMacPluginInfo {
	const char *name;
	const char *version;
	const char *author;
} NppMacPluginInfo;

typedef const NppMacPluginInfo *(*NppMacGetInfoFn)(void);
typedef void (*NppMacInitFn)(void);
typedef void (*NppMacCleanupFn)(void);

#define NPP_MAC_PLUGIN_GETINFO "NppMac_GetInfo"
#define NPP_MAC_PLUGIN_INIT "NppMac_Init"
#define NPP_MAC_PLUGIN_CLEANUP "NppMac_Cleanup"
#ifdef __cplusplus
}
#endif
