#import "DocumentMapController.h"
#import "ScintillaView.h"
#import "Scintilla.h"

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
	[view addSubview:self.mapView];
	self.view = view;
}

- (void)syncFromEditor:(ScintillaView *)editor
{
	if (!editor || !self.mapView) return;
	NSString *text = [editor string];
	if (![[self.mapView string] isEqualToString:text]) {
		[self.mapView setString:text ?: @""];
	}
	long first = [editor getGeneralProperty:SCI_GETFIRSTVISIBLELINE];
	[self.mapView setGeneralProperty:SCI_SETFIRSTVISIBLELINE parameter:0 value:first];
}

@end
