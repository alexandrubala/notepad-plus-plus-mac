What is Notepad++ ?
===================

[![GitHub release](https://img.shields.io/github/release/notepad-plus-plus/notepad-plus-plus.svg)](../../releases/latest)&nbsp;&nbsp;&nbsp;&nbsp;[![Build Status](https://img.shields.io/github/actions/workflow/status/notepad-plus-plus/notepad-plus-plus/CI_build.yml)](https://github.com/notepad-plus-plus/notepad-plus-plus/actions/workflows/CI_build.yml)
&nbsp;&nbsp;&nbsp;&nbsp;[![Join the discussions at https://community.notepad-plus-plus.org/](https://notepad-plus-plus.org/assets/images/NppCommunityBadge.svg)](https://community.notepad-plus-plus.org/)

Notepad++ is a free (free as in both "free speech" and "free beer") source code
editor and Notepad replacement that supports several programming languages and
natural languages. Running in the MS Windows environment, its use is governed by
[GPL License](LICENSE).

See the [Notepad++ official site](https://notepad-plus-plus.org/) for more information.

macOS (Apple Silicon) native build
----------------------------------

This fork includes a **native Cocoa** shell under `PowerEditor/mac/` that links
Scintilla Cocoa + Lexilla and builds a `Notepad++.app` for Apple Silicon (and
optionally Universal).

```bash
make -f Makefile.mac          # builds build/mac/Notepad++.app (arm64)
make -f Makefile.mac run      # launch
make -f Makefile.mac dmg      # create DMG
make -f Makefile.mac UNIVERSAL=1   # arm64 + x86_64
```

Requires macOS 12+ and Xcode Command Line Tools (`clang++`). CMake is also
supported via the root `CMakeLists.txt` if installed.

Features in the Mac shell: multi-tab editing, Open/Save, Find/Replace, syntax
highlighting, dark mode, status bar, preferences, split view, document map,
macro record/playback, UDL data folder, and a `.dylib` plugin ABI
(`NppMac_GetInfo` / `NppMac_Init` / `NppMac_Cleanup`).


Notepad++ GPG Release Key
-------------------------
_Since the release of version 7.6.5 Notepad++ is signed using GPG with the following key:_

- **Signer:** Notepad++
- **E-mail:** don.h@free.fr
- **Key ID:** 0x8D84F46E
- **Key fingerprint:** 14BC E436 2749 B2B5 1F8C 7122 6C42 9F1D 8D84 F46E
- **Key type:** RSA 4096/4096
- **Created:** 2019-03-11
- **Expires:** 2027-03-13

https://github.com/notepad-plus-plus/notepad-plus-plus/blob/master/nppGpgPub.asc


Supported OS
------------

All the Windows systems still supported by Microsoft are supported by Notepad++. However, not all Notepad++ users can or want to use the newest system. Here is the [Supported systems information](SUPPORTED_SYSTEM.md) you may need in case you are one of them.




Build Notepad++
---------------

Please follow [build guide](BUILD.md) to build Notepad++ from source.


Contribution
------------

Contributions are welcome. Be mindful of our [Contribution Rules](CONTRIBUTING.md) to increase the likelihood of your contribution getting accepted.

[Notepad++ Contributors](https://github.com/notepad-plus-plus/notepad-plus-plus/graphs/contributors)
