#pragma once
#import <Cocoa/Cocoa.h>

FOUNDATION_EXPORT NSNotificationName const NppMacPreferencesDidChangeNotification;

typedef NS_ENUM(NSInteger, NppMacThemeMode) {
	NppMacThemeSystem = 0,
	NppMacThemeLight = 1,
	NppMacThemeDark = 2,
};

@interface PreferencesController : NSWindowController
@property (nonatomic, assign) NSInteger fontSize;
@property (nonatomic, assign) NSInteger tabWidth;
@property (nonatomic, assign) BOOL useTabs;
@property (nonatomic, assign) BOOL wordWrap;
@property (nonatomic, assign) BOOL restoreSessionOnLaunch;
@property (nonatomic, assign) NppMacThemeMode themeMode;
@property (nonatomic, copy) NSString *fontName;
+ (instancetype)sharedController;
- (void)loadPreferences;
- (void)savePreferences;
- (void)applyAppearancePreference;
@end
