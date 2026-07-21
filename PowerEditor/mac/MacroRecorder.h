#pragma once
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MacroActionType) {
	MacroActionInsertText,
	MacroActionMessage
};

@interface MacroAction : NSObject
@property (nonatomic, assign) MacroActionType type;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign) unsigned int message;
@property (nonatomic, assign) long wParam;
@property (nonatomic, assign) long lParam;
@end

@interface MacroRecorder : NSObject
@property (nonatomic, assign, readonly) BOOL recording;
@property (nonatomic, strong) NSMutableArray<MacroAction *> *actions;
- (void)startRecording;
- (void)stopRecording;
- (void)recordInsertText:(NSString *)text;
- (void)recordMessage:(unsigned int)message wParam:(long)wParam lParam:(long)lParam;
- (void)playbackOnEditor:(id)editor;
@end
