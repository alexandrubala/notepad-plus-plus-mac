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
	BOOL isHTML = [lexer isEqualToString:@"hypertext"] || [lexer isEqualToString:@"xml"];
	if (isHTML) {
		if (set == 0) {
			return "^data- a abbr accept accept-charset accesskey acronym action address align "
			       "alink alt applet archive area article aside async audio autocomplete autofocus "
			       "axis b background base basefont bdi bdo bgcolor bgsound big blink blockquote "
			       "body border br button canvas caption cellpadding cellspacing center char "
			       "charoff charset checkbox checked cite class classid clear code codebase "
			       "codetype col colgroup color cols colspan command compact content "
			       "contenteditable contextmenu coords data datafld dataformatas datalist "
			       "datapagesize datasrc datetime dd declare defer del details dfn dialog dir "
			       "disabled div dl draggable dropzone dt element em embed enctype event face "
			       "fieldset figcaption figure file font footer for form formaction formenctype "
			       "formmethod formnovalidate formtarget frame frameborder frameset h1 h2 h3 h4 "
			       "h5 h6 head header headers height hgroup hidden hr href hreflang hspace html "
			       "http-equiv i id iframe image img input ins isindex ismap kbd keygen label "
			       "lang language leftmargin legend li link list listing longdesc main manifest "
			       "map marginheight marginwidth mark marquee max maxlength media menu menuitem "
			       "meta meter method min minlength multicol multiple name nav nobr noembed "
			       "noframes nohref noresize noscript noshade novalidate nowrap object ol onabort "
			       "onafterprint onautocomplete onautocompleteerror onbeforeonload onbeforeprint "
			       "onblur oncancel oncanplay oncanplaythrough onchange onclick onclose "
			       "oncontextmenu oncuechange ondblclick ondrag ondragend ondragenter ondragleave "
			       "ondragover ondragstart ondrop ondurationchange onemptied onended onerror "
			       "onfocus onhashchange oninput oninvalid onkeydown onkeypress onkeyup onload "
			       "onloadeddata onloadedmetadata onloadstart onmessage onmousedown onmouseenter "
			       "onmouseleave onmousemove onmouseout onmouseover onmouseup onmousewheel "
			       "onoffline ononline onpagehide onpageshow onpause onplay onplaying "
			       "onpointercancel onpointerdown onpointerenter onpointerleave onpointerlockchange "
			       "onpointerlockerror onpointermove onpointerout onpointerover onpointerup "
			       "onpopstate onprogress onratechange onreadystatechange onredo onreset onresize "
			       "onscroll onseeked onseeking onselect onshow onsort onstalled onstorage "
			       "onsubmit onsuspend ontimeupdate ontoggle onundo onunload onvolumechange "
			       "onwaiting optgroup option output p param password pattern picture placeholder "
			       "plaintext pre profile progress prompt public q radio readonly rel required "
			       "reset rev reversed role rows rowspan rp rt rtc ruby rules s samp sandbox "
			       "scheme scope scoped script seamless section select selected shadow shape size "
			       "sizes small source spacer span spellcheck src srcdoc srcset standby start "
			       "step strike strong style sub submit summary sup svg svg:svg tabindex table "
			       "target tbody td template text textarea tfoot th thead time title topmargin tr "
			       "track tt type u ul usemap valign value valuetype var version video vlink "
			       "vspace wbr width xml xmlns xmp";
		}
		if (set == 5) {
			return "ATTLIST DOCTYPE ELEMENT ENTITY NOTATION";
		}
		return "";
	}
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

	// HTML / XML use SCE_H_* style IDs that overlap C-family indices — override after generics
	if ([lexer isEqualToString:@"hypertext"] || [lexer isEqualToString:@"xml"]) {
		NSColor *tag = dark ? [NSColor colorWithCalibratedRed:0.45 green:0.7 blue:1.0 alpha:1]
		                    : [NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.85 alpha:1];
		NSColor *attr = dark ? [NSColor colorWithCalibratedRed:0.95 green:0.55 blue:0.45 alpha:1]
		                     : [NSColor colorWithCalibratedRed:0.85 green:0.0 blue:0.0 alpha:1];
		NSColor *entity = dark ? [NSColor colorWithCalibratedRed:0.85 green:0.75 blue:0.4 alpha:1]
		                       : [NSColor colorWithCalibratedRed:0.5 green:0.35 blue:0.0 alpha:1];
		NSColor *cdata = dark ? [NSColor colorWithCalibratedRed:0.95 green:0.65 blue:0.35 alpha:1]
		                      : [NSColor colorWithCalibratedRed:0.9 green:0.45 blue:0.0 alpha:1];
		NSColor *unknown = dark ? [NSColor colorWithCalibratedWhite:0.65 alpha:1]
		                        : [NSColor colorWithCalibratedWhite:0.25 alpha:1];
		NSColor *jsKeyword = keyword;
		NSColor *jsComment = comment;
		NSColor *jsString = string;
		NSColor *jsNumber = number;

		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_H_DEFAULT value:fg];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_H_TAG value:tag];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_H_TAGEND value:tag];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_H_TAGUNKNOWN value:unknown];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_H_ATTRIBUTE value:attr];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_H_ATTRIBUTEUNKNOWN value:unknown];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_H_NUMBER value:number];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_H_DOUBLESTRING value:string];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_H_SINGLESTRING value:string];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_H_OTHER value:fg];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_H_COMMENT value:comment];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_H_ENTITY value:entity];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_H_CDATA value:cdata];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_H_VALUE value:cdata];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_H_QUESTION value:tag];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_H_SGML_DEFAULT value:fg];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_H_SGML_COMMAND value:tag];
		[editor setGeneralProperty:SCI_STYLESETBOLD parameter:SCE_H_SGML_COMMAND value:1];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_H_SGML_1ST_PARAM value:attr];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_H_SGML_DOUBLESTRING value:string];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_H_SGML_SIMPLESTRING value:string];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_H_SGML_COMMENT value:comment];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_H_SGML_BLOCK_DEFAULT value:fg];

		// Embedded JavaScript inside <script>
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_HJ_DEFAULT value:fg];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_HJ_COMMENT value:jsComment];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_HJ_COMMENTLINE value:jsComment];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_HJ_COMMENTDOC value:jsComment];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_HJ_NUMBER value:jsNumber];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_HJ_WORD value:fg];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_HJ_KEYWORD value:jsKeyword];
		[editor setGeneralProperty:SCI_STYLESETBOLD parameter:SCE_HJ_KEYWORD value:1];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_HJ_DOUBLESTRING value:jsString];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_HJ_SINGLESTRING value:jsString];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_HJ_REGEX value:cdata];
	}

	[editor setColorProperty:SCI_STYLESETFORE parameter:STYLE_DEFAULT value:fg];
	[editor setColorProperty:SCI_STYLESETBACK parameter:STYLE_DEFAULT value:bg];
	[editor setGeneralProperty:SCI_SETCARETFORE parameter:0 value:(dark ? 0xFFFFFF : 0x000000)];
}

@end
