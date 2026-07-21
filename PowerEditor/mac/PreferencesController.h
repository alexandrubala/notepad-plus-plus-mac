#pragma once
#import <Cocoa/Cocoa.h>

FOUNDATION_EXPORT NSNotificationName const NppMacPreferencesDidChangeNotification;

@interface PreferencesController : NSWindowController
@property (nonatomic, assign) NSInteger fontSize;
@property (nonatomic, assign) NSInteger tabWidth;
@property (nonatomic, assign) BOOL useTabs;
@property (nonatomic, assign) BOOL wordWrap;
@property (nonatomic, copy) NSString *fontName;
+ (instancetype)sharedController;
- (void)loadPreferences;
- (void)savePreferences;
@end
