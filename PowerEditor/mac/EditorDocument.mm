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
		[self configureDefaults];
	}
	return self;
}

- (void)configureDefaults
{
	PreferencesController *prefs = [PreferencesController sharedController];

	[_editor setGeneralProperty:SCI_SETCODEPAGE parameter:0 value:SC_CP_UTF8];
	[_editor setGeneralProperty:SCI_SETTABWIDTH parameter:0 value:prefs.tabWidth];
	[_editor setGeneralProperty:SCI_SETUSETABS parameter:0 value:prefs.useTabs ? 1 : 0];
	[_editor setGeneralProperty:SCI_SETMULTIPLESELECTION parameter:0 value:1];
	[_editor setGeneralProperty:SCI_SETADDITIONALSELECTIONTYPING parameter:0 value:1];
	[_editor setGeneralProperty:SCI_SETVIRTUALSPACEOPTIONS parameter:0 value:SCVS_RECTANGULARSELECTION];
	[_editor setGeneralProperty:SCI_SETSCROLLWIDTHTRACKING parameter:0 value:1];

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

	if (prefs.wordWrap) {
		self.wordWrap = YES;
		[_editor setGeneralProperty:SCI_SETWRAPMODE parameter:0 value:SC_WRAP_WORD];
	}
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

	Scintilla::ILexer5 *pLexer = CreateLexer(lexer.UTF8String);
	if (!pLexer) {
		pLexer = CreateLexer("null");
	}
	[_editor setReferenceProperty:SCI_SETILEXER parameter:0 value:pLexer];

	const char *kw = [LanguageMapper keywordsForLexer:lexer set:0];
	[_editor setReferenceProperty:SCI_SETKEYWORDS parameter:0 value:kw];

	[self applyTheme];
	[_editor setGeneralProperty:SCI_COLOURISE parameter:0 value:-1];
}

- (BOOL)loadFromPath:(NSString *)path error:(NSError **)error
{
	NSString *contents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:error];
	if (!contents) {
		// Try Latin-1 fallback
		NSData *data = [NSData dataWithContentsOfFile:path options:0 error:error];
		if (!data) return NO;
		contents = [[NSString alloc] initWithData:data encoding:NSISOLatin1StringEncoding];
		if (!contents) return NO;
	}
	[_editor setString:contents];
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
	BOOL ok = [contents writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:error];
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

- (NSString *)statusText
{
	long pos = [_editor getGeneralProperty:SCI_GETCURRENTPOS];
	long line = [_editor getGeneralProperty:SCI_LINEFROMPOSITION parameter:pos] + 1;
	long col = [_editor getGeneralProperty:SCI_GETCOLUMN parameter:pos] + 1;
	long length = [_editor getGeneralProperty:SCI_GETLENGTH];
	long lines = [_editor getGeneralProperty:SCI_GETLINECOUNT];
	return [NSString stringWithFormat:@"Ln %ld, Col %ld    |    %@    |    UTF-8    |    %ld lines    |    %ld bytes",
	        line, col, self.languageName, lines, length];
}

@end
