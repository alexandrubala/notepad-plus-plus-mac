#pragma once
#import <Cocoa/Cocoa.h>
#import "ScintillaView.h"

@interface EditorDocument : NSObject
@property (nonatomic, strong) ScintillaView *editor;
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, copy) NSString *displayName;
@property (nonatomic, copy) NSString *languageName;
@property (nonatomic, assign) BOOL dirty;
@property (nonatomic, assign) BOOL wordWrap;
@property (nonatomic, assign) BOOL lineNumbersVisible;
@property (nonatomic, assign) NSStringEncoding textEncoding;

- (instancetype)initWithFrame:(NSRect)frame;
- (void)configureDefaults;
- (void)applyTheme;
- (void)setLanguage:(NSString *)languageName;
- (BOOL)loadFromPath:(NSString *)path error:(NSError **)error;
- (BOOL)saveToPath:(NSString *)path error:(NSError **)error;

- (NSString *)tabTitle;
- (NSString *)encodingDisplayName;
- (NSString *)eolDisplayName;
- (NSString *)lengthStatusText;
- (NSString *)positionStatusText;
- (NSString *)insertModeStatusText;
- (BOOL)isOvertype;
- (void)setOvertype:(BOOL)overtype;
- (void)toggleOvertype;
- (void)setEncodingByName:(NSString *)name;
- (void)convertToEOLMode:(int)eolMode;
- (void)zoomIn;
- (void)zoomOut;
- (void)zoomReset;
- (void)printDocument;
- (NSString *)statusText;
@end
