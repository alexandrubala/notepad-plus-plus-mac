#import "PluginHost.h"
#import "UDLManager.h"
#import <dlfcn.h>

@implementation PluginHost {
	NSMutableArray<NSDictionary *> *_plugins;
	NSMutableArray<NSValue *> *_handles;
}

+ (instancetype)sharedHost
{
	static PluginHost *shared;
	static dispatch_once_t once;
	dispatch_once(&once, ^{ shared = [[PluginHost alloc] init]; });
	return shared;
}

- (instancetype)init
{
	self = [super init];
	if (self) {
		_plugins = [NSMutableArray array];
		_handles = [NSMutableArray array];
	}
	return self;
}

- (void)loadPluginsFromBundle
{
	[[UDLManager sharedManager] ensureUserDataDirectory];
	NSString *userPlugins = [[[UDLManager sharedManager] userDataPath] stringByAppendingPathComponent:@"plugins"];
	NSString *bundledPlugins = [[NSBundle mainBundle] builtInPlugInsPath];
	[self loadPluginsFromDirectory:userPlugins];
	if (bundledPlugins) {
		[self loadPluginsFromDirectory:bundledPlugins];
	}
}

- (void)loadPluginsFromDirectory:(NSString *)dir
{
	NSArray *files = [NSFileManager.defaultManager contentsOfDirectoryAtPath:dir error:nil];
	for (NSString *file in files) {
		if (![file.pathExtension.lowercaseString isEqualToString:@"dylib"]) continue;
		NSString *path = [dir stringByAppendingPathComponent:file];
		void *handle = dlopen(path.fileSystemRepresentation, RTLD_NOW);
		if (!handle) {
			NSLog(@"Plugin load failed %@: %s", path, dlerror());
			continue;
		}
		NppMacGetInfoFn getInfo = (NppMacGetInfoFn)dlsym(handle, NPP_MAC_PLUGIN_GETINFO);
		NppMacInitFn initFn = (NppMacInitFn)dlsym(handle, NPP_MAC_PLUGIN_INIT);
		const NppMacPluginInfo *info = getInfo ? getInfo() : NULL;
		if (initFn) initFn();
		NSDictionary *entry = @{
			@"path": path,
			@"name": info && info->name ? @(info->name) : file,
			@"version": info && info->version ? @(info->version) : @"?",
			@"author": info && info->author ? @(info->author) : @"",
		};
		[_plugins addObject:entry];
		[_handles addObject:[NSValue valueWithPointer:handle]];
	}
}

- (NSArray<NSDictionary *> *)loadedPlugins
{
	return [_plugins copy];
}

- (void)showAdminPanel
{
	NSAlert *alert = [[NSAlert alloc] init];
	alert.messageText = @"Plugin Admin";
	if (_plugins.count == 0) {
		alert.informativeText = [NSString stringWithFormat:
			@"No plugins loaded.\n\nDrop macOS .dylib plugins into:\n%@\n\n"
			@"Expected exports: NppMac_GetInfo, NppMac_Init, NppMac_Cleanup",
			[[[UDLManager sharedManager] userDataPath] stringByAppendingPathComponent:@"plugins"]];
	} else {
		NSMutableString *list = [NSMutableString string];
		for (NSDictionary *p in _plugins) {
			[list appendFormat:@"• %@ %@ (%@)\n", p[@"name"], p[@"version"], p[@"author"]];
		}
		alert.informativeText = list;
	}
	[alert addButtonWithTitle:@"OK"];
	[alert runModal];
}

@end
