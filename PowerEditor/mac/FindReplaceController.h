#pragma once
#import <Cocoa/Cocoa.h>

@interface FindReplaceController : NSWindowController
@property (nonatomic, weak) id target; // MainWindowController
@property (nonatomic, strong) NSTextField *findField;
@property (nonatomic, strong) NSTextField *replaceField;
@property (nonatomic, strong) NSButton *caseCheckbox;
@property (nonatomic, strong) NSButton *wordCheckbox;
@property (nonatomic, strong) NSButton *wrapCheckbox;
- (void)showFind;
- (void)showReplace;
- (void)findNext;
- (void)findPrevious;
@end
