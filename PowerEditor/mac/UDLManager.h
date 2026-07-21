#pragma once
#import <Foundation/Foundation.h>

@interface UDLManager : NSObject
+ (instancetype)sharedManager;
- (void)ensureUserDataDirectory;
- (NSString *)userDataPath;
- (NSArray<NSString *> *)availableUDLNames;
- (BOOL)importUDLFromPath:(NSString *)path error:(NSError **)error;
@end
