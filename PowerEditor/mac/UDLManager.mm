#import "UDLManager.h"

@implementation UDLManager

+ (instancetype)sharedManager
{
	static UDLManager *shared;
	static dispatch_once_t once;
	dispatch_once(&once, ^{ shared = [[UDLManager alloc] init]; });
	return shared;
}

- (NSString *)userDataPath
{
	NSString *home = NSHomeDirectory();
	return [home stringByAppendingPathComponent:@"Library/Application Support/Notepad++"];
}

- (void)ensureUserDataDirectory
{
	NSString *base = [self userDataPath];
	NSString *udl = [base stringByAppendingPathComponent:@"userDefineLangs"];
	NSString *themes = [base stringByAppendingPathComponent:@"themes"];
	NSString *plugins = [base stringByAppendingPathComponent:@"plugins"];
	NSFileManager *fm = NSFileManager.defaultManager;
	[fm createDirectoryAtPath:udl withIntermediateDirectories:YES attributes:nil error:nil];
	[fm createDirectoryAtPath:themes withIntermediateDirectories:YES attributes:nil error:nil];
	[fm createDirectoryAtPath:plugins withIntermediateDirectories:YES attributes:nil error:nil];

	// Seed bundled UDL samples if present
	NSString *bundled = [[NSBundle mainBundle] pathForResource:@"userDefineLangs" ofType:nil];
	if (bundled) {
		NSArray *files = [fm contentsOfDirectoryAtPath:bundled error:nil];
		for (NSString *f in files) {
			NSString *dest = [udl stringByAppendingPathComponent:f];
			if (![fm fileExistsAtPath:dest]) {
				[fm copyItemAtPath:[bundled stringByAppendingPathComponent:f] toPath:dest error:nil];
			}
		}
	}
}

- (NSArray<NSString *> *)availableUDLNames
{
	NSString *udl = [[self userDataPath] stringByAppendingPathComponent:@"userDefineLangs"];
	NSArray *files = [NSFileManager.defaultManager contentsOfDirectoryAtPath:udl error:nil] ?: @[];
	NSMutableArray *names = [NSMutableArray array];
	for (NSString *f in files) {
		if ([f.pathExtension.lowercaseString isEqualToString:@"xml"]) {
			[names addObject:f.stringByDeletingPathExtension];
		}
	}
	return names;
}

- (BOOL)importUDLFromPath:(NSString *)path error:(NSError **)error
{
	NSString *destDir = [[self userDataPath] stringByAppendingPathComponent:@"userDefineLangs"];
	NSString *dest = [destDir stringByAppendingPathComponent:path.lastPathComponent];
	return [NSFileManager.defaultManager copyItemAtPath:path toPath:dest error:error];
}

@end
