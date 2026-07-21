// Stub UDL lexer for macOS — full LexUser.cxx is Windows-specific (windows.h).
// Provides lmUserDefine so Lexilla catalogue links; colouring is null-style for now.
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stdarg.h>
#include <assert.h>
#include <ctype.h>

#include <string>
#include <string_view>

#include "ILexer.h"
#include "Scintilla.h"
#include "SciLexer.h"

#include "WordList.h"
#include "LexAccessor.h"
#include "Accessor.h"
#include "StyleContext.h"
#include "CharacterSet.h"
#include "LexerModule.h"

using namespace Lexilla;

#ifndef SCLEX_USER
#define SCLEX_USER 152
#endif

static void ColouriseUserDoc(Sci_PositionU startPos, Sci_Position length, int, WordList *[],
                             Accessor &styler) {
	if (length > 0) {
		styler.StartAt(startPos + length - 1);
		styler.StartSegment(startPos + length - 1);
		styler.ColourTo(startPos + length - 1, 0);
	}
}

static void FoldUserDoc(Sci_PositionU, Sci_Position, int, WordList *[], Accessor &) {
}

extern const LexerModule lmUserDefine(SCLEX_USER, ColouriseUserDoc, "user", FoldUserDoc);
