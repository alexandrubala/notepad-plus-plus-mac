#import "MainWindowController.h"
#import "EditorDocument.h"
#import "FindReplaceController.h"
#import "DocumentMapController.h"
#import "MacroRecorder.h"
#import "PreferencesController.h"
#import "UDLManager.h"
#import "ScintillaView.h"
#import "Scintilla.h"

@interface MainWindowController () <ScintillaNotificationProtocol>
@property (nonatomic, strong) NSMutableArray<EditorDocument *> *documents;
@property (nonatomic, strong) ScintillaView *splitEditor;
@property (nonatomic, strong) NSView *editorHost;
@property (nonatomic, strong) NSLayoutConstraint *mapWidthConstraint;
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
		_splitEnabled = NO;
		_documentMapVisible = NO;
		window.delegate = self;
		[self buildUI];
		[self newDocument:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
		                                         selector:@selector(appearanceChanged:)
		                                             name:NSApplicationDidChangeScreenParametersNotification
		                                           object:nil];
		[NSApp addObserver:self forKeyPath:@"effectiveAppearance" options:0 context:NULL];
		[[UDLManager sharedManager] ensureUserDataDirectory];
		[NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(updateStatus:) userInfo:nil repeats:YES];
	}
	return self;
}

- (void)dealloc
{
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

- (void)buildUI
{
	NSView *content = self.window.contentView;

	self.statusLabel = [[NSTextField alloc] initWithFrame:NSZeroRect];
	self.statusLabel.editable = NO;
	self.statusLabel.bezeled = NO;
	self.statusLabel.drawsBackground = YES;
	self.statusLabel.backgroundColor = [NSColor windowBackgroundColor];
	self.statusLabel.font = [NSFont monospacedDigitSystemFontOfSize:11 weight:NSFontWeightRegular];
	self.statusLabel.stringValue = @"Ready";
	self.statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
	[content addSubview:self.statusLabel];

	self.tabView = [[NSTabView alloc] initWithFrame:NSZeroRect];
	self.tabView.tabViewType = NSTopTabsBezelBorder;
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
		[self.tabView.topAnchor constraintEqualToAnchor:content.topAnchor constant:0],
		[self.tabView.leadingAnchor constraintEqualToAnchor:content.leadingAnchor],
		[self.tabView.trailingAnchor constraintEqualToAnchor:self.documentMapContainer.leadingAnchor],
		[self.tabView.bottomAnchor constraintEqualToAnchor:self.statusLabel.topAnchor],
		[self.documentMapContainer.topAnchor constraintEqualToAnchor:content.topAnchor],
		[self.documentMapContainer.trailingAnchor constraintEqualToAnchor:content.trailingAnchor],
		[self.documentMapContainer.bottomAnchor constraintEqualToAnchor:self.statusLabel.topAnchor],
		self.mapWidthConstraint,
		[self.statusLabel.leadingAnchor constraintEqualToAnchor:content.leadingAnchor constant:8],
		[self.statusLabel.trailingAnchor constraintEqualToAnchor:content.trailingAnchor constant:-8],
		[self.statusLabel.bottomAnchor constraintEqualToAnchor:content.bottomAnchor constant:-2],
		[self.statusLabel.heightAnchor constraintEqualToConstant:22],
	]];
}

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
	item.label = doc.displayName;
	NSView *host = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 800, 600)];
	doc.editor.frame = host.bounds;
	doc.editor.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
	[host addSubview:doc.editor];
	item.view = host;
	doc.editor.delegate = self;
	[self.tabView addTabViewItem:item];
	[self.tabView selectTabViewItem:item];
	[self updateWindowTitle];
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
	// Reuse existing tab if open
	for (NSInteger i = 0; i < (NSInteger)self.documents.count; i++) {
		EditorDocument *d = self.documents[i];
		if ([d.filePath isEqualToString:path]) {
			[self.tabView selectTabViewItemAtIndex:i];
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
}

- (void)saveDocument:(id)sender
{
	EditorDocument *doc = [self currentDocument];
	if (!doc) return;
	if (!doc.filePath) {
		[self saveDocumentAs:sender];
		return;
	}
	NSError *error = nil;
	if (![doc saveToPath:doc.filePath error:&error]) {
		NSAlert *alert = [[NSAlert alloc] init];
		alert.messageText = @"Could not save file";
		alert.informativeText = error.localizedDescription;
		[alert runModal];
		return;
	}
	[self updateTabLabels];
}

- (void)saveDocumentAs:(id)sender
{
	EditorDocument *doc = [self currentDocument];
	if (!doc) return;
	NSSavePanel *panel = [NSSavePanel savePanel];
	panel.nameFieldStringValue = doc.displayName ?: @"Untitled.txt";
	if ([panel runModal] == NSModalResponseOK) {
		NSError *error = nil;
		if (![doc saveToPath:panel.URL.path error:&error]) {
			NSAlert *alert = [[NSAlert alloc] init];
			alert.messageText = @"Could not save file";
			alert.informativeText = error.localizedDescription;
			[alert runModal];
			return;
		}
		[self updateTabLabels];
		[self updateWindowTitle];
	}
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
		return !doc.dirty || doc.filePath != nil;
	}
	if (r == NSAlertSecondButtonReturn) return YES;
	return NO;
}

- (void)closeDocument:(id)sender
{
	EditorDocument *doc = [self currentDocument];
	if (!doc) return;
	if (![self confirmCloseDocument:doc]) return;
	NSInteger idx = [self.documents indexOfObject:doc];
	if (idx == NSNotFound) return;
	[self.tabView removeTabViewItem:[self.tabView tabViewItemAtIndex:idx]];
	[self.documents removeObjectAtIndex:idx];
	if (self.documents.count == 0) {
		[self newDocument:nil];
	}
	[self updateWindowTitle];
}

- (void)updateTabLabels
{
	for (NSInteger i = 0; i < (NSInteger)self.documents.count; i++) {
		EditorDocument *doc = self.documents[i];
		NSTabViewItem *item = [self.tabView tabViewItemAtIndex:i];
		item.label = doc.dirty ? [doc.displayName stringByAppendingString:@" •"] : doc.displayName;
	}
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
	if (doc) {
		self.statusLabel.stringValue = [doc statusText];
		if (self.documentMapVisible) {
			[self.documentMap syncFromEditor:doc.editor];
		}
	}
}

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
	[self updateWindowTitle];
	EditorDocument *doc = [self currentDocument];
	if (doc && self.documentMapVisible) {
		[self.documentMap syncFromEditor:doc.editor];
	}
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
			if (self.macroRecorder.recording && (modType & SC_MOD_INSERTTEXT) && notification->text) {
				NSString *text = [[NSString alloc] initWithBytes:notification->text
				                                          length:notification->length
				                                        encoding:NSUTF8StringEncoding];
				if (text) [self.macroRecorder recordInsertText:text];
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

- (void)toggleSplitView:(id)sender
{
	EditorDocument *doc = [self currentDocument];
	if (!doc) return;
	NSTabViewItem *item = self.tabView.selectedTabViewItem;
	NSView *host = item.view;
	self.splitEnabled = !self.splitEnabled;
	[host setSubviews:@[]];
	if (self.splitEnabled) {
		NSSplitView *split = [[NSSplitView alloc] initWithFrame:host.bounds];
		split.vertical = YES;
		split.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
		doc.editor.frame = NSMakeRect(0, 0, host.bounds.size.width / 2, host.bounds.size.height);
		self.splitEditor = [[ScintillaView alloc] initWithFrame:doc.editor.frame];
		[self.splitEditor setString:[doc.editor string]];
		[split addSubview:doc.editor];
		[split addSubview:self.splitEditor];
		[host addSubview:split];
		self.splitView = split;
	} else {
		doc.editor.frame = host.bounds;
		[host addSubview:doc.editor];
		self.splitEditor = nil;
		self.splitView = nil;
	}
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

- (BOOL)windowShouldClose:(NSWindow *)sender
{
	for (EditorDocument *doc in [self.documents copy]) {
		NSInteger idx = [self.documents indexOfObject:doc];
		[self.tabView selectTabViewItemAtIndex:idx];
		if (![self confirmCloseDocument:doc]) return NO;
	}
	return YES;
}

- (ScintillaView *)activeEditor
{
	return [self currentDocument].editor;
}

@end
