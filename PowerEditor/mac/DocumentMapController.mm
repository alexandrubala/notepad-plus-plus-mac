#import "DocumentMapController.h"
#import "ScintillaView.h"
#import "Scintilla.h"

@interface DocumentMapController () <ScintillaNotificationProtocol>
@property (nonatomic, assign) long lastSyncedLength;
@property (nonatomic, assign) BOOL syncingFromEditor;
@end

@implementation DocumentMapController

- (void)loadView
{
	NSView *view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 140, 600)];
	self.mapView = [[ScintillaView alloc] initWithFrame:view.bounds];
	self.mapView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
	[self.mapView setGeneralProperty:SCI_SETREADONLY parameter:0 value:1];
	[self.mapView setGeneralProperty:SCI_SETZOOM parameter:0 value:-8];
	[self.mapView setGeneralProperty:SCI_SETHSCROLLBAR parameter:0 value:0];
	[self.mapView setGeneralProperty:SCI_SETMARGINWIDTHN parameter:0 value:0];
	[self.mapView setGeneralProperty:SCI_SETMARGINWIDTHN parameter:1 value:0];
	[self.mapView setGeneralProperty:SCI_SETMARGINWIDTHN parameter:2 value:0];
	self.mapView.delegate = self;
	[view addSubview:self.mapView];
	self.view = view;
	self.lastSyncedLength = -1;
}

- (void)syncFromEditor:(ScintillaView *)editor
{
	if (!editor || !self.mapView) return;
	self.linkedEditor = editor;

	long length = [editor getGeneralProperty:SCI_GETLENGTH];
	long first = [editor getGeneralProperty:SCI_GETFIRSTVISIBLELINE];
	self.syncingFromEditor = YES;
	if (length != self.lastSyncedLength) {
		NSString *text = [editor string];
		if (![[self.mapView string] isEqualToString:text]) {
			[self.mapView setGeneralProperty:SCI_SETREADONLY parameter:0 value:0];
			[self.mapView setString:text ?: @""];
			[self.mapView setGeneralProperty:SCI_SETREADONLY parameter:0 value:1];
		}
		self.lastSyncedLength = length;
	}
	[self.mapView setGeneralProperty:SCI_SETFIRSTVISIBLELINE parameter:0 value:first];
	self.syncingFromEditor = NO;
}

- (void)notification:(SCNotification *)notification
{
	if (self.syncingFromEditor || !notification || !self.linkedEditor || !self.mapView) return;
	if (notification->nmhdr.code != SCN_UPDATEUI) return;
	if (!(notification->updated & SC_UPDATE_SELECTION)) return;

	long pos = [self.mapView getGeneralProperty:SCI_GETCURRENTPOS];
	long line = [self.mapView getGeneralProperty:SCI_LINEFROMPOSITION parameter:pos];
	[self.linkedEditor setGeneralProperty:SCI_SETFIRSTVISIBLELINE parameter:0 value:line];
}

@end
