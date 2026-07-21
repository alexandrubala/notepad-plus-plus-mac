#import "MacroRecorder.h"
#import "ScintillaView.h"

@implementation MacroAction
@end

@implementation MacroRecorder

- (instancetype)init
{
	self = [super init];
	if (self) {
		_actions = [NSMutableArray array];
		_recording = NO;
	}
	return self;
}

- (void)startRecording
{
	[self.actions removeAllObjects];
	_recording = YES;
}

- (void)stopRecording
{
	_recording = NO;
}

- (void)recordInsertText:(NSString *)text
{
	if (!_recording || !text.length) return;
	MacroAction *a = [[MacroAction alloc] init];
	a.type = MacroActionInsertText;
	a.text = text;
	[self.actions addObject:a];
}

- (void)recordMessage:(unsigned int)message wParam:(long)wParam lParam:(long)lParam
{
	if (!_recording) return;
	MacroAction *a = [[MacroAction alloc] init];
	a.type = MacroActionMessage;
	a.message = message;
	a.wParam = wParam;
	a.lParam = lParam;
	[self.actions addObject:a];
}

- (void)playbackOnEditor:(ScintillaView *)editor
{
	if (!editor) return;
	for (MacroAction *a in self.actions) {
		if (a.type == MacroActionInsertText) {
			[editor insertText:a.text];
		} else {
			[editor message:a.message wParam:a.wParam lParam:a.lParam];
		}
	}
}

@end
