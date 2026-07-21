#import "SessionStore.h"

static NSString *const kRecentFilesKey = @"NppMacRecentFiles";
static NSString *const kSessionEntriesKey = @"NppMacSessionEntries";
static NSString *const kLegacySessionPathsKey = @"NppMacSessionPaths";
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

+ (NSArray<NSDictionary *> *)sessionEntries
{
	NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
	NSArray *entries = [defaults arrayForKey:kSessionEntriesKey];
	if ([entries isKindOfClass:[NSArray class]] && entries.count > 0) {
		return entries;
	}

	// Migrate legacy path-only sessions.
	NSArray *paths = [defaults stringArrayForKey:kLegacySessionPathsKey];
	if (paths.count == 0) return @[];
	NSMutableArray *migrated = [NSMutableArray arrayWithCapacity:paths.count];
	for (NSString *path in paths) {
		[migrated addObject:@{@"path": path, @"caret": @0, @"firstVisibleLine": @0}];
	}
	return migrated;
}

+ (void)saveSessionEntries:(NSArray<NSDictionary *> *)entries
{
	NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
	[defaults setObject:(entries ?: @[]) forKey:kSessionEntriesKey];
	[defaults removeObjectForKey:kLegacySessionPathsKey];
}

@end
