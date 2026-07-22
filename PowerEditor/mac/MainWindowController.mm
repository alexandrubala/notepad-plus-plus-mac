#import "MainWindowController.h"
#import "DocumentTabBar.h"
#import "EditorDocument.h"
#import "FindReplaceController.h"
#import "DocumentMapController.h"
#import "MacroRecorder.h"
#import "PreferencesController.h"
#import "SessionStore.h"
#import "UDLManager.h"
#import "ScintillaView.h"
#import "Scintilla.h"

static NSString * const kTBNew = @"TBNew";
static NSString * const kTBOpen = @"TBOpen";
static NSString * const kTBSave = @"TBSave";
static NSString * const kTBSaveAll = @"TBSaveAll";
static NSString * const kTBPrint = @"TBPrint";
static NSString * const kTBCut = @"TBCut";
static NSString * const kTBCopy = @"TBCopy";
static NSString * const kTBPaste = @"TBPaste";
static NSString * const kTBUndo = @"TBUndo";
static NSString * const kTBRedo = @"TBRedo";
static NSString * const kTBFind = @"TBFind";
static NSString * const kTBReplace = @"TBReplace";
static NSString * const kTBZoomIn = @"TBZoomIn";
static NSString * const kTBZoomOut = @"TBZoomOut";
static NSString * const kTBWrap = @"TBWrap";
static NSString * const kTBDocMap = @"TBDocMap";
static NSString * const kTBMacroStart = @"TBMacroStart";
static NSString * const kTBMacroStop = @"TBMacroStop";
static NSString * const kTBMacroPlay = @"TBMacroPlay";

@interface MainWindowController () <ScintillaNotificationProtocol, DocumentTabBarDelegate>
@property (nonatomic, strong) NSMutableArray<EditorDocument *> *documents;
@property (nonatomic, strong) NSLayoutConstraint *mapWidthConstraint;
@property (nonatomic, strong) NSButton *statusLengthBtn;
@property (nonatomic, strong) NSButton *statusPosBtn;
@property (nonatomic, strong) NSButton *statusEOLBtn;
@property (nonatomic, strong) NSButton *statusEncodingBtn;
@property (nonatomic, strong) NSButton *statusInsBtn;
@end

@implementation MainWindowController

- (instancetype)init
{
	NSWindow *window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 1100, 720)
	                                               styleMask:NSWindowStyleMaskTitled |
	                                                         NSWindowStyleMaskClosable |
	                                                         NSWindowStyleMaskMiniaturizable |
	                                                         NSWindowStyleMaskResizable
	                                                 backing:NSBackingStoreBuffered
	                                                   defer:NO];
	window.title = @"Notepad++";
	window.minSize = NSMakeSize(500, 300);
	[window center];
	self = [super initWithWindow:window];
	if (self) {
		_documents = [NSMutableArray array];
		_findController = [[FindReplaceController alloc] init];
		_findController.target = self;
		_macroRecorder = [[MacroRecorder alloc] init];
		_documentMap = [[DocumentMapController alloc] init];
		_documentMapVisible = NO;
		window.delegate = self;
		[self buildUI];
		[self buildToolbar];
		[self newDocument:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
		                                         selector:@selector(appearanceChanged:)
		                                             name:NSApplicationDidChangeScreenParametersNotification
		                                           object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
		                                         selector:@selector(preferencesDidChange:)
		                                             name:NppMacPreferencesDidChangeNotification
		                                           object:nil];
		[NSApp addObserver:self forKeyPath:@"effectiveAppearance" options:0 context:NULL];
		[[UDLManager sharedManager] ensureUserDataDirectory];
		[NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(updateStatus:) userInfo:nil repeats:YES];
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	@try { [NSApp removeObserver:self forKeyPath:@"effectiveAppearance"]; } @catch (__unused NSException *e) {}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"effectiveAppearance"]) {
		for (EditorDocument *doc in self.documents) {
			[doc applyTheme];
		}
	}
}

- (void)appearanceChanged:(NSNotification *)n
{
	for (EditorDocument *doc in self.documents) {
		[doc applyTheme];
	}
}

- (void)preferencesDidChange:(NSNotification *)n
{
	for (EditorDocument *doc in self.documents) {
		[doc applyEditorPreferences];
	}
}

- (void)showFindStatus:(NSString *)text
{
	if (text.length == 0) return;
	self.statusPosBtn.title = text;
}

#pragma mark - Status bar helpers

- (NSButton *)makeStatusSegmentWithAction:(SEL)action
{
	NSButton *btn = [NSButton buttonWithTitle:@"" target:self action:action];
	btn.bezelStyle = NSBezelStyleInline;
	btn.bordered = NO;
	btn.font = [NSFont monospacedDigitSystemFontOfSize:11 weight:NSFontWeightRegular];
	btn.alignment = NSTextAlignmentCenter;
	btn.translatesAutoresizingMaskIntoConstraints = NO;
	[btn.heightAnchor constraintEqualToConstant:20].active = YES;
	return btn;
}

- (NSView *)makeStatusSeparator
{
	NSBox *box = [[NSBox alloc] initWithFrame:NSZeroRect];
	box.boxType = NSBoxSeparator;
	box.translatesAutoresizingMaskIntoConstraints = NO;
	[box.widthAnchor constraintEqualToConstant:1].active = YES;
	[box.heightAnchor constraintEqualToConstant:14].active = YES;
	return box;
}

- (void)buildUI
{
	NSView *content = self.window.contentView;

	self.statusLengthBtn = [self makeStatusSegmentWithAction:nil];
	self.statusPosBtn = [self makeStatusSegmentWithAction:nil];
	self.statusEOLBtn = [self makeStatusSegmentWithAction:@selector(statusEOLClicked:)];
	self.statusEncodingBtn = [self makeStatusSegmentWithAction:@selector(statusEncodingClicked:)];
	self.statusInsBtn = [self makeStatusSegmentWithAction:@selector(toggleOvertype:)];

	self.statusStack = [NSStackView stackViewWithViews:@[
		self.statusLengthBtn,
		[self makeStatusSeparator],
		self.statusPosBtn,
		[self makeStatusSeparator],
		self.statusEOLBtn,
		[self makeStatusSeparator],
		self.statusEncodingBtn,
		[self makeStatusSeparator],
		self.statusInsBtn,
	]];
	self.statusStack.orientation = NSUserInterfaceLayoutOrientationHorizontal;
	self.statusStack.alignment = NSLayoutAttributeCenterY;
	self.statusStack.spacing = 6;
	self.statusStack.edgeInsets = NSEdgeInsetsMake(2, 8, 2, 8);
	self.statusStack.translatesAutoresizingMaskIntoConstraints = NO;
	self.statusStack.wantsLayer = YES;
	self.statusStack.layer.backgroundColor = [NSColor windowBackgroundColor].CGColor;
	[content addSubview:self.statusStack];

	self.documentTabBar = [[DocumentTabBar alloc] initWithFrame:NSZeroRect];
	self.documentTabBar.delegate = self;
	self.documentTabBar.translatesAutoresizingMaskIntoConstraints = NO;
	[content addSubview:self.documentTabBar];

	self.tabView = [[NSTabView alloc] initWithFrame:NSZeroRect];
	self.tabView.tabViewType = NSNoTabsNoBorder;
	self.tabView.drawsBackground = NO;
	self.tabView.delegate = self;
	self.tabView.translatesAutoresizingMaskIntoConstraints = NO;
	[content addSubview:self.tabView];

	self.documentMapContainer = [[NSView alloc] initWithFrame:NSZeroRect];
	self.documentMapContainer.translatesAutoresizingMaskIntoConstraints = NO;
	self.documentMapContainer.hidden = YES;
	[content addSubview:self.documentMapContainer];

	NSView *mapView = self.documentMap.view;
	mapView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.documentMapContainer addSubview:mapView];
	[NSLayoutConstraint activateConstraints:@[
		[mapView.topAnchor constraintEqualToAnchor:self.documentMapContainer.topAnchor],
		[mapView.bottomAnchor constraintEqualToAnchor:self.documentMapContainer.bottomAnchor],
		[mapView.leadingAnchor constraintEqualToAnchor:self.documentMapContainer.leadingAnchor],
		[mapView.trailingAnchor constraintEqualToAnchor:self.documentMapContainer.trailingAnchor],
	]];

	self.mapWidthConstraint = [self.documentMapContainer.widthAnchor constraintEqualToConstant:0];
	[NSLayoutConstraint activateConstraints:@[
		[self.documentTabBar.topAnchor constraintEqualToAnchor:content.topAnchor],
		[self.documentTabBar.leadingAnchor constraintEqualToAnchor:content.leadingAnchor],
		[self.documentTabBar.trailingAnchor constraintEqualToAnchor:self.documentMapContainer.leadingAnchor],
		[self.documentTabBar.heightAnchor constraintEqualToConstant:36],
		[self.tabView.topAnchor constraintEqualToAnchor:self.documentTabBar.bottomAnchor constant:6],
		[self.tabView.leadingAnchor constraintEqualToAnchor:content.leadingAnchor constant:6],
		[self.tabView.trailingAnchor constraintEqualToAnchor:self.documentMapContainer.leadingAnchor constant:-6],
		[self.tabView.bottomAnchor constraintEqualToAnchor:self.statusStack.topAnchor constant:-6],
		[self.documentMapContainer.topAnchor constraintEqualToAnchor:content.topAnchor],
		[self.documentMapContainer.trailingAnchor constraintEqualToAnchor:content.trailingAnchor],
		[self.documentMapContainer.bottomAnchor constraintEqualToAnchor:self.statusStack.topAnchor],
		self.mapWidthConstraint,
		[self.statusStack.leadingAnchor constraintEqualToAnchor:content.leadingAnchor],
		[self.statusStack.trailingAnchor constraintEqualToAnchor:content.trailingAnchor],
		[self.statusStack.bottomAnchor constraintEqualToAnchor:content.bottomAnchor],
		[self.statusStack.heightAnchor constraintEqualToConstant:24],
	]];
}

#pragma mark - Toolbar

- (NSToolbarItem *)toolbarItemWithId:(NSString *)itemId
                               label:(NSString *)label
                             symbol:(NSString *)symbol
                             action:(SEL)action
{
	NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemId];
	item.label = label;
	item.paletteLabel = label;
	item.toolTip = label;
	item.target = self;
	item.action = action;
	item.image = [NSImage imageWithSystemSymbolName:symbol accessibilityDescription:label];
	return item;
}

- (void)buildToolbar
{
	NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier:@"NppMacToolbar"];
	toolbar.delegate = self;
	toolbar.displayMode = NSToolbarDisplayModeIconOnly;
	toolbar.allowsUserCustomization = YES;
	toolbar.autosavesConfiguration = YES;
	self.window.toolbar = toolbar;
}

- (NSArray<NSToolbarItemIdentifier> *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar
{
	return @[
		kTBNew, kTBOpen, kTBSave, kTBSaveAll, kTBPrint,
		NSToolbarSpaceItemIdentifier,
		kTBCut, kTBCopy, kTBPaste,
		NSToolbarSpaceItemIdentifier,
		kTBUndo, kTBRedo,
		NSToolbarSpaceItemIdentifier,
		kTBFind, kTBReplace,
		NSToolbarSpaceItemIdentifier,
		kTBZoomIn, kTBZoomOut,
		NSToolbarSpaceItemIdentifier,
		kTBWrap, kTBDocMap,
		NSToolbarSpaceItemIdentifier,
		kTBMacroStart, kTBMacroStop, kTBMacroPlay,
		NSToolbarFlexibleSpaceItemIdentifier,
	];
}

- (NSArray<NSToolbarItemIdentifier> *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
{
	return [self toolbarDefaultItemIdentifiers:toolbar];
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSToolbarItemIdentifier)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag
{
	if ([itemIdentifier isEqualToString:kTBNew])
		return [self toolbarItemWithId:kTBNew label:@"New" symbol:@"doc.badge.plus" action:@selector(newDocument:)];
	if ([itemIdentifier isEqualToString:kTBOpen])
		return [self toolbarItemWithId:kTBOpen label:@"Open" symbol:@"folder" action:@selector(openDocument:)];
	if ([itemIdentifier isEqualToString:kTBSave])
		return [self toolbarItemWithId:kTBSave label:@"Save" symbol:@"square.and.arrow.down" action:@selector(saveDocument:)];
	if ([itemIdentifier isEqualToString:kTBSaveAll])
		return [self toolbarItemWithId:kTBSaveAll label:@"Save All" symbol:@"square.and.arrow.down.on.square" action:@selector(saveAllDocuments:)];
	if ([itemIdentifier isEqualToString:kTBPrint])
		return [self toolbarItemWithId:kTBPrint label:@"Print" symbol:@"printer" action:@selector(printDocument:)];
	if ([itemIdentifier isEqualToString:kTBCut])
		return [self toolbarItemWithId:kTBCut label:@"Cut" symbol:@"scissors" action:@selector(cut:)];
	if ([itemIdentifier isEqualToString:kTBCopy])
		return [self toolbarItemWithId:kTBCopy label:@"Copy" symbol:@"doc.on.doc" action:@selector(copy:)];
	if ([itemIdentifier isEqualToString:kTBPaste])
		return [self toolbarItemWithId:kTBPaste label:@"Paste" symbol:@"doc.on.clipboard" action:@selector(paste:)];
	if ([itemIdentifier isEqualToString:kTBUndo])
		return [self toolbarItemWithId:kTBUndo label:@"Undo" symbol:@"arrow.uturn.backward" action:@selector(undo:)];
	if ([itemIdentifier isEqualToString:kTBRedo])
		return [self toolbarItemWithId:kTBRedo label:@"Redo" symbol:@"arrow.uturn.forward" action:@selector(redo:)];
	if ([itemIdentifier isEqualToString:kTBFind])
		return [self toolbarItemWithId:kTBFind label:@"Find" symbol:@"magnifyingglass" action:@selector(showFind:)];
	if ([itemIdentifier isEqualToString:kTBReplace])
		return [self toolbarItemWithId:kTBReplace label:@"Replace" symbol:@"arrow.triangle.2.circlepath" action:@selector(showReplace:)];
	if ([itemIdentifier isEqualToString:kTBZoomIn])
		return [self toolbarItemWithId:kTBZoomIn label:@"Zoom In" symbol:@"plus.magnifyingglass" action:@selector(zoomIn:)];
	if ([itemIdentifier isEqualToString:kTBZoomOut])
		return [self toolbarItemWithId:kTBZoomOut label:@"Zoom Out" symbol:@"minus.magnifyingglass" action:@selector(zoomOut:)];
	if ([itemIdentifier isEqualToString:kTBWrap])
		return [self toolbarItemWithId:kTBWrap label:@"Word Wrap" symbol:@"text.alignleft" action:@selector(toggleWordWrap:)];
	if ([itemIdentifier isEqualToString:kTBDocMap])
		return [self toolbarItemWithId:kTBDocMap label:@"Document Map" symbol:@"sidebar.right" action:@selector(toggleDocumentMap:)];
	if ([itemIdentifier isEqualToString:kTBMacroStart])
		return [self toolbarItemWithId:kTBMacroStart label:@"Start Recording" symbol:@"record.circle" action:@selector(startMacroRecording:)];
	if ([itemIdentifier isEqualToString:kTBMacroStop])
		return [self toolbarItemWithId:kTBMacroStop label:@"Stop Recording" symbol:@"stop.circle" action:@selector(stopMacroRecording:)];
	if ([itemIdentifier isEqualToString:kTBMacroPlay])
		return [self toolbarItemWithId:kTBMacroPlay label:@"Playback Macro" symbol:@"play.circle" action:@selector(playbackMacro:)];
	return nil;
}

#pragma mark - Documents

- (EditorDocument *)currentDocument
{
	NSTabViewItem *item = self.tabView.selectedTabViewItem;
	if (!item) return nil;
	NSInteger idx = [self.tabView indexOfTabViewItem:item];
	if (idx < 0 || idx >= (NSInteger)self.documents.count) return nil;
	return self.documents[idx];
}

- (void)addDocument:(EditorDocument *)doc
{
	[self.documents addObject:doc];
	NSTabViewItem *item = [[NSTabViewItem alloc] initWithIdentifier:doc];
	item.label = [doc tabTitle];
	NSView *host = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 800, 600)];
	doc.editor.frame = host.bounds;
	doc.editor.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
	[host addSubview:doc.editor];
	item.view = host;
	doc.editor.delegate = self;
	[self.tabView addTabViewItem:item];
	[self.tabView selectTabViewItem:item];
	[self reloadDocumentTabBar];
	[self updateWindowTitle];
}

- (void)reloadDocumentTabBar
{
	NSMutableArray<NSString *> *titles = [NSMutableArray arrayWithCapacity:self.documents.count];
	for (EditorDocument *doc in self.documents) {
		[titles addObject:[doc tabTitle]];
	}
	NSInteger selected = -1;
	NSTabViewItem *item = self.tabView.selectedTabViewItem;
	if (item) {
		selected = [self.tabView indexOfTabViewItem:item];
	}
	[self.documentTabBar reloadWithTitles:titles selectedIndex:selected];
}

- (void)newDocument:(id)sender
{
	EditorDocument *doc = [[EditorDocument alloc] initWithFrame:NSMakeRect(0, 0, 800, 600)];
	[self addDocument:doc];
}

- (void)openDocument:(id)sender
{
	NSOpenPanel *panel = [NSOpenPanel openPanel];
	panel.allowsMultipleSelection = YES;
	panel.canChooseDirectories = NO;
	if ([panel runModal] == NSModalResponseOK) {
		for (NSURL *url in panel.URLs) {
			[self openPath:url.path];
		}
	}
}

- (void)openPath:(NSString *)path
{
	[self openPath:path caret:NSNotFound firstVisibleLine:NSNotFound];
}

- (void)openPath:(NSString *)path caret:(NSInteger)caret firstVisibleLine:(NSInteger)firstVisibleLine
{
	for (NSInteger i = 0; i < (NSInteger)self.documents.count; i++) {
		EditorDocument *d = self.documents[i];
		if ([d.filePath isEqualToString:path]) {
			[self.tabView selectTabViewItemAtIndex:i];
			[self restoreViewStateForDocument:d caret:caret firstVisibleLine:firstVisibleLine];
			return;
		}
	}
	EditorDocument *doc = [[EditorDocument alloc] initWithFrame:NSMakeRect(0, 0, 800, 600)];
	NSError *error = nil;
	if (![doc loadFromPath:path error:&error]) {
		NSAlert *alert = [[NSAlert alloc] init];
		alert.messageText = @"Could not open file";
		alert.informativeText = error.localizedDescription ?: path;
		[alert runModal];
		return;
	}
	[self addDocument:doc];
	[SessionStore addRecentFile:path];
	[self restoreViewStateForDocument:doc caret:caret firstVisibleLine:firstVisibleLine];
}

- (void)restoreViewStateForDocument:(EditorDocument *)doc caret:(NSInteger)caret firstVisibleLine:(NSInteger)firstVisibleLine
{
	if (!doc.editor) return;
	if (caret != NSNotFound && caret >= 0) {
		[doc.editor setGeneralProperty:SCI_GOTOPOS parameter:0 value:caret];
	}
	if (firstVisibleLine != NSNotFound && firstVisibleLine >= 0) {
		[doc.editor setGeneralProperty:SCI_SETFIRSTVISIBLELINE parameter:0 value:firstVisibleLine];
	}
}

- (BOOL)saveDocument:(id)sender
{
	EditorDocument *doc = [self currentDocument];
	if (!doc) return NO;
	if (!doc.filePath) {
		return [self saveDocumentAs:sender];
	}
	NSError *error = nil;
	if (![doc saveToPath:doc.filePath error:&error]) {
		NSAlert *alert = [[NSAlert alloc] init];
		alert.messageText = @"Could not save file";
		alert.informativeText = error.localizedDescription;
		[alert runModal];
		return NO;
	}
	[SessionStore addRecentFile:doc.filePath];
	[self updateTabLabels];
	return YES;
}

- (BOOL)saveDocumentAs:(id)sender
{
	EditorDocument *doc = [self currentDocument];
	if (!doc) return NO;
	NSSavePanel *panel = [NSSavePanel savePanel];
	panel.nameFieldStringValue = doc.displayName ?: @"Untitled.txt";
	if ([panel runModal] != NSModalResponseOK) {
		return NO;
	}
	NSError *error = nil;
	if (![doc saveToPath:panel.URL.path error:&error]) {
		NSAlert *alert = [[NSAlert alloc] init];
		alert.messageText = @"Could not save file";
		alert.informativeText = error.localizedDescription;
		[alert runModal];
		return NO;
	}
	[SessionStore addRecentFile:doc.filePath];
	[self updateTabLabels];
	[self updateWindowTitle];
	return YES;
}

- (void)saveAllDocuments:(id)sender
{
	for (NSInteger i = 0; i < (NSInteger)self.documents.count; i++) {
		EditorDocument *doc = self.documents[i];
		if (!doc.dirty) continue;
		[self.tabView selectTabViewItemAtIndex:i];
		if (!doc.filePath) {
			if (![self saveDocumentAs:nil]) return;
		} else {
			NSError *error = nil;
			if (![doc saveToPath:doc.filePath error:&error]) {
				NSAlert *alert = [[NSAlert alloc] init];
				alert.messageText = @"Could not save file";
				alert.informativeText = error.localizedDescription;
				[alert runModal];
				return;
			}
			[SessionStore addRecentFile:doc.filePath];
		}
	}
	[self updateTabLabels];
}

- (BOOL)confirmCloseDocument:(EditorDocument *)doc
{
	if (!doc.dirty) return YES;
	NSAlert *alert = [[NSAlert alloc] init];
	alert.messageText = [NSString stringWithFormat:@"Do you want to save the changes you made to \"%@\"?", doc.displayName];
	alert.informativeText = @"Your changes will be lost if you don’t save them.";
	[alert addButtonWithTitle:@"Save"];
	[alert addButtonWithTitle:@"Don’t Save"];
	[alert addButtonWithTitle:@"Cancel"];
	NSModalResponse r = [alert runModal];
	if (r == NSAlertFirstButtonReturn) {
		[self saveDocument:nil];
		return !doc.dirty;
	}
	if (r == NSAlertSecondButtonReturn) return YES;
	return NO;
}

- (void)closeDocument:(id)sender
{
	EditorDocument *doc = [self currentDocument];
	if (!doc) return;
	NSInteger idx = [self.documents indexOfObject:doc];
	if (idx == NSNotFound) return;
	[self closeDocumentAtIndex:idx];
}

- (void)closeDocumentAtIndex:(NSInteger)idx
{
	if (idx < 0 || idx >= (NSInteger)self.documents.count) return;
	EditorDocument *doc = self.documents[idx];
	[self.tabView selectTabViewItemAtIndex:idx];
	if (![self confirmCloseDocument:doc]) return;
	[self.tabView removeTabViewItem:[self.tabView tabViewItemAtIndex:idx]];
	[self.documents removeObjectAtIndex:idx];
	if (self.documents.count == 0) {
		[self newDocument:nil];
		return;
	}
	[self reloadDocumentTabBar];
	[self updateWindowTitle];
}

- (void)closeAllDocuments:(id)sender
{
	while (self.documents.count > 0) {
		EditorDocument *doc = self.documents[0];
		[self.tabView selectTabViewItemAtIndex:0];
		if (![self confirmCloseDocument:doc]) return;
		[self.tabView removeTabViewItem:[self.tabView tabViewItemAtIndex:0]];
		[self.documents removeObjectAtIndex:0];
	}
	[self newDocument:nil];
}

- (void)printDocument:(id)sender
{
	[[self currentDocument] printDocument];
}

- (void)updateTabLabels
{
	[self reloadDocumentTabBar];
	[self updateWindowTitle];
}

- (void)updateWindowTitle
{
	EditorDocument *doc = [self currentDocument];
	if (!doc) {
		self.window.title = @"Notepad++";
		return;
	}
	NSString *name = doc.filePath ?: doc.displayName;
	self.window.title = [NSString stringWithFormat:@"%@%@ — Notepad++", name, doc.dirty ? @" *" : @""];
}

- (void)updateStatus:(NSTimer *)timer
{
	EditorDocument *doc = [self currentDocument];
	if (!doc) return;
	self.statusLengthBtn.title = [doc lengthStatusText];
	self.statusPosBtn.title = [doc positionStatusText];
	self.statusEOLBtn.title = [doc eolDisplayName];
	self.statusEncodingBtn.title = [doc encodingDisplayName];
	self.statusInsBtn.title = [doc insertModeStatusText];
	if (self.documentMapVisible) {
		[self.documentMap syncFromEditor:doc.editor];
	}
}

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
	[self reloadDocumentTabBar];
	[self updateWindowTitle];
	EditorDocument *doc = [self currentDocument];
	if (doc && self.documentMapVisible) {
		[self.documentMap syncFromEditor:doc.editor];
	}
}

#pragma mark - DocumentTabBarDelegate

- (void)documentTabBar:(DocumentTabBar *)bar didSelectTabAtIndex:(NSInteger)index
{
	if (index < 0 || index >= (NSInteger)self.tabView.numberOfTabViewItems) return;
	[self.tabView selectTabViewItemAtIndex:index];
}

- (void)documentTabBarDidRequestNewTab:(DocumentTabBar *)bar
{
	[self newDocument:nil];
}

- (void)documentTabBar:(DocumentTabBar *)bar didRequestCloseTabAtIndex:(NSInteger)index
{
	[self closeDocumentAtIndex:index];
}

- (void)notification:(SCNotification *)notification
{
	if (!notification) return;
	EditorDocument *doc = [self currentDocument];
	if (!doc) return;
	if (notification->nmhdr.code == SCN_MODIFIED) {
		int modType = notification->modificationType;
		if (modType & (SC_MOD_INSERTTEXT | SC_MOD_DELETETEXT)) {
			doc.dirty = YES;
			[self updateTabLabels];
			if (self.macroRecorder.recording) {
				if ((modType & SC_MOD_INSERTTEXT) && notification->text) {
					NSString *text = [[NSString alloc] initWithBytes:notification->text
					                                          length:notification->length
					                                        encoding:NSUTF8StringEncoding];
					if (text) [self.macroRecorder recordInsertText:text];
				} else if ((modType & SC_MOD_DELETETEXT) && notification->length > 0) {
					[self.macroRecorder recordMessage:SCI_DELETERANGE
					                           wParam:notification->position
					                           lParam:notification->length];
				}
			}
		}
	}
}

#pragma mark - Edit / Search / View actions

- (void)undo:(id)sender { [[self currentDocument].editor message:SCI_UNDO]; }
- (void)redo:(id)sender { [[self currentDocument].editor message:SCI_REDO]; }
- (void)cut:(id)sender { [[self currentDocument].editor message:SCI_CUT]; }
- (void)copy:(id)sender { [[self currentDocument].editor message:SCI_COPY]; }
- (void)paste:(id)sender { [[self currentDocument].editor message:SCI_PASTE]; }
- (void)selectAll:(id)sender { [[self currentDocument].editor message:SCI_SELECTALL]; }

- (void)showFind:(id)sender { [self.findController showFind]; }
- (void)showReplace:(id)sender { [self.findController showReplace]; }
- (void)findNext:(id)sender { [self.findController findNext]; }
- (void)findPrevious:(id)sender { [self.findController findPrevious]; }

- (void)zoomIn:(id)sender { [[self currentDocument] zoomIn]; }
- (void)zoomOut:(id)sender { [[self currentDocument] zoomOut]; }
- (void)zoomReset:(id)sender { [[self currentDocument] zoomReset]; }

- (void)toggleOvertype:(id)sender
{
	[[self currentDocument] toggleOvertype];
	[self updateStatus:nil];
}

- (void)setEncoding:(id)sender
{
	NSMenuItem *item = (NSMenuItem *)sender;
	NSString *name = item.representedObject ?: item.title;
	EditorDocument *doc = [self currentDocument];
	if (!doc || !name) return;

	NSStringEncoding enc = NSUTF8StringEncoding;
	if (![EditorDocument encodingFromName:name encoding:&enc]) return;

	if (doc.filePath) {
		if (doc.dirty) {
			NSAlert *alert = [[NSAlert alloc] init];
			alert.messageText = @"Reload file with new encoding?";
			alert.informativeText = @"Unsaved changes will be lost if you reload from disk.";
			[alert addButtonWithTitle:@"Reload"];
			[alert addButtonWithTitle:@"Cancel"];
			if ([alert runModal] != NSAlertFirstButtonReturn) return;
		}
		NSError *error = nil;
		if (![doc reloadFromDiskWithEncoding:enc error:&error]) {
			NSAlert *alert = [[NSAlert alloc] init];
			alert.messageText = @"Could not reload file";
			alert.informativeText = error.localizedDescription ?: @"Unknown error";
			[alert runModal];
			return;
		}
	} else {
		[doc setEncodingByName:name];
		self.statusPosBtn.title = [NSString stringWithFormat:@"Save encoding: %@", name];
	}
	[self updateTabLabels];
	[self updateStatus:nil];
}

- (void)convertEOL:(id)sender
{
	NSMenuItem *item = (NSMenuItem *)sender;
	NSNumber *modeNum = item.representedObject;
	if (![modeNum isKindOfClass:[NSNumber class]]) return;
	EditorDocument *doc = [self currentDocument];
	if (!doc) return;
	[doc convertToEOLMode:modeNum.intValue];
	[self updateTabLabels];
	[self updateStatus:nil];
}

- (void)statusEOLClicked:(id)sender
{
	NSMenu *menu = [[NSMenu alloc] initWithTitle:@"EOL"];
	NSArray *items = @[
		@[@"Windows (CR LF)", @(SC_EOL_CRLF)],
		@[@"Unix (LF)", @(SC_EOL_LF)],
		@[@"Macintosh (CR)", @(SC_EOL_CR)],
	];
	for (NSArray *pair in items) {
		NSMenuItem *mi = [menu addItemWithTitle:pair[0] action:@selector(convertEOL:) keyEquivalent:@""];
		mi.target = self;
		mi.representedObject = pair[1];
	}
	NSButton *btn = (NSButton *)sender;
	[menu popUpMenuPositioningItem:nil atLocation:NSMakePoint(0, btn.bounds.size.height) inView:btn];
}

- (void)statusEncodingClicked:(id)sender
{
	NSMenu *menu = [[NSMenu alloc] initWithTitle:@"Encoding"];
	for (NSString *name in @[@"UTF-8", @"UTF-16 LE", @"UTF-16 BE", @"ISO-8859-1", @"Windows-1252", @"ASCII"]) {
		NSMenuItem *mi = [menu addItemWithTitle:name action:@selector(setEncoding:) keyEquivalent:@""];
		mi.target = self;
		mi.representedObject = name;
	}
	NSButton *btn = (NSButton *)sender;
	[menu popUpMenuPositioningItem:nil atLocation:NSMakePoint(0, btn.bounds.size.height) inView:btn];
}

- (void)toggleWordWrap:(id)sender
{
	EditorDocument *doc = [self currentDocument];
	if (!doc) return;
	doc.wordWrap = !doc.wordWrap;
	[doc.editor setGeneralProperty:SCI_SETWRAPMODE parameter:0 value:doc.wordWrap ? SC_WRAP_WORD : SC_WRAP_NONE];
}

- (void)toggleLineNumbers:(id)sender
{
	EditorDocument *doc = [self currentDocument];
	if (!doc) return;
	doc.lineNumbersVisible = !doc.lineNumbersVisible;
	[doc.editor setGeneralProperty:SCI_SETMARGINWIDTHN parameter:1 value:doc.lineNumbersVisible ? 48 : 0];
}

- (void)toggleDocumentMap:(id)sender
{
	self.documentMapVisible = !self.documentMapVisible;
	self.documentMapContainer.hidden = !self.documentMapVisible;
	self.mapWidthConstraint.constant = self.documentMapVisible ? 140 : 0;
	if (self.documentMapVisible) {
		[self.documentMap syncFromEditor:[self currentDocument].editor];
	}
	[self.window.contentView layoutSubtreeIfNeeded];
}

- (void)setLanguage:(id)sender
{
	NSMenuItem *item = (NSMenuItem *)sender;
	NSString *name = item.representedObject;
	EditorDocument *doc = [self currentDocument];
	if (!doc || !name) return;
	[doc setLanguage:name];
	[self updateStatus:nil];
}

- (void)startMacroRecording:(id)sender { [self.macroRecorder startRecording]; }
- (void)stopMacroRecording:(id)sender { [self.macroRecorder stopRecording]; }
- (void)playbackMacro:(id)sender { [self.macroRecorder playbackOnEditor:[self currentDocument].editor]; }

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	SEL action = menuItem.action;
	BOOL hasDoc = [self currentDocument] != nil;
	if (action == @selector(undo:) || action == @selector(redo:) ||
	    action == @selector(cut:) || action == @selector(copy:) ||
	    action == @selector(paste:) || action == @selector(selectAll:) ||
	    action == @selector(showFind:) || action == @selector(showReplace:) ||
	    action == @selector(findNext:) || action == @selector(findPrevious:) ||
	    action == @selector(zoomIn:) || action == @selector(zoomOut:) ||
	    action == @selector(zoomReset:) || action == @selector(toggleWordWrap:) ||
	    action == @selector(toggleLineNumbers:) || action == @selector(toggleDocumentMap:) ||
	    action == @selector(setEncoding:) || action == @selector(convertEOL:) ||
	    action == @selector(setLanguage:) || action == @selector(saveDocument:) ||
	    action == @selector(saveDocumentAs:) || action == @selector(printDocument:) ||
	    action == @selector(closeDocument:) || action == @selector(playbackMacro:)) {
		return hasDoc;
	}
	if (action == @selector(saveAllDocuments:) || action == @selector(closeAllDocuments:)) {
		return self.documents.count > 0;
	}
	return YES;
}

- (BOOL)windowShouldClose:(NSWindow *)sender
{
	for (EditorDocument *doc in [self.documents copy]) {
		NSInteger idx = [self.documents indexOfObject:doc];
		[self.tabView selectTabViewItemAtIndex:idx];
		if (![self confirmCloseDocument:doc]) return NO;
	}
	[self persistSession];
	return YES;
}

- (NSArray<NSString *> *)openFilePaths
{
	NSMutableArray *paths = [NSMutableArray array];
	for (EditorDocument *doc in self.documents) {
		if (doc.filePath.length) [paths addObject:doc.filePath];
	}
	return paths;
}

- (void)persistSession
{
	NSMutableArray *entries = [NSMutableArray array];
	for (EditorDocument *doc in self.documents) {
		if (doc.filePath.length == 0) continue;
		long caret = [doc.editor getGeneralProperty:SCI_GETCURRENTPOS];
		long first = [doc.editor getGeneralProperty:SCI_GETFIRSTVISIBLELINE];
		[entries addObject:@{
			@"path": doc.filePath,
			@"caret": @(caret),
			@"firstVisibleLine": @(first),
		}];
	}
	[SessionStore saveSessionEntries:entries];
}

- (void)restoreSessionIfNeeded
{
	if (![PreferencesController sharedController].restoreSessionOnLaunch) return;

	NSArray<NSDictionary *> *entries = [SessionStore sessionEntries];
	if (entries.count == 0) return;

	BOOL hadOnlyBlank = (self.documents.count == 1
	                     && self.documents[0].filePath == nil
	                     && !self.documents[0].dirty
	                     && ([self.documents[0].editor string].length == 0));

	NSUInteger opened = 0;
	for (NSDictionary *entry in entries) {
		NSString *path = entry[@"path"];
		if (![path isKindOfClass:[NSString class]] || path.length == 0) continue;
		if (![[NSFileManager defaultManager] fileExistsAtPath:path]) continue;
		NSInteger caret = [entry[@"caret"] respondsToSelector:@selector(integerValue)] ? [entry[@"caret"] integerValue] : NSNotFound;
		NSInteger first = [entry[@"firstVisibleLine"] respondsToSelector:@selector(integerValue)] ? [entry[@"firstVisibleLine"] integerValue] : NSNotFound;
		[self openPath:path caret:caret firstVisibleLine:first];
		opened++;
	}

	if (opened > 0 && hadOnlyBlank && self.documents.count > 1) {
		EditorDocument *blank = self.documents[0];
		if (blank.filePath == nil && !blank.dirty) {
			[self.tabView removeTabViewItem:[self.tabView tabViewItemAtIndex:0]];
			[self.documents removeObjectAtIndex:0];
			[self reloadDocumentTabBar];
			[self updateWindowTitle];
		}
	}
}

@end
