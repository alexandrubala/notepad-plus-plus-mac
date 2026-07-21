#pragma once
#import <Foundation/Foundation.h>

@interface LanguageMapper : NSObject
+ (NSString *)lexerNameForExtension:(NSString *)ext;
+ (NSString *)displayNameForLexer:(NSString *)lexer;
+ (NSString *)lexerForDisplayName:(NSString *)displayName;
+ (const char *)keywordsForLexer:(NSString *)lexer set:(int)set;
+ (void)applyStylesToEditor:(id)editor forLexer:(NSString *)lexer dark:(BOOL)dark;
@end
