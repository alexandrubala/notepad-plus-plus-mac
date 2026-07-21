#pragma once
#import <Foundation/Foundation.h>

@interface UDLManager : NSObject
+ (instancetype)sharedManager;
- (void)ensureUserDataDirectory;
- (NSString *)userDataPath;
@end
