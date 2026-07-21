# Notepad++ for macOS

Native Cocoa fork of Notepad++ for Apple Silicon (and optionally Universal).
The Mac shell lives under `PowerEditor/mac/` and links Scintilla Cocoa + Lexilla.

## Build

Requires macOS 12+ and Xcode Command Line Tools (`clang++`).

```bash
make -f Makefile.mac          # builds build/mac/Notepad++.app (arm64)
make -f Makefile.mac run      # launch
make -f Makefile.mac dmg      # create DMG
make -f Makefile.mac UNIVERSAL=1   # arm64 + x86_64
```

CMake is also supported via the root `CMakeLists.txt` if installed.

## Features

Multi-tab editing, Open/Save, Find/Replace, syntax highlighting, dark mode,
status bar, preferences, split view, document map, macro record/playback,
UDL data folder, and a `.dylib` plugin ABI
(`NppMac_GetInfo` / `NppMac_Init` / `NppMac_Cleanup`).

## License

Use is governed by the [GPL License](LICENSE).

See the [Notepad++ official site](https://notepad-plus-plus.org/) for the
original Windows project.
