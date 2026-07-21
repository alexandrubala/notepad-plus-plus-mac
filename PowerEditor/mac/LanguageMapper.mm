#import "LanguageMapper.h"
#import "ScintillaView.h"
#import "Scintilla.h"
#import "SciLexer.h"

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
			@"js": @"javascript", @"jsx": @"javascript", @"mjs": @"javascript",
			@"ts": @"typescript", @"tsx": @"typescript",
			@"java": @"java", @"kt": @"java",
			@"swift": @"swift",
			@"rs": @"rust", @"go": @"go",
			@"html": @"hypertext", @"htm": @"hypertext", @"xhtml": @"hypertext",
			@"xml": @"xml", @"xsl": @"xml", @"svg": @"xml", @"plist": @"xml",
			@"json": @"json", @"jsonc": @"json", @"json5": @"json",
			@"css": @"css", @"scss": @"css", @"less": @"css",
			@"md": @"markdown", @"markdown": @"markdown",
			@"sh": @"bash", @"bash": @"bash", @"zsh": @"bash",
			@"sql": @"sql", @"rb": @"ruby", @"php": @"phpscript",
			@"cs": @"csharp", @"fs": @"csharp", @"r": @"r",
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
			@"null": @"None", @"cpp": @"C++", @"python": @"Python",
			@"javascript": @"JavaScript", @"typescript": @"TypeScript",
			@"hypertext": @"HTML", @"xml": @"XML", @"json": @"JSON",
			@"markdown": @"Markdown", @"css": @"CSS",
			@"bash": @"Shell", @"sql": @"SQL", @"rust": @"Rust", @"ruby": @"Ruby",
			@"phpscript": @"PHP", @"yaml": @"YAML", @"r": @"R",
			@"java": @"Java", @"swift": @"Swift", @"go": @"Go", @"csharp": @"C#"
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
			@"JavaScript": @"javascript", @"TypeScript": @"typescript",
			@"HTML": @"hypertext", @"XML": @"xml", @"JSON": @"json",
			@"Markdown": @"markdown", @"Java": @"java", @"Swift": @"swift",
			@"Rust": @"rust", @"Go": @"go", @"Shell": @"bash", @"SQL": @"sql",
			@"CSS": @"css", @"YAML": @"yaml", @"Ruby": @"ruby", @"PHP": @"phpscript",
			@"C#": @"csharp", @"R": @"r"
		};
	});
	return map[displayName] ?: @"null";
}

+ (NSString *)scintillaLexerName:(NSString *)lexer
{
	static NSDictionary *aliases;
	static dispatch_once_t once;
	dispatch_once(&once, ^{
		aliases = @{
			@"javascript": @"cpp",
			@"typescript": @"cpp",
			@"java": @"cpp",
			@"swift": @"cpp",
			@"go": @"cpp",
			@"csharp": @"cpp",
		};
	});
	return aliases[lexer] ?: lexer;
}

+ (const char *)keywordsForLexer:(NSString *)lexer set:(int)set
{
	BOOL isHTML = [lexer isEqualToString:@"hypertext"] || [lexer isEqualToString:@"xml"]
	              || [lexer isEqualToString:@"phpscript"];
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
			       "onafterprint onblur oncancel oncanplay oncanplaythrough onchange onclick "
			       "onclose oncontextmenu oncuechange ondblclick ondrag ondragend ondragenter "
			       "ondragleave ondragover ondragstart ondrop ondurationchange onemptied onended "
			       "onerror onfocus onhashchange oninput oninvalid onkeydown onkeypress onkeyup "
			       "onload onloadeddata onloadedmetadata onloadstart onmessage onmousedown "
			       "onmouseenter onmouseleave onmousemove onmouseout onmouseover onmouseup "
			       "onmousewheel onoffline ononline onpagehide onpageshow onpause onplay "
			       "onplaying onpopstate onprogress onratechange onreset onresize onscroll "
			       "onseeked onseeking onselect onshow onstalled onstorage onsubmit onsuspend "
			       "ontimeupdate ontoggle onunload onvolumechange onwaiting optgroup option "
			       "output p param password pattern picture placeholder plaintext pre profile "
			       "progress prompt public q radio readonly rel required reset rev reversed "
			       "role rows rowspan rp rt rtc ruby rules s samp sandbox scheme scope scoped "
			       "script seamless section select selected shadow shape size sizes small source "
			       "spacer span spellcheck src srcdoc srcset standby start step strike strong "
			       "style sub submit summary sup svg svg:svg tabindex table target tbody td "
			       "template text textarea tfoot th thead time title topmargin tr track tt type "
			       "u ul usemap valign value valuetype var version video vlink vspace wbr width "
			       "xml xmlns xmp";
		}
		if (set == 5) {
			return "ATTLIST DOCTYPE ELEMENT ENTITY NOTATION";
		}
		return "";
	}

	if ([lexer isEqualToString:@"css"]) {
		if (set == 0) {
			return "align-content align-items align-self all animation appearance backdrop-filter "
			       "backface-visibility background background-attachment background-blend-mode "
			       "background-clip background-color background-image background-origin "
			       "background-position background-repeat background-size border border-bottom "
			       "border-collapse border-color border-image border-left border-radius "
			       "border-right border-spacing border-style border-top border-width bottom "
			       "box-shadow box-sizing break-after break-before break-inside caption-side "
			       "caret-color clear clip clip-path color column-count column-gap column-rule "
			       "column-span column-width columns content counter-increment counter-reset "
			       "cursor direction display empty-cells filter flex flex-basis flex-direction "
			       "flex-flow flex-grow flex-shrink flex-wrap float font font-family font-feature-settings "
			       "font-kerning font-size font-style font-variant font-weight gap grid "
			       "grid-area grid-auto-columns grid-auto-flow grid-auto-rows grid-column "
			       "grid-row grid-template grid-template-areas grid-template-columns "
			       "grid-template-rows height hyphens image-rendering inset isolation "
			       "justify-content justify-items justify-self left letter-spacing line-break "
			       "line-height list-style list-style-image list-style-position list-style-type "
			       "margin margin-bottom margin-left margin-right margin-top mask max-height "
			       "max-width min-height min-width mix-blend-mode object-fit object-position "
			       "opacity order outline outline-color outline-offset outline-style "
			       "outline-width overflow overflow-wrap overflow-x overflow-y padding "
			       "padding-bottom padding-left padding-right padding-top perspective "
			       "place-content place-items place-self pointer-events position quotes resize "
			       "right row-gap scroll-behavior tab-size table-layout text-align "
			       "text-decoration text-decoration-color text-decoration-line text-indent "
			       "text-overflow text-shadow text-transform text-wrap top transform "
			       "transform-origin transition transition-delay transition-duration "
			       "transition-property transition-timing-function user-select vertical-align "
			       "visibility white-space width will-change word-break word-spacing "
			       "word-wrap writing-mode z-index zoom";
		}
		if (set == 1) {
			return "active after before checked disabled empty enabled first-child first-letter "
			       "first-line first-of-type focus focus-visible focus-within hover in-range "
			       "indeterminate invalid lang last-child last-of-type link not nth-child "
			       "nth-last-child nth-of-type only-child only-of-type optional out-of-range "
			       "placeholder-shown read-only read-write required root target valid visited";
		}
		return "";
	}

	if ([lexer isEqualToString:@"json"]) {
		if (set == 0) return "false null true";
		if (set == 1) return "@id @context @type @value @language @container @list @set @reverse @index @base @vocab @graph";
		return "";
	}

	if ([lexer isEqualToString:@"yaml"]) {
		if (set == 0) return "true false yes no on off null";
		return "";
	}

	if (set != 0) return "";

	if ([lexer isEqualToString:@"javascript"] || [lexer isEqualToString:@"typescript"]) {
		return "abstract async await boolean break byte case catch char class const continue "
		       "debugger default delete do double else enum export extends final finally float "
		       "for function goto if implements import in instanceof int interface let long "
		       "native new null of package private protected public return short static super "
		       "switch synchronized this throw throws transient try typeof var void volatile "
		       "while with true false prototype yield undefined Infinity NaN "
		       "as from type interface namespace declare module readonly satisfies keyof infer "
		       "never unknown any bigint symbol unique asserts is";
	}
	if ([lexer isEqualToString:@"java"]) {
		return "abstract assert boolean break byte case catch char class const continue default "
		       "do double else enum extends final finally float for goto if implements import "
		       "instanceof int interface long native new null package private protected public "
		       "return short static strictfp super switch synchronized this throw throws "
		       "transient try void volatile while true false var record sealed permits "
		       "non-sealed yield";
	}
	if ([lexer isEqualToString:@"go"]) {
		return "break case chan const continue default defer else fallthrough for func go goto "
		       "if import interface map package range return select struct switch type var "
		       "bool byte complex64 complex128 error float32 float64 int int8 int16 int32 "
		       "int64 rune string uint uint8 uint16 uint32 uint64 uintptr true false iota nil "
		       "append cap close complex copy delete imag len make new panic print println "
		       "real recover any comparable";
	}
	if ([lexer isEqualToString:@"swift"]) {
		return "associatedtype class deinit enum extension func import init inout internal let "
		       "operator private protocol public static struct subscript typealias var break case "
		       "continue default defer do else fallthrough for guard if in repeat return switch "
		       "where while as Any catch false is nil rethrows super self Self throw throws true "
		       "try #available #colorLiteral #column #else #elseif #endif #file #fileLiteral "
		       "fileID #function #if #imageLiteral #line #selector #sourceLocation #typeInfo "
		       "async await actor isolated nonisolated some borrowing consuming";
	}
	if ([lexer isEqualToString:@"csharp"]) {
		return "abstract as base bool break byte case catch char checked class const continue "
		       "decimal default delegate do double else enum event explicit extern false finally "
		       "fixed float for foreach goto if implicit in int interface internal is lock long "
		       "namespace new null object operator out override params private protected public "
		       "readonly ref return sbyte sealed short sizeof stackalloc static string struct "
		       "switch this throw true try typeof uint ulong unchecked unsafe ushort using "
		       "virtual void volatile while async await dynamic nameof when var record "
		       "init required nint nuint";
	}
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
		       "trait true type unsafe use where while abstract become box do final macro "
		       "override priv typeof unsized virtual yield";
	}
	if ([lexer isEqualToString:@"ruby"]) {
		return "BEGIN END alias and begin break case class def defined? do else elsif end ensure "
		       "false for if in module next nil not or redo rescue retry return self super then "
		       "true undef unless until when while yield __FILE__ __LINE__";
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
	NSColor *tag = dark ? [NSColor colorWithCalibratedRed:0.45 green:0.7 blue:1.0 alpha:1]
	                    : [NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.85 alpha:1];
	NSColor *attr = dark ? [NSColor colorWithCalibratedRed:0.95 green:0.55 blue:0.45 alpha:1]
	                     : [NSColor colorWithCalibratedRed:0.85 green:0.0 blue:0.0 alpha:1];
	NSColor *accent = dark ? [NSColor colorWithCalibratedRed:0.85 green:0.75 blue:0.4 alpha:1]
	                       : [NSColor colorWithCalibratedRed:0.5 green:0.35 blue:0.0 alpha:1];
	NSColor *cdata = dark ? [NSColor colorWithCalibratedRed:0.95 green:0.65 blue:0.35 alpha:1]
	                      : [NSColor colorWithCalibratedRed:0.9 green:0.45 blue:0.0 alpha:1];
	NSColor *preprocessor = dark ? [NSColor colorWithCalibratedRed:0.75 green:0.55 blue:0.85 alpha:1]
	                             : [NSColor colorWithCalibratedRed:0.5 green:0.25 blue:0.0 alpha:1];

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

	NSString *sciLexer = [self scintillaLexerName:lexer];
	BOOL isCFamily = [sciLexer isEqualToString:@"cpp"] || [sciLexer isEqualToString:@"rust"];
	BOOL isPython = [lexer isEqualToString:@"python"];

	if (isCFamily || isPython) {
		int commentStyles[] = {SCE_C_COMMENT, SCE_C_COMMENTLINE, SCE_C_COMMENTDOC,
		                       SCE_C_COMMENTLINEDOC, SCE_C_PREPROCESSORCOMMENT,
		                       SCE_C_PREPROCESSORCOMMENTDOC,
		                       SCE_P_COMMENTLINE, SCE_P_COMMENTBLOCK};
		for (size_t i = 0; i < sizeof(commentStyles)/sizeof(commentStyles[0]); i++) {
			[editor setColorProperty:SCI_STYLESETFORE parameter:commentStyles[i] value:comment];
		}
		int keywordStyles[] = {SCE_C_WORD, SCE_C_WORD2, SCE_P_WORD, SCE_P_WORD2};
		for (size_t i = 0; i < sizeof(keywordStyles)/sizeof(keywordStyles[0]); i++) {
			[editor setColorProperty:SCI_STYLESETFORE parameter:keywordStyles[i] value:keyword];
			[editor setGeneralProperty:SCI_STYLESETBOLD parameter:keywordStyles[i] value:1];
		}
		int stringStyles[] = {SCE_C_STRING, SCE_C_CHARACTER, SCE_C_STRINGRAW, SCE_C_VERBATIM,
		                      SCE_C_TRIPLEVERBATIM, SCE_C_HASHQUOTEDSTRING, SCE_C_REGEX,
		                      SCE_P_STRING, SCE_P_CHARACTER, SCE_P_TRIPLE, SCE_P_TRIPLEDOUBLE,
		                      SCE_P_FSTRING, SCE_P_FCHARACTER, SCE_P_FTRIPLE, SCE_P_FTRIPLEDOUBLE};
		for (size_t i = 0; i < sizeof(stringStyles)/sizeof(stringStyles[0]); i++) {
			[editor setColorProperty:SCI_STYLESETFORE parameter:stringStyles[i] value:string];
		}
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_C_NUMBER value:number];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_P_NUMBER value:number];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_C_PREPROCESSOR value:preprocessor];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_P_CLASSNAME value:tag];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_P_DEFNAME value:accent];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_P_DECORATOR value:preprocessor];
		[editor setGeneralProperty:SCI_STYLESETBOLD parameter:SCE_P_CLASSNAME value:1];
	}

	if ([lexer isEqualToString:@"hypertext"] || [lexer isEqualToString:@"xml"]
	    || [lexer isEqualToString:@"phpscript"]) {
		NSColor *unknown = dark ? [NSColor colorWithCalibratedWhite:0.65 alpha:1]
		                        : [NSColor colorWithCalibratedWhite:0.25 alpha:1];

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
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_H_ENTITY value:accent];
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

		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_HJ_DEFAULT value:fg];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_HJ_COMMENT value:comment];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_HJ_COMMENTLINE value:comment];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_HJ_COMMENTDOC value:comment];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_HJ_NUMBER value:number];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_HJ_WORD value:fg];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_HJ_KEYWORD value:keyword];
		[editor setGeneralProperty:SCI_STYLESETBOLD parameter:SCE_HJ_KEYWORD value:1];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_HJ_DOUBLESTRING value:string];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_HJ_SINGLESTRING value:string];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_HJ_REGEX value:cdata];
	}

	if ([lexer isEqualToString:@"phpscript"]) {
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_HPHP_DEFAULT value:fg];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_HPHP_HSTRING value:string];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_HPHP_SIMPLESTRING value:string];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_HPHP_WORD value:keyword];
		[editor setGeneralProperty:SCI_STYLESETBOLD parameter:SCE_HPHP_WORD value:1];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_HPHP_NUMBER value:number];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_HPHP_VARIABLE value:attr];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_HPHP_COMMENT value:comment];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_HPHP_COMMENTLINE value:comment];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_HPHP_OPERATOR value:fg];
	}

	if ([lexer isEqualToString:@"css"]) {
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_CSS_DEFAULT value:fg];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_CSS_TAG value:tag];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_CSS_CLASS value:attr];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_CSS_PSEUDOCLASS value:cdata];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_CSS_UNKNOWN_PSEUDOCLASS value:fg];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_CSS_OPERATOR value:fg];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_CSS_IDENTIFIER value:keyword];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_CSS_UNKNOWN_IDENTIFIER value:fg];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_CSS_VALUE value:number];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_CSS_COMMENT value:comment];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_CSS_ID value:accent];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_CSS_IMPORTANT value:attr];
		[editor setGeneralProperty:SCI_STYLESETBOLD parameter:SCE_CSS_IMPORTANT value:1];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_CSS_DIRECTIVE value:preprocessor];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_CSS_DOUBLESTRING value:string];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_CSS_SINGLESTRING value:string];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_CSS_ATTRIBUTE value:attr];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_CSS_PSEUDOELEMENT value:cdata];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_CSS_GROUP_RULE value:preprocessor];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_CSS_VARIABLE value:accent];
	}

	if ([lexer isEqualToString:@"json"]) {
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_JSON_DEFAULT value:fg];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_JSON_NUMBER value:number];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_JSON_STRING value:string];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_JSON_STRINGEOL value:string];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_JSON_PROPERTYNAME value:tag];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_JSON_ESCAPESEQUENCE value:accent];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_JSON_LINECOMMENT value:comment];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_JSON_BLOCKCOMMENT value:comment];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_JSON_OPERATOR value:fg];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_JSON_URI value:keyword];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_JSON_KEYWORD value:keyword];
		[editor setGeneralProperty:SCI_STYLESETBOLD parameter:SCE_JSON_KEYWORD value:1];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_JSON_LDKEYWORD value:attr];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_JSON_ERROR value:attr];
	}

	if ([lexer isEqualToString:@"markdown"]) {
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_MARKDOWN_DEFAULT value:fg];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_MARKDOWN_LINE_BEGIN value:fg];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_MARKDOWN_STRONG1 value:attr];
		[editor setGeneralProperty:SCI_STYLESETBOLD parameter:SCE_MARKDOWN_STRONG1 value:1];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_MARKDOWN_STRONG2 value:attr];
		[editor setGeneralProperty:SCI_STYLESETBOLD parameter:SCE_MARKDOWN_STRONG2 value:1];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_MARKDOWN_EM1 value:cdata];
		[editor setGeneralProperty:SCI_STYLESETITALIC parameter:SCE_MARKDOWN_EM1 value:1];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_MARKDOWN_EM2 value:cdata];
		[editor setGeneralProperty:SCI_STYLESETITALIC parameter:SCE_MARKDOWN_EM2 value:1];
		int headers[] = {SCE_MARKDOWN_HEADER1, SCE_MARKDOWN_HEADER2, SCE_MARKDOWN_HEADER3,
		                 SCE_MARKDOWN_HEADER4, SCE_MARKDOWN_HEADER5, SCE_MARKDOWN_HEADER6};
		for (size_t i = 0; i < sizeof(headers)/sizeof(headers[0]); i++) {
			[editor setColorProperty:SCI_STYLESETFORE parameter:headers[i] value:tag];
			[editor setGeneralProperty:SCI_STYLESETBOLD parameter:headers[i] value:1];
		}
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_MARKDOWN_ULIST_ITEM value:keyword];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_MARKDOWN_OLIST_ITEM value:keyword];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_MARKDOWN_BLOCKQUOTE value:comment];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_MARKDOWN_STRIKEOUT value:lineNum];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_MARKDOWN_HRULE value:accent];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_MARKDOWN_LINK value:keyword];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_MARKDOWN_CODE value:string];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_MARKDOWN_CODE2 value:string];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_MARKDOWN_CODEBK value:string];
	}

	if ([lexer isEqualToString:@"yaml"]) {
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_YAML_DEFAULT value:fg];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_YAML_COMMENT value:comment];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_YAML_IDENTIFIER value:tag];
		[editor setGeneralProperty:SCI_STYLESETBOLD parameter:SCE_YAML_IDENTIFIER value:1];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_YAML_KEYWORD value:keyword];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_YAML_NUMBER value:number];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_YAML_REFERENCE value:accent];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_YAML_DOCUMENT value:preprocessor];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_YAML_TEXT value:string];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_YAML_ERROR value:attr];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_YAML_OPERATOR value:fg];
	}

	if ([lexer isEqualToString:@"bash"]) {
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_SH_DEFAULT value:fg];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_SH_ERROR value:attr];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_SH_COMMENTLINE value:comment];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_SH_NUMBER value:number];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_SH_WORD value:keyword];
		[editor setGeneralProperty:SCI_STYLESETBOLD parameter:SCE_SH_WORD value:1];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_SH_STRING value:string];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_SH_CHARACTER value:string];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_SH_OPERATOR value:fg];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_SH_IDENTIFIER value:fg];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_SH_SCALAR value:attr];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_SH_PARAM value:accent];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_SH_BACKTICKS value:cdata];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_SH_HERE_DELIM value:preprocessor];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_SH_HERE_Q value:string];
	}

	if ([lexer isEqualToString:@"ruby"]) {
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_RB_DEFAULT value:fg];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_RB_ERROR value:attr];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_RB_COMMENTLINE value:comment];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_RB_POD value:comment];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_RB_NUMBER value:number];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_RB_WORD value:keyword];
		[editor setGeneralProperty:SCI_STYLESETBOLD parameter:SCE_RB_WORD value:1];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_RB_STRING value:string];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_RB_CHARACTER value:string];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_RB_CLASSNAME value:tag];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_RB_DEFNAME value:accent];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_RB_OPERATOR value:fg];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_RB_IDENTIFIER value:fg];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_RB_REGEX value:cdata];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_RB_GLOBAL value:attr];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_RB_SYMBOL value:accent];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_RB_MODULE_NAME value:tag];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_RB_INSTANCE_VAR value:attr];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_RB_CLASS_VAR value:attr];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_RB_BACKTICKS value:cdata];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_RB_STRING_Q value:string];
		[editor setColorProperty:SCI_STYLESETFORE parameter:SCE_RB_STRING_QQ value:string];
	}

	if ([lexer isEqualToString:@"sql"]) {
		[editor setColorProperty:SCI_STYLESETFORE parameter:1 value:comment]; // comment
		[editor setColorProperty:SCI_STYLESETFORE parameter:2 value:comment];
		[editor setColorProperty:SCI_STYLESETFORE parameter:4 value:number];
		[editor setColorProperty:SCI_STYLESETFORE parameter:5 value:keyword];
		[editor setGeneralProperty:SCI_STYLESETBOLD parameter:5 value:1];
		[editor setColorProperty:SCI_STYLESETFORE parameter:6 value:string];
		[editor setColorProperty:SCI_STYLESETFORE parameter:7 value:string];
	}

	[editor setColorProperty:SCI_STYLESETFORE parameter:STYLE_DEFAULT value:fg];
	[editor setColorProperty:SCI_STYLESETBACK parameter:STYLE_DEFAULT value:bg];
	[editor setGeneralProperty:SCI_SETCARETFORE parameter:0 value:(dark ? 0xFFFFFF : 0x000000)];
}

@end
