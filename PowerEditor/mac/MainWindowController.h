#pragma once
#import <Cocoa/Cocoa.h>

@class EditorDocument;
@class FindReplaceController;
@class DocumentMapController;
@class MacroRecorder;

@interface MainWindowController : NSWindowController <NSWindowDelegate, NSTabViewDelegate, NSToolbarDelegate>
@property (nonatomic, strong) NSTabView *tabView;
@property (nonatomic, strong) NSTextField *statusLabel;
@property (nonatomic, strong) NSStackView *statusStack;
@property (nonatomic, strong) NSSplitView *splitView;
@property (nonatomic, strong) NSView *documentMapContainer;
@property (nonatomic, strong) FindReplaceController *findController;
@property (nonatomic, strong) DocumentMapController *documentMap;
@property (nonatomic, strong) MacroRecorder *macroRecorder;
@property (nonatomic, assign) BOOL splitEnabled;
@property (nonatomic, assign) BOOL documentMapVisible;

- (EditorDocument *)currentDocument;
- (void)openPath:(NSString *)path;
- (void)newDocument:(id)sender;
- (void)openDocument:(id)sender;
- (void)saveDocument:(id)sender;
- (void)saveDocumentAs:(id)sender;
- (void)saveAllDocuments:(id)sender;
- (void)closeDocument:(id)sender;
- (void)closeAllDocuments:(id)sender;
- (void)printDocument:(id)sender;
@end
