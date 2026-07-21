#pragma once
#import <Foundation/Foundation.h>

@interface LanguageMapper : NSObject
+ (NSString *)lexerNameForExtension:(NSString *)ext;
+ (NSString *)displayNameForLexer:(NSString *)lexer;
+ (NSString *)lexerForDisplayName:(NSString *)displayName;
/// Maps logical language keys (e.g. javascript) to Lexilla CreateLexer names (e.g. cpp).
+ (NSString *)scintillaLexerName:(NSString *)lexer;
+ (const char *)keywordsForLexer:(NSString *)lexer set:(int)set;
+ (void)applyStylesToEditor:(id)editor forLexer:(NSString *)lexer dark:(BOOL)dark;
@end
