#pragma once
#import <Cocoa/Cocoa.h>

@interface SessionStore : NSObject
+ (NSArray<NSString *> *)recentFiles;
+ (void)addRecentFile:(NSString *)path;
+ (void)clearRecentFiles;
+ (NSArray<NSDictionary *> *)sessionEntries;
+ (void)saveSessionEntries:(NSArray<NSDictionary *> *)entries;
@end
