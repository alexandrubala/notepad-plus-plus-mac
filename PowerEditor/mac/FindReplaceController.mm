#import "FindReplaceController.h"
#import "MainWindowController.h"
#import "EditorDocument.h"
#import "ScintillaView.h"

@implementation FindReplaceController

- (instancetype)init
{
	NSWindow *window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 420, 160)
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
	findLabel.frame = NSMakeRect(20, 120, 60, 22);
	[content addSubview:findLabel];

	self.findField = [[NSTextField alloc] initWithFrame:NSMakeRect(90, 120, 300, 24)];
	[content addSubview:self.findField];

	NSTextField *replLabel = [self label:@"Replace:"];
	replLabel.frame = NSMakeRect(20, 88, 60, 22);
	replLabel.tag = 100;
	[content addSubview:replLabel];

	self.replaceField = [[NSTextField alloc] initWithFrame:NSMakeRect(90, 88, 300, 24)];
	self.replaceField.tag = 101;
	[content addSubview:self.replaceField];

	self.caseCheckbox = [[NSButton alloc] initWithFrame:NSMakeRect(90, 58, 120, 22)];
	self.caseCheckbox.buttonType = NSButtonTypeSwitch;
	self.caseCheckbox.title = @"Match case";
	[content addSubview:self.caseCheckbox];

	self.wordCheckbox = [[NSButton alloc] initWithFrame:NSMakeRect(220, 58, 120, 22)];
	self.wordCheckbox.buttonType = NSButtonTypeSwitch;
	self.wordCheckbox.title = @"Whole word";
	[content addSubview:self.wordCheckbox];

	self.wrapCheckbox = [[NSButton alloc] initWithFrame:NSMakeRect(90, 36, 120, 22)];
	self.wrapCheckbox.buttonType = NSButtonTypeSwitch;
	self.wrapCheckbox.title = @"Wrap around";
	self.wrapCheckbox.state = NSControlStateValueOn;
	[content addSubview:self.wrapCheckbox];

	NSButton *findBtn = [[NSButton alloc] initWithFrame:NSMakeRect(200, 8, 90, 28)];
	findBtn.title = @"Find Next";
	findBtn.bezelStyle = NSBezelStyleRounded;
	findBtn.target = self;
	findBtn.action = @selector(findNext);
	[content addSubview:findBtn];

	NSButton *replBtn = [[NSButton alloc] initWithFrame:NSMakeRect(300, 8, 90, 28)];
	replBtn.title = @"Replace";
	replBtn.bezelStyle = NSBezelStyleRounded;
	replBtn.target = self;
	replBtn.action = @selector(replaceOne:);
	replBtn.tag = 102;
	[content addSubview:replBtn];
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

- (void)showFind
{
	self.window.title = @"Find";
	[[self.window.contentView viewWithTag:100] setHidden:YES];
	[[self.window.contentView viewWithTag:101] setHidden:YES];
	[[self.window.contentView viewWithTag:102] setHidden:YES];
	[self.window makeKeyAndOrderFront:nil];
	[self.window makeFirstResponder:self.findField];
}

- (void)showReplace
{
	self.window.title = @"Replace";
	[[self.window.contentView viewWithTag:100] setHidden:NO];
	[[self.window.contentView viewWithTag:101] setHidden:NO];
	[[self.window.contentView viewWithTag:102] setHidden:NO];
	[self.window makeKeyAndOrderFront:nil];
	[self.window makeFirstResponder:self.findField];
}

- (void)findNext
{
	ScintillaView *editor = [self editor];
	if (!editor) return;
	[editor findAndHighlightText:self.findField.stringValue
	                   matchCase:self.caseCheckbox.state == NSControlStateValueOn
	                   wholeWord:self.wordCheckbox.state == NSControlStateValueOn
	                    scrollTo:YES
	                        wrap:self.wrapCheckbox.state == NSControlStateValueOn
	                   backwards:NO];
}

- (void)findPrevious
{
	ScintillaView *editor = [self editor];
	if (!editor) return;
	[editor findAndHighlightText:self.findField.stringValue
	                   matchCase:self.caseCheckbox.state == NSControlStateValueOn
	                   wholeWord:self.wordCheckbox.state == NSControlStateValueOn
	                    scrollTo:YES
	                        wrap:self.wrapCheckbox.state == NSControlStateValueOn
	                   backwards:YES];
}

- (void)replaceOne:(id)sender
{
	ScintillaView *editor = [self editor];
	if (!editor) return;
	[editor findAndReplaceText:self.findField.stringValue
	                    byText:self.replaceField.stringValue
	                 matchCase:self.caseCheckbox.state == NSControlStateValueOn
	                 wholeWord:self.wordCheckbox.state == NSControlStateValueOn
	                     doAll:NO];
}

@end
