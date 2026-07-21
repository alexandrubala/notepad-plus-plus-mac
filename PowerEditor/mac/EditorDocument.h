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
- (instancetype)initWithFrame:(NSRect)frame;
- (void)configureDefaults;
- (void)applyTheme;
- (void)setLanguage:(NSString *)languageName;
- (BOOL)loadFromPath:(NSString *)path error:(NSError **)error;
- (BOOL)saveToPath:(NSString *)path error:(NSError **)error;
- (NSString *)statusText;
@end
