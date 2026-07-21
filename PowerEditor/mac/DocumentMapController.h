#pragma once
#import <Cocoa/Cocoa.h>
@class ScintillaView;

@interface DocumentMapController : NSViewController
@property (nonatomic, strong) ScintillaView *mapView;
- (void)syncFromEditor:(ScintillaView *)editor;
@end
