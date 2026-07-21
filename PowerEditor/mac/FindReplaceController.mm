#import "FindReplaceController.h"
#import "MainWindowController.h"
#import "EditorDocument.h"
#import "ScintillaView.h"

@implementation FindReplaceController

- (instancetype)init
{
	NSWindow *window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 440, 200)
	                                               styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable
	                                                 backing:NSBackingStoreBuffered
	                                                   defer:NO];
	window.title = @"Find";
	self = [super initWithWindow:window];
	if (self) {
		[self buildUI];
	}
	return self;
}

- (void)buildUI
{
	NSView *content = self.window.contentView;

	NSTextField *findLabel = [self label:@"Find:"];
	findLabel.frame = NSMakeRect(20, 158, 60, 22);
	[content addSubview:findLabel];

	self.findField = [[NSTextField alloc] initWithFrame:NSMakeRect(90, 158, 320, 24)];
	[content addSubview:self.findField];

	NSTextField *replLabel = [self label:@"Replace:"];
	replLabel.frame = NSMakeRect(20, 126, 60, 22);
	replLabel.tag = 100;
	[content addSubview:replLabel];

	self.replaceField = [[NSTextField alloc] initWithFrame:NSMakeRect(90, 126, 320, 24)];
	self.replaceField.tag = 101;
	[content addSubview:self.replaceField];

	self.caseCheckbox = [[NSButton alloc] initWithFrame:NSMakeRect(90, 96, 120, 22)];
	self.caseCheckbox.buttonType = NSButtonTypeSwitch;
	self.caseCheckbox.title = @"Match case";
	[content addSubview:self.caseCheckbox];

	self.wordCheckbox = [[NSButton alloc] initWithFrame:NSMakeRect(220, 96, 120, 22)];
	self.wordCheckbox.buttonType = NSButtonTypeSwitch;
	self.wordCheckbox.title = @"Whole word";
	[content addSubview:self.wordCheckbox];

	self.wrapCheckbox = [[NSButton alloc] initWithFrame:NSMakeRect(90, 74, 120, 22)];
	self.wrapCheckbox.buttonType = NSButtonTypeSwitch;
	self.wrapCheckbox.title = @"Wrap around";
	self.wrapCheckbox.state = NSControlStateValueOn;
	[content addSubview:self.wrapCheckbox];

	self.regexCheckbox = [[NSButton alloc] initWithFrame:NSMakeRect(220, 74, 120, 22)];
	self.regexCheckbox.buttonType = NSButtonTypeSwitch;
	self.regexCheckbox.title = @"Regex";
	[content addSubview:self.regexCheckbox];

	self.statusLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(20, 44, 390, 18)];
	self.statusLabel.editable = NO;
	self.statusLabel.bezeled = NO;
	self.statusLabel.drawsBackground = NO;
	self.statusLabel.stringValue = @"";
	self.statusLabel.font = [NSFont systemFontOfSize:11];
	self.statusLabel.textColor = [NSColor secondaryLabelColor];
	[content addSubview:self.statusLabel];

	NSButton *findBtn = [[NSButton alloc] initWithFrame:NSMakeRect(110, 10, 90, 28)];
	findBtn.title = @"Find Next";
	findBtn.bezelStyle = NSBezelStyleRounded;
	findBtn.target = self;
	findBtn.action = @selector(findNext);
	[content addSubview:findBtn];

	NSButton *replBtn = [[NSButton alloc] initWithFrame:NSMakeRect(210, 10, 90, 28)];
	replBtn.title = @"Replace";
	replBtn.bezelStyle = NSBezelStyleRounded;
	replBtn.target = self;
	replBtn.action = @selector(replaceOne:);
	replBtn.tag = 102;
	[content addSubview:replBtn];

	NSButton *replAllBtn = [[NSButton alloc] initWithFrame:NSMakeRect(310, 10, 100, 28)];
	replAllBtn.title = @"Replace All";
	replAllBtn.bezelStyle = NSBezelStyleRounded;
	replAllBtn.target = self;
	replAllBtn.action = @selector(replaceAll:);
	replAllBtn.tag = 103;
	[content addSubview:replAllBtn];
}

- (NSTextField *)label:(NSString *)text
{
	NSTextField *f = [[NSTextField alloc] initWithFrame:NSZeroRect];
	f.stringValue = text;
	f.editable = NO;
	f.bezeled = NO;
	f.drawsBackground = NO;
	f.alignment = NSTextAlignmentRight;
	return f;
}

- (ScintillaView *)editor
{
	MainWindowController *main = (MainWindowController *)self.target;
	return [main currentDocument].editor;
}

- (BOOL)matchCaseOn
{
	return self.caseCheckbox.state == NSControlStateValueOn;
}

- (BOOL)wholeWordOn
{
	return self.wordCheckbox.state == NSControlStateValueOn;
}

- (BOOL)wrapOn
{
	return self.wrapCheckbox.state == NSControlStateValueOn;
}

- (BOOL)regexOn
{
	return self.regexCheckbox.state == NSControlStateValueOn;
}

- (void)setStatus:(NSString *)text
{
	self.statusLabel.stringValue = text ?: @"";
	MainWindowController *main = (MainWindowController *)self.target;
	if ([main respondsToSelector:@selector(showFindStatus:)]) {
		[main showFindStatus:text];
	}
}

- (void)showFind
{
	self.window.title = @"Find";
	[[self.window.contentView viewWithTag:100] setHidden:YES];
	[[self.window.contentView viewWithTag:101] setHidden:YES];
	[[self.window.contentView viewWithTag:102] setHidden:YES];
	[[self.window.contentView viewWithTag:103] setHidden:YES];
	self.statusLabel.stringValue = @"";
	[self.window makeKeyAndOrderFront:nil];
	[self.window makeFirstResponder:self.findField];
}

- (void)showReplace
{
	self.window.title = @"Replace";
	[[self.window.contentView viewWithTag:100] setHidden:NO];
	[[self.window.contentView viewWithTag:101] setHidden:NO];
	[[self.window.contentView viewWithTag:102] setHidden:NO];
	[[self.window.contentView viewWithTag:103] setHidden:NO];
	self.statusLabel.stringValue = @"";
	[self.window makeKeyAndOrderFront:nil];
	[self.window makeFirstResponder:self.findField];
}

- (void)findNext
{
	ScintillaView *editor = [self editor];
	if (!editor) return;
	BOOL found = [editor findAndHighlightText:self.findField.stringValue
	                                matchCase:[self matchCaseOn]
	                                wholeWord:[self wholeWordOn]
	                                 scrollTo:YES
	                                     wrap:[self wrapOn]
	                                backwards:NO
	                                    regex:[self regexOn]];
	[self setStatus:found ? @"Found" : @"Not found"];
}

- (void)findPrevious
{
	ScintillaView *editor = [self editor];
	if (!editor) return;
	BOOL found = [editor findAndHighlightText:self.findField.stringValue
	                                matchCase:[self matchCaseOn]
	                                wholeWord:[self wholeWordOn]
	                                 scrollTo:YES
	                                     wrap:[self wrapOn]
	                                backwards:YES
	                                    regex:[self regexOn]];
	[self setStatus:found ? @"Found" : @"Not found"];
}

- (void)replaceOne:(id)sender
{
	ScintillaView *editor = [self editor];
	if (!editor) return;
	int count = [editor findAndReplaceText:self.findField.stringValue
	                                byText:self.replaceField.stringValue
	                             matchCase:[self matchCaseOn]
	                             wholeWord:[self wholeWordOn]
	                                 doAll:NO
	                                 regex:[self regexOn]];
	[self setStatus:count > 0 ? @"Replaced 1 occurrence" : @"Not found"];
}

- (void)replaceAll:(id)sender
{
	ScintillaView *editor = [self editor];
	if (!editor) return;
	int count = [editor findAndReplaceText:self.findField.stringValue
	                                byText:self.replaceField.stringValue
	                             matchCase:[self matchCaseOn]
	                             wholeWord:[self wholeWordOn]
	                                 doAll:YES
	                                 regex:[self regexOn]];
	if (count == 0) {
		[self setStatus:@"Not found"];
	} else {
		[self setStatus:[NSString stringWithFormat:@"%d replacements", count]];
	}
}

@end
