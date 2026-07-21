cmake_minimum_required(VERSION 3.20)
project(NotepadPlusPlusMac LANGUAGES CXX OBJCXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_OSX_DEPLOYMENT_TARGET "12.0" CACHE STRING "")
set(CMAKE_OSX_ARCHITECTURES "arm64;x86_64" CACHE STRING "")

add_compile_definitions(NDEBUG)
add_compile_options(-fobjc-arc -Wall -Wno-unused-parameter)

set(SCI_ROOT ${CMAKE_SOURCE_DIR}/scintilla)
set(LEX_ROOT ${CMAKE_SOURCE_DIR}/lexilla)
set(MAC_ROOT ${CMAKE_SOURCE_DIR}/PowerEditor/mac)

file(GLOB SCI_SOURCES ${SCI_ROOT}/src/*.cxx)
set(SCI_COCOA
  ${SCI_ROOT}/cocoa/PlatCocoa.mm
  ${SCI_ROOT}/cocoa/ScintillaCocoa.mm
  ${SCI_ROOT}/cocoa/ScintillaView.mm
  ${SCI_ROOT}/cocoa/InfoBar.mm
)
add_library(scintilla STATIC ${SCI_SOURCES} ${SCI_COCOA})
target_include_directories(scintilla PUBLIC
  ${SCI_ROOT}/include ${SCI_ROOT}/src ${SCI_ROOT}/cocoa)
target_link_libraries(scintilla PUBLIC
  "-framework Cocoa" "-framework AppKit" "-framework QuartzCore"
  "-framework CoreText" "-framework Carbon")

file(GLOB LEXLIB_SOURCES ${LEX_ROOT}/lexlib/*.cxx)
file(GLOB LEXER_SOURCES ${LEX_ROOT}/lexers/Lex*.cxx)
list(FILTER LEXER_SOURCES EXCLUDE REGEX "LexUser\\.cxx$")
add_library(lexilla STATIC
  ${LEX_ROOT}/src/Lexilla.cxx
  ${LEXLIB_SOURCES}
  ${LEXER_SOURCES}
  ${MAC_ROOT}/LexUserStub.cxx
)
target_include_directories(lexilla PUBLIC
  ${LEX_ROOT}/include ${LEX_ROOT}/lexlib ${SCI_ROOT}/include)

set(APP_SOURCES
  ${MAC_ROOT}/main.mm
  ${MAC_ROOT}/AppDelegate.mm
  ${MAC_ROOT}/MainWindowController.mm
  ${MAC_ROOT}/EditorDocument.mm
  ${MAC_ROOT}/LanguageMapper.mm
  ${MAC_ROOT}/FindReplaceController.mm
  ${MAC_ROOT}/PreferencesController.mm
  ${MAC_ROOT}/DocumentMapController.mm
  ${MAC_ROOT}/MacroRecorder.mm
  ${MAC_ROOT}/UDLManager.mm
  ${MAC_ROOT}/PluginHost.mm
  ${MAC_ROOT}/SessionStore.mm
)

add_executable(Notepad++ MACOSX_BUNDLE ${APP_SOURCES})
set_target_properties(Notepad++ PROPERTIES
  MACOSX_BUNDLE_INFO_PLIST ${MAC_ROOT}/Info.plist
  MACOSX_BUNDLE_BUNDLE_NAME "Notepad++"
  MACOSX_BUNDLE_GUI_IDENTIFIER "org.notepad-plus-plus.macos"
  OUTPUT_NAME "NotepadPlusPlus"
)
target_include_directories(Notepad++ PRIVATE
  ${MAC_ROOT} ${SCI_ROOT}/include ${SCI_ROOT}/cocoa
  ${LEX_ROOT}/include ${SCI_ROOT}/src)
target_link_libraries(Notepad++ PRIVATE scintilla lexilla
  "-framework Cocoa" "-framework AppKit" "-framework QuartzCore"
  "-framework CoreText" "-framework Carbon")

install(TARGETS Notepad++ BUNDLE DESTINATION .)
