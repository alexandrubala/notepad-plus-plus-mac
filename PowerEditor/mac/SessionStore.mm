#import "SessionStore.h"

static NSString *const kRecentFilesKey = @"NppMacRecentFiles";
static NSString *const kSessionPathsKey = @"NppMacSessionPaths";
static const NSUInteger kMaxRecentFiles = 15;

@implementation SessionStore

+ (NSArray<NSString *> *)recentFiles
{
	NSArray *paths = [NSUserDefaults.standardUserDefaults stringArrayForKey:kRecentFilesKey];
	return paths ?: @[];
}

+ (void)addRecentFile:(NSString *)path
{
	if (path.length == 0) return;
	NSMutableArray *paths = [[self recentFiles] mutableCopy];
	[paths removeObject:path];
	[paths insertObject:path atIndex:0];
	while (paths.count > kMaxRecentFiles) {
		[paths removeLastObject];
	}
	[NSUserDefaults.standardUserDefaults setObject:paths forKey:kRecentFilesKey];
}

+ (void)clearRecentFiles
{
	[NSUserDefaults.standardUserDefaults removeObjectForKey:kRecentFilesKey];
}

+ (NSArray<NSString *> *)sessionPaths
{
	NSArray *paths = [NSUserDefaults.standardUserDefaults stringArrayForKey:kSessionPathsKey];
	return paths ?: @[];
}

+ (void)saveSessionPaths:(NSArray<NSString *> *)paths
{
	[NSUserDefaults.standardUserDefaults setObject:(paths ?: @[]) forKey:kSessionPathsKey];
}

@end
