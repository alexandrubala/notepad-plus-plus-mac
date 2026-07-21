#import "PreferencesController.h"

NSNotificationName const NppMacPreferencesDidChangeNotification = @"NppMacPreferencesDidChangeNotification";

static NSString *const kPrefFontSize = @"NppMacFontSize";
static NSString *const kPrefTabWidth = @"NppMacTabWidth";
static NSString *const kPrefUseTabs = @"NppMacUseTabs";
static NSString *const kPrefWordWrap = @"NppMacWordWrap";
static NSString *const kPrefFontName = @"NppMacFontName";
static NSString *const kPrefRestoreSession = @"NppMacRestoreSession";
static NSString *const kPrefThemeMode = @"NppMacThemeMode";

@implementation PreferencesController {
	NSTextField *_fontSizeField;
	NSTextField *_tabWidthField;
	NSButton *_useTabsCheck;
	NSButton *_wordWrapCheck;
	NSButton *_restoreSessionCheck;
	NSTextField *_fontNameField;
	NSPopUpButton *_themePopup;
}

+ (instancetype)sharedController
{
	static PreferencesController *shared;
	static dispatch_once_t once;
	dispatch_once(&once, ^{
		shared = [[PreferencesController alloc] init];
		[shared loadPreferences];
		[shared applyAppearancePreference];
	});
	return shared;
}

- (instancetype)init
{
	NSWindow *window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 400, 300)
	                                               styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable
	                                                 backing:NSBackingStoreBuffered
	                                                   defer:NO];
	window.title = @"Preferences";
	self = [super initWithWindow:window];
	if (self) {
		_fontSize = 13;
		_tabWidth = 4;
		_useTabs = NO;
		_wordWrap = NO;
		_restoreSessionOnLaunch = YES;
		_themeMode = NppMacThemeSystem;
		_fontName = @"Menlo";
		[self buildUI];
	}
	return self;
}

- (void)buildUI
{
	NSView *content = self.window.contentView;
	NSInteger y = 250;

	[content addSubview:[self label:@"Font name:" frame:NSMakeRect(20, y, 110, 22)]];
	_fontNameField = [[NSTextField alloc] initWithFrame:NSMakeRect(140, y, 230, 24)];
	_fontNameField.stringValue = self.fontName;
	[content addSubview:_fontNameField];
	y -= 36;

	[content addSubview:[self label:@"Font size:" frame:NSMakeRect(20, y, 110, 22)]];
	_fontSizeField = [[NSTextField alloc] initWithFrame:NSMakeRect(140, y, 80, 24)];
	_fontSizeField.stringValue = [NSString stringWithFormat:@"%ld", (long)self.fontSize];
	[content addSubview:_fontSizeField];
	y -= 36;

	[content addSubview:[self label:@"Tab width:" frame:NSMakeRect(20, y, 110, 22)]];
	_tabWidthField = [[NSTextField alloc] initWithFrame:NSMakeRect(140, y, 80, 24)];
	_tabWidthField.stringValue = [NSString stringWithFormat:@"%ld", (long)self.tabWidth];
	[content addSubview:_tabWidthField];
	y -= 36;

	[content addSubview:[self label:@"Theme:" frame:NSMakeRect(20, y, 110, 22)]];
	_themePopup = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(140, y, 160, 26) pullsDown:NO];
	[_themePopup addItemsWithTitles:@[@"System", @"Light", @"Dark"]];
	[_themePopup selectItemAtIndex:self.themeMode];
	[content addSubview:_themePopup];
	y -= 36;

	_useTabsCheck = [[NSButton alloc] initWithFrame:NSMakeRect(140, y, 230, 22)];
	_useTabsCheck.buttonType = NSButtonTypeSwitch;
	_useTabsCheck.title = @"Use tabs instead of spaces";
	_useTabsCheck.state = self.useTabs ? NSControlStateValueOn : NSControlStateValueOff;
	[content addSubview:_useTabsCheck];
	y -= 28;

	_wordWrapCheck = [[NSButton alloc] initWithFrame:NSMakeRect(140, y, 230, 22)];
	_wordWrapCheck.buttonType = NSButtonTypeSwitch;
	_wordWrapCheck.title = @"Word wrap by default";
	_wordWrapCheck.state = self.wordWrap ? NSControlStateValueOn : NSControlStateValueOff;
	[content addSubview:_wordWrapCheck];
	y -= 28;

	_restoreSessionCheck = [[NSButton alloc] initWithFrame:NSMakeRect(140, y, 230, 22)];
	_restoreSessionCheck.buttonType = NSButtonTypeSwitch;
	_restoreSessionCheck.title = @"Restore session on launch";
	_restoreSessionCheck.state = self.restoreSessionOnLaunch ? NSControlStateValueOn : NSControlStateValueOff;
	[content addSubview:_restoreSessionCheck];

	NSButton *save = [[NSButton alloc] initWithFrame:NSMakeRect(270, 16, 100, 28)];
	save.title = @"Save";
	save.bezelStyle = NSBezelStyleRounded;
	save.target = self;
	save.action = @selector(saveClicked:);
	[content addSubview:save];
}

- (NSTextField *)label:(NSString *)text frame:(NSRect)frame
{
	NSTextField *f = [[NSTextField alloc] initWithFrame:frame];
	f.stringValue = text;
	f.editable = NO;
	f.bezeled = NO;
	f.drawsBackground = NO;
	f.alignment = NSTextAlignmentRight;
	return f;
}

- (void)loadPreferences
{
	NSUserDefaults *d = NSUserDefaults.standardUserDefaults;
	if ([d objectForKey:kPrefFontSize]) self.fontSize = [d integerForKey:kPrefFontSize];
	if ([d objectForKey:kPrefTabWidth]) self.tabWidth = [d integerForKey:kPrefTabWidth];
	if ([d objectForKey:kPrefUseTabs]) self.useTabs = [d boolForKey:kPrefUseTabs];
	if ([d objectForKey:kPrefWordWrap]) self.wordWrap = [d boolForKey:kPrefWordWrap];
	if ([d objectForKey:kPrefRestoreSession]) self.restoreSessionOnLaunch = [d boolForKey:kPrefRestoreSession];
	else self.restoreSessionOnLaunch = YES;
	if ([d objectForKey:kPrefThemeMode]) self.themeMode = (NppMacThemeMode)[d integerForKey:kPrefThemeMode];
	NSString *fn = [d stringForKey:kPrefFontName];
	if (fn.length) self.fontName = fn;
}

- (void)savePreferences
{
	NSUserDefaults *d = NSUserDefaults.standardUserDefaults;
	[d setInteger:self.fontSize forKey:kPrefFontSize];
	[d setInteger:self.tabWidth forKey:kPrefTabWidth];
	[d setBool:self.useTabs forKey:kPrefUseTabs];
	[d setBool:self.wordWrap forKey:kPrefWordWrap];
	[d setBool:self.restoreSessionOnLaunch forKey:kPrefRestoreSession];
	[d setInteger:self.themeMode forKey:kPrefThemeMode];
	[d setObject:self.fontName forKey:kPrefFontName];
}

- (void)applyAppearancePreference
{
	switch (self.themeMode) {
	case NppMacThemeLight:
		NSApp.appearance = [NSAppearance appearanceNamed:NSAppearanceNameAqua];
		break;
	case NppMacThemeDark:
		NSApp.appearance = [NSAppearance appearanceNamed:NSAppearanceNameDarkAqua];
		break;
	case NppMacThemeSystem:
	default:
		NSApp.appearance = nil;
		break;
	}
}

- (void)saveClicked:(id)sender
{
	self.fontName = _fontNameField.stringValue.length ? _fontNameField.stringValue : @"Menlo";
	self.fontSize = MAX(9, _fontSizeField.integerValue);
	self.tabWidth = MAX(1, _tabWidthField.integerValue);
	self.useTabs = _useTabsCheck.state == NSControlStateValueOn;
	self.wordWrap = _wordWrapCheck.state == NSControlStateValueOn;
	self.restoreSessionOnLaunch = _restoreSessionCheck.state == NSControlStateValueOn;
	self.themeMode = (NppMacThemeMode)_themePopup.indexOfSelectedItem;
	[self savePreferences];
	[self applyAppearancePreference];
	[[NSNotificationCenter defaultCenter] postNotificationName:NppMacPreferencesDidChangeNotification object:self];
	[self.window close];
}

- (void)showWindow:(id)sender
{
	_fontNameField.stringValue = self.fontName;
	_fontSizeField.stringValue = [NSString stringWithFormat:@"%ld", (long)self.fontSize];
	_tabWidthField.stringValue = [NSString stringWithFormat:@"%ld", (long)self.tabWidth];
	_useTabsCheck.state = self.useTabs ? NSControlStateValueOn : NSControlStateValueOff;
	_wordWrapCheck.state = self.wordWrap ? NSControlStateValueOn : NSControlStateValueOff;
	_restoreSessionCheck.state = self.restoreSessionOnLaunch ? NSControlStateValueOn : NSControlStateValueOff;
	[_themePopup selectItemAtIndex:self.themeMode];
	[super showWindow:sender];
	[self.window center];
}

@end
