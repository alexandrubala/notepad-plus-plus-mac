#pragma once
#import <Cocoa/Cocoa.h>

@interface SessionStore : NSObject
+ (NSArray<NSString *> *)recentFiles;
+ (void)addRecentFile:(NSString *)path;
+ (void)clearRecentFiles;
+ (NSArray<NSString *> *)sessionPaths;
+ (void)saveSessionPaths:(NSArray<NSString *> *)paths;
@end
