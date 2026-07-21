# Contributing

Thanks for helping with **Notepad++ for macOS** — a native Cocoa fork of Notepad++.

This repository is not the upstream Windows project. For Windows Notepad++, see [notepad-plus-plus/notepad-plus-plus](https://github.com/notepad-plus-plus/notepad-plus-plus).

## Reporting issues

1. Search existing issues first.
2. Include macOS version, chip (Apple Silicon / Intel), and how you built the app.
3. Steps to reproduce and expected vs actual behavior help a lot.
4. If relevant, attach a short sample file or screenshot.

## Pull requests

1. One feature or bug fix per PR.
2. Keep diffs focused — avoid unrelated reformatting.
3. Prefer small commits that are easy to review.
4. Base your branch on the latest `master`.
5. Build and smoke-test locally before opening the PR:

```bash
make -f Makefile.mac
make -f Makefile.mac run
```

## Where to work

| Area | Path |
|------|------|
| macOS app (Cocoa UI) | `PowerEditor/mac/` |
| Sample plugin | `PowerEditor/mac/Plugins/` |
| Build | `Makefile.mac`, root `CMakeLists.txt` |
| Editor engine | `scintilla/` (prefer upstream Scintilla changes when possible) |
| Lexers | `lexilla/` (prefer upstream Lexilla changes when possible) |

Most product work belongs under `PowerEditor/mac/`. Treat Scintilla/Lexilla as vendored engines unless the fix is clearly Mac-specific.

## Coding notes

- Objective-C++ / Cocoa with ARC (`clang++`, C++17).
- Match the style of nearby code in `PowerEditor/mac/`.
- Deployment target: macOS 12+.
- Plugin ABI (`.dylib`): `NppMac_GetInfo` / `NppMac_Init` / `NppMac_Cleanup`.

## License

Contributions are accepted under the same terms as the project — see [LICENSE](LICENSE) (GPL-3).
