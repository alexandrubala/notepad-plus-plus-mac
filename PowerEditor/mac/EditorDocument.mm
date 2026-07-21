#import "EditorDocument.h"
#import "LanguageMapper.h"
#import "PreferencesController.h"
#import "Scintilla.h"
#import "ILexer.h"
#import "Lexilla.h"

@implementation EditorDocument

- (instancetype)initWithFrame:(NSRect)frame
{
	self = [super init];
	if (self) {
		_editor = [[ScintillaView alloc] initWithFrame:frame];
		_editor.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
		_displayName = @"Untitled";
		_languageName = @"None";
		_dirty = NO;
		_wordWrap = NO;
		_lineNumbersVisible = YES;
		_textEncoding = NSUTF8StringEncoding;
		[self configureDefaults];
	}
	return self;
}

- (void)configureDefaults
{
	[_editor setGeneralProperty:SCI_SETCODEPAGE parameter:0 value:SC_CP_UTF8];
	[_editor setGeneralProperty:SCI_SETMULTIPLESELECTION parameter:0 value:1];
	[_editor setGeneralProperty:SCI_SETADDITIONALSELECTIONTYPING parameter:0 value:1];
	[_editor setGeneralProperty:SCI_SETVIRTUALSPACEOPTIONS parameter:0 value:SCVS_RECTANGULARSELECTION];
	[_editor setGeneralProperty:SCI_SETSCROLLWIDTHTRACKING parameter:0 value:1];
	[_editor setGeneralProperty:SCI_SETEOLMODE parameter:0 value:SC_EOL_LF];

	// Margins: 0 = symbols, 1 = line numbers, 2 = folding
	[_editor setGeneralProperty:SCI_SETMARGINTYPEN parameter:0 value:SC_MARGIN_SYMBOL];
	[_editor setGeneralProperty:SCI_SETMARGINWIDTHN parameter:0 value:16];
	[_editor setGeneralProperty:SCI_SETMARGINTYPEN parameter:1 value:SC_MARGIN_NUMBER];
	[_editor setGeneralProperty:SCI_SETMARGINWIDTHN parameter:1 value:_lineNumbersVisible ? 48 : 0];
	[_editor setGeneralProperty:SCI_SETMARGINTYPEN parameter:2 value:SC_MARGIN_SYMBOL];
	[_editor setGeneralProperty:SCI_SETMARGINMASKN parameter:2 value:SC_MASK_FOLDERS];
	[_editor setGeneralProperty:SCI_SETMARGINWIDTHN parameter:2 value:12];
	[_editor setGeneralProperty:SCI_SETMARGINSENSITIVEN parameter:2 value:1];

	[_editor setGeneralProperty:SCI_MARKERDEFINE parameter:SC_MARKNUM_FOLDEROPEN value:SC_MARK_BOXMINUS];
	[_editor setGeneralProperty:SCI_MARKERDEFINE parameter:SC_MARKNUM_FOLDER value:SC_MARK_BOXPLUS];
	[_editor setGeneralProperty:SCI_MARKERDEFINE parameter:SC_MARKNUM_FOLDERSUB value:SC_MARK_VLINE];
	[_editor setGeneralProperty:SCI_MARKERDEFINE parameter:SC_MARKNUM_FOLDERTAIL value:SC_MARK_LCORNER];
	[_editor setGeneralProperty:SCI_MARKERDEFINE parameter:SC_MARKNUM_FOLDEREND value:SC_MARK_BOXPLUSCONNECTED];
	[_editor setGeneralProperty:SCI_MARKERDEFINE parameter:SC_MARKNUM_FOLDEROPENMID value:SC_MARK_BOXMINUSCONNECTED];
	[_editor setGeneralProperty:SCI_MARKERDEFINE parameter:SC_MARKNUM_FOLDERMIDTAIL value:SC_MARK_TCORNER];

	[_editor message:SCI_SETPROPERTY wParam:(uptr_t)"fold" lParam:(sptr_t)"1"];
	[_editor message:SCI_SETPROPERTY wParam:(uptr_t)"fold.compact" lParam:(sptr_t)"0"];

	[self applyTheme];
	[self setLanguage:_languageName];
	[self applyEditorPreferences];
}

- (void)applyEditorPreferences
{
	PreferencesController *prefs = [PreferencesController sharedController];
	[_editor setGeneralProperty:SCI_SETTABWIDTH parameter:0 value:prefs.tabWidth];
	[_editor setGeneralProperty:SCI_SETUSETABS parameter:0 value:prefs.useTabs ? 1 : 0];
	self.wordWrap = prefs.wordWrap;
	[_editor setGeneralProperty:SCI_SETWRAPMODE parameter:0 value:prefs.wordWrap ? SC_WRAP_WORD : SC_WRAP_NONE];
	[self applyTheme];
}

- (BOOL)isDarkAppearance
{
	NSAppearance *appearance = NSApp.effectiveAppearance;
	NSAppearanceName name = [appearance bestMatchFromAppearancesWithNames:
	    @[NSAppearanceNameAqua, NSAppearanceNameDarkAqua]];
	return [name isEqualToString:NSAppearanceNameDarkAqua];
}

- (void)applyTheme
{
	BOOL dark = [self isDarkAppearance];
	NSString *lexer = [LanguageMapper lexerForDisplayName:self.languageName];
	[LanguageMapper applyStylesToEditor:_editor forLexer:lexer dark:dark];

	PreferencesController *prefs = [PreferencesController sharedController];
	[_editor setStringProperty:SCI_STYLESETFONT parameter:STYLE_DEFAULT value:prefs.fontName];
	[_editor setGeneralProperty:SCI_STYLESETSIZE parameter:STYLE_DEFAULT value:prefs.fontSize];
	[_editor setGeneralProperty:SCI_STYLECLEARALL parameter:0 value:0];
	[LanguageMapper applyStylesToEditor:_editor forLexer:lexer dark:dark];
}

- (void)setLanguage:(NSString *)languageName
{
	_languageName = languageName ?: @"None";
	NSString *lexer = [LanguageMapper lexerForDisplayName:_languageName];
	NSString *sciLexer = [LanguageMapper scintillaLexerName:lexer];

	Scintilla::ILexer5 *pLexer = CreateLexer(sciLexer.UTF8String);
	if (!pLexer) {
		pLexer = CreateLexer("null");
	}
	[_editor setReferenceProperty:SCI_SETILEXER parameter:0 value:pLexer];

	for (int set = 0; set <= 8; set++) {
		[_editor setReferenceProperty:SCI_SETKEYWORDS parameter:set value:""];
	}
	for (int set = 0; set <= 5; set++) {
		const char *kw = [LanguageMapper keywordsForLexer:lexer set:set];
		if (kw && kw[0] != '\0') {
			[_editor setReferenceProperty:SCI_SETKEYWORDS parameter:set value:kw];
		}
	}

	if ([lexer isEqualToString:@"hypertext"] || [lexer isEqualToString:@"xml"]
	    || [lexer isEqualToString:@"phpscript"]) {
		[_editor message:SCI_SETPROPERTY wParam:(uptr_t)"fold.html" lParam:(sptr_t)"1"];
	}

	[self applyTheme];
	[_editor setGeneralProperty:SCI_COLOURISE parameter:0 value:-1];
}

+ (NSArray<NSNumber *> *)loadEncodingCandidates
{
	return @[
		@(NSUTF8StringEncoding),
		@(NSUTF16LittleEndianStringEncoding),
		@(NSUTF16BigEndianStringEncoding),
		@(NSISOLatin1StringEncoding),
		@(NSWindowsCP1252StringEncoding),
		@(NSASCIIStringEncoding),
	];
}

- (BOOL)loadFromPath:(NSString *)path error:(NSError **)error
{
	NSData *data = [NSData dataWithContentsOfFile:path options:0 error:error];
	if (!data) return NO;

	NSString *contents = nil;
	NSStringEncoding used = NSUTF8StringEncoding;
	for (NSNumber *encNum in [EditorDocument loadEncodingCandidates]) {
		NSStringEncoding enc = (NSStringEncoding)encNum.unsignedLongValue;
		NSString *tryStr = [[NSString alloc] initWithData:data encoding:enc];
		if (!tryStr) continue;
		contents = tryStr;
		used = enc;
		break;
	}
	if (!contents) {
		if (error) {
			*error = [NSError errorWithDomain:NSPOSIXErrorDomain code:EINVAL userInfo:@{
				NSLocalizedDescriptionKey: @"Unable to decode file contents"
			}];
		}
		return NO;
	}

	[_editor setString:contents];
	self.textEncoding = used;
	self.filePath = path;
	self.displayName = path.lastPathComponent;
	self.dirty = NO;

	NSString *ext = path.pathExtension;
	NSString *lexer = [LanguageMapper lexerNameForExtension:ext];
	self.languageName = [LanguageMapper displayNameForLexer:lexer];
	[self setLanguage:self.languageName];
	return YES;
}

- (BOOL)saveToPath:(NSString *)path error:(NSError **)error
{
	NSString *contents = [_editor string];
	BOOL ok = [contents writeToFile:path atomically:YES encoding:self.textEncoding error:error];
	if (ok) {
		self.filePath = path;
		self.displayName = path.lastPathComponent;
		self.dirty = NO;
		NSString *ext = path.pathExtension;
		NSString *lexer = [LanguageMapper lexerNameForExtension:ext];
		NSString *display = [LanguageMapper displayNameForLexer:lexer];
		if (![display isEqualToString:self.languageName] && ![lexer isEqualToString:@"null"]) {
			self.languageName = display;
			[self setLanguage:display];
		}
	}
	return ok;
}

- (NSString *)tabTitle
{
	NSString *name = self.displayName ?: @"Untitled";
	return self.dirty ? [@"*" stringByAppendingString:name] : name;
}

- (NSString *)encodingDisplayName
{
	switch (self.textEncoding) {
		case NSUTF8StringEncoding: return @"UTF-8";
		case NSUTF16LittleEndianStringEncoding: return @"UTF-16 LE";
		case NSUTF16BigEndianStringEncoding: return @"UTF-16 BE";
		case NSUTF16StringEncoding: return @"UTF-16";
		case NSISOLatin1StringEncoding: return @"ISO-8859-1";
		case NSWindowsCP1252StringEncoding: return @"Windows-1252";
		case NSASCIIStringEncoding: return @"ASCII";
		default: {
			CFStringRef cName = CFStringConvertEncodingToIANACharSetName(
			    CFStringConvertNSStringEncodingToEncoding(self.textEncoding));
			return cName ? (__bridge NSString *)cName : @"Unknown";
		}
	}
}

- (NSString *)eolDisplayName
{
	long mode = [_editor getGeneralProperty:SCI_GETEOLMODE];
	switch (mode) {
		case SC_EOL_CRLF: return @"Windows (CR LF)";
		case SC_EOL_CR: return @"Macintosh (CR)";
		case SC_EOL_LF:
		default: return @"Unix (LF)";
	}
}

- (NSString *)lengthStatusText
{
	long length = [_editor getGeneralProperty:SCI_GETLENGTH];
	return [NSString stringWithFormat:@"length : %ld", length];
}

- (NSString *)positionStatusText
{
	long pos = [_editor getGeneralProperty:SCI_GETCURRENTPOS];
	long line = [_editor getGeneralProperty:SCI_LINEFROMPOSITION parameter:pos] + 1;
	long col = [_editor getGeneralProperty:SCI_GETCOLUMN parameter:pos] + 1;
	return [NSString stringWithFormat:@"Ln : %ld  Col : %ld  Pos : %ld", line, col, pos];
}

- (NSString *)insertModeStatusText
{
	return [self isOvertype] ? @"OVR" : @"INS";
}

- (BOOL)isOvertype
{
	return [_editor getGeneralProperty:SCI_GETOVERTYPE] != 0;
}

- (void)setOvertype:(BOOL)overtype
{
	[_editor setGeneralProperty:SCI_SETOVERTYPE parameter:0 value:overtype ? 1 : 0];
}

- (void)toggleOvertype
{
	[self setOvertype:![self isOvertype]];
}

+ (BOOL)encodingFromName:(NSString *)name encoding:(NSStringEncoding *)outEncoding
{
	if (!name || !outEncoding) return NO;
	if ([name isEqualToString:@"UTF-8"]) {
		*outEncoding = NSUTF8StringEncoding;
	} else if ([name isEqualToString:@"UTF-16 LE"]) {
		*outEncoding = NSUTF16LittleEndianStringEncoding;
	} else if ([name isEqualToString:@"UTF-16 BE"]) {
		*outEncoding = NSUTF16BigEndianStringEncoding;
	} else if ([name isEqualToString:@"ISO-8859-1"]) {
		*outEncoding = NSISOLatin1StringEncoding;
	} else if ([name isEqualToString:@"Windows-1252"]) {
		*outEncoding = NSWindowsCP1252StringEncoding;
	} else if ([name isEqualToString:@"ASCII"]) {
		*outEncoding = NSASCIIStringEncoding;
	} else {
		return NO;
	}
	return YES;
}

- (void)setEncodingByName:(NSString *)name
{
	NSStringEncoding enc = NSUTF8StringEncoding;
	if (![EditorDocument encodingFromName:name encoding:&enc]) return;
	self.textEncoding = enc;
	self.dirty = YES;
}

- (BOOL)reloadFromDiskWithEncoding:(NSStringEncoding)encoding error:(NSError **)error
{
	if (!self.filePath) {
		if (error) {
			*error = [NSError errorWithDomain:NSPOSIXErrorDomain code:EINVAL userInfo:@{
				NSLocalizedDescriptionKey: @"Document has no file path"
			}];
		}
		return NO;
	}
	NSData *data = [NSData dataWithContentsOfFile:self.filePath options:0 error:error];
	if (!data) return NO;
	NSString *contents = [[NSString alloc] initWithData:data encoding:encoding];
	if (!contents) {
		if (error) {
			*error = [NSError errorWithDomain:NSPOSIXErrorDomain code:EINVAL userInfo:@{
				NSLocalizedDescriptionKey: @"Unable to decode file with the selected encoding"
			}];
		}
		return NO;
	}
	[_editor setString:contents];
	self.textEncoding = encoding;
	self.dirty = NO;
	[_editor setGeneralProperty:SCI_COLOURISE parameter:0 value:-1];
	return YES;
}

- (void)convertToEOLMode:(int)eolMode
{
	[_editor setGeneralProperty:SCI_CONVERTEOLS parameter:0 value:eolMode];
	[_editor setGeneralProperty:SCI_SETEOLMODE parameter:0 value:eolMode];
	self.dirty = YES;
}

- (void)zoomIn
{
	[_editor message:SCI_ZOOMIN];
}

- (void)zoomOut
{
	[_editor message:SCI_ZOOMOUT];
}

- (void)zoomReset
{
	[_editor setGeneralProperty:SCI_SETZOOM parameter:0 value:0];
}

- (void)printDocument
{
	NSPrintInfo *info = [NSPrintInfo sharedPrintInfo];
	info.horizontalPagination = NSPrintingPaginationModeFit;
	info.verticalPagination = NSPrintingPaginationModeAutomatic;
	info.horizontallyCentered = NO;
	info.verticallyCentered = NO;

	NSTextView *printView = [[NSTextView alloc] initWithFrame:NSMakeRect(0, 0, info.paperSize.width - info.leftMargin - info.rightMargin, 100)];
	printView.string = [_editor string] ?: @"";
	printView.font = [NSFont userFixedPitchFontOfSize:10];
	[printView sizeToFit];

	NSPrintOperation *op = [NSPrintOperation printOperationWithView:printView printInfo:info];
	op.showsPrintPanel = YES;
	op.showsProgressPanel = YES;
	[op runOperation];
}

- (NSString *)statusText
{
	return [NSString stringWithFormat:@"%@    |    %@    |    %@    |    %@    |    %@",
	        [self positionStatusText],
	        self.languageName,
	        [self encodingDisplayName],
	        [self eolDisplayName],
	        [self insertModeStatusText]];
}

@end
