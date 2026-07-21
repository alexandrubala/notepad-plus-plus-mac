#import "AppDelegate.h"
#import "MainWindowController.h"
#import "PreferencesController.h"
#import "PluginHost.h"
#import "Scintilla.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
	[self createApplicationMenu];
	[[PluginHost sharedHost] loadPluginsFromBundle];

	self.mainWindowController = [[MainWindowController alloc] init];
	[self.mainWindowController showWindow:nil];
	[NSApp activateIgnoringOtherApps:YES];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
	return YES;
}

- (BOOL)application:(NSApplication *)sender openFile:(NSString *)filename
{
	if (!self.mainWindowController) {
		self.mainWindowController = [[MainWindowController alloc] init];
		[self.mainWindowController showWindow:nil];
	}
	[self.mainWindowController openPath:filename];
	return YES;
}

- (void)createApplicationMenu
{
	NSMenu *menubar = [[NSMenu alloc] init];
	NSMenuItem *appItem = [[NSMenuItem alloc] init];
	[menubar addItem:appItem];

	NSMenu *appMenu = [[NSMenu alloc] initWithTitle:@"Notepad++"];
	[appMenu addItemWithTitle:@"About Notepad++" action:@selector(showAbout:) keyEquivalent:@""];
	[appMenu addItem:[NSMenuItem separatorItem]];
	[appMenu addItemWithTitle:@"Preferences…" action:@selector(showPreferences:) keyEquivalent:@","];
	[appMenu addItem:[NSMenuItem separatorItem]];
	NSMenuItem *quit = [appMenu addItemWithTitle:@"Quit Notepad++" action:@selector(terminate:) keyEquivalent:@"q"];
	quit.target = NSApp;
	[appItem setSubmenu:appMenu];

	NSMenuItem *fileItem = [[NSMenuItem alloc] init];
	[menubar addItem:fileItem];
	NSMenu *fileMenu = [[NSMenu alloc] initWithTitle:@"File"];
	[fileMenu addItemWithTitle:@"New" action:@selector(newDocument:) keyEquivalent:@"n"];
	[fileMenu addItemWithTitle:@"Open…" action:@selector(openDocument:) keyEquivalent:@"o"];
	[fileMenu addItemWithTitle:@"Save" action:@selector(saveDocument:) keyEquivalent:@"s"];
	[fileMenu addItemWithTitle:@"Save As…" action:@selector(saveDocumentAs:) keyEquivalent:@"S"];
	[fileMenu addItemWithTitle:@"Save All" action:@selector(saveAllDocuments:) keyEquivalent:@""];
	[fileMenu addItem:[NSMenuItem separatorItem]];
	[fileMenu addItemWithTitle:@"Print…" action:@selector(printDocument:) keyEquivalent:@"p"];
	[fileMenu addItem:[NSMenuItem separatorItem]];
	[fileMenu addItemWithTitle:@"Close Tab" action:@selector(closeDocument:) keyEquivalent:@"w"];
	[fileMenu addItemWithTitle:@"Close All" action:@selector(closeAllDocuments:) keyEquivalent:@"W"];
	[fileItem setSubmenu:fileMenu];

	NSMenuItem *editItem = [[NSMenuItem alloc] init];
	[menubar addItem:editItem];
	NSMenu *editMenu = [[NSMenu alloc] initWithTitle:@"Edit"];
	[editMenu addItemWithTitle:@"Undo" action:@selector(undo:) keyEquivalent:@"z"];
	[editMenu addItemWithTitle:@"Redo" action:@selector(redo:) keyEquivalent:@"Z"];
	[editMenu addItem:[NSMenuItem separatorItem]];
	[editMenu addItemWithTitle:@"Cut" action:@selector(cut:) keyEquivalent:@"x"];
	[editMenu addItemWithTitle:@"Copy" action:@selector(copy:) keyEquivalent:@"c"];
	[editMenu addItemWithTitle:@"Paste" action:@selector(paste:) keyEquivalent:@"v"];
	[editMenu addItemWithTitle:@"Select All" action:@selector(selectAll:) keyEquivalent:@"a"];
	[editItem setSubmenu:editMenu];

	NSMenuItem *searchItem = [[NSMenuItem alloc] init];
	[menubar addItem:searchItem];
	NSMenu *searchMenu = [[NSMenu alloc] initWithTitle:@"Search"];
	[searchMenu addItemWithTitle:@"Find…" action:@selector(showFind:) keyEquivalent:@"f"];
	[searchMenu addItemWithTitle:@"Find Next" action:@selector(findNext:) keyEquivalent:@"g"];
	[searchMenu addItemWithTitle:@"Find Previous" action:@selector(findPrevious:) keyEquivalent:@"G"];
	[searchMenu addItemWithTitle:@"Replace…" action:@selector(showReplace:) keyEquivalent:@"r"];
	[searchItem setSubmenu:searchMenu];

	NSMenuItem *viewItem = [[NSMenuItem alloc] init];
	[menubar addItem:viewItem];
	NSMenu *viewMenu = [[NSMenu alloc] initWithTitle:@"View"];
	[viewMenu addItemWithTitle:@"Zoom In" action:@selector(zoomIn:) keyEquivalent:@"="];
	[viewMenu addItemWithTitle:@"Zoom Out" action:@selector(zoomOut:) keyEquivalent:@"-"];
	[viewMenu addItemWithTitle:@"Restore Default Zoom" action:@selector(zoomReset:) keyEquivalent:@"0"];
	[viewMenu addItem:[NSMenuItem separatorItem]];
	[viewMenu addItemWithTitle:@"Toggle Word Wrap" action:@selector(toggleWordWrap:) keyEquivalent:@""];
	[viewMenu addItemWithTitle:@"Toggle Line Numbers" action:@selector(toggleLineNumbers:) keyEquivalent:@""];
	[viewMenu addItemWithTitle:@"Toggle Split View" action:@selector(toggleSplitView:) keyEquivalent:@""];
	[viewMenu addItemWithTitle:@"Toggle Document Map" action:@selector(toggleDocumentMap:) keyEquivalent:@""];
	[viewMenu addItem:[NSMenuItem separatorItem]];
	[viewMenu addItemWithTitle:@"Enter Full Screen" action:@selector(toggleFullScreen:) keyEquivalent:@"f"];
	viewMenu.itemArray.lastObject.keyEquivalentModifierMask = NSEventModifierFlagControl | NSEventModifierFlagCommand;
	[viewItem setSubmenu:viewMenu];

	NSMenuItem *encodingItem = [[NSMenuItem alloc] init];
	[menubar addItem:encodingItem];
	NSMenu *encodingMenu = [[NSMenu alloc] initWithTitle:@"Encoding"];
	for (NSString *name in @[@"UTF-8", @"UTF-16 LE", @"UTF-16 BE", @"ISO-8859-1", @"Windows-1252", @"ASCII"]) {
		NSMenuItem *mi = [encodingMenu addItemWithTitle:name action:@selector(setEncoding:) keyEquivalent:@""];
		mi.representedObject = name;
	}
	[encodingItem setSubmenu:encodingMenu];

	NSMenuItem *eolItem = [[NSMenuItem alloc] init];
	[menubar addItem:eolItem];
	NSMenu *eolMenu = [[NSMenu alloc] initWithTitle:@"EOL Conversion"];
	NSArray *eolEntries = @[
		@[@"Windows (CR LF)", @(SC_EOL_CRLF)],
		@[@"Unix (LF)", @(SC_EOL_LF)],
		@[@"Macintosh (CR)", @(SC_EOL_CR)],
	];
	for (NSArray *pair in eolEntries) {
		NSMenuItem *mi = [eolMenu addItemWithTitle:pair[0] action:@selector(convertEOL:) keyEquivalent:@""];
		mi.representedObject = pair[1];
	}
	[eolItem setSubmenu:eolMenu];

	NSMenuItem *langItem = [[NSMenuItem alloc] init];
	[menubar addItem:langItem];
	NSMenu *langMenu = [[NSMenu alloc] initWithTitle:@"Language"];
	NSArray *langs = @[@"None", @"C++", @"C", @"C#", @"Python", @"JavaScript", @"TypeScript",
	                   @"HTML", @"XML", @"CSS", @"JSON", @"Markdown", @"YAML",
	                   @"Java", @"Swift", @"Rust", @"Go", @"Ruby", @"PHP",
	                   @"Shell", @"SQL", @"UDL"];
	for (NSString *name in langs) {
		NSMenuItem *mi = [langMenu addItemWithTitle:name action:@selector(setLanguage:) keyEquivalent:@""];
		mi.representedObject = name;
	}
	[langItem setSubmenu:langMenu];

	NSMenuItem *settingsItem = [[NSMenuItem alloc] init];
	[menubar addItem:settingsItem];
	NSMenu *settingsMenu = [[NSMenu alloc] initWithTitle:@"Settings"];
	[settingsMenu addItemWithTitle:@"Preferences…" action:@selector(showPreferences:) keyEquivalent:@""];
	[settingsMenu addItemWithTitle:@"Plugin Admin…" action:@selector(showPluginAdmin:) keyEquivalent:@""];
	[settingsItem setSubmenu:settingsMenu];

	NSMenuItem *macroItem = [[NSMenuItem alloc] init];
	[menubar addItem:macroItem];
	NSMenu *macroMenu = [[NSMenu alloc] initWithTitle:@"Macro"];
	[macroMenu addItemWithTitle:@"Start Recording" action:@selector(startMacroRecording:) keyEquivalent:@""];
	[macroMenu addItemWithTitle:@"Stop Recording" action:@selector(stopMacroRecording:) keyEquivalent:@""];
	[macroMenu addItemWithTitle:@"Playback" action:@selector(playbackMacro:) keyEquivalent:@""];
	[macroItem setSubmenu:macroMenu];

	NSMenuItem *windowItem = [[NSMenuItem alloc] init];
	[menubar addItem:windowItem];
	NSMenu *windowMenu = [[NSMenu alloc] initWithTitle:@"Window"];
	[windowMenu addItemWithTitle:@"Minimize" action:@selector(performMiniaturize:) keyEquivalent:@"m"];
	[windowMenu addItemWithTitle:@"Zoom" action:@selector(performZoom:) keyEquivalent:@""];
	[windowItem setSubmenu:windowMenu];
	[NSApp setWindowsMenu:windowMenu];

	NSMenuItem *helpItem = [[NSMenuItem alloc] init];
	[menubar addItem:helpItem];
	NSMenu *helpMenu = [[NSMenu alloc] initWithTitle:@"Help"];
	[helpMenu addItemWithTitle:@"Notepad++ for macOS Help" action:@selector(showAbout:) keyEquivalent:@"?"];
	[helpItem setSubmenu:helpMenu];

	[NSApp setMainMenu:menubar];
}

- (void)showAbout:(id)sender
{
	NSAlert *alert = [[NSAlert alloc] init];
	alert.messageText = @"Notepad++ for macOS";
	alert.informativeText = @"Native Apple Silicon port of Notepad++.\n"
	                        @"Scintilla + Lexilla editing engine.\n"
	                        @"GPL-3.0 — based on Notepad++ by Don Ho.";
	[alert addButtonWithTitle:@"OK"];
	[alert runModal];
}

- (void)showPreferences:(id)sender
{
	[[PreferencesController sharedController] showWindow:nil];
}

- (void)showPluginAdmin:(id)sender
{
	[[PluginHost sharedHost] showAdminPanel];
}

@end
