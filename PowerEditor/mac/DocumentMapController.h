#pragma once
#import <Cocoa/Cocoa.h>
@class ScintillaView;

@interface DocumentMapController : NSViewController
@property (nonatomic, strong) ScintillaView *mapView;
@property (nonatomic, weak) ScintillaView *linkedEditor;
- (void)syncFromEditor:(ScintillaView *)editor;
@end
