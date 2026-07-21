#import "LanguageMapper.h"
#import "ScintillaView.h"
#import "Scintilla.h"
#import "SciLexer.h"
#import "ILexer.h"
#import "Lexilla.h"

@implementation LanguageMapper

+ (NSString *)lexerNameForExtension:(NSString *)ext
{
	ext = ext.lowercaseString;
	static NSDictionary *map;
	static dispatch_once_t once;
	dispatch_once(&once, ^{
		map = @{
			@"c": @"cpp", @"h": @"cpp", @"cpp": @"cpp", @"cc": @"cpp", @"cxx": @"cpp",
			@"hpp": @"cpp", @"hxx": @"cpp", @"mm": @"cpp", @"m": @"cpp",
			@"py": @"python", @"pyw": @"python",
			@"js": @"cpp", @"jsx": @"cpp", @"ts": @"cpp", @"tsx": @"cpp",
			@"java": @"cpp", @"kt": @"cpp", @"swift": @"cpp",
			@"rs": @"rust", @"go": @"cpp",
			@"html": @"hypertext", @"htm": @"hypertext", @"xhtml": @"hypertext",
			@"xml": @"xml", @"xsl": @"xml", @"svg": @"xml", @"plist": @"xml",
			@"json": @"json", @"css": @"css", @"scss": @"css",
			@"md": @"markdown", @"markdown": @"markdown",
			@"sh": @"bash", @"bash": @"bash", @"zsh": @"bash",
			@"sql": @"sql", @"rb": @"ruby", @"php": @"phpscript",
			@"cs": @"cpp", @"fs": @"cpp", @"r": @"r",
			@"yml": @"yaml", @"yaml": @"yaml", @"toml": @"props",
			@"txt": @"null", @"": @"null"
		};
	});
	NSString *lexer = map[ext ?: @""];
	return lexer ?: @"null";
}

+ (NSString *)displayNameForLexer:(NSString *)lexer
{
	static NSDictionary *map;
	static dispatch_once_t once;
	dispatch_once(&once, ^{
		map = @{
			@"null": @"None", @"cpp": @"C++", @"python": @"Python", @"hypertext": @"HTML",
			@"xml": @"XML", @"json": @"JSON", @"markdown": @"Markdown", @"css": @"CSS",
			@"bash": @"Shell", @"sql": @"SQL", @"rust": @"Rust", @"ruby": @"Ruby",
			@"phpscript": @"PHP", @"yaml": @"YAML", @"r": @"R"
		};
	});
	return map[lexer] ?: lexer.capitalizedString;
}

+ (NSString *)lexerForDisplayName:(NSString *)displayName
{
	static NSDictionary *map;
	static dispatch_once_t once;
	dispatch_once(&once, ^{
		map = @{
			@"None": @"null", @"C++": @"cpp", @"C": @"cpp", @"Python": @"python",
			@"JavaScript": @"cpp", @"HTML": @"hypertext", @"XML": @"xml", @"JSON": @"json",
			@"Markdown": @"markdown", @"Java": @"cpp", @"Swift": @"cpp", @"Rust": @"rust",
			@"Go": @"cpp", @"Shell": @"bash", @"SQL": @"sql", @"CSS": @"css", @"UDL": @"null"
		};
	});
	return map[displayName] ?: @"null";
}

+ (const char *)keywordsForLexer:(NSString *)lexer set:(int)set
{
	if (set != 0) return "";
	if ([lexer isEqualToString:@"cpp"]) {
		return "alignas alignof and and_eq asm auto bitand bitor bool break case catch char "
		       "char8_t char16_t char32_t class compl concept const consteval constexpr constinit "
		       "const_cast continue co_await co_return co_yield decltype default delete do double "
		       "dynamic_cast else enum explicit export extern false final float for friend goto "
		       "if inline int long mutable namespace new noexcept not not_eq nullptr operator or "
		       "or_eq override private protected public register reinterpret_cast requires return "
		       "short signed sizeof static static_assert static_cast struct switch template this "
		       "thread_local throw true try typedef typeid typename union unsigned using virtual "
		       "void volatile wchar_t while xor xor_eq "
		       "int8_t int16_t int32_t int64_t uint8_t uint16_t uint32_t uint64_t size_t ptrdiff_t "
		       "string vector map set unordered_map shared_ptr unique_ptr weak_ptr";
	}
	if ([lexer isEqualToString:@"python"]) {
		return "False None True and as assert async await break class continue def del elif else "
		       "except finally for from global if import in is lambda nonlocal not or pass raise "
		       "return try while with yield match case";
	}
	if ([lexer isEqualToString:@"bash"]) {
		return "if then else elif fi case esac for select while until do done in function time "
		       "coproc true false";
	}
	if ([lexer isEqualToString:@"sql"]) {
		return "select from where insert into update delete create table drop alter index join "
		       "left right inner outer on group by order having as and or not null primary key "
		       "foreign references values set distinct limit offset union all";
	}
	if ([lexer isEqualToString:@"rust"]) {
		return "as async await break const continue crate dyn else enum extern false fn for if "
		       "impl in let loop match mod move mut pub ref return self Self static struct super "
		       "trait true type unsafe use where while async await dyn abstract become box do "
		       "final macro override priv typeof unsized virtual yield";
	}
	return "";
}

+ (void)applyStylesToEditor:(ScintillaView *)editor forLexer:(NSString *)lexer dark:(BOOL)dark
{
	NSColor *fg = dark ? [NSColor colorWithCalibratedWhite:0.9 alpha:1] : [NSColor blackColor];
	NSColor *bg = dark ? [NSColor colorWithCalibratedWhite:0.12 alpha:1] : [NSColor whiteColor];
	NSColor *comment = dark ? [NSColor colorWithCalibratedRed:0.45 green:0.7 blue:0.45 alpha:1]
	                        : [NSColor colorWithCalibratedRed:0.0 green:0.5 blue:0.0 alpha:1];
	NSColor *keyword = dark ? [NSColor colorWithCalibratedRed:0.55 green:0.7 blue:1.0 alpha:1]
	                        : [NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.8 alpha:1];
	NSColor *string = dark ? [NSColor colorWithCalibratedRed:0.9 green:0.55 blue:0.45 alpha:1]
	                       : [NSColor colorWithCalibratedRed:0.6 green:0.1 blue:0.1 alpha:1];
	NSColor *number = dark ? [NSColor colorWithCalibratedRed:0.7 green:0.85 blue:0.55 alpha:1]
	                       : [NSColor colorWithCalibratedRed:0.1 green:0.4 blue:0.4 alpha:1];
	NSColor *lineNum = dark ? [NSColor colorWithCalibratedWhite:0.55 alpha:1]
	                        : [NSColor colorWithCalibratedWhite:0.4 alpha:1];
	NSColor *marginBg = dark ? [NSColor colorWithCalibratedWhite:0.16 alpha:1]
	                         : [NSColor colorWithCalibratedWhite:0.94 alpha:1];

	[editor setStringProperty:SCI_STYLESETFONT parameter:STYLE_DEFAULT value:@"Menlo"];
	[editor setGeneralProperty:SCI_STYLESETSIZE parameter:STYLE_DEFAULT value:13];
	[editor setColorProperty:SCI_STYLESETFORE parameter:STYLE_DEFAULT value:fg];
	[editor setColorProperty:SCI_STYLESETBACK parameter:STYLE_DEFAULT value:bg];
	[editor setGeneralProperty:SCI_STYLECLEARALL parameter:0 value:0];

	[editor setColorProperty:SCI_STYLESETFORE parameter:STYLE_LINENUMBER value:lineNum];
	[editor setColorProperty:SCI_STYLESETBACK parameter:STYLE_LINENUMBER value:marginBg];
	[editor setColorProperty:SCI_SETSELBACK parameter:1 value:
	    (dark ? [NSColor colorWithCalibratedRed:0.25 green:0.35 blue:0.5 alpha:1]
	          : [NSColor selectedTextBackgroundColor])];

	// Generic C-family / python / etc. style indices commonly used by Lexilla
	int commentStyles[] = {1, 2, 3, 23, 24, SCE_C_COMMENT, SCE_C_COMMENTLINE, SCE_C_COMMENTDOC,
	                       SCE_P_COMMENTLINE, SCE_P_COMMENTBLOCK};
	for (size_t i = 0; i < sizeof(commentStyles)/sizeof(commentStyles[0]); i++) {
		[editor setColorProperty:SCI_STYLESETFORE parameter:commentStyles[i] value:comment];
	}
	int keywordStyles[] = {5, SCE_C_WORD, SCE_C_WORD2, SCE_P_WORD};
	for (size_t i = 0; i < sizeof(keywordStyles)/sizeof(keywordStyles[0]); i++) {
		[editor setColorProperty:SCI_STYLESETFORE parameter:keywordStyles[i] value:keyword];
		[editor setGeneralProperty:SCI_STYLESETBOLD parameter:keywordStyles[i] value:1];
	}
	int stringStyles[] = {6, 7, SCE_C_STRING, SCE_C_CHARACTER, SCE_P_STRING, SCE_P_CHARACTER};
	for (size_t i = 0; i < sizeof(stringStyles)/sizeof(stringStyles[0]); i++) {
		[editor setColorProperty:SCI_STYLESETFORE parameter:stringStyles[i] value:string];
	}
	int numberStyles[] = {4, SCE_C_NUMBER, SCE_P_NUMBER};
	for (size_t i = 0; i < sizeof(numberStyles)/sizeof(numberStyles[0]); i++) {
		[editor setColorProperty:SCI_STYLESETFORE parameter:numberStyles[i] value:number];
	}

	[editor setColorProperty:SCI_STYLESETFORE parameter:STYLE_DEFAULT value:fg];
	[editor setColorProperty:SCI_STYLESETBACK parameter:STYLE_DEFAULT value:bg];
	[editor setGeneralProperty:SCI_SETCARETFORE parameter:0 value:(dark ? 0xFFFFFF : 0x000000)];
}

@end
